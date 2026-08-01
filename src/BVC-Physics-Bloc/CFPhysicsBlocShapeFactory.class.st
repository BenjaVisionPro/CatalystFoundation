"
I convert Bloc-derived shape state into convex polygon geometry used by collision detection.

My responsibility is to keep knowledge of Bloc shape representation at the integration boundary.
"
Class {
	#name : 'CFPhysicsBlocShapeFactory',
	#superclass : 'Object',
	#category : 'BVC-Physics-Bloc',
	#package : 'BVC-Physics-Bloc'
}

{ #category : 'converting' }
CFPhysicsBlocShapeFactory class >> polygonShapeFor: aShapeState [
	aShapeState isCircle ifTrue: [ ^ nil ].
	aShapeState isRoundedRectangle ifTrue: [
		^ CFPhysicsPolygonShape
			rectangleExtent: aShapeState extent
			radius: aShapeState roundedRectangleRadius ].
	aShapeState isPolygon ifTrue: [
		^ CFPhysicsPolygonShape
			vertices: aShapeState localCollisionVertices
			radius: 0.0
			rotationCentre: aShapeState extent / 2.0 ].
	aShapeState isRectangle ifTrue: [
		^ CFPhysicsPolygonShape rectangleExtent: aShapeState extent ].
	^ nil
]
