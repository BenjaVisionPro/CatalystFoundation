Class {
	#name : 'CFSmoothScrollableElementEventHandler',
	#superclass : 'BlScrollableElementEventHandler',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'mouse handlers' }
CFSmoothScrollableElementEventHandler >> mouseWheelEvent: anEvent [
	| aScrollableElement dY |
	"Keep GT's default scrollable behaviour everywhere except wheel input: vertical
	wheel input is routed through the existing Bloc smooth-scroll flinger, following
	the pattern used by GT infinite vertical orientation."
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

	aScrollableElement smoothScrollBy: 0 @ (dY * self smoothScrollScale).
	anEvent consumed: true
]

{ #category : 'accessing' }
CFSmoothScrollableElementEventHandler >> smoothScrollScale [
	^ 10.0
]
