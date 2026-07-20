Class {
	#name : 'CFPhysicsTransform',
	#superclass : 'Object',
	#instVars : [ 'position', 'rotation' ],
	#category : 'BVC-Foundation-Physics-Core',
	#package : 'BVC-Foundation-Physics-Core'
}

{ #category : 'instance creation' }
CFPhysicsTransform class >> position: aPoint rotation: aNumber [
	^ self new
		position: aPoint;
		rotation: aNumber;
		yourself
]

{ #category : 'interpolating' }
CFPhysicsTransform >> interpolatedTo: anotherTransform at: alpha [
	^ self class
		position: position + ((anotherTransform position - position) * alpha)
		rotation: rotation + ((anotherTransform rotation - rotation) * alpha)
]

{ #category : 'accessing' }
CFPhysicsTransform >> position [
	^ position
]

{ #category : 'accessing' }
CFPhysicsTransform >> position: aPoint [
	position := aPoint
]

{ #category : 'accessing' }
CFPhysicsTransform >> rotation [
	^ rotation
]

{ #category : 'accessing' }
CFPhysicsTransform >> rotation: aNumber [
	rotation := aNumber
]
