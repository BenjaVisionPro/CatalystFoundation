"
I build Box2D-style chains and their connected chain-segment shapes.

For a loop, every edge receives the previous and next loop vertices as ghost vertices. This preserves adjacency for one-sided collision and ghost-collision suppression.
"
Class {
	#name : 'CFPhysicsChainBuilder',
	#superclass : 'Object',
	#category : 'BVC-Physics-Collision',
	#package : 'BVC-Physics-Collision'
}

{ #category : 'building' }
CFPhysicsChainBuilder class >> inwardLoopFrom: aCollection material: aMaterial collisionFilter: aFilter [
	^ self
		inwardLoopFrom: aCollection
		material: aMaterial
		collisionFilter: aFilter
		body: nil
]

{ #category : 'building' }
CFPhysicsChainBuilder class >> inwardLoopFrom: aCollection material: aMaterial collisionFilter: aFilter body: aBody [
	^ self
		loopFrom: aCollection reversed
		material: aMaterial
		collisionFilter: aFilter
		body: aBody
]

{ #category : 'building' }
CFPhysicsChainBuilder class >> loopFrom: aCollection material: aMaterial collisionFilter: aFilter [
	^ self
		loopFrom: aCollection
		material: aMaterial
		collisionFilter: aFilter
		body: nil
]

{ #category : 'building' }
CFPhysicsChainBuilder class >> loopFrom: aCollection material: aMaterial collisionFilter: aFilter body: aBody [
	| vertices chain segments count |
	vertices := aCollection asArray copy.
	self validateLoopVertices: vertices.
	chain := CFPhysicsChain new
		vertices: vertices;
		material: aMaterial;
		collisionFilter: aFilter;
		loop: true;
		body: aBody;
		yourself.
	count := vertices size.
	segments := Array new: count.
	1 to: count do: [ :index |
		| previousIndex nextIndex nextNextIndex |
		previousIndex := index = 1 ifTrue: [ count ] ifFalse: [ index - 1 ].
		nextIndex := index = count ifTrue: [ 1 ] ifFalse: [ index + 1 ].
		nextNextIndex := nextIndex = count ifTrue: [ 1 ] ifFalse: [ nextIndex + 1 ].
		segments
			at: index
			put: (CFPhysicsChainSegmentShape
				ghost1: (vertices at: previousIndex)
				point1: (vertices at: index)
				point2: (vertices at: nextIndex)
				ghost2: (vertices at: nextNextIndex)
				chain: chain
				segmentIndex: index) ].
	chain segments: segments.
	aBody ifNotNil: [ segments do: [ :segment | aBody shapeCollection add: segment ] ].
	^ chain
]

{ #category : 'validating' }
CFPhysicsChainBuilder class >> validateLoopVertices: vertices [
	vertices size < 4 ifTrue: [
		self error: 'A Box2D-style chain loop requires at least four vertices' ].
	1 to: vertices size do: [ :index |
		| nextIndex |
		nextIndex := index = vertices size ifTrue: [ 1 ] ifFalse: [ index + 1 ].
		(vertices at: index) = (vertices at: nextIndex) ifTrue: [
			self error: 'Adjacent chain vertices must be distinct' ] ]
]
