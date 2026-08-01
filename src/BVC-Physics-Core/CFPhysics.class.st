"
I am the Physics facade attached to one Bloc element.

My responsibility is to expose element-oriented access to body, world, interaction, membership and Behaviour capabilities while keeping simulation objects behind the Bloc API. I create or locate the Physics state associated with my element.
"
Class {
	#name : 'CFPhysics',
	#superclass : 'Object',
	#instVars : [ 'element', 'body', 'pointerJointHandler', 'excludedFromWorld', 'behaviours' ],
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
	self body beDynamic
]

{ #category : 'body type' }
CFPhysics >> beKinematic [
	self body beKinematic
]

{ #category : 'body type' }
CFPhysics >> beStatic [
	self body beStatic
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

{ #category : 'body type' }
CFPhysics >> bodyType [
	^ self body bodyType
]

{ #category : 'bodies' }
CFPhysics >> bodyOrNil [
	^ body
]


{ #category : 'private - bodies' }
CFPhysics >> ensureBodyInWorld: aWorld [
	body ifNil: [ body := CFPhysicsBody element: element world: aWorld ].
	body world: aWorld.
	^ body
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
	pointerJointHandler := CFPhysicsPointerJointHandler on: element
]

{ #category : 'world membership' }
CFPhysics >> excludeFromWorld [
	excludedFromWorld := true
]

{ #category : 'world membership' }
CFPhysics >> includeInWorld [
	excludedFromWorld := false
]

{ #category : 'world membership' }
CFPhysics >> isExcludedFromWorld [
	^ excludedFromWorld = true
]

{ #category : 'world membership' }
CFPhysics >> excludeDescendantsFromWorld [
	element children do: [ :each |
		each physics
			excludeFromWorld;
			excludeDescendantsFromWorld ]
]


{ #category : 'material' }
CFPhysics >> density [
	^ self body density
]

{ #category : 'material' }
CFPhysics >> density: aNumber [
	self body density: aNumber
]

{ #category : 'material' }
CFPhysics >> friction [
	^ self body friction
]

{ #category : 'material' }
CFPhysics >> friction: aNumber [
	self body friction: aNumber
]

{ #category : 'material' }
CFPhysics >> restitution [
	^ self body restitution
]

{ #category : 'material' }
CFPhysics >> restitution: aNumber [
	self body restitution: aNumber
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
	^ self body position
]

{ #category : 'bodies' }
CFPhysics >> position: aPoint [
	self body position: aPoint
]


{ #category : 'bodies' }
CFPhysics >> body [
	| aWorld |
	body ifNotNil: [ ^ body ].
	aWorld := self world.
	aWorld ifNil: [ self error: 'The element does not belong to a physics world' ].
	aWorld synchroniseMembership.
	body ifNil: [ self error: 'The element is not tracked by its physics world' ].
	^ body
]

{ #category : 'bodies' }
CFPhysics >> rotation [
	^ self body rotation
]

{ #category : 'bodies' }
CFPhysics >> rotation: aNumber [
	self body rotation: aNumber
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
	self body translation: aPoint rotation: aNumber
]

{ #category : 'bodies' }
CFPhysics >> velocity [
	^ self body velocity
]

{ #category : 'bodies' }
CFPhysics >> velocity: aPoint [
	self body velocity: aPoint
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
	self body allowSleeping
]

{ #category : 'sleeping' }
CFPhysics >> preventSleeping [
	self body preventSleeping
]

{ #category : 'sleeping' }
CFPhysics >> sleep [
	self body sleep
]

{ #category : 'sleeping' }
CFPhysics >> wake [
	self body wake
]


{ #category : 'linear dynamics' }
CFPhysics >> applyForce: aPoint [ self body applyForce: aPoint ]

{ #category : 'linear dynamics' }
CFPhysics >> clearForces [ self body clearForces ]

{ #category : 'linear dynamics' }
CFPhysics >> linearDamping [ ^ self body linearDamping ]

{ #category : 'linear dynamics' }
CFPhysics >> linearDamping: aNumber [ self body linearDamping: aNumber ]

{ #category : 'linear dynamics' }
CFPhysics >> gravityScale [ ^ self body gravityScale ]

{ #category : 'linear dynamics' }
CFPhysics >> gravityScale: aNumber [ self body gravityScale: aNumber ]

{ #category : 'angular dynamics' }
CFPhysics >> angularVelocity [ ^ self body angularVelocity ]


{ #category : 'angular dynamics' }
CFPhysics >> angularVelocity: aNumber [ self body angularVelocity: aNumber ]

{ #category : 'angular dynamics' }
CFPhysics >> angularDamping [ ^ self body angularDamping ]

{ #category : 'angular dynamics' }
CFPhysics >> angularDamping: aNumber [ self body angularDamping: aNumber ]

{ #category : 'angular dynamics' }
CFPhysics >> applyTorque: aNumber [ self body applyTorque: aNumber ]

{ #category : 'mass' }
CFPhysics >> inverseInertia [ ^ self body inverseInertia ]


{ #category : 'sensors' }
CFPhysics >> beSensor [
	self body beSensor
]

{ #category : 'sensors' }
CFPhysics >> beSolid [
	self body beSolid
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
	self body collisionCategoryBits: anInteger
]

{ #category : 'collision filtering' }
CFPhysics >> collisionMaskBits [
	^ self body collisionMaskBits
]

{ #category : 'collision filtering' }
CFPhysics >> collisionMaskBits: anInteger [
	self body collisionMaskBits: anInteger
]

{ #category : 'collision filtering' }
CFPhysics >> collisionGroupIndex [
	^ self body collisionGroupIndex
]

{ #category : 'collision filtering' }
CFPhysics >> collisionGroupIndex: anInteger [
	self body collisionGroupIndex: anInteger
]


{ #category : 'pull interaction' }
CFPhysics >> enablePullInteraction [
	pointerJointHandler enable.
	^ pointerJointHandler
]

{ #category : 'pull interaction' }
CFPhysics >> disablePullInteraction [
	pointerJointHandler disable
]

{ #category : 'pull interaction' }
CFPhysics >> isPullInteractionEnabled [
	^ pointerJointHandler isEnabled
]

{ #category : 'pull interaction' }
CFPhysics >> pointerJointHandler [
	^ pointerJointHandler
]

{ #category : 'spring interaction' }
CFPhysics >> springTo: anotherElement [
	| aWorld otherWorld spring |
	aWorld := self world.
	otherWorld := anotherElement physics world.
	(aWorld notNil and: [ aWorld == otherWorld ])
		ifFalse: [ self error: 'Both elements must belong to the same physics world' ].
	aWorld synchroniseMembership.
	spring := CFPhysicsSpringConstraint
		between: self body
		and: anotherElement physics body.
	^ aWorld addSpringConstraint: spring
]


{ #category : 'spring interaction' }
CFPhysics >> springs [
	| aWorld body |
	aWorld := self world.
	aWorld ifNil: [ ^ #() ].
	aWorld synchroniseMembership.
	body := aWorld bodyStateFor: element.
	body ifNil: [ ^ #() ].
	^ aWorld springsUsingBody: body
]

{ #category : 'spring interaction' }
CFPhysics >> removeSpring: aSpringConstraint [
	| aWorld |
	aWorld := self world.
	aWorld ifNotNil: [ aWorld removeSpringConstraint: aSpringConstraint ]
]

{ #category : 'distance joints' }
CFPhysics >> distanceJointTo: anotherElement [
	| aWorld otherWorld joint |
	aWorld := self world.
	otherWorld := anotherElement physics world.
	(aWorld notNil and: [ aWorld == otherWorld ])
		ifFalse: [ self error: 'Both elements must belong to the same physics world' ].
	aWorld synchroniseMembership.
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
	aWorld synchroniseMembership.
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

{ #category : 'revolute joints' }
CFPhysics >> revoluteJointTo: anotherElement [
	| aWorld otherWorld joint |
	aWorld := self world.
	otherWorld := anotherElement physics world.
	(aWorld notNil and: [ aWorld == otherWorld ])
		ifFalse: [ self error: 'Both elements must belong to the same physics world' ].
	aWorld synchroniseMembership.
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
	aWorld synchroniseMembership.
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
	aWorld synchroniseMembership.
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
	aWorld synchroniseMembership.
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
	aWorld synchroniseMembership.
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
	aWorld synchroniseMembership.
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


{ #category : 'containment interaction' }
CFPhysics >> containWithinWorld [
	| aWorld constraint |
	aWorld := self world.
	aWorld ifNil: [ self error: 'The element does not belong to a physics world' ].
	aWorld synchroniseMembership.
	constraint := CFPhysicsContainmentConstraint on: self body.
	^ aWorld addContainmentConstraint: constraint
]

{ #category : 'containment interaction' }
CFPhysics >> removeContainment: aContainmentConstraint [
	| aWorld |
	aWorld := self world.
	aWorld ifNotNil: [ aWorld removeContainmentConstraint: aContainmentConstraint ]
]

{ #category : 'attraction interaction' }
CFPhysics >> attract: anotherElement [
	| aWorld otherWorld attraction |
	aWorld := self world.
	otherWorld := anotherElement physics world.
	(aWorld notNil and: [ aWorld == otherWorld ])
		ifFalse: [ self error: 'Both elements must belong to the same physics world' ].
	aWorld synchroniseMembership.
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
	aWorld synchroniseMembership.
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
	aWorld synchroniseMembership.
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
	aWorld synchroniseMembership.
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
	aWorld synchroniseMembership.
	^ CFPhysicsLocalAnchor on: self body at: aPoint
]

{ #category : 'anchors' }
CFPhysics >> normalisedAnchorAt: aPoint [
	| aWorld |
	aWorld := self world.
	aWorld ifNil: [ self error: 'The element does not belong to a physics world' ].
	aWorld synchroniseMembership.
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
	aWorld synchroniseMembership.
	^ CFPhysicsNearestGeometryEndpointPair
		between: self body
		and: anotherElement physics body
]

{ #category : 'angular dynamics' }
CFPhysics >> applyAngularImpulse: aNumber [
	self body applyAngularImpulse: aNumber
]

