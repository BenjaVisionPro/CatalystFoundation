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

{ #category : 'distance' }
CFPhysicsGJK class >> distanceBetween: firstBody and: secondBody [
	^ self
		distanceBetweenShapeState: firstBody shapeState
		transform: (CFPhysicsTransform
			position: firstBody position
			rotation: firstBody rotation)
		andShapeState: secondBody shapeState
		transform: (CFPhysicsTransform
			position: secondBody position
			rotation: secondBody rotation)
]

{ #category : 'distance' }
CFPhysicsGJK class >> distanceBetweenShapeState: firstShapeState transform: firstTransform andShapeState: secondShapeState transform: secondTransform [
	| simplex direction support state closest previousDistanceSquared progress tolerance |
	tolerance := 1.0e-9.
	direction := (secondShapeState centreAt: secondTransform position)
		- (firstShapeState centreAt: firstTransform position).
	direction r = 0 ifTrue: [ direction := 1 @ 0 ].
	simplex := OrderedCollection with: (self
		supportBetweenShapeState: firstShapeState
		transform: firstTransform
		andShapeState: secondShapeState
		transform: secondTransform
		inDirection: direction).
	state := self closestStateForDistanceSimplex: simplex.
	previousDistanceSquared := Float infinity.
	1 to: 32 do: [ :iteration |
		state fourth ifTrue: [ ^ self distanceResultFromState: state ].
		closest := state second.
		closest r <= tolerance ifTrue: [ ^ self distanceResultFromState: state ].
		((closest x squared + closest y squared) >= (previousDistanceSquared - tolerance))
			ifTrue: [ ^ self distanceResultFromState: state ].
		previousDistanceSquared := closest x squared + closest y squared.
		direction := closest negated.
		support := self
			supportBetweenShapeState: firstShapeState
			transform: firstTransform
			andShapeState: secondShapeState
			transform: secondTransform
			inDirection: direction.
		(state first anySatisfy: [ :each | each point = support point ])
			ifTrue: [ ^ self distanceResultFromState: state ].
		progress := (self dot: support point with: direction)
			- (self dot: closest with: direction).
		progress <= tolerance ifTrue: [ ^ self distanceResultFromState: state ].
		simplex := state first asOrderedCollection.
		simplex add: support.
		state := self closestStateForDistanceSimplex: simplex ].
	^ self distanceResultFromState: state
]

{ #category : 'distance - private' }
CFPhysicsGJK class >> closestStateForDistanceSimplex: simplex [
	simplex size = 1 ifTrue: [
		^ { simplex asArray. simplex first point. #(1.0). false } ].
	simplex size = 2 ifTrue: [ ^ self closestStateForDistanceLine: simplex ].
	^ self closestStateForDistanceTriangle: simplex
]

{ #category : 'distance - private' }
CFPhysicsGJK class >> closestStateForDistanceLine: simplex [
	| first second edge denominator parameter closest |
	first := simplex first.
	second := simplex second.
	edge := second point - first point.
	denominator := self dot: edge with: edge.
	denominator = 0 ifTrue: [
		^ { { first }. first point. #(1.0). false } ].
	parameter := (self dot: first point negated with: edge) / denominator.
	parameter <= 0 ifTrue: [
		^ { { first }. first point. #(1.0). false } ].
	parameter >= 1 ifTrue: [
		^ { { second }. second point. #(1.0). false } ].
	closest := first point + (edge * parameter).
	^ { { first. second }. closest. { 1.0 - parameter. parameter }. false }
]

{ #category : 'distance - private' }
CFPhysicsGJK class >> closestStateForDistanceTriangle: simplex [
	| aSupport bSupport cSupport a b c ab ac ap d1 d2 bp d3 d4 vc parameter cp d5 d6 vb va denominator firstWeight secondWeight thirdWeight |
	aSupport := simplex first.
	bSupport := simplex second.
	cSupport := simplex third.
	a := aSupport point.
	b := bSupport point.
	c := cSupport point.
	ab := b - a.
	ac := c - a.
	ap := a negated.
	d1 := self dot: ab with: ap.
	d2 := self dot: ac with: ap.
	(d1 <= 0 and: [ d2 <= 0 ]) ifTrue: [
		^ { { aSupport }. a. #(1.0). false } ].
	bp := b negated.
	d3 := self dot: ab with: bp.
	d4 := self dot: ac with: bp.
	(d3 >= 0 and: [ d4 <= d3 ]) ifTrue: [
		^ { { bSupport }. b. #(1.0). false } ].
	vc := (d1 * d4) - (d3 * d2).
	(vc <= 0 and: [ d1 >= 0 and: [ d3 <= 0 ] ]) ifTrue: [
		parameter := d1 / (d1 - d3).
		^ {
			{ aSupport. bSupport }.
			a + (ab * parameter).
			{ 1.0 - parameter. parameter }.
			false } ].
	cp := c negated.
	d5 := self dot: ab with: cp.
	d6 := self dot: ac with: cp.
	(d6 >= 0 and: [ d5 <= d6 ]) ifTrue: [
		^ { { cSupport }. c. #(1.0). false } ].
	vb := (d5 * d2) - (d1 * d6).
	(vb <= 0 and: [ d2 >= 0 and: [ d6 <= 0 ] ]) ifTrue: [
		parameter := d2 / (d2 - d6).
		^ {
			{ aSupport. cSupport }.
			a + (ac * parameter).
			{ 1.0 - parameter. parameter }.
			false } ].
	va := (d3 * d6) - (d5 * d4).
	(va <= 0 and: [ (d4 - d3) >= 0 and: [ (d5 - d6) >= 0 ] ]) ifTrue: [
		parameter := (d4 - d3) / ((d4 - d3) + (d5 - d6)).
		^ {
			{ bSupport. cSupport }.
			b + ((c - b) * parameter).
			{ 1.0 - parameter. parameter }.
			false } ].
	denominator := 1.0 / (va + vb + vc).
	secondWeight := vb * denominator.
	thirdWeight := vc * denominator.
	firstWeight := 1.0 - secondWeight - thirdWeight.
	^ {
		{ aSupport. bSupport. cSupport }.
		0 @ 0.
		{ firstWeight. secondWeight. thirdWeight }.
		true }
]

{ #category : 'distance - private' }
CFPhysicsGJK class >> distanceResultFromState: state [
	| simplex weights firstWitness secondWitness distance axis overlapping |
	simplex := state first.
	weights := state third.
	firstWitness := 0 @ 0.
	secondWitness := 0 @ 0.
	1 to: simplex size do: [ :index |
		firstWitness := firstWitness
			+ ((simplex at: index) firstPoint * (weights at: index)).
		secondWitness := secondWitness
			+ ((simplex at: index) secondPoint * (weights at: index)) ].
	distance := (firstWitness - secondWitness) r.
	overlapping := state fourth or: [ distance <= 1.0e-9 ].
	axis := overlapping
		ifTrue: [ 0 @ 0 ]
		ifFalse: [ (secondWitness - firstWitness) / distance ].
	^ CFPhysicsDistanceResult
		distance: (overlapping ifTrue: [ 0.0 ] ifFalse: [ distance ])
		firstPoint: firstWitness
		secondPoint: secondWitness
		axis: axis
		overlapping: overlapping
]
