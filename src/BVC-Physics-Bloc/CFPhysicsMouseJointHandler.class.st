"
I connect Bloc pull gestures to a Physics mouse joint.

My responsibility is to track the pointer in world coordinates, configure the Box2D mouse joint for responsive UI manipulation, preserve Physics ownership of body movement, and remove the joint when interaction ends.
"
Class {
	#name : 'CFPhysicsMouseJointHandler',
	#superclass : 'Object',
	#instVars : [ 'element', 'mouseJoint', 'startHandler', 'pullHandler', 'endHandler', 'dragStartFilter', 'dragFilter', 'initialPointerPosition', 'pointerPosition', 'enabled', 'hertz', 'dampingRatio', 'maximumAcceleration' ],
	#category : 'BVC-Physics-Bloc',
	#package : 'BVC-Physics-Bloc'
}

{ #category : 'instance creation' }
CFPhysicsMouseJointHandler class >> on: anElement [
	^ self new
		installOn: anElement;
		yourself
]

{ #category : 'initialization' }
CFPhysicsMouseJointHandler >> initialize [
	super initialize.
	enabled := true.
	hertz := 30.0.
	dampingRatio := 1.0.
	maximumAcceleration := 1000000.0
]

{ #category : 'lifecycle' }
CFPhysicsMouseJointHandler >> installOn: anElement [
	element := anElement.
	dragStartFilter := BlEventHandler on: BlDragStartEvent do: [ :anEvent |
		self captureInitialPointerPositionFrom: anEvent ].
	dragFilter := BlEventHandler on: BlDragEvent do: [ :anEvent |
		self capturePointerPositionFrom: anEvent ].
	startHandler := BlEventHandler on: BlPullStartEvent do: [ :anEvent |
		self beginFrom: anEvent ].
	pullHandler := BlEventHandler on: BlPullEvent do: [ :anEvent |
		self continueFrom: anEvent ].
	endHandler := BlEventHandler on: BlPullEndEvent do: [ :anEvent |
		self endFrom: anEvent ].
	element
		addEventFilter: dragStartFilter;
		addEventFilter: dragFilter;
		addEventHandler: startHandler;
		addEventHandler: pullHandler;
		addEventHandler: endHandler
]

{ #category : 'events' }
CFPhysicsMouseJointHandler >> beginFrom: anEvent [
	(self shouldHandle: anEvent) ifFalse: [ ^ self ].
	self removeMouseJoint
]

{ #category : 'events' }
CFPhysicsMouseJointHandler >> continueFrom: anEvent [
	mouseJoint
		ifNil: [ self beginMouseJointFrom: anEvent ]
		ifNotNil: [ mouseJoint target: pointerPosition ].
	mouseJoint ifNil: [ ^ self ].
	self restorePositionFrom: anEvent
]

{ #category : 'events' }
CFPhysicsMouseJointHandler >> endFrom: anEvent [
	mouseJoint ifNil: [ ^ self ].
	self finishMouseJoint
]


{ #category : 'private' }
CFPhysicsMouseJointHandler >> captureInitialPointerPositionFrom: anEvent [
	initialPointerPosition := self worldPointFromGlobalPoint: anEvent position.
	pointerPosition := initialPointerPosition
]

{ #category : 'private' }
CFPhysicsMouseJointHandler >> capturePointerPositionFrom: anEvent [
	pointerPosition := self worldPointFromGlobalPoint: anEvent position
]

{ #category : 'private' }
CFPhysicsMouseJointHandler >> worldPointFromGlobalPoint: aPoint [
	^ element globalPointToParentChildren: aPoint
]

{ #category : 'private' }
CFPhysicsMouseJointHandler >> shouldHandle: anEvent [
	^ enabled and: [ anEvent target == element ]
]

{ #category : 'private' }
CFPhysicsMouseJointHandler >> restorePositionFrom: anEvent [
	element relocate: anEvent oldPosition
]

{ #category : 'private' }
CFPhysicsMouseJointHandler >> beginMouseJointFrom: anEvent [
	| world body |
	(initialPointerPosition isNil or: [ pointerPosition isNil ]) ifTrue: [ ^ self ].
	world := element physics world.
	world ifNil: [ ^ self ].
	body := world bodyStateFor: element.
	(body isNil or: [ body isDynamic not ]) ifTrue: [ ^ self ].
	mouseJoint := CFPhysicsMouseJoint body: body target: initialPointerPosition.
	mouseJoint
		hertz: hertz;
		dampingRatio: dampingRatio;
		maximumForce: maximumAcceleration * body mass;
		target: pointerPosition.
	world addMouseJoint: mouseJoint
]

{ #category : 'private' }
CFPhysicsMouseJointHandler >> finishMouseJoint [
	| activeMouseJoint world |
	mouseJoint ifNil: [ ^ self ].
	activeMouseJoint := mouseJoint.
	mouseJoint := nil.
	world := activeMouseJoint bodyB world.
	world ifNotNil: [ world removeMouseJoint: activeMouseJoint ]
]

{ #category : 'private' }
CFPhysicsMouseJointHandler >> removeMouseJoint [
	| activeMouseJoint world |
	mouseJoint ifNil: [ ^ self ].
	activeMouseJoint := mouseJoint.
	mouseJoint := nil.
	world := activeMouseJoint bodyB world.
	world ifNotNil: [ world removeMouseJoint: activeMouseJoint ]
]

{ #category : 'controlling' }
CFPhysicsMouseJointHandler >> enable [
	enabled := true
]

{ #category : 'controlling' }
CFPhysicsMouseJointHandler >> disable [
	enabled := false.
	self removeMouseJoint
]

{ #category : 'testing' }
CFPhysicsMouseJointHandler >> isEnabled [
	^ enabled
]

{ #category : 'accessing' }
CFPhysicsMouseJointHandler >> element [
	^ element
]

{ #category : 'accessing' }
CFPhysicsMouseJointHandler >> mouseJoint [
	^ mouseJoint
]

{ #category : 'configuration' }
CFPhysicsMouseJointHandler >> hertz [ ^ hertz ]

{ #category : 'configuration' }
CFPhysicsMouseJointHandler >> hertz: aNumber [
	hertz := aNumber asFloat max: 0.0.
	mouseJoint ifNotNil: [ mouseJoint hertz: hertz ]
]

{ #category : 'configuration' }
CFPhysicsMouseJointHandler >> dampingRatio [ ^ dampingRatio ]

{ #category : 'configuration' }
CFPhysicsMouseJointHandler >> dampingRatio: aNumber [
	dampingRatio := aNumber asFloat max: 0.0.
	mouseJoint ifNotNil: [ mouseJoint dampingRatio: dampingRatio ]
]

{ #category : 'configuration' }
CFPhysicsMouseJointHandler >> maximumAcceleration [ ^ maximumAcceleration ]

{ #category : 'configuration' }
CFPhysicsMouseJointHandler >> maximumAcceleration: aNumber [
	maximumAcceleration := aNumber asFloat max: 0.0.
	mouseJoint ifNotNil: [
		mouseJoint maximumForce: maximumAcceleration * mouseJoint bodyB mass ]
]
