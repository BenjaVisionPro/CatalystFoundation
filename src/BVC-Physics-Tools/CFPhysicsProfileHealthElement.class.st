"I show low-frequency memory and runtime instance trends for one Physics world."
Class {
	#name : 'CFPhysicsProfileHealthElement',
	#superclass : 'BrVerticalPane',
	#instVars : [ 'world', 'telemetryUpdatesStream', 'content', 'scrollPane', 'samples', 'retentionSamples', 'lastSampleMilliseconds', 'lastRetentionSampleMilliseconds', 'running', 'sampling', 'liveContent', 'profileContent', 'latestPhysicsData' ],
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
		vMatchParent
]

{ #category : 'accessing' }
CFPhysicsProfileHealthElement >> world: aWorld [
	world := aWorld.
	telemetryUpdatesStream := CFPhysicsTelemetryStream on: world.
	self withAsyncSinkDo: [ :anElementSink |
		anElementSink
			sink: AsyncPeekSink new;
			whenUpdate: [ :anElement :aSink |
				aSink peek ifSome: [ anElement updateLiveHealth. anElement sampleIfDue ] ];
			forwardStream: telemetryUpdatesStream ]
]

{ #category : 'building' }
CFPhysicsProfileHealthElement >> build [
	self removeChildren.
	content := BrVerticalPane new
		hMatchParent;
		vFitContent;
		cellSpacing: 4;
		padding: (BlInsets all: 6);
		yourself.
	liveContent := BrVerticalPane new
		hMatchParent;
		vFitContent;
		cellSpacing: 3;
		yourself.
	profileContent := BrVerticalPane new
		hMatchParent;
		vFitContent;
		cellSpacing: 2;
		yourself.
	content addChild: liveContent; addChild: profileContent.
	profileContent withAsyncFutureDo: [ :anElementFuture |
		anElementFuture
			executionConfiguration: (AsyncFutureExecutionConfiguration new
				customGroup: #'Physics Profile Health');
			cancelSoft;
			whenSuccess: [ :anElement :sample | self acceptSample: sample ];
			whenError: [ :anElement :anError |
				sampling := false.
				anError class = AsyncFutureCancelled
					ifFalse: [ anElement showNotification: anError asNotification ] ] ].
	scrollPane := BrScrollPane new
		allowMeAndChildrenMouseEvents;
		aptitude: BrScrollPaneAptitude + BrGlamorousWithVerticalScrollbarAptitude;
		hMatchParent;
		vMatchParent;
		content: content;
		yourself.
	self addChild: scrollPane.
	self updateLiveHealth.
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
	profileContent ifNotNil: [ profileContent asyncFuture interrupt ]
]

{ #category : 'profiling' }
CFPhysicsProfileHealthElement >> collectRetainedNow [
	(running and: [ sampling not ]) ifFalse: [ ^ self ].
	sampling := true.
	profileContent asyncFuture future: [ self collectRetentionSample ] asAsyncFuture
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
	profileContent asyncFuture future: [ self collectSample ] asAsyncFuture
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
	| bodies contacts joints islands worldStates backgroundSteps solutions pipelineResults loggers |
	bodies := CFPhysicsBody allInstances.
	contacts := CFPhysicsContact allInstances.
	joints := CFPhysicsJoint withAllSubclasses
		flatCollect: [ :each | each allInstances ].
	islands := CFPhysicsIsland allInstances.
	worldStates := CFPhysicsWorldState allInstances.
	backgroundSteps := CFPhysicsWorldBackgroundStep allInstances.
	solutions := CFPhysicsWorldSolution allInstances.
	pipelineResults := CFPhysicsStepPipelineResult allInstances.
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
				expected: world contacts size.
			self
				jointRetentionRowFrom: joints
				worldStates: worldStates
				backgroundSteps: backgroundSteps
				solutions: solutions
				pipelineResults: pipelineResults.
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
CFPhysicsProfileHealthElement >> jointRetentionRowFrom: allJoints worldStates: allWorldStates backgroundSteps: allBackgroundSteps solutions: allSolutions pipelineResults: allPipelineResults [
	| related live captured unexplained |
	related := (allJoints select: [ :each | self joint: each belongsTo: world ]) asIdentitySet.
	live := (allJoints select: [ :each | each world == world ]) asIdentitySet.
	captured := (allJoints select: [ :each |
		each world isNil and: [ each solverCommitTarget world == world ] ]) asIdentitySet.
	unexplained := related reject: [ :each |
		(live includes: each) or: [ captured includes: each ] ].
	^ {
		#name -> 'PhysicsJoint'.
		#total -> allJoints size.
		#owned -> related size.
		#live -> live size.
		#captured -> captured size.
		#unexplained -> unexplained size.
		#difference -> unexplained size.
		#worldStateCount -> (allWorldStates count: [ :each | each world == world ]).
		#backgroundStepCount -> (allBackgroundSteps count: [ :each |
			each state notNil and: [ each state world == world ] ]).
		#solutionCount -> (allSolutions count: [ :each | each world == world ]).
		#pipelineResultCount -> (allPipelineResults count: [ :each |
			self pipelineResult: each belongsTo: world ]) } asDictionary
]

{ #category : 'private - sampling' }
CFPhysicsProfileHealthElement >> pipelineResult: aPipelineResult belongsTo: aWorld [
	^ aPipelineResult joints anySatisfy: [ :joint |
		joint solverCommitTarget world == aWorld ]
]

{ #category : 'private - sampling' }
CFPhysicsProfileHealthElement >> isJointRetentionRow: row [
	^ row includesKey: #live
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
	((aJoint respondsTo: #endpointPair)
		and: [ aJoint endpointPair isNil ]) ifTrue: [ ^ false ].
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
	profileContent removeChildren.
	heapDelta := (aSample at: #heapSize) - (self baselineSample at: #heapSize).
	profileContent addChild: (BrLabel new
		hMatchParent;
		vExact: 30;
		aptitude: BrGlamorousLabelAptitude new;
		text: 'Image heap  ', (aSample at: #heapSize) humanReadableSISizeString,
			'  (', (heapDelta >= 0 ifTrue: [ '+' ] ifFalse: [ '' ]),
			heapDelta humanReadableSISizeString, ') ', self heapTrend;
		yourself).
	retainedSample := retentionSamples ifEmpty: [ nil ] ifNotEmpty: [ retentionSamples last ].
	retainedSample
		ifNil: [
			profileContent addChild: (BrLabel new
				vFitContent;
				aptitude: (BrGlamorousLabelAptitude new foreground: (Color black alpha: 0.58));
				text: 'Current instances. Use Collect to establish retained counts after garbage collection.';
				yourself).
			(aSample at: #rows) do: [ :row | profileContent addChild: (self labelForCurrentRow: row) ] ]
		ifNotNil: [
			profileContent addChild: (BrLabel new
				vFitContent;
				aptitude: (BrGlamorousLabelAptitude new foreground: (Color black alpha: 0.58));
				text: 'Retained counts follow two garbage collections. Current counts show allocation pressure before collection.';
				yourself).
			(retainedSample at: #rows) do: [ :row |
				profileContent addChild: (self labelForRetainedRow: row currentSample: aSample) ] ].
	self alerts do: [ :alert |
		profileContent addChild: (BrLabel new
			hMatchParent;
			vFitContent;
			aptitude: (BrGlamorousLabelAptitude new foreground: Color orange muchDarker);
			text: alert;
			yourself) ]
]

{ #category : 'private - updating' }
CFPhysicsProfileHealthElement >> renderStopped [
	profileContent removeChildren.
	profileContent addChild: (BrLabel new
		vFitContent;
		aptitude: (BrGlamorousLabelAptitude new foreground: (Color black alpha: 0.58));
		text: 'Start profiling to collect health samples.';
		yourself)
]

{ #category : 'private - building' }
CFPhysicsProfileHealthElement >> labelForCurrentRow: row [
	^ BrLabel new
		hMatchParent;
		vFitContent;
		padding: (BlInsets top: 3 right: 0 bottom: 5 left: 0);
		aptitude: (BrGlamorousLabelAptitude new foreground: (Color black alpha: 0.78));
		text: (row at: #name), String cr,
			'Current   ', (self currentSummaryFor: row);
		yourself
]

{ #category : 'private - building' }
CFPhysicsProfileHealthElement >> labelForRetainedRow: row currentSample: currentSample [
	| currentRow |
	currentRow := (currentSample at: #rows)
		detect: [ :each | (each at: #name) = (row at: #name) ].
	^ BrLabel new
		hMatchParent;
		vFitContent;
		padding: (BlInsets top: 3 right: 0 bottom: 6 left: 0);
		aptitude: (BrGlamorousLabelAptitude new foreground: (Color black alpha: 0.78));
		text: (row at: #name), '  ', (self retentionTrendFor: (row at: #name)), String cr,
			'Retained  ', (self retainedSummaryFor: row), String cr,
			((self isJointRetentionRow: row)
				ifTrue: [ 'Holders   ', (self jointHolderSummaryFor: row), String cr ]
				ifFalse: [ '' ]),
			'Current   ', (self currentSummaryFor: currentRow),
			((self isJointRetentionRow: currentRow)
				ifTrue: [ String cr, 'Holders   ', (self jointHolderSummaryFor: currentRow) ]
				ifFalse: [ '' ]);
		yourself
]

{ #category : 'private - building' }
CFPhysicsProfileHealthElement >> retainedSummaryFor: row [
	(self isJointRetentionRow: row) ifTrue: [ ^ self jointInstanceSummaryFor: row ].
	^ self standardInstanceSummaryFor: row
]

{ #category : 'private - building' }
CFPhysicsProfileHealthElement >> currentSummaryFor: row [
	(self isJointRetentionRow: row) ifTrue: [ ^ self jointInstanceSummaryFor: row ].
	^ self standardInstanceSummaryFor: row
]

{ #category : 'private - building' }
CFPhysicsProfileHealthElement >> standardInstanceSummaryFor: row [
	| difference sign |
	difference := row at: #difference.
	sign := difference > 0 ifTrue: [ '+' ] ifFalse: [ '' ].
	^ 'image ', (row at: #total) asString,
		' · world ', (row at: #owned) asString,
		' · expected ', (row at: #expected) asString,
		' · excess ', sign, difference asString
]

{ #category : 'private - building' }
CFPhysicsProfileHealthElement >> jointInstanceSummaryFor: row [
	^ 'image ', (row at: #total) asString,
		' · related ', (row at: #owned) asString,
		' · live ', (row at: #live) asString,
		' · captured ', (row at: #captured) asString,
		' · unexplained ', (row at: #unexplained) asString
]

{ #category : 'private - building' }
CFPhysicsProfileHealthElement >> jointHolderSummaryFor: row [
	^ 'states ', (row at: #worldStateCount) asString,
		' · background steps ', (row at: #backgroundStepCount) asString,
		' · solutions ', (row at: #solutionCount) asString,
		' · pipeline results ', (row at: #pipelineResultCount) asString
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
				((self isJointRetentionRow: row)
					ifTrue: [ ' structurally unexplained retained joint count is increasing after GC.' ]
					ifFalse: [ ' retained excess instance count is increasing after GC.' ]) ] ].
	^ result
]


{ #category : 'private - updating' }
CFPhysicsProfileHealthElement >> updateLiveHealth [
	latestPhysicsData := self latestPhysicsFrameDataFrom: world telemetryRecordings.
	self renderLiveHealth
]

{ #category : 'private - updating' }
CFPhysicsProfileHealthElement >> latestPhysicsFrameDataFrom: recordings [
	recordings reverseDo: [ :recording |
		(recording data includesKey: #physicsFrame) ifTrue: [ ^ recording physicsData ] ].
	^ Dictionary new
]

{ #category : 'private - updating' }
CFPhysicsProfileHealthElement >> renderLiveHealth [
	| data |
	liveContent removeChildren.
	data := latestPhysicsData ifNil: [ Dictionary new ].
	liveContent addChild: (self healthSectionNamed: 'CONTACT LIFECYCLE' rows: {
		self healthRowNamed: 'Persistent' value: (self integerAt: #persistentContactCount in: data) secondaryNamed: 'Touching' value: (self integerAt: #contactCount in: data).
		self healthRowNamed: 'Began' value: (self integerAt: #beganContactCount in: data) secondaryNamed: 'Continued' value: (self integerAt: #continuedContactCount in: data).
		self healthRowNamed: 'Ended' value: (self integerAt: #endedContactCount in: data) secondaryNamed: 'Pairs visited' value: (self integerAt: #contactUpdateVisitedPairCount in: data) }).
	liveContent addChild: (self healthSectionNamed: 'CONTACT UPDATE WORK' rows: {
		self healthRowNamed: 'Manifolds generated' value: (self integerAt: #contactUpdateManifoldGenerationCount in: data) secondaryNamed: 'Both sleeping' value: (self integerAt: #contactUpdateBothSleepingPairCount in: data).
		self healthRowNamed: 'Previous matched' value: (self integerAt: #contactUpdatePreviousMatchCount in: data) secondaryNamed: 'Simplex cached' value: (self integerAt: #contactUpdateCachedSimplexCount in: data).
		self healthRowNamed: 'Contacts reused' value: (self integerAt: #contactUpdateReusedContactCount in: data) secondaryNamed: 'Copied' value: (self integerAt: #contactUpdateCopiedContactCount in: data).
		self healthRowNamed: 'Created' value: (self integerAt: #contactUpdateCreatedContactCount in: data) secondaryNamed: 'Impact' value: (self integerAt: #contactUpdateImpactContactCount in: data) }).
	liveContent addChild: (self healthSectionNamed: 'MANIFOLD DECISIONS' rows: {
		self healthRowNamed: 'Sleeping retained' value: (self integerAt: #contactUpdateSleepingRetainedContactCount in: data) secondaryNamed: 'Awake generated' value: (self integerAt: #contactUpdateAwakeManifoldGenerationCount in: data).
		self healthRowNamed: 'Sleeping non-touching' value: (self integerAt: #contactUpdateSleepingNonTouchingManifoldGenerationCount in: data) secondaryNamed: 'Sleeping sensor' value: (self integerAt: #contactUpdateSleepingNonSolidManifoldGenerationCount in: data).
		self healthRowNamed: 'Sleeping new' value: (self integerAt: #contactUpdateSleepingNewManifoldGenerationCount in: data) secondaryNamed: 'Sleeping impact' value: (self integerAt: #contactUpdateSleepingImpactManifoldGenerationCount in: data).
		self healthRowNamed: 'Sleeping other' value: (self integerAt: #contactUpdateSleepingOtherManifoldGenerationCount in: data) secondaryNamed: 'Decision total' value: ((self integerValueAt: #contactUpdateAwakeManifoldGenerationCount in: data) + (self integerValueAt: #contactUpdateSleepingNonTouchingManifoldGenerationCount in: data) + (self integerValueAt: #contactUpdateSleepingNonSolidManifoldGenerationCount in: data) + (self integerValueAt: #contactUpdateSleepingNewManifoldGenerationCount in: data) + (self integerValueAt: #contactUpdateSleepingImpactManifoldGenerationCount in: data) + (self integerValueAt: #contactUpdateSleepingOtherManifoldGenerationCount in: data)) printString }).
	liveContent addChild: (self healthSectionNamed: 'MANIFOLD CONTINUITY' rows: {
		self healthRowNamed: 'Stable' value: (self integerAt: #stablePreparedManifoldCount in: data) secondaryNamed: 'Changed' value: (self integerAt: #changedPreparedManifoldCount in: data).
		self healthRowNamed: 'Points reused' value: (self integerAt: #reusablePreparedContactPointCount in: data) secondaryNamed: 'New points' value: (self integerAt: #newPreparedContactPointCount in: data).
		self healthRowNamed: 'Feature id' value: (self integerAt: #featureIdChangedPreparedManifoldCount in: data) secondaryNamed: 'Normal' value: (self integerAt: #normalChangedPreparedManifoldCount in: data).
		self healthRowNamed: 'Point count' value: (self integerAt: #pointCountChangedPreparedManifoldCount in: data) secondaryNamed: 'Order' value: (self integerAt: #pointOrderChangedPreparedManifoldCount in: data) }).
	liveContent addChild: (self healthSectionNamed: 'SLEEP' rows: {
		self healthRowNamed: 'Awake' value: (self integerAt: #activeBodyCount in: data) secondaryNamed: 'Sleeping' value: (self integerAt: #sleepingBodyCount in: data).
		self healthRowNamed: 'Accepted' value: (self integerAt: #sleepMotionAcceptedBodyCount in: data) secondaryNamed: 'Disabled' value: (self integerAt: #sleepDisabledBodyCount in: data).
		self healthRowNamed: 'Motion rejected' value: (self integerAt: #sleepMotionOnlyRejectedBodyCount in: data) secondaryNamed: 'Correction rejected' value: (self integerAt: #sleepCorrectionOnlyRejectedBodyCount in: data) }).
	liveContent addChild: (self healthSectionNamed: 'SOLVER' rows: {
		self healthRowNamed: 'Initial penetration' value: (self decimalAt: #solverMaximumInitialContactPenetration in: data) secondaryNamed: 'Final penetration' value: (self decimalAt: #solverMaximumFinalContactPenetration in: data).
		self healthRowNamed: 'Average penetration' value: (self decimalAt: #solverAverageFinalContactPenetration in: data) secondaryNamed: 'Max translation' value: (self decimalAt: #solverMaximumBodyTranslation in: data).
		self healthRowNamed: 'Normal impulse' value: (self decimalAt: #solverTotalNormalImpulse in: data) secondaryNamed: 'Tangent impulse' value: (self decimalAt: #solverTotalTangentImpulse in: data) })
]

{ #category : 'private - building' }
CFPhysicsProfileHealthElement >> healthSectionNamed: aName rows: rows [
	| section |
	section := BrVerticalPane new
		hMatchParent;
		vFitContent;
		cellSpacing: 1;
		padding: (BlInsets top: 2 right: 2 bottom: 2 left: 2);
		yourself.
	section addChild: (BrLabel new
		hMatchParent;
		vExact: 16;
		aptitude: (BrGlamorousLabelAptitude new
			foreground: (Color black alpha: 0.48);
			fontSize: 9);
		text: aName;
		yourself).
	rows do: [ :row | section addChild: row ].
	^ section
]

{ #category : 'private - building' }
CFPhysicsProfileHealthElement >> healthRowNamed: firstName value: firstValue secondaryNamed: secondName value: secondValue [
	| row first second |
	row := BrHorizontalPane new hMatchParent; vExact: 18; cellSpacing: 6; yourself.
	first := self healthCellNamed: firstName value: firstValue.
	second := self healthCellNamed: secondName value: secondValue.
	row addChild: first; addChild: second.
	^ row
]

{ #category : 'private - building' }
CFPhysicsProfileHealthElement >> healthCellNamed: aName value: aValue [
	^ BrLabel new
		hExact: 250;
		vExact: 18;
		aptitude: (BrGlamorousLabelAptitude new
			foreground: (Color black alpha: 0.78);
			fontSize: 10);
		text: aName, '  ', aValue;
		yourself
]


{ #category : 'private - formatting' }
CFPhysicsProfileHealthElement >> integerValueAt: aKey in: data [
	^ data at: aKey ifAbsent: [ 0 ]
]

{ #category : 'private - formatting' }
CFPhysicsProfileHealthElement >> integerAt: aKey in: data [
	^ (data at: aKey ifAbsent: [ 0 ]) printString
]

{ #category : 'private - formatting' }
CFPhysicsProfileHealthElement >> decimalAt: aKey in: data [
	^ (data at: aKey ifAbsent: [ 0.0 ]) asFloat printShowingDecimalPlaces: 3
]
