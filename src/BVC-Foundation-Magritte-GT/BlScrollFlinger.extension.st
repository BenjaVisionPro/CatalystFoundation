Extension { #name : 'BlScrollFlinger' }

{ #category : '*bvc-foundation-magritte-gt' }
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
