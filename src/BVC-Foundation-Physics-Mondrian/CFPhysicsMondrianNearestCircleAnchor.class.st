"
I anchor a Mondrian edge to the rendered position of a node.

Bloc's standard relative anchors derive their points from layout bounds. Physics
presents position and rotation as an element transformation, which layout bounds
do not include. I instead use the element's composed transformation directly,
in the coordinate system shared by sibling Mondrian nodes and edges.
"
Class {
	#name : 'CFPhysicsMondrianNearestCircleAnchor',
	#superclass : 'BlNearestPositionAnchor',
	#category : 'BVC-Foundation-Physics-Mondrian',
	#package : 'BVC-Foundation-Physics-Mondrian'
}

{ #category : 'accessing' }
CFPhysicsMondrianNearestCircleAnchor class >> label [
	^ 'Physics circle'
]

{ #category : 'geometry' }
CFPhysicsMondrianNearestCircleAnchor >> computePositionWithin: anAnchoredElement [
	"Both the edge and its nodes are siblings in a Mondrian step. The position
	returned here is therefore already in the edge parent's children coordinates."
	^ self
		positionForAnchoredElement: anAnchoredElement
		within: anAnchoredElement parent
]

{ #category : 'geometry' }
CFPhysicsMondrianNearestCircleAnchor >> positionForAnchoredElement: aGeometryElement within: aCommonParent [
	| referenceCenter nearestCenter direction radius |
	referenceCenter := self displayedCenterOf: self referenceElement.
	nearestCenter := self displayedCenterOf: self nearestToElement.
	direction := (nearestCenter - referenceCenter) asBlocVector.
	radius := ((self referenceElement extent r / 2.0) min: direction length).
	direction := direction length isZero
		ifTrue: [ BlVector x: 1 y: 0 ]
		ifFalse: [ direction normalized ].
	^ referenceCenter + (direction * radius) asPoint
]

{ #category : 'private - geometry' }
CFPhysicsMondrianNearestCircleAnchor >> displayedCenterOf: anElement [
	^ (anElement transformation transformPoint: anElement extent / 2.0)
		+ anElement position
]
