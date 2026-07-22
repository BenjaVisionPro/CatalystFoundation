Class {
	#name : 'CFPhysicsDynamicBodyType',
	#superclass : 'CFPhysicsBodyType',
	#category : 'BVC-Foundation-Physics-Core',
	#package : 'BVC-Foundation-Physics-Core'
}

{ #category : 'testing' }
CFPhysicsDynamicBodyType >> isDynamic [
	^ true
]

{ #category : 'mass' }
CFPhysicsDynamicBodyType >> inverseMass [
	^ body calculatedInverseMass
]

{ #category : 'mass' }
CFPhysicsDynamicBodyType >> inverseInertia [
	^ body calculatedInverseInertia
]

{ #category : 'linear dynamics' }
CFPhysicsDynamicBodyType >> applyForce: aPoint [
	body accumulateForce: aPoint
]

{ #category : 'angular dynamics' }
CFPhysicsDynamicBodyType >> applyTorque: aNumber [
	body accumulateTorque: aNumber
]

{ #category : 'angular dynamics' }
CFPhysicsDynamicBodyType >> applyImpulse: anImpulse atWorldPoint: aPoint [
	body accumulateImpulse: anImpulse atWorldPoint: aPoint
]

{ #category : 'velocity' }
CFPhysicsDynamicBodyType >> addVelocity: aPoint [
	body accumulateVelocity: aPoint
]

{ #category : 'angular dynamics' }
CFPhysicsDynamicBodyType >> addAngularVelocity: aNumber [
	body accumulateAngularVelocity: aNumber
]


{ #category : 'velocity' }
CFPhysicsDynamicBodyType >> velocity: aPoint [
	body assignVelocity: aPoint
]

{ #category : 'angular dynamics' }
CFPhysicsDynamicBodyType >> angularVelocity: aNumber [
	body assignAngularVelocity: aNumber
]

{ #category : 'stepping' }
CFPhysicsDynamicBodyType >> commitVelocity: aVelocity angularVelocity: anAngularVelocity [
	body commitVelocity: aVelocity angularVelocity: anAngularVelocity
]


{ #category : 'integration' }
CFPhysicsDynamicBodyType >> integrateVelocityOf: aStepState by: seconds gravity: gravityVector [
	body isAwake ifFalse: [ ^ self ].
	aStepState integrateDynamicVelocityBy: seconds gravity: gravityVector
]

{ #category : 'integration' }
CFPhysicsDynamicBodyType >> integratePositionOf: aStepState by: seconds [
	body isAwake ifFalse: [ ^ self ].
	aStepState integrateCurrentVelocityBy: seconds
]

{ #category : 'integration' }
CFPhysicsDynamicBodyType >> translate: aStepState by: aPoint [
	aStepState accumulateTranslation: aPoint
]

{ #category : 'prediction' }
CFPhysicsDynamicBodyType >> predictedTransformOf: aStepState after: seconds [
	| currentTransform |
	body isAwake ifFalse: [ ^ aStepState currentTransform ].
	currentTransform := aStepState currentTransform.
	^ CFPhysicsTransform
		position: currentTransform position + (aStepState linearVelocity * seconds)
		rotation: currentTransform rotation + (aStepState angularVelocity * seconds)
]


{ #category : 'sleeping' }
CFPhysicsDynamicBodyType >> isAwake [
	^ body awakeState
]

{ #category : 'sleeping' }
CFPhysicsDynamicBodyType >> isSleeping [
	^ body allowsSleeping and: [ body awakeState not ]
]

{ #category : 'sleeping' }
CFPhysicsDynamicBodyType >> sleep [
	body allowsSleeping ifTrue: [ body putToSleep ]
]

{ #category : 'sleeping' }
CFPhysicsDynamicBodyType >> wake [
	body markAwake
]

{ #category : 'sleeping' }
CFPhysicsDynamicBodyType >> advanceSleepTimeBy: seconds [
	body incrementSleepTimeBy: seconds
]

{ #category : 'sleeping' }
CFPhysicsDynamicBodyType >> updateSleepBy: seconds linearThresholdSquared: thresholdSquared angularThresholdSquared: angularThresholdSquared requiredTime: requiredTime [
	body
		updateDynamicSleepBy: seconds
		linearThresholdSquared: thresholdSquared
		angularThresholdSquared: angularThresholdSquared
		requiredTime: requiredTime
]


{ #category : 'stepping' }
CFPhysicsDynamicBodyType >> advanceBy: seconds gravity: gravityVector [
	body advanceDynamicBy: seconds gravity: gravityVector
]

{ #category : 'collision' }
CFPhysicsDynamicBodyType >> formsCollisionPairWith: anotherBodyType [
	^ anotherBodyType formsCollisionPairWithDynamicBodyType
]

{ #category : 'collision' }
CFPhysicsDynamicBodyType >> formsCollisionPairWithKinematicBodyType [
	^ true
]

{ #category : 'collision' }
CFPhysicsDynamicBodyType >> formsCollisionPairWithStaticBodyType [
	^ true
]

{ #category : 'islands' }
CFPhysicsDynamicBodyType >> canSeedSolverIsland [
	^ true
]

{ #category : 'islands' }
CFPhysicsDynamicBodyType >> propagatesSolverIsland [
	^ true
]

{ #category : 'pointer constraints' }
CFPhysicsDynamicBodyType >> acceptsPointerConstraint [
	^ true
]

{ #category : 'pointer constraints' }
CFPhysicsDynamicBodyType >> prepareForPointerConstraint: aConstraint by: seconds [
	aConstraint prepareDynamicBodyBy: seconds
]

{ #category : 'pointer constraints' }
CFPhysicsDynamicBodyType >> releaseFromPointerConstraint: aConstraint [
	aConstraint releaseDynamicBody
]

{ #category : 'containment' }
CFPhysicsDynamicBodyType >> applyContainmentConstraint: aConstraint bounds: aRectangle [
	aConstraint applyToDynamicBodyInBounds: aRectangle
]

{ #category : 'continuous collision' }
CFPhysicsDynamicBodyType >> isFastForContinuousCollision: aStepState [
	body isAwake ifFalse: [ ^ false ].
	body isSensor ifTrue: [ ^ false ].
	^ aStepState maximumPointMotion > (0.5 * body shapeState minimumExtent)
]

{ #category : 'continuous collision' }
CFPhysicsDynamicBodyType >> requiresContinuousCollisionAgainst: anotherBodyType [
	^ anotherBodyType isContinuousCollisionCounterpartForDynamicBodyType
]

{ #category : 'continuous collision' }
CFPhysicsDynamicBodyType >> isContinuousCollisionCounterpartForDynamicBodyType [
	^ false
]

