Class {
	#name : 'CFMotion',
	#superclass : 'Object',
	#instVars : [ 'coordinator', 'tracks', 'duration', 'easing', 'animation', 'generation', 'state', 'trace', 'terminalHandlers', 'holdAtDestination', 'componentMotions' ],
	#category : 'BVC-Foundation-Motion-Core',
	#package : 'BVC-Foundation-Motion-Core'
}

{ #category : 'instance creation' }
CFMotion class >> coordinator: aCoordinator tracks: aCollection [
	^ self new
		coordinator: aCoordinator;
		tracks: aCollection;
		yourself
]

{ #category : 'instance creation' }
CFMotion class >> composedOf: aCollection [
	| aMotion |
	aMotion := self new.
	aMotion componentMotions: aCollection.
	^ aMotion
]

{ #category : 'initialization' }
CFMotion >> initialize [
	super initialize.
	duration := 180 milliSeconds.
	easing := BlDecelerateInterpolator factor: 1.4.
	generation := 0.
	state := CFMotionState idle.
	trace := CFMotionTrace new.
	terminalHandlers := OrderedCollection new.
	holdAtDestination := false.
	componentMotions := OrderedCollection new
]

{ #category : 'accessing' }
CFMotion >> animation [ ^ animation ]

{ #category : 'controlling' }
CFMotion >> cancel [ ^ self cancelPreservingCurrentPresentation ]

{ #category : 'controlling' }
CFMotion >> cancelAndRestore [
	(self hasComponentMotions) ifTrue: [ ^ self cancelComponentMotionsWith: #cancelAndRestore ].
	^ self cancelApplying: [ :each | each restoreOrigin ]
]

{ #category : 'controlling' }
CFMotion >> cancelPreservingCurrentPresentation [
	(self hasComponentMotions) ifTrue: [ ^ self cancelComponentMotionsWith: #cancel ].
	^ self cancelApplying: [ :each | each preserveCurrentPresentation ]
]

{ #category : 'controlling' }
CFMotion >> cancelSettlingAtEnd [
	(self hasComponentMotions) ifTrue: [ ^ self cancelComponentMotionsWith: #cancelSettlingAtEnd ].
	^ self cancelApplying: [ :each | each applyDestination ]
]

{ #category : 'private - controlling' }
CFMotion >> cancelComponentMotionsWith: aSelector [
	state isTerminal ifTrue: [ ^ self ].
	state := CFMotionState cancelled.
	trace record: #cancelled for: self.
	componentMotions do: [ :each | each perform: aSelector ].
	self notifyTerminalHandlers.
	^ self
]

{ #category : 'private - controlling' }
CFMotion >> cancelApplying: aBlock [
	state isTerminal ifTrue: [ ^ self ].
	generation := generation + 1.
	self discardAnimation.
	tracks do: aBlock.
	state := CFMotionState cancelled.
	trace record: #cancelled for: self.
	self releaseClaims.
	self notifyTerminalHandlers.
	^ self
]

{ #category : 'private - controlling' }
CFMotion >> complete [
	state isTerminal ifTrue: [ ^ self ].
	(self hasComponentMotions) ifTrue: [
		state := CFMotionState completed.
		trace record: #completed for: self.
		self notifyTerminalHandlers.
		^ self ].
	holdAtDestination ifTrue: [
		state := CFMotionState settled.
		trace record: #settled for: self.
		^ self ].
	tracks do: [ :each | each applyDestination ].
	state := CFMotionState completed.
	trace record: #completed for: self.
	self releaseClaims.
	self notifyTerminalHandlers
]

{ #category : 'accessing' }
CFMotion >> coordinator [ ^ coordinator ]

{ #category : 'accessing' }
CFMotion >> coordinator: aCoordinator [ coordinator := aCoordinator ]

{ #category : 'accessing' }
CFMotion >> componentMotions [ ^ componentMotions asArray ]

{ #category : 'private - initialization' }
CFMotion >> componentMotions: aCollection [
	componentMotions := aCollection asOrderedCollection.
	^ self
]

{ #category : 'private - playing' }
CFMotion >> discardAnimation [
	| currentAnimation |
	currentAnimation := animation.
	animation := nil.
	currentAnimation ifNotNil: [ :each | each stopIfRunning ]
]

{ #category : 'accessing' }
CFMotion >> duration: aDuration [ duration := aDuration ]

{ #category : 'accessing' }
CFMotion >> easing: anInterpolator [ easing := anInterpolator ]

{ #category : 'private - playing' }
CFMotion >> finish: anAnimation generation: anInteger [
	(animation == anAnimation
		and: [ generation = anInteger and: [ state == CFMotionState running ] ])
		ifTrue: [
			animation := nil.
			self complete ]
]

{ #category : 'testing' }
CFMotion >> isCancelled [ ^ state == CFMotionState cancelled ]

{ #category : 'testing' }
CFMotion >> isCompleted [ ^ state == CFMotionState completed ]

{ #category : 'private - testing' }
CFMotion >> hasComponentMotions [ ^ componentMotions isNotEmpty ]

{ #category : 'testing' }
CFMotion >> isRunning [ ^ state == CFMotionState running ]

{ #category : 'configuration' }
CFMotion >> holdAtDestination [
	holdAtDestination := true.
	^ self
]

{ #category : 'configuration' }
CFMotion >> holdAtDestination: aBoolean [
	holdAtDestination := aBoolean.
	^ self
]

{ #category : 'private - notifying' }
CFMotion >> notifyTerminalHandlers [
	terminalHandlers do: [ :each | each cull: self ].
	terminalHandlers removeAll
]

{ #category : 'action handling' }
CFMotion >> onTerminalDo: aBlock [
	state isTerminal
		ifTrue: [ aBlock cull: self ]
		ifFalse: [ terminalHandlers add: aBlock ].
	^ self
]

{ #category : 'private - ownership' }
CFMotion >> claimTracks [
	tracks do: [ :each | coordinator claim: each propertyKey for: self ].
	trace record: #claimed for: self
]

{ #category : 'private - ownership' }
CFMotion >> releaseClaims [
	coordinator releaseAllFor: self.
	trace record: #cleanedUp for: self
]

{ #category : 'playing' }
CFMotion >> retarget: aTrackOrTracks duration: aDuration easing: anInterpolator [
	| requestedTracks ownedTracks |
	(self hasComponentMotions) ifTrue: [
		self error: 'A composed Motion must retarget one of its component Motions' ].
	requestedTracks := aTrackOrTracks isCollection
		ifTrue: [ aTrackOrTracks asArray ]
		ifFalse: [ { aTrackOrTracks } ].
	ownedTracks := requestedTracks collect: [ :each |
		tracks
			detect: [ :ownedTrack | ownedTrack propertyKey = each propertyKey ]
			ifNone: [ self error: 'A Motion can only retarget a property it owns' ] ].
	duration := aDuration.
	easing := anInterpolator.
	requestedTracks with: ownedTracks do: [ :each :ownedTrack |
		ownedTrack targetValue: each targetValue.
		trace record: #retargeted for: self track: ownedTrack ].
	self startFromCurrentPresentation.
	^ self
]

{ #category : 'controlling' }
CFMotion >> reversed [
	(self hasComponentMotions) ifTrue: [
		^ CFMotion composedOf: (componentMotions collect: #reversed) ].
	^ (CFMotion
		coordinator: coordinator
		tracks: (tracks reverse collect: #reversed))
		duration: duration;
		easing: easing;
		yourself
]

{ #category : 'playing' }
CFMotion >> start [
	(self hasComponentMotions) ifTrue: [ ^ self startComponentMotions ].
	self claimTracks.
	tracks do: [ :each | each captureOriginIn: coordinator ].
	self startFromCurrentPresentation.
	^ self
]

{ #category : 'private - playing' }
CFMotion >> startComponentMotions [
	state isTerminal ifTrue: [ self error: 'A completed Motion cannot start again' ].
	(state == CFMotionState running) ifTrue: [ self error: 'A Motion cannot start while it is already running' ].
	state := CFMotionState running.
	trace record: #started for: self.
	componentMotions do: [ :each |
		each onTerminalDo: [ :anOperation | self finishComponentMotionsIfTerminal ].
		each start ].
	self finishComponentMotionsIfTerminal.
	^ self
]

{ #category : 'private - playing' }
CFMotion >> finishComponentMotionsIfTerminal [
	(state == CFMotionState running) ifFalse: [ ^ self ].
	(componentMotions allSatisfy: [ :each | each state isTerminal ]) ifFalse: [ ^ self ].
	(componentMotions anySatisfy: #isCancelled)
		ifTrue: [
			state := CFMotionState cancelled.
			trace record: #cancelled for: self.
			self notifyTerminalHandlers ]
		ifFalse: [ self complete ]
]

{ #category : 'private - playing' }
CFMotion >> startFromCurrentPresentation [
	| currentGeneration newAnimation |
	generation := generation + 1.
	currentGeneration := generation.
	self discardAnimation.
	tracks do: [ :each | each prepareFromCurrentPresentation ].
	state := CFMotionState running.
	trace record: #started for: self.
	(tracks allSatisfy: [ :each | each isAtDestination ]) ifTrue: [
		^ self complete ].
	newAnimation := BlNumberTransition new
		from: 0.0;
		to: 1.0;
		duration: duration;
		easing: easing;
		onStepDo: [ :progress |
			tracks do: [ :each | each applyProgress: progress ] ];
		yourself.
	animation := newAnimation.
	newAnimation onFinishedDo: [
		self finish: newAnimation generation: currentGeneration ].
	tracks first animationTarget addAnimation: newAnimation
]

{ #category : 'accessing' }
CFMotion >> state [ ^ state ]

{ #category : 'accessing' }
CFMotion >> trace [ ^ trace ]

{ #category : 'accessing' }
CFMotion >> tracks [ ^ tracks asArray ]

{ #category : 'accessing' }
CFMotion >> tracks: aCollection [ tracks := aCollection asOrderedCollection ]
