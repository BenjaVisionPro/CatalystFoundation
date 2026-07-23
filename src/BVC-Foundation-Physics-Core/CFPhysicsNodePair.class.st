"
I am an unordered identity pair used as a stable key for one repulsion between two graph nodes.
"
Class {
	#name : 'CFPhysicsNodePair',
	#superclass : 'Object',
	#instVars : [ 'first', 'second' ],
	#category : 'BVC-Foundation-Physics-Core-Behaviours',
	#package : 'BVC-Foundation-Physics-Core'
}

{ #category : 'instance creation' }
CFPhysicsNodePair class >> first: firstNode second: secondNode [
	^ self new first: firstNode; second: secondNode; yourself
]

{ #category : 'accessing' }
CFPhysicsNodePair >> first [ ^ first ]

{ #category : 'private - initialization' }
CFPhysicsNodePair >> first: anObject [ first := anObject ]

{ #category : 'accessing' }
CFPhysicsNodePair >> second [ ^ second ]

{ #category : 'private - initialization' }
CFPhysicsNodePair >> second: anObject [ second := anObject ]

{ #category : 'comparing' }
CFPhysicsNodePair >> = anotherPair [
	self class == anotherPair class ifFalse: [ ^ false ].
	^ (first == anotherPair first and: [ second == anotherPair second ])
		or: [ first == anotherPair second and: [ second == anotherPair first ] ]
]

{ #category : 'comparing' }
CFPhysicsNodePair >> hash [
	^ first identityHash bitXor: second identityHash
]
