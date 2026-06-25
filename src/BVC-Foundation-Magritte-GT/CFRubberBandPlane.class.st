Class {
	#name : 'CFRubberBandPlane',
	#superclass : 'Object',
	#instVars : [
		'axes',
		'position',
		'state',
		'wantsSnapBack'
	],
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'instance creation' }
CFRubberBandPlane class >> horizontal [
	^ self new
		horizontal;
		yourself
]

{ #category : 'instance creation' }
CFRubberBandPlane class >> plane [
	^ self new
		horizontal;
		vertical;
		yourself
]

{ #category : 'instance creation' }
CFRubberBandPlane class >> vertical [
	^ self new
		vertical;
		yourself
]

{ #category : 'initialization' }
CFRubberBandPlane >> initialize [
	super initialize.
	axes := CFRubberBandProjectionPlane new.
	position := 0.0 @ 0.0.
	state := #idle.
	wantsSnapBack := false
]

{ #category : 'accessing' }
CFRubberBandPlane >> axes [
	^ axes
]

{ #category : 'accessing' }
CFRubberBandPlane >> position [
	^ position
]

{ #category : 'accessing' }
CFRubberBandPlane >> position: aPoint [
	position := self limitedPointFor: aPoint.
	^ self
]

{ #category : 'accessing' }
CFRubberBandPlane >> state [
	^ state
]

{ #category : 'accessing' }
CFRubberBandPlane >> state: aSymbol [
	state := aSymbol
]

{ #category : 'configuration' }
CFRubberBandPlane >> horizontal [
	^ axes horizontal
]

{ #category : 'configuration' }
CFRubberBandPlane >> horizontal: aProjection [
	axes horizontal: aProjection
]

{ #category : 'configuration' }
CFRubberBandPlane >> vertical [
	^ axes vertical
]

{ #category : 'configuration' }
CFRubberBandPlane >> vertical: aProjection [
	axes vertical: aProjection
]

{ #category : 'testing' }
CFRubberBandPlane >> hasHorizontal [
	^ axes hasHorizontal
]

{ #category : 'testing' }
CFRubberBandPlane >> hasVertical [
	^ axes hasVertical
]

{ #category : 'testing' }
CFRubberBandPlane >> isEmpty [
	^ axes isEmpty
]

{ #category : 'interaction' }
CFRubberBandPlane >> beginInteraction [
	state := #interacting.
	wantsSnapBack := false.
	^ self
]

{ #category : 'interaction' }
CFRubberBandPlane >> endInteraction [
	state := #idle.
	self isOverscrolled ifTrue: [ wantsSnapBack := true ].
	^ wantsSnapBack
]

{ #category : 'movement' }
CFRubberBandPlane >> jumpTo: aPoint [
	"Set the logical position directly, applying configured logical safety limits.
	This is the explicit non-interaction setter used for layout/debug/programmatic state."

	position := self limitedPointFor: aPoint.
	^ position
]

{ #category : 'movement' }
CFRubberBandPlane >> moveByUserInput: aDeltaPoint [
	"Move by user supplied input. This is the rubber-band path: movement farther
	into overscroll is resisted by the axes. If the movement reaches the configured
	overscroll stop while still trying to move farther out, request snapback."

	| previous |
	previous := position.
	position := axes point: position movedBy: aDeltaPoint.
	((self isOverscrolled)
		and: [ (self isAtOverscrollStop)
		and: [ axes
			isMovingFartherIntoOverscrollFrom: previous
			to: position
			requestedDelta: aDeltaPoint ] ])
		ifTrue: [ wantsSnapBack := true ].
	^ position
]

{ #category : 'movement' }
CFRubberBandPlane >> moveByMomentum: aDeltaPoint [
	^ self moveByUserInput: aDeltaPoint
]

{ #category : 'movement' }
CFRubberBandPlane >> moveBySnapBack: aDeltaPoint [
	"Move during snapback. Snapback is already a return animation; it must not be
	fed through user-input rubber resistance. Clamp only when the movement crosses
	the natural bound."

	| proposed minimum maximum x y |
	state := #snappingBack.
	proposed := position + aDeltaPoint.
	minimum := self minimumPointWithFallback: position.
	maximum := self maximumPointWithFallback: position.
	x := proposed x.
	y := proposed y.

	(position x < minimum x and: [ x > minimum x ]) ifTrue: [ x := minimum x ].
	(position x > maximum x and: [ x < maximum x ]) ifTrue: [ x := maximum x ].
	(position y < minimum y and: [ y > minimum y ]) ifTrue: [ y := minimum y ].
	(position y > maximum y and: [ y < maximum y ]) ifTrue: [ y := maximum y ].

	position := self limitedPointFor: x @ y.
	self isOverscrolled
		ifFalse: [
			state := #idle.
			wantsSnapBack := false ].
	^ position
]

{ #category : 'snapback' }
CFRubberBandPlane >> wantsSnapBack [
	^ wantsSnapBack
]

{ #category : 'snapback' }
CFRubberBandPlane >> requestSnapBack [
	wantsSnapBack := true
]

{ #category : 'snapback' }
CFRubberBandPlane >> clearSnapBackRequest [
	wantsSnapBack := false
]

{ #category : 'snapback' }
CFRubberBandPlane >> nearestBoundsPosition [
	^ axes nearestBoundFor: position
]

{ #category : 'testing' }
CFRubberBandPlane >> isOverscrolled [
	^ axes isOutOfBounds: position
]

{ #category : 'testing' }
CFRubberBandPlane >> isAtOverscrollStop [
	^ axes isAtOverscrollStop: position
]

{ #category : 'projection' }
CFRubberBandPlane >> projectedPosition [
	^ axes project: position
]

{ #category : 'projection' }
CFRubberBandPlane >> project: aPoint [
	^ axes project: aPoint
]

{ #category : 'projection' }
CFRubberBandPlane >> limitedPointFor: aPoint [
	^ axes limitedPointFor: aPoint
]

{ #category : 'projection' }
CFRubberBandPlane >> clamp: aPoint [
	^ axes clamp: aPoint
]

{ #category : 'projection' }
CFRubberBandPlane >> nearestBoundFor: aPoint [
	^ axes nearestBoundFor: aPoint
]

{ #category : 'bounds' }
CFRubberBandPlane >> minimumPointWithFallback: aPoint [
	^ axes minimumPointWithFallback: aPoint
]

{ #category : 'bounds' }
CFRubberBandPlane >> maximumPointWithFallback: aPoint [
	^ axes maximumPointWithFallback: aPoint
]

{ #category : 'overscroll' }
CFRubberBandPlane >> overscrollDistanceFor: aPoint [
	^ axes overscrollDistanceFor: aPoint
]

{ #category : 'overscroll' }
CFRubberBandPlane >> signedOverscrollDistanceFor: aPoint [
	^ axes signedOverscrollDistanceFor: aPoint
]

{ #category : 'overscroll' }
CFRubberBandPlane >> projectedOverscrollDistanceFor: aPoint [
	^ axes projectedOverscrollDistanceFor: aPoint
]

{ #category : 'overscroll' }
CFRubberBandPlane >> signedProjectedOverscrollDistanceFor: aPoint [
	^ axes signedProjectedOverscrollDistanceFor: aPoint
]

{ #category : 'overscroll limits' }
CFRubberBandPlane >> logicalOverscrollLimit [
	^ axes logicalOverscrollLimit
]

{ #category : 'testing' }
CFRubberBandPlane >> isAtOverscrollStop: aPoint [
	^ axes isAtOverscrollStop: aPoint
]

{ #category : 'testing' }
CFRubberBandPlane >> isMovingFartherIntoOverscrollFrom: previousPoint to: currentPoint requestedDelta: deltaPoint [
	^ axes
		isMovingFartherIntoOverscrollFrom: previousPoint
		to: currentPoint
		requestedDelta: deltaPoint
]

{ #category : 'velocity' }
CFRubberBandPlane >> velocityScaleAt: aPoint [
	^ axes velocityScaleAt: aPoint
]

{ #category : 'velocity' }
CFRubberBandPlane >> projectedVelocityFor: aVelocityPoint at: aPoint [
	^ axes projectedVelocityFor: aVelocityPoint at: aPoint
]

{ #category : 'printing' }
CFRubberBandPlane >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPutAll: '(position: ';
		nextPutAll: position asString;
		nextPutAll: ', state: ';
		nextPutAll: state asString;
		nextPutAll: ', wantsSnapBack: ';
		nextPutAll: wantsSnapBack asString;
		nextPut: $)
]
