Class {
	#name : 'CFSmoothScrollableElementEventHandler',
	#superclass : 'BlScrollableElementEventHandler',
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

{ #category : 'mouse handlers' }
CFSmoothScrollableElementEventHandler >> mouseWheelEvent: anEvent [
	| aScrollableElement dY |
	"Follow GT's vertical infinite-list wheel handling: ignore horizontal wheel
	intent and rebuild the delta as a vertical-only smooth scroll."
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

	aScrollableElement smoothScrollBy: 0 @ dY * 10.
	anEvent consumed: true
]
