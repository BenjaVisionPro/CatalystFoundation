Class {
	#name : 'CFPhysicsNearestGeometryEndpointPair',
	#superclass : 'CFPhysicsEndpointPair',
	#instVars : [ 'bodyA', 'bodyB' ],
	#category : 'BVC-Foundation-Physics-World',
	#package : 'BVC-Foundation-Physics-World'
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
			ifTrue: [ ((bodyA shapeState centreAt: bodyA position)
				+ (bodyB shapeState centreAt: bodyB position)) / 2.0 ]
			ifFalse: [ manifold points first ].
		^ { point. point } ].
	pointA := bodyA shapeState
		nearestBoundaryPointTo: (bodyB shapeState centreAt: bodyB position)
		at: bodyA position
		rotation: bodyA rotation.
	pointB := bodyB shapeState
		nearestBoundaryPointTo: pointA
		at: bodyB position
		rotation: bodyB rotation.
	1 to: 16 do: [ :iteration |
		newPointA := bodyA shapeState
			nearestBoundaryPointTo: pointB
			at: bodyA position
			rotation: bodyA rotation.
		newPointB := bodyB shapeState
			nearestBoundaryPointTo: newPointA
			at: bodyB position
			rotation: bodyB rotation.
		(((newPointA - pointA) r <= 0.000001)
			and: [ (newPointB - pointB) r <= 0.000001 ])
			ifTrue: [ ^ { newPointA. newPointB } ].
		pointA := newPointA.
		pointB := newPointB ].
	^ { pointA. pointB }
]
