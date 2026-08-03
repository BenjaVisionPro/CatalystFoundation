"
I describe the core geometry Box2D uses for distance and time-of-impact queries.

My points are body-local, relative to the body's rotation centre. Radius is kept
separate, so a rounded shape can use its polygonal core for GJK and apply its
rounding only through Box2D's TOI target distance.
"
Class {
	#name : 'CFPhysicsDistanceProxy',
	#superclass : 'Object',
	#instVars : [ 'points', 'radius' ],
	#category : 'BVC-Physics-Collision',
	#package : 'BVC-Physics-Collision'
}

{ #category : 'instance creation' }
CFPhysicsDistanceProxy class >> points: aCollection radius: aNumber [
	^ self new
		points: aCollection;
		radius: aNumber;
		yourself
]

{ #category : 'instance creation' }
CFPhysicsDistanceProxy class >> fromShapeState: aShapeState [
	| extent centre cornerRadius |
	extent := aShapeState extent.
	centre := extent / 2.0.
	aShapeState isCircle ifTrue: [
		^ self points: { 0 @ 0 } radius: aShapeState radius ].
	aShapeState isRoundedRectangle ifTrue: [
		cornerRadius := aShapeState roundedRectangleRadius.
		^ self
			points: {
				(cornerRadius @ cornerRadius) - centre.
				((extent x - cornerRadius) @ cornerRadius) - centre.
				((extent x - cornerRadius) @ (extent y - cornerRadius)) - centre.
				(cornerRadius @ (extent y - cornerRadius)) - centre }
			radius: cornerRadius ].
	^ self
		points: (aShapeState localCollisionVertices collect: [ :each | each - centre ])
		radius: 0.0
]

{ #category : 'accessing' }
CFPhysicsDistanceProxy >> points [
	^ points
]

{ #category : 'accessing' }
CFPhysicsDistanceProxy >> points: aCollection [
	points := aCollection asArray.
	points ifEmpty: [ self error: 'A distance proxy requires at least one point' ]
]

{ #category : 'accessing' }
CFPhysicsDistanceProxy >> radius [
	^ radius
]

{ #category : 'accessing' }
CFPhysicsDistanceProxy >> radius: aNumber [
	radius := aNumber asFloat max: 0.0
]

{ #category : 'querying' }
CFPhysicsDistanceProxy >> supportIndexInDirection: aDirection [
	| index bestProjection projection |
	index := 1.
	bestProjection := (points first x * aDirection x) + (points first y * aDirection y).
	2 to: points size do: [ :eachIndex |
		projection := ((points at: eachIndex) x * aDirection x)
			+ ((points at: eachIndex) y * aDirection y).
		projection > bestProjection ifTrue: [
			index := eachIndex.
			bestProjection := projection ] ].
	^ index
]

{ #category : 'querying' }
CFPhysicsDistanceProxy >> supportPointInDirection: aDirection [
	^ points at: (self supportIndexInDirection: aDirection)
]
