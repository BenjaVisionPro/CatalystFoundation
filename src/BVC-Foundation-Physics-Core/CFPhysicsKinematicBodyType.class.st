Class {
	#name : 'CFPhysicsKinematicBodyType',
	#superclass : 'CFPhysicsBodyType',
	#category : 'BVC-Foundation-Physics-Core',
	#package : 'BVC-Foundation-Physics-Core'
}

{ #category : 'testing' }
CFPhysicsKinematicBodyType >> isKinematic [
	^ true
]


{ #category : 'velocity' }
CFPhysicsKinematicBodyType >> velocity: aPoint [
	body assignVelocity: aPoint
]

{ #category : 'angular dynamics' }
CFPhysicsKinematicBodyType >> angularVelocity: aNumber [
	body assignAngularVelocity: aNumber
]

{ #category : 'stepping' }
CFPhysicsKinematicBodyType >> commitVelocity: aVelocity angularVelocity: anAngularVelocity [
	body commitVelocity: aVelocity angularVelocity: anAngularVelocity
]


{ #category : 'integration' }
CFPhysicsKinematicBodyType >> integratePositionOf: aStepState by: seconds [
	aStepState integrateCurrentVelocityBy: seconds
]

{ #category : 'prediction' }
CFPhysicsKinematicBodyType >> predictedTransformOf: aStepState after: seconds [
	| currentTransform |
	currentTransform := aStepState currentTransform.
	^ CFPhysicsTransform
		position: currentTransform position + (aStepState linearVelocity * seconds)
		rotation: currentTransform rotation + (aStepState angularVelocity * seconds)
]


{ #category : 'sleeping' }
CFPhysicsKinematicBodyType >> isAwake [
	^ true
]
