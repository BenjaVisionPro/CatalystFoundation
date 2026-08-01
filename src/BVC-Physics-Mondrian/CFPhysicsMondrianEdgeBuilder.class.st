"
I build Mondrian edges that remain attached while Physics presents their nodes.

My responsibility is to prepare each newly created edge with the Physics-aware presentation anchors owned by its Mondrian facade.
"
Class {
	#name : 'CFPhysicsMondrianEdgeBuilder',
	#superclass : 'GtMondrianEdgeBuilder',
	#category : 'BVC-Physics-Mondrian',
	#package : 'BVC-Physics-Mondrian'
}

{ #category : 'scripting' }
CFPhysicsMondrianEdgeBuilder >> connect: aCollection from: aFromBlock to: aToBlock [
	| edges |
	edges := super
		connect: aCollection
		from: aFromBlock
		to: aToBlock.
	edges do: [ :each |
		mondrian physics preparePhysicsPresentationOf: each ].
	^ edges
]
