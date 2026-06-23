Class {
	#name : 'CFRubberBandProjection',
	#superclass : 'Object',
	#instVars : [
		'minimum',
		'maximum',
		'dimension',
		'coefficient',
		'beforeOverscrollLimit',
		'afterOverscrollLimit'
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
	This uses the default dimension asymptote. Edge-specific projection uses
	derivativeForOverscroll:usingAsymptote:."

	^ self
		derivativeForOverscroll: anOverscrollDistance
		usingAsymptote: dimension
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
	"Answer the projected distance for a raw overscroll distance using the default dimension asymptote."

	^ self
		distanceForOverscroll: anOverscrollDistance
		usingAsymptote: dimension
]

{ #category : 'initialization' }
CFRubberBandProjection >> initialize [
	super initialize.
	minimum := 0.
	maximum := 0.
	dimension := 1.
	coefficient := self class defaultCoefficient.
	beforeOverscrollLimit := nil.
	afterOverscrollLimit := nil
]

{ #category : 'math' }
CFRubberBandProjection >> inverseDistanceForProjectedOverscroll: aProjectedOverscrollDistance [
	"Recover raw overscroll distance from a projected overscroll distance using the default dimension asymptote."

	^ self
		inverseDistanceForProjectedOverscroll: aProjectedOverscrollDistance
		usingAsymptote: dimension
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
	"Answer the unsigned distance outside the valid range after applying any configured overscroll limit.
	Answer zero when the offset is in bounds."

	^ self overscrollDistanceForLimitedOffset: (self limitedOffsetFor: anOffset)
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

	^ self projectLimitedOffset: (self limitedOffsetFor: anOffset)
]

{ #category : 'velocity' }
CFRubberBandProjection >> projectedVelocityFor: aVelocity at: anOffset [
	"Answer velocity mapped into projected space at the supplied logical offset."

	^ aVelocity * (self velocityScaleAt: anOffset)
]

{ #category : 'overscroll' }
CFRubberBandProjection >> projectedOverscrollDistanceFor: anOffset [
	"Answer the unsigned projected distance from the nearest bound using the relevant edge asymptote."

	| limitedOffset |
	limitedOffset := self limitedOffsetFor: anOffset.
	limitedOffset < minimum
		ifTrue: [ ^ self
			distanceForOverscroll: minimum - limitedOffset
			usingAsymptote: self beforeOverscrollAsymptote ].
	limitedOffset > maximum
		ifTrue: [ ^ self
			distanceForOverscroll: limitedOffset - maximum
			usingAsymptote: self afterOverscrollAsymptote ].
	^ 0
]

{ #category : 'overscroll' }
CFRubberBandProjection >> signedOverscrollDistanceFor: anOffset [
	"Answer negative overscroll below minimum, positive overscroll above maximum,
	or zero when the offset is in bounds, after applying any configured overscroll limit."

	^ self signedOverscrollDistanceForLimitedOffset: (self limitedOffsetFor: anOffset)
]

{ #category : 'overscroll' }
CFRubberBandProjection >> signedProjectedOverscrollDistanceFor: anOffset [
	| limitedOffset |
	limitedOffset := self limitedOffsetFor: anOffset.
	limitedOffset < minimum
		ifTrue: [ ^ (self
			distanceForOverscroll: minimum - limitedOffset
			usingAsymptote: self beforeOverscrollAsymptote) negated ].
	limitedOffset > maximum
		ifTrue: [ ^ self
			distanceForOverscroll: limitedOffset - maximum
			usingAsymptote: self afterOverscrollAsymptote ].
	^ 0
]

{ #category : 'validation' }
CFRubberBandProjection >> validateBounds [
	minimum > maximum
		ifTrue: [ self error: 'Minimum must not be greater than maximum.' ]
]

{ #category : 'velocity' }
CFRubberBandProjection >> velocityScaleAt: anOffset [
	"Answer the multiplier that maps logical velocity to projected velocity at the supplied logical offset."

	| limitedOffset |
	limitedOffset := self limitedOffsetFor: anOffset.
	limitedOffset < minimum
		ifTrue: [ ^ self
			derivativeForOverscroll: minimum - limitedOffset
			usingAsymptote: self beforeOverscrollAsymptote ].
	limitedOffset > maximum
		ifTrue: [ ^ self
			derivativeForOverscroll: limitedOffset - maximum
			usingAsymptote: self afterOverscrollAsymptote ].
	^ self derivativeForOverscroll: 0
]

{ #category : 'copying' }
CFRubberBandProjection >> withCoefficient: aCoefficient [
	^ (self class
		minimum: minimum
		maximum: maximum
		dimension: dimension
		coefficient: aCoefficient)
		beforeOverscrollLimit: beforeOverscrollLimit;
		afterOverscrollLimit: afterOverscrollLimit;
		yourself
]

{ #category : 'copying' }
CFRubberBandProjection >> withDimension: aDimension [
	^ (self class
		minimum: minimum
		maximum: maximum
		dimension: aDimension
		coefficient: coefficient)
		beforeOverscrollLimit: beforeOverscrollLimit;
		afterOverscrollLimit: afterOverscrollLimit;
		yourself
]

{ #category : 'copying' }
CFRubberBandProjection >> withMinimum: aMinimum maximum: aMaximum [
	^ (self class
		minimum: aMinimum
		maximum: aMaximum
		dimension: dimension
		coefficient: coefficient)
		beforeOverscrollLimit: beforeOverscrollLimit;
		afterOverscrollLimit: afterOverscrollLimit;
		yourself
]


{ #category : 'accessing' }
CFRubberBandProjection >> afterOverscrollLimit [
	"Answer the configured overscroll limit after the maximum bound.
	Nil means unlimited. Values strictly between zero and one are interpreted as a dimension proportion when resolved."

	^ afterOverscrollLimit
]

{ #category : 'accessing' }
CFRubberBandProjection >> afterOverscrollLimit: aNumberOrNil [
	aNumberOrNil ifNotNil: [ self validateOverscrollLimit: aNumberOrNil ].
	afterOverscrollLimit := aNumberOrNil
]

{ #category : 'accessing' }
CFRubberBandProjection >> beforeOverscrollLimit [
	"Answer the configured overscroll limit before the minimum bound.
	Nil means unlimited. Values strictly between zero and one are interpreted as a dimension proportion when resolved."

	^ beforeOverscrollLimit
]

{ #category : 'accessing' }
CFRubberBandProjection >> beforeOverscrollLimit: aNumberOrNil [
	aNumberOrNil ifNotNil: [ self validateOverscrollLimit: aNumberOrNil ].
	beforeOverscrollLimit := aNumberOrNil
]

{ #category : 'projection' }
CFRubberBandProjection >> limitedOffsetFor: anOffset [
	"Answer anOffset constrained to a safety logical limit derived from the configured projected overscroll asymptote.
	The public limit remains a projected/visible limit; this method only prevents infinite logical runaway."

	self validateBounds.

	anOffset < minimum
		ifTrue: [ ^ minimum - ((minimum - anOffset) min: self maximumBeforeLogicalOverscroll) ].
	anOffset > maximum
		ifTrue: [ ^ maximum + ((anOffset - maximum) min: self maximumAfterLogicalOverscroll) ].
	^ anOffset
]

{ #category : 'projection' }
CFRubberBandProjection >> overscrollLimit: aNumberOrNil [
	"Set the same overscroll limit before and after the bounds.
	Nil means unlimited.
	0 means zero pixels.
	Values strictly between 0 and 1 mean that proportion of the dimension.
	Values greater than or equal to 1 mean pixels."

	self
		beforeOverscrollLimit: aNumberOrNil;
		afterOverscrollLimit: aNumberOrNil
]

{ #category : 'private - overscroll limits' }
CFRubberBandProjection >> maximumAfterLogicalOverscroll [
	^ self logicalOverscrollLimitFor: afterOverscrollLimit
]

{ #category : 'private - overscroll limits' }
CFRubberBandProjection >> maximumBeforeLogicalOverscroll [
	^ self logicalOverscrollLimitFor: beforeOverscrollLimit
]

{ #category : 'private - overscroll limits' }
CFRubberBandProjection >> logicalOverscrollLimitFor: anOverscrollLimitOrNil [
	| asymptote safetyProjectedLimit |
	anOverscrollLimitOrNil ifNil: [ ^ Float infinity ].

	asymptote := self resolvedOverscrollLimitFor: anOverscrollLimitOrNil.
	asymptote <= 0
		ifTrue: [ ^ 0 ].

	safetyProjectedLimit := asymptote * self overscrollLogicalSafetyRatio.
	^ self
		inverseDistanceForProjectedOverscroll: safetyProjectedLimit
		usingAsymptote: asymptote
]

{ #category : 'private - overscroll limits' }
CFRubberBandProjection >> maximumRepresentableOverscrollLimit [
	^ (dimension - self overscrollLimitEpsilon) max: 0
]

{ #category : 'private - overscroll limits' }
CFRubberBandProjection >> overscrollDistanceForLimitedOffset: anOffset [
	anOffset < minimum
		ifTrue: [ ^ minimum - anOffset ].
	anOffset > maximum
		ifTrue: [ ^ anOffset - maximum ].
	^ 0
]

{ #category : 'private - overscroll limits' }
CFRubberBandProjection >> overscrollLimitEpsilon [
	^ 0.000001
]

{ #category : 'private - projection' }
CFRubberBandProjection >> projectLimitedOffset: anOffset [
	self validateBounds.

	anOffset < minimum
		ifTrue: [ ^ minimum - (self
			distanceForOverscroll: minimum - anOffset
			usingAsymptote: self beforeOverscrollAsymptote) ].
	anOffset > maximum
		ifTrue: [ ^ maximum + (self
			distanceForOverscroll: anOffset - maximum
			usingAsymptote: self afterOverscrollAsymptote) ].
	^ anOffset
]

{ #category : 'private - overscroll limits' }
CFRubberBandProjection >> resolvedOverscrollLimitFor: aNumber [
	self validateOverscrollLimit: aNumber.

	^ (aNumber > 0 and: [ aNumber < 1 ])
		ifTrue: [ dimension * aNumber ]
		ifFalse: [ aNumber ]
]

{ #category : 'private - overscroll limits' }
CFRubberBandProjection >> signedOverscrollDistanceForLimitedOffset: anOffset [
	anOffset < minimum
		ifTrue: [ ^ anOffset - minimum ].
	anOffset > maximum
		ifTrue: [ ^ anOffset - maximum ].
	^ 0
]

{ #category : 'validation' }
CFRubberBandProjection >> validateOverscrollLimit: aNumber [
	aNumber < 0
		ifTrue: [ self error: 'Overscroll limit must not be negative.' ]
]

{ #category : 'private - overscroll limits' }
CFRubberBandProjection >> afterOverscrollAsymptote [
	^ afterOverscrollLimit
		ifNil: [ dimension ]
		ifNotNil: [ self resolvedOverscrollLimitFor: afterOverscrollLimit ]
]

{ #category : 'private - overscroll limits' }
CFRubberBandProjection >> beforeOverscrollAsymptote [
	^ beforeOverscrollLimit
		ifNil: [ dimension ]
		ifNotNil: [ self resolvedOverscrollLimitFor: beforeOverscrollLimit ]
]

{ #category : 'private - math' }
CFRubberBandProjection >> derivativeForOverscroll: anOverscrollDistance usingAsymptote: anAsymptote [
	anOverscrollDistance < 0
		ifTrue: [ self error: 'Overscroll distance must not be negative.' ].
	anAsymptote <= 0
		ifTrue: [ ^ 0 ].

	^ (anAsymptote * anAsymptote * coefficient)
		/ ((anAsymptote + (coefficient * anOverscrollDistance))
			* (anAsymptote + (coefficient * anOverscrollDistance)))
]

{ #category : 'private - math' }
CFRubberBandProjection >> distanceForOverscroll: anOverscrollDistance usingAsymptote: anAsymptote [
	"Answer the projected overscroll distance for a raw overscroll distance and visible asymptote.
	A configured overscroll limit is this asymptote: the projected distance approaches it smoothly."

	anOverscrollDistance <= 0
		ifTrue: [ ^ 0 ].
	anAsymptote <= 0
		ifTrue: [ ^ 0 ].

	^ (anOverscrollDistance * anAsymptote * coefficient)
		/ (anAsymptote + (coefficient * anOverscrollDistance))
]

{ #category : 'private - math' }
CFRubberBandProjection >> inverseDistanceForProjectedOverscroll: aProjectedOverscrollDistance usingAsymptote: anAsymptote [
	"Recover raw overscroll distance from projected overscroll distance for the given asymptote."

	aProjectedOverscrollDistance < 0
		ifTrue: [ self error: 'Projected overscroll distance must not be negative.' ].
	anAsymptote <= 0
		ifTrue: [
			aProjectedOverscrollDistance = 0
				ifTrue: [ ^ 0 ].
			self error: 'Projected overscroll distance must be zero when the asymptote is zero.' ].
	aProjectedOverscrollDistance >= anAsymptote
		ifTrue: [ self error: 'Projected overscroll distance must be smaller than the asymptote.' ].

	^ (aProjectedOverscrollDistance * anAsymptote)
		/ (coefficient * (anAsymptote - aProjectedOverscrollDistance))
]

{ #category : 'private - overscroll limits' }
CFRubberBandProjection >> overscrollLogicalSafetyRatio [
	"Use the configured projected limit as the curve asymptote, but cap logical state just below it
	to prevent infinite logical runaway without turning the visible limit into a hard wall."

	^ 0.995
]

{ #category : 'movement' }
CFRubberBandProjection >> offset: anOffset movedBy: aDelta [
	"Answer the next logical offset for an input delta.
	When already overscrolled and moving back toward bounds, consume the delta in projected space
	so the user does not have to repay a huge invisible logical overscroll debt."

	| current raw projected nextProjected |
	self validateBounds.
	current := self limitedOffsetFor: anOffset.
	aDelta = 0
		ifTrue: [ ^ current ].

	current > maximum
		ifTrue: [
			aDelta > 0
				ifTrue: [ ^ self limitedOffsetFor: current + aDelta ].
			raw := current - maximum.
			projected := self
				distanceForOverscroll: raw
				usingAsymptote: self afterOverscrollAsymptote.
			nextProjected := projected + aDelta.
			nextProjected > 0
				ifTrue: [ ^ maximum + (self
					inverseDistanceForProjectedOverscroll: nextProjected
					usingAsymptote: self afterOverscrollAsymptote) ].
			^ maximum + nextProjected ].

	current < minimum
		ifTrue: [
			aDelta < 0
				ifTrue: [ ^ self limitedOffsetFor: current + aDelta ].
			raw := minimum - current.
			projected := self
				distanceForOverscroll: raw
				usingAsymptote: self beforeOverscrollAsymptote.
			nextProjected := projected - aDelta.
			nextProjected > 0
				ifTrue: [ ^ minimum - (self
					inverseDistanceForProjectedOverscroll: nextProjected
					usingAsymptote: self beforeOverscrollAsymptote) ].
			^ minimum - nextProjected ].

	^ self limitedOffsetFor: current + aDelta
]

