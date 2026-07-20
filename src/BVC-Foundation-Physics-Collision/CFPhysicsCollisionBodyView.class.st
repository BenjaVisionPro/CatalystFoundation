Class {
	#name : 'CFPhysicsCollisionBodyView',
	#superclass : 'Object',
	#instVars : [ 'shapeState', 'transform' ],
	#category : 'BVC-Foundation-Physics-Collision',
	#package : 'BVC-Foundation-Physics-Collision'
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
	^ shapeState aabbAt: self position rotation: self rotation
]

{ #category : 'accessing' }
CFPhysicsCollisionBodyView >> position [
	^ transform position
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
