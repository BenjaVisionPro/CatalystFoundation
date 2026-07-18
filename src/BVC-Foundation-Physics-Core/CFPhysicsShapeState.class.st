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
	^ self aabbAt: aPosition rotation: 0
]

{ #category : 'collision' }
CFPhysicsShapeState >> aabbAt: aPosition rotation: anAngle [
	| left right top bottom minimum maximum |
	left := self supportPointAt: aPosition rotation: anAngle inDirection: -1 @ 0.
	right := self supportPointAt: aPosition rotation: anAngle inDirection: 1 @ 0.
	top := self supportPointAt: aPosition rotation: anAngle inDirection: 0 @ -1.
	bottom := self supportPointAt: aPosition rotation: anAngle inDirection: 0 @ 1.
	minimum := left x @ top y.
	maximum := right x @ bottom y.
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
	^ self collisionVerticesAt: aPosition rotation: 0
]

{ #category : 'polygon' }
CFPhysicsShapeState >> collisionVerticesAt: aPosition rotation: anAngle [
	| centre collisionRotation |
	centre := self extent / 2.0.
	collisionRotation := self collisionRotationFor: anAngle.
	^ self localCollisionVertices collect: [ :each |
		aPosition + (self rotate: each around: centre by: collisionRotation) ]
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
	^ self supportPointAt: aPosition rotation: 0 inDirection: aDirection
]

{ #category : 'convex support' }
CFPhysicsShapeState >> supportPointAt: aPosition rotation: anAngle inDirection: aDirection [
	| direction localDirection localPoint centre collisionRotation |
	direction := aDirection r = 0
		ifTrue: [ 1 @ 0 ]
		ifFalse: [ aDirection / aDirection r ].
	self isCircle ifTrue: [
		^ (self circleCentreAt: aPosition) + (direction * self radius) ].
	collisionRotation := self collisionRotationFor: anAngle.
	localDirection := self rotateVector: direction by: collisionRotation negated.
	localPoint := self localSupportPointInDirection: localDirection.
	centre := self extent / 2.0.
	^ aPosition + (self rotate: localPoint around: centre by: collisionRotation)
]

{ #category : 'convex support' }
CFPhysicsShapeState >> localSupportPointInDirection: direction [
	self isRoundedRectangle ifTrue: [
		^ self roundedRectangleLocalSupportPointInDirection: direction ].
	^ self supportPointOf: self localCollisionVertices inDirection: direction
]

{ #category : 'geometry' }
CFPhysicsShapeState >> rotate: aPoint around: aCentre by: anAngle [
	| translated cosine sine |
	anAngle = 0 ifTrue: [ ^ aPoint ].
	translated := aPoint - aCentre.
	cosine := anAngle cos.
	sine := anAngle sin.
	^ aCentre +
		(((translated x * cosine) - (translated y * sine))
		@ ((translated x * sine) + (translated y * cosine)))
]

{ #category : 'geometry' }
CFPhysicsShapeState >> rotateVector: aPoint by: anAngle [
	| cosine sine |
	anAngle = 0 ifTrue: [ ^ aPoint ].
	cosine := anAngle cos.
	sine := anAngle sin.
	^ ((aPoint x * cosine) - (aPoint y * sine))
		@ ((aPoint x * sine) + (aPoint y * cosine))
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
	^ aPosition + (self roundedRectangleLocalSupportPointInDirection: direction)
]

{ #category : 'rounded rectangle' }
CFPhysicsShapeState >> roundedRectangleLocalSupportPointInDirection: direction [
	| anExtent radius innerPoint innerX innerY unitDirection |
	anExtent := self extent.
	radius := self roundedRectangleRadius.
	radius = 0 ifTrue: [
		^ self supportPointOf: self localCollisionVertices inDirection: direction ].
	unitDirection := direction r = 0
		ifTrue: [ 1 @ 0 ]
		ifFalse: [ direction / direction r ].
	innerX := unitDirection x = 0
		ifTrue: [ anExtent x / 2.0 ]
		ifFalse: [ unitDirection x > 0 ifTrue: [ anExtent x - radius ] ifFalse: [ radius ] ].
	innerY := unitDirection y = 0
		ifTrue: [ anExtent y / 2.0 ]
		ifFalse: [ unitDirection y > 0 ifTrue: [ anExtent y - radius ] ifFalse: [ radius ] ].
	innerPoint := innerX @ innerY.
	^ innerPoint + (unitDirection * radius)
]

{ #category : 'geometry' }
CFPhysicsShapeState >> collisionRotationFor: anAngle [
	| fullTurn quarterTurn normalized |
	fullTurn := Float pi * 2.0.
	quarterTurn := Float pi / 2.0.
	normalized := anAngle \\ fullTurn.
	(normalized closeTo: 0.0) ifTrue: [ ^ 0.0 ].
	(normalized closeTo: quarterTurn) ifTrue: [ ^ quarterTurn ].
	(normalized closeTo: Float pi) ifTrue: [ ^ Float pi ].
	(normalized closeTo: quarterTurn * 3.0) ifTrue: [ ^ quarterTurn * 3.0 ].
	(normalized closeTo: fullTurn) ifTrue: [ ^ 0.0 ].
	^ normalized
]
