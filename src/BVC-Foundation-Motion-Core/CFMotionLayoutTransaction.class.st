Class {
	#name : 'CFMotionLayoutTransaction',
	#superclass : 'Object',
	#instVars : [ 'container', 'coordinateSpace', 'participants', 'mutation', 'duration', 'easing', 'sourceSnapshots', 'destinationSnapshots', 'readiness', 'operation', 'phase', 'fadeInElements' ],
	#category : 'BVC-Foundation-Motion-Core',
	#package : 'BVC-Foundation-Motion-Core'
}

{ #category : 'instance creation' }
CFMotionLayoutTransaction class >> on: anElement [
	^ self new container: anElement; yourself
]

{ #category : 'configuration' }
CFMotionLayoutTransaction >> affecting: aCollection [
	participants := aCollection asArray.
	^ self
]

{ #category : 'controlling' }
CFMotionLayoutTransaction >> cancel [
	readiness ifNotNil: [ readiness cancel ].
	operation
		ifNil: [ phase := #cancelled ]
		ifNotNil: [
			operation cancel.
			phase := operation state ].
	^ self
]

{ #category : 'accessing' }
CFMotionLayoutTransaction >> container [ ^ container ]

{ #category : 'accessing' }
CFMotionLayoutTransaction >> container: anElement [
	container := anElement.
	coordinateSpace := anElement
]

{ #category : 'accessing' }
CFMotionLayoutTransaction >> coordinateSpace [ ^ coordinateSpace ]

{ #category : 'configuration' }
CFMotionLayoutTransaction >> coordinateSpace: anElement [
	coordinateSpace := anElement.
	^ self
]

{ #category : 'private - playing' }
CFMotionLayoutTransaction >> captureDestinationAndStart [
	| tracks coordinator |
	phase = #awaitingLayout ifFalse: [ ^ self ].
	coordinator := container space cfMotionCoordinator.
	"The completed layout is authoritative, but an outgoing geometry presenter can
	still be transforming it. Settle that presenter before taking the destination."
	coordinator replaceGeometryOwnersForKeys: (participants collect: [ :each |
		CFMotionPropertyKey
			element: each
			property: CFGeometryMotionProperty uniqueInstance ]).
	destinationSnapshots := participants collect: [ :each |
		CFMotionGeometrySnapshot of: each in: coordinateSpace ].
	tracks := OrderedCollection new.
	1 to: participants size do: [ :eachIndex |
		tracks add: (CFMotionGeometryTrack
			from: (sourceSnapshots at: eachIndex)
			to: (destinationSnapshots at: eachIndex)) ].
	fadeInElements do: [ :each |
		tracks add: (CFMotionPropertyTrack
			on: each
			property: CFOpacityMotionProperty uniqueInstance
			target: 1.0) ].
	operation := CFMotionOperation
		coordinator: coordinator
		tracks: tracks.
	phase := #running.
	operation
		duration: duration;
		easing: easing;
		onTerminalDo: [ :anOperation | phase := anOperation state ];
		start.
]

{ #category : 'accessing' }
CFMotionLayoutTransaction >> destinationSnapshots [ ^ destinationSnapshots ifNil: [ #() ] ]

{ #category : 'configuration' }
CFMotionLayoutTransaction >> duration: aDuration [
	duration := aDuration.
	^ self
]

{ #category : 'configuration' }
CFMotionLayoutTransaction >> easing: anInterpolator [
	easing := anInterpolator.
	^ self
]

{ #category : 'configuration' }
CFMotionLayoutTransaction >> fadeIn: anElement [
	(fadeInElements includes: anElement) ifFalse: [ fadeInElements add: anElement ].
	anElement opacity: 0.0.
	^ self
]

{ #category : 'initialization' }
CFMotionLayoutTransaction >> initialize [
	super initialize.
	participants := #().
	fadeInElements := OrderedCollection new.
	duration := 180 milliSeconds.
	easing := BlDecelerateInterpolator factor: 1.4.
	phase := #idle
]

{ #category : 'private - playing' }
CFMotionLayoutTransaction >> installLayoutObservationAndMutate [
	"Run in the space task phase. Register immediately before the mutation so the
	first layout-computed event necessarily describes this transaction's mutation."
	phase = #awaitingLayout ifFalse: [ ^ self ].
	readiness := CFMotionNextLayoutReadiness
		on: container
		then: [ self captureDestinationAndStart ].
	readiness start.
	mutation value
]

{ #category : 'testing' }
CFMotionLayoutTransaction >> isAwaitingLayout [ ^ phase = #awaitingLayout ]

{ #category : 'testing' }
CFMotionLayoutTransaction >> isCancelled [
	^ phase = #cancelled or: [ phase == CFMotionOperationState cancelled ]
]

{ #category : 'configuration' }
CFMotionLayoutTransaction >> insert: anElement into: aDestinationContainer at: anIndex [
	anElement hasParent ifTrue: [
		self error: 'An inserted motion element must be detached before insertion' ].
	(participants includes: anElement) ifTrue: [
		self error: 'An inserted motion element cannot be a pre-mutation participant' ].
	^ self mutate: [ aDestinationContainer addChild: anElement at: anIndex ]
]

{ #category : 'configuration' }
CFMotionLayoutTransaction >> mutate: aBlock [
	mutation := aBlock.
	^ self
]

{ #category : 'configuration' }
CFMotionLayoutTransaction >> remove: anElement [
	anElement hasParent ifFalse: [
		self error: 'A removed motion element must belong to a container' ].
	(participants includes: anElement) ifTrue: [
		self error: 'A removed motion element cannot be a post-mutation participant' ].
	^ self mutate: [ anElement parent removeChild: anElement ]
]

{ #category : 'configuration' }
CFMotionLayoutTransaction >> move: anElement from: aSourceContainer to: aDestinationContainer [
	aSourceContainer == aDestinationContainer ifTrue: [
		self error: 'A motion move needs distinct source and destination containers' ].
	anElement parent == aSourceContainer ifFalse: [
		self error: 'A motion move subject must belong to its declared source container' ].
	^ self mutate: [
		aSourceContainer removeChild: anElement.
		aDestinationContainer addChild: anElement ]
]

{ #category : 'configuration' }
CFMotionLayoutTransaction >> move: anElement from: aSourceContainer to: aDestinationContainer at: anIndex [
	aSourceContainer == aDestinationContainer ifTrue: [
		self error: 'A motion move needs distinct source and destination containers' ].
	anElement parent == aSourceContainer ifFalse: [
		self error: 'A motion move subject must belong to its declared source container' ].
	^ self mutate: [
		aSourceContainer removeChild: anElement.
		aDestinationContainer addChild: anElement at: anIndex ]
]

{ #category : 'accessing' }
CFMotionLayoutTransaction >> operation [ ^ operation ]

{ #category : 'accessing' }
CFMotionLayoutTransaction >> participants [ ^ participants ]

{ #category : 'accessing' }
CFMotionLayoutTransaction >> phase [
	^ phase
]

{ #category : 'accessing' }
CFMotionLayoutTransaction >> readiness [ ^ readiness ]

{ #category : 'playing' }
CFMotionLayoutTransaction >> play [
	self validateBeforePlaying.
	sourceSnapshots := participants collect: [ :each |
		CFMotionGeometrySnapshot of: each in: coordinateSpace ].
	phase := #awaitingLayout.
	container enqueueTask: (BlTaskAction new
		action: [ self installLayoutObservationAndMutate ]).
	^ self
]

{ #category : 'accessing' }
CFMotionLayoutTransaction >> sourceSnapshots [ ^ sourceSnapshots ifNil: [ #() ] ]

{ #category : 'private - validation' }
CFMotionLayoutTransaction >> validateBeforePlaying [
	phase = #idle ifFalse: [ self error: 'A layout transaction can only play once' ].
	container isAttachedToSceneGraph ifFalse: [
		self error: 'A layout transaction container must be attached to a BlSpace' ].
	coordinateSpace isAttachedToSceneGraph ifFalse: [
		self error: 'A layout transaction coordinate space must be attached to a BlSpace' ].
	coordinateSpace space == container space ifFalse: [
		self error: 'A layout transaction coordinate space must share the container BlSpace' ].
	participants isEmpty ifTrue: [
		self error: 'A layout transaction needs explicit participants' ].
	mutation ifNil: [ self error: 'A layout transaction needs a mutation block' ].
	participants do: [ :each |
		each isAttachedToSceneGraph ifFalse: [
			self error: 'A layout transaction participant must be attached to a BlSpace' ].
		each space == container space ifFalse: [
			self error: 'A layout transaction participant must share the container BlSpace' ] ]
]
