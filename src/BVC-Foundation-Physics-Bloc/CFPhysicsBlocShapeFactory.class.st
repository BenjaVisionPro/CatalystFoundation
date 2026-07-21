Class {
	#name : 'CFPhysicsBlocShapeFactory',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Physics-Bloc',
	#package : 'BVC-Foundation-Physics-Bloc'
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
