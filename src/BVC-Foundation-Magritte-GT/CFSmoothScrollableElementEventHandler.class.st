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
CFSmoothScrollableElementEventHandler >> clampedOverscrollOffset: aNumber [
	^ (aNumber max: self overscrollMaximumOffset negated)
		min: self overscrollMaximumOffset
]

{ #category : 'private - overscroll' }
CFSmoothScrollableElementEventHandler >> applyOverscrollOffset: aNumber to: aScrollableElement [
	| aClampedOffset |
	aScrollableElement hasScrolledElement
		ifFalse: [ ^ self ].

	aClampedOffset := self clampedOverscrollOffset: aNumber.
	aScrollableElement scrolledElement
		transformDo: [ :aBuilder |
			aBuilder translateBy: 0 @ aClampedOffset ]
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
CFSmoothScrollableElementEventHandler >> rubberBandOffsetForPullDistance: aDistance [
	"Apple-style rubber band distance. UIScrollView-style rubber banding is commonly
	modelled as: b = (1 - (1 / (((x * c) / d) + 1))) * d.
	x is the real pull distance beyond the edge, c is the rubber-band constant, and
	d is the asymptotic maximum visible offset. Foundation uses d = 100px so the
	visual overshoot can never exceed 100px."
	| x c d |
	x := aDistance abs.
	c := self overscrollRubberBandConstant.
	d := self overscrollMaximumOffset.
	^ (1.0 - (1.0 / (((x * c) / d) + 1.0))) * d
]

{ #category : 'private - overscroll' }
CFSmoothScrollableElementEventHandler >> overscrollDirectionFor: dY [
	^ dY < 0
		ifTrue: [ -1 ]
		ifFalse: [ 1 ]
]

{ #category : 'accessing - overscroll' }
CFSmoothScrollableElementEventHandler >> overscrollMaximumOffset [
	^ 100.0
]

{ #category : 'accessing - overscroll' }
CFSmoothScrollableElementEventHandler >> overscrollInputScale [
	^ 28.0
]

{ #category : 'accessing - overscroll' }
CFSmoothScrollableElementEventHandler >> overscrollRubberBandConstant [
	^ 0.55
]


{ #category : 'animation' }
CFSmoothScrollableElementEventHandler >> overscrollReturnDelay [
	^ 100 milliSeconds
]

{ #category : 'animation' }
CFSmoothScrollableElementEventHandler >> overscrollReturnDuration [
	^ 220 milliSeconds
]

{ #category : 'animation' }
CFSmoothScrollableElementEventHandler >> overscrollReturnEasing [
	^ BlDecelerateInterpolator factor: 1.2
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
	| aDirection aVisibleDistance |
	"During active wheel input, accumulate the real pull distance and convert it
	through the Apple-style rubber-band curve. Do not start the return animation
	immediately; restart a short delayed return task instead, so repeated wheel
	events feel like one continuous elastic pull."
	aDirection := self overscrollDirectionFor: dY.
	overscrollDirection = aDirection
		ifFalse: [
			overscrollPullDistance := 0.
			overscrollDirection := aDirection ].

	self stopOverscrollReturn.

	overscrollPullDistance := overscrollPullDistance
		+ (dY abs * self overscrollInputScale).
	aVisibleDistance := self rubberBandOffsetForPullDistance: overscrollPullDistance.
	overscrollOffset := self clampedOverscrollOffset: aDirection * aVisibleDistance.

	self applyOverscrollOffset: overscrollOffset to: aScrollableElement.
	self scheduleOverscrollReturnFor: aScrollableElement
]
