"I show low-frequency memory and runtime instance trends for one Physics world."
Class {
	#name : 'CFPhysicsProfileHealthElement',
	#superclass : 'BrVerticalPane',
	#instVars : [ 'world', 'telemetryUpdatesStream', 'content', 'samples', 'retentionSamples', 'lastSampleMilliseconds', 'lastRetentionSampleMilliseconds', 'running', 'sampling' ],
	#category : 'BVC-Physics-Tools',
	#package : 'BVC-Physics-Tools'
}

{ #category : 'instance creation' }
CFPhysicsProfileHealthElement class >> world: aWorld [
	^ self new
		world: aWorld;
		build;
		yourself
]

{ #category : 'initialization' }
CFPhysicsProfileHealthElement >> initialize [
	super initialize.
	samples := OrderedCollection new.
	retentionSamples := OrderedCollection new.
	lastSampleMilliseconds := nil.
	lastRetentionSampleMilliseconds := nil.
	running := false.
	sampling := false.
	self
		hMatchParent;
		vFitContent;
		cellSpacing: 6;
		padding: (BlInsets all: 12)
]

{ #category : 'accessing' }
CFPhysicsProfileHealthElement >> world: aWorld [
	world := aWorld.
	telemetryUpdatesStream := CFPhysicsTelemetryStream on: world.
	self withAsyncSinkDo: [ :anElementSink |
		anElementSink
			sink: AsyncPeekSink new;
			whenUpdate: [ :anElement :aSink |
				aSink peek ifSome: [ anElement sampleIfDue ] ];
			forwardStream: telemetryUpdatesStream ]
]

{ #category : 'building' }
CFPhysicsProfileHealthElement >> build [
	self removeChildren.
	content := BrVerticalPane new
		hMatchParent;
		vFitContent;
		cellSpacing: 4;
		yourself.
	content withAsyncFutureDo: [ :anElementFuture |
		anElementFuture
			executionConfiguration: (AsyncFutureExecutionConfiguration new
				customGroup: #'Physics Profile Health');
			cancelSoft;
			whenSuccess: [ :anElement :sample | self acceptSample: sample ];
			whenError: [ :anElement :anError |
				sampling := false.
				anError class = AsyncFutureCancelled
					ifFalse: [ anElement showNotification: anError asNotification ] ] ].
	self addChild: content.
	self renderStopped
]

{ #category : 'profiling' }
CFPhysicsProfileHealthElement >> startProfiling [
	samples removeAll.
	retentionSamples removeAll.
	lastSampleMilliseconds := nil.
	lastRetentionSampleMilliseconds := nil.
	sampling := false.
	running := true.
	self sampleNow
]

{ #category : 'profiling' }
CFPhysicsProfileHealthElement >> stopProfiling [
	running := false.
	sampling := false.
	content ifNotNil: [ content asyncFuture interrupt ]
]

{ #category : 'profiling' }
CFPhysicsProfileHealthElement >> collectRetainedNow [
	(running and: [ sampling not ]) ifFalse: [ ^ self ].
	sampling := true.
	content asyncFuture future: [ self collectRetentionSample ] asAsyncFuture
]

{ #category : 'private - sampling' }
CFPhysicsProfileHealthElement >> sampleIfDue [
	| now |
	(running and: [ sampling not ]) ifFalse: [ ^ self ].
	now := Time millisecondClockValue.
	(lastRetentionSampleMilliseconds isNil
		or: [ now - lastRetentionSampleMilliseconds >= 600000 ])
		ifTrue: [ ^ self collectRetainedNow ].
	(lastSampleMilliseconds isNil or: [ now - lastSampleMilliseconds >= 30000 ])
		ifTrue: [ self sampleNow ]
]

{ #category : 'private - sampling' }
CFPhysicsProfileHealthElement >> sampleNow [
	(running and: [ sampling not ]) ifFalse: [ ^ self ].
	lastSampleMilliseconds := Time millisecondClockValue.
	sampling := true.
	content asyncFuture future: [ self collectSample ] asAsyncFuture
]

{ #category : 'private - sampling' }
CFPhysicsProfileHealthElement >> collectRetentionSample [
	Smalltalk garbageCollect.
	500 milliSeconds wait.
	Smalltalk garbageCollect.
	^ self collectSample
		at: #retention put: true;
		yourself
]

{ #category : 'private - sampling' }
CFPhysicsProfileHealthElement >> collectSample [
	| bodies contacts joints islands solutions loggers |
	bodies := CFPhysicsBody allInstances.
	contacts := CFPhysicsContact allInstances.
	joints := CFPhysicsJoint withAllSubclasses
		flatCollect: [ :each | each allInstances ].
	islands := CFPhysicsIsland allInstances.
	solutions := CFPhysicsWorldSolution allInstances.
	loggers := CFPhysicsTelemetryLogger allInstances.
	^ {
		#timestamp -> DateAndTime now.
		#retention -> false.
		#heapSize -> (Smalltalk vm parameterAt: 3).
		#rows -> {
			self rowNamed: 'PhysicsBody'
				total: bodies size
				owned: (bodies count: [ :each | each world == world ])
				expected: world members size.
			self rowNamed: 'PhysicsContact'
				total: contacts size
				owned: (contacts count: [ :each | each firstBody world == world ])
				expected: world activeContacts size.
			self rowNamed: 'PhysicsJoint'
				total: joints size
				owned: (joints count: [ :each | self joint: each belongsTo: world ])
				expected: world joints size.
			self rowNamed: 'PhysicsIsland'
				total: islands size
				owned: (islands count: [ :each | self island: each belongsTo: world ])
				expected: world persistentIslandGraph islands size.
			self rowNamed: 'PhysicsWorldSolution'
				total: solutions size
				owned: (solutions count: [ :each | each world == world ])
				expected: (world activeSolveTicket ifNil: [ 0 ] ifNotNil: [ 1 ]).
			self rowNamed: 'PhysicsTelemetryLogger'
				total: loggers size
				owned: (loggers count: [ :each | each world == world ])
				expected: (world hasTelemetryLogger ifTrue: [ 1 ] ifFalse: [ 0 ]) }
	} asDictionary
]

{ #category : 'private - sampling' }
CFPhysicsProfileHealthElement >> rowNamed: aName total: totalCount owned: ownedCount expected: expectedCount [
	^ {
		#name -> aName.
		#total -> totalCount.
		#owned -> ownedCount.
		#expected -> expectedCount.
		#difference -> (ownedCount - expectedCount) } asDictionary
]

{ #category : 'private - sampling' }
CFPhysicsProfileHealthElement >> joint: aJoint belongsTo: aWorld [
	| body |
	body := aJoint bodyA ifNil: [ aJoint bodyB ].
	^ body notNil and: [ body world == aWorld ]
]

{ #category : 'private - sampling' }
CFPhysicsProfileHealthElement >> island: anIsland belongsTo: aWorld [
	^ anIsland bodies anySatisfy: [ :body | body world == aWorld ]
]

{ #category : 'private - updating' }
CFPhysicsProfileHealthElement >> acceptSample: aSample [
	sampling := false.
	running ifFalse: [ ^ self ].
	(aSample at: #retention)
		ifTrue: [
			lastRetentionSampleMilliseconds := Time millisecondClockValue.
			retentionSamples add: aSample.
			[ retentionSamples size > 100 ] whileTrue: [ retentionSamples removeFirst ] ]
		ifFalse: [
			samples add: aSample.
			[ samples size > 20 ] whileTrue: [ samples removeFirst ] ].
	self renderSample: aSample
]

{ #category : 'private - updating' }
CFPhysicsProfileHealthElement >> renderSample: aSample [
	| heapDelta retainedSample |
	content removeChildren.
	heapDelta := (aSample at: #heapSize) - (self baselineSample at: #heapSize).
	content addChild: (BrLabel new
		hMatchParent;
		vExact: 30;
		aptitude: BrGlamorousLabelAptitude new;
		text: 'Image heap  ', (aSample at: #heapSize) humanReadableSISizeString,
			'  (', (self signedSizeString: heapDelta), ') ', self heapTrend;
		yourself).
	retainedSample := retentionSamples ifEmpty: [ nil ] ifNotEmpty: [ retentionSamples last ].
	retainedSample
		ifNil: [
			content addChild: (BrLabel new
				vFitContent;
				aptitude: (BrGlamorousLabelAptitude new foreground: (Color black alpha: 0.58));
				text: 'Current instances. Use Collect to establish retained counts after garbage collection.';
				yourself).
			(aSample at: #rows) do: [ :row | content addChild: (self labelForCurrentRow: row) ] ]
		ifNotNil: [
			content addChild: (BrLabel new
				vFitContent;
				aptitude: (BrGlamorousLabelAptitude new foreground: (Color black alpha: 0.58));
				text: 'After GC: image / world / expected (world difference). Current pre-GC counts shown below.';
				yourself).
			(retainedSample at: #rows) do: [ :row |
				content addChild: (self labelForRetainedRow: row currentSample: aSample) ] ].
	self alerts do: [ :alert |
		content addChild: (BrLabel new
			hMatchParent;
			vFitContent;
			aptitude: (BrGlamorousLabelAptitude new foreground: Color orange muchDarker);
			text: alert;
			yourself) ]
]

{ #category : 'private - updating' }
CFPhysicsProfileHealthElement >> renderStopped [
	content removeChildren.
	content addChild: (BrLabel new
		vFitContent;
		aptitude: (BrGlamorousLabelAptitude new foreground: (Color black alpha: 0.58));
		text: 'Start profiling to collect health samples.';
		yourself)
]

{ #category : 'private - building' }
CFPhysicsProfileHealthElement >> labelForCurrentRow: row [
	^ BrLabel new
		hMatchParent;
		vExact: 28;
		aptitude: (BrGlamorousLabelAptitude new foreground: (Color black alpha: 0.78));
		text: (row at: #name), '  ', (self rowSummary: row), ' ·';
		yourself
]

{ #category : 'private - building' }
CFPhysicsProfileHealthElement >> labelForRetainedRow: row currentSample: currentSample [
	| currentRow |
	currentRow := (currentSample at: #rows)
		detect: [ :each | (each at: #name) = (row at: #name) ].
	^ BrLabel new
		hMatchParent;
		vExact: 42;
		aptitude: (BrGlamorousLabelAptitude new foreground: (Color black alpha: 0.78));
		text: (row at: #name), '  ', (self rowSummary: row), ' ',
			(self retentionTrendFor: (row at: #name)), String cr,
			'Current  ', (self rowSummary: currentRow);
		yourself
]

{ #category : 'private - building' }
CFPhysicsProfileHealthElement >> rowSummary: row [
	| difference sign |
	difference := row at: #difference.
	sign := difference > 0 ifTrue: [ '+' ] ifFalse: [ '' ].
	^ (row at: #total) asString, '/',
		(row at: #owned) asString, '/',
		(row at: #expected) asString, ' (', sign, difference asString, ')'
]

{ #category : 'private - analysis' }
CFPhysicsProfileHealthElement >> baselineSample [
	retentionSamples ifNotEmpty: [ ^ retentionSamples first ].
	samples ifNotEmpty: [ ^ samples first ].
	^ { #heapSize -> 0 } asDictionary
]

{ #category : 'private - analysis' }
CFPhysicsProfileHealthElement >> retentionTrendFor: aName [
	| differences first last delta tolerance |
	retentionSamples size < 3 ifTrue: [ ^ '·' ].
	differences := retentionSamples collect: [ :sample |
		((sample at: #rows) detect: [ :row | (row at: #name) = aName ]) at: #difference ].
	first := differences first.
	last := differences last.
	delta := last - first.
	tolerance := ((first abs max: last abs) * 0.05) ceiling max: 2.
	delta > tolerance ifTrue: [ ^ '↗' ].
	delta < tolerance negated ifTrue: [ ^ '↘' ].
	^ '→'
]

{ #category : 'private - analysis' }
CFPhysicsProfileHealthElement >> heapTrend [
	| source first last tolerance |
	source := retentionSamples size >= 3
		ifTrue: [ retentionSamples ]
		ifFalse: [ samples ].
	source size < 3 ifTrue: [ ^ '·' ].
	first := source first at: #heapSize.
	last := source last at: #heapSize.
	tolerance := 10 * 1024 * 1024.
	last - first > tolerance ifTrue: [ ^ '↗' ].
	first - last > tolerance ifTrue: [ ^ '↘' ].
	^ '→'
]

{ #category : 'private - analysis' }
CFPhysicsProfileHealthElement >> alerts [
	| result firstHeap lastHeap |
	result := OrderedCollection new.
	retentionSamples size < 3 ifTrue: [ ^ result ].
	firstHeap := retentionSamples first at: #heapSize.
	lastHeap := retentionSamples last at: #heapSize.
	lastHeap - firstHeap > (100 * 1024 * 1024) ifTrue: [
		result add: '⚠ Image heap after GC has increased by ',
			(lastHeap - firstHeap) humanReadableSISizeString, '.' ].
	(retentionSamples last at: #rows) do: [ :row |
		(self retentionTrendFor: (row at: #name)) = '↗' ifTrue: [
			result add: '⚠ ', (row at: #name),
				' retained excess instance count is increasing after GC.' ] ].
	^ result
]
