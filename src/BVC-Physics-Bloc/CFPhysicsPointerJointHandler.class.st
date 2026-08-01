"
I connect Bloc pull gestures to a Physics mouse joint.

My responsibility is to track the pointer in world coordinates, preserve Physics ownership of body movement, and release the mouse joint when interaction ends.
"
Class {
	#name : 'CFPhysicsPointerJointHandler',
	#superclass : 'Object',
	#instVars : [ 'element', 'mouseJoint', 'startHandler', 'pullHandler', 'endHandler', 'dragStartFilter', 'dragFilter', 'initialPointerPosition', 'pointerPosition', 'enabled', 'hertz', 'dampingRatio', 'maximumForce' ],
	#category : 'BVC-Physics-Bloc',
	#package : 'BVC-Physics-Bloc'
}

{ #category : 'instance creation' }
CFPhysicsPointerJointHandler class >> on: anElement [
	^ self new
		installOn: anElement;
		yourself
]

{ #category : 'initialization' }
CFPhysicsPointerJointHandler >> initialize [
	super initialize.
	enabled := true.
	hertz := 5.0.
	dampingRatio := 0.7.
	maximumForce := 1000.0
]

{ #category : 'lifecycle' }
CFPhysicsPointerJointHandler >> installOn: anElement [
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
CFPhysicsPointerJointHandler >> beginFrom: anEvent [
	(self shouldHandle: anEvent) ifFalse: [ ^ self ].
	self removeMouseJoint
]

{ #category : 'events' }
CFPhysicsPointerJointHandler >> continueFrom: anEvent [
	mouseJoint
		ifNil: [ self beginMouseJointFrom: anEvent ]
		ifNotNil: [ mouseJoint target: pointerPosition ].
	mouseJoint ifNil: [ ^ self ].
	self restorePositionFrom: anEvent
]

{ #category : 'events' }
CFPhysicsPointerJointHandler >> endFrom: anEvent [
	mouseJoint ifNil: [ ^ self ].
	self finishMouseJoint
]


{ #category : 'private' }
CFPhysicsPointerJointHandler >> captureInitialPointerPositionFrom: anEvent [
	initialPointerPosition := self worldPointFromGlobalPoint: anEvent position.
	pointerPosition := initialPointerPosition
]

{ #category : 'private' }
CFPhysicsPointerJointHandler >> capturePointerPositionFrom: anEvent [
	pointerPosition := self worldPointFromGlobalPoint: anEvent position
]

{ #category : 'private' }
CFPhysicsPointerJointHandler >> worldPointFromGlobalPoint: aPoint [
	^ element globalPointToParentChildren: aPoint
]

{ #category : 'private' }
CFPhysicsPointerJointHandler >> shouldHandle: anEvent [
	^ enabled and: [ anEvent target == element ]
]

{ #category : 'private' }
CFPhysicsPointerJointHandler >> restorePositionFrom: anEvent [
	element relocate: anEvent oldPosition
]

{ #category : 'private' }
CFPhysicsPointerJointHandler >> beginMouseJointFrom: anEvent [
	| world body |
	(initialPointerPosition isNil or: [ pointerPosition isNil ]) ifTrue: [ ^ self ].
	world := element physics world.
	world ifNil: [ ^ self ].
	world synchroniseMembership.
	body := world bodyStateFor: element.
	(body isNil or: [ body isDynamic not ]) ifTrue: [ ^ self ].
	mouseJoint := CFPhysicsMouseJoint body: body target: initialPointerPosition.
	mouseJoint
		hertz: hertz;
		dampingRatio: dampingRatio;
		maximumForce: maximumForce;
		target: pointerPosition.
	world addMouseJoint: mouseJoint
]

{ #category : 'private' }
CFPhysicsPointerJointHandler >> finishMouseJoint [
	| activeMouseJoint world |
	mouseJoint ifNil: [ ^ self ].
	activeMouseJoint := mouseJoint.
	mouseJoint := nil.
	world := activeMouseJoint bodyB world.
	world ifNotNil: [ world removeMouseJoint: activeMouseJoint ]
]

{ #category : 'private' }
CFPhysicsPointerJointHandler >> removeMouseJoint [
	| activeMouseJoint world |
	mouseJoint ifNil: [ ^ self ].
	activeMouseJoint := mouseJoint.
	mouseJoint := nil.
	world := activeMouseJoint bodyB world.
	world ifNotNil: [ world removeMouseJoint: activeMouseJoint ]
]

{ #category : 'controlling' }
CFPhysicsPointerJointHandler >> enable [
	enabled := true
]

{ #category : 'controlling' }
CFPhysicsPointerJointHandler >> disable [
	enabled := false.
	self removeMouseJoint
]

{ #category : 'testing' }
CFPhysicsPointerJointHandler >> isEnabled [
	^ enabled
]

{ #category : 'accessing' }
CFPhysicsPointerJointHandler >> element [
	^ element
]

{ #category : 'accessing' }
CFPhysicsPointerJointHandler >> mouseJoint [
	^ mouseJoint
]

{ #category : 'configuration' }
CFPhysicsPointerJointHandler >> hertz [ ^ hertz ]

{ #category : 'configuration' }
CFPhysicsPointerJointHandler >> hertz: aNumber [
	hertz := aNumber asFloat max: 0.0.
	mouseJoint ifNotNil: [ mouseJoint hertz: hertz ]
]

{ #category : 'configuration' }
CFPhysicsPointerJointHandler >> dampingRatio [ ^ dampingRatio ]

{ #category : 'configuration' }
CFPhysicsPointerJointHandler >> dampingRatio: aNumber [
	dampingRatio := aNumber asFloat max: 0.0.
	mouseJoint ifNotNil: [ mouseJoint dampingRatio: dampingRatio ]
]

{ #category : 'configuration' }
CFPhysicsPointerJointHandler >> maximumForce [ ^ maximumForce ]

{ #category : 'configuration' }
CFPhysicsPointerJointHandler >> maximumForce: aNumber [
	maximumForce := aNumber asFloat max: 0.0.
	mouseJoint ifNotNil: [ mouseJoint maximumForce: maximumForce ]
]
