Class {
	#name : 'CFPhysicsCollision',
	#superclass : 'Object',
	#category : 'BVC-Physics-Collision',
	#package : 'BVC-Physics-Collision'
}

{ #category : 'collision' }
CFPhysicsCollision class >> manifoldBetween: firstBody and: secondBody [
	(firstBody rotation ~= 0 or: [ secondBody rotation ~= 0 ]) ifTrue: [
		^ self
			ensureLocalAnchorsOn: (CFPhysicsConvexCollision manifoldBetween: firstBody and: secondBody)
			between: firstBody
			and: secondBody ].
	(firstBody shapeState isRoundedRectangle or: [ secondBody shapeState isRoundedRectangle ]) ifTrue: [
		^ self
			ensureLocalAnchorsOn: (CFPhysicsConvexCollision manifoldBetween: firstBody and: secondBody)
			between: firstBody
			and: secondBody ].
	firstBody shapeState isCircle ifTrue: [
		secondBody shapeState isCircle ifTrue: [
			^ self
				ensureLocalAnchorsOn: (CFPhysicsCircleCollision manifoldBetweenCircle: firstBody andCircle: secondBody)
				between: firstBody
				and: secondBody ].
		secondBody shapeState isRectangle ifTrue: [
			^ self
				ensureLocalAnchorsOn: (CFPhysicsCircleCollision manifoldBetweenCircle: firstBody andRectangle: secondBody)
				between: firstBody
				and: secondBody ].
		^ self
			ensureLocalAnchorsOn: (CFPhysicsPolygonCollision manifoldBetweenCircle: firstBody andPolygon: secondBody)
			between: firstBody
			and: secondBody ].
	secondBody shapeState isCircle ifTrue: [
		firstBody shapeState isRectangle ifTrue: [
			^ self
				ensureLocalAnchorsOn: (CFPhysicsCircleCollision manifoldBetweenRectangle: firstBody andCircle: secondBody)
				between: firstBody
				and: secondBody ].
		^ self
			ensureLocalAnchorsOn: (CFPhysicsPolygonCollision manifoldBetweenPolygon: firstBody andCircle: secondBody)
			between: firstBody
			and: secondBody ].
	(firstBody shapeState isRectangle and: [ secondBody shapeState isRectangle ]) ifTrue: [
		^ self
			ensureLocalAnchorsOn: (CFPhysicsRectangleCollision manifoldBetween: firstBody and: secondBody)
			between: firstBody
			and: secondBody ].
	^ self
		ensureLocalAnchorsOn: (CFPhysicsPolygonCollision manifoldBetween: firstBody and: secondBody)
		between: firstBody
		and: secondBody
]

{ #category : 'private' }
CFPhysicsCollision class >> ensureLocalAnchorsOn: manifold between: firstBody and: secondBody [
	manifold ifNil: [ ^ nil ].
	manifold contactPoints do: [ :point |
		point localAnchorA ifNil: [
			point localAnchorA: (firstBody shapeState
				localPointForWorldPoint: point position
				bodyOrigin: firstBody worldBodyOrigin
				rotation: firstBody rotation) ].
		point localAnchorB ifNil: [
			point localAnchorB: (secondBody shapeState
				localPointForWorldPoint: point position
				bodyOrigin: secondBody worldBodyOrigin
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
		centreDelta := secondTransform bodyOrigin
			- firstTransform bodyOrigin.
		normal := centreDelta r = 0
			ifTrue: [ 1 @ 0 ]
			ifFalse: [ centreDelta / centreDelta r ] ].
	firstCentre := firstTransform bodyOrigin.
	secondCentre := secondTransform bodyOrigin.
	firstBoundary := firstShapeState
		nearestBoundaryPointTo: secondCentre
		atBodyOrigin: firstTransform bodyOrigin
		rotation: firstTransform rotation.
	secondBoundary := secondShapeState
		nearestBoundaryPointTo: firstCentre
		atBodyOrigin: secondTransform bodyOrigin
		rotation: secondTransform rotation.
	worldPoint := (firstBoundary + secondBoundary) / 2.0.
	point := CFPhysicsManifoldPoint at: worldPoint.
	point
		separation: 0.0;
		localAnchorA: (firstShapeState
			localPointForWorldPoint: worldPoint
			bodyOrigin: firstTransform bodyOrigin
			rotation: firstTransform rotation);
		localAnchorB: (secondShapeState
			localPointForWorldPoint: worldPoint
			bodyOrigin: secondTransform bodyOrigin
			rotation: secondTransform rotation).
	^ (CFPhysicsManifold normal: normal penetration: 0.0)
		contactPoints: { point };
		yourself
]
