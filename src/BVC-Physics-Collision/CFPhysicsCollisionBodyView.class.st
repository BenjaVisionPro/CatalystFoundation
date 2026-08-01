"
I adapt a shape state and transform to the body protocol required by collision algorithms.

My responsibility is to let transform-based collision queries reuse body-oriented narrow-phase code without creating a simulation body.
"
Class {
	#name : 'CFPhysicsCollisionBodyView',
	#superclass : 'Object',
	#instVars : [ 'shapeState', 'transform' ],
	#category : 'BVC-Physics-Collision',
	#package : 'BVC-Physics-Collision'
}

{ #category : 'instance creation' }
CFPhysicsCollisionBodyView class >> shapeState: aShapeState transform: aTransform [
	^ self new
		shapeState: aShapeState;
		transform: aTransform;
		yourself
]

{ #category : 'geometry' }
CFPhysicsCollisionBodyView >> aabb [
	^ shapeState aabbAtBodyOrigin: self worldBodyOrigin rotation: self rotation
]

{ #category : 'geometry - coordinates' }
CFPhysicsCollisionBodyView >> worldBodyOrigin [
	^ transform bodyOrigin
]

{ #category : 'accessing' }
CFPhysicsCollisionBodyView >> rotation [
	^ transform rotation
]

{ #category : 'accessing' }
CFPhysicsCollisionBodyView >> shapeState [
	^ shapeState
]

{ #category : 'accessing' }
CFPhysicsCollisionBodyView >> shapeState: aShapeState [
	shapeState := aShapeState
]

{ #category : 'accessing' }
CFPhysicsCollisionBodyView >> transform: aTransform [
	transform := aTransform
]
