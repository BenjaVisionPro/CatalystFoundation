Class {
	#name : 'CFBlRubberBandScrollableElementExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'examples' }
CFBlRubberBandScrollableElementExamples >> elementCanBeCreated [
	<gtExample>
	| element |

	element := CFBlRubberBandScrollableElement new.

	self assert: element animator class = CFRubberBandAnimator.
	self assert: element motion class = CFRubberBandMotion.
	self assert: element motion logicalPosition = (0 @ 0).
	self assert: element motion logicalVelocity = (0 @ 0).
	self assert: element animator isIdle.
	self assert: (element motion hasProjectionPlane) not.

	^ element
]

{ #category : 'examples' }
CFBlRubberBandScrollableElementExamples >> elementCanConfigureVerticalProjection [
	<gtExample>
	| element |

	element := self elementCanBeCreated.
	element vertical
		minimum: -1000;
		maximum: 0;
		dimension: 500.

	self assert: element motion hasProjectionPlane.
	self assert: (element motion projectionPlane hasHorizontal) not.
	self assert: element motion projectionPlane hasVertical.

	^ element
]
