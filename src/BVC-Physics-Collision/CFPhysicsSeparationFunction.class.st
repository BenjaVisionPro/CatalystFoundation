"
I evaluate the local separating axis used by Box2D's time-of-impact root finder.

I am constructed from the final core-distance simplex at the current sweep
fraction. I deliberately retain feature indices, rather than deriving a new
axis from velocity, so rotation is handled by the geometric query as in Box2D.
"
Class {
	#name : 'CFPhysicsSeparationFunction',
	#superclass : 'Object',
	#instVars : [ 'proxyA', 'proxyB', 'sweepA', 'sweepB', 'type', 'axis', 'localPoint' ],
	#category : 'BVC-Physics-Collision',
	#package : 'BVC-Physics-Collision'
}

{ #category : 'instance creation' }
CFPhysicsSeparationFunction class >> fromSimplex: simplex proxyA: firstProxy sweepA: firstSweep proxyB: secondProxy sweepB: secondSweep at: fraction [
	^ self new
		initializeFromSimplex: simplex
		proxyA: firstProxy
		sweepA: firstSweep
		proxyB: secondProxy
		sweepB: secondSweep
		at: fraction;
		yourself
]

{ #category : 'initialization' }
CFPhysicsSeparationFunction >> initializeFromSimplex: simplex proxyA: firstProxy sweepA: firstSweep proxyB: secondProxy sweepB: secondSweep at: fraction [
	| transformA transformB first second pointA pointB normal |
	proxyA := firstProxy.
	proxyB := secondProxy.
	sweepA := firstSweep.
	sweepB := secondSweep.
	transformA := sweepA transformAt: fraction.
	transformB := sweepB transformAt: fraction.
	simplex size = 1 ifTrue: [
		type := #points.
		first := simplex first.
		axis := self normalized: first secondPoint - first firstPoint.
		localPoint := 0 @ 0.
		^ self ].
	first := simplex first.
	second := simplex second.
	first firstIndex = second firstIndex ifTrue: [
		type := #faceB.
		localPoint := ((proxyB points at: first secondIndex) + (proxyB points at: second secondIndex)) / 2.0.
		axis := self normalized: (self perpendicularTo: ((proxyB points at: second secondIndex) - (proxyB points at: first secondIndex))).
		normal := self rotate: axis by: transformB rotation.
		pointA := self transform: (proxyA points at: first firstIndex) by: transformA.
		pointB := self transform: localPoint by: transformB.
		(self dot: pointA - pointB with: normal) < 0 ifTrue: [ axis := axis negated ].
		^ self ].
	type := #faceA.
	localPoint := ((proxyA points at: first firstIndex) + (proxyA points at: second firstIndex)) / 2.0.
	axis := self normalized: (self perpendicularTo: ((proxyA points at: second firstIndex) - (proxyA points at: first firstIndex))).
	normal := self rotate: axis by: transformA rotation.
	pointA := self transform: localPoint by: transformA.
	pointB := self transform: (proxyB points at: first secondIndex) by: transformB.
	(self dot: pointB - pointA with: normal) < 0 ifTrue: [ axis := axis negated ]
]

{ #category : 'querying' }
CFPhysicsSeparationFunction >> minimumSeparationAt: fraction [
	| transformA transformB normal indexA indexB pointA pointB |
	transformA := sweepA transformAt: fraction.
	transformB := sweepB transformAt: fraction.
	type = #points ifTrue: [
		indexA := proxyA supportIndexInDirection: (self inverseRotate: axis by: transformA rotation).
		indexB := proxyB supportIndexInDirection: (self inverseRotate: axis negated by: transformB rotation).
		pointA := self transform: (proxyA points at: indexA) by: transformA.
		pointB := self transform: (proxyB points at: indexB) by: transformB.
		^ { self dot: pointB - pointA with: axis. indexA. indexB } ].
	type = #faceA ifTrue: [
		normal := self rotate: axis by: transformA rotation.
		indexB := proxyB supportIndexInDirection: (self inverseRotate: normal negated by: transformB rotation).
		pointA := self transform: localPoint by: transformA.
		pointB := self transform: (proxyB points at: indexB) by: transformB.
		^ { self dot: pointB - pointA with: normal. nil. indexB } ].
	normal := self rotate: axis by: transformB rotation.
	indexA := proxyA supportIndexInDirection: (self inverseRotate: normal negated by: transformA rotation).
	pointA := self transform: (proxyA points at: indexA) by: transformA.
	pointB := self transform: localPoint by: transformB.
	^ { self dot: pointA - pointB with: normal. indexA. nil }
]

{ #category : 'querying' }
CFPhysicsSeparationFunction >> separationAtFirstIndex: firstIndex secondIndex: secondIndex at: fraction [
	| transformA transformB normal pointA pointB |
	transformA := sweepA transformAt: fraction.
	transformB := sweepB transformAt: fraction.
	type = #points ifTrue: [
		pointA := self transform: (proxyA points at: firstIndex) by: transformA.
		pointB := self transform: (proxyB points at: secondIndex) by: transformB.
		^ self dot: pointB - pointA with: axis ].
	type = #faceA ifTrue: [
		normal := self rotate: axis by: transformA rotation.
		pointA := self transform: localPoint by: transformA.
		pointB := self transform: (proxyB points at: secondIndex) by: transformB.
		^ self dot: pointB - pointA with: normal ].
	normal := self rotate: axis by: transformB rotation.
	pointA := self transform: (proxyA points at: firstIndex) by: transformA.
	pointB := self transform: localPoint by: transformB.
	^ self dot: pointA - pointB with: normal
]

{ #category : 'private' }
CFPhysicsSeparationFunction >> dot: first with: second [
	^ (first x * second x) + (first y * second y)
]

{ #category : 'private' }
CFPhysicsSeparationFunction >> inverseRotate: aPoint by: anAngle [
	^ self rotate: aPoint by: anAngle negated
]

{ #category : 'private' }
CFPhysicsSeparationFunction >> normalized: aPoint [
	^ aPoint r = 0 ifTrue: [ 1 @ 0 ] ifFalse: [ aPoint / aPoint r ]
]

{ #category : 'private' }
CFPhysicsSeparationFunction >> perpendicularTo: aPoint [
	^ aPoint y @ aPoint x negated
]

{ #category : 'private' }
CFPhysicsSeparationFunction >> rotate: aPoint by: anAngle [
	| cosine sine |
	anAngle = 0 ifTrue: [ ^ aPoint ].
	cosine := anAngle cos.
	sine := anAngle sin.
	^ ((aPoint x * cosine) - (aPoint y * sine)) @ ((aPoint x * sine) + (aPoint y * cosine))
]

{ #category : 'private' }
CFPhysicsSeparationFunction >> transform: aPoint by: aTransform [
	^ aTransform bodyOrigin + (self rotate: aPoint by: aTransform rotation)
]
