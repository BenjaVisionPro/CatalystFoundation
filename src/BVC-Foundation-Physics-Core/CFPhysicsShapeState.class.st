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
	| vertices sum count radius anExtent |
	self isCircle ifTrue: [ ^ Float pi * self radius squared ].
	self isRoundedRectangle ifTrue: [
		radius := self roundedRectangleRadius.
		anExtent := self extent.
		^ (anExtent x * anExtent y) - ((4.0 - Float pi) * radius squared) ].
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


{ #category : 'testing' }
CFPhysicsShapeState >> isRoundedRectangle [
	^ element geometry isKindOf: BlRoundedRectangleGeometry
]

{ #category : 'testing' }
CFPhysicsShapeState >> isRectangle [
	^ self isCircle not
		and: [ self isPolygon not
			and: [ self isRoundedRectangle not ] ]
]

{ #category : 'convex support' }
CFPhysicsShapeState >> centreAt: aPosition [
	^ aPosition + (self extent / 2.0)
]

{ #category : 'convex support' }
CFPhysicsShapeState >> supportPointAt: aPosition inDirection: aDirection [
	| direction |
	direction := aDirection r = 0
		ifTrue: [ 1 @ 0 ]
		ifFalse: [ aDirection / aDirection r ].
	self isCircle ifTrue: [
		^ (self circleCentreAt: aPosition) + (direction * self radius) ].
	self isRoundedRectangle ifTrue: [
		^ self roundedRectangleSupportPointAt: aPosition inDirection: direction ].
	^ self supportPointOf: (self collisionVerticesAt: aPosition) inDirection: direction
]

{ #category : 'convex support' }
CFPhysicsShapeState >> supportPointOf: vertices inDirection: direction [
	| best bestProjection projection |
	best := vertices first.
	bestProjection := (best x * direction x) + (best y * direction y).
	vertices allButFirst do: [ :each |
		projection := (each x * direction x) + (each y * direction y).
		projection > bestProjection ifTrue: [
			best := each.
			bestProjection := projection ] ].
	^ best
]

{ #category : 'rounded rectangle' }
CFPhysicsShapeState >> roundedRectangleRadius [
	| radii radius |
	radii := element geometry cornerRadii.
	radius := radii topLeft.
	((radii topRight = radius)
		and: [ radii bottomRight = radius
			and: [ radii bottomLeft = radius ] ])
		ifFalse: [ self error: 'Physics currently requires equal rounded-rectangle corner radii' ].
	^ radius min: (self extent min / 2.0)
]

{ #category : 'rounded rectangle' }
CFPhysicsShapeState >> roundedRectangleSupportPointAt: aPosition inDirection: direction [
	| anExtent radius innerPoint |
	anExtent := self extent.
	radius := self roundedRectangleRadius.
	radius = 0 ifTrue: [
		^ self supportPointOf: (self collisionVerticesAt: aPosition) inDirection: direction ].
	innerPoint :=
		(direction x >= 0 ifTrue: [ anExtent x - radius ] ifFalse: [ radius ])
		@
		(direction y >= 0 ifTrue: [ anExtent y - radius ] ifFalse: [ radius ]).
	^ aPosition + innerPoint + (direction * radius)
]
