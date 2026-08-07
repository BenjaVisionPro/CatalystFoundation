
"
I adapt an application graph to the protocol required by Physics graph Behaviours.

Users configure me with blocks when their target has a custom graph model. Specialised adapters may override my query methods instead.
"
Class {
	#name : 'CFPhysicsGraphAdapter',
	#superclass : 'Object',
	#instVars : [ 'elementsBlock', 'edgesBlock', 'sourceElementBlock', 'destinationElementBlock' ],
	#category : 'BVC-Physics-Behaviours',
	#package : 'BVC-Physics-Behaviours'
}

{ #category : 'configuration' }
CFPhysicsGraphAdapter >> elementsBlock: aBlock [
	elementsBlock := aBlock.
	^ self
]

{ #category : 'configuration' }
CFPhysicsGraphAdapter >> edgesBlock: aBlock [
	edgesBlock := aBlock.
	^ self
]

{ #category : 'configuration' }
CFPhysicsGraphAdapter >> sourceElementBlock: aBlock [
	sourceElementBlock := aBlock.
	^ self
]

{ #category : 'configuration' }
CFPhysicsGraphAdapter >> destinationElementBlock: aBlock [
	destinationElementBlock := aBlock.
	^ self
]

{ #category : 'accessing' }
CFPhysicsGraphAdapter >> elementsFor: aTarget [
	elementsBlock ifNil: [ self error: 'A graph adapter requires an elements block' ].
	^ (elementsBlock value: aTarget) asArray
]

{ #category : 'accessing' }
CFPhysicsGraphAdapter >> edgesFor: aTarget [
	edgesBlock ifNil: [ self error: 'A graph adapter requires an edges block' ].
	^ (edgesBlock value: aTarget) asArray
]

{ #category : 'accessing' }
CFPhysicsGraphAdapter >> sourceElementFor: anEdge [
	sourceElementBlock ifNil: [ self error: 'A graph adapter requires a source-element block' ].
	^ sourceElementBlock value: anEdge
]

{ #category : 'accessing' }
CFPhysicsGraphAdapter >> destinationElementFor: anEdge [
	destinationElementBlock ifNil: [ self error: 'A graph adapter requires a destination-element block' ].
	^ destinationElementBlock value: anEdge
]
