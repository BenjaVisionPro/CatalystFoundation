"
I am the Physics facade attached to one Bloc element.

My responsibility is to expose element-oriented access to body, world, interaction, membership and Behaviour capabilities while keeping simulation objects behind the Bloc API. I create or locate the Physics state associated with my element.
"
Class {
	#name : 'CFPhysics',
	#superclass : 'Object',
	#instVars : [ 'element', 'body', 'pointerJointHandler', 'behaviours' ],
	#category : 'BVC-Physics-Core',
	#package : 'BVC-Physics-Core'
}

{ #category : 'instance creation' }
CFPhysics class >> on: anElement [
	^ self new
		element: anElement;
		yourself
]


{ #category : 'initialization' }
CFPhysics >> initialize [
	super initialize.
	behaviours := OrderedCollection new
]

{ #category : 'behaviours' }
CFPhysics >> behaviours [
	^ behaviours copy
]

{ #category : 'behaviours' }
CFPhysics >> addBehaviour: aBehaviour [
	| aWorld |
	(aBehaviour physics notNil and: [ aBehaviour physics ~~ self ]) ifTrue: [
		self error: 'The Physics Behaviour already belongs to another Physics facade' ].
	aWorld := self world.
	aWorld ifNil: [
		self error: 'A Physics Behaviour requires an element belonging to a physics world' ].
	(behaviours identityIncludes: aBehaviour) ifTrue: [ ^ aBehaviour ].
	aBehaviour
		physics: self;
		world: aWorld.
	behaviours add: aBehaviour.
	aWorld addBehaviour: aBehaviour.
	^ aBehaviour
]

{ #category : 'behaviours' }
CFPhysics >> removeBehaviour: aBehaviour [
	behaviours remove: aBehaviour ifAbsent: [ ].
	^ aBehaviour
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

{ #category : 'bodies' }
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


{ #category : 'bodies' }
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


{ #category : 'bodies' }
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

{ #category : 'mass' }
CFPhysics >> inverseInertia [ ^ self body inverseInertia ]


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

{ #category : 'distance joints' }
CFPhysics >> distanceJointTo: anotherElement [
	| aWorld otherWorld joint |
	aWorld := self world.
	otherWorld := anotherElement physics world.
	(aWorld notNil and: [ aWorld == otherWorld ])
		ifFalse: [ self error: 'Both elements must belong to the same physics world' ].
	joint := CFPhysicsDistanceJoint
		between: self body
		and: anotherElement physics body.
	^ aWorld addDistanceJoint: joint
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

{ #category : 'distance joints' }
CFPhysics >> removeDistanceJoint: aJoint [
	| aWorld |
	aWorld := self world.
	aWorld ifNotNil: [ aWorld removeDistanceJoint: aJoint ]
]

{ #category : 'motor joints' }
CFPhysics >> motorJointTo: anotherElement [
	| aWorld otherWorld joint |
	aWorld := self world. otherWorld := anotherElement physics world.
	(aWorld notNil and: [ aWorld == otherWorld ]) ifFalse: [ self error: 'Both elements must belong to the same physics world' ].
	joint := CFPhysicsMotorJoint between: self body and: anotherElement physics body.
	^ aWorld addMotorJoint: joint
]

{ #category : 'motor joints' }
CFPhysics >> motorJoints [ | aWorld body | aWorld := self world. aWorld ifNil: [ ^ #() ]. body := aWorld bodyStateFor: element. body ifNil: [ ^ #() ]. ^ aWorld motorJoints select: [ :each | each includesBody: body ] ]

{ #category : 'motor joints' }
CFPhysics >> removeMotorJoint: aJoint [ self world ifNotNil: [ :aWorld | aWorld removeMotorJoint: aJoint ] ]

{ #category : 'filter joints' }
CFPhysics >> filterJointTo: anotherElement [
	| aWorld otherWorld joint |
	aWorld := self world.
	otherWorld := anotherElement physics world.
	(aWorld notNil and: [ aWorld == otherWorld ]) ifFalse: [
		self error: 'Both elements must belong to the same physics world' ].
	joint := CFPhysicsFilterJoint between: self body and: anotherElement physics body.
	^ aWorld addFilterJoint: joint
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

{ #category : 'filter joints' }
CFPhysics >> removeFilterJoint: aJoint [
	self world ifNotNil: [ :aWorld | aWorld removeFilterJoint: aJoint ]
]

{ #category : 'revolute joints' }
CFPhysics >> revoluteJointTo: anotherElement [
	| aWorld otherWorld joint |
	aWorld := self world.
	otherWorld := anotherElement physics world.
	(aWorld notNil and: [ aWorld == otherWorld ])
		ifFalse: [ self error: 'Both elements must belong to the same physics world' ].
	joint := CFPhysicsRevoluteJoint
		between: self body
		and: anotherElement physics body.
	^ aWorld addRevoluteJoint: joint
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

{ #category : 'revolute joints' }
CFPhysics >> removeRevoluteJoint: aJoint [
	| aWorld |
	aWorld := self world.
	aWorld ifNotNil: [ aWorld removeRevoluteJoint: aJoint ]
]

{ #category : 'weld joints' }
CFPhysics >> weldJointTo: anotherElement [
	| aWorld otherWorld joint |
	aWorld := self world.
	otherWorld := anotherElement physics world.
	(aWorld notNil and: [ aWorld == otherWorld ])
		ifFalse: [ self error: 'Both elements must belong to the same physics world' ].
	joint := CFPhysicsWeldJoint
		between: self body
		and: anotherElement physics body.
	^ aWorld addWeldJoint: joint
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

{ #category : 'weld joints' }
CFPhysics >> removeWeldJoint: aJoint [
	| aWorld |
	aWorld := self world.
	aWorld ifNotNil: [ aWorld removeWeldJoint: aJoint ]
]

{ #category : 'prismatic joints' }
CFPhysics >> prismaticJointTo: anotherElement along: anAxis [
	| aWorld otherWorld joint |
	aWorld := self world.
	otherWorld := anotherElement physics world.
	(aWorld notNil and: [ aWorld == otherWorld ])
		ifFalse: [ self error: 'Both elements must belong to the same physics world' ].
	joint := CFPhysicsPrismaticJoint
		between: self body
		and: anotherElement physics body
		along: anAxis.
	^ aWorld addPrismaticJoint: joint
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

{ #category : 'prismatic joints' }
CFPhysics >> removePrismaticJoint: aJoint [
	| aWorld |
	aWorld := self world.
	aWorld ifNotNil: [ aWorld removePrismaticJoint: aJoint ]
]


{ #category : 'attraction interaction' }
CFPhysics >> attract: anotherElement [
	| aWorld otherWorld attraction |
	aWorld := self world.
	otherWorld := anotherElement physics world.
	(aWorld notNil and: [ aWorld == otherWorld ])
		ifFalse: [ self error: 'Both elements must belong to the same physics world' ].
	attraction := CFPhysicsAttractionConstraint
		between: self body
		and: anotherElement physics body.
	^ aWorld addAttractionConstraint: attraction
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

{ #category : 'attraction interaction' }
CFPhysics >> removeAttraction: anAttractionConstraint [
	| aWorld |
	aWorld := self world.
	aWorld ifNotNil: [ aWorld removeAttractionConstraint: anAttractionConstraint ]
]



{ #category : 'repulsion interaction' }
CFPhysics >> repel: anotherElement [
	| aWorld otherWorld repulsion |
	aWorld := self world.
	otherWorld := anotherElement physics world.
	(aWorld notNil and: [ aWorld == otherWorld ])
		ifFalse: [ self error: 'Both elements must belong to the same physics world' ].
	repulsion := CFPhysicsRepulsionConstraint
		between: self body
		and: anotherElement physics body.
	^ aWorld addRepulsionConstraint: repulsion
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

{ #category : 'repulsion interaction' }
CFPhysics >> removeRepulsion: aRepulsionConstraint [
	| aWorld |
	aWorld := self world.
	aWorld ifNotNil: [ aWorld removeRepulsionConstraint: aRepulsionConstraint ]
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


{ #category : 'relationship endpoints' }
CFPhysics >> nearestGeometryEndpointsTo: anotherElement [
	| aWorld otherWorld |
	aWorld := self world.
	otherWorld := anotherElement physics world.
	(aWorld notNil and: [ aWorld == otherWorld ])
		ifFalse: [ self error: 'Both elements must belong to the same physics world' ].
	^ CFPhysicsNearestGeometryEndpointPair
		between: self body
		and: anotherElement physics body
]

{ #category : 'angular dynamics' }
CFPhysics >> applyAngularImpulse: aNumber [
	self body applyAngularImpulse: aNumber
]



{ #category : 'wheel joints' }
CFPhysics >> wheelJointTo: anotherElement along: anAxis [
	| aWorld otherWorld joint |
	aWorld := self world.
	otherWorld := anotherElement physics world.
	(aWorld notNil and: [ aWorld == otherWorld ])
		ifFalse: [ self error: 'Both elements must belong to the same physics world' ].
	joint := CFPhysicsWheelJoint between: self body and: anotherElement physics body along: anAxis.
	^ aWorld addWheelJoint: joint
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

{ #category : 'wheel joints' }
CFPhysics >> removeWheelJoint: aJoint [
	self world ifNotNil: [ :aWorld | aWorld removeWheelJoint: aJoint ]
]
