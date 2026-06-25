Class {
	#name : 'CFRubberBandProjection',
	#superclass : 'Object',
	#instVars : [
		'minimum',
		'maximum',
		'dimension',
		'coefficient',
		'beforeOverscrollLimit',
		'afterOverscrollLimit',
		'overscrollLimitRatio',
		'movementStep'
	],
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'defaults' }
CFRubberBandProjection class >> defaultCoefficient [
	"Commonly reported UIScrollView-like coefficient."

	^ 0.55
]

{ #category : 'defaults' }
CFRubberBandProjection class >> defaultMovementStep [
	"Maximum input delta integrated at once while moving farther into overscroll."

	^ 16.0
]

{ #category : 'defaults' }
CFRubberBandProjection class >> defaultOverscrollLimitRatio [
	"How close the stored logical value may get to a configured visual overscroll asymptote."

	^ 0.8
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
	afterOverscrollLimit := nil.
	overscrollLimitRatio := self class defaultOverscrollLimitRatio.
	movementStep := self class defaultMovementStep
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
	"Answer the unsigned projected distance from the nearest bound.
	A configured overscroll limit caps the projected distance; it does not replace
	the normal dimension-based curve."

	| limitedOffset |
	limitedOffset := self limitedOffsetFor: anOffset.
	limitedOffset < minimum
		ifTrue: [ ^ self
			projectedDistanceForOverscroll: minimum - limitedOffset
			limit: beforeOverscrollLimit ].
	limitedOffset > maximum
		ifTrue: [ ^ self
			projectedDistanceForOverscroll: limitedOffset - maximum
			limit: afterOverscrollLimit ].
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
			projectedDistanceForOverscroll: minimum - limitedOffset
			limit: beforeOverscrollLimit) negated ].
	limitedOffset > maximum
		ifTrue: [ ^ self
			projectedDistanceForOverscroll: limitedOffset - maximum
			limit: afterOverscrollLimit ].
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
			limit: beforeOverscrollLimit ].
	limitedOffset > maximum
		ifTrue: [ ^ self
			derivativeForOverscroll: limitedOffset - maximum
			limit: afterOverscrollLimit ].
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
		overscrollLimitRatio: overscrollLimitRatio;
		movementStep: movementStep;
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
		overscrollLimitRatio: overscrollLimitRatio;
		movementStep: movementStep;
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
		overscrollLimitRatio: overscrollLimitRatio;
		movementStep: movementStep;
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
	"Answer the finite raw overscroll allowed for a configured visible
	overscroll asymptote. The stored logical value stops at a configurable
	ratio of the asymptote so it cannot run away, while the projection itself
	still approaches the configured visible limit asymptotically."

	| asymptote projectedLimit |
	anOverscrollLimitOrNil ifNil: [ ^ Float infinity ].

	asymptote := self resolvedOverscrollLimitFor: anOverscrollLimitOrNil.
	asymptote <= 0
		ifTrue: [ ^ 0 ].

	projectedLimit := asymptote * overscrollLimitRatio.
	^ self
		inverseDistanceForProjectedOverscroll: projectedLimit
		usingAsymptote: asymptote
]


{ #category : 'private - overscroll limits' }
CFRubberBandProjection >> overscrollDistanceForLimitedOffset: anOffset [
	anOffset < minimum
		ifTrue: [ ^ minimum - anOffset ].
	anOffset > maximum
		ifTrue: [ ^ anOffset - maximum ].
	^ 0
]


{ #category : 'private - projection' }
CFRubberBandProjection >> projectLimitedOffset: anOffset [
	self validateBounds.

	anOffset < minimum
		ifTrue: [ ^ minimum - (self
			projectedDistanceForOverscroll: minimum - anOffset
			limit: beforeOverscrollLimit) ].
	anOffset > maximum
		ifTrue: [ ^ maximum + (self
			projectedDistanceForOverscroll: anOffset - maximum
			limit: afterOverscrollLimit) ].
	^ anOffset
]


{ #category : 'private - projection' }
CFRubberBandProjection >> projectedDistanceForOverscroll: anOverscrollDistance limit: anOverscrollLimitOrNil [
	"Answer the projected distance for a raw overscroll distance.
	A configured overscroll limit is the visual asymptote for that edge,
	not a hard min: cap."

	anOverscrollLimitOrNil ifNil: [
		^ self distanceForOverscroll: anOverscrollDistance ].

	^ self
		distanceForOverscroll: anOverscrollDistance
		usingAsymptote: (self resolvedOverscrollLimitFor: anOverscrollLimitOrNil)
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
	"Answer the projected overscroll distance for a raw overscroll distance and asymptote."

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


{ #category : 'overscroll limits' }
CFRubberBandProjection >> logicalOverscrollLimit [
	"Answer the largest raw overscroll distance configured for either side.
	Nil side limits answer Float infinity."

	^ self beforeLogicalOverscrollLimit max: self afterLogicalOverscrollLimit
]

{ #category : 'overscroll limits' }
CFRubberBandProjection >> afterLogicalOverscrollLimit [
	^ self maximumAfterLogicalOverscroll
]

{ #category : 'overscroll limits' }
CFRubberBandProjection >> beforeLogicalOverscrollLimit [
	^ self maximumBeforeLogicalOverscroll
]


{ #category : 'movement' }
CFRubberBandProjection >> offset: anOffset movedBy: aDelta [
	"Answer the next logical offset after applying aDelta.
	Movement inside bounds is raw. Movement farther into overscroll is
	integrated through the projection derivative so it slows progressively
	instead of jumping directly to the logical cap. Movement back toward the
	bounds is raw so the user does not have to repay invisible overscroll debt."

	| delta |
	delta := aDelta asFloat.
	delta isZero ifTrue: [ ^ self limitedOffsetFor: anOffset ].

	(delta > 0 and: [ anOffset < minimum ])
		ifTrue: [ ^ self overscrolledOffset: anOffset movedBackBy: delta ].
	(delta < 0 and: [ anOffset > maximum ])
		ifTrue: [ ^ self overscrolledOffset: anOffset movedBackBy: delta ].

	(anOffset <= maximum and: [ anOffset >= minimum ])
		ifTrue: [ ^ self offsetFromBounds: anOffset movedBy: delta ].

	^ self overscrolledOffset: anOffset movedFartherBy: delta
]



{ #category : 'private - movement' }
CFRubberBandProjection >> overscrolledOffset: anOffset movedBackBy: aDelta [
	| proposed remaining |
	proposed := anOffset + aDelta.
	(proposed between: minimum and: maximum)
		ifTrue: [ ^ proposed ].

	(anOffset < minimum and: [ proposed > maximum ]) ifTrue: [
		remaining := proposed - maximum.
		^ self overscrolledOffset: maximum movedFartherBy: remaining ].

	(anOffset > maximum and: [ proposed < minimum ]) ifTrue: [
		remaining := proposed - minimum.
		^ self overscrolledOffset: minimum movedFartherBy: remaining ].

	^ self limitedOffsetFor: proposed
]

{ #category : 'private - movement' }
CFRubberBandProjection >> offsetFromBounds: anOffset movedBy: aDelta [
	| proposed remaining |
	proposed := anOffset + aDelta.
	(proposed between: minimum and: maximum)
		ifTrue: [ ^ proposed ].

	proposed < minimum ifTrue: [
		remaining := proposed - minimum.
		^ self overscrolledOffset: minimum movedFartherBy: remaining ].

	remaining := proposed - maximum.
	^ self overscrolledOffset: maximum movedFartherBy: remaining
]

{ #category : 'private - movement' }
CFRubberBandProjection >> overscrolledOffset: anOffset movedFartherBy: aDelta [
	| remaining offset step |
	remaining := aDelta asFloat.
	offset := anOffset.

	[ remaining abs > 0 ] whileTrue: [
		step := remaining abs min: movementStep.
		step := remaining negative ifTrue: [ step negated ] ifFalse: [ step ].
		offset := self overscrolledOffset: offset movedFartherOneStepBy: step.
		remaining := remaining - step ].

	^ self limitedOffsetFor: offset
]

{ #category : 'private - movement' }
CFRubberBandProjection >> overscrolledOffset: anOffset movedFartherOneStepBy: aDelta [
	| overscroll scale next |
	(anOffset <= minimum and: [ aDelta < 0 ]) ifTrue: [
		overscroll := minimum - anOffset.
		scale := self derivativeForOverscroll: overscroll limit: beforeOverscrollLimit.
		next := anOffset + (aDelta * scale).
		^ self limitedOffsetFor: next ].

	(anOffset >= maximum and: [ aDelta > 0 ]) ifTrue: [
		overscroll := anOffset - maximum.
		scale := self derivativeForOverscroll: overscroll limit: afterOverscrollLimit.
		next := anOffset + (aDelta * scale).
		^ self limitedOffsetFor: next ].

	^ self limitedOffsetFor: anOffset + aDelta
]

{ #category : 'private - projection' }
CFRubberBandProjection >> derivativeForOverscroll: anOverscrollDistance limit: anOverscrollLimitOrNil [
	anOverscrollLimitOrNil ifNil: [
		^ self derivativeForOverscroll: anOverscrollDistance ].

	^ self
		derivativeForOverscroll: anOverscrollDistance
		usingAsymptote: (self resolvedOverscrollLimitFor: anOverscrollLimitOrNil)
]

{ #category : 'accessing' }
CFRubberBandProjection >> movementStep [
	^ movementStep
]

{ #category : 'accessing' }
CFRubberBandProjection >> movementStep: aNumber [
	aNumber <= 0 ifTrue: [ self error: 'Movement step must be greater than zero.' ].
	movementStep := aNumber
]

{ #category : 'accessing' }
CFRubberBandProjection >> overscrollLimitRatio [
	^ overscrollLimitRatio
]

{ #category : 'accessing' }
CFRubberBandProjection >> overscrollLimitRatio: aNumber [
	(aNumber <= 0 or: [ aNumber >= 1 ])
		ifTrue: [ self error: 'Overscroll limit ratio must be greater than zero and less than one.' ].
	overscrollLimitRatio := aNumber
]


{ #category : 'overscroll limits' }
CFRubberBandProjection >> beforeOverscrollStop [
	"Answer the logical offset at the before/minimum overscroll stop.
	Nil overscroll limits have no finite stop."

	beforeOverscrollLimit ifNil: [ ^ Float negativeInfinity ].
	^ minimum - self beforeLogicalOverscrollLimit
]

{ #category : 'overscroll limits' }
CFRubberBandProjection >> afterOverscrollStop [
	"Answer the logical offset at the after/maximum overscroll stop.
	Nil overscroll limits have no finite stop."

	afterOverscrollLimit ifNil: [ ^ Float infinity ].
	^ maximum + self afterLogicalOverscrollLimit
]

{ #category : 'testing' }
CFRubberBandProjection >> isAtBeforeOverscrollStop: anOffset [
	beforeOverscrollLimit ifNil: [ ^ false ].
	^ anOffset <= self beforeOverscrollStop
]

{ #category : 'testing' }
CFRubberBandProjection >> isAtAfterOverscrollStop: anOffset [
	afterOverscrollLimit ifNil: [ ^ false ].
	^ anOffset >= self afterOverscrollStop
]

{ #category : 'testing' }
CFRubberBandProjection >> isAtOverscrollStop: anOffset [
	^ (self isAtBeforeOverscrollStop: anOffset)
		or: [ self isAtAfterOverscrollStop: anOffset ]
]

{ #category : 'testing' }
CFRubberBandProjection >> isMovingFartherIntoOverscrollFrom: previousOffset to: currentOffset requestedDelta: aDelta [
	"Answer true when the requested movement is still pushing away from the nearest bound
	at an overscroll stop. This is used to start snapback immediately when momentum
	reaches the configured stop, while allowing movement back toward bounds."

	(aDelta < 0 and: [ self isAtBeforeOverscrollStop: currentOffset ])
		ifTrue: [ ^ true ].
	(aDelta > 0 and: [ self isAtAfterOverscrollStop: currentOffset ])
		ifTrue: [ ^ true ].
	^ false
]
