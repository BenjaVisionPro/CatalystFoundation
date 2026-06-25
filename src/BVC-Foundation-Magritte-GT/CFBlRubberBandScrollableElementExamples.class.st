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

	self assert: element scrollFlinger class = BlScrollFlinger.
	self assert: element scrollPosition = (0 @ 0).
	self assert: element scrollState = #idle.
	self assert: element gestureScrollScale = element defaultGestureScrollScale.
	self assert: element wheelScrollScale = element defaultWheelScrollScale.
	self assert: element flingVelocityScale = element defaultFlingVelocityScale.
	self assert: element hasProjectionPlane not.
	self assert: element canScrollHorizontally not.
	self assert: element canScrollVertically not.

	^ element
]

{ #category : 'examples' }
CFBlRubberBandScrollableElementExamples >> elementCanConfigureVerticalProjection [
	<gtExample>
	| element |

	element := self elementCanBeCreated.
	element vertical.

	self assert: element hasProjectionPlane.
	self assert: element projectionPlane hasVertical.
	self assert: element projectionPlane hasHorizontal not.
	self assert: element canScrollVertically.
	self assert: element canScrollHorizontally not.
	self assert: element vertical beforeOverscrollLimit = element defaultOverscrollLimit.

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
	self assert: element hasProjectionPlane.
	self assert: element projectionPlane hasVertical.

	^ element
]

{ #category : 'examples' }
CFBlRubberBandScrollableElementExamples >> scrollToHugeValueDoesNotRunAway [
	<gtExample>
	| element expectedLimit |

	element := self verticalScrollableElementPreview.
	element vertical
		minimum: -660;
		maximum: 0;
		dimension: 240;
		overscrollLimit: 120.
	expectedLimit := element vertical limitedOffsetFor: 999999.

	element scrollTo: 0 @ 999999.

	self assert: element scrollPosition y = expectedLimit.
	self assert: element scrollPosition y < 1000.
	self assert: element projectedScrollPosition y <= 120.000001.

	^ element
]

{ #category : 'examples' }
CFBlRubberBandScrollableElementExamples >> repeatedScrollByDoesNotRunAway [
	<gtExample>
	| element |

	element := self verticalScrollableElementPreview.
	element vertical
		minimum: -660;
		maximum: 0;
		dimension: 240;
		overscrollLimit: 120.

	100 timesRepeat: [ element scrollBy: 0 @ -1000 ].

	self assert: element scrollPosition y < 1000.
	self assert: element projectedScrollPosition y <= 120.000001.

	^ element
]

{ #category : 'examples' }
CFBlRubberBandScrollableElementExamples >> scrollVerticallyByReturnsConsumedDistance [
	<gtExample>
	| element consumed |

	element := self verticalScrollableElementPreview.
	element vertical
		minimum: -660;
		maximum: 0;
		dimension: 240;
		overscrollLimit: 120.

	consumed := element scrollVerticallyBy: 100.

	self assert: consumed > 0.
	self assert: consumed = element scrollPosition y.
	self assert: element projectedScrollPosition y > 0.
	self assert: element projectedScrollPosition y < element scrollPosition y.

	^ element
]

{ #category : 'examples' }
CFBlRubberBandScrollableElementExamples >> scrollOvershotIsFinite [
	<gtExample>
	| element overshot |

	element := self verticalScrollableElementPreview.
	element vertical
		minimum: -660;
		maximum: 0;
		dimension: 240;
		overscrollLimit: 120.

	overshot := element scrollOvershot.

	self assert: overshot y > 0.
	self assert: overshot y < 1000.

	^ element
]

{ #category : 'examples' }
CFBlRubberBandScrollableElementExamples >> smoothScrollUsesScrollFlinger [
	<gtExample>
	| element |

	element := self verticalScrollableElementPreview.
	element smoothScrollBy: 0 @ 120.

	self assert: element scrollFlinger isIdle not.

	^ element
]

{ #category : 'examples' }
CFBlRubberBandScrollableElementExamples >> flingUsesScrollFlinger [
	<gtExample>
	| element |

	element := self verticalScrollableElementPreview.
	element flingBy: 0 @ 1000.

	self assert: element scrollFlinger isIdle not.

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
	self assert: (element debugValuesString includesSubstring: 'logical scroll:').

	^ element
]

{ #category : 'examples - visual' }
CFBlRubberBandScrollableElementExamples >> verticalScrollableElementDebugPreview [
	<gtExample>
	| container element debugPanel updateDebugPanel |

	element := self verticalScrollableElementPreview.
	element vertical overscrollLimit: 120.
	element scrollTo: 0 @ 999999.

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

	self assert: (debugPanel text asString includesSubstring: 'logical scroll:').

	^ container
]

{ #category : 'examples' }
CFBlRubberBandScrollableElementExamples >> repeatedLargeScrollByApproachesButDoesNotReachOverscrollLimit [
	<gtExample>
	| element |
	element := self verticalScrollableElementPreview.
	element vertical
		minimum: -660;
		maximum: 0;
		dimension: 240;
		overscrollLimit: 120.

	100 timesRepeat: [ element scrollBy: 0 @ -1000 ].

	self assert: element scrollPosition y < 1000.
	self assert: element projectedScrollPosition y > 0.
	self assert: element projectedScrollPosition y < 120.

	^ element
]


{ #category : 'examples' }
CFBlRubberBandScrollableElementExamples >> inputScalesCanBeConfigured [
	<gtExample>
	| element |

	element := self verticalScrollableElementPreview.
	element
		gestureScrollScale: 10;
		wheelScrollScale: 6 @ -6;
		flingVelocityScale: 0.01.

	self assert: element gestureScrollScale = 10.
	self assert: element wheelScrollScale = (6 @ -6).
	self assert: element flingVelocityScale = 0.01.

	^ element
]

{ #category : 'examples' }
CFBlRubberBandScrollableElementExamples >> invalidGestureScaleIsRejected [
	<gtExample>
	| element failed |

	element := self elementCanBeCreated.
	failed := false.
	[ element gestureScrollScale: -1 ]
		on: Error
		do: [ :anError | failed := true ].

	self assert: failed.

	^ element
]

{ #category : 'examples' }
CFBlRubberBandScrollableElementExamples >> invalidFlingVelocityScaleIsRejected [
	<gtExample>
	| element failed |

	element := self elementCanBeCreated.
	failed := false.
	[ element flingVelocityScale: -1 ]
		on: Error
		do: [ :anError | failed := true ].

	self assert: failed.

	^ element
]

{ #category : 'examples' }
CFBlRubberBandScrollableElementExamples >> rubberBandEventHandlerCanBeCreated [
	<gtExample>
	| handler |

	handler := CFBlRubberBandScrollableElementEventHandler new.

	self assert: handler class = CFBlRubberBandScrollableElementEventHandler.
	self assert: (handler isKindOf: BlScrollableElementEventHandler).

	^ handler
]


{ #category : 'examples' }
CFBlRubberBandScrollableElementExamples >> snapBackInsideBoundsDoesNothing [
	<gtExample>
	| element |

	element := self verticalScrollableElementPreview.
	element vertical
		minimum: -660;
		maximum: 0;
		dimension: 240;
		overscrollLimit: 120.
	element scrollTo: 0 @ -100.

	self assert: element isOverscrolled not.
	self assert: element snapBackIfNeeded not.
	self assert: element scrollFlinger isIdle.

	^ element
]

{ #category : 'examples' }
CFBlRubberBandScrollableElementExamples >> snapBackFromTopOverscrollStartsFlinger [
	<gtExample>
	| element |

	element := self verticalScrollableElementPreview.
	element vertical
		minimum: -660;
		maximum: 0;
		dimension: 240;
		overscrollLimit: 120.
	element scrollTo: 0 @ 100.

	self assert: element isOverscrolled.
	self assert: element nearestScrollBoundsPosition = (0 @ element scrollMaximum y).
	self assert: element snapBackIfNeeded.
	self assert: element scrollState = #settling.
	self assert: element scrollFlinger isIdle not.

	^ element
]

{ #category : 'examples' }
CFBlRubberBandScrollableElementExamples >> snapBackFromBottomOverscrollStartsFlinger [
	<gtExample>
	| element |

	element := self verticalScrollableElementPreview.
	element vertical
		minimum: -660;
		maximum: 0;
		dimension: 240;
		overscrollLimit: 120.
	element scrollTo: 0 @ -760.

	self assert: element isOverscrolled.
	self assert: element nearestScrollBoundsPosition = (0 @ -660).
	self assert: element snapBackIfNeeded.
	self assert: element scrollState = #settling.
	self assert: element scrollFlinger isIdle not.

	^ element
]

{ #category : 'examples - visual' }
CFBlRubberBandScrollableElementExamples >> verticalSnapBackDebugPreview [
	<gtExample>
	| container element debugPanel updateDebugPanel |

	element := self verticalScrollableElementPreview.
	element vertical overscrollLimit: 120.
	element scrollTo: 0 @ 100.
	element snapBackIfNeeded.

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

	self assert: element scrollState = #settling.
	self assert: (debugPanel text asString includesSubstring: 'overscrolled:').

	^ container
]

{ #category : 'examples' }
CFBlRubberBandScrollableElementExamples >> programmaticOverscrollDoesNotAutoSnap [
	<gtExample>
	| element |

	element := self verticalScrollableElementPreview.
	element vertical
		minimum: -660;
		maximum: 0;
		dimension: 240;
		overscrollLimit: 120.

	element scrollTo: 0 @ 100.

	self assert: element isOverscrolled.
	self assert: element scrollState = #idle.
	self assert: element scrollFlinger isIdle.

	^ element
]

{ #category : 'examples' }
CFBlRubberBandScrollableElementExamples >> reachingTopOverscrollStopStartsSnapBack [
	<gtExample>
	| element axis stop |

	element := self verticalScrollableElementPreview.
	axis := element vertical.
	axis
		minimum: -660;
		maximum: 0;
		dimension: 240;
		overscrollLimit: 120.
	stop := axis afterOverscrollStop.

	element scrollTo: 0 @ (stop - 0.01).
	element scrollVerticallyBy: 100.

	self assert: element isOverscrolled.
	self assert: element scrollPosition y = stop.
	self assert: element scrollState = #settling.
	self assert: element scrollFlinger isIdle not.

	^ element
]

{ #category : 'examples' }
CFBlRubberBandScrollableElementExamples >> reachingBottomOverscrollStopStartsSnapBack [
	<gtExample>
	| element axis stop |

	element := self verticalScrollableElementPreview.
	axis := element vertical.
	axis
		minimum: -660;
		maximum: 0;
		dimension: 240;
		overscrollLimit: 120.
	stop := axis beforeOverscrollStop.

	element scrollTo: 0 @ (stop + 0.01).
	element scrollVerticallyBy: -100.

	self assert: element isOverscrolled.
	self assert: element scrollPosition y = stop.
	self assert: element scrollState = #settling.
	self assert: element scrollFlinger isIdle not.

	^ element
]

{ #category : 'examples' }
CFBlRubberBandScrollableElementExamples >> movingBackTowardBoundsDoesNotStartSnapBack [
	<gtExample>
	| element axis stop |

	element := self verticalScrollableElementPreview.
	axis := element vertical.
	axis
		minimum: -660;
		maximum: 0;
		dimension: 240;
		overscrollLimit: 120.
	stop := axis afterOverscrollStop.

	element scrollTo: 0 @ stop.
	element scrollVerticallyBy: -10.

	self assert: element isOverscrolled.
	self assert: element scrollPosition y < stop.
	self assert: element scrollState = #idle.
	self assert: element scrollFlinger isIdle.

	^ element
]

{ #category : 'examples' }
CFBlRubberBandScrollableElementExamples >> snapBackStepMovesTowardBottomBoundWithoutResistance [
	<gtExample>
	| element previous consumed |

	element := self verticalScrollableElementPreview.
	element vertical
		minimum: -660;
		maximum: 0;
		dimension: 240;
		overscrollLimit: 120.
	element scrollTo: 0 @ -760.

	self assert: element snapBackIfNeeded.
	self assert: element isSnappingBack.
	previous := element scrollPosition y.
	consumed := element scrollVerticallyBy: 20.

	self assert: consumed = 20.
	self assert: element scrollPosition y = (previous + 20).
	self assert: element isOverscrolled.
	self assert: element isSnappingBack.

	^ element
]

{ #category : 'examples' }
CFBlRubberBandScrollableElementExamples >> snapBackStepClampsWhenCrossingBottomBound [
	<gtExample>
	| element consumed |

	element := self verticalScrollableElementPreview.
	element vertical
		minimum: -660;
		maximum: 0;
		dimension: 240;
		overscrollLimit: 120.
	element scrollTo: 0 @ -670.

	self assert: element snapBackIfNeeded.
	self assert: element isSnappingBack.
	consumed := element scrollVerticallyBy: 20.

	self assert: consumed = 10.
	self assert: element scrollPosition y = -660.
	self assert: element isOverscrolled not.
	self assert: element isSnappingBack not.

	^ element
]

{ #category : 'examples' }
CFBlRubberBandScrollableElementExamples >> snapBackDoesNotRestartWhileSnappingBack [
	<gtExample>
	| element axis stop restarted |

	element := self verticalScrollableElementPreview.
	axis := element vertical.
	axis
		minimum: -660;
		maximum: 0;
		dimension: 240;
		overscrollLimit: 120.
	stop := axis beforeOverscrollStop.
	element scrollTo: 0 @ stop.

	self assert: element snapBackIfNeeded.
	self assert: element isSnappingBack.
	restarted := element
		snapBackIfStoppedInOverscrollFrom: 0 @ (stop + 1)
		to: 0 @ stop
		requestedDelta: 0 @ -100.

	self assert: restarted not.
	self assert: element isSnappingBack.

	^ element
]
