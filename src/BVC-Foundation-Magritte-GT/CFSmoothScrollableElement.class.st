Class {
	#name : 'CFSmoothScrollableElement',
	#superclass : 'BlScrollableElement',
	#instVars : [
		'scrollTarget'
	],
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'private - scrolling' }
CFSmoothScrollableElement >> clampedScrollPosition: aPoint [
	| aMinimum aMaximum |
	aMinimum := self scrollMinimum.
	aMaximum := self scrollMaximum.

	^ ((aPoint x max: aMinimum x) min: aMaximum x)
		@ ((aPoint y max: aMinimum y) min: aMaximum y)
]

{ #category : 'defaults' }
CFSmoothScrollableElement >> defaultSmoothScrollDuration [
	^ 180 milliSeconds
]

{ #category : 'initialization' }
CFSmoothScrollableElement >> initialize [
	super initialize.

	scrollTarget := 0.0 @ 0.0.
	self removeEventHandlersSuchThat: [ :anEventHandler |
		anEventHandler class = BlScrollableElementEventHandler ].
	self addEventHandler: CFSmoothScrollableElementEventHandler new
]

{ #category : 'scrolling' }
CFSmoothScrollableElement >> scrollBy: aPoint [
	| didScroll |
	didScroll := super scrollBy: aPoint.
	scrollTarget := self scrollPosition.
	^ didScroll
]

{ #category : 'scrolling' }
CFSmoothScrollableElement >> scrollHorizontallyBy: aNumber [
	| aCurrent aTarget aDelta |
	aCurrent := self scrollPosition.
	aTarget := self clampedScrollPosition:
		(aCurrent x + aNumber asFloat) @ aCurrent y.
	aDelta := aTarget x - aCurrent x.
	aDelta isZero ifTrue: [ ^ 0.0 ].

	^ super scrollHorizontallyBy: aDelta
]

{ #category : 'scrolling' }
CFSmoothScrollableElement >> scrollVerticallyBy: aNumber [
	| aCurrent aTarget aDelta |
	aCurrent := self scrollPosition.
	aTarget := self clampedScrollPosition:
		aCurrent x @ (aCurrent y + aNumber asFloat).
	aDelta := aTarget y - aCurrent y.
	aDelta isZero ifTrue: [ ^ 0.0 ].

	^ super scrollVerticallyBy: aDelta
]

{ #category : 'scrolling' }
CFSmoothScrollableElement >> smoothScrollBy: aPoint [
	| aBaseTarget aRequestedTarget aClampedTarget aDelta |
	self hasScrolledElement ifFalse: [ ^ self ].

	aBaseTarget := self scrollFlinger isIdle
		ifTrue: [ self scrollPosition ]
		ifFalse: [ scrollTarget ].

	aRequestedTarget := aBaseTarget + aPoint.
	aClampedTarget := self clampedScrollPosition: aRequestedTarget.
	scrollTarget := aClampedTarget.
	aDelta := scrollTarget - self scrollPosition.

	aDelta isZero ifFalse: [
		self scrollFlinger
			smoothScrollBy: aDelta
			during: self defaultSmoothScrollDuration ]
]

{ #category : 'scrolling - input' }
CFSmoothScrollableElement >> smoothScrollWheelEvent: anEvent [
	| dY |
	anEvent vector isZero ifTrue: [ ^ false ].
	anEvent isPrimarilyHorizontal ifTrue: [ ^ false ].

	dY := anEvent isScrollDown
		ifTrue: [ anEvent vector length negated ]
		ifFalse: [
			anEvent isScrollUp
				ifTrue: [ anEvent vector length ]
				ifFalse: [ 0 ] ].
	dY isZero ifTrue: [ ^ false ].

	self smoothScrollBy: 0 @ (dY * 10.0).
	^ true
]
