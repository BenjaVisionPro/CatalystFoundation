Class {
	#name : 'CFBlRubberBandScrollableElement',
	#superclass : 'BlElement',
	#traits : 'TBlScrollable + TBlAlignable',
	#classTraits : 'TBlScrollable classTrait + TBlAlignable classTrait',
	#instVars : [
		'scrollState',
		'scrollFlinger',
		'scrollPosition',
		'horizontalAlignment',
		'verticalAlignment',
		'projectionPlane',
		'debugOverlay'
	],
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : #conversion }
CFBlRubberBandScrollableElement >> asScrollableElement [
	^ self
]

{ #category : 'api - scrolling testing' }
CFBlRubberBandScrollableElement >> canScrollHorizontally [
	^ self hasProjectionPlane and: [ projectionPlane hasHorizontal ]
]

{ #category : 'api - scrolling testing' }
CFBlRubberBandScrollableElement >> canScrollVertically [
	^ self hasProjectionPlane and: [ projectionPlane hasVertical ]
]

{ #category : 'api - scrolling thumb' }
CFBlRubberBandScrollableElement >> computeHorizontalScrollExtent [
	^ self width
]

{ #category : 'api - scrolling thumb' }
CFBlRubberBandScrollableElement >> computeHorizontalScrollOffset [
	^ scrollPosition x negated
]

{ #category : 'api - scrolling thumb' }
CFBlRubberBandScrollableElement >> computeHorizontalScrollRange [
	^ self hasScrolledElement
		ifTrue: [ self scrolledElement width + self scrolledElement margin width + self padding width ]
		ifFalse: [ self width ]
]

{ #category : 'api - scrolling thumb' }
CFBlRubberBandScrollableElement >> computeVerticalScrollExtent [
	^ self height
]

{ #category : 'api - scrolling thumb' }
CFBlRubberBandScrollableElement >> computeVerticalScrollOffset [
	^ scrollPosition y negated
]

{ #category : 'api - scrolling thumb' }
CFBlRubberBandScrollableElement >> computeVerticalScrollRange [
	^ self hasScrolledElement
		ifTrue: [ self scrolledElement height + self scrolledElement margin height + self padding height ]
		ifFalse: [ self height ]
]

{ #category : 'defaults' }
CFBlRubberBandScrollableElement >> defaultHorizontalAlignment [
	^ BlElementAlignment null horizontal
]

{ #category : 'defaults' }
CFBlRubberBandScrollableElement >> defaultLayout [
	^ BlFrameLayout new
]

{ #category : 'defaults' }
CFBlRubberBandScrollableElement >> defaultOverscrollLimit [
	"A UI default only. CFRubberBandProjection remains neutral by default."

	^ 1 / 2
]

{ #category : 'defaults' }
CFBlRubberBandScrollableElement >> defaultVerticalAlignment [
	^ BlElementAlignment null vertical
]

{ #category : 'debugging' }
CFBlRubberBandScrollableElement >> debugOverlay [
	debugOverlay ifNil: [ debugOverlay := self newDebugOverlay ].
	^ debugOverlay
]

{ #category : 'debugging' }
CFBlRubberBandScrollableElement >> debugValuesString [
	^ String streamContents: [ :aStream |
		aStream
			nextPutAll: 'Rubber band'; cr;
			nextPutAll: 'state: '; nextPutAll: scrollState asString; cr;
			nextPutAll: 'logical scroll: '; nextPutAll: scrollPosition asString; cr;
			nextPutAll: 'projected scroll: '; nextPutAll: self projectedScrollPosition asString; cr;
			nextPutAll: 'scroll minimum: '; nextPutAll: self scrollMinimum asString; cr;
			nextPutAll: 'scroll maximum: '; nextPutAll: self scrollMaximum asString; cr;
			nextPutAll: 'scroll overshot: '; nextPutAll: self scrollOvershot asString; cr;
			nextPutAll: 'overscroll: '; nextPutAll: (self projectionPlaneIfPresent
				ifNil: [ 0 @ 0 ]
				ifNotNil: [ :plane | plane overscrollDistanceFor: scrollPosition ]) asString; cr;
			nextPutAll: 'projected overscroll: '; nextPutAll: (self projectionPlaneIfPresent
				ifNil: [ 0 @ 0 ]
				ifNotNil: [ :plane | plane projectedOverscrollDistanceFor: scrollPosition ]) asString; cr;
			nextPutAll: 'has horizontal: '; nextPutAll: self canScrollHorizontally asString; cr;
			nextPutAll: 'has vertical: '; nextPutAll: self canScrollVertically asString ]
]

{ #category : 'scrolling' }
CFBlRubberBandScrollableElement >> flingBy: aVelocityPoint [
	self scrollFlinger flingBy: aVelocityPoint
]

{ #category : 'testing' }
CFBlRubberBandScrollableElement >> hasDebugOverlay [
	^ debugOverlay notNil and: [ debugOverlay hasParent ]
]

{ #category : 'testing' }
CFBlRubberBandScrollableElement >> hasProjectionPlane [
	^ projectionPlane notNil
]

{ #category : 'testing' }
CFBlRubberBandScrollableElement >> hasScrolledElement [
	^ self children isNotEmpty
]

{ #category : 'projection configuration' }
CFBlRubberBandScrollableElement >> horizontal [
	| wasPresent axis |
	wasPresent := self hasProjectionPlane and: [ projectionPlane hasHorizontal ].
	axis := self projectionPlane horizontal.
	wasPresent ifFalse: [ axis overscrollLimit: self defaultOverscrollLimit ].
	^ axis
]

{ #category : 'accessing' }
CFBlRubberBandScrollableElement >> horizontalAlignment [
	^ horizontalAlignment
]

{ #category : 'accessing' }
CFBlRubberBandScrollableElement >> horizontalAlignment: aBlElementAlignment [
	horizontalAlignment := aBlElementAlignment.
	self requestLayout
]

{ #category : 'initialization' }
CFBlRubberBandScrollableElement >> initialize [
	super initialize.

	scrollFlinger := BlScrollFlinger on: self.
	scrollPosition := 0.0 @ 0.0.
	scrollState := #idle.
	horizontalAlignment := self defaultHorizontalAlignment.
	verticalAlignment := self defaultVerticalAlignment.
	projectionPlane := nil.
	debugOverlay := nil.
	self layout: self defaultLayout.
	self addEventHandler: BlScrollableElementEventHandler new
]

{ #category : 'private - geometry' }
CFBlRubberBandScrollableElement >> limitedScrollPositionFor: aPoint [
	^ self projectionPlaneIfPresent
		ifNil: [ aPoint ]
		ifNotNil: [ :plane | plane limitedPointFor: aPoint ]
]

{ #category : 'private - debugging' }
CFBlRubberBandScrollableElement >> newDebugOverlay [
	^ BrEditor new
		aptitude: BrGlamorousRegularEditorAptitude;
		text: '';
		beReadOnlyWithoutSelection;
		background: (Color white alpha: 0.92);
		border: (BlBorder paint: (Color black alpha: 0.18) width: 1);
		padding: (BlInsets all: 8);
		zIndex: 1000;
		hExact: 300;
		vFitContent;
		constraintsDo: [ :c |
			c frame horizontal alignRight.
			c frame vertical alignTop ];
		yourself
]

{ #category : 'hooks - children' }
CFBlRubberBandScrollableElement >> onChildAdded: anElement [
	super onChildAdded: anElement.
	anElement constraintsDo: [ :c |
		c frame horizontal alignNone.
		c frame vertical alignNone ]
]

{ #category : 'layout' }
CFBlRubberBandScrollableElement >> onLayout: aBounds context: aBlElementBoundsUpdateContext [
	| previousProjectedPosition |

	previousProjectedPosition := self projectedScrollPosition.
	super onLayout: aBounds context: aBlElementBoundsUpdateContext.
	self hasScrolledElement ifFalse: [ ^ self ].

	self updateProjectionBounds.
	scrollPosition := self limitedScrollPositionFor: scrollPosition.
	self applyProjectedPosition.
	self dispatchOnScrolled: self projectedScrollPosition - previousProjectedPosition
]

{ #category : 'hooks - scrolling' }
CFBlRubberBandScrollableElement >> onScrolled: aPoint [
	super onScrolled: aPoint.
	self updateDebugOverlay
]

{ #category : 'private - applying' }
CFBlRubberBandScrollableElement >> applyProjectedPosition [
	self scrolledElementDo: [ :anElement |
		anElement relocate: self projectedScrollPosition ].
	self updateDebugOverlay.
	^ self
]

{ #category : 'projection configuration' }
CFBlRubberBandScrollableElement >> projectionPlane [
	projectionPlane ifNil: [ projectionPlane := CFRubberBandProjectionPlane new ].
	^ projectionPlane
]

{ #category : 'projection configuration' }
CFBlRubberBandScrollableElement >> projectionPlane: aProjectionPlane [
	projectionPlane := aProjectionPlane.
	scrollPosition := self limitedScrollPositionFor: scrollPosition.
	self applyProjectedPosition.
	^ self
]

{ #category : 'private - accessing' }
CFBlRubberBandScrollableElement >> projectionPlaneIfPresent [
	^ projectionPlane
]

{ #category : 'api - scrolling accessing' }
CFBlRubberBandScrollableElement >> projectedScrollPosition [
	^ self projectionPlaneIfPresent
		ifNil: [ scrollPosition ]
		ifNotNil: [ :plane | plane project: scrollPosition ]
]

{ #category : 'scrolling' }
CFBlRubberBandScrollableElement >> scrollBy: aPoint [
	"Instant scroll by the given amount of pixels along either axis.
	Positive Y component scrolls the content down, matching BlScrollableElement."
	| dX dY consumedX consumedY |

	self hasScrolledElement ifFalse: [ ^ false ].
	self updateProjectionBounds.

	dX := self canScrollHorizontally ifTrue: [ aPoint x negated ] ifFalse: [ 0.0 ].
	dY := self canScrollVertically ifTrue: [ aPoint y negated ] ifFalse: [ 0.0 ].

	consumedX := dX isZero ifTrue: [ 0.0 ] ifFalse: [ self scrollHorizontallyBy: dX ].
	consumedY := dY isZero ifTrue: [ 0.0 ] ifFalse: [ self scrollVerticallyBy: dY ].

	^ consumedX isZero not or: [ consumedY isZero not ]
]

{ #category : 'api - scrolling accessing' }
CFBlRubberBandScrollableElement >> scrollFlinger [
	^ scrollFlinger
]

{ #category : 'api - scrolling' }
CFBlRubberBandScrollableElement >> scrollHorizontallyBy: aNumber [
	| previous next consumed |

	(self hasScrolledElement and: [ self canScrollHorizontally ])
		ifFalse: [ ^ 0 ].

	self updateProjectionBounds.
	previous := scrollPosition.
	next := self limitedScrollPositionFor: (scrollPosition x + aNumber asFloat) @ scrollPosition y.
	consumed := next x - previous x.
	consumed isZero ifTrue: [ ^ 0 ].

	scrollPosition := next.
	self applyProjectedPosition.
	self dispatchOnScrolled: consumed @ 0.0.
	^ consumed
]

{ #category : 'api - scrolling geometry' }
CFBlRubberBandScrollableElement >> scrollMaximum [
	^ 0.0 @ 0.0
]

{ #category : 'api - scrolling geometry' }
CFBlRubberBandScrollableElement >> scrollMinimum [
	self hasScrolledElement ifFalse: [ ^ 0.0 @ 0.0 ].
	^ (self extent - self scrolledElement extent) min: 0.0 @ 0.0
]

{ #category : 'api - scrolling geometry' }
CFBlRubberBandScrollableElement >> scrollOvershot [
	| overshot fallback |
	fallback := self extent / 2.0.
	overshot := self projectionPlaneIfPresent
		ifNil: [ fallback ]
		ifNotNil: [ :plane | plane logicalOverscrollLimit ].
	^ (self finiteOvershot: overshot x fallback: fallback x)
		@ (self finiteOvershot: overshot y fallback: fallback y)
]

{ #category : 'api - scrolling accessing' }
CFBlRubberBandScrollableElement >> scrollPosition [
	^ scrollPosition
]

{ #category : 'api - scrolling' }
CFBlRubberBandScrollableElement >> scrollTo: aPoint [
	| previousProjectedPosition |

	self hasScrolledElement ifFalse: [ ^ self ].
	self updateProjectionBounds.
	previousProjectedPosition := self projectedScrollPosition.
	scrollPosition := self limitedScrollPositionFor: aPoint.
	self applyProjectedPosition.
	self dispatchOnScrolled: self projectedScrollPosition - previousProjectedPosition.
	^ self
]

{ #category : 'private - scrolling accessing' }
CFBlRubberBandScrollableElement >> scrollState [
	^ scrollState
]

{ #category : 'private - scrolling accessing' }
CFBlRubberBandScrollableElement >> scrollState: aScrollState [
	scrollState := aScrollState.
	self updateDebugOverlay
]

{ #category : 'api - scrolling' }
CFBlRubberBandScrollableElement >> scrollVerticallyBy: aNumber [
	| previous next consumed |

	(self hasScrolledElement and: [ self canScrollVertically ])
		ifFalse: [ ^ 0 ].

	self updateProjectionBounds.
	previous := scrollPosition.
	next := self limitedScrollPositionFor: scrollPosition x @ (scrollPosition y + aNumber asFloat).
	consumed := next y - previous y.
	consumed isZero ifTrue: [ ^ 0 ].

	scrollPosition := next.
	self applyProjectedPosition.
	self dispatchOnScrolled: 0.0 @ consumed.
	^ consumed
]

{ #category : 'accessing' }
CFBlRubberBandScrollableElement >> scrolledElement [
	^ self children first
]

{ #category : 'accessing' }
CFBlRubberBandScrollableElement >> scrolledElementDo: aBlock [
	self children ifNotEmpty: [ :theChildren | aBlock value: theChildren first ]
]

{ #category : 'debugging' }
CFBlRubberBandScrollableElement >> hideDebugOverlay [
	debugOverlay ifNotNil: [
		debugOverlay hasParent ifTrue: [ debugOverlay removeFromParent ] ].
	^ self
]

{ #category : 'scrolling' }
CFBlRubberBandScrollableElement >> smoothScrollBy: aPoint [
	| dX dY |

	dX := self canScrollHorizontally ifTrue: [ aPoint x ] ifFalse: [ 0.0 ].
	dY := self canScrollVertically ifTrue: [ aPoint y ] ifFalse: [ 0.0 ].
	(dX isZero and: [ dY isZero ])
		ifFalse: [ scrollFlinger smoothScrollBy: dX @ dY ]
]

{ #category : 'debugging' }
CFBlRubberBandScrollableElement >> showDebugOverlay [
	self hasScrolledElement ifFalse: [ ^ self ].
	self debugOverlay hasParent
		ifFalse: [ self addChild: self debugOverlay as: #rubberBandDebugOverlay ].
	self updateDebugOverlayLayout.
	self updateDebugOverlay.
	^ self
]

{ #category : 'private - scrolling geometry' }
CFBlRubberBandScrollableElement >> finiteOvershot: aNumber fallback: aFallbackNumber [
	(aNumber = Float infinity or: [ aNumber = Float negativeInfinity ])
		ifTrue: [ ^ aFallbackNumber ].
	^ aNumber
]

{ #category : 'private - configuration' }
CFBlRubberBandScrollableElement >> updateHorizontalProjectionBounds [
	| axis |

	(self width <= 0 or: [ self hasScrolledElement not or: [ self scrolledElement width <= 0 ] ])
		ifTrue: [ ^ self ].

	axis := projectionPlane horizontal.
	axis
		minimum: self scrollMinimum x;
		maximum: self scrollMaximum x;
		dimension: (self width max: 1.0)
]

{ #category : 'private - configuration' }
CFBlRubberBandScrollableElement >> updateProjectionBounds [
	(self hasScrolledElement and: [ self hasProjectionPlane ])
		ifFalse: [ ^ self ].
	projectionPlane hasHorizontal ifTrue: [ self updateHorizontalProjectionBounds ].
	projectionPlane hasVertical ifTrue: [ self updateVerticalProjectionBounds ].
	^ self
]

{ #category : 'private - configuration' }
CFBlRubberBandScrollableElement >> updateVerticalProjectionBounds [
	| axis |

	(self height <= 0 or: [ self hasScrolledElement not or: [ self scrolledElement height <= 0 ] ])
		ifTrue: [ ^ self ].

	axis := projectionPlane vertical.
	axis
		minimum: self scrollMinimum y;
		maximum: self scrollMaximum y;
		dimension: (self height max: 1.0)
]

{ #category : 'private - debugging' }
CFBlRubberBandScrollableElement >> updateDebugOverlay [
	(debugOverlay notNil and: [ debugOverlay hasParent ])
		ifTrue: [
			debugOverlay text: self debugValuesString.
			debugOverlay requestLayout ].
	^ self
]

{ #category : 'private - debugging' }
CFBlRubberBandScrollableElement >> updateDebugOverlayLayout [
	debugOverlay ifNil: [ ^ self ].
	debugOverlay
		fitContent;
		zIndex: 1000;
		constraintsDo: [ :c |
			c frame horizontal alignRight.
			c frame vertical alignTop ].
	^ self
]

{ #category : 'accessing' }
CFBlRubberBandScrollableElement >> verticalAlignment [
	^ verticalAlignment
]

{ #category : 'accessing' }
CFBlRubberBandScrollableElement >> verticalAlignment: aBlElementAlignment [
	verticalAlignment := aBlElementAlignment.
	self requestLayout
]

{ #category : 'projection configuration' }
CFBlRubberBandScrollableElement >> vertical [
	| wasPresent axis |
	wasPresent := self hasProjectionPlane and: [ projectionPlane hasVertical ].
	axis := self projectionPlane vertical.
	wasPresent ifFalse: [ axis overscrollLimit: self defaultOverscrollLimit ].
	^ axis
]
