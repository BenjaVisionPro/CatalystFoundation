"
I am the Physics facade attached to one Bloc element.

My responsibility is to expose element-oriented Physics configuration and operations while keeping runtime bodies, contacts, constraints and solver state behind the Bloc API.
"
Class {
	#name : 'CFPhysics',
	#superclass : 'Object',
	#instVars : [ 'element', 'body', 'pointerJointHandler' ],
	#category : 'BVC-Physics-Core',
	#package : 'BVC-Physics-Core'
}

{ #category : 'instance creation' }
CFPhysics class >> on: anElement [
	^ self new
		element: anElement;
		yourself
]


{ #category : 'body type' }
CFPhysics >> beDynamic [
	| aWorld aBody |
	aWorld := self world.
	aWorld ifNil: [ self error: 'The element does not belong to a physics world' ].
	aBody := aWorld addElement: element.
	aBody beDynamic.
	^ self
]

{ #category : 'body type' }
CFPhysics >> beKinematic [
	| aWorld aBody |
	aWorld := self world.
	aWorld ifNil: [ self error: 'The element does not belong to a physics world' ].
	aBody := aWorld addElement: element.
	aBody beKinematic.
	^ self
]

{ #category : 'body type' }
CFPhysics >> beStatic [
	| aWorld aBody |
	aWorld := self world.
	aWorld ifNil: [ self error: 'The element does not belong to a physics world' ].
	aBody := aWorld addElement: element.
	aBody beStatic.
	^ self
]

{ #category : 'worlds' }
CFPhysics >> beWorld [
	| aWorld |
	aWorld := self world.
	aWorld ifNotNil: [ ^ aWorld ].
	aWorld := CFPhysicsWorld on: element.
	element userData at: CFPhysicsWorld put: aWorld.
	element fireEvent: CFPhysicsWorldAttachmentChanged new.
	^ aWorld
]

{ #category : 'worlds' }
CFPhysics >> ceaseBeingWorld [
	| aWorld |
	aWorld := element userData at: CFPhysicsWorld ifAbsent: [ nil ].
	aWorld ifNil: [ ^ self ].
	aWorld release.
	element userData removeKey: CFPhysicsWorld ifAbsent: [ ].
	element fireEvent: CFPhysicsWorldAttachmentChanged new.
	^ self
]

{ #category : 'private - runtime' }
CFPhysics >> bodyOrNil [
	^ body
]


{ #category : 'private - bodies' }
CFPhysics >> bodyForRegistrationInWorld: aWorld [
	body ifNil: [ body := CFPhysicsBody element: element world: aWorld ].
	body world: aWorld.
	^ body
]


{ #category : 'private - world membership' }
CFPhysics >> retireFromCurrentWorld [
	body ifNil: [ ^ self ].
	body world ifNotNil: [ :aWorld | aWorld retireElement: element ].
	^ self
]

{ #category : 'private - bodies' }
CFPhysics >> retireBodyFromWorld: aWorld [
	(body notNil and: [ body world == aWorld ]) ifTrue: [ body world: nil ]
]

{ #category : 'accessing' }
CFPhysics >> element [
	^ element
]

{ #category : 'accessing' }
CFPhysics >> element: anElement [
	element := anElement.
	pointerJointHandler := CFPhysicsMouseJointHandler on: element.
	element
		when: BlElementRemovedFromParentEvent
		do: [ :anEvent | self retireFromCurrentWorld ]
]

{ #category : 'children' }
CFPhysics >> makeChildrenDynamic [
	^ self makeChildrenDynamicMatching: [ :each | true ]
]

{ #category : 'children' }
CFPhysics >> makeChildrenDynamicMatching: aBlock [
	element children do: [ :each |
		(aBlock value: each) ifTrue: [ each physics beDynamic ] ].
	^ self
]

{ #category : 'children' }
CFPhysics >> makeChildrenKinematic [
	^ self makeChildrenKinematicMatching: [ :each | true ]
]

{ #category : 'children' }
CFPhysics >> makeChildrenKinematicMatching: aBlock [
	element children do: [ :each |
		(aBlock value: each) ifTrue: [ each physics beKinematic ] ].
	^ self
]

{ #category : 'children' }
CFPhysics >> makeChildrenStatic [
	^ self makeChildrenStaticMatching: [ :each | true ]
]

{ #category : 'children' }
CFPhysics >> makeChildrenStaticMatching: aBlock [
	element children do: [ :each |
		(aBlock value: each) ifTrue: [ each physics beStatic ] ].
	^ self
]

{ #category : 'material' }
CFPhysics >> density [
	^ self body density
]

{ #category : 'material' }
CFPhysics >> density: aNumber [
	self body density: aNumber.
	^ self
]

{ #category : 'material' }
CFPhysics >> friction [
	^ self body friction
]

{ #category : 'material' }
CFPhysics >> friction: aNumber [
	self body friction: aNumber.
	^ self
]


{ #category : 'material' }
CFPhysics >> rollingResistance [
	^ self body rollingResistance
]

{ #category : 'material' }
CFPhysics >> rollingResistance: aNumber [
	self body rollingResistance: aNumber.
	^ self
]

{ #category : 'material' }
CFPhysics >> tangentSpeed [
	^ self body tangentSpeed
]

{ #category : 'material' }
CFPhysics >> tangentSpeed: aNumber [
	self body tangentSpeed: aNumber.
	^ self
]

{ #category : 'material' }
CFPhysics >> restitution [
	^ self body restitution
]

{ #category : 'material' }
CFPhysics >> restitution: aNumber [
	self body restitution: aNumber.
	^ self
]

{ #category : 'body type' }
CFPhysics >> isDynamic [
	^ self body isDynamic
]

{ #category : 'body type' }
CFPhysics >> isKinematic [
	^ self body isKinematic
]

{ #category : 'body type' }
CFPhysics >> isStatic [
	^ self body isStatic
]

{ #category : 'worlds' }
CFPhysics >> isWorld [
	^ element userData includesKey: CFPhysicsWorld
]

{ #category : 'bodies' }
CFPhysics >> position [
	"Answer the element's top-left position in the owning Bloc world's length units."
	^ self body position
]

{ #category : 'bodies' }
CFPhysics >> position: aPoint [
	"Set the element's top-left position in the owning Bloc world's length units."
	self body position: aPoint.
	^ self
]


{ #category : 'private - runtime' }
CFPhysics >> body [
	| aWorld |
	aWorld := self world.
	aWorld ifNil: [ self error: 'The element does not belong to a physics world' ].
	(body notNil and: [ body world == aWorld and: [ aWorld includes: element ] ])
		ifTrue: [ ^ body ].
	self error: 'The element is not participating in Physics. Send #beDynamic, #beKinematic or #beStatic first'
]

{ #category : 'bodies' }
CFPhysics >> rotation [
	^ self body rotation
]

{ #category : 'bodies' }
CFPhysics >> rotation: aNumber [
	self body rotation: aNumber.
	^ self
]


{ #category : 'worlds' }
CFPhysics >> world [
	| ancestor |
	(element userData at: CFPhysicsWorld ifAbsent: [ nil ])
		ifNotNil: [ :aWorld | ^ aWorld ].
	ancestor := element parent.
	[ ancestor notNil ] whileTrue: [
		(ancestor userData at: CFPhysicsWorld ifAbsent: [ nil ])
			ifNotNil: [ :aWorld | ^ aWorld ].
		ancestor := ancestor parent ].
	^ nil
]


{ #category : 'private - presentation' }
CFPhysics >> translation: aPoint rotation: aNumber [
	self body translation: aPoint rotation: aNumber.
	^ self
]

{ #category : 'bodies' }
CFPhysics >> velocity [
	"Answer linear velocity in physics length units per second."
	^ self body velocity
]

{ #category : 'bodies' }
CFPhysics >> velocity: aPoint [
	"Set linear velocity in physics length units per second."
	self body velocity: aPoint.
	^ self
]


{ #category : 'sleeping' }
CFPhysics >> isAwake [
	^ self body isAwake
]

{ #category : 'sleeping' }
CFPhysics >> isSleeping [
	^ self body isSleeping
]

{ #category : 'sleeping' }
CFPhysics >> allowsSleeping [
	^ self body allowsSleeping
]

{ #category : 'sleeping' }
CFPhysics >> allowSleeping [
	self body allowSleeping.
	^ self
]

{ #category : 'sleeping' }
CFPhysics >> sleepThreshold [
	^ self body sleepThreshold
]

{ #category : 'sleeping' }
CFPhysics >> sleepThreshold: aNumber [
	self body sleepThreshold: aNumber.
	^ self
]

{ #category : 'sleeping' }
CFPhysics >> preventSleeping [
	self body preventSleeping.
	^ self
]

{ #category : 'sleeping' }
CFPhysics >> sleep [
	self body sleep.
	^ self
]

{ #category : 'sleeping' }
CFPhysics >> wake [
	self body wake.
	^ self
]


{ #category : 'linear dynamics' }
CFPhysics >> addVelocity: aPoint [
	self body addVelocity: aPoint.
	^ self
]

{ #category : 'linear dynamics' }
CFPhysics >> applyForce: aPoint [
	self body applyForce: aPoint.
	^ self
]

{ #category : 'linear dynamics' }
CFPhysics >> applyImpulse: anImpulse [
	"Apply a linear impulse at the body's centre of mass."
	self body
		applyImpulse: anImpulse
		atWorldPoint: self body worldBodyOrigin.
	^ self
]

{ #category : 'linear dynamics' }
CFPhysics >> applyImpulse: anImpulse atWorldPoint: aPoint [
	"Apply a linear impulse at a point expressed in the owning world's coordinate frame."
	self body applyImpulse: anImpulse atWorldPoint: aPoint.
	^ self
]

{ #category : 'linear dynamics' }
CFPhysics >> clearForces [
	self body clearForces.
	^ self
]

{ #category : 'linear dynamics' }
CFPhysics >> linearDamping [ ^ self body linearDamping ]

{ #category : 'linear dynamics' }
CFPhysics >> linearDamping: aNumber [
	self body linearDamping: aNumber.
	^ self
]

{ #category : 'linear dynamics' }
CFPhysics >> gravityScale [ ^ self body gravityScale ]

{ #category : 'linear dynamics' }
CFPhysics >> gravityScale: aNumber [
	self body gravityScale: aNumber.
	^ self
]

{ #category : 'angular dynamics' }
CFPhysics >> angularVelocity [ ^ self body angularVelocity ]


{ #category : 'angular dynamics' }
CFPhysics >> angularVelocity: aNumber [
	self body angularVelocity: aNumber.
	^ self
]

{ #category : 'angular dynamics' }
CFPhysics >> angularDamping [ ^ self body angularDamping ]

{ #category : 'angular dynamics' }
CFPhysics >> angularDamping: aNumber [
	self body angularDamping: aNumber.
	^ self
]

{ #category : 'angular dynamics' }
CFPhysics >> applyTorque: aNumber [
	self body applyTorque: aNumber.
	^ self
]


{ #category : 'continuous collision' }
CFPhysics >> beBullet [
	self body beBullet.
	^ self
]

{ #category : 'continuous collision' }
CFPhysics >> beNonBullet [
	self body beNonBullet.
	^ self
]

{ #category : 'continuous collision' }
CFPhysics >> isBullet [
	^ self body isBullet
]

{ #category : 'sensors' }
CFPhysics >> beSensor [
	self body beSensor.
	^ self
]

{ #category : 'sensors' }
CFPhysics >> beSolid [
	self body beSolid.
	^ self
]

{ #category : 'sensors' }
CFPhysics >> isSensor [
	^ self body isSensor
]


{ #category : 'collision filtering' }
CFPhysics >> collisionCategoryBits [
	^ self body collisionCategoryBits
]

{ #category : 'collision filtering' }
CFPhysics >> collisionCategoryBits: anInteger [
	self body collisionCategoryBits: anInteger.
	^ self
]

{ #category : 'collision filtering' }
CFPhysics >> collisionMaskBits [
	^ self body collisionMaskBits
]

{ #category : 'collision filtering' }
CFPhysics >> collisionMaskBits: anInteger [
	self body collisionMaskBits: anInteger.
	^ self
]

{ #category : 'collision filtering' }
CFPhysics >> collisionGroupIndex [
	^ self body collisionGroupIndex
]

{ #category : 'collision filtering' }
CFPhysics >> collisionGroupIndex: anInteger [
	self body collisionGroupIndex: anInteger.
	^ self
]


{ #category : 'private - interaction' }
CFPhysics >> enablePullInteraction [
	pointerJointHandler enable.
	^ pointerJointHandler
]

{ #category : 'private - interaction' }
CFPhysics >> disablePullInteraction [
	pointerJointHandler disable.
	^ pointerJointHandler
]

{ #category : 'private - interaction' }
CFPhysics >> isPullInteractionEnabled [
	^ pointerJointHandler isEnabled
]

{ #category : 'private - interaction' }
CFPhysics >> pointerJointHandler [
	^ pointerJointHandler
]

{ #category : 'joints' }
CFPhysics >> joints [
	| body |
	body := self bodyOrNil.
	body ifNil: [ ^ #() ].
	^ body joints
]

{ #category : 'distance joints' }
CFPhysics >> distanceJointTo: anotherElement [
	| body |
	body := self body.
	^ body world addJoint: (CFPhysicsDistanceJoint
		between: body
		and: anotherElement physics body)
]

{ #category : 'distance joints' }
CFPhysics >> distanceJoints [
	| aWorld body |
	aWorld := self world.
	aWorld ifNil: [ ^ #() ].
	body := aWorld bodyStateFor: element.
	body ifNil: [ ^ #() ].
	^ aWorld distanceJointsUsingBody: body
]


{ #category : 'motor joints' }
CFPhysics >> motorJointTo: anotherElement [
	| body |
	body := self body.
	^ body world addJoint: (CFPhysicsMotorJoint
		between: body
		and: anotherElement physics body)
]

{ #category : 'motor joints' }
CFPhysics >> motorJoints [
	| aWorld body |
	aWorld := self world.
	aWorld ifNil: [ ^ #() ].
	body := aWorld bodyStateFor: element.
	body ifNil: [ ^ #() ].
	^ aWorld motorJointsUsingBody: body
]


{ #category : 'filter joints' }
CFPhysics >> filterJointTo: anotherElement [
	| body |
	body := self body.
	^ body world addJoint: (CFPhysicsFilterJoint
		between: body
		and: anotherElement physics body)
]

{ #category : 'filter joints' }
CFPhysics >> filterJoints [
	| aWorld body |
	aWorld := self world.
	aWorld ifNil: [ ^ #() ].
	body := aWorld bodyStateFor: element.
	body ifNil: [ ^ #() ].
	^ aWorld filterJointsUsingBody: body
]


{ #category : 'revolute joints' }
CFPhysics >> revoluteJointTo: anotherElement [
	| body |
	body := self body.
	^ body world addJoint: (CFPhysicsRevoluteJoint
		between: body
		and: anotherElement physics body)
]

{ #category : 'revolute joints' }
CFPhysics >> revoluteJoints [
	| aWorld body |
	aWorld := self world.
	aWorld ifNil: [ ^ #() ].
	body := aWorld bodyStateFor: element.
	body ifNil: [ ^ #() ].
	^ aWorld revoluteJointsUsingBody: body
]


{ #category : 'weld joints' }
CFPhysics >> weldJointTo: anotherElement [
	| body |
	body := self body.
	^ body world addJoint: (CFPhysicsWeldJoint
		between: body
		and: anotherElement physics body)
]

{ #category : 'weld joints' }
CFPhysics >> weldJoints [
	| aWorld body |
	aWorld := self world.
	aWorld ifNil: [ ^ #() ].
	body := aWorld bodyStateFor: element.
	body ifNil: [ ^ #() ].
	^ aWorld weldJointsUsingBody: body
]


{ #category : 'prismatic joints' }
CFPhysics >> prismaticJointTo: anotherElement along: anAxis [
	| body |
	body := self body.
	^ body world addJoint: (CFPhysicsPrismaticJoint
		between: body
		and: anotherElement physics body
		along: anAxis)
]

{ #category : 'prismatic joints' }
CFPhysics >> prismaticJoints [
	| aWorld body |
	aWorld := self world.
	aWorld ifNil: [ ^ #() ].
	body := aWorld bodyStateFor: element.
	body ifNil: [ ^ #() ].
	^ aWorld prismaticJointsUsingBody: body
]



{ #category : 'forces' }
CFPhysics >> restoreOrientation [
	| aWorld force |
	aWorld := self world.
	aWorld ifNil: [ self error: 'The element does not belong to a Physics world' ].
	force := CFPhysicsOrientationRestoringForce new body: self body.
	^ aWorld addForce: force
]

{ #category : 'attraction interaction' }
CFPhysics >> attract: anotherElement [
	| aWorld otherWorld attraction |
	aWorld := self world.
	otherWorld := anotherElement physics world.
	(aWorld notNil and: [ aWorld == otherWorld ])
		ifFalse: [ self error: 'Both elements must belong to the same physics world' ].
	attraction := CFPhysicsAttractionForce
		between: self body
		and: anotherElement physics body.
	^ aWorld addForce: attraction
]

{ #category : 'attraction interaction' }
CFPhysics >> attractions [
	| aWorld body |
	aWorld := self world.
	aWorld ifNil: [ ^ #() ].
	body := aWorld bodyStateFor: element.
	body ifNil: [ ^ #() ].
	^ aWorld attractionsUsingBody: body
]




{ #category : 'repulsion interaction' }
CFPhysics >> repel: anotherElement [
	| aWorld otherWorld repulsion |
	aWorld := self world.
	otherWorld := anotherElement physics world.
	(aWorld notNil and: [ aWorld == otherWorld ])
		ifFalse: [ self error: 'Both elements must belong to the same physics world' ].
	repulsion := CFPhysicsRepulsionForce
		between: self body
		and: anotherElement physics body.
	^ aWorld addForce: repulsion
]

{ #category : 'repulsion interaction' }
CFPhysics >> repulsions [
	| aWorld body |
	aWorld := self world.
	aWorld ifNil: [ ^ #() ].
	body := aWorld bodyStateFor: element.
	body ifNil: [ ^ #() ].
	^ aWorld repulsionsUsingBody: body
]


{ #category : 'anchors' }
CFPhysics >> localAnchorAt: aPoint [
	| aWorld |
	aWorld := self world.
	aWorld ifNil: [ self error: 'The element does not belong to a physics world' ].
	^ CFPhysicsLocalAnchor on: self body at: aPoint
]

{ #category : 'anchors' }
CFPhysics >> normalisedAnchorAt: aPoint [
	| aWorld |
	aWorld := self world.
	aWorld ifNil: [ self error: 'The element does not belong to a physics world' ].
	^ CFPhysicsNormalisedAnchor on: self body at: aPoint
]


{ #category : 'anchors' }
CFPhysics >> worldAnchorAt: aPoint [
	| aWorld |
	aWorld := self world.
	aWorld ifNil: [ self error: 'The element does not belong to a physics world' ].
	^ aWorld anchorAt: aPoint
]



{ #category : 'angular dynamics' }
CFPhysics >> applyAngularImpulse: aNumber [
	self body applyAngularImpulse: aNumber.
	^ self
]



{ #category : 'wheel joints' }
CFPhysics >> wheelJointTo: anotherElement along: anAxis [
	| body |
	body := self body.
	^ body world addJoint: (CFPhysicsWheelJoint
		between: body
		and: anotherElement physics body
		along: anAxis)
]

{ #category : 'wheel joints' }
CFPhysics >> wheelJoints [
	| aWorld body |
	aWorld := self world.
	aWorld ifNil: [ ^ #() ].
	body := aWorld bodyStateFor: element.
	body ifNil: [ ^ #() ].
	^ aWorld wheelJointsUsingBody: body
]

