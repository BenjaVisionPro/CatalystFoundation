Class {
	#name : 'CFPhysicsCollision',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Physics-Collision',
	#package : 'BVC-Foundation-Physics-Collision'
}

{ #category : 'collision' }
CFPhysicsCollision class >> manifoldBetween: firstBody and: secondBody [
	(firstBody rotation ~= 0 or: [ secondBody rotation ~= 0 ])
		ifTrue: [ ^ CFPhysicsConvexCollision manifoldBetween: firstBody and: secondBody ].
	(firstBody shapeState isRoundedRectangle or: [ secondBody shapeState isRoundedRectangle ])
		ifTrue: [ ^ CFPhysicsConvexCollision manifoldBetween: firstBody and: secondBody ].
	firstBody shapeState isCircle ifTrue: [
		secondBody shapeState isCircle ifTrue: [
			^ CFPhysicsCircleCollision manifoldBetweenCircle: firstBody andCircle: secondBody ].
		secondBody shapeState isRectangle ifTrue: [
			^ CFPhysicsCircleCollision manifoldBetweenCircle: firstBody andRectangle: secondBody ].
		^ CFPhysicsPolygonCollision manifoldBetweenCircle: firstBody andPolygon: secondBody ].
	secondBody shapeState isCircle ifTrue: [
		firstBody shapeState isRectangle ifTrue: [
			^ CFPhysicsCircleCollision manifoldBetweenRectangle: firstBody andCircle: secondBody ].
		^ CFPhysicsPolygonCollision manifoldBetweenPolygon: firstBody andCircle: secondBody ].
	(firstBody shapeState isRectangle and: [ secondBody shapeState isRectangle ])
		ifTrue: [ ^ CFPhysicsRectangleCollision manifoldBetween: firstBody and: secondBody ].
	^ CFPhysicsPolygonCollision manifoldBetween: firstBody and: secondBody
]

{ #category : 'collision' }
CFPhysicsCollision class >> manifoldBetweenShapeState: firstShapeState transform: firstTransform andShapeState: secondShapeState transform: secondTransform [
	| firstBody secondBody manifold distanceResult normal centreDelta |
	firstBody := CFPhysicsCollisionBodyView
		shapeState: firstShapeState
		transform: firstTransform.
	secondBody := CFPhysicsCollisionBodyView
		shapeState: secondShapeState
		transform: secondTransform.
	manifold := self manifoldBetween: firstBody and: secondBody.
	manifold ifNotNil: [ ^ manifold ].
	distanceResult := CFPhysicsGJK
		distanceBetweenShapeState: firstShapeState
		transform: firstTransform
		andShapeState: secondShapeState
		transform: secondTransform.
	distanceResult distance > 1.0e-7 ifTrue: [ ^ nil ].
	normal := distanceResult axis.
	normal r = 0 ifTrue: [
		centreDelta := (secondShapeState centreAt: secondTransform position)
			- (firstShapeState centreAt: firstTransform position).
		normal := centreDelta r = 0
			ifTrue: [ 1 @ 0 ]
			ifFalse: [ centreDelta / centreDelta r ] ].
	^ (CFPhysicsManifold normal: normal penetration: 0.0)
		points: { (distanceResult firstPoint + distanceResult secondPoint) / 2.0 };
		yourself
]
