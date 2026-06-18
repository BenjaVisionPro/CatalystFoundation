Class {
	#name : 'CFSmoothScrollableElementEventHandler',
	#superclass : 'BlScrollableElementEventHandler',
	#instVars : [
		'logicalScrollY',
		'rubberBandState',
		'rubberBandOutAnimation',
		'rubberBandReturnAnimation'
	],
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'initialization' }
CFSmoothScrollableElementEventHandler >> initialize [
	super initialize.

	logicalScrollY := nil.
	rubberBandState := #normal.
	rubberBandOutAnimation := nil.
	rubberBandReturnAnimation := nil
]

{ #category : 'mouse handlers' }
CFSmoothScrollableElementEventHandler >> mouseWheelEvent: anEvent [
	| dY |
	"Follow GT's vertical infinite-list wheel handling: ignore horizontal wheel
	intent and rebuild the delta as a vertical-only scroll. Pixel-based wheel
	events already arrive in pixel units, so do not apply the line-wheel scale to
	trackpad input."
	anEvent isTouch
		ifTrue: [ ^ self ].
	anEvent vector isZero
		ifTrue: [ ^ self ].
	anEvent isPrimarilyHorizontal
		ifTrue: [ ^ self ].

	dY := anEvent isScrollDown
		ifTrue: [ anEvent vector length negated * (self wheelScrollScaleFor: anEvent) ]
		ifFalse: [
			anEvent isScrollUp
				ifTrue: [ anEvent vector length * (self wheelScrollScaleFor: anEvent) ]
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
	the vertical axis and send it through the same rubber-band state machine as
	wheel input."
	dY := aVector y * self gestureScrollScale negated.

	(self handleVerticalScrollDelta: dY on: anEvent currentTarget)
		ifTrue: [ anEvent consumed: true ]
]

{ #category : 'mouse handlers' }
CFSmoothScrollableElementEventHandler >> gestureScrollEndEvent: anEvent [
	"The closed rubber-band state machine releases itself. Gesture end is not used
	as a timing source, because wheel/trackpad end delivery is host-dependent and
	zero-distance end events may not be delivered to this handler."
	self rubberBandState = #normal
		ifFalse: [ anEvent consumed: true ]
]

{ #category : 'private - scrolling' }
CFSmoothScrollableElementEventHandler >> handleVerticalScrollDelta: dY on: aScrollableElement [
	| oldY newY |
	dY isZero
		ifTrue: [ ^ false ].
	aScrollableElement hasScrolledElement
		ifFalse: [ ^ false ].

	self rubberBandState = #rubberBandOut
		ifTrue: [ ^ true ].

	self rubberBandState = #snapBack
		ifTrue: [ self interruptRubberBandSnapBackOn: aScrollableElement ].

	self ensureLogicalScrollYFor: aScrollableElement.
	oldY := logicalScrollY.
	newY := oldY + dY.

	(self isOutsideBounds: newY on: aScrollableElement)
		ifTrue: [
			self enterRubberBandFrom: oldY to: newY on: aScrollableElement.
			^ true ].

	"Normal in-bounds scroll is still a single logical value projected into the
	Bloc scroll position. No flinger is used by this handler."
	aScrollableElement scrollFlinger stop.
	self stopRubberBandAnimations.
	logicalScrollY := newY.
	self renderLogicalScrollYOn: aScrollableElement.
	^ true
]

{ #category : 'private - scrolling' }
CFSmoothScrollableElementEventHandler >> enterRubberBandFrom: oldY to: newY on: aScrollableElement [
	| boundaryY overscrollDelta peakRaw peakVisible |
	"A boundary crossing creates one rubber-band impulse. From this point until
	the outward rubber-band animation completes, incoming wheel/gesture events are
	consumed and ignored so the native flick tail cannot keep mutating the
	overscroll state."
	aScrollableElement scrollFlinger stop.
	self stopRubberBandAnimations.

	boundaryY := self boundaryForOutsideY: newY on: aScrollableElement.
	overscrollDelta := newY - boundaryY.

	logicalScrollY := boundaryY.
	self renderLogicalScrollYOn: aScrollableElement.

	peakRaw := overscrollDelta abs * self overscrollImpulseScale.
	peakVisible := self
		rubberDistanceFor: peakRaw
		dimension: (self rubberBandDimensionFor: aScrollableElement).

	self
		animateRubberBandOutTo: overscrollDelta sign * peakVisible
		on: aScrollableElement
]

{ #category : 'private - scrolling' }
CFSmoothScrollableElementEventHandler >> interruptRubberBandSnapBackOn: aScrollableElement [
	"New user input during snap-back is allowed. Stop the return animation, settle
	the derived transform, and let the incoming event become the active driver."
	self stopRubberBandAnimations.
	self applyRubberBandTransform: 0 to: aScrollableElement.
	logicalScrollY := aScrollableElement scrollPosition y.
	rubberBandState := #normal
]

{ #category : 'private - scrolling' }
CFSmoothScrollableElementEventHandler >> ensureLogicalScrollYFor: aScrollableElement [
	logicalScrollY ifNil: [ logicalScrollY := aScrollableElement scrollPosition y ]
]

{ #category : 'private - scrolling' }
CFSmoothScrollableElementEventHandler >> renderLogicalScrollYOn: aScrollableElement [
	| clampedY projectedY transformY realDeltaY |
	clampedY := self clampedYFor: logicalScrollY on: aScrollableElement.
	projectedY := self projectedYFor: logicalScrollY on: aScrollableElement.
	transformY := projectedY - clampedY.

	realDeltaY := clampedY - aScrollableElement scrollPosition y.
	realDeltaY isZero
		ifFalse: [ aScrollableElement scrollVerticallyBy: realDeltaY ].

	self applyRubberBandTransform: transformY to: aScrollableElement
]

{ #category : 'private - scrolling' }
CFSmoothScrollableElementEventHandler >> isOutsideBounds: aNumber on: aScrollableElement [
	^ (aNumber > aScrollableElement scrollMaximum y)
		or: [ aNumber < aScrollableElement scrollMinimum y ]
]

{ #category : 'private - scrolling' }
CFSmoothScrollableElementEventHandler >> boundaryForOutsideY: aNumber on: aScrollableElement [
	aNumber > aScrollableElement scrollMaximum y
		ifTrue: [ ^ aScrollableElement scrollMaximum y ].
	aNumber < aScrollableElement scrollMinimum y
		ifTrue: [ ^ aScrollableElement scrollMinimum y ].
	^ aNumber
]

{ #category : 'private - scrolling' }
CFSmoothScrollableElementEventHandler >> clampedYFor: aNumber on: aScrollableElement [
	^ (aNumber max: aScrollableElement scrollMinimum y)
		min: aScrollableElement scrollMaximum y
]

{ #category : 'private - scrolling' }
CFSmoothScrollableElementEventHandler >> projectedYFor: aNumber on: aScrollableElement [
	| minimumY maximumY dimension overscroll |
	minimumY := aScrollableElement scrollMinimum y.
	maximumY := aScrollableElement scrollMaximum y.
	dimension := self rubberBandDimensionFor: aScrollableElement.

	aNumber > maximumY
		ifTrue: [
			overscroll := aNumber - maximumY.
			^ maximumY + (self rubberDistanceFor: overscroll dimension: dimension) ].

	aNumber < minimumY
		ifTrue: [
			overscroll := minimumY - aNumber.
			^ minimumY - (self rubberDistanceFor: overscroll dimension: dimension) ].

	^ aNumber
]

{ #category : 'private - scrolling' }
CFSmoothScrollableElementEventHandler >> rubberDistanceFor: anOverscrollDistance dimension: aDimension [
	| c |
	c := self rubberBandConstant.
	^ (anOverscrollDistance * aDimension * c)
		/ (aDimension + (c * anOverscrollDistance))
]

{ #category : 'private - scrolling' }
CFSmoothScrollableElementEventHandler >> rubberBandDimensionFor: aScrollableElement [
	"The rubber-band formula approaches this dimension asymptotically. Using half
	the visible viewport gives a hard upper feel without changing the initial
	Apple-style edge response controlled by rubberBandConstant."
	^ ((aScrollableElement height max: 1.0) * self rubberBandExtentFraction)
		max: 1.0
]

{ #category : 'accessing - rubber band' }
CFSmoothScrollableElementEventHandler >> rubberBandConstant [
	"Commonly cited UIScrollView-style rubber-band stiffness constant."
	^ 0.55
]

{ #category : 'accessing - rubber band' }
CFSmoothScrollableElementEventHandler >> rubberBandExtentFraction [
	"Maximum effective rubber-band range as a fraction of the viewport height."
	^ 0.5
]

{ #category : 'accessing - rubber band' }
CFSmoothScrollableElementEventHandler >> overscrollImpulseScale [
	"Scales the boundary-crossing remainder into the raw overscroll impulse that
	is projected by the rubber-band formula."
	^ 1.0
]

{ #category : 'accessing - scrolling' }
CFSmoothScrollableElementEventHandler >> wheelScrollScaleFor: anEvent [
	"Glutin/Winit pixel wheel events already arrive in pixel units. Keep the
	legacy scale only for non-pixel / line-based wheel events."
	anEvent isPixelBased
		ifTrue: [ ^ 1.0 ].
	^ self wheelLineScrollScale
]

{ #category : 'accessing - scrolling' }
CFSmoothScrollableElementEventHandler >> wheelLineScrollScale [
	^ 10.0
]

{ #category : 'accessing - scrolling' }
CFSmoothScrollableElementEventHandler >> gestureScrollScale [
	^ 400
]

{ #category : 'animation' }
CFSmoothScrollableElementEventHandler >> animateRubberBandOutTo: aNumber on: aScrollableElement [
	| anAnimation aScrolledElement |
	aScrollableElement hasScrolledElement
		ifFalse: [ ^ self ].
	aScrolledElement := aScrollableElement scrolledElement.

	rubberBandState := #rubberBandOut.
	rubberBandOutAnimation ifNotNil: [
		rubberBandOutAnimation stopIfRunning.
		rubberBandOutAnimation := nil ].

	anAnimation := BlTransformAnimation translate: 0 @ aNumber.
	anAnimation
		absolute;
		duration: self rubberBandOutDuration;
		easing: self rubberBandOutEasing;
		onFinishedDo: [
			rubberBandOutAnimation := nil.
			self rubberBandState = #rubberBandOut
				ifTrue: [ self animateRubberBandTransformBackFor: aScrollableElement ] ].

	rubberBandOutAnimation := anAnimation.
	aScrolledElement addAnimation: anAnimation
]

{ #category : 'animation' }
CFSmoothScrollableElementEventHandler >> animateRubberBandTransformBackFor: aScrollableElement [
	| anAnimation aScrolledElement |
	aScrollableElement hasScrolledElement
		ifFalse: [ ^ self ].
	aScrolledElement := aScrollableElement scrolledElement.

	rubberBandState := #snapBack.
	rubberBandReturnAnimation ifNotNil: [
		rubberBandReturnAnimation stopIfRunning.
		rubberBandReturnAnimation := nil ].

	anAnimation := BlTransformAnimation translate: 0 @ 0.
	anAnimation
		absolute;
		duration: self rubberBandReturnDuration;
		easing: self rubberBandReturnEasing;
		onFinishedDo: [
			logicalScrollY := nil.
			rubberBandReturnAnimation := nil.
			rubberBandState := #normal ].

	rubberBandReturnAnimation := anAnimation.
	aScrolledElement addAnimation: anAnimation
]

{ #category : 'animation' }
CFSmoothScrollableElementEventHandler >> stopRubberBandAnimations [
	rubberBandOutAnimation ifNotNil: [
		rubberBandOutAnimation stopIfRunning.
		rubberBandOutAnimation := nil ].
	rubberBandReturnAnimation ifNotNil: [
		rubberBandReturnAnimation stopIfRunning.
		rubberBandReturnAnimation := nil ]
]

{ #category : 'private - rendering' }
CFSmoothScrollableElementEventHandler >> applyRubberBandTransform: aNumber to: aScrollableElement [
	aScrollableElement hasScrolledElement
		ifFalse: [ ^ self ].

	aScrollableElement scrolledElement
		transformDo: [ :aBuilder |
			aBuilder translateBy: 0 @ aNumber ]
]

{ #category : 'testing' }
CFSmoothScrollableElementEventHandler >> rubberBandState [
	^ rubberBandState
]

{ #category : 'animation' }
CFSmoothScrollableElementEventHandler >> rubberBandOutDuration [
	^ 90 milliSeconds
]

{ #category : 'animation' }
CFSmoothScrollableElementEventHandler >> rubberBandOutEasing [
	^ BlDecelerateInterpolator factor: 1.3
]

{ #category : 'animation' }
CFSmoothScrollableElementEventHandler >> rubberBandReturnDuration [
	^ 220 milliSeconds
]

{ #category : 'animation' }
CFSmoothScrollableElementEventHandler >> rubberBandReturnEasing [
	^ BlDecelerateInterpolator factor: 1.2
]
