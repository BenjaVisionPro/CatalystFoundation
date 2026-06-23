Class {
	#name : 'CFBlRubberBandScrollableElement',
	#superclass : 'BlScrollableElement',
	#instVars : [
		'animator',
		'debugOverlay'
	],
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'accessing' }
CFBlRubberBandScrollableElement >> animator [
	^ animator
]

{ #category : 'accessing' }
CFBlRubberBandScrollableElement >> animator: anAnimator [
	animator := anAnimator.
	scrollPosition := animator motion logicalPosition.
	self updateDebugOverlay
]

{ #category : 'private - applying' }
CFBlRubberBandScrollableElement >> applyProjectedPosition [
	"Apply the projected motion position to the child element.
	Keep the inherited scrollPosition aligned with the limited logical position so existing
	scroll-bar queries continue to report logical scroll state."

	self limitLogicalPosition.
	scrollPosition := self motion logicalPosition.
	self scrolledElementDo: [ :anElement |
		anElement relocate: self motion projectedPosition ].
	self updateDebugOverlay
]


{ #category : 'private - applying' }
CFBlRubberBandScrollableElement >> limitLogicalPosition [
	"Re-apply the current projection limits to the stored logical position.
	This matters when layout later provides real viewport/content dimensions after
	a scroll position was set while the element was not yet measured."

	self motion hasProjectionPlane
		ifTrue: [ self motion moveTo: self motion logicalPosition ].
	^ self
]

{ #category : 'scrolling' }
CFBlRubberBandScrollableElement >> flingBy: aVelocityPoint [
	self hasScrolledElement
		ifFalse: [ ^ self ].
	self updateProjectionBounds.
	animator decelerateWithVelocity: aVelocityPoint negated.
	self updateDebugOverlay.
	^ self
]

{ #category : 'projection configuration' }
CFBlRubberBandScrollableElement >> horizontal [
	^ animator horizontal
]

{ #category : 'initialization' }
CFBlRubberBandScrollableElement >> initialize [
	super initialize.
	animator := CFRubberBandAnimator new.
	debugOverlay := nil.
	scrollPosition := animator motion logicalPosition
]

{ #category : 'accessing' }
CFBlRubberBandScrollableElement >> motion [
	^ animator motion
]

{ #category : 'layout' }
CFBlRubberBandScrollableElement >> onLayout: aBounds context: aBlElementBoundsUpdateContext [
	| previousProjectedPosition |

	self layout layout: self in: aBounds context: aBlElementBoundsUpdateContext.
	self hasScrolledElement
		ifFalse: [ ^ self ].

	previousProjectedPosition := self motion projectedPosition.
	self updateProjectionBounds.
	self applyProjectedPosition.
	self dispatchOnScrolled: self motion projectedPosition - previousProjectedPosition
]

{ #category : 'hooks - scrolling' }
CFBlRubberBandScrollableElement >> onScrolled: aPoint [
	super onScrolled: aPoint.
	self updateDebugOverlay
]

{ #category : 'scrolling' }
CFBlRubberBandScrollableElement >> scrollBy: aPoint [
	| previousProjectedPosition delta |

	self hasScrolledElement
		ifFalse: [ ^ false ].

	animator stop.
	self updateProjectionBounds.

	previousProjectedPosition := self motion projectedPosition.
	delta := self scrollDeltaFor: aPoint.
	delta = (0 @ 0)
		ifTrue: [ ^ false ].

	self motion moveBy: delta.
	self applyProjectedPosition.
	self dispatchOnScrolled: self motion projectedPosition - previousProjectedPosition.

	^ true
]

{ #category : 'private - scrolling' }
CFBlRubberBandScrollableElement >> scrollDeltaFor: aPoint [
	| plane dX dY |

	self motion hasProjectionPlane
		ifFalse: [ ^ 0 @ 0 ].

	plane := self motion projectionPlane.
	dX := (plane hasHorizontal and: [ self canScrollHorizontally ])
		ifTrue: [ aPoint x negated ]
		ifFalse: [ 0 ].
	dY := (plane hasVertical and: [ self canScrollVertically ])
		ifTrue: [ aPoint y negated ]
		ifFalse: [ 0 ].

	^ dX @ dY
]

{ #category : 'scrolling' }
CFBlRubberBandScrollableElement >> scrollHorizontallyBy: aNumber [
	| previousProjectedPosition |

	self hasScrolledElement
		ifFalse: [ ^ 0 ].
	self motion hasProjectionPlane
		ifFalse: [ ^ 0 ].
	self motion projectionPlane hasHorizontal
		ifFalse: [ ^ 0 ].

	animator stop.
	self updateProjectionBounds.
	previousProjectedPosition := self motion projectedPosition.
	self motion moveBy: aNumber asFloat @ 0.0.
	self applyProjectedPosition.
	self dispatchOnScrolled: self motion projectedPosition - previousProjectedPosition.

	^ aNumber
]

{ #category : 'api - scrolling geometry' }
CFBlRubberBandScrollableElement >> scrollPosition [
	^ self motion logicalPosition
]

{ #category : 'scrolling' }
CFBlRubberBandScrollableElement >> scrollTo: aPoint [
	| previousProjectedPosition |

	self hasScrolledElement
		ifFalse: [ ^ self ].

	animator stop.
	self updateProjectionBounds.
	previousProjectedPosition := self motion projectedPosition.
	self motion moveTo: aPoint.
	self applyProjectedPosition.
	self dispatchOnScrolled: self motion projectedPosition - previousProjectedPosition.
	^ self
]

{ #category : 'scrolling' }
CFBlRubberBandScrollableElement >> scrollVerticallyBy: aNumber [
	| previousProjectedPosition |

	self hasScrolledElement
		ifFalse: [ ^ 0 ].
	self motion hasProjectionPlane
		ifFalse: [ ^ 0 ].
	self motion projectionPlane hasVertical
		ifFalse: [ ^ 0 ].

	animator stop.
	self updateProjectionBounds.
	previousProjectedPosition := self motion projectedPosition.
	self motion moveBy: 0.0 @ aNumber asFloat.
	self applyProjectedPosition.
	self dispatchOnScrolled: self motion projectedPosition - previousProjectedPosition.

	^ aNumber
]

{ #category : 'scrolling' }
CFBlRubberBandScrollableElement >> settleToBounds [
	self updateProjectionBounds.
	animator settleToBounds.
	self updateDebugOverlay.
	^ self
]

{ #category : 'scrolling' }
CFBlRubberBandScrollableElement >> stepAnimationBy: deltaSeconds [
	animator stepBy: deltaSeconds.
	self applyProjectedPosition.
	^ self
]

{ #category : 'scrolling' }
CFBlRubberBandScrollableElement >> stopAnimation [
	animator stop.
	self updateDebugOverlay.
	^ self
]

{ #category : 'private - configuration' }
CFBlRubberBandScrollableElement >> updateHorizontalProjectionBounds [
	| axis |

	axis := self motion projectionPlane horizontal.
	axis
		minimum: ((self width - self scrolledElement width) min: 0.0);
		maximum: 0.0;
		dimension: (self width max: 1.0)
]

{ #category : 'private - configuration' }
CFBlRubberBandScrollableElement >> updateProjectionBounds [
	self hasScrolledElement
		ifFalse: [ ^ self ].
	self motion hasProjectionPlane
		ifFalse: [ ^ self ].
	self motion projectionPlane hasHorizontal
		ifTrue: [ self updateHorizontalProjectionBounds ].
	self motion projectionPlane hasVertical
		ifTrue: [ self updateVerticalProjectionBounds ].
	^ self
]

{ #category : 'private - configuration' }
CFBlRubberBandScrollableElement >> updateVerticalProjectionBounds [
	| axis |

	axis := self motion projectionPlane vertical.
	axis
		minimum: ((self height - self scrolledElement height) min: 0.0);
		maximum: 0.0;
		dimension: (self height max: 1.0)
]

{ #category : 'projection configuration' }
CFBlRubberBandScrollableElement >> vertical [
	^ animator vertical
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
			nextPutAll: 'mode: '; nextPutAll: animator mode asString; cr;
			nextPutAll: 'logical: '; nextPutAll: self motion logicalPosition asString; cr;
			nextPutAll: 'projected: '; nextPutAll: self motion projectedPosition asString; cr;
			nextPutAll: 'velocity: '; nextPutAll: self motion logicalVelocity asString; cr;
			nextPutAll: 'projected velocity: '; nextPutAll: self motion projectedVelocity asString; cr;
			nextPutAll: 'release target: '; nextPutAll: self motion releaseTargetPosition asString; cr;
			nextPutAll: 'overscroll: '; nextPutAll: self motion overscrollDistance asString; cr;
			nextPutAll: 'signed overscroll: '; nextPutAll: self motion signedOverscrollDistance asString; cr;
			nextPutAll: 'projected overscroll: '; nextPutAll: self motion projectedOverscrollDistance asString; cr;
			nextPutAll: 'velocity scale: '; nextPutAll: self motion velocityScale asString; cr;
			nextPutAll: 'in bounds: '; nextPutAll: self motion isInBounds asString; cr;
			nextPutAll: 'has horizontal: '; nextPutAll: self hasHorizontalProjectionForDebug asString; cr;
			nextPutAll: 'has vertical: '; nextPutAll: self hasVerticalProjectionForDebug asString ]
]

{ #category : 'debugging' }
CFBlRubberBandScrollableElement >> hasDebugOverlay [
	^ debugOverlay notNil and: [ debugOverlay hasParent ]
]

{ #category : 'private - debugging' }
CFBlRubberBandScrollableElement >> hasHorizontalProjectionForDebug [
	^ self motion hasProjectionPlane
		and: [ self motion projectionPlane hasHorizontal ]
]

{ #category : 'private - debugging' }
CFBlRubberBandScrollableElement >> hasVerticalProjectionForDebug [
	^ self motion hasProjectionPlane
		and: [ self motion projectionPlane hasVertical ]
]

{ #category : 'debugging' }
CFBlRubberBandScrollableElement >> hideDebugOverlay [
	debugOverlay ifNotNil: [
		debugOverlay hasParent
			ifTrue: [ debugOverlay removeFromParent ] ].
	^ self
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

{ #category : 'debugging' }
CFBlRubberBandScrollableElement >> showDebugOverlay [
	self hasScrolledElement
		ifFalse: [ ^ self ].
	self debugOverlay hasParent
		ifFalse: [ self addChild: self debugOverlay as: #rubberBandDebugOverlay ].
	self updateDebugOverlayLayout.
	self updateDebugOverlay.
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

{ #category : 'private - debugging' }
CFBlRubberBandScrollableElement >> updateDebugOverlay [
	(debugOverlay notNil and: [ debugOverlay hasParent ])
		ifTrue: [
			debugOverlay text: self debugValuesString.
			debugOverlay requestLayout ].
	^ self
]
