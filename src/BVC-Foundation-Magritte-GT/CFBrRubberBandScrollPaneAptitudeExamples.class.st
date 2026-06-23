Class {
	#name : 'CFBrRubberBandScrollPaneAptitudeExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'examples' }
CFBrRubberBandScrollPaneAptitudeExamples >> aptitudeCanBeCreated [
	<gtExample>
	| aptitude |

	aptitude := CFBrRubberBandScrollPaneAptitude new.

	self assert: aptitude scrollable class = CFBlRubberBandScrollableElement.
	self assert: aptitude scrollable hasProjectionPlane.
	self assert: aptitude scrollable projectionPlane hasVertical.
	self assert: aptitude scrollable canScrollVertically.
	self assert: aptitude scrollable canScrollHorizontally not.

	^ aptitude
]

{ #category : 'examples' }
CFBrRubberBandScrollPaneAptitudeExamples >> content [
	<gtExample>
	| content |

	content := BrVerticalPane new
		vFitContent;
		hExact: 320;
		cellSpacing: 5;
		padding: (BlInsets right: 10);
		yourself.

	content addChildren: (20 timesCollect: [ :index |
		BlElement new
			background: (BlColorTransition
				interpolate: (Color blue alpha: 0.12)
				to: (Color purple alpha: 0.20)
				at: index / 20.0);
			border: (BlBorder paint: (Color blue alpha: 0.25) width: 1);
			constraintsDo: [ :constraints |
				constraints horizontal matchParent.
				constraints vertical exact: 24 + (index * 4) ];
			yourself ]).

	^ content
]

{ #category : 'examples' }
CFBrRubberBandScrollPaneAptitudeExamples >> scrollPaneCanUseRubberBandAptitude [
	<gtExample>
	| scrollPane aptitude |

	aptitude := self aptitudeCanBeCreated.
	scrollPane := BrScrollPane new
		aptitude: aptitude;
		content: self content;
		yourself.

	self assert: aptitude scrollable class = CFBlRubberBandScrollableElement.
	self assert: aptitude scrollable canScrollVertically.

	^ scrollPane
]

{ #category : 'examples' }
CFBrRubberBandScrollPaneAptitudeExamples >> scrollWishRoutesToRubberBandScrollable [
	<gtExample>
	| aptitude wish before after |

	aptitude := self aptitudeCanBeCreated.
	aptitude scrollable
		constraintsDo: [ :constraints |
			constraints horizontal exact: 320.
			constraints vertical exact: 240 ];
		addChild: self content.
	aptitude scrollable vertical
		minimum: -660;
		maximum: 0;
		dimension: 240;
		overscrollLimit: 120.

	before := aptitude scrollable scrollPosition.
	wish := BrScrollByWish new
		delta: 0 @ -100;
		yourself.
	aptitude onScrollBy: wish.
	after := aptitude scrollable scrollPosition.

	self assert: after y > before y.
	self assert: aptitude scrollable projectedScrollPosition y > 0.
	self assert: aptitude scrollable projectedScrollPosition y < after y.

	^ aptitude scrollable
]

{ #category : 'examples - visual' }
CFBrRubberBandScrollPaneAptitudeExamples >> verticalRubberBandScrollPanePreview [
	<gtExample>
	| scrollPane |

	scrollPane := self scrollPaneCanUseRubberBandAptitude.
	scrollPane
		background: Color veryVeryLightGray;
		border: (BlBorder paint: Color lightGray width: 1);
		constraintsDo: [ :constraints |
			constraints horizontal exact: 320.
			constraints vertical exact: 240 ].

	^ scrollPane
]
