Class {
	#name : 'CFPhysicsPullInteractionHandler',
	#superclass : 'Object',
	#instVars : [ 'element', 'constraint', 'startHandler', 'pullHandler', 'endHandler', 'enabled', 'responsiveness', 'velocityRetention', 'maximumSpeed' ],
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
	maximumSpeed := 2400.0
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
	element
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
	(self shouldHandle: anEvent) ifFalse: [ ^ self ].
	constraint
		ifNil: [ self beginConstraintFrom: anEvent ]
		ifNotNil: [ constraint updatePointerPosition: anEvent newPosition ].
	constraint ifNil: [ ^ self ].
	self restorePositionFrom: anEvent
]

{ #category : 'events' }
CFPhysicsPullInteractionHandler >> endFrom: anEvent [
	(self shouldHandle: anEvent) ifFalse: [ ^ self ].
	constraint ifNil: [ ^ self ].
	self finishConstraint
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
	world := element physics world.
	world ifNil: [ ^ self ].
	world synchroniseMembership.
	body := world bodyStateFor: element.
	(body isNil or: [ body isDynamic not ]) ifTrue: [ ^ self ].
	constraint := CFPhysicsPointerConstraint
		body: body
		pointerPosition: anEvent oldPosition.
	constraint
		responsiveness: responsiveness;
		velocityRetention: velocityRetention;
		maximumSpeed: maximumSpeed;
		movePointerPositionTo: anEvent newPosition.
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
