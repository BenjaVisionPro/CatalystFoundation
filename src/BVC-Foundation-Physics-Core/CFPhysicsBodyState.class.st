Class {
	#name : 'CFPhysicsBodyState',
	#superclass : 'Object',
	#instVars : [ 'element', 'world', 'position', 'rotation', 'presentation' ],
	#category : 'BVC-Foundation-Physics-Core',
	#package : 'BVC-Foundation-Physics-Core'
}

{ #category : 'instance creation' }
CFPhysicsBodyState class >> element: anElement world: aWorld [
	^ self new
		element: anElement;
		world: aWorld;
		yourself
]

{ #category : 'accessing' }
CFPhysicsBodyState >> element [
	^ element
]

{ #category : 'accessing' }
CFPhysicsBodyState >> element: anElement [
	element := anElement.
	presentation := CFPhysicsPresentation on: anElement
]

{ #category : 'initialization' }
CFPhysicsBodyState >> initialize [
	super initialize.
	position := 0 @ 0.
	rotation := 0
]

{ #category : 'presenting' }
CFPhysicsBodyState >> present [
	presentation presentTranslation: position rotation: rotation
]

{ #category : 'accessing' }
CFPhysicsBodyState >> position [
	^ position
]

{ #category : 'accessing' }
CFPhysicsBodyState >> position: aPoint [
	position := aPoint.
	self present
]

{ #category : 'accessing' }
CFPhysicsBodyState >> presentation [
	^ presentation
]

{ #category : 'controlling' }
CFPhysicsBodyState >> release [
	presentation release
]

{ #category : 'accessing' }
CFPhysicsBodyState >> rotation [
	^ rotation
]

{ #category : 'accessing' }
CFPhysicsBodyState >> rotation: aNumber [
	rotation := aNumber.
	self present
]

{ #category : 'presenting' }
CFPhysicsBodyState >> translation: aPoint rotation: aNumber [
	position := aPoint.
	rotation := aNumber.
	self present
]

{ #category : 'accessing' }
CFPhysicsBodyState >> world [
	^ world
]

{ #category : 'accessing' }
CFPhysicsBodyState >> world: aWorld [
	world := aWorld
]
