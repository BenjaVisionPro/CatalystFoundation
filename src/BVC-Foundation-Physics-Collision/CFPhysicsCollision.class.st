Class {
	#name : 'CFPhysicsCollision',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Physics-Collision',
	#package : 'BVC-Foundation-Physics-Collision'
}

{ #category : 'collision' }
CFPhysicsCollision class >> manifoldBetween: firstBody and: secondBody [
	firstBody shapeState isCircle ifTrue: [
		secondBody shapeState isCircle ifTrue: [
			^ CFPhysicsCircleCollision manifoldBetweenCircle: firstBody andCircle: secondBody ].
		^ CFPhysicsPolygonCollision manifoldBetweenCircle: firstBody andPolygon: secondBody ].
	secondBody shapeState isCircle ifTrue: [
		^ CFPhysicsPolygonCollision manifoldBetweenPolygon: firstBody andCircle: secondBody ].
	^ CFPhysicsPolygonCollision manifoldBetween: firstBody and: secondBody
]
