Class {
	#name : 'CFPhysics',
	#superclass : 'Object',
	#instVars : [ 'element', 'body', 'pullInteractionHandler', 'excludedFromWorld', 'behaviours' ],
	#category : 'BVC-Foundation-Physics-Core',
	#package : 'BVC-Foundation-Physics-Core'
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
CFPhysics >> behaviourWorld [
	^ self existingWorld ifNil: [ self owningWorld ]
]

{ #category : 'behaviours' }
CFPhysics >> addBehaviour: aBehaviour [
	| behaviourWorld |
	(aBehaviour physics notNil and: [ aBehaviour physics ~~ self ]) ifTrue: [
		self error: 'The Physics Behaviour already belongs to another Physics facade' ].
	behaviourWorld := self behaviourWorld.
	behaviourWorld ifNil: [
		self error: 'A Physics Behaviour requires an element belonging to a physics world' ].
	(behaviours identityIncludes: aBehaviour) ifTrue: [ ^ aBehaviour ].
	aBehaviour
		physics: self;
		world: behaviourWorld.
	behaviours add: aBehaviour.
	behaviourWorld addBehaviour: aBehaviour.
	^ aBehaviour
]

{ #category : 'behaviours' }
CFPhysics >> removeBehaviour: aBehaviour [
	behaviours remove: aBehaviour ifAbsent: [ ].
	^ aBehaviour
]

{ #category : 'body type' }
CFPhysics >> beDynamic [
	self requireBodyState beDynamic
]

{ #category : 'body type' }
CFPhysics >> beKinematic [
	self requireBodyState beKinematic
]

{ #category : 'body type' }
CFPhysics >> beStatic [
	self requireBodyState beStatic
]

{ #category : 'worlds' }
CFPhysics >> beWorld [
	| aWorld |
	aWorld := element userData
		at: CFPhysicsWorld
		ifAbsent: [
			aWorld := CFPhysicsWorld on: element.
			element userData at: CFPhysicsWorld put: aWorld.
			element fireEvent: CFPhysicsWorldChangedEvent new.
			aWorld ].
	^ aWorld
]

{ #category : 'worlds' }
CFPhysics >> ceaseBeingWorld [
	| existingWorld |
	existingWorld := self existingWorld.
	existingWorld ifNil: [ ^ self ].
	existingWorld release.
	element userData removeKey: CFPhysicsWorld ifAbsent: [ ].
	element fireEvent: CFPhysicsWorldChangedEvent new.
	^ self
]

{ #category : 'bodies' }
CFPhysics >> bodyState [
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
	pullInteractionHandler := CFPhysicsPullInteractionHandler on: element
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
	^ self requireBodyState density
]

{ #category : 'material' }
CFPhysics >> density: aNumber [
	self requireBodyState density: aNumber
]

{ #category : 'material' }
CFPhysics >> friction [
	^ self requireBodyState friction
]

{ #category : 'material' }
CFPhysics >> friction: aNumber [
	self requireBodyState friction: aNumber
]

{ #category : 'material' }
CFPhysics >> restitution [
	^ self requireBodyState restitution
]

{ #category : 'material' }
CFPhysics >> restitution: aNumber [
	self requireBodyState restitution: aNumber
]

{ #category : 'worlds' }
CFPhysics >> existingWorld [
	^ element userData
		at: CFPhysicsWorld
		ifAbsent: [ nil ]
]

{ #category : 'worlds' }
CFPhysics >> ownedWorld [
	^ self existingWorld
]

{ #category : 'body type' }
CFPhysics >> isDynamic [
	^ self requireBodyState isDynamic
]

{ #category : 'body type' }
CFPhysics >> isKinematic [
	^ self requireBodyState isKinematic
]

{ #category : 'body type' }
CFPhysics >> isStatic [
	^ self requireBodyState isStatic
]

{ #category : 'worlds' }
CFPhysics >> isWorld [
	^ self existingWorld notNil
]

{ #category : 'worlds' }
CFPhysics >> owningWorld [
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
CFPhysics >> position [
	^ self requireBodyState position
]

{ #category : 'bodies' }
CFPhysics >> position: aPoint [
	self requireBodyState position: aPoint
]


{ #category : 'private - bodies' }
CFPhysics >> requireBodyState [
	| owningWorld |
	body ifNotNil: [ ^ body ].
	owningWorld := self owningWorld.
	owningWorld ifNil: [ self error: 'The element does not belong to a physics world' ].
	owningWorld synchroniseMembership.
	body ifNil: [ self error: 'The element is not tracked by its physics world' ].
	^ body
]

{ #category : 'bodies' }
CFPhysics >> rotation [
	^ self requireBodyState rotation
]

{ #category : 'bodies' }
CFPhysics >> rotation: aNumber [
	self requireBodyState rotation: aNumber
]


{ #category : 'worlds' }
CFPhysics >> world [
	^ element userData
		at: CFPhysicsWorld
		ifAbsent: [
			element parent
				ifNil: [ self beWorld ]
				ifNotNil: [ :aParent | aParent physics world ] ]
]

{ #category : 'worlds' }
CFPhysics >> synchroniseWorldMembership [
	| existingWorld owningWorld |
	existingWorld := self existingWorld.
	owningWorld := self owningWorld.
	existingWorld ifNotNil: [ existingWorld synchroniseMembership ].
	owningWorld ifNotNil: [ owningWorld synchroniseMembership ].
	^ owningWorld
]

{ #category : 'bodies' }
CFPhysics >> translation: aPoint rotation: aNumber [
	self requireBodyState translation: aPoint rotation: aNumber
]

{ #category : 'bodies' }
CFPhysics >> velocity [
	^ self requireBodyState velocity
]

{ #category : 'bodies' }
CFPhysics >> velocity: aPoint [
	self requireBodyState velocity: aPoint
]


{ #category : 'sleeping' }
CFPhysics >> isAwake [
	^ self requireBodyState isAwake
]

{ #category : 'sleeping' }
CFPhysics >> isSleeping [
	^ self requireBodyState isSleeping
]

{ #category : 'sleeping' }
CFPhysics >> allowsSleeping [
	^ self requireBodyState allowsSleeping
]

{ #category : 'sleeping' }
CFPhysics >> allowSleeping [
	self requireBodyState allowSleeping
]

{ #category : 'sleeping' }
CFPhysics >> preventSleeping [
	self requireBodyState preventSleeping
]

{ #category : 'sleeping' }
CFPhysics >> sleep [
	self requireBodyState sleep
]

{ #category : 'sleeping' }
CFPhysics >> wake [
	self requireBodyState wake
]


{ #category : 'linear dynamics' }
CFPhysics >> applyForce: aPoint [ self requireBodyState applyForce: aPoint ]

{ #category : 'linear dynamics' }
CFPhysics >> clearForces [ self requireBodyState clearForces ]

{ #category : 'linear dynamics' }
CFPhysics >> linearDamping [ ^ self requireBodyState linearDamping ]

{ #category : 'linear dynamics' }
CFPhysics >> linearDamping: aNumber [ self requireBodyState linearDamping: aNumber ]

{ #category : 'linear dynamics' }
CFPhysics >> gravityScale [ ^ self requireBodyState gravityScale ]

{ #category : 'linear dynamics' }
CFPhysics >> gravityScale: aNumber [ self requireBodyState gravityScale: aNumber ]

{ #category : 'angular dynamics' }
CFPhysics >> angularVelocity [ ^ self requireBodyState angularVelocity ]

{ #category : 'linear dynamics' }
CFPhysics >> applyForce: aPoint [ self requireBodyState applyForce: aPoint ]

{ #category : 'linear dynamics' }
CFPhysics >> clearForces [ self requireBodyState clearForces ]

{ #category : 'linear dynamics' }
CFPhysics >> linearDamping [ ^ self requireBodyState linearDamping ]

{ #category : 'linear dynamics' }
CFPhysics >> linearDamping: aNumber [ self requireBodyState linearDamping: aNumber ]

{ #category : 'linear dynamics' }
CFPhysics >> gravityScale [ ^ self requireBodyState gravityScale ]

{ #category : 'linear dynamics' }
CFPhysics >> gravityScale: aNumber [ self requireBodyState gravityScale: aNumber ]

{ #category : 'angular dynamics' }
CFPhysics >> angularVelocity: aNumber [ self requireBodyState angularVelocity: aNumber ]

{ #category : 'angular dynamics' }
CFPhysics >> angularDamping [ ^ self requireBodyState angularDamping ]

{ #category : 'angular dynamics' }
CFPhysics >> angularDamping: aNumber [ self requireBodyState angularDamping: aNumber ]

{ #category : 'angular dynamics' }
CFPhysics >> applyTorque: aNumber [ self requireBodyState applyTorque: aNumber ]

{ #category : 'mass' }
CFPhysics >> inverseInertia [ ^ self requireBodyState inverseInertia ]


{ #category : 'sensors' }
CFPhysics >> beSensor [
	self requireBodyState beSensor
]

{ #category : 'sensors' }
CFPhysics >> beSolid [
	self requireBodyState beSolid
]

{ #category : 'sensors' }
CFPhysics >> isSensor [
	^ self requireBodyState isSensor
]


{ #category : 'collision filtering' }
CFPhysics >> collisionCategoryBits [
	^ self requireBodyState collisionCategoryBits
]

{ #category : 'collision filtering' }
CFPhysics >> collisionCategoryBits: anInteger [
	self requireBodyState collisionCategoryBits: anInteger
]

{ #category : 'collision filtering' }
CFPhysics >> collisionMaskBits [
	^ self requireBodyState collisionMaskBits
]

{ #category : 'collision filtering' }
CFPhysics >> collisionMaskBits: anInteger [
	self requireBodyState collisionMaskBits: anInteger
]

{ #category : 'collision filtering' }
CFPhysics >> collisionGroupIndex [
	^ self requireBodyState collisionGroupIndex
]

{ #category : 'collision filtering' }
CFPhysics >> collisionGroupIndex: anInteger [
	self requireBodyState collisionGroupIndex: anInteger
]


{ #category : 'pull interaction' }
CFPhysics >> enablePullInteraction [
	pullInteractionHandler enable.
	^ pullInteractionHandler
]

{ #category : 'pull interaction' }
CFPhysics >> disablePullInteraction [
	pullInteractionHandler disable
]

{ #category : 'pull interaction' }
CFPhysics >> isPullInteractionEnabled [
	^ pullInteractionHandler isEnabled
]

{ #category : 'pull interaction' }
CFPhysics >> pullInteractionHandler [
	^ pullInteractionHandler
]

{ #category : 'spring interaction' }
CFPhysics >> springTo: anotherElement [
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
CFPhysics >> springs [
	| aWorld body |
	aWorld := self owningWorld.
	aWorld ifNil: [ ^ #() ].
	aWorld synchroniseMembership.
	body := aWorld bodyStateFor: element.
	body ifNil: [ ^ #() ].
	^ aWorld springsUsingBody: body
]

{ #category : 'spring interaction' }
CFPhysics >> removeSpring: aSpringConstraint [
	| aWorld |
	aWorld := self owningWorld.
	aWorld ifNotNil: [ aWorld removeSpringConstraint: aSpringConstraint ]
]

{ #category : 'distance joints' }
CFPhysics >> distanceJointTo: anotherElement [
	| aWorld otherWorld joint |
	aWorld := self owningWorld.
	otherWorld := anotherElement physics owningWorld.
	(aWorld notNil and: [ aWorld == otherWorld ])
		ifFalse: [ self error: 'Both elements must belong to the same physics world' ].
	aWorld synchroniseMembership.
	joint := CFPhysicsDistanceJoint
		between: self requireBodyState
		and: anotherElement physics requireBodyState.
	^ aWorld addDistanceJoint: joint
]

{ #category : 'distance joints' }
CFPhysics >> distanceJoints [
	| aWorld body |
	aWorld := self owningWorld.
	aWorld ifNil: [ ^ #() ].
	aWorld synchroniseMembership.
	body := aWorld bodyStateFor: element.
	body ifNil: [ ^ #() ].
	^ aWorld distanceJointsUsingBody: body
]

{ #category : 'distance joints' }
CFPhysics >> removeDistanceJoint: aJoint [
	| aWorld |
	aWorld := self owningWorld.
	aWorld ifNotNil: [ aWorld removeDistanceJoint: aJoint ]
]

{ #category : 'revolute joints' }
CFPhysics >> revoluteJointTo: anotherElement [
	| aWorld otherWorld joint |
	aWorld := self owningWorld.
	otherWorld := anotherElement physics owningWorld.
	(aWorld notNil and: [ aWorld == otherWorld ])
		ifFalse: [ self error: 'Both elements must belong to the same physics world' ].
	aWorld synchroniseMembership.
	joint := CFPhysicsRevoluteJoint
		between: self requireBodyState
		and: anotherElement physics requireBodyState.
	^ aWorld addRevoluteJoint: joint
]

{ #category : 'revolute joints' }
CFPhysics >> revoluteJoints [
	| aWorld body |
	aWorld := self owningWorld.
	aWorld ifNil: [ ^ #() ].
	aWorld synchroniseMembership.
	body := aWorld bodyStateFor: element.
	body ifNil: [ ^ #() ].
	^ aWorld revoluteJointsUsingBody: body
]

{ #category : 'revolute joints' }
CFPhysics >> removeRevoluteJoint: aJoint [
	| aWorld |
	aWorld := self owningWorld.
	aWorld ifNotNil: [ aWorld removeRevoluteJoint: aJoint ]
]

{ #category : 'fixed joints' }
CFPhysics >> fixedJointTo: anotherElement [
	| aWorld otherWorld joint |
	aWorld := self owningWorld.
	otherWorld := anotherElement physics owningWorld.
	(aWorld notNil and: [ aWorld == otherWorld ])
		ifFalse: [ self error: 'Both elements must belong to the same physics world' ].
	aWorld synchroniseMembership.
	joint := CFPhysicsFixedJoint
		between: self requireBodyState
		and: anotherElement physics requireBodyState.
	^ aWorld addFixedJoint: joint
]

{ #category : 'fixed joints' }
CFPhysics >> fixedJoints [
	| aWorld body |
	aWorld := self owningWorld.
	aWorld ifNil: [ ^ #() ].
	aWorld synchroniseMembership.
	body := aWorld bodyStateFor: element.
	body ifNil: [ ^ #() ].
	^ aWorld fixedJointsUsingBody: body
]

{ #category : 'fixed joints' }
CFPhysics >> removeFixedJoint: aJoint [
	| aWorld |
	aWorld := self owningWorld.
	aWorld ifNotNil: [ aWorld removeFixedJoint: aJoint ]
]

{ #category : 'rail joints' }
CFPhysics >> railJointTo: anotherElement along: anAxis [
	| aWorld otherWorld joint |
	aWorld := self owningWorld.
	otherWorld := anotherElement physics owningWorld.
	(aWorld notNil and: [ aWorld == otherWorld ])
		ifFalse: [ self error: 'Both elements must belong to the same physics world' ].
	aWorld synchroniseMembership.
	joint := CFPhysicsRailJoint
		between: self requireBodyState
		and: anotherElement physics requireBodyState
		along: anAxis.
	^ aWorld addRailJoint: joint
]

{ #category : 'rail joints' }
CFPhysics >> railJoints [
	| aWorld body |
	aWorld := self owningWorld.
	aWorld ifNil: [ ^ #() ].
	aWorld synchroniseMembership.
	body := aWorld bodyStateFor: element.
	body ifNil: [ ^ #() ].
	^ aWorld railJointsUsingBody: body
]

{ #category : 'rail joints' }
CFPhysics >> removeRailJoint: aJoint [
	| aWorld |
	aWorld := self owningWorld.
	aWorld ifNotNil: [ aWorld removeRailJoint: aJoint ]
]


{ #category : 'containment interaction' }
CFPhysics >> containWithinWorld [
	| aWorld constraint |
	aWorld := self owningWorld.
	aWorld ifNil: [ self error: 'The element does not belong to a physics world' ].
	aWorld synchroniseMembership.
	constraint := CFPhysicsContainmentConstraint on: self requireBodyState.
	^ aWorld addContainmentConstraint: constraint
]

{ #category : 'containment interaction' }
CFPhysics >> removeContainment: aContainmentConstraint [
	| aWorld |
	aWorld := self owningWorld.
	aWorld ifNotNil: [ aWorld removeContainmentConstraint: aContainmentConstraint ]
]

{ #category : 'attraction interaction' }
CFPhysics >> attract: anotherElement [
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
CFPhysics >> attractions [
	| aWorld body |
	aWorld := self owningWorld.
	aWorld ifNil: [ ^ #() ].
	aWorld synchroniseMembership.
	body := aWorld bodyStateFor: element.
	body ifNil: [ ^ #() ].
	^ aWorld attractionsUsingBody: body
]

{ #category : 'attraction interaction' }
CFPhysics >> removeAttraction: anAttractionConstraint [
	| aWorld |
	aWorld := self owningWorld.
	aWorld ifNotNil: [ aWorld removeAttractionConstraint: anAttractionConstraint ]
]



{ #category : 'repulsion interaction' }
CFPhysics >> repel: anotherElement [
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
CFPhysics >> repulsions [
	| aWorld body |
	aWorld := self owningWorld.
	aWorld ifNil: [ ^ #() ].
	aWorld synchroniseMembership.
	body := aWorld bodyStateFor: element.
	body ifNil: [ ^ #() ].
	^ aWorld repulsionsUsingBody: body
]

{ #category : 'repulsion interaction' }
CFPhysics >> removeRepulsion: aRepulsionConstraint [
	| aWorld |
	aWorld := self owningWorld.
	aWorld ifNotNil: [ aWorld removeRepulsionConstraint: aRepulsionConstraint ]
]

{ #category : 'anchors' }
CFPhysics >> localAnchorAt: aPoint [
	| aWorld |
	aWorld := self owningWorld.
	aWorld ifNil: [ self error: 'The element does not belong to a physics world' ].
	aWorld synchroniseMembership.
	^ CFPhysicsLocalAnchor on: self requireBodyState at: aPoint
]

{ #category : 'anchors' }
CFPhysics >> normalisedAnchorAt: aPoint [
	| aWorld |
	aWorld := self owningWorld.
	aWorld ifNil: [ self error: 'The element does not belong to a physics world' ].
	aWorld synchroniseMembership.
	^ CFPhysicsNormalisedAnchor on: self requireBodyState at: aPoint
]


{ #category : 'anchors' }
CFPhysics >> worldAnchorAt: aPoint [
	| aWorld |
	aWorld := self owningWorld.
	aWorld ifNil: [ self error: 'The element does not belong to a physics world' ].
	^ aWorld anchorAt: aPoint
]


{ #category : 'relationship endpoints' }
CFPhysics >> nearestGeometryEndpointsTo: anotherElement [
	| aWorld otherWorld |
	aWorld := self owningWorld.
	otherWorld := anotherElement physics owningWorld.
	(aWorld notNil and: [ aWorld == otherWorld ])
		ifFalse: [ self error: 'Both elements must belong to the same physics world' ].
	aWorld synchroniseMembership.
	^ CFPhysicsNearestGeometryEndpointPair
		between: self requireBodyState
		and: anotherElement physics requireBodyState
]

{ #category : 'angular dynamics' }
CFPhysics >> applyAngularImpulse: aNumber [
	self requireBodyState applyAngularImpulse: aNumber
]

{ #category : 'behaviours' }
CFPhysics >> forceDirected [
	^ self addBehaviour: (CFPhysicsForceDirectedBehaviour physics: self)
]
