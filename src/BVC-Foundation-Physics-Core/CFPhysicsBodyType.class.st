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
