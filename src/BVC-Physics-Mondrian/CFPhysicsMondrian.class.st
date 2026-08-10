"
I integrate one Mondrian graph with a Physics world.

My responsibility is to manage the graph's participating elements, Physics Behaviours, playback lifecycle and presentation changes, and to restore the original Mondrian state when the integration ends.
"
Class {
	#name : 'CFPhysicsMondrian',
	#superclass : 'Object',
	#instVars : [ 'mondrian', 'world', 'worldPhysics', 'originalRootLayout', 'originalAutoScaleEnabled', 'originalChildrenScaleFactor', 'originalChildrenTranslationFactor', 'playbackHandler', 'sessionPhysicsFacades' ],
	#category : 'BVC-Physics-Mondrian',
	#package : 'BVC-Physics-Mondrian'
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

{ #category : 'worlds' }
CFPhysicsMondrian >> world [
	^ world
]

{ #category : 'worlds' }
CFPhysicsMondrian >> beWorld [
	world ifNotNil: [ ^ world ].
	self captureOriginalPresentation.
	worldPhysics := self physicsForSessionElement: mondrian root.
	world := worldPhysics beWorld.
	self addNodeElements: mondrian nodeElements.
	self prepareGraphElements.
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
	worldPhysics ceaseBeingWorld.
	self removeSessionPhysicsFacades.
	worldPhysics := nil.
	world := nil.
	mondrian root userData removeKey: CFPhysicsMondrian ifAbsent: [ ].
	^ self
]

{ #category : 'behaviours' }
CFPhysicsMondrian >> forceDirected [
	self prepareForceDirectedStartingPositions.
	self beWorld.
	^ CFPhysicsForceDirectedBehaviour new
		target: mondrian;
		adapter: CFPhysicsMondrianGraphAdapter new;
		start
]

{ #category : 'private - behaviours' }
CFPhysicsMondrian >> prepareForceDirectedStartingPositions [
	mondrian layout force.
	mondrian root forceLayout.
	world ifNotNil: [
		mondrian nodeElements do: [ :each |
			(world includes: each) ifTrue: [ each physics position: each position ] ].
		self configureRootForPhysicsPresentation ].
	^ self
]


{ #category : 'behaviours' }
CFPhysicsMondrian >> forceDirectedTree [
	self beWorld.
	^ CFPhysicsForceDirectedTreeBehaviour new
		target: mondrian;
		adapter: CFPhysicsMondrianGraphAdapter new;
		start
]

{ #category : 'graph synchronisation' }
CFPhysicsMondrian >> synchroniseGraph [
	mondrian nodeElements do: [ :element |
		(world includes: element) ifFalse: [ self addNodeElement: element ] ].
	mondrian edgeElements do: [ :edge |
		(edge fromAnchor isKindOf: CFPhysicsMondrianPresentationAnchor) ifFalse: [
			self preparePhysicsPresentationOf: edge ] ]
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
	sessionPhysicsFacades := IdentitySet new
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
	anEdgeElement fromAnchor: (CFPhysicsMondrianPresentationAnchor on: anEdgeElement fromAnchor).
	anEdgeElement toAnchor: (CFPhysicsMondrianPresentationAnchor on: anEdgeElement toAnchor)
]

{ #category : 'private - world setup' }
CFPhysicsMondrian >> addNodeElement: anElement [
	world ifNil: [ ^ anElement ].
	(self physicsForSessionElement: anElement)
		beDynamic;
		position: anElement position.
	^ anElement
]

{ #category : 'private - world setup' }
CFPhysicsMondrian >> addNodeElements: aCollection [
	aCollection do: [ :each | self addNodeElement: each ].
	^ aCollection
]

{ #category : 'private - teardown' }
CFPhysicsMondrian >> removeSessionPhysicsFacades [
	sessionPhysicsFacades ifNil: [ ^ self ].
	sessionPhysicsFacades do: #release.
	sessionPhysicsFacades := nil
]

{ #category : 'private - world setup' }
CFPhysicsMondrian >> physicsForSessionElement: anElement [
	| physics |
	physics := anElement existingPhysics.
	physics ifNotNil: [ ^ physics ].
	physics := anElement physics.
	sessionPhysicsFacades add: physics.
	^ physics
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
CFPhysicsMondrian >> unwrappedPresentationAnchor: anAnchor [
	^ (anAnchor isKindOf: CFPhysicsMondrianPresentationAnchor)
		ifTrue: [ anAnchor anchor ]
		ifFalse: [ anAnchor ]
]

{ #category : 'private - initialization' }
CFPhysicsMondrian >> mondrian: aMondrian [
	mondrian := aMondrian
]
