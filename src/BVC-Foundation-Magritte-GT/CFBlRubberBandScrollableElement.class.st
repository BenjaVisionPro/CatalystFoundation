Class {
	#name : 'CFBlRubberBandScrollableElement',
	#superclass : 'BlScrollableElement',
	#instVars : [
		'animator'
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
	scrollPosition := animator motion logicalPosition
]

{ #category : 'private - applying' }
CFBlRubberBandScrollableElement >> applyProjectedPosition [
	"Apply the projected motion position to the child element.
	Keep the inherited scrollPosition aligned with the logical position so existing
	scroll-bar queries continue to report logical scroll state."

	scrollPosition := self motion logicalPosition.
	self scrolledElementDo: [ :anElement |
		anElement relocate: self motion projectedPosition ]
]

{ #category : 'scrolling' }
CFBlRubberBandScrollableElement >> flingBy: aVelocityPoint [
	self hasScrolledElement
		ifFalse: [ ^ self ].
	self updateProjectionBounds.
	animator decelerateWithVelocity: aVelocityPoint negated.
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
