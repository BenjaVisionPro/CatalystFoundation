Class {
	#name : 'CFPhysicsConservativeAdvancement',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Physics-Collision',
	#package : 'BVC-Foundation-Physics-Collision'
}

{ #category : 'querying' }
CFPhysicsConservativeAdvancement class >> betweenShapeState: firstShapeState sweep: firstSweep andShapeState: secondShapeState sweep: secondSweep [
	| fraction distanceResult closingSpeed advance nextFraction tolerance maximumIterations |
	tolerance := 1.0e-7.
	maximumIterations := 32.
	fraction := 0.0.
	1 to: maximumIterations do: [ :iteration |
		distanceResult := self
			distanceBetweenShapeState: firstShapeState
			sweep: firstSweep
			andShapeState: secondShapeState
			sweep: secondSweep
			at: fraction.
		(distanceResult isOverlapping or: [ distanceResult distance <= tolerance ])
			ifTrue: [
				^ CFPhysicsTimeOfImpactResult
					status: #impact
					fraction: fraction
					distanceResult: distanceResult
					iterations: iteration ].
		closingSpeed := self
			closingSpeedBetweenShapeState: firstShapeState
			sweep: firstSweep
			andShapeState: secondShapeState
			sweep: secondSweep
			along: distanceResult axis.
		closingSpeed <= tolerance ifTrue: [
			^ self
				separatedResultBetweenShapeState: firstShapeState
				sweep: firstSweep
				andShapeState: secondShapeState
				sweep: secondSweep
				iterations: iteration ].
		advance := distanceResult distance / closingSpeed.
		nextFraction := fraction + advance.
		(nextFraction > 1.0 or: [ nextFraction <= fraction + tolerance ]) ifTrue: [
			^ self
				separatedResultBetweenShapeState: firstShapeState
				sweep: firstSweep
				andShapeState: secondShapeState
				sweep: secondSweep
				iterations: iteration ].
		fraction := nextFraction ].
	^ CFPhysicsTimeOfImpactResult
		status: #iterationLimit
		fraction: fraction
		distanceResult: distanceResult
		iterations: maximumIterations
]

{ #category : 'private' }
CFPhysicsConservativeAdvancement class >> closingSpeedBetweenShapeState: firstShapeState sweep: firstSweep andShapeState: secondShapeState sweep: secondSweep along: axis [
	| firstTranslation secondTranslation relativeTranslation linearClosing firstRotation secondRotation angularClosing |
	firstTranslation := firstSweep endTransform position - firstSweep startTransform position.
	secondTranslation := secondSweep endTransform position - secondSweep startTransform position.
	relativeTranslation := firstTranslation - secondTranslation.
	linearClosing := self dot: relativeTranslation with: axis.
	firstRotation := (firstSweep endTransform rotation - firstSweep startTransform rotation) abs.
	secondRotation := (secondSweep endTransform rotation - secondSweep startTransform rotation) abs.
	angularClosing := (firstRotation * firstShapeState boundingRadius)
		+ (secondRotation * secondShapeState boundingRadius).
	^ linearClosing + angularClosing
]

{ #category : 'private' }
CFPhysicsConservativeAdvancement class >> distanceBetweenShapeState: firstShapeState sweep: firstSweep andShapeState: secondShapeState sweep: secondSweep at: fraction [
	^ CFPhysicsGJK
		distanceBetweenShapeState: firstShapeState
		transform: (firstSweep transformAt: fraction)
		andShapeState: secondShapeState
		transform: (secondSweep transformAt: fraction)
]

{ #category : 'private' }
CFPhysicsConservativeAdvancement class >> dot: first with: second [
	^ (first x * second x) + (first y * second y)
]

{ #category : 'private' }
CFPhysicsConservativeAdvancement class >> separatedResultBetweenShapeState: firstShapeState sweep: firstSweep andShapeState: secondShapeState sweep: secondSweep iterations: iterationCount [
	^ CFPhysicsTimeOfImpactResult
		status: #separated
		fraction: 1.0
		distanceResult: (self
			distanceBetweenShapeState: firstShapeState
			sweep: firstSweep
			andShapeState: secondShapeState
			sweep: secondSweep
			at: 1.0)
		iterations: iterationCount
]
