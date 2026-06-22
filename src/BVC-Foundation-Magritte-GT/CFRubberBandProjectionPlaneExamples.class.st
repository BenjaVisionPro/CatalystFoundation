Class {
	#name : 'CFRubberBandProjectionPlaneExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'examples' }
CFRubberBandProjectionPlaneExamples >> configuredPlane [
	<gtExample>
	| plane |
	plane := CFRubberBandProjectionPlane plane.

	plane horizontal
		minimum: 0;
		maximum: 1000;
		dimension: 500.

	plane vertical
		minimum: 0;
		maximum: 2000;
		dimension: 800.

	self assert: plane hasHorizontal.
	self assert: plane hasVertical.
	self assert: plane isEmpty not.
	self assert: plane horizontal minimum = 0.
	self assert: plane horizontal maximum = 1000.
	self assert: plane vertical minimum = 0.
	self assert: plane vertical maximum = 2000.

	^ plane
]

{ #category : 'examples' }
CFRubberBandProjectionPlaneExamples >> configuredPlaneProjectsBothAxes [
	<gtExample>
	| plane projected expected |
	plane := self configuredPlane.
	projected := plane project: 1100 @ 2200.
	expected := (plane horizontal project: 1100) @ (plane vertical project: 2200).

	self assert: projected = expected.
	self assert: projected x > 1000.
	self assert: projected x < 1100.
	self assert: projected y > 2000.
	self assert: projected y < 2200.

	^ plane
]

{ #category : 'examples' }
CFRubberBandProjectionPlaneExamples >> configuredPlaneProjectsInsideBoundsAsIdentity [
	<gtExample>
	| plane |
	plane := self configuredPlane.

	self assert: (plane project: 250 @ 1200) = (250 @ 1200).

	^ plane
]

{ #category : 'examples' }
CFRubberBandProjectionPlaneExamples >> configuredPlaneVelocityMapsBothAxes [
	<gtExample>
	| plane scale velocity projectedVelocity |
	plane := self configuredPlane.
	scale := plane velocityScaleAt: 1100 @ 2200.
	velocity := 100 @ 200.
	projectedVelocity := plane projectedVelocityFor: velocity at: 1100 @ 2200.

	self assert: scale = ((plane horizontal velocityScaleAt: 1100) @ (plane vertical velocityScaleAt: 2200)).
	self assert: projectedVelocity = ((velocity x * scale x) @ (velocity y * scale y)).
	self assert: projectedVelocity x < velocity x.
	self assert: projectedVelocity y < velocity y.

	^ plane
]

{ #category : 'examples' }
CFRubberBandProjectionPlaneExamples >> horizontalAccessorCreatesHorizontalAxis [
	<gtExample>
	| plane horizontal |
	plane := CFRubberBandProjectionPlane new.

	self assert: plane hasHorizontal not.
	horizontal := plane horizontal.

	self assert: horizontal class = CFRubberBandProjection.
	self assert: plane hasHorizontal.
	self assert: plane hasVertical not.
	self assert: plane horizontal == horizontal.

	^ plane
]

{ #category : 'examples' }
CFRubberBandProjectionPlaneExamples >> horizontalClassCreatorCreatesOnlyHorizontalAxis [
	<gtExample>
	| plane |
	plane := CFRubberBandProjectionPlane horizontal.

	self assert: plane hasHorizontal.
	self assert: plane hasVertical not.

	^ plane
]

{ #category : 'examples' }
CFRubberBandProjectionPlaneExamples >> horizontalOnlyClampClampsOnlyX [
	<gtExample>
	| plane clamped |
	plane := self horizontalOnlyPlane.
	clamped := plane clamp: 1100 @ 999999.

	self assert: clamped = (1000 @ 999999).

	^ plane
]

{ #category : 'examples' }
CFRubberBandProjectionPlaneExamples >> horizontalOnlyNearestBoundAppliesOnlyToX [
	<gtExample>
	| plane nearest |
	plane := self horizontalOnlyPlane.
	nearest := plane nearestBoundFor: 1100 @ 999999.

	self assert: nearest = (1000 @ 999999).

	^ plane
]

{ #category : 'examples' }
CFRubberBandProjectionPlaneExamples >> horizontalOnlyPlane [
	<gtExample>
	| plane |
	plane := CFRubberBandProjectionPlane horizontal.

	plane horizontal
		minimum: 0;
		maximum: 1000;
		dimension: 500.

	self assert: plane hasHorizontal.
	self assert: plane hasVertical not.

	^ plane
]

{ #category : 'examples' }
CFRubberBandProjectionPlaneExamples >> horizontalOnlyProjectsOnlyX [
	<gtExample>
	| plane projected expectedX |
	plane := self horizontalOnlyPlane.
	projected := plane project: 1100 @ 999999.
	expectedX := plane horizontal project: 1100.

	self assert: projected = (expectedX @ 999999).
	self assert: projected x > 1000.
	self assert: projected x < 1100.

	^ plane
]

{ #category : 'examples' }
CFRubberBandProjectionPlaneExamples >> horizontalOnlyVelocityMapsOnlyX [
	<gtExample>
	| plane scale velocity projectedVelocity |
	plane := self horizontalOnlyPlane.
	scale := plane velocityScaleAt: 1100 @ 999999.
	velocity := 100 @ 200.
	projectedVelocity := plane projectedVelocityFor: velocity at: 1100 @ 999999.

	self assert: scale = ((plane horizontal velocityScaleAt: 1100) @ 1).
	self assert: projectedVelocity = ((velocity x * scale x) @ velocity y).

	^ plane
]

{ #category : 'examples' }
CFRubberBandProjectionPlaneExamples >> newPlaneHasNoAxes [
	<gtExample>
	| plane |
	plane := CFRubberBandProjectionPlane new.

	self assert: plane hasHorizontal not.
	self assert: plane hasVertical not.
	self assert: plane isEmpty.

	^ plane
]

{ #category : 'examples' }
CFRubberBandProjectionPlaneExamples >> planeClassCreatorCreatesBothAxes [
	<gtExample>
	| plane |
	plane := CFRubberBandProjectionPlane plane.

	self assert: plane hasHorizontal.
	self assert: plane hasVertical.
	self assert: plane isEmpty not.

	^ plane
]

{ #category : 'examples' }
CFRubberBandProjectionPlaneExamples >> projectDoesNotCreateAxes [
	<gtExample>
	| plane projected |
	plane := self newPlaneHasNoAxes.
	projected := plane project: 1100 @ 2200.

	self assert: projected = (1100 @ 2200).
	self assert: plane hasHorizontal not.
	self assert: plane hasVertical not.
	self assert: plane isEmpty.

	^ plane
]

{ #category : 'examples' }
CFRubberBandProjectionPlaneExamples >> settersCanClearAxes [
	<gtExample>
	| plane projected |
	plane := self configuredPlane.
	plane horizontal: nil.
	projected := plane project: 1100 @ 2200.

	self assert: plane hasHorizontal not.
	self assert: plane hasVertical.
	self assert: projected = (1100 @ (plane vertical project: 2200)).

	^ plane
]

{ #category : 'examples' }
CFRubberBandProjectionPlaneExamples >> unconfiguredAxesAreIgnoredByBoundsQueries [
	<gtExample>
	| plane |
	plane := self verticalOnlyPlane.

	self assert: (plane isInBounds: 999999 @ 1200).
	self assert: (plane isOutOfBounds: 999999 @ 2200).

	^ plane
]

{ #category : 'examples' }
CFRubberBandProjectionPlaneExamples >> verticalAccessorCreatesVerticalAxis [
	<gtExample>
	| plane vertical |
	plane := CFRubberBandProjectionPlane new.

	self assert: plane hasVertical not.
	vertical := plane vertical.

	self assert: vertical class = CFRubberBandProjection.
	self assert: plane hasVertical.
	self assert: plane hasHorizontal not.
	self assert: plane vertical == vertical.

	^ plane
]

{ #category : 'examples' }
CFRubberBandProjectionPlaneExamples >> verticalClassCreatorCreatesOnlyVerticalAxis [
	<gtExample>
	| plane |
	plane := CFRubberBandProjectionPlane vertical.

	self assert: plane hasVertical.
	self assert: plane hasHorizontal not.

	^ plane
]

{ #category : 'examples' }
CFRubberBandProjectionPlaneExamples >> verticalOnlyClampClampsOnlyY [
	<gtExample>
	| plane clamped |
	plane := self verticalOnlyPlane.
	clamped := plane clamp: 999999 @ 2200.

	self assert: clamped = (999999 @ 2000).

	^ plane
]

{ #category : 'examples' }
CFRubberBandProjectionPlaneExamples >> verticalOnlyNearestBoundAppliesOnlyToY [
	<gtExample>
	| plane nearest |
	plane := self verticalOnlyPlane.
	nearest := plane nearestBoundFor: 999999 @ 2200.

	self assert: nearest = (999999 @ 2000).

	^ plane
]

{ #category : 'examples' }
CFRubberBandProjectionPlaneExamples >> verticalOnlyOverscrollAnswersOnlyY [
	<gtExample>
	| plane projectedDistance |
	plane := self verticalOnlyPlane.
	projectedDistance := plane vertical distanceForOverscroll: 200.

	self assert: (plane overscrollDistanceFor: 999999 @ 2200) = (0 @ 200).
	self assert: (plane signedOverscrollDistanceFor: 999999 @ 2200) = (0 @ 200).
	self assert: (plane projectedOverscrollDistanceFor: 999999 @ 2200) = (0 @ projectedDistance).
	self assert: (plane signedProjectedOverscrollDistanceFor: 999999 @ 2200) = (0 @ projectedDistance).

	^ plane
]

{ #category : 'examples' }
CFRubberBandProjectionPlaneExamples >> verticalOnlyPlane [
	<gtExample>
	| plane |
	plane := CFRubberBandProjectionPlane vertical.

	plane vertical
		minimum: 0;
		maximum: 2000;
		dimension: 800.

	self assert: plane hasVertical.
	self assert: plane hasHorizontal not.

	^ plane
]

{ #category : 'examples' }
CFRubberBandProjectionPlaneExamples >> verticalOnlyProjectsOnlyY [
	<gtExample>
	| plane projected expectedY |
	plane := self verticalOnlyPlane.
	projected := plane project: 999999 @ 2200.
	expectedY := plane vertical project: 2200.

	self assert: projected = (999999 @ expectedY).
	self assert: projected y > 2000.
	self assert: projected y < 2200.

	^ plane
]

{ #category : 'examples' }
CFRubberBandProjectionPlaneExamples >> verticalOnlyVelocityMapsOnlyY [
	<gtExample>
	| plane scale velocity projectedVelocity |
	plane := self verticalOnlyPlane.
	scale := plane velocityScaleAt: 999999 @ 2200.
	velocity := 100 @ 200.
	projectedVelocity := plane projectedVelocityFor: velocity at: 999999 @ 2200.

	self assert: scale = (1 @ (plane vertical velocityScaleAt: 2200)).
	self assert: projectedVelocity = (velocity x @ (velocity y * scale y)).

	^ plane
]
