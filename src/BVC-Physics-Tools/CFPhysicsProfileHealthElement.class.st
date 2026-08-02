"I show low-frequency memory and runtime instance trends for one Physics world."
Class {
	#name : 'CFPhysicsProfileHealthElement',
	#superclass : 'BrVerticalPane',
	#instVars : [ 'world', 'telemetryUpdatesStream', 'content', 'samples', 'lastSampleMilliseconds', 'running' ],
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
	lastSampleMilliseconds := nil.
	running := false.
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
				anError class = AsyncFutureCancelled
					ifFalse: [ anElement showNotification: anError asNotification ] ] ].
	self addChild: content.
	self renderStopped
]

{ #category : 'profiling' }
CFPhysicsProfileHealthElement >> startProfiling [
	samples removeAll.
	lastSampleMilliseconds := nil.
	running := true.
	self sampleNow
]

{ #category : 'profiling' }
CFPhysicsProfileHealthElement >> stopProfiling [
	running := false.
	content ifNotNil: [ content asyncFuture interrupt ]
]

{ #category : 'private - sampling' }
CFPhysicsProfileHealthElement >> sampleIfDue [
	| now |
	running ifFalse: [ ^ self ].
	now := Time millisecondClockValue.
	(lastSampleMilliseconds isNil or: [ now - lastSampleMilliseconds >= 30000 ])
		ifTrue: [ self sampleNow ]
]

{ #category : 'private - sampling' }
CFPhysicsProfileHealthElement >> sampleNow [
	running ifFalse: [ ^ self ].
	lastSampleMilliseconds := Time millisecondClockValue.
	content asyncFuture future: [ self collectSample ] asAsyncFuture
]

{ #category : 'private - sampling' }
CFPhysicsProfileHealthElement >> collectSample [
	^ {
		#timestamp -> DateAndTime now.
		#heapSize -> (Smalltalk vm parameterAt: 3).
		#rows -> {
			self rowNamed: 'PhysicsBody' actual: CFPhysicsBody allInstances size expected: world members size.
			self rowNamed: 'PhysicsContact' actual: CFPhysicsContact allInstances size expected: world activeContacts size.
			self rowNamed: 'PhysicsJoint' actual: (CFPhysicsJoint withAllSubclasses inject: 0 into: [ :total :each | total + each allInstances size ]) expected: world joints size.
			self rowNamed: 'PhysicsIsland' actual: CFPhysicsIsland allInstances size expected: world persistentIslandGraph islands size.
			self rowNamed: 'PhysicsWorldSolution' actual: CFPhysicsWorldSolution allInstances size expected: (world activeSolveTicket ifNil: [ 0 ] ifNotNil: [ 1 ]).
			self rowNamed: 'PhysicsTelemetryLogger' actual: CFPhysicsTelemetryLogger allInstances size expected: (world hasTelemetryLogger ifTrue: [ 1 ] ifFalse: [ 0 ]) }
	} asDictionary
]

{ #category : 'private - sampling' }
CFPhysicsProfileHealthElement >> rowNamed: aName actual: actualCount expected: expectedCount [
	^ {
		#name -> aName.
		#actual -> actualCount.
		#expected -> expectedCount.
		#difference -> (actualCount - expectedCount) } asDictionary
]

{ #category : 'private - updating' }
CFPhysicsProfileHealthElement >> acceptSample: aSample [
	running ifFalse: [ ^ self ].
	samples add: aSample.
	[ samples size > 20 ] whileTrue: [ samples removeFirst ].
	self renderSample: aSample
]

{ #category : 'private - updating' }
CFPhysicsProfileHealthElement >> renderSample: aSample [
	| heapDelta |
	content removeChildren.
	heapDelta := (aSample at: #heapSize) - (samples first at: #heapSize).
	content addChild: (BrLabel new
		hMatchParent;
		vExact: 30;
		aptitude: BrGlamorousLabelAptitude new;
		text: 'Image heap  ', (aSample at: #heapSize) humanReadableSISizeString,
			'  (', (self signedSizeString: heapDelta), ') ', self heapTrend;
		yourself).
	content addChild: (BrLabel new
		vFitContent;
		aptitude: (BrGlamorousLabelAptitude new foreground: (Color black alpha: 0.58));
		text: 'Instances / expected (difference), sampled every 30 seconds';
		yourself).
	(aSample at: #rows) do: [ :row | content addChild: (self labelForRow: row) ].
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
CFPhysicsProfileHealthElement >> labelForRow: row [
	| difference sign |
	difference := row at: #difference.
	sign := difference > 0 ifTrue: [ '+' ] ifFalse: [ '' ].
	^ BrLabel new
		hMatchParent;
		vExact: 28;
		aptitude: (BrGlamorousLabelAptitude new foreground: (Color black alpha: 0.78));
		text: (row at: #name), '  ',
			(row at: #actual) asString, '/',
			(row at: #expected) asString, ' (', sign, difference asString, ') ',
			(self trendFor: (row at: #name));
		yourself
]

{ #category : 'private - analysis' }
CFPhysicsProfileHealthElement >> trendFor: aName [
	| differences first last delta tolerance |
	samples size < 3 ifTrue: [ ^ '·' ].
	differences := samples collect: [ :sample |
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
	| first last tolerance |
	samples size < 3 ifTrue: [ ^ '·' ].
	first := samples first at: #heapSize.
	last := samples last at: #heapSize.
	tolerance := 10 * 1024 * 1024.
	last - first > tolerance ifTrue: [ ^ '↗' ].
	first - last > tolerance ifTrue: [ ^ '↘' ].
	^ '→'
]

{ #category : 'private - analysis' }
CFPhysicsProfileHealthElement >> alerts [
	| result firstHeap lastHeap |
	result := OrderedCollection new.
	samples size < 3 ifTrue: [ ^ result ].
	firstHeap := samples first at: #heapSize.
	lastHeap := samples last at: #heapSize.
	lastHeap - firstHeap > (100 * 1024 * 1024) ifTrue: [
		result add: '⚠ Image heap has increased by ', (lastHeap - firstHeap) humanReadableSISizeString, '.' ].
	(samples last at: #rows) do: [ :row |
		(self trendFor: (row at: #name)) = '↗' ifTrue: [
			result add: '⚠ ', (row at: #name), ' excess instance count is increasing.' ] ].
	^ result
]

{ #category : 'private - formatting' }
CFPhysicsProfileHealthElement >> signedSizeString: byteCount [
	byteCount > 0 ifTrue: [ ^ '+', byteCount humanReadableSISizeString ].
	^ byteCount humanReadableSISizeString
]

{ #category : 'hooks - scene graph' }
CFPhysicsProfileHealthElement >> onRemovedFromSceneGraph [
	self stopProfiling.
	super onRemovedFromSceneGraph
]
