"
I describe a Mondrian element in the coordinate system shared by its sibling
edges. Motion transformations are already applied by Bloc during rendering, so
I apply each element's local transformation and position exactly once.
"
Class {
	#name : 'CFPhysicsMondrianDisplayedGeometry',
	#superclass : 'Object',
	#instVars : [ 'element' ],
	#category : 'BVC-Foundation-Physics-Mondrian',
	#package : 'BVC-Foundation-Physics-Mondrian'
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
