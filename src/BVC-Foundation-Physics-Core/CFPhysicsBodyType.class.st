Class {
	#name : 'CFPhysicsBodyType',
	#superclass : 'Object',
	#instVars : [ 'body' ],
	#category : 'BVC-Foundation-Physics-Core',
	#package : 'BVC-Foundation-Physics-Core'
}

{ #category : 'instance creation' }
CFPhysicsBodyType class >> on: aBody [
	^ self new
		body: aBody;
		yourself
]

{ #category : 'accessing' }
CFPhysicsBodyType >> body [
	^ body
]

{ #category : 'accessing' }
CFPhysicsBodyType >> body: aBody [
	body := aBody
]

{ #category : 'testing' }
CFPhysicsBodyType >> isDynamic [
	^ false
]

{ #category : 'testing' }
CFPhysicsBodyType >> isKinematic [
	^ false
]

{ #category : 'testing' }
CFPhysicsBodyType >> isMovable [
	^ true
]

{ #category : 'testing' }
CFPhysicsBodyType >> isStatic [
	^ false
]

{ #category : 'mass' }
CFPhysicsBodyType >> inverseMass [
	^ 0.0
]

{ #category : 'mass' }
CFPhysicsBodyType >> inverseInertia [
	^ 0.0
]

{ #category : 'linear dynamics' }
CFPhysicsBodyType >> applyForce: aPoint [
]

{ #category : 'angular dynamics' }
CFPhysicsBodyType >> applyTorque: aNumber [
]

{ #category : 'angular dynamics' }
CFPhysicsBodyType >> applyImpulse: anImpulse atWorldPoint: aPoint [
]

{ #category : 'velocity' }
CFPhysicsBodyType >> addVelocity: aPoint [
]

{ #category : 'angular dynamics' }
CFPhysicsBodyType >> addAngularVelocity: aNumber [
]


{ #category : 'velocity' }
CFPhysicsBodyType >> velocity: aPoint [
	body stopMotion
]

{ #category : 'angular dynamics' }
CFPhysicsBodyType >> angularVelocity: aNumber [
	body stopMotion
]

{ #category : 'stepping' }
CFPhysicsBodyType >> commitVelocity: aVelocity angularVelocity: anAngularVelocity [
	body stopMotion
]

{ #category : 'integration' }
CFPhysicsBodyType >> integrateVelocityOf: aStepState by: seconds gravity: gravityVector [
]

{ #category : 'integration' }
CFPhysicsBodyType >> integratePositionOf: aStepState by: seconds [
]

{ #category : 'integration' }
CFPhysicsBodyType >> translate: aStepState by: aPoint [
]

{ #category : 'prediction' }
CFPhysicsBodyType >> predictedTransformOf: aStepState after: seconds [
	^ aStepState currentTransform
]


{ #category : 'sleeping' }
CFPhysicsBodyType >> isAwake [
	^ false
]

{ #category : 'sleeping' }
CFPhysicsBodyType >> isSleeping [
	^ false
]

{ #category : 'sleeping' }
CFPhysicsBodyType >> sleep [
]

{ #category : 'sleeping' }
CFPhysicsBodyType >> wake [
]

{ #category : 'sleeping' }
CFPhysicsBodyType >> advanceSleepTimeBy: seconds [
]

{ #category : 'sleeping' }
CFPhysicsBodyType >> updateSleepBy: seconds linearThresholdSquared: thresholdSquared angularThresholdSquared: angularThresholdSquared requiredTime: requiredTime [
]


{ #category : 'stepping' }
CFPhysicsBodyType >> advanceBy: seconds gravity: gravityVector [
]

{ #category : 'body type' }
CFPhysicsBodyType >> enter [
	body markAwake
]

{ #category : 'collision' }
CFPhysicsBodyType >> formsCollisionPairWith: anotherBodyType [
	^ anotherBodyType formsCollisionPairWithStaticBodyType
]

{ #category : 'collision' }
CFPhysicsBodyType >> formsCollisionPairWithDynamicBodyType [
	^ true
]

{ #category : 'collision' }
CFPhysicsBodyType >> formsCollisionPairWithKinematicBodyType [
	^ false
]

{ #category : 'collision' }
CFPhysicsBodyType >> formsCollisionPairWithStaticBodyType [
	^ false
]

{ #category : 'islands' }
CFPhysicsBodyType >> canSeedSolverIsland [
	^ false
]

{ #category : 'islands' }
CFPhysicsBodyType >> propagatesSolverIsland [
	^ false
]

{ #category : 'pointer constraints' }
CFPhysicsBodyType >> acceptsPointerConstraint [
	^ false
]

{ #category : 'pointer constraints' }
CFPhysicsBodyType >> prepareForPointerConstraint: aConstraint by: seconds [
]

{ #category : 'pointer constraints' }
CFPhysicsBodyType >> releaseFromPointerConstraint: aConstraint [
]

{ #category : 'containment' }
CFPhysicsBodyType >> applyContainmentConstraint: aConstraint bounds: aRectangle [
]

{ #category : 'continuous collision' }
CFPhysicsBodyType >> isFastForContinuousCollision: aStepState [
	^ false
]

{ #category : 'continuous collision' }
CFPhysicsBodyType >> requiresContinuousCollisionAgainst: anotherBodyType [
	^ false
]

{ #category : 'continuous collision' }
CFPhysicsBodyType >> isContinuousCollisionCounterpartForDynamicBodyType [
	^ true
]

