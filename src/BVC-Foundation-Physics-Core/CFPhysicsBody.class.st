Class {
	#name : 'CFPhysicsBody',
	#superclass : 'Object',
	#instVars : [ 'element', 'world', 'position', 'previousPosition', 'rotation', 'previousRotation', 'velocity', 'bodyType', 'sequence', 'shapeState', 'contacts', 'awake', 'sleepTime', 'angularVelocity', 'force', 'torque', 'linearDamping', 'angularDamping', 'gravityScale', 'sleepingAllowed' ],
	#category : 'BVC-Foundation-Physics-Core',
	#package : 'BVC-Foundation-Physics-Core'
}

{ #category : 'instance creation' }
CFPhysicsBody class >> element: anElement world: aWorld [
	^ self new
		element: anElement;
		world: aWorld;
		yourself
]

{ #category : 'stepping' }
CFPhysicsBody >> advanceBy: seconds gravity: gravityVector [
	bodyType advanceBy: seconds gravity: gravityVector
]

{ #category : 'private - stepping' }
CFPhysicsBody >> advanceDynamicBy: seconds gravity: gravityVector [
	self isAwake ifFalse: [ ^ self ].
	velocity := velocity + (((gravityVector * gravityScale) + (force * self calculatedInverseMass)) * seconds).
	angularVelocity := angularVelocity + (torque * self calculatedInverseInertia * seconds).
	linearDamping > 0 ifTrue: [ velocity := velocity * (1.0 / (1.0 + (seconds * linearDamping))) ].
	angularDamping > 0 ifTrue: [ angularVelocity := angularVelocity * (1.0 / (1.0 + (seconds * angularDamping))) ].
	self advanceUsingCurrentVelocityBy: seconds
]

{ #category : 'private - stepping' }
CFPhysicsBody >> advanceUsingCurrentVelocityBy: seconds [
	position := position + (velocity * seconds).
	rotation := rotation + (angularVelocity * seconds).
	self clearForces
]


{ #category : 'velocity' }
CFPhysicsBody >> addVelocity: aPoint [
	bodyType addVelocity: aPoint.
	^ self
]


{ #category : 'contacts' }
CFPhysicsBody >> addContact: aContact [
	contacts ifNil: [ contacts := IdentitySet new ].
	contacts add: aContact
]

{ #category : 'contacts' }
CFPhysicsBody >> contacts [
	contacts ifNil: [ contacts := IdentitySet new ].
	^ contacts asArray
]

{ #category : 'contacts' }
CFPhysicsBody >> removeContact: aContact [
	contacts ifNil: [ ^ self ].
	contacts remove: aContact ifAbsent: [ ]
]

{ #category : 'collision' }
CFPhysicsBody >> aabb [
	^ self shapeState aabbAt: position rotation: rotation
]

{ #category : 'body type' }
CFPhysicsBody >> beDynamic [
	self setBodyType: (CFPhysicsDynamicBodyType on: self)
]

{ #category : 'body type' }
CFPhysicsBody >> beKinematic [
	self setBodyType: (CFPhysicsKinematicBodyType on: self)
]

{ #category : 'body type' }
CFPhysicsBody >> beStatic [
	self setBodyType: (CFPhysicsStaticBodyType on: self)
]

{ #category : 'body type' }
CFPhysicsBody >> setBodyType: aBodyType [
	bodyType class = aBodyType class ifTrue: [ ^ self ].
	self wakeContactNeighbours.
	world ifNotNil: [ world wakeJointsUsingBody: self ].
	bodyType := aBodyType.
	self resetSleepTime.
	self clearForces.
	bodyType enter
]

{ #category : 'body type' }
CFPhysicsBody >> wakeContactNeighbours [
	self contacts do: [ :contact |
		(contact firstBody == self
			ifTrue: [ contact secondBody ]
			ifFalse: [ contact firstBody ]) wake ]
]

{ #category : 'accessing' }
CFPhysicsBody >> element [
	^ element
]

{ #category : 'accessing' }
CFPhysicsBody >> element: anElement [
	element := anElement.
	shapeState := CFPhysicsShapeState on: anElement
]


{ #category : 'geometry' }
CFPhysicsBody >> extent [
	^ self shapeState extent
]

{ #category : 'mass' }
CFPhysicsBody >> inverseMass [
	^ bodyType inverseMass
]

{ #category : 'mass' }
CFPhysicsBody >> calculatedInverseMass [
	| area mass |
	area := self shapeState area.
	mass := area * self shapeState material density.
	^ mass > 0 ifTrue: [ 1.0 / mass ] ifFalse: [ 0.0 ]
]

{ #category : 'material' }
CFPhysicsBody >> friction [
	^ self shapeState material friction
]

{ #category : 'material' }
CFPhysicsBody >> friction: aNumber [
	self shapeState material friction: aNumber
]

{ #category : 'material' }
CFPhysicsBody >> restitution [
	^ self shapeState material restitution
]

{ #category : 'material' }
CFPhysicsBody >> restitution: aNumber [
	self shapeState material restitution: aNumber
]

{ #category : 'material' }
CFPhysicsBody >> density [
	^ self shapeState material density
]

{ #category : 'material' }
CFPhysicsBody >> density: aNumber [
	self shapeState material density: aNumber
]

{ #category : 'initialization' }
CFPhysicsBody >> initialize [
	super initialize.
	position := 0 @ 0.
	previousPosition := position.
	rotation := 0.
	previousRotation := rotation.
	velocity := 0 @ 0.
	bodyType := CFPhysicsDynamicBodyType on: self.
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
CFPhysicsBody >> bodyType [
	^ bodyType
]

{ #category : 'body type' }
CFPhysicsBody >> isDynamic [
	^ bodyType isDynamic
]

{ #category : 'body type' }
CFPhysicsBody >> isKinematic [
	^ bodyType isKinematic
]

{ #category : 'body type' }
CFPhysicsBody >> isMovable [
	^ bodyType isMovable
]

{ #category : 'body type' }
CFPhysicsBody >> isStatic [
	^ bodyType isStatic
]


{ #category : 'stepping' }
CFPhysicsBody >> beginStep [
	previousPosition := position.
	previousRotation := rotation
]


{ #category : 'accessing' }
CFPhysicsBody >> previousPosition [
	^ previousPosition
]

{ #category : 'accessing' }
CFPhysicsBody >> previousRotation [
	^ previousRotation
]


{ #category : 'accessing' }
CFPhysicsBody >> position [
	^ position
]

{ #category : 'accessing' }
CFPhysicsBody >> position: aPoint [
	previousPosition := aPoint.
	position := aPoint.
	self wake
]





{ #category : 'accessing' }
CFPhysicsBody >> rotation [
	^ rotation
]

{ #category : 'accessing' }
CFPhysicsBody >> rotation: aNumber [
	previousRotation := aNumber.
	rotation := aNumber.
	self wake
]



{ #category : 'geometry' }
CFPhysicsBody >> shapeState [
	shapeState ifNil: [ shapeState := CFPhysicsShapeState on: element ].
	^ shapeState
]

{ #category : 'ordering' }
CFPhysicsBody >> sequence [
	^ sequence
]


{ #category : 'ordering' }
CFPhysicsBody >> sequence: anInteger [
	sequence := anInteger
]

{ #category : 'collision' }
CFPhysicsBody >> translateBy: aPoint [
	position := position + aPoint
]

{ #category : 'presenting' }
CFPhysicsBody >> translation: aPoint rotation: aNumber [
	previousPosition := aPoint.
	position := aPoint.
	previousRotation := aNumber.
	rotation := aNumber.
	self wake
]

{ #category : 'accessing' }
CFPhysicsBody >> velocity [
	^ velocity
]

{ #category : 'accessing' }
CFPhysicsBody >> velocity: aPoint [
	bodyType velocity: aPoint.
	^ self
]

{ #category : 'velocity' }
CFPhysicsBody >> assignVelocity: aPoint [
	velocity := aPoint.
	aPoint = (0 @ 0) ifFalse: [ self wake ]
]

{ #category : 'accessing' }
CFPhysicsBody >> world [
	^ world
]

{ #category : 'accessing' }
CFPhysicsBody >> world: aWorld [
	world := aWorld
]


{ #category : 'sleeping' }
CFPhysicsBody >> isAwake [
	^ bodyType isAwake
]

{ #category : 'sleeping' }
CFPhysicsBody >> isSleeping [
	^ bodyType isSleeping
]

{ #category : 'sleeping' }
CFPhysicsBody >> allowsSleeping [
	^ sleepingAllowed
]

{ #category : 'sleeping' }
CFPhysicsBody >> allowSleeping [
	sleepingAllowed := true
]

{ #category : 'sleeping' }
CFPhysicsBody >> preventSleeping [
	sleepingAllowed := false.
	self wake
]


{ #category : 'sleeping' }
CFPhysicsBody >> sleep [
	bodyType sleep
]

{ #category : 'sleeping' }
CFPhysicsBody >> sleepTime [
	^ sleepTime
]

{ #category : 'sleeping' }
CFPhysicsBody >> updateSleepBy: seconds linearThresholdSquared: thresholdSquared angularThresholdSquared: angularThresholdSquared requiredTime: requiredTime [
	bodyType
		updateSleepBy: seconds
		linearThresholdSquared: thresholdSquared
		angularThresholdSquared: angularThresholdSquared
		requiredTime: requiredTime
]

{ #category : 'sleeping' }
CFPhysicsBody >> wake [
	bodyType wake
]


{ #category : 'linear dynamics' }
CFPhysicsBody >> force [
	^ force
]

{ #category : 'linear dynamics' }
CFPhysicsBody >> applyForce: aPoint [
	bodyType applyForce: aPoint.
	^ self
]

{ #category : 'linear dynamics' }
CFPhysicsBody >> accumulateForce: aPoint [
	force := force + aPoint.
	aPoint = (0 @ 0) ifFalse: [ self wake ]
]

{ #category : 'velocity' }
CFPhysicsBody >> accumulateVelocity: aPoint [
	velocity := velocity + aPoint.
	aPoint = (0 @ 0) ifFalse: [ self wake ]
]

{ #category : 'linear dynamics' }
CFPhysicsBody >> clearForces [
	force := 0 @ 0.
	torque := 0.0
]

{ #category : 'linear dynamics' }
CFPhysicsBody >> linearDamping [
	^ linearDamping
]

{ #category : 'linear dynamics' }
CFPhysicsBody >> linearDamping: aNumber [
	linearDamping := aNumber asFloat max: 0.0
]

{ #category : 'linear dynamics' }
CFPhysicsBody >> gravityScale [
	^ gravityScale
]

{ #category : 'linear dynamics' }
CFPhysicsBody >> gravityScale: aNumber [
	gravityScale := aNumber asFloat
]

{ #category : 'angular dynamics' }
CFPhysicsBody >> angularVelocity [
	^ angularVelocity
]

{ #category : 'angular dynamics' }
CFPhysicsBody >> angularVelocity: aNumber [
	bodyType angularVelocity: aNumber.
	^ self
]

{ #category : 'angular dynamics' }
CFPhysicsBody >> assignAngularVelocity: aNumber [
	angularVelocity := aNumber asFloat.
	angularVelocity = 0.0 ifFalse: [ self wake ]
]

{ #category : 'angular dynamics' }
CFPhysicsBody >> angularDamping [
	^ angularDamping
]

{ #category : 'angular dynamics' }
CFPhysicsBody >> angularDamping: aNumber [
	angularDamping := aNumber asFloat max: 0.0
]

{ #category : 'angular dynamics' }
CFPhysicsBody >> applyTorque: aNumber [
	bodyType applyTorque: aNumber.
	^ self
]

{ #category : 'angular dynamics' }
CFPhysicsBody >> accumulateTorque: aNumber [
	torque := torque + aNumber.
	aNumber = 0 ifFalse: [ self wake ]
]

{ #category : 'angular dynamics' }
CFPhysicsBody >> addAngularVelocity: aNumber [
	bodyType addAngularVelocity: aNumber.
	^ self
]

{ #category : 'angular dynamics' }
CFPhysicsBody >> accumulateAngularVelocity: aNumber [
	angularVelocity := angularVelocity + aNumber.
	aNumber = 0 ifFalse: [ self wake ]
]

{ #category : 'mass' }
CFPhysicsBody >> mass [
	| inverse |
	inverse := self inverseMass.
	^ inverse = 0 ifTrue: [ 0.0 ] ifFalse: [ 1.0 / inverse ]
]

{ #category : 'mass' }
CFPhysicsBody >> inverseInertia [
	^ bodyType inverseInertia
]

{ #category : 'mass' }
CFPhysicsBody >> calculatedInverseInertia [
	| mass extent inertia |
	mass := self mass.
	mass = 0 ifTrue: [ ^ 0.0 ].
	extent := self shapeState extent.
	inertia := self shapeState isCircle
		ifTrue: [ mass * self shapeState radius squared / 2.0 ]
		ifFalse: [ mass * (extent x squared + extent y squared) / 12.0 ].
	^ inertia > 0 ifTrue: [ 1.0 / inertia ] ifFalse: [ 0.0 ]
]

{ #category : 'geometry' }
CFPhysicsBody >> centre [
	^ self shapeState centreAt: position
]

{ #category : 'angular dynamics' }
CFPhysicsBody >> velocityAtWorldPoint: aPoint [
	| radiusVector |
	radiusVector := aPoint - self centre.
	^ velocity + ((angularVelocity * radiusVector y negated) @ (angularVelocity * radiusVector x))
]

{ #category : 'angular dynamics' }
CFPhysicsBody >> applyImpulse: anImpulse atWorldPoint: aPoint [
	bodyType applyImpulse: anImpulse atWorldPoint: aPoint.
	^ self
]

{ #category : 'angular dynamics' }
CFPhysicsBody >> accumulateImpulse: anImpulse atWorldPoint: aPoint [
	| radiusVector cross |
	self accumulateVelocity: anImpulse * self calculatedInverseMass.
	radiusVector := aPoint - self centre.
	cross := (radiusVector x * anImpulse y) - (radiusVector y * anImpulse x).
	self accumulateAngularVelocity: cross * self calculatedInverseInertia
]

{ #category : 'collision' }
CFPhysicsBody >> rotateBy: anAngle [
	rotation := rotation + anAngle
]

{ #category : 'stepping' }
CFPhysicsBody >> torque [
	^ torque
]

{ #category : 'stepping' }
CFPhysicsBody >> commitPosition: aPosition rotation: anAngle velocity: aVelocity angularVelocity: anAngularVelocity [
	position := aPosition.
	rotation := anAngle.
	bodyType commitVelocity: aVelocity angularVelocity: anAngularVelocity.
	force := 0 @ 0.
	torque := 0.0
]

{ #category : 'stepping' }
CFPhysicsBody >> commitVelocity: aVelocity angularVelocity: anAngularVelocity [
	velocity := aVelocity.
	angularVelocity := anAngularVelocity
]

{ #category : 'stepping' }
CFPhysicsBody >> stopMotion [
	velocity := 0 @ 0.
	angularVelocity := 0.0
]

{ #category : 'sleeping' }
CFPhysicsBody >> advanceSleepTimeBy: seconds [
	bodyType advanceSleepTimeBy: seconds
]

{ #category : 'sleeping' }
CFPhysicsBody >> resetSleepTime [
	sleepTime := 0.0
]


{ #category : 'private - sleeping' }
CFPhysicsBody >> awakeState [
	^ awake
]

{ #category : 'private - sleeping' }
CFPhysicsBody >> markAwake [
	awake := true.
	sleepTime := 0.0
]

{ #category : 'private - sleeping' }
CFPhysicsBody >> markInactive [
	awake := false.
	sleepTime := 0.0
]

{ #category : 'private - sleeping' }
CFPhysicsBody >> putToSleep [
	awake := false.
	sleepTime := 0.0.
	velocity := 0 @ 0.
	angularVelocity := 0.0.
	force := 0 @ 0.
	torque := 0.0
]

{ #category : 'private - sleeping' }
CFPhysicsBody >> incrementSleepTimeBy: seconds [
	sleepTime := sleepTime + seconds
]

{ #category : 'private - sleeping' }
CFPhysicsBody >> updateDynamicSleepBy: seconds linearThresholdSquared: thresholdSquared angularThresholdSquared: angularThresholdSquared requiredTime: requiredTime [
	sleepingAllowed ifFalse: [
		self markAwake.
		^ self ].
	((velocity x squared + velocity y squared) <= thresholdSquared and: [ angularVelocity squared <= angularThresholdSquared ])
		ifTrue: [
			self incrementSleepTimeBy: seconds.
			sleepTime >= requiredTime ifTrue: [ self putToSleep ] ]
		ifFalse: [ self markAwake ]
]


{ #category : 'sensors' }
CFPhysicsBody >> beSensor [
	self shapeState beSensor
]

{ #category : 'sensors' }
CFPhysicsBody >> beSolid [
	self shapeState beSolid
]

{ #category : 'sensors' }
CFPhysicsBody >> isSensor [
	^ self shapeState isSensor
]


{ #category : 'collision filtering' }
CFPhysicsBody >> collisionFilter [
	^ self shapeState collisionFilter
]

{ #category : 'collision filtering' }
CFPhysicsBody >> collisionCategoryBits [
	^ self shapeState collisionCategoryBits
]

{ #category : 'collision filtering' }
CFPhysicsBody >> collisionCategoryBits: anInteger [
	self shapeState collisionCategoryBits: anInteger
]

{ #category : 'collision filtering' }
CFPhysicsBody >> collisionMaskBits [
	^ self shapeState collisionMaskBits
]

{ #category : 'collision filtering' }
CFPhysicsBody >> collisionMaskBits: anInteger [
	self shapeState collisionMaskBits: anInteger
]

{ #category : 'collision filtering' }
CFPhysicsBody >> collisionGroupIndex [
	^ self shapeState collisionGroupIndex
]

{ #category : 'collision filtering' }
CFPhysicsBody >> collisionGroupIndex: anInteger [
	self shapeState collisionGroupIndex: anInteger
]

{ #category : 'collision filtering' }
CFPhysicsBody >> allowsCollisionWith: anotherBody [
	^ self shapeState allowsCollisionWith: anotherBody shapeState
]

{ #category : 'geometry' }
CFPhysicsBody >> worldPointForLocalPoint: aPoint [
	^ position + (self shapeState rotateVector: aPoint by: rotation)
]

{ #category : 'geometry' }
CFPhysicsBody >> localPointForNormalisedPoint: aPoint [
	^ (aPoint - (0.5 @ 0.5)) * self extent
]

{ #category : 'geometry' }
CFPhysicsBody >> worldPointForNormalisedPoint: aPoint [
	^ self worldPointForLocalPoint: (self localPointForNormalisedPoint: aPoint)
]

{ #category : 'continuous collision' }
CFPhysicsBody >> sweep [
	^ CFPhysicsSweep
		from: (CFPhysicsTransform position: previousPosition rotation: previousRotation)
		to: (CFPhysicsTransform position: position rotation: rotation)
]

{ #category : 'collision' }
CFPhysicsBody >> sweptAABB [
	^ self shapeState sweptAABBAlong: self sweep
]

{ #category : 'collision' }
CFPhysicsBody >> formsCollisionPairWith: anotherBody [
	^ bodyType formsCollisionPairWith: anotherBody bodyType
]

{ #category : 'islands' }
CFPhysicsBody >> canSeedSolverIsland [
	^ bodyType canSeedSolverIsland
]

{ #category : 'islands' }
CFPhysicsBody >> propagatesSolverIsland [
	^ bodyType propagatesSolverIsland
]

{ #category : 'pointer constraints' }
CFPhysicsBody >> acceptsPointerConstraint [
	^ bodyType acceptsPointerConstraint
]

{ #category : 'pointer constraints' }
CFPhysicsBody >> prepareForPointerConstraint: aConstraint by: seconds [
	bodyType prepareForPointerConstraint: aConstraint by: seconds
]

{ #category : 'pointer constraints' }
CFPhysicsBody >> releaseFromPointerConstraint: aConstraint [
	bodyType releaseFromPointerConstraint: aConstraint
]

{ #category : 'containment' }
CFPhysicsBody >> applyContainmentConstraint: aConstraint bounds: aRectangle [
	bodyType applyContainmentConstraint: aConstraint bounds: aRectangle
]

{ #category : 'continuous collision' }
CFPhysicsBody >> requiresContinuousCollisionAgainst: anotherBody [
	^ bodyType requiresContinuousCollisionAgainst: anotherBody bodyType
]

