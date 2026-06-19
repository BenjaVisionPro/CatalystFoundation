Class {
	#name : 'CFSmoothScrollableElementEventHandler',
	#superclass : 'BlScrollableElementEventHandler',
	#instVars : [
		'logicalScrollY',
		'rubberBandState',
		'rubberBandOutAnimation',
		'rubberBandReturnAnimation',
		'suppressedWheelSequenceActive',
		'rubberBandTailSuppressionTask'
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
	rubberBandReturnAnimation := nil.
	suppressedWheelSequenceActive := false.
	rubberBandTailSuppressionTask := nil
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

	(self handleVerticalScrollDelta: dY on: anEvent currentTarget event: anEvent)
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

	(self handleVerticalScrollDelta: dY on: anEvent currentTarget event: anEvent)
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
CFSmoothScrollableElementEventHandler >> handleVerticalScrollDelta: dY on: aScrollableElement event: anEvent [
	| oldY newY |
	dY isZero
		ifTrue: [ ^ false ].
	aScrollableElement hasScrolledElement
		ifFalse: [ ^ false ].

	self rubberBandState = #rubberBandOut
		ifTrue: [ ^ true ].

	self rubberBandState = #snapBack
		ifTrue: [
			(self shouldSuppressEventDuringSnapBack: anEvent)
				ifTrue: [ ^ true ].
			self interruptRubberBandSnapBackOn: aScrollableElement ].

	self rubberBandState = #suppressingTail
		ifTrue: [
			(self shouldSuppressEventDuringTailSuppression: anEvent)
				ifTrue: [ ^ true ].
			self stopRubberBandTailSuppression.
			rubberBandState := #normal ].

	self ensureLogicalScrollYFor: aScrollableElement.
	oldY := logicalScrollY.
	newY := oldY + dY.

	(self isOutsideBounds: newY on: aScrollableElement)
		ifTrue: [
			self enterRubberBandFrom: oldY to: newY on: aScrollableElement event: anEvent.
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
CFSmoothScrollableElementEventHandler >> enterRubberBandFrom: oldY to: newY on: aScrollableElement event: anEvent [
	| boundaryY overscrollDelta peakRaw peakVisible |
	"A boundary crossing creates one rubber-band impulse. From this point until
	the outward rubber-band animation completes, incoming wheel/gesture events are
	consumed and ignored so the native flick tail cannot keep mutating the
	overscroll state."
	aScrollableElement scrollFlinger stop.
	self stopRubberBandAnimations.
	suppressedWheelSequenceActive := self isWheelPhaseKnown: anEvent.

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
	rubberBandState := #normal.
	suppressedWheelSequenceActive := false.
	self stopRubberBandAnimations.
	self applyRubberBandTransform: 0 to: aScrollableElement.
	logicalScrollY := aScrollableElement scrollPosition y
]


{ #category : 'private - wheel sequence' }
CFSmoothScrollableElementEventHandler >> shouldSuppressEventDuringSnapBack: anEvent [
	"During snap-back, wheel input is unsafe to treat as new unless the backend
	identifies it as the start of a fresh wheel sequence. Native trackpad inertial
	tails can continue as BlMouseWheelEvent instances after the rubber-band phase
	has started; allowing those events to interrupt snap-back causes repeated
	re-entry into rubberBandOut."
	(self isWheelEvent: anEvent)
		ifFalse: [ ^ false ].

	(self isWheelPhaseStarted: anEvent)
		ifTrue: [
			suppressedWheelSequenceActive := false.
			^ false ].

	(self isWheelEndEvent: anEvent)
		ifTrue: [ suppressedWheelSequenceActive := false ].

	^ true
]


{ #category : 'private - wheel sequence' }
CFSmoothScrollableElementEventHandler >> shouldSuppressEventDuringTailSuppression: anEvent [
	"After snap-back has visually returned to the boundary, native trackpad
	wheel tails can still arrive. Suppress wheel events briefly unless the
	backend explicitly marks the event as the start of a new wheel sequence.
	Non-wheel input is treated as fresh user intent."
	(self isWheelEvent: anEvent)
		ifFalse: [ ^ false ].

	(self isWheelPhaseStarted: anEvent)
		ifTrue: [
			suppressedWheelSequenceActive := false.
			^ false ].

	(self isWheelEndEvent: anEvent)
		ifTrue: [ suppressedWheelSequenceActive := false ].

	^ true
]

{ #category : 'private - wheel sequence' }
CFSmoothScrollableElementEventHandler >> isWheelEvent: anEvent [
	"Wheel events in the relevant Bloc hosts expose #isPixelBased. Avoid using
	#phase alone here because other event families may also expose phase-like
	protocol, but they should not be quarantined as wheel tails."
	^ anEvent respondsTo: #isPixelBased
]

{ #category : 'private - wheel sequence' }
CFSmoothScrollableElementEventHandler >> isWheelPhaseKnown: anEvent [
	| aPhase |
	(anEvent respondsTo: #phase)
		ifFalse: [ ^ false ].
	aPhase := anEvent phase.
	aPhase ifNil: [ ^ false ].
	(Smalltalk globals includesKey: #WinitEventTouchPhase)
		ifFalse: [ ^ false ].
	^ aPhase ~= WinitEventTouchPhase Unknown
]

{ #category : 'private - wheel sequence' }
CFSmoothScrollableElementEventHandler >> isWheelPhaseStarted: anEvent [
	(self isWheelPhaseKnown: anEvent)
		ifFalse: [ ^ false ].
	^ anEvent phase = WinitEventTouchPhase Started
]

{ #category : 'private - wheel sequence' }
CFSmoothScrollableElementEventHandler >> isWheelEndEvent: anEvent [
	(self isWheelPhaseKnown: anEvent)
		ifFalse: [ ^ false ].
	^ (anEvent phase = WinitEventTouchPhase Ended)
		or: [ anEvent phase = WinitEventTouchPhase Cancelled ]
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

	rubberBandOutAnimation ifNotNil: [ :anOldAnimation |
		rubberBandOutAnimation := nil.
		anOldAnimation stopIfRunning ].
	rubberBandState := #rubberBandOut.

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

	rubberBandReturnAnimation ifNotNil: [ :anOldAnimation |
		rubberBandReturnAnimation := nil.
		anOldAnimation stopIfRunning ].
	rubberBandState := #snapBack.

	anAnimation := BlTransformAnimation translate: 0 @ 0.
	anAnimation
		absolute;
		duration: self rubberBandReturnDuration;
		easing: self rubberBandReturnEasing;
		onFinishedDo: [
			logicalScrollY := nil.
			rubberBandReturnAnimation := nil.
			self beginRubberBandTailSuppressionOn: aScrollableElement ].

	rubberBandReturnAnimation := anAnimation.
	aScrolledElement addAnimation: anAnimation
]

{ #category : 'animation' }
CFSmoothScrollableElementEventHandler >> stopRubberBandAnimations [
	| anOutAnimation aReturnAnimation |
	"Stopping a Bloc animation runs its onFinishedDo: handlers. Move the state out
	of rubber-band phases before stopping so cancellation cannot advance the state
	machine as if an animation had naturally completed."
	rubberBandState := #normal.
	anOutAnimation := rubberBandOutAnimation.
	rubberBandOutAnimation := nil.
	aReturnAnimation := rubberBandReturnAnimation.
	rubberBandReturnAnimation := nil.
	self stopRubberBandTailSuppression.

	anOutAnimation ifNotNil: [ anOutAnimation stopIfRunning ].
	aReturnAnimation ifNotNil: [ aReturnAnimation stopIfRunning ]
]


{ #category : 'private - wheel sequence' }
CFSmoothScrollableElementEventHandler >> beginRubberBandTailSuppressionOn: aScrollableElement [
	"Snap-back is already complete. Keep wheel-tail events from immediately
	re-entering rubber-band for a short post-return quarantine. This is not a
	snap-back delay: the visual return has completed before this state begins."
	self stopRubberBandTailSuppression.
	rubberBandState := #suppressingTail.

	rubberBandTailSuppressionTask := BlDelayedTaskAction new
		delay: self rubberBandTailSuppressionDuration;
		action: [
			rubberBandTailSuppressionTask := nil.
			suppressedWheelSequenceActive := false.
			self rubberBandState = #suppressingTail
				ifTrue: [ rubberBandState := #normal ] ];
		yourself.
	aScrollableElement enqueueTask: rubberBandTailSuppressionTask
]

{ #category : 'private - wheel sequence' }
CFSmoothScrollableElementEventHandler >> stopRubberBandTailSuppression [
	rubberBandTailSuppressionTask ifNotNil: [ :aTask | aTask stop ].
	rubberBandTailSuppressionTask := nil
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
CFSmoothScrollableElementEventHandler >> rubberBandTailSuppressionDuration [
	^ 120 milliSeconds
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
