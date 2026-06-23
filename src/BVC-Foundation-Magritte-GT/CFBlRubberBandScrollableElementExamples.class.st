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

{ #category : 'examples - visual' }
CFBlRubberBandScrollableElementExamples >> verticalScrollableElementPreview [
	<gtExample>
	| element content |

	element := CFBlRubberBandScrollableElement new.
	element
		background: Color veryVeryLightGray;
		border: (BlBorder paint: Color lightGray width: 1);
		clipChildren: true;
		constraintsDo: [ :c |
			c horizontal exact: 320.
			c vertical exact: 240 ].

	content := BlElement new.
	content
		background: (Color blue alpha: 0.12);
		border: (BlBorder paint: (Color blue alpha: 0.35) width: 1);
		constraintsDo: [ :c |
			c horizontal exact: 320.
			c vertical exact: 900 ].

	element addChild: content.
	element vertical.

	self assert: element hasScrolledElement.
	self assert: element motion hasProjectionPlane.
	self assert: (element motion projectionPlane hasHorizontal) not.
	self assert: element motion projectionPlane hasVertical.

	^ element
]



{ #category : 'examples' }
CFBlRubberBandScrollableElementExamples >> debugOverlayCanBeShown [
	<gtExample>
	| element |

	element := self verticalScrollableElementPreview.
	element showDebugOverlay.

	self assert: element hasDebugOverlay.
	self assert: element debugOverlay hasParent.
	self assert: (element debugValuesString includesSubstring: 'logical:').
	self assert: element children first ~~ element debugOverlay.

	^ element
]

{ #category : 'examples - visual' }
CFBlRubberBandScrollableElementExamples >> verticalScrollableElementDebugPreview [
	<gtExample>
	| container element debugPanel updateDebugPanel |

	element := self verticalScrollableElementPreview.
	element scrollTo: 0 @ 120.

	debugPanel := BrEditor new
		aptitude: BrGlamorousRegularEditorAptitude;
		beReadOnlyWithoutSelection;
		background: (Color white alpha: 0.92);
		border: (BlBorder paint: (Color black alpha: 0.18) width: 1);
		padding: (BlInsets all: 8);
		hExact: 360;
		vFitContent;
		yourself.

	updateDebugPanel := [ debugPanel text: element debugValuesString ].
	updateDebugPanel value.
	element when: BlElementScrolledEvent do: [ :anEvent | updateDebugPanel value ].

	container := BrHorizontalPane new
		fitContent;
		cellSpacing: 12;
		padding: (BlInsets all: 8);
		addChild: element;
		addChild: debugPanel;
		yourself.

	self assert: (debugPanel text asString includesSubstring: 'logical:').

	^ container
]
