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
