"
I describe a Mondrian element's displayed geometry in its parent's child coordinate system.

My responsibility is to apply the element's position and local transformation once so Physics-aware edge anchors can follow Motion presentation.
"
Class {
	#name : 'CFPhysicsMondrianDisplayedGeometry',
	#superclass : 'Object',
	#instVars : [ 'element' ],
	#category : 'BVC-Physics-Mondrian',
	#package : 'BVC-Physics-Mondrian'
}

{ #category : 'instance creation' }
CFPhysicsMondrianDisplayedGeometry class >> on: anElement [
	^ self new
		element: anElement;
		yourself
]

{ #category : 'accessing' }
CFPhysicsMondrianDisplayedGeometry >> element [
	^ element
]

{ #category : 'private - initialization' }
CFPhysicsMondrianDisplayedGeometry >> element: anElement [
	element := anElement
]

{ #category : 'geometry' }
CFPhysicsMondrianDisplayedGeometry >> bounds [
	^ Rectangle encompassing: self corners
]

{ #category : 'geometry' }
CFPhysicsMondrianDisplayedGeometry >> center [
	^ self bounds center
]

{ #category : 'geometry' }
CFPhysicsMondrianDisplayedGeometry >> corners [
	^ {
		self positionOfLocalPoint: 0 @ 0.
		self positionOfLocalPoint: element extent x @ 0.
		self positionOfLocalPoint: element extent x @ element extent y.
		self positionOfLocalPoint: 0 @ element extent y }
]

{ #category : 'geometry' }
CFPhysicsMondrianDisplayedGeometry >> positionOfLocalPoint: aPoint [
	^ (element transformation transformPoint: aPoint) + element position
]
