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
CFPhysicsMondrianTests >> mondrianPhysicsBeWorldTracksAddedAndRemovedEdges [
	<gtExample>
	| mondrian edgeElements world behaviour |
	mondrian := GtMondrian new.
	mondrian nodes with: #(one two three).
	edgeElements := mondrian edges
		connectAssociations: { #one -> #two }.
	world := mondrian physics beWorld.
	behaviour := mondrian physics forceDirected.
	world step.
	self assert: behaviour springsByEdge size equals: 1.
	mondrian edges connectAssociations: { #two -> #three }.
	world step.
	self assert: behaviour springsByEdge size equals: 2.
	mondrian root removeChild: edgeElements first.
	world step.
	self assert: behaviour springsByEdge size equals: 1.
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
	self assert: mondrian physics forceDirected notNil.
	^ mondrian
]
