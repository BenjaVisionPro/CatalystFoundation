"
I represent a body's origin and rotation.

My responsibility is to carry rigid transforms consistently through capture, collision, solving and presentation.

The body origin is the body's rotation centre. Rotation is an unwrapped angle in radians; interpolation must preserve the solved angular displacement rather than choosing an alternative wrapped path.
"
Class {
	#name : 'CFPhysicsTransform',
	#superclass : 'Object',
	#instVars : [ 'bodyOrigin', 'rotation' ],
	#category : 'BVC-Physics-Model',
	#package : 'BVC-Physics-Model'
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
