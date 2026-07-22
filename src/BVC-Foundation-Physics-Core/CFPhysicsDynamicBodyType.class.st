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
