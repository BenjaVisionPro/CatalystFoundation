Class {
	#name : 'CFRubberBandMotionExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'examples' }
CFRubberBandMotionExamples >> boundsQueriesUseConfiguredAxes [
	<gtExample>
	| motion |
	motion := self verticalOnlyMotion.

	motion moveTo: 999999 @ 100.
	self assert: motion isInBounds.
	self assert: (motion isOutOfBounds) not.

	motion moveTo: 999999 @ 2200.
	self assert: (motion isInBounds) not.
	self assert: motion isOutOfBounds.

	^ motion
]

{ #category : 'examples' }
CFRubberBandMotionExamples >> configuredMotionProjectsBothAxes [
	<gtExample>
	| motion projected |
	motion := self twoAxisMotion.
	motion moveTo: 1200 @ 2200.

	projected := motion projectedPosition.

	self assert: projected x > 1000.
	self assert: projected x < 1200.
	self assert: projected y > 2000.
	self assert: projected y < 2200.

	^ motion
]

{ #category : 'examples' }
CFRubberBandMotionExamples >> horizontalAccessorCreatesPlaneAndHorizontalAxis [
	<gtExample>
	| motion horizontal |
	motion := CFRubberBandMotion new.

	horizontal := motion horizontal.

	self assert: motion hasProjectionPlane.
	self assert: motion projectionPlane hasHorizontal.
	self assert: (motion projectionPlane hasVertical) not.
	self assert: horizontal == motion projectionPlane horizontal.

	^ motion
]

{ #category : 'examples' }
CFRubberBandMotionExamples >> horizontalOnlyMotion [
	<gtExample>
	| motion |
	motion := CFRubberBandMotion new.
	motion horizontal
		minimum: 0;
		maximum: 1000;
		dimension: 500.

	self assert: motion hasProjectionPlane.
	self assert: motion projectionPlane hasHorizontal.
	self assert: (motion projectionPlane hasVertical) not.

	^ motion
]

{ #category : 'examples' }
CFRubberBandMotionExamples >> horizontalOnlyProjectsOnlyX [
	<gtExample>
	| motion projected |
	motion := self horizontalOnlyMotion.
	motion moveTo: 1200 @ 999999.

	projected := motion projectedPosition.

	self assert: projected x > 1000.
	self assert: projected x < 1200.
	self assert: projected y = 999999.

	^ motion
]

{ #category : 'examples' }
CFRubberBandMotionExamples >> moveByUpdatesLogicalPosition [
	<gtExample>
	| motion |
	motion := CFRubberBandMotion new.
	motion moveTo: 10 @ 20.
	motion moveBy: 5 @ -10.

	self assert: motion logicalPosition = (15 @ 10).

	^ motion
]

{ #category : 'examples' }
CFRubberBandMotionExamples >> newMotionIsNeutral [
	<gtExample>
	| motion |
	motion := CFRubberBandMotion new.

	self assert: (motion hasProjectionPlane) not.
	self assert: motion logicalPosition = (0 @ 0).
	self assert: motion logicalVelocity = (0 @ 0).
	self assert: motion projectedPosition = (0 @ 0).
	self assert: motion projectedVelocity = (0 @ 0).
	self assert: motion velocityScale = (1 @ 1).
	self assert: motion overscrollDistance = (0 @ 0).
	self assert: motion signedOverscrollDistance = (0 @ 0).
	self assert: motion projectedOverscrollDistance = (0 @ 0).
	self assert: motion signedProjectedOverscrollDistance = (0 @ 0).
	self assert: motion isInBounds.
	self assert: (motion isOutOfBounds) not.

	^ motion
]

{ #category : 'examples' }
CFRubberBandMotionExamples >> overscrollAnswersConfiguredAxesOnly [
	<gtExample>
	| motion |
	motion := self verticalOnlyMotion.
	motion moveTo: 999999 @ 2200.

	self assert: motion overscrollDistance = (0 @ 200).
	self assert: motion signedOverscrollDistance = (0 @ 200).
	self assert: motion projectedOverscrollDistance x = 0.
	self assert: motion projectedOverscrollDistance y > 0.
	self assert: motion signedProjectedOverscrollDistance x = 0.
	self assert: motion signedProjectedOverscrollDistance y > 0.

	^ motion
]

{ #category : 'examples' }
CFRubberBandMotionExamples >> projectedPositionDoesNotCreatePlane [
	<gtExample>
	| motion |
	motion := CFRubberBandMotion new.
	motion moveTo: 1200 @ 2200.

	self assert: motion projectedPosition = (1200 @ 2200).
	self assert: (motion hasProjectionPlane) not.

	^ motion
]

{ #category : 'examples' }
CFRubberBandMotionExamples >> projectedVelocityUsesConfiguredAxesOnly [
	<gtExample>
	| motion projectedVelocity |
	motion := self verticalOnlyMotion.
	motion
		moveTo: 100 @ 2200;
		logicalVelocity: 100 @ -50.

	projectedVelocity := motion projectedVelocity.

	self assert: projectedVelocity x = 100.
	self assert: projectedVelocity y > -50.
	self assert: projectedVelocity y < 0.

	^ motion
]

{ #category : 'examples' }
CFRubberBandMotionExamples >> projectionPlaneCanBeInjected [
	<gtExample>
	| motion plane |
	plane := CFRubberBandProjectionPlane vertical.
	plane vertical
		minimum: 0;
		maximum: 2000;
		dimension: 800.

	motion := CFRubberBandMotion new.
	motion projectionPlane: plane.
	motion moveTo: 999999 @ 2200.

	self assert: motion projectionPlane == plane.
	self assert: motion projectedPosition x = 999999.
	self assert: motion projectedPosition y > 2000.
	self assert: motion projectedPosition y < 2200.

	^ motion
]

{ #category : 'examples' }
CFRubberBandMotionExamples >> releaseTargetUsesConfiguredAxesOnly [
	<gtExample>
	| motion |
	motion := self verticalOnlyMotion.
	motion moveTo: 999999 @ 2200.

	self assert: motion releaseTargetPosition = (999999 @ 2000).

	^ motion
]

{ #category : 'examples' }
CFRubberBandMotionExamples >> snapToBoundsMovesLogicalPositionAndStopsVelocity [
	<gtExample>
	| motion |
	motion := self verticalOnlyMotion.
	motion
		moveTo: 999999 @ 2200;
		logicalVelocity: 4 @ 5;
		snapToBounds.

	self assert: motion logicalPosition = (999999 @ 2000).
	self assert: motion logicalVelocity = (0 @ 0).
	self assert: motion projectedPosition = (999999 @ 2000).

	^ motion
]

{ #category : 'examples' }
CFRubberBandMotionExamples >> twoAxisMotion [
	<gtExample>
	| motion |
	motion := CFRubberBandMotion new.
	motion horizontal
		minimum: 0;
		maximum: 1000;
		dimension: 500.
	motion vertical
		minimum: 0;
		maximum: 2000;
		dimension: 800.

	self assert: motion hasProjectionPlane.
	self assert: motion projectionPlane hasHorizontal.
	self assert: motion projectionPlane hasVertical.

	^ motion
]

{ #category : 'examples' }
CFRubberBandMotionExamples >> velocityCanBeUpdated [
	<gtExample>
	| motion |
	motion := CFRubberBandMotion new.
	motion logicalVelocity: 12 @ -8.

	self assert: motion logicalVelocity = (12 @ -8).
	self assert: motion projectedVelocity = (12 @ -8).

	^ motion
]

{ #category : 'examples' }
CFRubberBandMotionExamples >> velocityScalePassesThroughWithoutPlane [
	<gtExample>
	| motion |
	motion := CFRubberBandMotion new.
	motion moveTo: 999999 @ 999999.

	self assert: motion velocityScale = (1 @ 1).
	self assert: motion projectedVelocity = (0 @ 0).
	self assert: (motion hasProjectionPlane) not.

	^ motion
]

{ #category : 'examples' }
CFRubberBandMotionExamples >> verticalAccessorCreatesPlaneAndVerticalAxis [
	<gtExample>
	| motion vertical |
	motion := CFRubberBandMotion new.

	vertical := motion vertical.

	self assert: motion hasProjectionPlane.
	self assert: (motion projectionPlane hasHorizontal) not.
	self assert: motion projectionPlane hasVertical.
	self assert: vertical == motion projectionPlane vertical.

	^ motion
]

{ #category : 'examples' }
CFRubberBandMotionExamples >> verticalOnlyMotion [
	<gtExample>
	| motion |
	motion := CFRubberBandMotion new.
	motion vertical
		minimum: 0;
		maximum: 2000;
		dimension: 800.

	self assert: motion hasProjectionPlane.
	self assert: (motion projectionPlane hasHorizontal) not.
	self assert: motion projectionPlane hasVertical.

	^ motion
]

{ #category : 'examples' }
CFRubberBandMotionExamples >> verticalOnlyProjectsOnlyY [
	<gtExample>
	| motion projected |
	motion := self verticalOnlyMotion.
	motion moveTo: 999999 @ 2200.

	projected := motion projectedPosition.

	self assert: projected x = 999999.
	self assert: projected y > 2000.
	self assert: projected y < 2200.

	^ motion
]

{ #category : 'examples' }
CFRubberBandMotionExamples >> moveToStoresLimitedLogicalPosition [
	<gtExample>
	| motion expectedY |
	motion := self verticalOnlyMotion.
	motion vertical overscrollLimit: 100.
	expectedY := motion vertical limitedOffsetFor: 999999.

	motion moveTo: 999999 @ 999999.

	self assert: motion logicalPosition = (999999 @ expectedY).
	self assert: motion logicalPosition y < 3000.
	self assert: motion logicalPosition y > 2000.
	self assert: motion projectedPosition y = 2100.

	^ motion
]

{ #category : 'examples' }
CFRubberBandMotionExamples >> moveByBackFromLimitedOverscrollReturnsInProjectedSpace [
	<gtExample>
	| motion projectedBefore projectedAfter |
	motion := self verticalOnlyMotion.
	motion vertical overscrollLimit: 100.
	motion moveTo: 999999 @ 999999.
	projectedBefore := motion projectedPosition.

	motion moveBy: 0 @ -50.
	projectedAfter := motion projectedPosition.

	self assert: projectedAfter y < projectedBefore y.
	self assert: projectedAfter y > 2000.
	self assert: (projectedBefore y - projectedAfter y) > 40.

	^ motion
]

