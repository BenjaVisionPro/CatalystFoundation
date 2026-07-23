Class {
	#name : 'CFPhysicsMondrianTests',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Physics-Tests',
	#package : 'BVC-Foundation-Physics-Tests'
}

{ #category : 'examples' }
CFPhysicsMondrianTests >> mondrianPhysicsBeWorldAdoptsExistingNodes [
	<gtExample>
	| mondrian nodes world |
	mondrian := GtMondrian new.
	nodes := mondrian nodes with: #(one two three).
	nodes withIndexDo: [ :each :index | each relocate: (index * 30) @ (index * 20) ].
	world := mondrian physics beWorld.
	self assert: world owner == mondrian root.
	self assert: world members size equals: 3.
	nodes do: [ :each |
		self assert: each physics position equals: each position ].
	^ mondrian
]

{ #category : 'examples' }
CFPhysicsMondrianTests >> mondrianPhysicsBeWorldTracksAddedAndRemovedNodes [
	<gtExample>
	| mondrian initial added world |
	mondrian := GtMondrian new.
	initial := mondrian nodes with: #(one two).
	world := mondrian physics beWorld.
	added := (mondrian nodes with: #(three)) first.
	world synchroniseMembership.
	self assert: (world includes: added).
	mondrian root removeChild: initial first.
	world synchroniseMembership.
	self assert: (world includes: initial first) not.
	^ mondrian
]

{ #category : 'examples' }
CFPhysicsMondrianTests >> mondrianPhysicsBeWorldExcludesEdges [
	<gtExample>
	| mondrian edgeElements world |
	mondrian := GtMondrian new.
	mondrian nodes with: #(one two three).
	edgeElements := mondrian edges
		connectAssociations: { #one -> #two }.
	world := mondrian physics beWorld.
	self assert: (world includes: edgeElements first) not.
	mondrian edges connectAssociations: { #two -> #three }.
	world synchroniseMembership.
	self assert: world members size equals: 3.
	^ mondrian
]

{ #category : 'examples' }
CFPhysicsMondrianTests >> mondrianPhysicsBeWorldIsIdempotent [
	<gtExample>
	| mondrian firstWorld secondWorld |
	mondrian := GtMondrian new.
	mondrian nodes with: #(one two).
	firstWorld := mondrian physics beWorld.
	secondWorld := mondrian physics beWorld.
	self assert: firstWorld == secondWorld.
	^ mondrian
]

{ #category : 'examples' }
CFPhysicsMondrianTests >> mondrianPhysicsUsesDefaultGravityWithoutABehaviour [
	<gtExample>
	| mondrian nodes initialPositions world |
	mondrian := GtMondrian new.
	mondrian root
		size: 920 @ 620;
		background: Color veryVeryLightGray.
	mondrian nodes with: (1 to: 12).
	nodes := mondrian nodeElements.
	nodes withIndexDo: [ :each :index |
		each
			size: 62 @ 34;
			relocate: 24 + ((index - 1) * 74) @ (28 + (index * 6)) ].
	initialPositions := nodes collect: [ :each | each position ].
	world := mondrian physics beWorld.
	self assert: world gravity equals: 0 @ 1000.
	world step: 80.
	nodes with: initialPositions do: [ :each :initialPosition |
		self assert: each physics position y > initialPosition y ].
	^ mondrian
]

{ #category : 'examples' }
CFPhysicsMondrianTests >> mondrianPhysicsForceDirectedUsesLiveMondrianConnections [
	<gtExample>
	| mondrian world behaviour |
	mondrian := GtMondrian new.
	mondrian nodes with: #(one two three).
	mondrian edges connectAssociations: { #one -> #two }.
	world := mondrian physics beWorld.
	world gravity: 0 @ 0.
	behaviour := mondrian physics forceDirected.
	world step.
	self assert: behaviour springsByConnection size equals: 1.
	self assert: behaviour repulsionsByPair size equals: 3.
	mondrian edges connectAssociations: { #two -> #three }.
	world step.
	self assert: behaviour springsByConnection size equals: 2.
	^ mondrian
]

{ #category : 'examples' }
CFPhysicsMondrianTests >> mondrianPhysicsForceDirectedTracksAddedNodes [
	<gtExample>
	| mondrian added addedEdge world behaviour |
	mondrian := GtMondrian new.
	mondrian nodes with: #(one two).
	mondrian edges connectAssociations: { #one -> #two }.
	world := mondrian physics beWorld.
	world gravity: 0 @ 0.
	behaviour := mondrian physics forceDirected.
	world step.
	self assert: world members size equals: 2.
	self assert: behaviour springsByConnection size equals: 1.
	self assert: behaviour repulsionsByPair size equals: 1.
	added := (mondrian nodes with: #(three)) first.
	addedEdge := (mondrian edges connectAssociations: { #two -> #three }) first.
	world step.
	self assert: (world includes: added).
	self assert: world members size equals: 3.
	self assert: behaviour springsByConnection size equals: 2.
	self assert: behaviour repulsionsByPair size equals: 3.
	mondrian root removeChild: addedEdge.
	world step.
	self assert: behaviour springsByConnection size equals: 1.
	self assert: behaviour repulsionsByPair size equals: 3.
	^ mondrian
]
