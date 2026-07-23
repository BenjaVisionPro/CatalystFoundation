Class {
	#name : 'CFPhysicsMondrian',
	#superclass : 'Object',
	#instVars : [ 'mondrian', 'world', 'graphSource', 'forceDirected' ],
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

{ #category : 'accessing' }
CFPhysicsMondrian >> forceDirected [
	^ forceDirected
]

{ #category : 'worlds' }
CFPhysicsMondrian >> beWorld [
	world ifNotNil: [ ^ world ].
	self prepareGraphElements.
	world := mondrian root physics beWorld.
	world synchroniseMembership.
	self adoptCurrentNodePositions.
	mondrian root layout: BlBasicLayout new.
	graphSource := self newGraphSource.
	forceDirected := mondrian root physics forceDirectedUsing: graphSource.
	self installGraphChangeHandlers.
	^ world
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

{ #category : 'private - graph source' }
CFPhysicsMondrian >> newGraphSource [
	^ CFPhysicsGraphSource
		nodes: [ mondrian nodeElements ]
		edges: [ mondrian edgeElements ]
		source: [ :edgeElement | edgeElement graph model fromElement ]
		target: [ :edgeElement | edgeElement graph model toElement ]
]

{ #category : 'private - events' }
CFPhysicsMondrian >> installGraphChangeHandlers [
	mondrian root
		when: BlElementAddedToSuperParentEvent
		do: [ :anEvent | self graphChanged ];
		when: BlElementRemovedFromSuperParentEvent
		do: [ :anEvent | self graphChanged ]
]

{ #category : 'private - events' }
CFPhysicsMondrian >> graphChanged [
	self prepareGraphElements.
	world synchroniseMembership
]

{ #category : 'private - initialization' }
CFPhysicsMondrian >> mondrian: aMondrian [
	mondrian := aMondrian
]
