Extension { #name : 'BlScrollFlinger' }

{ #category : '*BVC-Foundation-Magritte-GT' }
BlScrollFlinger >> cfSpringBackFrom: aStartPoint min: aMinPoint max: aMaxPoint [
	| didStart |

	self beSettling.
	lastFlingX := aStartPoint x.
	lastFlingY := aStartPoint y.

	didStart := scroller
		springBack: aStartPoint
		min: aMinPoint
		max: aMaxPoint.

	didStart
		ifTrue: [ self postOnAnimation ]
		ifFalse: [ self beIdle ].

	^ didStart
]
