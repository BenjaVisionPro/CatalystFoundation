Class {
	#name : 'CFPhysicsStaticBodyType',
	#superclass : 'CFPhysicsBodyType',
	#category : 'BVC-Physics-Model',
	#package : 'BVC-Physics-Model'
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
