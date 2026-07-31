Class {
	#name : 'CFPhysicsStaticBodyType',
	#superclass : 'CFPhysicsBodyType',
	#category : 'BVC-Physics-Core',
	#package : 'BVC-Physics-Core'
}

{ #category : 'testing' }
CFPhysicsStaticBodyType >> isMovable [
	^ false
]

{ #category : 'testing' }
CFPhysicsStaticBodyType >> isStatic [
	^ true
]


{ #category : 'body type' }
CFPhysicsStaticBodyType >> enter [
	body markInactive.
	body stopMotion
]
