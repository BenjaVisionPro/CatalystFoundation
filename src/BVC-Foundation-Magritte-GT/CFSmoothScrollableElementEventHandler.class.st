Class {
	#name : 'CFSmoothScrollableElementEventHandler',
	#superclass : 'BlScrollableElementEventHandler',
	#instVars : [
		'overscrollOffset',
		'overscrollReturnAnimation'
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
			overscrollReturnAnimation := nil ].

	overscrollReturnAnimation := anAnimation.
	aScrolledElement addAnimation: anAnimation
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
	overscrollReturnAnimation := nil
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
CFSmoothScrollableElementEventHandler >> overscrollDeltaFor: dY [
	| resistance |
	resistance := 1.0 / (1.0 + (overscrollOffset abs / self overscrollResistanceDistance)).
	^ dY * self overscrollScrollScale * self overscrollStrength * resistance
]

{ #category : 'accessing - overscroll' }
CFSmoothScrollableElementEventHandler >> overscrollMaximumOffset [
	^ 100.0
]

{ #category : 'accessing - overscroll' }
CFSmoothScrollableElementEventHandler >> overscrollResistanceDistance [
	^ 80.0
]

{ #category : 'animation' }
CFSmoothScrollableElementEventHandler >> overscrollReturnDuration [
	^ 220 milliSeconds
]

{ #category : 'animation' }
CFSmoothScrollableElementEventHandler >> overscrollReturnEasing [
	^ BlEasing linear
]

{ #category : 'accessing - overscroll' }
CFSmoothScrollableElementEventHandler >> overscrollScrollScale [
	^ 10.0
]

{ #category : 'accessing - overscroll' }
CFSmoothScrollableElementEventHandler >> overscrollStrength [
	^ 0.35
]

{ #category : 'private - overscroll' }
CFSmoothScrollableElementEventHandler >> resetOverscrollFor: aScrollableElement [
	overscrollOffset isZero
		ifTrue: [ ^ self ].

	overscrollReturnAnimation ifNotNil: [
		overscrollReturnAnimation stopIfRunning.
		overscrollReturnAnimation := nil ].

	overscrollOffset := 0.
	self applyOverscrollOffset: 0 to: aScrollableElement
]

{ #category : 'private - overscroll' }
CFSmoothScrollableElementEventHandler >> rubberBand: dY on: aScrollableElement [
	overscrollReturnAnimation ifNotNil: [
		overscrollReturnAnimation stopIfRunning.
		overscrollReturnAnimation := nil ].

	overscrollOffset := self clampedOverscrollOffset:
		overscrollOffset + (self overscrollDeltaFor: dY).
	self applyOverscrollOffset: overscrollOffset to: aScrollableElement.
	self animateOverscrollBackFor: aScrollableElement
]
