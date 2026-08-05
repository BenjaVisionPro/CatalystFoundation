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
	| totalRadius target tolerance fraction maximumIterations simplexCache distanceState distanceResult simplex separationFunction done secondFraction pushBackIterations separationAtEnd firstIndex secondIndex separationAtStart rootIterations lower upper candidate candidateSeparation |
	totalRadius := proxyA radius + proxyB radius.
	target := linearSlop max: (totalRadius - linearSlop).
	tolerance := 0.25 * linearSlop.
	fraction := 0.0.
	maximumIterations := 20.
	simplexCache := CFPhysicsSimplexCache empty.
	1 to: maximumIterations do: [ :iteration |
		distanceState := self
			distanceBetween: proxyA sweep: firstSweep and: proxyB sweep: secondSweep at: fraction cache: simplexCache.
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
CFPhysicsBox2DTimeOfImpact class >> distanceBetween: proxyA sweep: firstSweep and: proxyB sweep: secondSweep at: fraction cache: simplexCache [
	| transformA transformB distanceResult simplex |
	transformA := firstSweep transformAt: fraction.
	transformB := secondSweep transformAt: fraction.
	distanceResult := CFPhysicsGJK
		distanceBetweenProxy: proxyA
		transform: transformA
		andProxy: proxyB
		transform: transformB
		cache: simplexCache.
	simplex := CFPhysicsGJK
		simplexFromCache: simplexCache
		firstProxy: proxyA
		transform: transformA
		secondProxy: proxyB
		transform: transformB.
	^ { distanceResult. simplex asArray }
]

{ #category : 'private' }
CFPhysicsBox2DTimeOfImpact class >> separatedResultBetween: proxyA sweep: firstSweep and: proxyB sweep: secondSweep [
	| distanceState |
	distanceState := self distanceBetween: proxyA sweep: firstSweep and: proxyB sweep: secondSweep at: 1.0 cache: CFPhysicsSimplexCache empty.
	^ CFPhysicsTimeOfImpactResult status: #separated fraction: 1.0 distanceResult: distanceState first iterations: 0
]
