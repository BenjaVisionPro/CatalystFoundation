"
I connect Bloc pull gestures to a Physics pointer constraint.

My responsibility is to track the pointer in world coordinates, preserve Physics ownership of body movement, and release the constraint when interaction ends.
"
Class {
	#name : 'CFPhysicsPullInteractionHandler',
	#superclass : 'Object',
	#instVars : [ 'element', 'constraint', 'startHandler', 'pullHandler', 'endHandler', 'dragStartFilter', 'dragFilter', 'initialPointerPosition', 'pointerPosition', 'enabled', 'responsiveness', 'velocityRetention', 'maximumSpeed' ],
	#category : 'BVC-Physics-Bloc',
	#package : 'BVC-Physics-Bloc'
}

{ #category : 'instance creation' }
CFPhysicsPullInteractionHandler class >> on: anElement [
	^ self new
		installOn: anElement;
		yourself
]

{ #category : 'initialization' }
CFPhysicsPullInteractionHandler >> initialize [
	super initialize.
	enabled := true.
	responsiveness := 24.0.
	velocityRetention := 0.2.
	maximumSpeed := 2400.0
]

{ #category : 'lifecycle' }
CFPhysicsPullInteractionHandler >> installOn: anElement [
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
CFPhysicsPullInteractionHandler >> beginFrom: anEvent [
	(self shouldHandle: anEvent) ifFalse: [ ^ self ].
	self removeConstraint
]

{ #category : 'events' }
CFPhysicsPullInteractionHandler >> continueFrom: anEvent [
	constraint
		ifNil: [ self beginConstraintFrom: anEvent ]
		ifNotNil: [ constraint updatePointerPosition: pointerPosition ].
	constraint ifNil: [ ^ self ].
	self restorePositionFrom: anEvent
]

{ #category : 'events' }
CFPhysicsPullInteractionHandler >> endFrom: anEvent [
	constraint ifNil: [ ^ self ].
	self finishConstraint
]


{ #category : 'private' }
CFPhysicsPullInteractionHandler >> captureInitialPointerPositionFrom: anEvent [
	initialPointerPosition := self worldPointFromGlobalPoint: anEvent position.
	pointerPosition := initialPointerPosition
]

{ #category : 'private' }
CFPhysicsPullInteractionHandler >> capturePointerPositionFrom: anEvent [
	pointerPosition := self worldPointFromGlobalPoint: anEvent position
]

{ #category : 'private' }
CFPhysicsPullInteractionHandler >> worldPointFromGlobalPoint: aPoint [
	^ element globalPointToParentChildren: aPoint
]

{ #category : 'private' }
CFPhysicsPullInteractionHandler >> shouldHandle: anEvent [
	^ enabled and: [ anEvent target == element ]
]

{ #category : 'private' }
CFPhysicsPullInteractionHandler >> restorePositionFrom: anEvent [
	element relocate: anEvent oldPosition
]

{ #category : 'private' }
CFPhysicsPullInteractionHandler >> beginConstraintFrom: anEvent [
	| world body |
	(initialPointerPosition isNil or: [ pointerPosition isNil ]) ifTrue: [ ^ self ].
	world := element physics worldOrNil.
	world ifNil: [ ^ self ].
	world synchroniseMembership.
	body := world bodyStateFor: element.
	(body isNil or: [ body acceptsPointerConstraint not ]) ifTrue: [ ^ self ].
	constraint := CFPhysicsPointerConstraint
		body: body
		pointerPosition: initialPointerPosition.
	constraint
		responsiveness: responsiveness;
		velocityRetention: velocityRetention;
		maximumSpeed: maximumSpeed;
		movePointerPositionTo: pointerPosition.
	world addPointerConstraint: constraint
]

{ #category : 'private' }
CFPhysicsPullInteractionHandler >> finishConstraint [
	constraint ifNil: [ ^ self ].
	constraint release.
	constraint body world removePointerConstraint: constraint.
	constraint := nil
]

{ #category : 'private' }
CFPhysicsPullInteractionHandler >> removeConstraint [
	constraint ifNil: [ ^ self ].
	constraint cancel.
	constraint body world removePointerConstraint: constraint.
	constraint := nil
]

{ #category : 'controlling' }
CFPhysicsPullInteractionHandler >> enable [
	enabled := true
]

{ #category : 'controlling' }
CFPhysicsPullInteractionHandler >> disable [
	enabled := false.
	self removeConstraint
]

{ #category : 'testing' }
CFPhysicsPullInteractionHandler >> isEnabled [
	^ enabled
]

{ #category : 'accessing' }
CFPhysicsPullInteractionHandler >> element [
	^ element
]

{ #category : 'accessing' }
CFPhysicsPullInteractionHandler >> constraint [
	^ constraint
]

{ #category : 'configuration' }
CFPhysicsPullInteractionHandler >> responsiveness [
	^ responsiveness
]

{ #category : 'configuration' }
CFPhysicsPullInteractionHandler >> responsiveness: aNumber [
	responsiveness := aNumber asFloat max: 0.0.
	constraint ifNotNil: [ constraint responsiveness: responsiveness ]
]

{ #category : 'configuration' }
CFPhysicsPullInteractionHandler >> velocityRetention [
	^ velocityRetention
]

{ #category : 'configuration' }
CFPhysicsPullInteractionHandler >> velocityRetention: aNumber [
	velocityRetention := (aNumber asFloat max: 0.0) min: 1.0.
	constraint ifNotNil: [ constraint velocityRetention: velocityRetention ]
]

{ #category : 'configuration' }
CFPhysicsPullInteractionHandler >> maximumSpeed [
	^ maximumSpeed
]

{ #category : 'configuration' }
CFPhysicsPullInteractionHandler >> maximumSpeed: aNumber [
	maximumSpeed := aNumber asFloat max: 0.0.
	constraint ifNotNil: [ constraint maximumSpeed: maximumSpeed ]
]
