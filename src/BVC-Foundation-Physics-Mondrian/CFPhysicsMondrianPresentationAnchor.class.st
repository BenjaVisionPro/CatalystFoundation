"
I preserve an existing Mondrian anchor while physics presents its reference
elements through Motion transformations.

Mondrian graph authors continue to choose ordinary Bloc anchors. When physics
is enabled, I evaluate those anchors in the displayed coordinate system so
their edges remain attached to their moving nodes.
"
Class {
	#name : 'CFPhysicsMondrianPresentationAnchor',
	#superclass : 'BlGeometryAnchor',
	#instVars : [ 'anchor' ],
	#category : 'BVC-Foundation-Physics-Mondrian',
	#package : 'BVC-Foundation-Physics-Mondrian'
}

{ #category : 'instance creation' }
CFPhysicsMondrianPresentationAnchor class >> on: aGeometryAnchor [
	^ self new
		anchor: aGeometryAnchor;
		yourself
]

{ #category : 'accessing' }
CFPhysicsMondrianPresentationAnchor >> anchor [
	^ anchor
]

{ #category : 'private - initialization' }
CFPhysicsMondrianPresentationAnchor >> anchor: aGeometryAnchor [
	anchor := aGeometryAnchor
]

{ #category : #'anchor - lifecycle' }
CFPhysicsMondrianPresentationAnchor >> attachToAnchoredElement: anAnchoredElement [
	anchor attachToAnchoredElement: anAnchoredElement
]

{ #category : 'geometry' }
CFPhysicsMondrianPresentationAnchor >> computePositionWithin: anAnchoredElement [
	"Mondrian nodes and edges share a parent. Return directly in that parent’s
	children coordinates instead of applying Bloc's second global conversion."
	^ self
		positionForAnchoredElement: anAnchoredElement
		within: anAnchoredElement parent
]

{ #category : #'anchor - lifecycle' }
CFPhysicsMondrianPresentationAnchor >> detachFromAnchoredElement: anAnchoredElement [
	anchor detachFromAnchoredElement: anAnchoredElement
]

{ #category : 'private - geometry' }
CFPhysicsMondrianPresentationAnchor >> displayedBoundsOf: anElement in: aCommonParent [
	^ Rectangle encompassing: {
		self displayedPositionOf: anElement localPoint: 0 @ 0.
		self displayedPositionOf: anElement localPoint: anElement extent x @ 0.
		self displayedPositionOf: anElement localPoint: anElement extent x @ anElement extent y.
		self displayedPositionOf: anElement localPoint: 0 @ anElement extent y }
]

{ #category : 'private - geometry' }
CFPhysicsMondrianPresentationAnchor >> displayedPositionOf: anElement localPoint: aPoint [
	"An edge and its nodes are siblings. Return their shared child coordinates;
	the canvas applies its scale and translation to both exactly once."
	^ (anElement transformation transformPoint: aPoint) + anElement position
]

{ #category : 'testing - self anchors' }
CFPhysicsMondrianPresentationAnchor >> isSelfTo: anotherAnchor [
	^ anchor isSelfTo: (self unwrapped: anotherAnchor)
]

{ #category : 'testing - self anchors' }
CFPhysicsMondrianPresentationAnchor >> isSelfToAbsolute: anotherAnchor [
	^ anchor isSelfToAbsolute: (self unwrapped: anotherAnchor)
]

{ #category : 'testing - self anchors' }
CFPhysicsMondrianPresentationAnchor >> isSelfToRelative: anotherAnchor [
	^ anchor isSelfToRelative: (self unwrapped: anotherAnchor)
]

{ #category : 'private - geometry' }
CFPhysicsMondrianPresentationAnchor >> positionForAnchoredElement: anAnchoredElement within: aCommonParent [
	(anchor isKindOf: BlAnchorRelativeToAnchor) ifTrue: [
		^ self positionForRelativeToAnchor: anAnchoredElement within: aCommonParent ].
	(anchor isKindOf: BlAnchorRelativeToElement) ifTrue: [
		^ self positionForRelativeToElement: anAnchoredElement within: aCommonParent ].
	^ anchor
		positionForAnchoredElement: anAnchoredElement
		within: aCommonParent
]

{ #category : 'private - geometry' }
CFPhysicsMondrianPresentationAnchor >> positionForNearestBounds: anAnchoredElement within: aCommonParent [
	| referenceBounds nearestBounds edges path result |
	referenceBounds := self displayedBoundsOf: anchor referenceElement in: aCommonParent.
	nearestBounds := self displayedBoundsOf: anchor nearestToElement in: aCommonParent.
	edges := {
		(BlLineGeometry from: referenceBounds topLeft to: referenceBounds topRight).
		(BlLineGeometry from: referenceBounds topRight to: referenceBounds bottomRight).
		(BlLineGeometry from: referenceBounds bottomRight to: referenceBounds bottomLeft).
		(BlLineGeometry from: referenceBounds bottomLeft to: referenceBounds topLeft) }.
	path := BlLineGeometry from: referenceBounds center to: nearestBounds center.
	^ edges
		detect: [ :each |
			result := each intersectionWith: path.
			result isNotNil ]
		ifFound: [ result ]
		ifNone: [ referenceBounds center ]
]

{ #category : 'private - geometry' }
CFPhysicsMondrianPresentationAnchor >> positionForNearestCircle: anAnchoredElement within: aCommonParent [
	| referenceBounds nearestBounds direction radius |
	referenceBounds := self displayedBoundsOf: anchor referenceElement in: aCommonParent.
	nearestBounds := self displayedBoundsOf: anchor nearestToElement in: aCommonParent.
	direction := (nearestBounds center - referenceBounds center) asBlocVector.
	radius := ((referenceBounds extent r / 2.0) min: direction length).
	direction := direction length isZero
		ifTrue: [ BlVector x: 1 y: 0 ]
		ifFalse: [ direction normalized ].
	^ referenceBounds center + (direction * radius) asPoint
]

{ #category : 'private - geometry' }
CFPhysicsMondrianPresentationAnchor >> positionForNearestEllipse: anAnchoredElement within: aCommonParent [
	| major minor referenceBounds nearestBounds direction metric k x y intersection |
	referenceBounds := self displayedBoundsOf: anchor referenceElement in: aCommonParent.
	nearestBounds := self displayedBoundsOf: anchor nearestToElement in: aCommonParent.
	direction := (nearestBounds center - referenceBounds center) asBlocVector.
	major := referenceBounds width / 2.0.
	minor := referenceBounds height / 2.0.
	metric := ((major * major * direction y * direction y) +
		(minor * minor * direction x * direction x)) sqrt.
	k := metric isZero
		ifTrue: [ 0 ]
		ifFalse: [ (major * minor) / metric ].
	x := k * direction x.
	y := k * direction y.
	intersection := ((x @ y) distanceTo: direction) < ((x @ y) negated distanceTo: direction)
		ifTrue: [ x @ y ]
		ifFalse: [ (x @ y) negated ].
	^ referenceBounds center + intersection
]

{ #category : 'private - geometry' }
CFPhysicsMondrianPresentationAnchor >> positionForNearestTightCircle: anAnchoredElement within: aCommonParent [
	| referenceBounds nearestBounds direction radius |
	referenceBounds := self displayedBoundsOf: anchor referenceElement in: aCommonParent.
	nearestBounds := self displayedBoundsOf: anchor nearestToElement in: aCommonParent.
	direction := (nearestBounds center - referenceBounds center) asBlocVector.
	radius := (referenceBounds extent max / 2.0) min: direction length.
	direction := direction length isZero
		ifTrue: [ BlVector x: 1 y: 0 ]
		ifFalse: [ direction normalized ].
	^ referenceBounds center + (direction * radius) asPoint
]

{ #category : 'private - geometry' }
CFPhysicsMondrianPresentationAnchor >> positionForRelativeToAnchor: anAnchoredElement within: aCommonParent [
	| referenceAnchors |
	referenceAnchors := anchor referenceAnchors.
	^ [
		anchor referenceAnchors: (referenceAnchors collect: [ :each |
			self class on: each ]).
		anchor
			positionForAnchoredElement: anAnchoredElement
			within: aCommonParent ] ensure: [
			anchor referenceAnchors: referenceAnchors ]
]

{ #category : 'private - geometry' }
CFPhysicsMondrianPresentationAnchor >> positionForRelativeToElement: anAnchoredElement within: aCommonParent [
	(anchor isKindOf: BlNearestPositionBoundsAnchor) ifTrue: [
		^ self positionForNearestBounds: anAnchoredElement within: aCommonParent ].
	(anchor isKindOf: BlNearestPositionLooseCircleAnchor) ifTrue: [
		^ self positionForNearestCircle: anAnchoredElement within: aCommonParent ].
	(anchor isKindOf: BlNearestPositionTightCircleAnchor) ifTrue: [
		^ self positionForNearestTightCircle: anAnchoredElement within: aCommonParent ].
	(anchor isKindOf: BlNearestPositionEllipseAnchor) ifTrue: [
		^ self positionForNearestEllipse: anAnchoredElement within: aCommonParent ].
	(anchor isKindOf: BlAnchorRelativeToElementBounds) ifTrue: [
		^ self
			displayedPositionOf: anchor referenceElement
			localPoint: (anchor positionWithinBounds: anchor referenceElement bounds inLocal) ].
	^ self transformPosition: (anchor
		positionForAnchoredElement: anAnchoredElement
		within: aCommonParent)
	of: anchor referenceElement
	in: aCommonParent
]

{ #category : 'geometry' }
CFPhysicsMondrianPresentationAnchor >> selfPositionsForAnchoredElement: anAnchoredElement and: anotherAnchor within: aCommonParent [
	^ anchor
		selfPositionsForAnchoredElement: anAnchoredElement
		and: (self unwrapped: anotherAnchor)
		within: aCommonParent
]

{ #category : 'private - geometry' }
CFPhysicsMondrianPresentationAnchor >> transformPosition: aPoint of: anElement in: aCommonParent [
	| layoutOrigin localPosition |
	layoutOrigin := anElement position.
	localPosition := aPoint - layoutOrigin.
	^ self displayedPositionOf: anElement localPoint: localPosition
]

{ #category : 'private - accessing' }
CFPhysicsMondrianPresentationAnchor >> unwrapped: anotherAnchor [
	^ (anotherAnchor isKindOf: self class)
		ifTrue: [ anotherAnchor anchor ]
		ifFalse: [ anotherAnchor ]
]
