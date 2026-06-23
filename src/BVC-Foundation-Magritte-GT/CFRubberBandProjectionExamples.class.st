Class {
	#name : 'CFRubberBandProjectionExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'examples' }
CFRubberBandProjectionExamples >> appleLikeProjection [
	<gtExample>
	| projection |
	projection := CFRubberBandProjection
		minimum: 0
		maximum: 1000
		dimension: 500.

	self assert: projection minimum = 0.
	self assert: projection maximum = 1000.
	self assert: projection dimension = 500.
	self assert: projection coefficient = CFRubberBandProjection defaultCoefficient.

	^ projection
]

{ #category : 'examples' }
CFRubberBandProjectionExamples >> clampedInsideBoundsIsUnchanged [
	<gtExample>
	| projection |
	projection := self appleLikeProjection.

	self assert: (projection clamp: 250) = 250.
	self assert: (projection clamp: 0) = 0.
	self assert: (projection clamp: 1000) = 1000.

	^ projection
]

{ #category : 'examples' }
CFRubberBandProjectionExamples >> clampedOutsideBoundsUsesNearestBound [
	<gtExample>
	| projection |
	projection := self appleLikeProjection.

	self assert: (projection clamp: -100) = 0.
	self assert: (projection clamp: 1100) = 1000.

	^ projection
]

{ #category : 'examples' }
CFRubberBandProjectionExamples >> copiedWithCustomCoefficient [
	<gtExample>
	| original copy |
	original := self appleLikeProjection.
	copy := original withCoefficient: 0.35.

	self assert: copy minimum = original minimum.
	self assert: copy maximum = original maximum.
	self assert: copy dimension = original dimension.
	self assert: copy coefficient = 0.35.
	self assert: copy ~~ original.

	^ copy
]

{ #category : 'examples' }
CFRubberBandProjectionExamples >> copiedWithCustomDimension [
	<gtExample>
	| original copy |
	original := self appleLikeProjection.
	copy := original withDimension: 250.

	self assert: copy minimum = original minimum.
	self assert: copy maximum = original maximum.
	self assert: copy dimension = 250.
	self assert: copy coefficient = original coefficient.
	self assert: copy ~~ original.

	^ copy
]

{ #category : 'examples' }
CFRubberBandProjectionExamples >> copiedWithCustomBounds [
	<gtExample>
	| original copy |
	original := self appleLikeProjection.
	copy := original withMinimum: -100 maximum: 100.

	self assert: copy minimum = -100.
	self assert: copy maximum = 100.
	self assert: copy dimension = original dimension.
	self assert: copy coefficient = original coefficient.
	self assert: copy ~~ original.

	^ copy
]

{ #category : 'examples' }
CFRubberBandProjectionExamples >> customCoefficientProjection [
	<gtExample>
	| projection |
	projection := CFRubberBandProjection
		minimum: 0
		maximum: 1000
		dimension: 500
		coefficient: 0.35.

	self assert: projection coefficient = 0.35.
	self assert: (projection project: 250) = 250.

	^ projection
]

{ #category : 'examples' }
CFRubberBandProjectionExamples >> derivativeAtBoundaryEqualsCoefficient [
	<gtExample>
	| projection |
	projection := self appleLikeProjection.

	self assert: (projection derivativeForOverscroll: 0) = projection coefficient.
	self assert: (projection velocityScaleAt: 0) = projection coefficient.
	self assert: (projection velocityScaleAt: 1000) = projection coefficient.

	^ projection
]

{ #category : 'examples' }
CFRubberBandProjectionExamples >> distanceForOverscrollUsesProjectionFormula [
	<gtExample>
	| projection distance expected |
	projection := self appleLikeProjection.
	distance := projection distanceForOverscroll: 100.
	expected := (100 * 500 * 0.55) / (500 + (0.55 * 100)).

	self assert: distance = expected.
	self assert: distance > 0.
	self assert: distance < 100.

	^ projection
]

{ #category : 'examples' }
CFRubberBandProjectionExamples >> inverseDistanceRoundTrip [
	<gtExample>
	| projection raw projected recovered |
	projection := self appleLikeProjection.
	raw := 100.
	projected := projection distanceForOverscroll: raw.
	recovered := projection inverseDistanceForProjectedOverscroll: projected.

	self assert: (recovered - raw) abs < 0.000001.

	^ projection
]

{ #category : 'examples' }
CFRubberBandProjectionExamples >> nearestBoundAnswersOffsetInsideBounds [
	<gtExample>
	| projection |
	projection := self appleLikeProjection.

	self assert: (projection nearestBoundFor: 250) = 250.

	^ projection
]

{ #category : 'examples' }
CFRubberBandProjectionExamples >> nearestBoundAnswersMinimumBelowBounds [
	<gtExample>
	| projection |
	projection := self appleLikeProjection.

	self assert: (projection nearestBoundFor: -100) = 0.

	^ projection
]

{ #category : 'examples' }
CFRubberBandProjectionExamples >> nearestBoundAnswersMaximumAboveBounds [
	<gtExample>
	| projection |
	projection := self appleLikeProjection.

	self assert: (projection nearestBoundFor: 1100) = 1000.

	^ projection
]

{ #category : 'examples' }
CFRubberBandProjectionExamples >> projectAboveMaximum [
	<gtExample>
	| projection projected expected |
	projection := self appleLikeProjection.
	projected := projection project: 1100.
	expected := 1000 + (projection distanceForOverscroll: 100).

	self assert: projected = expected.
	self assert: projected > 1000.
	self assert: projected < 1100.

	^ projection
]

{ #category : 'examples' }
CFRubberBandProjectionExamples >> projectBelowMinimum [
	<gtExample>
	| projection projected expected |
	projection := self appleLikeProjection.
	projected := projection project: -100.
	expected := 0 - (projection distanceForOverscroll: 100).

	self assert: projected = expected.
	self assert: projected < 0.
	self assert: projected > -100.

	^ projection
]

{ #category : 'examples' }
CFRubberBandProjectionExamples >> projectInsideBoundsIsIdentity [
	<gtExample>
	| projection |
	projection := self appleLikeProjection.

	self assert: (projection project: 0) = 0.
	self assert: (projection project: 250) = 250.
	self assert: (projection project: 1000) = 1000.

	^ projection
]

{ #category : 'examples' }
CFRubberBandProjectionExamples >> projectedOverscrollDistances [
	<gtExample>
	| projection projected |
	projection := self appleLikeProjection.
	projected := projection distanceForOverscroll: 100.

	self assert: (projection projectedOverscrollDistanceFor: 250) = 0.
	self assert: (projection projectedOverscrollDistanceFor: -100) = projected.
	self assert: (projection projectedOverscrollDistanceFor: 1100) = projected.
	self assert: (projection signedProjectedOverscrollDistanceFor: -100) = projected negated.
	self assert: (projection signedProjectedOverscrollDistanceFor: 1100) = projected.

	^ projection
]

{ #category : 'examples' }
CFRubberBandProjectionExamples >> stateQueries [
	<gtExample>
	| projection |
	projection := self appleLikeProjection.

	self assert: (projection isInBounds: 250).
	self assert: (projection isOutOfBounds: -1).
	self assert: (projection isOutOfBounds: 1001).
	self assert: (projection isBelowMinimum: -1).
	self assert: (projection isAboveMaximum: 1001).

	^ projection
]

{ #category : 'examples' }
CFRubberBandProjectionExamples >> overscrollDistances [
	<gtExample>
	| projection |
	projection := self appleLikeProjection.

	self assert: (projection overscrollDistanceFor: 250) = 0.
	self assert: (projection overscrollDistanceFor: -100) = 100.
	self assert: (projection overscrollDistanceFor: 1100) = 100.
	self assert: (projection signedOverscrollDistanceFor: 250) = 0.
	self assert: (projection signedOverscrollDistanceFor: -100) = -100.
	self assert: (projection signedOverscrollDistanceFor: 1100) = 100.

	^ projection
]

{ #category : 'examples' }
CFRubberBandProjectionExamples >> projectedVelocityOutsideBoundsUsesDerivative [
	<gtExample>
	| projection scale velocity projectedVelocity |
	projection := self appleLikeProjection.
	scale := projection derivativeForOverscroll: 100.
	velocity := 40.
	projectedVelocity := projection projectedVelocityFor: velocity at: -100.

	self assert: (projection velocityScaleAt: -100) = scale.
	self assert: projectedVelocity = (velocity * scale).
	self assert: projectedVelocity < velocity.

	^ projection
]

{ #category : 'examples' }
CFRubberBandProjectionExamples >> validationRejectsInvalidCoefficient [
	<gtExample>
	| wasRaised |
	wasRaised := false.

	[ CFRubberBandProjection
		minimum: 0
		maximum: 1000
		dimension: 500
		coefficient: 0 ]
		on: Error
		do: [ :anError | wasRaised := true ].

	self assert: wasRaised.

	^ wasRaised
]

{ #category : 'examples' }
CFRubberBandProjectionExamples >> validationRejectsInvalidDimension [
	<gtExample>
	| wasRaised |
	wasRaised := false.

	[ CFRubberBandProjection
		minimum: 0
		maximum: 1000
		dimension: 0 ]
		on: Error
		do: [ :anError | wasRaised := true ].

	self assert: wasRaised.

	^ wasRaised
]

{ #category : 'examples' }
CFRubberBandProjectionExamples >> validationRejectsInvalidBounds [
	<gtExample>
	| wasRaised |
	wasRaised := false.

	[ CFRubberBandProjection
		minimum: 1000
		maximum: 0
		dimension: 500 ]
		on: Error
		do: [ :anError | wasRaised := true ].

	self assert: wasRaised.

	^ wasRaised
]

{ #category : 'examples' }
CFRubberBandProjectionExamples >> overscrollLimitInPixelsLimitsProjection [
	<gtExample>
	| projection limited projected |
	projection := self appleLikeProjection.
	projection overscrollLimit: 100.

	limited := projection limitedOffsetFor: 999999.
	projected := projection project: 999999.

	self assert: limited < 2000.
	self assert: projected = 1100.
	self assert: (projection projectedOverscrollDistanceFor: 999999) = 100.
	self assert: (projection overscrollDistanceFor: 999999) = (projection overscrollDistanceFor: limited).

	^ projection
]

{ #category : 'examples' }
CFRubberBandProjectionExamples >> overscrollLimitZeroClampsProjection [
	<gtExample>
	| projection |
	projection := self appleLikeProjection.
	projection overscrollLimit: 0.

	self assert: (projection limitedOffsetFor: -999999) = 0.
	self assert: (projection limitedOffsetFor: 999999) = 1000.
	self assert: (projection project: -999999) = 0.
	self assert: (projection project: 999999) = 1000.

	^ projection
]

{ #category : 'examples' }
CFRubberBandProjectionExamples >> overscrollLimitFractionUsesCurrentDimension [
	<gtExample>
	| projection projected |
	projection := self appleLikeProjection.
	projection overscrollLimit: 1 / 4.
	projected := projection project: 999999.

	self assert: projected = 1125.

	projection dimension: 800.
	projected := projection project: 999999.
	self assert: projected = 1200.

	^ projection
]

{ #category : 'examples' }
CFRubberBandProjectionExamples >> asymmetricOverscrollLimits [
	<gtExample>
	| projection beforeProjected afterProjected |
	projection := self appleLikeProjection.
	projection
		beforeOverscrollLimit: 50;
		afterOverscrollLimit: 100.

	beforeProjected := projection project: -999999.
	afterProjected := projection project: 999999.

	self assert: beforeProjected = -50.
	self assert: afterProjected = 1100.

	^ projection
]

{ #category : 'examples' }
CFRubberBandProjectionExamples >> validationRejectsNegativeOverscrollLimit [
	<gtExample>
	| projection wasRaised |
	projection := self appleLikeProjection.
	wasRaised := false.

	[ projection overscrollLimit: -1 ]
		on: Error
		do: [ :anError | wasRaised := true ].

	self assert: wasRaised.

	^ projection
]

{ #category : 'examples' }
CFRubberBandProjectionExamples >> overscrollLimitCapsProjectionWithoutLogicalRunaway [
	<gtExample>
	| projection first second third limited |
	projection := self appleLikeProjection.
	projection overscrollLimit: 100.

	first := projection project: 1100.
	second := projection project: 1300.
	third := projection project: 1700.
	limited := projection limitedOffsetFor: 999999.

	self assert: first > 1000.
	self assert: second > first.
	self assert: third = 1100.
	self assert: limited < 2000.

	^ projection
]

{ #category : 'examples' }
CFRubberBandProjectionExamples >> movingBackFromLimitedOverscrollConsumesProjectedDebt [
	<gtExample>
	| projection offset moved projectedBefore projectedAfter |
	projection := self appleLikeProjection.
	projection overscrollLimit: 100.
	offset := projection limitedOffsetFor: 999999.
	projectedBefore := projection project: offset.

	moved := projection offset: offset movedBy: -50.
	projectedAfter := projection project: moved.

	self assert: projectedAfter < projectedBefore.
	self assert: projectedAfter > 1000.
	self assert: (projectedBefore - projectedAfter) > 40.

	^ projection
]

{ #category : 'examples' }
CFRubberBandProjectionExamples >> movingFartherIntoLimitedOverscrollStillMovesGradually [
	<gtExample>
	| projection first second third |
	projection := self appleLikeProjection.
	projection overscrollLimit: 100.

	first := projection offset: 1000 movedBy: 100.
	second := projection offset: first movedBy: 100.
	third := projection offset: second movedBy: 100.

	self assert: (projection project: second) > (projection project: first).
	self assert: (projection project: third) > (projection project: second).
	self assert: (projection project: third) = 1100.

	^ projection
]

