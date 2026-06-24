Class {
	#name : 'CFBlRubberBandScrollableElementEventHandler',
	#superclass : 'BlScrollableElementEventHandler',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'mouse handlers' }
CFBlRubberBandScrollableElementEventHandler >> gestureScrollEvent: anEvent [
	| aScrollableElement aScrollHappened |

	aScrollableElement := anEvent currentTarget.
	aScrollHappened := aScrollableElement scrollBy:
		(anEvent vector * aScrollableElement gestureScrollScale).
	anEvent consumed: aScrollHappened
]

{ #category : 'mouse handlers' }
CFBlRubberBandScrollableElementEventHandler >> mouseWheelEvent: anEvent [
	| aScrollableElement aScrollHappened |

	"I implement touch support, so ignore fake mouse wheel events"
	anEvent isTouch
		ifTrue: [ ^ self ].

	aScrollableElement := anEvent currentTarget.
	aScrollHappened := aScrollableElement scrollBy:
		(anEvent vector * aScrollableElement wheelScrollScale).
	anEvent consumed: aScrollHappened
]


{ #category : 'mouse handlers' }
CFBlRubberBandScrollableElementEventHandler >> gestureScrollEndEvent: anEvent [
	| aScrollableElement didStart |

	aScrollableElement := anEvent currentTarget.
	didStart := aScrollableElement snapBackIfNeeded.
	anEvent consumed: didStart
]
