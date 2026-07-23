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
	mondrian root layout: BlBasicLayout new.
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

{ #category : 'private - events' }
CFPhysicsMondrian >> installGraphChangeHandlers [
	mondrian root
		when: BlElementAddedToSuperParentEvent
		do: [ :anEvent | self refreshWorldMembership ];
		when: BlElementRemovedFromSuperParentEvent
		do: [ :anEvent | self refreshWorldMembership ]
]

{ #category : 'private - events' }
CFPhysicsMondrian >> refreshWorldMembership [
	self prepareGraphElements.
	world synchroniseMembership
]

{ #category : 'private - initialization' }
CFPhysicsMondrian >> mondrian: aMondrian [
	mondrian := aMondrian
]
