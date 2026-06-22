Class {
	#name : 'CFRubberBandProjection',
	#superclass : 'Object',
	#instVars : [
		'minimum',
		'maximum',
		'dimension',
		'coefficient'
	],
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'defaults' }
CFRubberBandProjection class >> defaultCoefficient [
	"Commonly reported UIScrollView-like coefficient."

	^ 0.55
]

{ #category : 'instance creation' }
CFRubberBandProjection class >> minimum: aMinimum maximum: aMaximum dimension: aDimension [
	^ self
		minimum: aMinimum
		maximum: aMaximum
		dimension: aDimension
		coefficient: self defaultCoefficient
]

{ #category : 'instance creation' }
CFRubberBandProjection class >> minimum: aMinimum maximum: aMaximum dimension: aDimension coefficient: aCoefficient [
	^ self new
		minimum: aMinimum
		maximum: aMaximum
		dimension: aDimension
		coefficient: aCoefficient;
		yourself
]

{ #category : 'projection' }
CFRubberBandProjection >> clamp: anOffset [
	"Answer the nearest in-bounds offset without projection."

	self validateBounds.

	anOffset < minimum
		ifTrue: [ ^ minimum ].
	anOffset > maximum
		ifTrue: [ ^ maximum ].
	^ anOffset
]

{ #category : 'accessing' }
CFRubberBandProjection >> coefficient [
	^ coefficient
]

{ #category : 'accessing' }
CFRubberBandProjection >> coefficient: aNumber [
	aNumber <= 0
		ifTrue: [ self error: 'Coefficient must be greater than zero.' ].
	coefficient := aNumber
]

{ #category : 'math' }
CFRubberBandProjection >> derivativeForOverscroll: anOverscrollDistance [
	"Answer the derivative of distanceForOverscroll: at the given raw overscroll distance.
	This is useful for mapping logical velocity into projected velocity."

	anOverscrollDistance < 0
		ifTrue: [ self error: 'Overscroll distance must not be negative.' ].

	^ (dimension * dimension * coefficient)
		/ ((dimension + (coefficient * anOverscrollDistance))
			* (dimension + (coefficient * anOverscrollDistance)))
]

{ #category : 'accessing' }
CFRubberBandProjection >> dimension [
	^ dimension
]

{ #category : 'accessing' }
CFRubberBandProjection >> dimension: aNumber [
	aNumber <= 0
		ifTrue: [ self error: 'Dimension must be greater than zero.' ].
	dimension := aNumber
]

{ #category : 'math' }
CFRubberBandProjection >> distanceForOverscroll: anOverscrollDistance [
	"Answer the projected distance for a raw overscroll distance.

	Formula:
		b = (x * d * c) / (d + c * x)

	x = raw overscroll distance
	d = projection dimension
	c = coefficient"

	anOverscrollDistance <= 0
		ifTrue: [ ^ 0 ].

	^ (anOverscrollDistance * dimension * coefficient)
		/ (dimension + (coefficient * anOverscrollDistance))
]

{ #category : 'initialization' }
CFRubberBandProjection >> initialize [
	super initialize.
	minimum := 0.
	maximum := 0.
	dimension := 1.
	coefficient := self class defaultCoefficient
]

{ #category : 'math' }
CFRubberBandProjection >> inverseDistanceForProjectedOverscroll: aProjectedOverscrollDistance [
	"Recover raw overscroll distance from a projected overscroll distance.

	Formula:
		x = (b * d) / (c * (d - b))

	The projected distance must be smaller than the dimension."

	aProjectedOverscrollDistance < 0
		ifTrue: [ self error: 'Projected overscroll distance must not be negative.' ].
	aProjectedOverscrollDistance >= dimension
		ifTrue: [ self error: 'Projected overscroll distance must be smaller than the dimension.' ].

	^ (aProjectedOverscrollDistance * dimension)
		/ (coefficient * (dimension - aProjectedOverscrollDistance))
]

{ #category : 'testing' }
CFRubberBandProjection >> isAboveMaximum: anOffset [
	^ anOffset > maximum
]

{ #category : 'testing' }
CFRubberBandProjection >> isBelowMinimum: anOffset [
	^ anOffset < minimum
]

{ #category : 'testing' }
CFRubberBandProjection >> isInBounds: anOffset [
	self validateBounds.
	^ anOffset >= minimum and: [ anOffset <= maximum ]
]

{ #category : 'testing' }
CFRubberBandProjection >> isOutOfBounds: anOffset [
	^ (self isInBounds: anOffset) not
]

{ #category : 'accessing' }
CFRubberBandProjection >> maximum [
	^ maximum
]

{ #category : 'accessing' }
CFRubberBandProjection >> maximum: aNumber [
	maximum := aNumber
]

{ #category : 'accessing' }
CFRubberBandProjection >> minimum [
	^ minimum
]

{ #category : 'accessing' }
CFRubberBandProjection >> minimum: aNumber [
	minimum := aNumber
]

{ #category : 'accessing' }
CFRubberBandProjection >> minimum: aMinimum maximum: aMaximum dimension: aDimension coefficient: aCoefficient [
	minimum := aMinimum.
	maximum := aMaximum.
	self validateBounds.
	self dimension: aDimension.
	self coefficient: aCoefficient
]

{ #category : 'projection' }
CFRubberBandProjection >> nearestBoundFor: anOffset [
	self validateBounds.

	anOffset < minimum
		ifTrue: [ ^ minimum ].
	anOffset > maximum
		ifTrue: [ ^ maximum ].
	^ anOffset
]

{ #category : 'overscroll' }
CFRubberBandProjection >> overscrollDistanceFor: anOffset [
	"Answer the unsigned distance outside the valid range.
	Answer zero when the offset is in bounds."

	self validateBounds.

	anOffset < minimum
		ifTrue: [ ^ minimum - anOffset ].
	anOffset > maximum
		ifTrue: [ ^ anOffset - maximum ].
	^ 0
]

{ #category : 'printing' }
CFRubberBandProjection >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPutAll: '(';
		nextPutAll: minimum asString;
		nextPutAll: ' <= offset <= ';
		nextPutAll: maximum asString;
		nextPutAll: ', dimension: ';
		nextPutAll: dimension asString;
		nextPutAll: ', coefficient: ';
		nextPutAll: coefficient asString;
		nextPut: $)
]

{ #category : 'projection' }
CFRubberBandProjection >> project: anOffset [
	"Answer the visible/projected offset for a logical offset."

	self validateBounds.

	anOffset < minimum
		ifTrue: [ ^ minimum - (self distanceForOverscroll: minimum - anOffset) ].
	anOffset > maximum
		ifTrue: [ ^ maximum + (self distanceForOverscroll: anOffset - maximum) ].
	^ anOffset
]

{ #category : 'velocity' }
CFRubberBandProjection >> projectedVelocityFor: aVelocity at: anOffset [
	"Answer velocity mapped into projected space at the supplied logical offset."

	^ aVelocity * (self velocityScaleAt: anOffset)
]

{ #category : 'overscroll' }
CFRubberBandProjection >> projectedOverscrollDistanceFor: anOffset [
	"Answer the unsigned projected distance from the nearest bound."

	^ self distanceForOverscroll: (self overscrollDistanceFor: anOffset)
]

{ #category : 'overscroll' }
CFRubberBandProjection >> signedOverscrollDistanceFor: anOffset [
	"Answer negative overscroll below minimum, positive overscroll above maximum,
	or zero when the offset is in bounds."

	self validateBounds.

	anOffset < minimum
		ifTrue: [ ^ anOffset - minimum ].
	anOffset > maximum
		ifTrue: [ ^ anOffset - maximum ].
	^ 0
]

{ #category : 'overscroll' }
CFRubberBandProjection >> signedProjectedOverscrollDistanceFor: anOffset [
	| signedDistance projectedDistance |
	signedDistance := self signedOverscrollDistanceFor: anOffset.
	signedDistance = 0
		ifTrue: [ ^ 0 ].

	projectedDistance := self distanceForOverscroll: signedDistance abs.
	^ signedDistance negative
		ifTrue: [ projectedDistance negated ]
		ifFalse: [ projectedDistance ]
]

{ #category : 'validation' }
CFRubberBandProjection >> validateBounds [
	minimum > maximum
		ifTrue: [ self error: 'Minimum must not be greater than maximum.' ]
]

{ #category : 'velocity' }
CFRubberBandProjection >> velocityScaleAt: anOffset [
	"Answer the multiplier that maps logical velocity to projected velocity at the supplied logical offset."

	^ self derivativeForOverscroll: (self overscrollDistanceFor: anOffset)
]

{ #category : 'copying' }
CFRubberBandProjection >> withCoefficient: aCoefficient [
	^ self class
		minimum: minimum
		maximum: maximum
		dimension: dimension
		coefficient: aCoefficient
]

{ #category : 'copying' }
CFRubberBandProjection >> withDimension: aDimension [
	^ self class
		minimum: minimum
		maximum: maximum
		dimension: aDimension
		coefficient: coefficient
]

{ #category : 'copying' }
CFRubberBandProjection >> withMinimum: aMinimum maximum: aMaximum [
	^ self class
		minimum: aMinimum
		maximum: aMaximum
		dimension: dimension
		coefficient: coefficient
]
