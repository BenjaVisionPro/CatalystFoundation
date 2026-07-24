Class {
	#name : 'CFPhysicsMondrian',
	#superclass : 'Object',
	#instVars : [ 'mondrian', 'world', 'bodyElements' ],
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

{ #category : 'configuration' }
CFPhysicsMondrian >> bodyElements [
	"Answer the live collection of graph elements represented as Physics bodies."
	^ (bodyElements
		ifNil: [ mondrian nodeElements ]
		ifNotNil: [ :aCollectionOrProvider | aCollectionOrProvider value ]) asArray
]

{ #category : 'configuration' }
CFPhysicsMondrian >> bodyElements: aCollectionOrProvider [
	"Configure the graph elements represented as Physics bodies. The argument may
	be a collection or a zero-argument block, so live graph changes are supported."
	bodyElements := aCollectionOrProvider.
	world ifNotNil: [ world synchroniseMembership ].
	^ self
]

{ #category : 'accessing' }
CFPhysicsMondrian >> world [
	^ world
]

{ #category : 'worlds' }
CFPhysicsMondrian >> beWorld [
	world ifNotNil: [ ^ world ].
	world := mondrian root physics beWorld.
	world membershipProvider: [ self bodyElements ].
	self prepareGraphElements.
	self adoptCurrentNodePositions.
	self configureRootForPhysicsPresentation.
	self installPlaybackLifecycle.
	^ world
]

{ #category : 'behaviours' }
CFPhysicsMondrian >> forceDirected [
	| behaviour |
	self beWorld.
	behaviour := mondrian root physics forceDirected.
	behaviour
		nodes: [ self bodyElements ];
		connections: [ self forceDirectedConnections ].
	^ behaviour
]

{ #category : 'private - behaviours' }
CFPhysicsMondrian >> forceDirectedConnections [
	| currentBodyElements |
	currentBodyElements := self bodyElements asIdentitySet.
	^ (mondrian edgeElements collect: [ :each |
		each graph model fromElement -> each graph model toElement ]) select: [ :each |
		(currentBodyElements includes: each key) and: [
			currentBodyElements includes: each value ] ]
]

{ #category : 'private - world setup' }
CFPhysicsMondrian >> configureRootForPhysicsPresentation [
	mondrian root
		disableAutoScale;
		childrenScaleFactor: 1;
		childrenTranslationFactor: 0 @ 0;
		layout: BlBasicLayout new
]

{ #category : 'private - world setup' }
CFPhysicsMondrian >> installPlaybackLifecycle [
	mondrian root when: BlElementAddedToSceneGraphEvent do: [ :anEvent |
		world startStepping ].
	mondrian root isAddedToSceneGraph ifTrue: [ world startStepping ]
]

{ #category : 'private - world setup' }
CFPhysicsMondrian >> prepareGraphElements [
	mondrian edgeElements do: [ :each |
		self preparePhysicsPresentationOf: each ]
]

{ #category : 'private - world setup' }
CFPhysicsMondrian >> preparePhysicsPresentationOf: anEdgeElement [
	anEdgeElement physics excludeFromWorld.
	anEdgeElement fromAnchor: (CFPhysicsMondrianPresentationAnchor on: anEdgeElement fromAnchor).
	anEdgeElement toAnchor: (CFPhysicsMondrianPresentationAnchor on: anEdgeElement toAnchor)
]

{ #category : 'private - world setup' }
CFPhysicsMondrian >> adoptCurrentNodePositions [
	self bodyElements do: [ :each |
		each physics position: each position ]
]

{ #category : 'private - initialization' }
CFPhysicsMondrian >> mondrian: aMondrian [
	mondrian := aMondrian
]
