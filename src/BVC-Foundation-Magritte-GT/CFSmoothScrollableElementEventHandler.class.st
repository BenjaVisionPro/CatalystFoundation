Class {
	#name : 'CFSmoothScrollableElementEventHandler',
	#superclass : 'BlScrollableElementEventHandler',
	#instVars : [
		'overscrollPullDistance',
		'overscrollReturnAnimation',
		'overscrollReturnTask'
	],
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'initialization' }
CFSmoothScrollableElementEventHandler >> initialize [
	super initialize.

	overscrollPullDistance := 0.
	overscrollReturnAnimation := nil.
	overscrollReturnTask := nil
]

{ #category : 'mouse handlers' }
CFSmoothScrollableElementEventHandler >> mouseWheelEvent: anEvent [
	| dY |
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

	dY := anEvent isScrollDown
		ifTrue: [ anEvent vector length negated * 10 ]
		ifFalse: [
			anEvent isScrollUp
				ifTrue: [ anEvent vector length * 10 ]
				ifFalse: [ 0 ] ].

	(self handleVerticalScrollDelta: dY on: anEvent currentTarget)
		ifTrue: [ anEvent consumed: true ]
]

{ #category : 'mouse handlers' }
CFSmoothScrollableElementEventHandler >> gestureScrollEvent: anEvent [
	| aVector dY |
	aVector := anEvent vector.
	aVector isZero
		ifTrue: [ ^ self ].
	(aVector x abs > aVector y abs)
		ifTrue: [ ^ self ].

	"Keep the default BlScrollableElement gesture scale/sign, but constrain it to
	the vertical axis and send it through the same edge/rubber-band path as wheel
	input."
	dY := aVector y * 400 negated.

	(self handleVerticalScrollDelta: dY on: anEvent currentTarget)
		ifTrue: [ anEvent consumed: true ]
]

{ #category : 'mouse handlers' }
CFSmoothScrollableElementEventHandler >> gestureScrollEndEvent: anEvent [
	"Gesture scrolling has an explicit end event, so return immediately instead
	of waiting for the wheel-idle fallback delay."
	self returnOverscrollNowFor: anEvent currentTarget
]

{ #category : 'private - scrolling' }
CFSmoothScrollableElementEventHandler >> handleVerticalScrollDelta: dY on: aScrollableElement [
	| aConsumedDelta anOverscrollDelta |
	dY isZero
		ifTrue: [ ^ false ].
	aScrollableElement hasScrolledElement
		ifFalse: [ ^ false ].

	aConsumedDelta := self
		consumableVerticalDeltaFor: dY
		on: aScrollableElement.
	anOverscrollDelta := dY - aConsumedDelta.

	anOverscrollDelta isZero
		ifFalse: [
			"Large/flick deltas can cross an edge in a single event. Consume only the
			in-range part as real scroll, then send the leftover through the same
			log10 rubber-band path as direct edge input."
			self resetOverscrollFor: aScrollableElement.
			aConsumedDelta isZero
				ifFalse: [ aScrollableElement scrollVerticallyBy: aConsumedDelta ].
			self rubberBand: anOverscrollDelta on: aScrollableElement.
			^ true ].

	self resetOverscrollFor: aScrollableElement.
	aScrollableElement smoothScrollBy: 0 @ dY.
	^ true
]

{ #category : 'private - scrolling' }
CFSmoothScrollableElementEventHandler >> consumableVerticalDeltaFor: dY on: aScrollableElement [
	| aCurrentY aMinimumY aMaximumY |
	aCurrentY := aScrollableElement scrollPosition y.
	aMinimumY := aScrollableElement scrollMinimum y.
	aMaximumY := aScrollableElement scrollMaximum y.

	dY > 0
		ifTrue: [ ^ dY min: aMaximumY - aCurrentY ].
	dY < 0
		ifTrue: [ ^ dY max: aMinimumY - aCurrentY ].

	^ 0
]

{ #category : 'private - overscroll' }
CFSmoothScrollableElementEventHandler >> rubberBandOffsetForPullDistance: aDistance [
	"Map accumulated attempted overscroll to visible rubber-band offset. The
	visible distance grows with log10 of the pull distance, so each additional
	unit of input has less visual effect than the previous one."
	| sign |
	aDistance isZero
		ifTrue: [ ^ 0 ].

	sign := aDistance sign.
	^ sign * self overscrollCurveScale * (self log10: aDistance abs + 1.0)
]

{ #category : 'accessing - overscroll' }
CFSmoothScrollableElementEventHandler >> overscrollCurveScale [
	^ 32.0
]

{ #category : 'private - overscroll' }
CFSmoothScrollableElementEventHandler >> rubberBand: dY on: aScrollableElement [
	"During active edge input, accumulate the raw attempted scroll distance and
	map it through a log10 curve. There is intentionally no hard overscroll cap;
	the curve itself makes extra pull distance produce progressively smaller
	visual movement."
	self stopOverscrollReturn.

	overscrollPullDistance := overscrollPullDistance + dY.
	self
		applyOverscrollOffset: (self rubberBandOffsetForPullDistance: overscrollPullDistance)
		to: aScrollableElement.
	self scheduleOverscrollReturnFor: aScrollableElement
]

{ #category : 'private - overscroll' }
CFSmoothScrollableElementEventHandler >> resetOverscrollFor: aScrollableElement [
	overscrollPullDistance isZero
		ifTrue: [ ^ self ].

	self stopOverscrollReturn.

	overscrollPullDistance := 0.
	self applyOverscrollOffset: 0 to: aScrollableElement
]

{ #category : 'animation' }
CFSmoothScrollableElementEventHandler >> returnOverscrollNowFor: aScrollableElement [
	overscrollPullDistance isZero
		ifTrue: [ ^ self ].

	overscrollReturnTask ifNotNil: [
		overscrollReturnTask stop.
		overscrollReturnTask := nil ].
	self animateOverscrollBackFor: aScrollableElement
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
			overscrollPullDistance := 0.
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


