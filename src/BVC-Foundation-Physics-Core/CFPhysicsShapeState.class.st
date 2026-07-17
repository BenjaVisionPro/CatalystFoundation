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
	self isCircle ifTrue: [
		^ CFPhysicsAABB
			position: (self circleCentreAt: aPosition) - self radius asPoint
			extent: (self radius * 2.0) asPoint ].
	^ CFPhysicsAABB position: aPosition extent: self extent
]

{ #category : 'circle' }
CFPhysicsShapeState >> circleCentreAt: aPosition [
	^ aPosition + (self extent / 2.0)
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
	| computedExtent horizontal vertical |
	computedExtent := element extent.
	(computedExtent x > 0 and: [ computedExtent y > 0 ])
		ifTrue: [ ^ computedExtent ].
	horizontal := element constraints horizontal resizer.
	vertical := element constraints vertical resizer.
	(horizontal isExact and: [ vertical isExact ])
		ifTrue: [ ^ horizontal size @ vertical size ].
	^ computedExtent
]

{ #category : 'testing' }
CFPhysicsShapeState >> isCircle [
	^ element geometry isKindOf: BlCircleGeometry
]

{ #category : 'testing' }
CFPhysicsShapeState >> isRectangle [
	^ self isCircle not
]

{ #category : 'circle' }
CFPhysicsShapeState >> radius [
	^ self extent min / 2.0
]
