Class {
	#name : 'CFPhysicsMondrian',
	#superclass : 'Object',
	#instVars : [ 'mondrian', 'world' ],
	#category : 'BVC-Foundation-Physics-Mondrian',
	#package : 'BVC-Foundation-Physics-Mondrian'
}

{ #category : 'instance creation' }
CFPhysicsMondrian class >> on: aMondrian [
	^ self new
		mondrian: aMondrian;
		yourself
]

{ #category : 'accessing' }
CFPhysicsMondrian >> mondrian [
	^ mondrian
]

{ #category : 'accessing' }
CFPhysicsMondrian >> world [
	^ world
]

{ #category : 'worlds' }
CFPhysicsMondrian >> beWorld [
	world ifNotNil: [ ^ world ].
	self prepareGraphElements.
	world := mondrian root physics beWorld.
	world synchroniseMembership.
	self adoptCurrentNodePositions.
	mondrian root
		disableAutoScale;
		layout: BlBasicLayout new.
	^ world
]

{ #category : 'behaviours' }
CFPhysicsMondrian >> forceDirected [
	| behaviour |
	self beWorld.
	behaviour := mondrian root physics forceDirected.
	behaviour
		nodes: [ mondrian nodeElements ];
		connections: [ self forceDirectedConnections ].
	^ behaviour
]

{ #category : 'private - behaviours' }
CFPhysicsMondrian >> forceDirectedConnections [
	^ mondrian edgeElements collect: [ :each |
		each graph model fromElement -> each graph model toElement ]
]

{ #category : 'private - world setup' }
CFPhysicsMondrian >> prepareGraphElements [
	mondrian edgeElements do: [ :each | each physics excludeFromWorld ]
]

{ #category : 'private - world setup' }
CFPhysicsMondrian >> adoptCurrentNodePositions [
	mondrian nodeElements do: [ :each |
		each physics position: each position ]
]

{ #category : 'private - initialization' }
CFPhysicsMondrian >> mondrian: aMondrian [
	mondrian := aMondrian
]
