Class {
	#name : 'CFSmoothScrollableElementEventHandler',
	#superclass : 'BlScrollableElementEventHandler',
	#instVars : [
		'overscrollOffset',
		'overscrollReturnAnimation',
		'overscrollReturnTask',
		'overscrollPullDistance',
		'overscrollDirection'
	],
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'testing' }
CFSmoothScrollableElementEventHandler >> canScroll: aScrollableElement by: aDeltaPoint [
	aScrollableElement hasScrolledElement
		ifFalse: [ ^ false ].

	^ ((aDeltaPoint x isZero not)
		and: [ aScrollableElement computeHorizontalScrollRange > aScrollableElement computeHorizontalScrollExtent ])
		or: [ (aDeltaPoint y isZero not)
			and: [ aScrollableElement computeVerticalScrollRange > aScrollableElement computeVerticalScrollExtent ] ]
]

{ #category : 'mouse handlers' }
CFSmoothScrollableElementEventHandler >> gestureScrollEvent: anEvent [
	| aScrollableElement aDeltaPoint |
	aScrollableElement := anEvent currentTarget.
	aDeltaPoint := (anEvent vector * 400) negated.

	(self canScroll: aScrollableElement by: aDeltaPoint)
		ifFalse: [ ^ self ].

	aScrollableElement smoothScrollBy: aDeltaPoint.
	anEvent consumed: true
]

{ #category : 'animation' }
CFSmoothScrollableElementEventHandler >> animateOverscrollBackFor: aScrollableElement [
	| anAnimation aScrolledElement |
	aScrollableElement hasScrolledElement
		ifFalse: [ ^ self ].

	aScrolledElement := aScrollableElement scrolledElement.

	overscrollReturnAnimation ifNotNil: [
		overscrollReturnAnimation stopIfRunning.
		overscrollReturnAnimation := nil ].

	anAnimation := BlTransformAnimation translate: 0 @ 0.
	anAnimation
		absolute;
		duration: self overscrollReturnDuration;
		easing: self overscrollReturnEasing;
		onFinishedDo: [
			overscrollOffset := 0.
			overscrollPullDistance := 0.
			overscrollDirection := nil.
			overscrollReturnAnimation := nil ].

	overscrollReturnAnimation := anAnimation.
	aScrolledElement addAnimation: anAnimation
]

{ #category : 'animation' }
CFSmoothScrollableElementEventHandler >> scheduleOverscrollReturnFor: aScrollableElement [
	| aTask |
	aScrollableElement hasScrolledElement
		ifFalse: [ ^ self ].

	overscrollReturnTask ifNotNil: [
		overscrollReturnTask stop.
		overscrollReturnTask := nil ].

	aTask := BlDelayedTaskAction new
		delay: self overscrollReturnDelay;
		action: [
			self animateOverscrollBackFor: aScrollableElement.
			overscrollReturnTask := nil ];
		yourself.
	overscrollReturnTask := aTask.
	aScrollableElement scrolledElement enqueueTask: aTask
]

{ #category : 'animation' }
CFSmoothScrollableElementEventHandler >> stopOverscrollReturn [
	overscrollReturnTask ifNotNil: [
		overscrollReturnTask stop.
		overscrollReturnTask := nil ].
	overscrollReturnAnimation ifNotNil: [
		overscrollReturnAnimation stopIfRunning.
		overscrollReturnAnimation := nil ]
]

{ #category : 'private - overscroll' }
CFSmoothScrollableElementEventHandler >> log10: aNumber [
	"Use natural logarithms so this does not depend on a dialect-specific log10 selector."
	^ aNumber ln / 10.0 ln
]

{ #category : 'private - overscroll' }
CFSmoothScrollableElementEventHandler >> applyOverscrollOffset: aNumber to: aScrollableElement [
	aScrollableElement hasScrolledElement
		ifFalse: [ ^ self ].

	aScrollableElement scrolledElement
		transformDo: [ :aBuilder |
			aBuilder translateBy: 0 @ aNumber ]
]

{ #category : 'testing' }
CFSmoothScrollableElementEventHandler >> isAtBottom: aScrollableElement [
	^ aScrollableElement scrollPosition y <= aScrollableElement scrollMinimum y
]

{ #category : 'testing' }
CFSmoothScrollableElementEventHandler >> isAtTop: aScrollableElement [
	^ aScrollableElement scrollPosition y >= aScrollableElement scrollMaximum y
]

{ #category : 'initialization' }
CFSmoothScrollableElementEventHandler >> initialize [
	super initialize.

	overscrollOffset := 0.
	overscrollPullDistance := 0.
	overscrollDirection := nil.
	overscrollReturnAnimation := nil.
	overscrollReturnTask := nil
]

{ #category : 'mouse handlers' }
CFSmoothScrollableElementEventHandler >> mouseWheelEvent: anEvent [
	| aScrollableElement dY |
	"Follow GT's vertical infinite-list wheel handling: ignore horizontal wheel
	intent and rebuild the delta as a vertical-only smooth scroll. At an edge,
	apply a transient visual rubber-band transform to the scrolled content rather
	than changing the real scroll position beyond its layout-owned bounds."
	anEvent isTouch
		ifTrue: [ ^ self ].
	anEvent vector isZero
		ifTrue: [ ^ self ].
	anEvent isPrimarilyHorizontal
		ifTrue: [ ^ self ].

	aScrollableElement := anEvent currentTarget.
	dY := anEvent isScrollDown
		ifTrue: [ anEvent vector length negated ]
		ifFalse: [
			anEvent isScrollUp
				ifTrue: [ anEvent vector length ]
				ifFalse: [ 0 ] ].
	dY isZero
		ifTrue: [ ^ self ].

	((dY > 0 and: [ self isAtTop: aScrollableElement ])
		or: [ dY < 0 and: [ self isAtBottom: aScrollableElement ] ])
		ifTrue: [
			self rubberBand: dY on: aScrollableElement.
			anEvent consumed: true.
			^ self ].

	self resetOverscrollFor: aScrollableElement.
	aScrollableElement smoothScrollBy: 0 @ dY * 10.
	anEvent consumed: true
]

{ #category : 'private - overscroll' }
CFSmoothScrollableElementEventHandler >> rubberBandOffsetForPullDistance: aDistance extent: anExtent [
	"Map accumulated pull distance to visible rubber-band offset using the
	log10 curve used by common Apple rubber-band recreations. The extent is a
	reference distance for the curve, not a hard visual cap."
	| sign rawDistance visibleDistance |
	aDistance isZero
		ifTrue: [ ^ 0 ].

	sign := aDistance sign.
	rawDistance := aDistance abs.
	visibleDistance := anExtent * (self log10: ((rawDistance / anExtent) + 1.0)).

	^ sign * visibleDistance
]

{ #category : 'private - overscroll' }
CFSmoothScrollableElementEventHandler >> overscrollDirectionFor: dY [
	^ dY < 0
		ifTrue: [ -1 ]
		ifFalse: [ 1 ]
]

{ #category : 'accessing - overscroll' }
CFSmoothScrollableElementEventHandler >> overscrollInputScale [
	^ 28.0
]

{ #category : 'accessing - overscroll' }
CFSmoothScrollableElementEventHandler >> overscrollMaximumPullDistanceFactor [
	^ 8.0
]

{ #category : 'accessing - overscroll' }
CFSmoothScrollableElementEventHandler >> overscrollMaximumRubberBandExtent [
	^ 140.0
]

{ #category : 'accessing - overscroll' }
CFSmoothScrollableElementEventHandler >> overscrollMinimumRubberBandExtent [
	^ 60.0
]

{ #category : 'accessing - overscroll' }
CFSmoothScrollableElementEventHandler >> overscrollRubberBandExtentFor: aScrollableElement [
	| anExtent |
	anExtent := aScrollableElement extent y * self overscrollRubberBandExtentFraction.
	^ (anExtent max: self overscrollMinimumRubberBandExtent)
		min: self overscrollMaximumRubberBandExtent
]

{ #category : 'accessing - overscroll' }
CFSmoothScrollableElementEventHandler >> overscrollRubberBandExtentFraction [
	^ 0.18
]


{ #category : 'animation' }
CFSmoothScrollableElementEventHandler >> overscrollReturnDelay [
	^ 100 milliSeconds
]

{ #category : 'animation' }
CFSmoothScrollableElementEventHandler >> overscrollReturnDuration [
	^ 500 milliSeconds
]

{ #category : 'animation' }
CFSmoothScrollableElementEventHandler >> overscrollReturnEasing [
	^ BlEasing bounceOut
]



{ #category : 'private - overscroll' }
CFSmoothScrollableElementEventHandler >> resetOverscrollFor: aScrollableElement [
	(overscrollOffset isZero
		and: [ overscrollPullDistance isZero ])
		ifTrue: [ ^ self ].

	self stopOverscrollReturn.

	overscrollOffset := 0.
	overscrollPullDistance := 0.
	overscrollDirection := nil.
	self applyOverscrollOffset: 0 to: aScrollableElement
]

{ #category : 'private - overscroll' }
CFSmoothScrollableElementEventHandler >> rubberBand: dY on: aScrollableElement [
	| aDirection aRubberBandExtent aMaximumPullDistance |
	"During active wheel input, accumulate raw pull distance and convert it
	through a log10 rubber-band curve. The curve extent is derived from the
	scrollable height, so it governs the visible feel instead of a fixed pixel cap."
	aDirection := self overscrollDirectionFor: dY.
	overscrollDirection = aDirection
		ifFalse: [
			overscrollPullDistance := 0.
			overscrollDirection := aDirection ].

	self stopOverscrollReturn.

	aRubberBandExtent := self overscrollRubberBandExtentFor: aScrollableElement.
	aMaximumPullDistance := aRubberBandExtent * self overscrollMaximumPullDistanceFactor.
	overscrollPullDistance := (overscrollPullDistance + (dY abs * self overscrollInputScale))
		min: aMaximumPullDistance.
	overscrollOffset := aDirection *
		(self rubberBandOffsetForPullDistance: overscrollPullDistance extent: aRubberBandExtent).

	self applyOverscrollOffset: overscrollOffset to: aScrollableElement.
	self scheduleOverscrollReturnFor: aScrollableElement
]
