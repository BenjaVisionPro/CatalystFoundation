Class {
	#name : 'CFPhysicsCollision',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Physics-Collision',
	#package : 'BVC-Foundation-Physics-Collision'
}

{ #category : 'collision' }
CFPhysicsCollision class >> manifoldBetween: firstBody and: secondBody [
	| manifold |
	(firstBody rotation ~= 0 or: [ secondBody rotation ~= 0 ])
		ifTrue: [ manifold := CFPhysicsConvexCollision manifoldBetween: firstBody and: secondBody ]
		ifFalse: [
			(firstBody shapeState isRoundedRectangle or: [ secondBody shapeState isRoundedRectangle ])
				ifTrue: [ manifold := CFPhysicsConvexCollision manifoldBetween: firstBody and: secondBody ]
				ifFalse: [
					firstBody shapeState isCircle
						ifTrue: [
							secondBody shapeState isCircle
								ifTrue: [ manifold := CFPhysicsCircleCollision manifoldBetweenCircle: firstBody andCircle: secondBody ]
								ifFalse: [
									secondBody shapeState isRectangle
										ifTrue: [ manifold := CFPhysicsCircleCollision manifoldBetweenCircle: firstBody andRectangle: secondBody ]
										ifFalse: [ manifold := CFPhysicsPolygonCollision manifoldBetweenCircle: firstBody andPolygon: secondBody ] ] ]
						ifFalse: [
							secondBody shapeState isCircle
								ifTrue: [
									firstBody shapeState isRectangle
										ifTrue: [ manifold := CFPhysicsCircleCollision manifoldBetweenRectangle: firstBody andCircle: secondBody ]
										ifFalse: [ manifold := CFPhysicsPolygonCollision manifoldBetweenPolygon: firstBody andCircle: secondBody ] ]
								ifFalse: [
									(firstBody shapeState isRectangle and: [ secondBody shapeState isRectangle ])
										ifTrue: [ manifold := CFPhysicsRectangleCollision manifoldBetween: firstBody and: secondBody ]
										ifFalse: [ manifold := CFPhysicsPolygonCollision manifoldBetween: firstBody and: secondBody ] ] ] ] ] ].
	^ self ensureLocalAnchorsOn: manifold between: firstBody and: secondBody
]

{ #category : 'private' }
CFPhysicsCollision class >> ensureLocalAnchorsOn: manifold between: firstBody and: secondBody [
	manifold ifNil: [ ^ nil ].
	manifold contactPoints do: [ :point |
		point localAnchorA ifNil: [
			point localAnchorA: (firstBody shapeState
				localPointForWorldPoint: point position
				position: firstBody position
				rotation: firstBody rotation) ].
		point localAnchorB ifNil: [
			point localAnchorB: (secondBody shapeState
				localPointForWorldPoint: point position
				position: secondBody position
				rotation: secondBody rotation) ] ].
	^ manifold
]

{ #category : 'collision' }
CFPhysicsCollision class >> manifoldBetweenShapeState: firstShapeState transform: firstTransform andShapeState: secondShapeState transform: secondTransform [
	| firstBody secondBody manifold distanceResult normal centreDelta firstCentre secondCentre firstBoundary secondBoundary worldPoint point |
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
	firstCentre := firstShapeState centreAt: firstTransform position.
	secondCentre := secondShapeState centreAt: secondTransform position.
	firstBoundary := firstShapeState
		nearestBoundaryPointTo: secondCentre
		at: firstTransform position
		rotation: firstTransform rotation.
	secondBoundary := secondShapeState
		nearestBoundaryPointTo: firstCentre
		at: secondTransform position
		rotation: secondTransform rotation.
	worldPoint := (firstBoundary + secondBoundary) / 2.0.
	point := CFPhysicsManifoldPoint at: worldPoint.
	point
		separation: 0.0;
		localAnchorA: (firstShapeState
			localPointForWorldPoint: worldPoint
			position: firstTransform position
			rotation: firstTransform rotation);
		localAnchorB: (secondShapeState
			localPointForWorldPoint: worldPoint
			position: secondTransform position
			rotation: secondTransform rotation).
	^ (CFPhysicsManifold normal: normal penetration: 0.0)
		contactPoints: { point };
		yourself
]
