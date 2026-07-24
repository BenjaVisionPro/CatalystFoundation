Class {
	#name : 'CFPhysicsMondrian',
	#superclass : 'Object',
	#instVars : [ 'mondrian', 'world', 'bodyElements', 'originalRootLayout', 'originalAutoScaleEnabled', 'originalChildrenScaleFactor', 'originalChildrenTranslationFactor', 'playbackHandler', 'preexistingPhysicsElements', 'sessionPhysicsElements' ],
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
	| elements |
	elements := (bodyElements
		ifNil: [ mondrian nodeElements ]
		ifNotNil: [ :aCollectionOrProvider | aCollectionOrProvider value ]) asArray.
	sessionPhysicsElements ifNotNil: [ sessionPhysicsElements addAll: elements ].
	^ elements
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
	self captureOriginalPresentation.
	world := mondrian root physics beWorld.
	world membershipProvider: [ self bodyElements ].
	self prepareGraphElements.
	self adoptCurrentNodePositions.
	self configureRootForPhysicsPresentation.
	self installPlaybackLifecycle.
	^ world
]

{ #category : 'worlds' }
CFPhysicsMondrian >> ceaseBeingWorld [
	| formerWorld |
	world ifNil: [ ^ self ].
	formerWorld := world.
	self removePlaybackLifecycle.
	formerWorld stopStepping.
	self restoreGraphPresentation.
	mondrian root physics ceaseBeingWorld.
	self removeSessionPhysicsFacadesFrom: formerWorld.
	world := nil.
	mondrian root userData removeKey: CFPhysicsMondrian ifAbsent: [ ].
	^ self
]

{ #category : 'behaviours' }
CFPhysicsMondrian >> forceDirected [
	| behaviour hierarchy orientation |
	self beWorld.
	behaviour := mondrian root physics forceDirected.
	behaviour
		nodes: [ self bodyElements ];
		connections: [ self forceDirectedConnections ];
		restLength: 104.0;
		stiffness: 480.0;
		damping: 520.0;
		repulsion: 72000.0;
		repulsionSofteningDistance: 58.0;
		maximumRepulsionDistance: 175.0;
		velocityDamping: 10.0.
	hierarchy := mondrian root physics addBehaviour:
		(CFPhysicsMondrianHierarchyBehaviour physics: mondrian root physics).
	hierarchy
		nodes: [ self bodyElements ];
		connections: [ self forceDirectedConnections ];
		centre: [ mondrian root extent / 2.0 ].
	orientation := mondrian root physics restoreOrientations.
	orientation
		nodes: [ self bodyElements ];
		density: 2.5;
		angularDamping: 8.0;
		stiffness: 36.0;
		damping: 6.0;
		maximumAngularAcceleration: 30.0.
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
CFPhysicsMondrian >> captureOriginalPresentation [
	| root |
	root := mondrian root.
	originalRootLayout := root layout.
	originalAutoScaleEnabled := root autoScaleEnabled.
	originalChildrenScaleFactor := root childrenScaleFactor.
	originalChildrenTranslationFactor := root childrenTranslationFactor.
	preexistingPhysicsElements := IdentitySet new.
	sessionPhysicsElements := IdentitySet new.
	sessionPhysicsElements add: root.
	mondrian edgeElements do: [ :each | sessionPhysicsElements add: each ].
	self sessionElements do: [ :each |
		each existingPhysics ifNotNil: [ preexistingPhysicsElements add: each ] ]
]

{ #category : 'private - world setup' }
CFPhysicsMondrian >> installPlaybackLifecycle [
	playbackHandler ifNil: [
		playbackHandler := BlEventHandler
			on: BlElementAddedToSceneGraphEvent
			do: [ :anEvent | world startStepping ].
		mondrian root addEventHandler: playbackHandler ].
	mondrian root isAddedToSceneGraph ifTrue: [ world startStepping ]
]

{ #category : 'private - world setup' }
CFPhysicsMondrian >> removePlaybackLifecycle [
	playbackHandler ifNotNil: [
		mondrian root removeEventHandler: playbackHandler.
		playbackHandler := nil ]
]

{ #category : 'private - world setup' }
CFPhysicsMondrian >> prepareGraphElements [
	mondrian edgeElements do: [ :each |
		self preparePhysicsPresentationOf: each ]
]

{ #category : 'private - world setup' }
CFPhysicsMondrian >> preparePhysicsPresentationOf: anEdgeElement [
	sessionPhysicsElements ifNotNil: [ sessionPhysicsElements add: anEdgeElement ].
	anEdgeElement physics excludeFromWorld.
	anEdgeElement fromAnchor: (CFPhysicsMondrianPresentationAnchor on: anEdgeElement fromAnchor).
	anEdgeElement toAnchor: (CFPhysicsMondrianPresentationAnchor on: anEdgeElement toAnchor)
]

{ #category : 'private - world setup' }
CFPhysicsMondrian >> adoptCurrentNodePositions [
	self bodyElements do: [ :each |
		each physics position: each position ]
]

{ #category : 'private - teardown' }
CFPhysicsMondrian >> removeSessionPhysicsFacadesFrom: aWorld [
	self sessionElementsFrom: aWorld do: [ :each |
		(preexistingPhysicsElements includes: each) ifFalse: [
			each userData removeKey: CFPhysics ifAbsent: [ ] ] ].
	preexistingPhysicsElements := nil.
	sessionPhysicsElements := nil
]

{ #category : 'private - teardown' }
CFPhysicsMondrian >> restoreGraphPresentation [
	mondrian edgeElements do: [ :each |
		each fromAnchor: (self unwrappedPresentationAnchor: each fromAnchor).
		each toAnchor: (self unwrappedPresentationAnchor: each toAnchor) ].
	mondrian root
		layout: originalRootLayout;
		childrenScaleFactor: originalChildrenScaleFactor;
		childrenTranslationFactor: originalChildrenTranslationFactor.
	originalAutoScaleEnabled
		ifTrue: [ mondrian root enableAutoScale ]
		ifFalse: [ mondrian root disableAutoScale ].
	originalRootLayout := nil.
	originalAutoScaleEnabled := nil.
	originalChildrenScaleFactor := nil.
	originalChildrenTranslationFactor := nil
]

{ #category : 'private - teardown' }
CFPhysicsMondrian >> sessionElements [
	^ self sessionElementsFrom: world
]

{ #category : 'private - teardown' }
CFPhysicsMondrian >> sessionElementsFrom: aWorld [
	| elements |
	elements := IdentitySet new.
	elements add: mondrian root.
	sessionPhysicsElements ifNotNil: [ elements addAll: sessionPhysicsElements ].
	self bodyElements do: [ :each | elements add: each ].
	aWorld ifNotNil: [
		aWorld bodyStatesInOrder do: [ :each | elements add: each element ] ].
	mondrian edgeElements do: [ :each | elements add: each ].
	^ elements
]

{ #category : 'private - teardown' }
CFPhysicsMondrian >> sessionElementsFrom: aWorld do: aBlock [
	(self sessionElementsFrom: aWorld) do: aBlock
]

{ #category : 'private - teardown' }
CFPhysicsMondrian >> unwrappedPresentationAnchor: anAnchor [
	^ (anAnchor isKindOf: CFPhysicsMondrianPresentationAnchor)
		ifTrue: [ anAnchor anchor ]
		ifFalse: [ anAnchor ]
]

{ #category : 'private - initialization' }
CFPhysicsMondrian >> mondrian: aMondrian [
	mondrian := aMondrian
]
