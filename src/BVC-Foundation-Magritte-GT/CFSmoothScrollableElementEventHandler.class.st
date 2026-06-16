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
	| aScrollableElement aDeltaPoint |
	"BlScrollableElementEventHandler ignores fake mouse wheel events generated
	for touch support; keep the same contract."
	anEvent isTouch
		ifTrue: [ ^ self ].

	aScrollableElement := anEvent currentTarget.
	aDeltaPoint := (anEvent vector * (20 @ 20 negated)) negated.

	(self canScroll: aScrollableElement by: aDeltaPoint)
		ifFalse: [ ^ self ].

	aScrollableElement smoothScrollBy: aDeltaPoint.
	anEvent consumed: true
]
