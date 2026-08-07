
"I adapt a Mondrian graph to Physics graph Behaviours."
Class {
	#name : 'CFPhysicsMondrianGraphAdapter',
	#superclass : 'CFPhysicsGraphAdapter',
	#category : 'BVC-Physics-Mondrian',
	#package : 'BVC-Physics-Mondrian'
}

{ #category : 'accessing' }
CFPhysicsMondrianGraphAdapter >> elementsFor: aMondrian [
	aMondrian physics synchroniseGraph.
	^ aMondrian nodeElements asArray
]

{ #category : 'accessing' }
CFPhysicsMondrianGraphAdapter >> edgesFor: aMondrian [
	| elements |
	elements := aMondrian nodeElements asIdentitySet.
	^ aMondrian edgeElements select: [ :edge |
		(elements includes: (self sourceElementFor: edge)) and: [
			elements includes: (self destinationElementFor: edge) ] ]
]

{ #category : 'accessing' }
CFPhysicsMondrianGraphAdapter >> sourceElementFor: anEdge [
	^ anEdge graph model fromElement
]

{ #category : 'accessing' }
CFPhysicsMondrianGraphAdapter >> destinationElementFor: anEdge [
	^ anEdge graph model toElement
]
