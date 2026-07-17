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
		^ CFPhysicsCircleCollision manifoldBetweenCircle: firstBody andRectangle: secondBody ].
	secondBody shapeState isCircle ifTrue: [
		^ CFPhysicsCircleCollision manifoldBetweenRectangle: firstBody andCircle: secondBody ].
	^ CFPhysicsRectangleCollision manifoldBetween: firstBody and: secondBody
]
