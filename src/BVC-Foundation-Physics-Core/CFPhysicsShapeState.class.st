Class {
	#name : 'CFPhysicsShapeState',
	#superclass : 'Object',
	#instVars : [ 'element', 'material' ],
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
CFPhysicsShapeState >> aabb [
	^ self aabbAt: 0 @ 0
]

{ #category : 'collision' }
CFPhysicsShapeState >> aabbAt: aPosition [
	| vertices minimum maximum |
	self isCircle ifTrue: [
		^ CFPhysicsAABB
			position: (self circleCentreAt: aPosition) - self radius asPoint
			extent: (self radius * 2.0) asPoint ].
	vertices := self collisionVerticesAt: aPosition.
	minimum := vertices first.
	maximum := vertices first.
	vertices allButFirst do: [ :each |
		minimum := (minimum x min: each x) @ (minimum y min: each y).
		maximum := (maximum x max: each x) @ (maximum y max: each y) ].
	^ CFPhysicsAABB position: minimum extent: maximum - minimum
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

{ #category : 'initialization' }
CFPhysicsShapeState >> initialize [
	super initialize.
	material := CFPhysicsMaterial new
]

{ #category : 'material' }
CFPhysicsShapeState >> material [
	^ material
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
CFPhysicsShapeState >> isPolygon [
	^ (element geometry isKindOf: BlPolygonGeometry)
		or: [ element geometry isKindOf: BlNormalizedPolygonGeometry ]
]

{ #category : 'testing' }
CFPhysicsShapeState >> isRectangle [
	^ self isCircle not and: [ self isPolygon not ]
]

{ #category : 'circle' }
CFPhysicsShapeState >> radius [
	^ self extent min / 2.0
]

{ #category : 'polygon' }
CFPhysicsShapeState >> collisionVerticesAt: aPosition [
	| localVertices |
	localVertices := self localCollisionVertices.
	^ localVertices collect: [ :each | each + aPosition ]
]

{ #category : 'polygon' }
CFPhysicsShapeState >> localCollisionVertices [
	| geometry anExtent |
	geometry := element geometry.
	anExtent := self extent.
	(geometry isKindOf: BlPolygonGeometry) ifTrue: [ ^ geometry vertices ].
	(geometry isKindOf: BlNormalizedPolygonGeometry) ifTrue: [
		^ geometry vertices collect: [ :each | (each x * anExtent x) @ (each y * anExtent y) ] ].
	^ { 0 @ 0. anExtent x @ 0. anExtent. 0 @ anExtent y }
]

{ #category : 'mass' }
CFPhysicsShapeState >> area [
	| vertices sum count |
	self isCircle ifTrue: [ ^ Float pi * self radius squared ].
	vertices := self localCollisionVertices.
	sum := 0.0.
	count := vertices size.
	1 to: count do: [ :index |
		| first second |
		first := vertices at: index.
		second := vertices at: (index = count ifTrue: [ 1 ] ifFalse: [ index + 1 ]).
		sum := sum + ((first x * second y) - (second x * first y)) ].
	^ sum abs / 2.0
]
