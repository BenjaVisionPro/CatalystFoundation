"
I implement Box2D 3.1.1's local-separating-axis time-of-impact algorithm.

Unlike Catalyst's legacy conservative advancement, I use core distance proxies,
feature-indexed simplex witnesses and a geometric separation function. This is
the narrow-phase source of truth used before continuous-step integration.
"
Class {
	#name : 'CFPhysicsBox2DTimeOfImpact',
	#superclass : 'Object',
	#category : 'BVC-Physics-Collision',
	#package : 'BVC-Physics-Collision'
}

{ #category : 'querying' }
CFPhysicsBox2DTimeOfImpact class >> betweenShapeState: firstShapeState sweep: firstSweep andShapeState: secondShapeState sweep: secondSweep linearSlop: linearSlop [
	| proxyA proxyB |
	proxyA := firstShapeState distanceProxy.
	proxyB := secondShapeState distanceProxy.
	^ self
		betweenProxy: proxyA
		sweep: firstSweep
		andProxy: proxyB
		sweep: secondSweep
		linearSlop: linearSlop
]

{ #category : 'querying' }
CFPhysicsBox2DTimeOfImpact class >> betweenProxy: proxyA sweep: firstSweep andProxy: proxyB sweep: secondSweep linearSlop: linearSlop [
	| totalRadius target tolerance fraction maximumIterations distanceState distanceResult simplex separationFunction done secondFraction pushBackIterations separationAtEnd firstIndex secondIndex separationAtStart rootIterations lower upper candidate candidateSeparation |
	totalRadius := proxyA radius + proxyB radius.
	target := linearSlop max: (totalRadius - linearSlop).
	tolerance := 0.25 * linearSlop.
	fraction := 0.0.
	maximumIterations := 20.
	1 to: maximumIterations do: [ :iteration |
		distanceState := self
			distanceBetween: proxyA sweep: firstSweep and: proxyB sweep: secondSweep at: fraction.
		distanceResult := distanceState first.
		simplex := distanceState second.
		distanceResult isOverlapping ifTrue: [
			^ CFPhysicsTimeOfImpactResult status: #overlapped fraction: 0.0 distanceResult: distanceResult iterations: iteration ].
		distanceResult distance <= (target + tolerance) ifTrue: [
			^ CFPhysicsTimeOfImpactResult status: #impact fraction: fraction distanceResult: distanceResult iterations: iteration ].
		separationFunction := CFPhysicsSeparationFunction
			fromSimplex: simplex
			proxyA: proxyA
			sweepA: firstSweep
			proxyB: proxyB
			sweepB: secondSweep
			at: fraction.
		done := false.
		secondFraction := 1.0.
		pushBackIterations := 0.
		[ done ] whileFalse: [
			separationAtEnd := separationFunction minimumSeparationAt: secondFraction.
			(separationAtEnd first > (target + tolerance)) ifTrue: [
				^ self separatedResultBetween: proxyA sweep: firstSweep and: proxyB sweep: secondSweep ].
			(separationAtEnd first > (target - tolerance)) ifTrue: [
				fraction := secondFraction.
				done := true ] ifFalse: [
				firstIndex := separationAtEnd second.
				secondIndex := separationAtEnd third.
				separationAtStart := separationFunction
					separationAtFirstIndex: firstIndex
					secondIndex: secondIndex
					at: fraction.
				separationAtStart < (target - tolerance) ifTrue: [
					^ CFPhysicsTimeOfImpactResult status: #failed fraction: fraction distanceResult: distanceResult iterations: iteration ].
				separationAtStart <= (target + tolerance) ifTrue: [
					^ CFPhysicsTimeOfImpactResult status: #impact fraction: fraction distanceResult: distanceResult iterations: iteration ].
				rootIterations := 0.
				lower := fraction.
				upper := secondFraction.
				[ rootIterations < 50 ] whileTrue: [
					candidate := rootIterations odd
						ifTrue: [ lower + ((target - separationAtStart) * (upper - lower) / (separationAtEnd first - separationAtStart)) ]
						ifFalse: [ 0.5 * (lower + upper) ].
					candidateSeparation := separationFunction
						separationAtFirstIndex: firstIndex
						secondIndex: secondIndex
						at: candidate.
					rootIterations := rootIterations + 1.
					(candidateSeparation - target) abs < tolerance ifTrue: [
						secondFraction := candidate.
						rootIterations := 50 ] ifFalse: [
						candidateSeparation > target
							ifTrue: [ lower := candidate. separationAtStart := candidateSeparation ]
							ifFalse: [ upper := candidate. separationAtEnd := { candidateSeparation. firstIndex. secondIndex } ] ] ].
				pushBackIterations := pushBackIterations + 1.
				pushBackIterations >= (proxyA points size max: proxyB points size) ifTrue: [ done := true ] ] ] ].
	^ CFPhysicsTimeOfImpactResult status: #failed fraction: fraction distanceResult: distanceResult iterations: maximumIterations
]

{ #category : 'private - distance' }
CFPhysicsBox2DTimeOfImpact class >> distanceBetween: proxyA sweep: firstSweep and: proxyB sweep: secondSweep at: fraction [
	| transformA transformB direction simplex state closest previousDistanceSquared support progress result |
	transformA := firstSweep transformAt: fraction.
	transformB := secondSweep transformAt: fraction.
	direction := transformB bodyOrigin - transformA bodyOrigin.
	direction r = 0 ifTrue: [ direction := 1 @ 0 ].
	simplex := OrderedCollection with: (self supportBetween: proxyA transform: transformA and: proxyB transform: transformB inDirection: direction).
	state := CFPhysicsGJK closestStateForDistanceSimplex: simplex.
	previousDistanceSquared := Float infinity.
	1 to: 32 do: [ :ignored |
		state fourth ifTrue: [ ^ { self distanceResultFrom: state. state first } ].
		closest := state second.
		closest r <= 1.0e-9 ifTrue: [ ^ { self distanceResultFrom: state. state first } ].
		((closest x squared + closest y squared) >= (previousDistanceSquared - 1.0e-9)) ifTrue: [
			^ { self distanceResultFrom: state. state first } ].
		previousDistanceSquared := closest x squared + closest y squared.
		direction := closest negated.
		support := self supportBetween: proxyA transform: transformA and: proxyB transform: transformB inDirection: direction.
		(state first anySatisfy: [ :each | each firstIndex = support firstIndex and: [ each secondIndex = support secondIndex ] ]) ifTrue: [
			^ { self distanceResultFrom: state. state first } ].
		progress := (self dot: support point with: direction) - (self dot: closest with: direction).
		progress <= 1.0e-9 ifTrue: [ ^ { self distanceResultFrom: state. state first } ].
		simplex := state first asOrderedCollection.
		simplex add: support.
		state := CFPhysicsGJK closestStateForDistanceSimplex: simplex ].
	result := self distanceResultFrom: state.
	^ { result. state first }
]

{ #category : 'private - distance' }
CFPhysicsBox2DTimeOfImpact class >> distanceResultFrom: state [
	| simplex weights firstWitness secondWitness distance |
	simplex := state first.
	weights := state third.
	firstWitness := 0 @ 0.
	secondWitness := 0 @ 0.
	1 to: simplex size do: [ :index |
		firstWitness := firstWitness + ((simplex at: index) firstPoint * (weights at: index)).
		secondWitness := secondWitness + ((simplex at: index) secondPoint * (weights at: index)) ].
	distance := (firstWitness - secondWitness) r.
	^ CFPhysicsDistanceResult
		distance: (state fourth ifTrue: [ 0.0 ] ifFalse: [ distance ])
		firstPoint: firstWitness
		secondPoint: secondWitness
		axis: (distance = 0 ifTrue: [ 0 @ 0 ] ifFalse: [ (secondWitness - firstWitness) / distance ])
		overlapping: state fourth
]

{ #category : 'private - support' }
CFPhysicsBox2DTimeOfImpact class >> supportBetween: proxyA transform: transformA and: proxyB transform: transformB inDirection: direction [
	| indexA indexB pointA pointB |
	indexA := proxyA supportIndexInDirection: (self inverseRotate: direction by: transformA rotation).
	indexB := proxyB supportIndexInDirection: (self inverseRotate: direction negated by: transformB rotation).
	pointA := self transform: (proxyA points at: indexA) by: transformA.
	pointB := self transform: (proxyB points at: indexB) by: transformB.
	^ CFPhysicsSupportPoint
		point: pointA - pointB
		firstPoint: pointA
		secondPoint: pointB
		firstIndex: indexA
		secondIndex: indexB
]

{ #category : 'private' }
CFPhysicsBox2DTimeOfImpact class >> separatedResultBetween: proxyA sweep: firstSweep and: proxyB sweep: secondSweep [
	| distanceState |
	distanceState := self distanceBetween: proxyA sweep: firstSweep and: proxyB sweep: secondSweep at: 1.0.
	^ CFPhysicsTimeOfImpactResult status: #separated fraction: 1.0 distanceResult: distanceState first iterations: 0
]

{ #category : 'private' }
CFPhysicsBox2DTimeOfImpact class >> dot: first with: second [
	^ (first x * second x) + (first y * second y)
]

{ #category : 'private' }
CFPhysicsBox2DTimeOfImpact class >> inverseRotate: aPoint by: anAngle [
	^ self rotate: aPoint by: anAngle negated
]

{ #category : 'private' }
CFPhysicsBox2DTimeOfImpact class >> rotate: aPoint by: anAngle [
	| cosine sine |
	anAngle = 0 ifTrue: [ ^ aPoint ].
	cosine := anAngle cos.
	sine := anAngle sin.
	^ ((aPoint x * cosine) - (aPoint y * sine)) @ ((aPoint x * sine) + (aPoint y * cosine))
]

{ #category : 'private' }
CFPhysicsBox2DTimeOfImpact class >> transform: aPoint by: aTransform [
	^ aTransform bodyOrigin + (self rotate: aPoint by: aTransform rotation)
]
