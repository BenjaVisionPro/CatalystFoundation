"
I represent the kinematic movement policy.

My responsibility is to move a body from explicit velocity or transform changes without force-based acceleration.
"
Class {
	#name : 'CFPhysicsKinematicBodyType',
	#superclass : 'CFPhysicsBodyType',
	#category : 'BVC-Physics-Model',
	#package : 'BVC-Physics-Model'
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
		bodyOrigin: currentTransform bodyOrigin + (aStepState linearVelocity * seconds)
		rotation: currentTransform rotation + (aStepState angularVelocity * seconds)
]


{ #category : 'sleeping' }
CFPhysicsKinematicBodyType >> isAwake [
	^ true
]


{ #category : 'stepping' }
CFPhysicsKinematicBodyType >> advanceBy: seconds gravity: gravityVector [
	body advanceUsingCurrentVelocityBy: seconds
]

{ #category : 'collision' }
CFPhysicsKinematicBodyType >> formsCollisionPairWith: anotherBodyType [
	^ anotherBodyType formsCollisionPairWithKinematicBodyType
]
