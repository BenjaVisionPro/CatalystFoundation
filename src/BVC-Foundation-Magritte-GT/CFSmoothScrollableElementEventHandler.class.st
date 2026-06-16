Class {
	#name : 'CFSmoothScrollableElementEventHandler',
	#superclass : 'BlScrollableElementEventHandler',
	#instVars : [
		'logicalScrollY',
		'rubberBandReturnAnimation',
		'rubberBandReturnTask'
	],
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'initialization' }
CFSmoothScrollableElementEventHandler >> initialize [
	super initialize.

	logicalScrollY := nil.
	rubberBandReturnAnimation := nil.
	rubberBandReturnTask := nil
]

{ #category : 'mouse handlers' }
CFSmoothScrollableElementEventHandler >> mouseWheelEvent: anEvent [
	| dY |
	"Follow GT's vertical infinite-list wheel handling: ignore horizontal wheel
	intent and rebuild the delta as a vertical-only scroll. This handler owns a
	logical scroll position and projects it into Bloc's real clamped scroll
	position plus a presentation-only rubber-band transform."
	anEvent isTouch
		ifTrue: [ ^ self ].
	anEvent vector isZero
		ifTrue: [ ^ self ].
	anEvent isPrimarilyHorizontal
		ifTrue: [ ^ self ].

	dY := anEvent isScrollDown
		ifTrue: [ anEvent vector length negated * self wheelScrollScale ]
		ifFalse: [
			anEvent isScrollUp
				ifTrue: [ anEvent vector length * self wheelScrollScale ]
				ifFalse: [ 0 ] ].

	(self
		handleVerticalScrollDelta: dY
		on: anEvent currentTarget
		scheduleRelease: true)
		ifTrue: [
			anEvent consumed: true.
			(self isWheelEndEvent: anEvent)
				ifTrue: [ self releaseRubberBandFor: anEvent currentTarget ] ]
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
	the vertical axis and send it through the same logical-offset projection path
	as wheel input."
	dY := aVector y * self gestureScrollScale negated.

	(self
		handleVerticalScrollDelta: dY
		on: anEvent currentTarget
		scheduleRelease: false)
		ifTrue: [ anEvent consumed: true ]
]

{ #category : 'mouse handlers' }
CFSmoothScrollableElementEventHandler >> gestureScrollEndEvent: anEvent [
	"Gesture scrolling has an explicit end event, so release immediately instead
	of waiting for the wheel-idle fallback delay."
	self releaseRubberBandFor: anEvent currentTarget
]

{ #category : 'private - scrolling' }
CFSmoothScrollableElementEventHandler >> handleVerticalScrollDelta: dY on: aScrollableElement scheduleRelease: aBoolean [
	dY isZero
		ifTrue: [ ^ false ].
	aScrollableElement hasScrolledElement
		ifFalse: [ ^ false ].

	"This handler owns the scroll interaction while it is active. Stop Bloc's
	flinger so it does not write scrollPosition while the logical projection is
	also rendering the scrolled element."
	aScrollableElement scrollFlinger stop.
	self stopRubberBandReturn.
	self ensureLogicalScrollYFor: aScrollableElement.

	logicalScrollY := logicalScrollY + dY.
	self renderLogicalScrollYOn: aScrollableElement.

	aBoolean
		ifTrue: [ self scheduleRubberBandReleaseFor: aScrollableElement ].

	^ true
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
CFSmoothScrollableElementEventHandler >> clampedYFor: aNumber on: aScrollableElement [
	^ (aNumber max: aScrollableElement scrollMinimum y)
		min: aScrollableElement scrollMaximum y
]

{ #category : 'private - scrolling' }
CFSmoothScrollableElementEventHandler >> projectedYFor: aNumber on: aScrollableElement [
	| minimumY maximumY dimension overscroll |
	minimumY := aScrollableElement scrollMinimum y.
	maximumY := aScrollableElement scrollMaximum y.
	dimension := aScrollableElement height max: 1.0.

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

{ #category : 'accessing - rubber band' }
CFSmoothScrollableElementEventHandler >> rubberBandConstant [
	"Commonly cited UIScrollView-style rubber-band stiffness constant."
	^ 0.55
]

{ #category : 'accessing - scrolling' }
CFSmoothScrollableElementEventHandler >> wheelScrollScale [
	^ 10
]

{ #category : 'accessing - scrolling' }
CFSmoothScrollableElementEventHandler >> gestureScrollScale [
	^ 400
]

{ #category : 'animation' }
CFSmoothScrollableElementEventHandler >> releaseRubberBandFor: aScrollableElement [
	| targetY |
	aScrollableElement hasScrolledElement
		ifFalse: [ ^ self ].
	logicalScrollY ifNil: [ ^ self ].

	rubberBandReturnTask ifNotNil: [
		rubberBandReturnTask stop.
		rubberBandReturnTask := nil ].

	targetY := self clampedYFor: logicalScrollY on: aScrollableElement.
	logicalScrollY := targetY.
	self renderLogicalScrollYOn: aScrollableElement.
	self animateRubberBandTransformBackFor: aScrollableElement
]

{ #category : 'animation' }
CFSmoothScrollableElementEventHandler >> animateRubberBandTransformBackFor: aScrollableElement [
	| anAnimation aScrolledElement |
	aScrollableElement hasScrolledElement
		ifFalse: [ ^ self ].

	aScrolledElement := aScrollableElement scrolledElement.

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
			rubberBandReturnAnimation := nil ].

	rubberBandReturnAnimation := anAnimation.
	aScrolledElement addAnimation: anAnimation
]

{ #category : 'animation' }
CFSmoothScrollableElementEventHandler >> scheduleRubberBandReleaseFor: aScrollableElement [
	| aTask |
	aScrollableElement hasScrolledElement
		ifFalse: [ ^ self ].

	rubberBandReturnTask ifNotNil: [
		rubberBandReturnTask stop.
		rubberBandReturnTask := nil ].

	aTask := BlDelayedTaskAction new
		delay: self rubberBandWheelReleaseDelay;
		action: [
			self releaseRubberBandFor: aScrollableElement.
			rubberBandReturnTask := nil ];
		yourself.
	rubberBandReturnTask := aTask.
	aScrollableElement scrolledElement enqueueTask: aTask
]

{ #category : 'animation' }
CFSmoothScrollableElementEventHandler >> stopRubberBandReturn [
	rubberBandReturnTask ifNotNil: [
		rubberBandReturnTask stop.
		rubberBandReturnTask := nil ].
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
CFSmoothScrollableElementEventHandler >> isWheelEndEvent: anEvent [
	| aTouchPhaseClass |
	"Wheel phase is host dependent. Glutin/Winit supplies it, but other hosts may
	leave it nil. Use it only when the Winit phase class is present; otherwise the
	wheel-idle fallback remains the safe behaviour."
	anEvent phase ifNil: [ ^ false ].
	aTouchPhaseClass := Smalltalk globals
		at: #WinitEventTouchPhase
		ifAbsent: [ ^ false ].
	^ anEvent phase = aTouchPhaseClass Ended
]

{ #category : 'animation' }
CFSmoothScrollableElementEventHandler >> rubberBandWheelReleaseDelay [
	^ 80 milliSeconds
]

{ #category : 'animation' }
CFSmoothScrollableElementEventHandler >> rubberBandReturnDuration [
	^ 260 milliSeconds
]

{ #category : 'animation' }
CFSmoothScrollableElementEventHandler >> rubberBandReturnEasing [
	^ BlDecelerateInterpolator factor: 1.2
]
