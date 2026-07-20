Class {
	#name : 'CFPhysicsGJK',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Physics-Collision',
	#package : 'BVC-Foundation-Physics-Collision'
}

{ #category : 'collision' }
CFPhysicsGJK class >> simplexBetween: firstBody and: secondBody [
	^ self
		simplexBetweenShapeState: firstBody shapeState
		transform: (CFPhysicsTransform
			position: firstBody position
			rotation: firstBody rotation)
		andShapeState: secondBody shapeState
		transform: (CFPhysicsTransform
			position: secondBody position
			rotation: secondBody rotation)
]

{ #category : 'collision' }
CFPhysicsGJK class >> simplexBetweenShapeState: firstShapeState transform: firstTransform andShapeState: secondShapeState transform: secondTransform [
	| simplex direction support result |
	direction := (secondShapeState centreAt: secondTransform position)
		- (firstShapeState centreAt: firstTransform position).
	direction r = 0 ifTrue: [ direction := 1 @ 0 ].
	simplex := OrderedCollection new.
	support := self
		supportBetweenShapeState: firstShapeState
		transform: firstTransform
		andShapeState: secondShapeState
		transform: secondTransform
		inDirection: direction.
	simplex addFirst: support.
	direction := support point negated.
	1 to: 32 do: [ :iteration |
		direction r = 0 ifTrue: [ direction := 1 @ 0 ].
		support := self
			supportBetweenShapeState: firstShapeState
			transform: firstTransform
			andShapeState: secondShapeState
			transform: secondTransform
			inDirection: direction.
		(self dot: support point with: direction) < 0 ifTrue: [ ^ nil ].
		simplex addFirst: support.
		result := self processSimplex: simplex.
		result first ifTrue: [ ^ simplex asArray ].
		direction := result second ].
	^ nil
]

{ #category : 'collision' }
CFPhysicsGJK class >> supportBetween: firstBody and: secondBody inDirection: direction [
	^ self
		supportBetweenShapeState: firstBody shapeState
		transform: (CFPhysicsTransform
			position: firstBody position
			rotation: firstBody rotation)
		andShapeState: secondBody shapeState
		transform: (CFPhysicsTransform
			position: secondBody position
			rotation: secondBody rotation)
		inDirection: direction
]

{ #category : 'collision' }
CFPhysicsGJK class >> supportBetweenShapeState: firstShapeState transform: firstTransform andShapeState: secondShapeState transform: secondTransform inDirection: direction [
	| firstPoint secondPoint |
	firstPoint := firstShapeState
		supportPointAt: firstTransform position
		rotation: firstTransform rotation
		inDirection: direction.
	secondPoint := secondShapeState
		supportPointAt: secondTransform position
		rotation: secondTransform rotation
		inDirection: direction negated.
	^ CFPhysicsSupportPoint
		point: firstPoint - secondPoint
		firstPoint: firstPoint
		secondPoint: secondPoint
]

{ #category : 'private' }
CFPhysicsGJK class >> processSimplex: simplex [
	simplex size = 2 ifTrue: [ ^ self processLine: simplex ].
	^ self processTriangle: simplex
]

{ #category : 'private' }
CFPhysicsGJK class >> processLine: simplex [
	| a b ao ab direction |
	a := simplex first point.
	b := simplex second point.
	ao := a negated.
	ab := b - a.
	(self dot: ab with: ao) > 0
		ifTrue: [
			direction := self tripleProduct: ab with: ao with: ab.
			direction r = 0 ifTrue: [ direction := ab y negated @ ab x ] ]
		ifFalse: [
			simplex removeLast.
			direction := ao ].
	^ { false. direction }
]

{ #category : 'private' }
CFPhysicsGJK class >> processTriangle: simplex [
	| a b c ao ab ac abPerpendicular acPerpendicular |
	a := simplex first point.
	b := simplex second point.
	c := simplex third point.
	ao := a negated.
	ab := b - a.
	ac := c - a.
	abPerpendicular := self tripleProduct: ac with: ab with: ab.
	(self dot: abPerpendicular with: ao) > 0 ifTrue: [
		simplex removeLast.
		^ { false. abPerpendicular } ].
	acPerpendicular := self tripleProduct: ab with: ac with: ac.
	(self dot: acPerpendicular with: ao) > 0 ifTrue: [
		simplex removeAt: 2.
		^ { false. acPerpendicular } ].
	^ { true. 0 @ 0 }
]

{ #category : 'private' }
CFPhysicsGJK class >> tripleProduct: first with: second with: third [
	^ (second * (self dot: first with: third))
		- (first * (self dot: second with: third))
]

{ #category : 'private' }
CFPhysicsGJK class >> dot: first with: second [
	^ (first x * second x) + (first y * second y)
]
