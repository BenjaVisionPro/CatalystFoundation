Class {
	#name : 'CFRubberBandProjectionPlane',
	#superclass : 'Object',
	#instVars : [
		'horizontal',
		'vertical'
	],
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'instance creation' }
CFRubberBandProjectionPlane class >> horizontal [
	^ self new
		horizontal;
		yourself
]

{ #category : 'instance creation' }
CFRubberBandProjectionPlane class >> plane [
	^ self new
		horizontal;
		vertical;
		yourself
]

{ #category : 'instance creation' }
CFRubberBandProjectionPlane class >> vertical [
	^ self new
		vertical;
		yourself
]

{ #category : 'projection' }
CFRubberBandProjectionPlane >> clamp: aPoint [
	^ (self clampX: aPoint x) @ (self clampY: aPoint y)
]

{ #category : 'private - projection' }
CFRubberBandProjectionPlane >> clampX: aNumber [
	^ horizontal
		ifNil: [ aNumber ]
		ifNotNil: [ horizontal clamp: aNumber ]
]

{ #category : 'private - projection' }
CFRubberBandProjectionPlane >> clampY: aNumber [
	^ vertical
		ifNil: [ aNumber ]
		ifNotNil: [ vertical clamp: aNumber ]
]

{ #category : 'testing' }
CFRubberBandProjectionPlane >> hasHorizontal [
	^ horizontal notNil
]

{ #category : 'testing' }
CFRubberBandProjectionPlane >> hasVertical [
	^ vertical notNil
]

{ #category : 'accessing' }
CFRubberBandProjectionPlane >> horizontal [
	"Answer the horizontal axis projection, creating it on first use."

	horizontal ifNil: [ horizontal := CFRubberBandProjection new ].
	^ horizontal
]

{ #category : 'accessing' }
CFRubberBandProjectionPlane >> horizontal: aProjection [
	horizontal := aProjection
]

{ #category : 'testing' }
CFRubberBandProjectionPlane >> isEmpty [
	^ horizontal isNil and: [ vertical isNil ]
]

{ #category : 'testing' }
CFRubberBandProjectionPlane >> isInBounds: aPoint [
	^ (self isXInBounds: aPoint x) and: [ self isYInBounds: aPoint y ]
]

{ #category : 'testing' }
CFRubberBandProjectionPlane >> isOutOfBounds: aPoint [
	^ (self isInBounds: aPoint) not
]

{ #category : 'private - testing' }
CFRubberBandProjectionPlane >> isXInBounds: aNumber [
	^ horizontal
		ifNil: [ true ]
		ifNotNil: [ horizontal isInBounds: aNumber ]
]

{ #category : 'private - testing' }
CFRubberBandProjectionPlane >> isYInBounds: aNumber [
	^ vertical
		ifNil: [ true ]
		ifNotNil: [ vertical isInBounds: aNumber ]
]

{ #category : 'projection' }
CFRubberBandProjectionPlane >> nearestBoundFor: aPoint [
	^ (self nearestBoundXFor: aPoint x) @ (self nearestBoundYFor: aPoint y)
]

{ #category : 'private - projection' }
CFRubberBandProjectionPlane >> nearestBoundXFor: aNumber [
	^ horizontal
		ifNil: [ aNumber ]
		ifNotNil: [ horizontal nearestBoundFor: aNumber ]
]

{ #category : 'private - projection' }
CFRubberBandProjectionPlane >> nearestBoundYFor: aNumber [
	^ vertical
		ifNil: [ aNumber ]
		ifNotNil: [ vertical nearestBoundFor: aNumber ]
]

{ #category : 'overscroll' }
CFRubberBandProjectionPlane >> overscrollDistanceFor: aPoint [
	^ (self overscrollDistanceXFor: aPoint x) @ (self overscrollDistanceYFor: aPoint y)
]

{ #category : 'private - overscroll' }
CFRubberBandProjectionPlane >> overscrollDistanceXFor: aNumber [
	^ horizontal
		ifNil: [ 0 ]
		ifNotNil: [ horizontal overscrollDistanceFor: aNumber ]
]

{ #category : 'private - overscroll' }
CFRubberBandProjectionPlane >> overscrollDistanceYFor: aNumber [
	^ vertical
		ifNil: [ 0 ]
		ifNotNil: [ vertical overscrollDistanceFor: aNumber ]
]


{ #category : 'bounds' }
CFRubberBandProjectionPlane >> minimumPointWithFallback: aPoint [
	"Answer the natural minimum point using configured axis bounds when present.
	Unconfigured axes use the supplied fallback value. This is intentionally
	non-creating, so asking for bounds does not create projections."

	^ (self minimumXWithFallback: aPoint x)
		@ (self minimumYWithFallback: aPoint y)
]

{ #category : 'private - bounds' }
CFRubberBandProjectionPlane >> minimumXWithFallback: aNumber [
	^ horizontal
		ifNil: [ aNumber ]
		ifNotNil: [ horizontal minimum ]
]

{ #category : 'private - bounds' }
CFRubberBandProjectionPlane >> minimumYWithFallback: aNumber [
	^ vertical
		ifNil: [ aNumber ]
		ifNotNil: [ vertical minimum ]
]

{ #category : 'bounds' }
CFRubberBandProjectionPlane >> maximumPointWithFallback: aPoint [
	"Answer the natural maximum point using configured axis bounds when present.
	Unconfigured axes use the supplied fallback value. This is intentionally
	non-creating, so asking for bounds does not create projections."

	^ (self maximumXWithFallback: aPoint x)
		@ (self maximumYWithFallback: aPoint y)
]

{ #category : 'private - bounds' }
CFRubberBandProjectionPlane >> maximumXWithFallback: aNumber [
	^ horizontal
		ifNil: [ aNumber ]
		ifNotNil: [ horizontal maximum ]
]

{ #category : 'private - bounds' }
CFRubberBandProjectionPlane >> maximumYWithFallback: aNumber [
	^ vertical
		ifNil: [ aNumber ]
		ifNotNil: [ vertical maximum ]
]

{ #category : 'printing' }
CFRubberBandProjectionPlane >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPutAll: '(horizontal: ';
		nextPutAll: horizontal asString;
		nextPutAll: ', vertical: ';
		nextPutAll: vertical asString;
		nextPut: $)
]

{ #category : 'projection' }
CFRubberBandProjectionPlane >> project: aPoint [
	^ (self projectX: aPoint x) @ (self projectY: aPoint y)
]

{ #category : 'private - projection' }
CFRubberBandProjectionPlane >> projectX: aNumber [
	^ horizontal
		ifNil: [ aNumber ]
		ifNotNil: [ horizontal project: aNumber ]
]

{ #category : 'private - projection' }
CFRubberBandProjectionPlane >> projectY: aNumber [
	^ vertical
		ifNil: [ aNumber ]
		ifNotNil: [ vertical project: aNumber ]
]

{ #category : 'velocity' }
CFRubberBandProjectionPlane >> projectedVelocityFor: aVelocityPoint at: aLogicalPoint [
	| scale |
	scale := self velocityScaleAt: aLogicalPoint.
	^ (aVelocityPoint x * scale x) @ (aVelocityPoint y * scale y)
]

{ #category : 'overscroll' }
CFRubberBandProjectionPlane >> projectedOverscrollDistanceFor: aPoint [
	^ (self projectedOverscrollDistanceXFor: aPoint x) @ (self projectedOverscrollDistanceYFor: aPoint y)
]

{ #category : 'private - overscroll' }
CFRubberBandProjectionPlane >> projectedOverscrollDistanceXFor: aNumber [
	^ horizontal
		ifNil: [ 0 ]
		ifNotNil: [ horizontal projectedOverscrollDistanceFor: aNumber ]
]

{ #category : 'private - overscroll' }
CFRubberBandProjectionPlane >> projectedOverscrollDistanceYFor: aNumber [
	^ vertical
		ifNil: [ 0 ]
		ifNotNil: [ vertical projectedOverscrollDistanceFor: aNumber ]
]

{ #category : 'overscroll' }
CFRubberBandProjectionPlane >> signedOverscrollDistanceFor: aPoint [
	^ (self signedOverscrollDistanceXFor: aPoint x) @ (self signedOverscrollDistanceYFor: aPoint y)
]

{ #category : 'private - overscroll' }
CFRubberBandProjectionPlane >> signedOverscrollDistanceXFor: aNumber [
	^ horizontal
		ifNil: [ 0 ]
		ifNotNil: [ horizontal signedOverscrollDistanceFor: aNumber ]
]

{ #category : 'private - overscroll' }
CFRubberBandProjectionPlane >> signedOverscrollDistanceYFor: aNumber [
	^ vertical
		ifNil: [ 0 ]
		ifNotNil: [ vertical signedOverscrollDistanceFor: aNumber ]
]

{ #category : 'overscroll' }
CFRubberBandProjectionPlane >> signedProjectedOverscrollDistanceFor: aPoint [
	^ (self signedProjectedOverscrollDistanceXFor: aPoint x)
		@ (self signedProjectedOverscrollDistanceYFor: aPoint y)
]

{ #category : 'private - overscroll' }
CFRubberBandProjectionPlane >> signedProjectedOverscrollDistanceXFor: aNumber [
	^ horizontal
		ifNil: [ 0 ]
		ifNotNil: [ horizontal signedProjectedOverscrollDistanceFor: aNumber ]
]

{ #category : 'private - overscroll' }
CFRubberBandProjectionPlane >> signedProjectedOverscrollDistanceYFor: aNumber [
	^ vertical
		ifNil: [ 0 ]
		ifNotNil: [ vertical signedProjectedOverscrollDistanceFor: aNumber ]
]

{ #category : 'accessing' }
CFRubberBandProjectionPlane >> vertical [
	"Answer the vertical axis projection, creating it on first use."

	vertical ifNil: [ vertical := CFRubberBandProjection new ].
	^ vertical
]

{ #category : 'accessing' }
CFRubberBandProjectionPlane >> vertical: aProjection [
	vertical := aProjection
]

{ #category : 'velocity' }
CFRubberBandProjectionPlane >> velocityScaleAt: aPoint [
	^ (self velocityScaleXAt: aPoint x) @ (self velocityScaleYAt: aPoint y)
]

{ #category : 'private - velocity' }
CFRubberBandProjectionPlane >> velocityScaleXAt: aNumber [
	^ horizontal
		ifNil: [ 1 ]
		ifNotNil: [ horizontal velocityScaleAt: aNumber ]
]

{ #category : 'private - velocity' }
CFRubberBandProjectionPlane >> velocityScaleYAt: aNumber [
	^ vertical
		ifNil: [ 1 ]
		ifNotNil: [ vertical velocityScaleAt: aNumber ]
]

{ #category : 'projection' }
CFRubberBandProjectionPlane >> limitedPointFor: aPoint [
	"Answer aPoint constrained to configured axis overscroll limits.
	Unconfigured axes pass through unchanged."

	^ (self limitedXFor: aPoint x) @ (self limitedYFor: aPoint y)
]

{ #category : 'private - projection' }
CFRubberBandProjectionPlane >> limitedXFor: aNumber [
	^ horizontal
		ifNil: [ aNumber ]
		ifNotNil: [ horizontal limitedOffsetFor: aNumber ]
]

{ #category : 'private - projection' }
CFRubberBandProjectionPlane >> limitedYFor: aNumber [
	^ vertical
		ifNil: [ aNumber ]
		ifNotNil: [ vertical limitedOffsetFor: aNumber ]
]

{ #category : 'overscroll limits' }
CFRubberBandProjectionPlane >> logicalOverscrollLimit [
	"Answer the raw overscroll distance permitted on each configured axis.
	Unconfigured axes answer zero."

	^ (self logicalOverscrollLimitX) @ (self logicalOverscrollLimitY)
]

{ #category : 'private - overscroll limits' }
CFRubberBandProjectionPlane >> logicalOverscrollLimitX [
	^ horizontal
		ifNil: [ 0 ]
		ifNotNil: [ horizontal logicalOverscrollLimit ]
]

{ #category : 'private - overscroll limits' }
CFRubberBandProjectionPlane >> logicalOverscrollLimitY [
	^ vertical
		ifNil: [ 0 ]
		ifNotNil: [ vertical logicalOverscrollLimit ]
]

{ #category : 'movement' }
CFRubberBandProjectionPlane >> point: aPoint movedBy: aDeltaPoint [
	"Answer the next logical point after applying aDeltaPoint through each configured axis.
	Unconfigured axes move raw. Configured axes apply projection-aware overscroll resistance."

	^ (self x: aPoint x movedBy: aDeltaPoint x)
		@ (self y: aPoint y movedBy: aDeltaPoint y)
]

{ #category : 'private - movement' }
CFRubberBandProjectionPlane >> x: aNumber movedBy: aDelta [
	^ horizontal
		ifNil: [ aNumber + aDelta ]
		ifNotNil: [ horizontal offset: aNumber movedBy: aDelta ]
]

{ #category : 'private - movement' }
CFRubberBandProjectionPlane >> y: aNumber movedBy: aDelta [
	^ vertical
		ifNil: [ aNumber + aDelta ]
		ifNotNil: [ vertical offset: aNumber movedBy: aDelta ]
]
