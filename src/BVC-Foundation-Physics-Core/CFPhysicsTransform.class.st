Class {
	#name : 'CFPhysicsTransform',
	#superclass : 'Object',
	#instVars : [ 'bodyOrigin', 'rotation' ],
	#category : 'BVC-Foundation-Physics-Core',
	#package : 'BVC-Foundation-Physics-Core'
}

{ #category : 'instance creation' }
CFPhysicsTransform class >> bodyOrigin: aPoint rotation: aNumber [
	^ self new
		bodyOrigin: aPoint;
		rotation: aNumber;
		yourself
]

{ #category : 'interpolating' }
CFPhysicsTransform >> interpolatedTo: anotherTransform at: alpha [
	^ self class
		bodyOrigin: bodyOrigin + ((anotherTransform bodyOrigin - bodyOrigin) * alpha)
		rotation: rotation + ((anotherTransform rotation - rotation) * alpha)
]

{ #category : 'accessing' }
CFPhysicsTransform >> bodyOrigin [
	^ bodyOrigin
]

{ #category : 'accessing' }
CFPhysicsTransform >> bodyOrigin: aPoint [
	bodyOrigin := aPoint
]

{ #category : 'accessing' }
CFPhysicsTransform >> rotation [
	^ rotation
]

{ #category : 'accessing' }
CFPhysicsTransform >> rotation: aNumber [
	rotation := aNumber
]
