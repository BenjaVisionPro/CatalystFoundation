Class {
	#name : 'CFPhysicsNearestGeometryEndpointPair',
	#superclass : 'CFPhysicsEndpointPair',
	#instVars : [ 'bodyA', 'bodyB' ],
	#category : 'BVC-Physics-Collision',
	#package : 'BVC-Physics-Collision'
}

{ #category : 'instance creation' }
CFPhysicsNearestGeometryEndpointPair class >> between: firstBody and: secondBody [
	^ self new
		bodyA: firstBody;
		bodyB: secondBody;
		yourself
]

{ #category : 'accessing' }
CFPhysicsNearestGeometryEndpointPair >> bodyA [
	^ bodyA
]

{ #category : 'accessing' }
CFPhysicsNearestGeometryEndpointPair >> bodyA: aBodyState [
	bodyA := aBodyState
]

{ #category : 'accessing' }
CFPhysicsNearestGeometryEndpointPair >> bodyB [
	^ bodyB
]

{ #category : 'accessing' }
CFPhysicsNearestGeometryEndpointPair >> bodyB: aBodyState [
	bodyB := aBodyState
]

{ #category : 'accessing' }
CFPhysicsNearestGeometryEndpointPair >> world [
	(bodyA world notNil and: [ bodyA world == bodyB world ])
		ifFalse: [ self error: 'Both bodies must belong to the same physics world' ].
	^ bodyA world
]

{ #category : 'geometry' }
CFPhysicsNearestGeometryEndpointPair >> worldPoints [
	| manifold point pointA pointB newPointA newPointB |
	manifold := CFPhysicsCollision manifoldBetween: bodyA and: bodyB.
	manifold ifNotNil: [
		point := manifold points isEmpty
			ifTrue: [ (bodyA worldBodyOrigin + bodyB worldBodyOrigin) / 2.0 ]
			ifFalse: [ manifold points first ].
		^ { point. point } ].
	pointA := bodyA shapeState
		nearestBoundaryPointTo: bodyB worldBodyOrigin
		atBodyOrigin: bodyA worldBodyOrigin
		rotation: bodyA rotation.
	pointB := bodyB shapeState
		nearestBoundaryPointTo: pointA
		atBodyOrigin: bodyB worldBodyOrigin
		rotation: bodyB rotation.
	1 to: 16 do: [ :iteration |
		newPointA := bodyA shapeState
			nearestBoundaryPointTo: pointB
			atBodyOrigin: bodyA worldBodyOrigin
			rotation: bodyA rotation.
		newPointB := bodyB shapeState
			nearestBoundaryPointTo: newPointA
			atBodyOrigin: bodyB worldBodyOrigin
			rotation: bodyB rotation.
		(((newPointA - pointA) r <= 0.000001)
			and: [ (newPointB - pointB) r <= 0.000001 ])
			ifTrue: [ ^ { newPointA. newPointB } ].
		pointA := newPointA.
		pointB := newPointB ].
	^ { pointA. pointB }
]
