"
I integrate one Mondrian graph with a Physics world.

My responsibility is to manage the graph's participating elements, Physics Behaviours, playback lifecycle and presentation changes, and to restore the original Mondrian state when the integration ends.
"
Class {
	#name : 'CFPhysicsMondrian',
	#superclass : 'Object',
	#instVars : [ 'mondrian', 'world', 'behaviours', 'originalRootLayout', 'originalAutoScaleEnabled', 'originalChildrenScaleFactor', 'originalChildrenTranslationFactor', 'playbackHandler', 'preexistingPhysicsElements', 'sessionPhysicsElements' ],
	#category : 'BVC-Physics-Mondrian',
	#package : 'BVC-Physics-Mondrian'
}

{ #category : 'instance creation' }
CFPhysicsMondrian class >> on: aMondrian [
	^ self new
		mondrian: aMondrian;
		yourself
]


{ #category : 'initialization' }
CFPhysicsMondrian >> initialize [
	super initialize.
	behaviours := OrderedCollection new
]

{ #category : 'behaviours' }
CFPhysicsMondrian >> behaviours [
	^ behaviours copy
]

{ #category : 'behaviours' }
CFPhysicsMondrian >> addBehaviour: aBehaviour [
	self beWorld.
	(aBehaviour physics notNil and: [ aBehaviour physics ~~ self ]) ifTrue: [
		self error: 'The Mondrian Physics Behaviour already belongs to another facade' ].
	(behaviours identityIncludes: aBehaviour) ifTrue: [ ^ aBehaviour ].
	aBehaviour
		physics: self;
		world: world.
	behaviours add: aBehaviour.
	world addBehaviour: aBehaviour.
	^ aBehaviour
]

{ #category : 'behaviours' }
CFPhysicsMondrian >> removeBehaviour: aBehaviour [
	behaviours remove: aBehaviour ifAbsent: [ ].
	^ aBehaviour
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
	world := mondrian root physics beWorld.
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
	behaviours copy do: [ :each | each remove ].
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
	| behaviour |
	behaviour := self addBehaviour:
		(CFPhysicsMondrianForceDirectedBehaviour physics: self).
	^ behaviour install
]

{ #category : 'private - behaviours' }
CFPhysicsMondrian >> forceDirectedConnections [
	| currentNodeElements |
	currentNodeElements := mondrian nodeElements asIdentitySet.
	^ (mondrian edgeElements collect: [ :each |
		each graph model fromElement -> each graph model toElement ]) select: [ :each |
		(currentNodeElements includes: each key) and: [
			currentNodeElements includes: each value ] ]
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
	anEdgeElement fromAnchor: (CFPhysicsMondrianPresentationAnchor on: anEdgeElement fromAnchor).
	anEdgeElement toAnchor: (CFPhysicsMondrianPresentationAnchor on: anEdgeElement toAnchor)
]

{ #category : 'private - world setup' }
CFPhysicsMondrian >> addNodeElement: anElement [
	world ifNil: [ ^ anElement ].
	sessionPhysicsElements add: anElement.
	anElement existingPhysics ifNotNil: [ preexistingPhysicsElements add: anElement ].
	anElement physics
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
	mondrian nodeElements do: [ :each | elements add: each ].
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
