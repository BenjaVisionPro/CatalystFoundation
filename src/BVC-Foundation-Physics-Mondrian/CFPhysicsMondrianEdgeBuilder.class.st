Class {
	#name : 'CFPhysicsMondrianEdgeBuilder',
	#superclass : 'GtMondrianEdgeBuilder',
	#category : 'BVC-Foundation-Physics-Mondrian',
	#package : 'BVC-Foundation-Physics-Mondrian'
}

{ #category : #'scripting anchors' }
CFPhysicsMondrianEdgeBuilder >> fromNearestCircle [
	self fromAnchor: CFPhysicsMondrianNearestCircleAnchor
]

{ #category : 'scripting' }
CFPhysicsMondrianEdgeBuilder >> connect: aCollection from: aFromBlock to: aToBlock [
	| edges |
	edges := super
		connect: aCollection
		from: aFromBlock
		to: aToBlock.
	edges do: [ :each | each physics excludeFromWorld ].
	^ edges
]

{ #category : #'scripting anchors' }
CFPhysicsMondrianEdgeBuilder >> toNearestCircle [
	self toAnchor: CFPhysicsMondrianNearestCircleAnchor
]
