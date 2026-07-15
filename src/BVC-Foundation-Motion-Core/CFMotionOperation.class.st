Class {
	#name : 'CFMotionOperation',
	#superclass : 'Object',
	#instVars : [ 'coordinator', 'tracks', 'duration', 'easing', 'animation', 'generation', 'state', 'trace' ],
	#category : 'BVC-Foundation-Motion-Core',
	#package : 'BVC-Foundation-Motion-Core'
}

{ #category : 'instance creation' }
CFMotionOperation class >> coordinator: aCoordinator tracks: aCollection [
	^ self new
		coordinator: aCoordinator;
		tracks: aCollection;
		yourself
]

{ #category : 'initialization' }
CFMotionOperation >> initialize [
	super initialize.
	duration := 180 milliSeconds.
	easing := BlDecelerateInterpolator factor: 1.4.
	generation := 0.
	state := CFMotionOperationState idle.
	trace := CFMotionTrace new
]

{ #category : 'accessing' }
CFMotionOperation >> animation [ ^ animation ]

{ #category : 'controlling' }
CFMotionOperation >> cancel [ ^ self cancelPreservingCurrentPresentation ]

{ #category : 'controlling' }
CFMotionOperation >> cancelAndRestore [
	^ self cancelApplying: [ :each | each restoreOrigin ]
]

{ #category : 'controlling' }
CFMotionOperation >> cancelPreservingCurrentPresentation [
	^ self cancelApplying: [ :each | each preserveCurrentPresentation ]
]

{ #category : 'controlling' }
CFMotionOperation >> cancelSettlingAtEnd [
	^ self cancelApplying: [ :each | each applyDestination ]
]

{ #category : 'private - controlling' }
CFMotionOperation >> cancelApplying: aBlock [
	state isTerminal ifTrue: [ ^ self ].
	generation := generation + 1.
	self discardAnimation.
	tracks do: aBlock.
	state := CFMotionOperationState cancelled.
	trace record: #cancelled for: self.
	self releaseClaims.
	^ self
]

{ #category : 'private - controlling' }
CFMotionOperation >> complete [
	state isTerminal ifTrue: [ ^ self ].
	tracks do: [ :each | each applyDestination ].
	state := CFMotionOperationState completed.
	trace record: #completed for: self.
	self releaseClaims
]

{ #category : 'accessing' }
CFMotionOperation >> coordinator [ ^ coordinator ]

{ #category : 'accessing' }
CFMotionOperation >> coordinator: aCoordinator [ coordinator := aCoordinator ]

{ #category : 'private - playing' }
CFMotionOperation >> discardAnimation [
	| currentAnimation |
	currentAnimation := animation.
	animation := nil.
	currentAnimation ifNotNil: [ :each | each stopIfRunning ]
]

{ #category : 'accessing' }
CFMotionOperation >> duration: aDuration [ duration := aDuration ]

{ #category : 'accessing' }
CFMotionOperation >> easing: anInterpolator [ easing := anInterpolator ]

{ #category : 'private - playing' }
CFMotionOperation >> finish: anAnimation generation: anInteger [
	(animation == anAnimation
		and: [ generation = anInteger and: [ state == CFMotionOperationState running ] ])
		ifTrue: [
			animation := nil.
			self complete ]
]

{ #category : 'testing' }
CFMotionOperation >> isCancelled [ ^ state == CFMotionOperationState cancelled ]

{ #category : 'testing' }
CFMotionOperation >> isCompleted [ ^ state == CFMotionOperationState completed ]

{ #category : 'testing' }
CFMotionOperation >> isRunning [ ^ state == CFMotionOperationState running ]

{ #category : 'private - ownership' }
CFMotionOperation >> claimTracks [
	tracks do: [ :each | coordinator claim: each propertyKey for: self ].
	trace record: #claimed for: self
]

{ #category : 'private - ownership' }
CFMotionOperation >> releaseClaims [
	coordinator releaseAllFor: self.
	trace record: #cleanedUp for: self
]

{ #category : 'playing' }
CFMotionOperation >> retarget: aTrack duration: aDuration easing: anInterpolator [
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
CFMotionOperation >> start [
	self claimTracks.
	tracks do: [ :each | each captureOrigin ].
	self startFromCurrentPresentation.
	^ self
]

{ #category : 'private - playing' }
CFMotionOperation >> startFromCurrentPresentation [
	| currentGeneration newAnimation |
	generation := generation + 1.
	currentGeneration := generation.
	self discardAnimation.
	tracks do: [ :each | each prepareFromCurrentPresentation ].
	state := CFMotionOperationState running.
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
CFMotionOperation >> state [ ^ state ]

{ #category : 'accessing' }
CFMotionOperation >> trace [ ^ trace ]

{ #category : 'accessing' }
CFMotionOperation >> tracks [ ^ tracks asArray ]

{ #category : 'accessing' }
CFMotionOperation >> tracks: aCollection [ tracks := aCollection asOrderedCollection ]
