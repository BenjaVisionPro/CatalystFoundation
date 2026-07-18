Class {
	#name : 'CFPhysicsElement',
	#superclass : 'Object',
	#instVars : [ 'element', 'ownedWorld', 'pointerDragHandler' ],
	#category : 'BVC-Foundation-Physics-World',
	#package : 'BVC-Foundation-Physics-World'
}

{ #category : 'instance creation' }
CFPhysicsElement class >> on: anElement [
	^ self new
		element: anElement;
		yourself
]

{ #category : 'body type' }
CFPhysicsElement >> beDynamic [
	self requireBodyState beDynamic
]

{ #category : 'body type' }
CFPhysicsElement >> beStatic [
	self requireBodyState beStatic
]

{ #category : 'worlds' }
CFPhysicsElement >> beWorld [
	ownedWorld ifNil: [ ownedWorld := CFPhysicsWorld on: element ].
	^ ownedWorld
]

{ #category : 'bodies' }
CFPhysicsElement >> bodyState [
	| owningWorld |
	owningWorld := self owningWorld.
	owningWorld ifNil: [ ^ nil ].
	^ owningWorld bodyStateFor: element
]

{ #category : 'accessing' }
CFPhysicsElement >> element [
	^ element
]

{ #category : 'accessing' }
CFPhysicsElement >> element: anElement [
	element := anElement
]


{ #category : 'material' }
CFPhysicsElement >> density [
	^ self requireBodyState density
]

{ #category : 'material' }
CFPhysicsElement >> density: aNumber [
	self requireBodyState density: aNumber
]

{ #category : 'material' }
CFPhysicsElement >> friction [
	^ self requireBodyState friction
]

{ #category : 'material' }
CFPhysicsElement >> friction: aNumber [
	self requireBodyState friction: aNumber
]

{ #category : 'material' }
CFPhysicsElement >> restitution [
	^ self requireBodyState restitution
]

{ #category : 'material' }
CFPhysicsElement >> restitution: aNumber [
	self requireBodyState restitution: aNumber
]

{ #category : 'worlds' }
CFPhysicsElement >> existingWorld [
	^ ownedWorld
]

{ #category : 'worlds' }
CFPhysicsElement >> ownedWorld [
	^ ownedWorld
]

{ #category : 'body type' }
CFPhysicsElement >> isDynamic [
	^ self requireBodyState isDynamic
]

{ #category : 'body type' }
CFPhysicsElement >> isStatic [
	^ self requireBodyState isStatic
]

{ #category : 'worlds' }
CFPhysicsElement >> isWorld [
	^ ownedWorld notNil
]

{ #category : 'worlds' }
CFPhysicsElement >> owningWorld [
	| ancestor physics |
	ancestor := element parent.
	[ ancestor notNil ] whileTrue: [
		physics := ancestor existingPhysics.
		physics ifNotNil: [
			physics existingWorld ifNotNil: [ :anExistingWorld |
				^ anExistingWorld ] ].
		ancestor := ancestor parent ].
	^ nil
]

{ #category : 'bodies' }
CFPhysicsElement >> position [
	^ self requireBodyState position
]

{ #category : 'bodies' }
CFPhysicsElement >> position: aPoint [
	self requireBodyState position: aPoint
]

{ #category : 'bodies' }
CFPhysicsElement >> presentation [
	^ self requireBodyState presentation
]

{ #category : 'private - bodies' }
CFPhysicsElement >> requireBodyState [
	| owningWorld bodyState |
	owningWorld := self owningWorld.
	owningWorld ifNil: [ self error: 'The element does not belong to a physics world' ].
	bodyState := owningWorld bodyStateFor: element.
	bodyState ifNil: [
		owningWorld synchroniseMembership.
		bodyState := owningWorld bodyStateFor: element ].
	bodyState ifNil: [ self error: 'The element is not tracked by its physics world' ].
	^ bodyState
]

{ #category : 'bodies' }
CFPhysicsElement >> rotation [
	^ self requireBodyState rotation
]

{ #category : 'bodies' }
CFPhysicsElement >> rotation: aNumber [
	self requireBodyState rotation: aNumber
]


{ #category : 'worlds' }
CFPhysicsElement >> world [
	"Answer the physics world that contains this element. World-owning elements
	use #ownedWorld to access the world they establish."
	^ self owningWorld
]

{ #category : 'worlds' }
CFPhysicsElement >> synchroniseWorldMembership [
	| owningWorld |
	owningWorld := self owningWorld.
	ownedWorld ifNotNil: [ ownedWorld synchroniseMembership ].
	owningWorld ifNotNil: [ owningWorld synchroniseMembership ].
	^ owningWorld
]

{ #category : 'bodies' }
CFPhysicsElement >> translation: aPoint rotation: aNumber [
	self requireBodyState translation: aPoint rotation: aNumber
]

{ #category : 'bodies' }
CFPhysicsElement >> velocity [
	^ self requireBodyState velocity
]

{ #category : 'bodies' }
CFPhysicsElement >> velocity: aPoint [
	self requireBodyState velocity: aPoint
]


{ #category : 'sleeping' }
CFPhysicsElement >> isAwake [
	^ self requireBodyState isAwake
]

{ #category : 'sleeping' }
CFPhysicsElement >> isSleeping [
	^ self requireBodyState isSleeping
]

{ #category : 'sleeping' }
CFPhysicsElement >> sleep [
	self requireBodyState sleep
]

{ #category : 'sleeping' }
CFPhysicsElement >> wake [
	self requireBodyState wake
]


{ #category : 'angular dynamics' }
CFPhysicsElement >> angularVelocity [ ^ self requireBodyState angularVelocity ]

{ #category : 'angular dynamics' }
CFPhysicsElement >> angularVelocity: aNumber [ self requireBodyState angularVelocity: aNumber ]

{ #category : 'angular dynamics' }
CFPhysicsElement >> angularDamping [ ^ self requireBodyState angularDamping ]

{ #category : 'angular dynamics' }
CFPhysicsElement >> angularDamping: aNumber [ self requireBodyState angularDamping: aNumber ]

{ #category : 'angular dynamics' }
CFPhysicsElement >> applyTorque: aNumber [ self requireBodyState applyTorque: aNumber ]

{ #category : 'mass' }
CFPhysicsElement >> inverseInertia [ ^ self requireBodyState inverseInertia ]


{ #category : 'sensors' }
CFPhysicsElement >> beSensor [
	self requireBodyState beSensor
]

{ #category : 'sensors' }
CFPhysicsElement >> beSolid [
	self requireBodyState beSolid
]

{ #category : 'sensors' }
CFPhysicsElement >> isSensor [
	^ self requireBodyState isSensor
]


{ #category : 'collision filtering' }
CFPhysicsElement >> collisionCategoryBits [
	^ self requireBodyState collisionCategoryBits
]

{ #category : 'collision filtering' }
CFPhysicsElement >> collisionCategoryBits: anInteger [
	self requireBodyState collisionCategoryBits: anInteger
]

{ #category : 'collision filtering' }
CFPhysicsElement >> collisionMaskBits [
	^ self requireBodyState collisionMaskBits
]

{ #category : 'collision filtering' }
CFPhysicsElement >> collisionMaskBits: anInteger [
	self requireBodyState collisionMaskBits: anInteger
]

{ #category : 'collision filtering' }
CFPhysicsElement >> collisionGroupIndex [
	^ self requireBodyState collisionGroupIndex
]

{ #category : 'collision filtering' }
CFPhysicsElement >> collisionGroupIndex: anInteger [
	self requireBodyState collisionGroupIndex: anInteger
]


{ #category : 'pointer interaction' }
CFPhysicsElement >> enablePointerDragging [
	pointerDragHandler ifNil: [
		pointerDragHandler := CFPhysicsPointerDragHandler on: element ].
	^ pointerDragHandler
]

{ #category : 'pointer interaction' }
CFPhysicsElement >> disablePointerDragging [
	pointerDragHandler ifNotNil: [ pointerDragHandler uninstall ].
	pointerDragHandler := nil
]

{ #category : 'pointer interaction' }
CFPhysicsElement >> isPointerDraggingEnabled [
	^ pointerDragHandler notNil
]

{ #category : 'pointer interaction' }
CFPhysicsElement >> pointerDragHandler [
	^ pointerDragHandler
]


{ #category : 'spring interaction' }
CFPhysicsElement >> springTo: anotherElement [
	| aWorld otherWorld spring |
	aWorld := self owningWorld.
	otherWorld := anotherElement physics owningWorld.
	(aWorld notNil and: [ aWorld == otherWorld ])
		ifFalse: [ self error: 'Both elements must belong to the same physics world' ].
	aWorld synchroniseMembership.
	spring := CFPhysicsSpringConstraint
		between: self requireBodyState
		and: anotherElement physics requireBodyState.
	^ aWorld addSpringConstraint: spring
]


{ #category : 'spring interaction' }
CFPhysicsElement >> springs [
	| aWorld body |
	aWorld := self owningWorld.
	aWorld ifNil: [ ^ #() ].
	aWorld synchroniseMembership.
	body := aWorld bodyStateFor: element.
	body ifNil: [ ^ #() ].
	^ aWorld springsUsingBody: body
]

{ #category : 'spring interaction' }
CFPhysicsElement >> removeSpring: aSpringConstraint [
	| aWorld |
	aWorld := self owningWorld.
	aWorld ifNotNil: [ aWorld removeSpringConstraint: aSpringConstraint ]
]


{ #category : 'containment interaction' }
CFPhysicsElement >> containWithinWorld [
	| aWorld constraint |
	aWorld := self owningWorld.
	aWorld ifNil: [ self error: 'The element does not belong to a physics world' ].
	aWorld synchroniseMembership.
	constraint := CFPhysicsContainmentConstraint on: self requireBodyState.
	^ aWorld addContainmentConstraint: constraint
]

{ #category : 'containment interaction' }
CFPhysicsElement >> removeContainment: aContainmentConstraint [
	| aWorld |
	aWorld := self owningWorld.
	aWorld ifNotNil: [ aWorld removeContainmentConstraint: aContainmentConstraint ]
]

{ #category : 'attraction interaction' }
CFPhysicsElement >> attract: anotherElement [
	| aWorld otherWorld attraction |
	aWorld := self owningWorld.
	otherWorld := anotherElement physics owningWorld.
	(aWorld notNil and: [ aWorld == otherWorld ])
		ifFalse: [ self error: 'Both elements must belong to the same physics world' ].
	aWorld synchroniseMembership.
	attraction := CFPhysicsAttractionConstraint
		between: self requireBodyState
		and: anotherElement physics requireBodyState.
	^ aWorld addAttractionConstraint: attraction
]

{ #category : 'attraction interaction' }
CFPhysicsElement >> attractions [
	| aWorld body |
	aWorld := self owningWorld.
	aWorld ifNil: [ ^ #() ].
	aWorld synchroniseMembership.
	body := aWorld bodyStateFor: element.
	body ifNil: [ ^ #() ].
	^ aWorld attractionsUsingBody: body
]

{ #category : 'attraction interaction' }
CFPhysicsElement >> removeAttraction: anAttractionConstraint [
	| aWorld |
	aWorld := self owningWorld.
	aWorld ifNotNil: [ aWorld removeAttractionConstraint: anAttractionConstraint ]
]



{ #category : 'repulsion interaction' }
CFPhysicsElement >> repel: anotherElement [
	| aWorld otherWorld repulsion |
	aWorld := self owningWorld.
	otherWorld := anotherElement physics owningWorld.
	(aWorld notNil and: [ aWorld == otherWorld ])
		ifFalse: [ self error: 'Both elements must belong to the same physics world' ].
	aWorld synchroniseMembership.
	repulsion := CFPhysicsRepulsionConstraint
		between: self requireBodyState
		and: anotherElement physics requireBodyState.
	^ aWorld addRepulsionConstraint: repulsion
]

{ #category : 'repulsion interaction' }
CFPhysicsElement >> repulsions [
	| aWorld body |
	aWorld := self owningWorld.
	aWorld ifNil: [ ^ #() ].
	aWorld synchroniseMembership.
	body := aWorld bodyStateFor: element.
	body ifNil: [ ^ #() ].
	^ aWorld repulsionsUsingBody: body
]

{ #category : 'repulsion interaction' }
CFPhysicsElement >> removeRepulsion: aRepulsionConstraint [
	| aWorld |
	aWorld := self owningWorld.
	aWorld ifNotNil: [ aWorld removeRepulsionConstraint: aRepulsionConstraint ]
]

{ #category : 'anchors' }
CFPhysicsElement >> localAnchorAt: aPoint [
	| aWorld |
	aWorld := self owningWorld.
	aWorld ifNil: [ self error: 'The element does not belong to a physics world' ].
	aWorld synchroniseMembership.
	^ CFPhysicsLocalAnchor on: self requireBodyState at: aPoint
]
