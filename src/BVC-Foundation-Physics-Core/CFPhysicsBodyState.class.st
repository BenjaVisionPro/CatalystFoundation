Class {
	#name : 'CFPhysicsBodyState',
	#superclass : 'Object',
	#instVars : [ 'element', 'world', 'position', 'previousPosition', 'rotation', 'previousRotation', 'velocity', 'bodyType', 'sequence', 'shapeState', 'contacts', 'awake', 'sleepTime', 'angularVelocity', 'force', 'torque', 'linearDamping', 'angularDamping', 'gravityScale', 'sleepingAllowed' ],
	#category : 'BVC-Foundation-Physics-Core',
	#package : 'BVC-Foundation-Physics-Core'
}

{ #category : 'instance creation' }
CFPhysicsBodyState class >> element: anElement world: aWorld [
	^ self new
		element: anElement;
		world: aWorld;
		yourself
]

{ #category : 'stepping' }
CFPhysicsBodyState >> advanceBy: seconds gravity: gravityVector [
	(self isMovable and: [ self isAwake ]) ifFalse: [ ^ self ].
	self isDynamic ifTrue: [
		velocity := velocity + (((gravityVector * gravityScale) + (force * self inverseMass)) * seconds).
		angularVelocity := angularVelocity + (torque * self inverseInertia * seconds).
		linearDamping > 0 ifTrue: [ velocity := velocity * (1.0 / (1.0 + (seconds * linearDamping))) ].
		angularDamping > 0 ifTrue: [ angularVelocity := angularVelocity * (1.0 / (1.0 + (seconds * angularDamping))) ] ].
	position := position + (velocity * seconds).
	rotation := rotation + (angularVelocity * seconds).
	force := 0 @ 0.
	torque := 0.0
]


{ #category : 'velocity' }
CFPhysicsBodyState >> addVelocity: aPoint [
	self isDynamic ifTrue: [
		velocity := velocity + aPoint.
		aPoint = (0 @ 0) ifFalse: [ self wake ] ]
]


{ #category : 'contacts' }
CFPhysicsBodyState >> addContact: aContact [
	contacts ifNil: [ contacts := IdentitySet new ].
	contacts add: aContact
]

{ #category : 'contacts' }
CFPhysicsBodyState >> contacts [
	contacts ifNil: [ contacts := IdentitySet new ].
	^ contacts asArray
]

{ #category : 'contacts' }
CFPhysicsBodyState >> removeContact: aContact [
	contacts ifNil: [ ^ self ].
	contacts remove: aContact ifAbsent: [ ]
]

{ #category : 'collision' }
CFPhysicsBodyState >> aabb [
	^ self shapeState aabbAt: position rotation: rotation
]

{ #category : 'body type' }
CFPhysicsBodyState >> beDynamic [
	self setBodyType: #dynamic
]

{ #category : 'body type' }
CFPhysicsBodyState >> beKinematic [
	self setBodyType: #kinematic
]

{ #category : 'body type' }
CFPhysicsBodyState >> beStatic [
	self setBodyType: #static
]

{ #category : 'body type' }
CFPhysicsBodyState >> setBodyType: aSymbol [
	bodyType = aSymbol ifTrue: [ ^ self ].
	self wakeContactNeighbours.
	world ifNotNil: [ world wakeJointsUsingBody: self ].
	bodyType := aSymbol.
	self isStatic
		ifTrue: [
			awake := false.
			velocity := 0 @ 0.
			angularVelocity := 0.0 ]
		ifFalse: [ awake := true ].
	sleepTime := 0.0.
	force := 0 @ 0.
	torque := 0.0
]

{ #category : 'body type' }
CFPhysicsBodyState >> wakeContactNeighbours [
	self contacts do: [ :contact |
		(contact firstBody == self
			ifTrue: [ contact secondBody ]
			ifFalse: [ contact firstBody ]) wake ]
]

{ #category : 'accessing' }
CFPhysicsBodyState >> element [
	^ element
]

{ #category : 'accessing' }
CFPhysicsBodyState >> element: anElement [
	element := anElement.
	shapeState := CFPhysicsShapeState on: anElement
]


{ #category : 'geometry' }
CFPhysicsBodyState >> extent [
	^ self shapeState extent
]

{ #category : 'mass' }
CFPhysicsBodyState >> inverseMass [
	| area mass |
	self isDynamic ifFalse: [ ^ 0.0 ].
	area := self shapeState area.
	mass := area * self shapeState material density.
	^ mass > 0 ifTrue: [ 1.0 / mass ] ifFalse: [ 0.0 ]
]

{ #category : 'material' }
CFPhysicsBodyState >> friction [
	^ self shapeState material friction
]

{ #category : 'material' }
CFPhysicsBodyState >> friction: aNumber [
	self shapeState material friction: aNumber
]

{ #category : 'material' }
CFPhysicsBodyState >> restitution [
	^ self shapeState material restitution
]

{ #category : 'material' }
CFPhysicsBodyState >> restitution: aNumber [
	self shapeState material restitution: aNumber
]

{ #category : 'material' }
CFPhysicsBodyState >> density [
	^ self shapeState material density
]

{ #category : 'material' }
CFPhysicsBodyState >> density: aNumber [
	self shapeState material density: aNumber
]

{ #category : 'initialization' }
CFPhysicsBodyState >> initialize [
	super initialize.
	position := 0 @ 0.
	previousPosition := position.
	rotation := 0.
	previousRotation := rotation.
	velocity := 0 @ 0.
	bodyType := #dynamic.
	awake := true.
	sleepTime := 0.0.
	angularVelocity := 0.0.
	force := 0 @ 0.
	torque := 0.0.
	linearDamping := 0.0.
	angularDamping := 0.0.
	gravityScale := 1.0.
	sleepingAllowed := true.
	contacts := IdentitySet new
]

{ #category : 'body type' }
CFPhysicsBodyState >> isDynamic [
	^ bodyType = #dynamic
]

{ #category : 'body type' }
CFPhysicsBodyState >> isKinematic [
	^ bodyType = #kinematic
]

{ #category : 'body type' }
CFPhysicsBodyState >> isMovable [
	^ self isStatic not
]

{ #category : 'body type' }
CFPhysicsBodyState >> isStatic [
	^ bodyType = #static
]


{ #category : 'stepping' }
CFPhysicsBodyState >> beginStep [
	previousPosition := position.
	previousRotation := rotation
]


{ #category : 'accessing' }
CFPhysicsBodyState >> previousPosition [
	^ previousPosition
]

{ #category : 'accessing' }
CFPhysicsBodyState >> previousRotation [
	^ previousRotation
]


{ #category : 'accessing' }
CFPhysicsBodyState >> position [
	^ position
]

{ #category : 'accessing' }
CFPhysicsBodyState >> position: aPoint [
	previousPosition := aPoint.
	position := aPoint.
	self wake
]





{ #category : 'accessing' }
CFPhysicsBodyState >> rotation [
	^ rotation
]

{ #category : 'accessing' }
CFPhysicsBodyState >> rotation: aNumber [
	previousRotation := aNumber.
	rotation := aNumber.
	self wake
]



{ #category : 'geometry' }
CFPhysicsBodyState >> shapeState [
	shapeState ifNil: [ shapeState := CFPhysicsShapeState on: element ].
	^ shapeState
]

{ #category : 'ordering' }
CFPhysicsBodyState >> sequence [
	^ sequence
]


{ #category : 'ordering' }
CFPhysicsBodyState >> sequence: anInteger [
	sequence := anInteger
]

{ #category : 'collision' }
CFPhysicsBodyState >> translateBy: aPoint [
	position := position + aPoint
]

{ #category : 'presenting' }
CFPhysicsBodyState >> translation: aPoint rotation: aNumber [
	previousPosition := aPoint.
	position := aPoint.
	previousRotation := aNumber.
	rotation := aNumber.
	self wake
]

{ #category : 'accessing' }
CFPhysicsBodyState >> velocity [
	^ velocity
]

{ #category : 'accessing' }
CFPhysicsBodyState >> velocity: aPoint [
	velocity := self isMovable
		ifTrue: [
			aPoint = (0 @ 0) ifFalse: [ self wake ].
			aPoint ]
		ifFalse: [ 0 @ 0 ]
]

{ #category : 'accessing' }
CFPhysicsBodyState >> world [
	^ world
]

{ #category : 'accessing' }
CFPhysicsBodyState >> world: aWorld [
	world := aWorld
]


{ #category : 'sleeping' }
CFPhysicsBodyState >> isAwake [
	^ self isKinematic or: [ self isDynamic and: [ awake ] ]
]

{ #category : 'sleeping' }
CFPhysicsBodyState >> isSleeping [
	^ self isDynamic and: [ sleepingAllowed and: [ awake not ] ]
]

{ #category : 'sleeping' }
CFPhysicsBodyState >> allowsSleeping [
	^ sleepingAllowed
]

{ #category : 'sleeping' }
CFPhysicsBodyState >> allowSleeping [
	sleepingAllowed := true
]

{ #category : 'sleeping' }
CFPhysicsBodyState >> preventSleeping [
	sleepingAllowed := false.
	self wake
]


{ #category : 'sleeping' }
CFPhysicsBodyState >> sleep [
	(self isDynamic and: [ sleepingAllowed ]) ifFalse: [ ^ self ].
	awake := false.
	sleepTime := 0.0.
	velocity := 0 @ 0.
	angularVelocity := 0.0.
	force := 0 @ 0.
	torque := 0.0
]

{ #category : 'sleeping' }
CFPhysicsBodyState >> sleepTime [
	^ sleepTime
]

{ #category : 'sleeping' }
CFPhysicsBodyState >> updateSleepBy: seconds linearThresholdSquared: thresholdSquared angularThresholdSquared: angularThresholdSquared requiredTime: requiredTime [
	(self isDynamic and: [ sleepingAllowed ]) ifFalse: [
		self wake.
		^ self ].
	((velocity x squared + velocity y squared) <= thresholdSquared and: [ angularVelocity squared <= angularThresholdSquared ])
		ifTrue: [
			sleepTime := sleepTime + seconds.
			sleepTime >= requiredTime ifTrue: [ self sleep ] ]
		ifFalse: [
			sleepTime := 0.0.
			awake := true ]
]

{ #category : 'sleeping' }
CFPhysicsBodyState >> wake [
	self isDynamic ifFalse: [ ^ self ].
	awake := true.
	sleepTime := 0.0
]


{ #category : 'linear dynamics' }
CFPhysicsBodyState >> force [
	^ force
]

{ #category : 'linear dynamics' }
CFPhysicsBodyState >> applyForce: aPoint [
	self isDynamic ifFalse: [ ^ self ].
	force := force + aPoint.
	aPoint = (0 @ 0) ifFalse: [ self wake ]
]

{ #category : 'linear dynamics' }
CFPhysicsBodyState >> clearForces [
	force := 0 @ 0.
	torque := 0.0
]

{ #category : 'linear dynamics' }
CFPhysicsBodyState >> linearDamping [
	^ linearDamping
]

{ #category : 'linear dynamics' }
CFPhysicsBodyState >> linearDamping: aNumber [
	linearDamping := aNumber asFloat max: 0.0
]

{ #category : 'linear dynamics' }
CFPhysicsBodyState >> gravityScale [
	^ gravityScale
]

{ #category : 'linear dynamics' }
CFPhysicsBodyState >> gravityScale: aNumber [
	gravityScale := aNumber asFloat
]

{ #category : 'angular dynamics' }
CFPhysicsBodyState >> angularVelocity [
	^ angularVelocity
]

{ #category : 'angular dynamics' }
CFPhysicsBodyState >> angularVelocity: aNumber [
	angularVelocity := self isMovable ifTrue: [ aNumber asFloat ] ifFalse: [ 0.0 ].
	angularVelocity = 0.0 ifFalse: [ self wake ]
]

{ #category : 'angular dynamics' }
CFPhysicsBodyState >> angularDamping [
	^ angularDamping
]

{ #category : 'angular dynamics' }
CFPhysicsBodyState >> angularDamping: aNumber [
	angularDamping := aNumber asFloat max: 0.0
]

{ #category : 'angular dynamics' }
CFPhysicsBodyState >> applyTorque: aNumber [
	self isDynamic ifFalse: [ ^ self ].
	torque := torque + aNumber.
	aNumber = 0 ifFalse: [ self wake ]
]

{ #category : 'angular dynamics' }
CFPhysicsBodyState >> addAngularVelocity: aNumber [
	self isDynamic ifTrue: [
		angularVelocity := angularVelocity + aNumber.
		aNumber = 0 ifFalse: [ self wake ] ]
]

{ #category : 'mass' }
CFPhysicsBodyState >> mass [
	| inverse |
	inverse := self inverseMass.
	^ inverse = 0 ifTrue: [ 0.0 ] ifFalse: [ 1.0 / inverse ]
]

{ #category : 'mass' }
CFPhysicsBodyState >> inverseInertia [
	| mass extent inertia |
	self isDynamic ifFalse: [ ^ 0.0 ].
	mass := self mass.
	mass = 0 ifTrue: [ ^ 0.0 ].
	extent := self shapeState extent.
	inertia := self shapeState isCircle
		ifTrue: [ mass * self shapeState radius squared / 2.0 ]
		ifFalse: [ mass * (extent x squared + extent y squared) / 12.0 ].
	^ inertia > 0 ifTrue: [ 1.0 / inertia ] ifFalse: [ 0.0 ]
]

{ #category : 'geometry' }
CFPhysicsBodyState >> centre [
	^ self shapeState centreAt: position
]

{ #category : 'angular dynamics' }
CFPhysicsBodyState >> velocityAtWorldPoint: aPoint [
	| radiusVector |
	radiusVector := aPoint - self centre.
	^ velocity + ((angularVelocity * radiusVector y negated) @ (angularVelocity * radiusVector x))
]

{ #category : 'angular dynamics' }
CFPhysicsBodyState >> applyImpulse: anImpulse atWorldPoint: aPoint [
	| radiusVector cross |
	self isDynamic ifFalse: [ ^ self ].
	self addVelocity: anImpulse * self inverseMass.
	radiusVector := aPoint - self centre.
	cross := (radiusVector x * anImpulse y) - (radiusVector y * anImpulse x).
	self addAngularVelocity: cross * self inverseInertia
]

{ #category : 'collision' }
CFPhysicsBodyState >> rotateBy: anAngle [
	rotation := rotation + anAngle
]

{ #category : 'stepping' }
CFPhysicsBodyState >> torque [
	^ torque
]

{ #category : 'stepping' }
CFPhysicsBodyState >> commitPosition: aPosition rotation: anAngle velocity: aVelocity angularVelocity: anAngularVelocity [
	position := aPosition.
	rotation := anAngle.
	velocity := self isMovable ifTrue: [ aVelocity ] ifFalse: [ 0 @ 0 ].
	angularVelocity := self isMovable ifTrue: [ anAngularVelocity ] ifFalse: [ 0.0 ].
	force := 0 @ 0.
	torque := 0.0
]

{ #category : 'sleeping' }
CFPhysicsBodyState >> advanceSleepTimeBy: seconds [
	self isDynamic ifTrue: [ sleepTime := sleepTime + seconds ]
]

{ #category : 'sleeping' }
CFPhysicsBodyState >> resetSleepTime [
	sleepTime := 0.0
]


{ #category : 'sensors' }
CFPhysicsBodyState >> beSensor [
	self shapeState beSensor
]

{ #category : 'sensors' }
CFPhysicsBodyState >> beSolid [
	self shapeState beSolid
]

{ #category : 'sensors' }
CFPhysicsBodyState >> isSensor [
	^ self shapeState isSensor
]


{ #category : 'collision filtering' }
CFPhysicsBodyState >> collisionFilter [
	^ self shapeState collisionFilter
]

{ #category : 'collision filtering' }
CFPhysicsBodyState >> collisionCategoryBits [
	^ self shapeState collisionCategoryBits
]

{ #category : 'collision filtering' }
CFPhysicsBodyState >> collisionCategoryBits: anInteger [
	self shapeState collisionCategoryBits: anInteger
]

{ #category : 'collision filtering' }
CFPhysicsBodyState >> collisionMaskBits [
	^ self shapeState collisionMaskBits
]

{ #category : 'collision filtering' }
CFPhysicsBodyState >> collisionMaskBits: anInteger [
	self shapeState collisionMaskBits: anInteger
]

{ #category : 'collision filtering' }
CFPhysicsBodyState >> collisionGroupIndex [
	^ self shapeState collisionGroupIndex
]

{ #category : 'collision filtering' }
CFPhysicsBodyState >> collisionGroupIndex: anInteger [
	self shapeState collisionGroupIndex: anInteger
]

{ #category : 'collision filtering' }
CFPhysicsBodyState >> allowsCollisionWith: anotherBody [
	^ self shapeState allowsCollisionWith: anotherBody shapeState
]

{ #category : 'geometry' }
CFPhysicsBodyState >> worldPointForLocalPoint: aPoint [
	^ position + (self shapeState rotateVector: aPoint by: rotation)
]

{ #category : 'geometry' }
CFPhysicsBodyState >> localPointForNormalisedPoint: aPoint [
	^ (aPoint - (0.5 @ 0.5)) * self extent
]

{ #category : 'geometry' }
CFPhysicsBodyState >> worldPointForNormalisedPoint: aPoint [
	^ self worldPointForLocalPoint: (self localPointForNormalisedPoint: aPoint)
]

{ #category : 'continuous collision' }
CFPhysicsBodyState >> sweep [
	^ CFPhysicsSweep
		from: (CFPhysicsTransform position: previousPosition rotation: previousRotation)
		to: (CFPhysicsTransform position: position rotation: rotation)
]

{ #category : 'collision' }
CFPhysicsBodyState >> sweptAABB [
	^ self shapeState sweptAABBAlong: self sweep
]
