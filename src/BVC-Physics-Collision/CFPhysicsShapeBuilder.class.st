"
I build runtime collision shapes from immutable captured Physics geometry.
"
Class {
	#name : 'CFPhysicsShapeBuilder',
	#superclass : 'Object',
	#category : 'BVC-Physics-Collision',
	#package : 'BVC-Physics-Collision'
}

{ #category : 'building' }
CFPhysicsShapeBuilder class >> polygonShapeFor: aShapeState [
	| geometry |
	geometry := aShapeState capturedCollisionGeometry
		ifNil: [ aShapeState uncapturedCollisionGeometry ].
	geometry isCircle ifTrue: [ ^ nil ].
	^ CFPhysicsPolygonShape
		vertices: geometry vertices
		radius: geometry radius
		rotationCentre: geometry rotationCentre
]
