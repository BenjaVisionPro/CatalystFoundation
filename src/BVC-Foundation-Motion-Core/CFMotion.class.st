Class {
	#name : 'CFMotion',
	#superclass : 'Object',
	#instVars : [ 'coordinator', 'tracks', 'duration', 'easing', 'animation', 'generation', 'state', 'trace', 'terminalHandlers' ],
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

{ #category : 'initialization' }
CFMotion >> initialize [
	super initialize.
	duration := 180 milliSeconds.
	easing := BlDecelerateInterpolator factor: 1.4.
	generation := 0.
	state := CFMotionState idle.
	trace := CFMotionTrace new.
	terminalHandlers := OrderedCollection new
]

{ #category : 'accessing' }
CFMotion >> animation [ ^ animation ]

{ #category : 'controlling' }
CFMotion >> cancel [ ^ self cancelPreservingCurrentPresentation ]

{ #category : 'controlling' }
CFMotion >> cancelAndRestore [
	^ self cancelApplying: [ :each | each restoreOrigin ]
]

{ #category : 'controlling' }
CFMotion >> cancelPreservingCurrentPresentation [
	^ self cancelApplying: [ :each | each preserveCurrentPresentation ]
]

{ #category : 'controlling' }
CFMotion >> cancelSettlingAtEnd [
	^ self cancelApplying: [ :each | each applyDestination ]
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

{ #category : 'testing' }
CFMotion >> isRunning [ ^ state == CFMotionState running ]

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
CFMotion >> retarget: aTrack duration: aDuration easing: anInterpolator [
	| ownedTrack |
	ownedTrack := tracks
		detect: [ :each | each propertyKey = aTrack propertyKey ]
		ifNone: [ self error: 'An operation can only retarget a property it owns' ].
	duration := aDuration.
	easing := anInterpolator.
	ownedTrack targetValue: aTrack targetValue.
	trace record: #retargeted for: self track: ownedTrack.
	self startFromCurrentPresentation.
	^ self
]

{ #category : 'playing' }
CFMotion >> start [
	self claimTracks.
	tracks do: [ :each | each captureOriginIn: coordinator ].
	self startFromCurrentPresentation.
	^ self
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
