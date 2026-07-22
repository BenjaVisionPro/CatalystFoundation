Class {
	#name : 'CFPhysicsStaticBodyType',
	#superclass : 'CFPhysicsBodyType',
	#category : 'BVC-Foundation-Physics-Core',
	#package : 'BVC-Foundation-Physics-Core'
}

{ #category : 'testing' }
CFPhysicsStaticBodyType >> isMovable [
	^ false
]

{ #category : 'testing' }
CFPhysicsStaticBodyType >> isStatic [
	^ true
]
