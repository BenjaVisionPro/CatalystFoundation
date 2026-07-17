Class {
	#name : 'CFPhysicsShapeState',
	#superclass : 'Object',
	#instVars : [ 'element' ],
	#category : 'BVC-Foundation-Physics-Core',
	#package : 'BVC-Foundation-Physics-Core'
}

{ #category : 'instance creation' }
CFPhysicsShapeState class >> on: anElement [
	^ self new
		element: anElement;
		yourself
]

{ #category : 'collision' }
CFPhysicsShapeState >> aabbAt: aPosition [
	^ CFPhysicsAABB position: aPosition extent: self extent
]

{ #category : 'accessing' }
CFPhysicsShapeState >> element [
	^ element
]

{ #category : 'accessing' }
CFPhysicsShapeState >> element: anElement [
	element := anElement
]

{ #category : 'geometry' }
CFPhysicsShapeState >> extent [
	^ element extent
]
