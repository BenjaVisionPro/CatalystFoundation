"
I build Mondrian nodes that participate in an active Physics world.

My responsibility is to enrol each newly created Mondrian node through the ordinary element Physics API.
"
Class {
	#name : 'CFPhysicsMondrianNodeBuilder',
	#superclass : 'GtMondrianNodeBuilder',
	#category : 'BVC-Physics-Mondrian',
	#package : 'BVC-Physics-Mondrian'
}

{ #category : 'scripting' }
CFPhysicsMondrianNodeBuilder >> with: aCollection [
	| elements |
	elements := super with: aCollection.
	mondrian physics addNodeElements: elements.
	^ elements
]
