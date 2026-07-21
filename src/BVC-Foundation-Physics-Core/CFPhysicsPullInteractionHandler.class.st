Class {
	#name : 'CFPhysicsPullInteractionHandler',
	#superclass : 'Object',
	#instVars : [ 'element', 'constraint', 'startHandler', 'pullHandler', 'endHandler', 'dragStartHandler', 'dragHandler', 'dragEndHandler', 'enabled', 'responsiveness', 'velocityRetention', 'maximumSpeed', 'dragPreviousPosition', 'pullObserved' ],
	#category : 'BVC-Foundation-Physics-Core',
	#package : 'BVC-Foundation-Physics-Core'
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
	maximumSpeed := 2400.0.
	pullObserved := false
]

{ #category : 'lifecycle' }
CFPhysicsPullInteractionHandler >> installOn: anElement [
	element := anElement.
	startHandler := BlEventHandler on: BlPullStartEvent do: [ :anEvent |
		self beginFrom: anEvent ].
	pullHandler := BlEventHandler on: BlPullEvent do: [ :anEvent |
		self continueFrom: anEvent ].
	endHandler := BlEventHandler on: BlPullEndEvent do: [ :anEvent |
		self endFrom: anEvent ].
	dragStartHandler := BlEventHandler on: BlDragStartEvent do: [ :anEvent |
		self dragBeginFrom: anEvent ].
	dragHandler := BlEventHandler on: BlDragEvent do: [ :anEvent |
		self dragContinueFrom: anEvent ].
	dragEndHandler := BlEventHandler on: BlDragEndEvent do: [ :anEvent |
		self dragEndFrom: anEvent ].
	element
		addEventHandler: startHandler;
		addEventHandler: pullHandler;
		addEventHandler: endHandler;
		addEventHandler: dragStartHandler;
		addEventHandler: dragHandler;
		addEventHandler: dragEndHandler
]

{ #category : 'events' }
CFPhysicsPullInteractionHandler >> beginFrom: anEvent [
	(self shouldHandle: anEvent) ifFalse: [ ^ self ].
	pullObserved := true.
	self removeConstraint
]

{ #category : 'events' }
CFPhysicsPullInteractionHandler >> continueFrom: anEvent [
	pullObserved := true.
	self continueFromPosition: anEvent oldPosition to: anEvent newPosition
]

{ #category : 'events' }
CFPhysicsPullInteractionHandler >> endFrom: anEvent [
	pullObserved := true.
	constraint ifNil: [ ^ self ].
	self finishConstraint
]

{ #category : 'events - drag fallback' }
CFPhysicsPullInteractionHandler >> dragBeginFrom: anEvent [
	(self shouldHandle: anEvent) ifFalse: [ ^ self ].
	pullObserved := false.
	dragPreviousPosition := element constraints position
]

{ #category : 'events - drag fallback' }
CFPhysicsPullInteractionHandler >> dragContinueFrom: anEvent [
	| newPosition |
	pullObserved ifTrue: [
		pullObserved := false.
		^ self ].
	enabled ifFalse: [ ^ self ].
	newPosition := element constraints position.
	dragPreviousPosition ifNil: [ dragPreviousPosition := newPosition ].
	self continueFromPosition: dragPreviousPosition to: newPosition
]

{ #category : 'events - drag fallback' }
CFPhysicsPullInteractionHandler >> dragEndFrom: anEvent [
	pullObserved ifTrue: [
		pullObserved := false.
		dragPreviousPosition := nil.
		^ self ].
	constraint ifNotNil: [ self finishConstraint ].
	dragPreviousPosition := nil
]

{ #category : 'private' }
CFPhysicsPullInteractionHandler >> continueFromPosition: oldPosition to: newPosition [
	constraint
		ifNil: [ self beginConstraintFromPosition: oldPosition to: newPosition ]
		ifNotNil: [ constraint updatePointerPosition: newPosition ].
	constraint ifNil: [ ^ self ].
	element relocate: oldPosition
]

{ #category : 'private' }
CFPhysicsPullInteractionHandler >> shouldHandle: anEvent [
	^ enabled and: [ anEvent target == element ]
]

{ #category : 'private' }
CFPhysicsPullInteractionHandler >> beginConstraintFrom: anEvent [
	self beginConstraintFromPosition: anEvent oldPosition to: anEvent newPosition
]

{ #category : 'private' }
CFPhysicsPullInteractionHandler >> beginConstraintFromPosition: oldPosition to: newPosition [
	| world body |
	world := element physics world.
	world ifNil: [ ^ self ].
	world synchroniseMembership.
	body := world bodyStateFor: element.
	(body isNil or: [ body isDynamic not ]) ifTrue: [ ^ self ].
	constraint := CFPhysicsPointerConstraint
		body: body
		pointerPosition: oldPosition.
	constraint
		responsiveness: responsiveness;
		velocityRetention: velocityRetention;
		maximumSpeed: maximumSpeed;
		movePointerPositionTo: newPosition.
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
CFPhysicsPullInteractionHandler >> enable [ enabled := true ]

{ #category : 'controlling' }
CFPhysicsPullInteractionHandler >> disable [
	enabled := false.
	self removeConstraint
]

{ #category : 'testing' }
CFPhysicsPullInteractionHandler >> isEnabled [ ^ enabled ]

{ #category : 'accessing' }
CFPhysicsPullInteractionHandler >> element [ ^ element ]

{ #category : 'accessing' }
CFPhysicsPullInteractionHandler >> constraint [ ^ constraint ]

{ #category : 'configuration' }
CFPhysicsPullInteractionHandler >> responsiveness [ ^ responsiveness ]

{ #category : 'configuration' }
CFPhysicsPullInteractionHandler >> responsiveness: aNumber [
	responsiveness := aNumber asFloat max: 0.0.
	constraint ifNotNil: [ constraint responsiveness: responsiveness ]
]

{ #category : 'configuration' }
CFPhysicsPullInteractionHandler >> velocityRetention [ ^ velocityRetention ]

{ #category : 'configuration' }
CFPhysicsPullInteractionHandler >> velocityRetention: aNumber [
	velocityRetention := (aNumber asFloat max: 0.0) min: 1.0.
	constraint ifNotNil: [ constraint velocityRetention: velocityRetention ]
]

{ #category : 'configuration' }
CFPhysicsPullInteractionHandler >> maximumSpeed [ ^ maximumSpeed ]

{ #category : 'configuration' }
CFPhysicsPullInteractionHandler >> maximumSpeed: aNumber [
	maximumSpeed := aNumber asFloat max: 0.0.
	constraint ifNotNil: [ constraint maximumSpeed: maximumSpeed ]
]
