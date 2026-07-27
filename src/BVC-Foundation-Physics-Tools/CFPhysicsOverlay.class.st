Class {
	#name : 'CFPhysicsOverlay',
	#superclass : 'Object',
	#instVars : [ 'host', 'world', 'root', 'context', 'bodyElements', 'contactPass', 'objectInspector', 'selectedElement', 'selectionHandler', 'framePresentedHandler', 'controlRoot', 'worldInspectorButton' ],
	#category : 'BVC-Foundation-Physics-Tools',
	#package : 'BVC-Foundation-Physics-Tools'
}

{ #category : 'instance creation' }
CFPhysicsOverlay class >> on: aHostElement [
	| physics |
	physics := aHostElement existingPhysics.
	(physics notNil and: [ physics isWorld ])
		ifFalse: [ self error: 'A physics overlay requires an element that owns a physics world' ].
	^ self new
		host: aHostElement;
		world: physics existingWorld;
		initializeOverlay;
		yourself
]

{ #category : 'accessing' }
CFPhysicsOverlay >> host [ ^ host ]

{ #category : 'accessing' }
CFPhysicsOverlay >> host: anElement [ host := anElement ]

{ #category : 'accessing' }
CFPhysicsOverlay >> world [ ^ world ]

{ #category : 'accessing' }
CFPhysicsOverlay >> world: aWorld [ world := aWorld ]

{ #category : 'accessing' }
CFPhysicsOverlay >> root [ ^ root ]

{ #category : 'accessing' }
CFPhysicsOverlay >> bodyElements [ ^ bodyElements values asArray ]

{ #category : 'accessing' }
CFPhysicsOverlay >> contactPass [ ^ contactPass ]

{ #category : 'accessing' }
CFPhysicsOverlay >> objectInspector [ ^ objectInspector ]

{ #category : 'accessing' }
CFPhysicsOverlay >> controlRoot [ ^ controlRoot ]

{ #category : 'accessing' }
CFPhysicsOverlay >> worldInspectorButton [ ^ worldInspectorButton ]


{ #category : 'accessing' }
CFPhysicsOverlay >> selectedElement [
	^ selectedElement
]

{ #category : 'private - selection' }
CFPhysicsOverlay >> clickEvent: anEvent [
	| anElement |
	(objectInspector includesEventTarget: anEvent target) ifTrue: [ ^ self ].
	anElement := self physicalElementFrom: anEvent target.
	anElement ifNil: [ ^ self clearSelection ].
	selectedElement == anElement ifTrue: [ ^ self clearSelection ].
	selectedElement := anElement.
	self refreshSelectionHighlight.
	objectInspector inspect: anElement existingPhysics.
	^ self
]

{ #category : 'private - selection' }
CFPhysicsOverlay >> physicalElementFrom: anElement [
	| current physics body |
	current := anElement.
	[ current notNil ] whileTrue: [
		physics := current existingPhysics.
		physics ifNotNil: [
			body := physics bodyState.
			(body notNil and: [ body world == world ]) ifTrue: [ ^ current ] ].
		current == host ifTrue: [ ^ nil ].
		current := current parent ].
	^ nil
]

{ #category : 'private - selection' }
CFPhysicsOverlay >> clearSelection [
	selectedElement := nil.
	self refreshSelectionHighlight.
	objectInspector clear.
	^ self
]


{ #category : 'private - selection' }
CFPhysicsOverlay >> refreshSelectionHighlight [
	| selectedBody |
	selectedBody := selectedElement
		ifNil: [ nil ]
		ifNotNil: [
			| physics |
			physics := selectedElement existingPhysics.
			physics ifNotNil: [ physics bodyState ] ].
	bodyElements keysAndValuesDo: [ :body :overlayElement |
		overlayElement selected: body == selectedBody ].
	^ self
]

{ #category : 'initialization' }
CFPhysicsOverlay >> initializeOverlay [
	bodyElements := IdentityDictionary new.
	root := BlOverlayElement on: host.
	root
		id: #cfPhysicsOverlay;
		zIndex: (host elevation relatedTo: 0) + 1;
		clipChildren: false;
		preventMeAndChildrenMouseEvents.
	context := CFPhysicsOverlayContext host: host world: world overlay: self.
	contactPass := CFPhysicsContactOverlayPass in: root context: context.
	objectInspector := CFPhysicsObjectInspector on: host.
	self initializeWorldInspectorControl.
	selectionHandler := BlEventHandler
		on: BlClickEvent
		do: [ :anEvent | self clickEvent: anEvent ].
	framePresentedHandler := BlEventHandler
		on: CFPhysicsFramePresentedEvent
		do: [ :anEvent | self refreshFrameDiagnostics ]
]



{ #category : 'initialization' }
CFPhysicsOverlay >> initializeWorldInspectorControl [
	controlRoot := BlOverlayElement on: host.
	controlRoot
		id: #cfPhysicsWorldInspectorControl;
		zIndex: (host elevation relatedTo: 0) + 3;
		clipChildren: false;
		preventMouseEvents.
	worldInspectorButton := self newWorldInspectorButton.
	controlRoot addChild: worldInspectorButton
]

{ #category : 'private - building' }
CFPhysicsOverlay >> newWorldInspectorButton [
	^ BrButton new
		id: #cfPhysicsWorldInspectorButton;
		aptitude: BrGlamorousButtonWithIconCircularAptitude;
		icon: ([ (FontAwesomeIcons defaultStyle icon: #atom) size: 48 @ 48 ] asStencil);
		label: 'Inspect Physics world';
		size: 64 @ 64;
		background: (Color black alpha: 0.08);
		effect: (BlBlurBelowEffect radius: 14);
		geometry: BlCircleGeometry new;
		constraintsDo: [ :c |
			c frame horizontal alignRight.
			c frame vertical alignTop ];
		margin: (BlInsets all: 10);
		action: [ :aButton | aButton phlow spawnObject: world ];
		yourself
]

{ #category : 'testing' }
CFPhysicsOverlay >> isInstalled [
	^ root hasParent
]

{ #category : 'installing' }
CFPhysicsOverlay >> install [
	| container |
	self isInstalled ifTrue: [ ^ self ].
	container := host parent.
	(container notNil and: [ host isAttachedToSceneGraph ])
		ifFalse: [ self error: 'The physics host must be attached to a Bloc space before its overlay can be shown' ].
	container addChild: root.
	container addChild: controlRoot.
	objectInspector install.
	host addEventFilter: selectionHandler.
	host addEventHandler: framePresentedHandler.
	self refresh.
	^ self
]

{ #category : 'updating' }
CFPhysicsOverlay >> refreshFrameDiagnostics [
	"Refresh diagnostics whose geometry or lifetime may change on every
	presented Physics frame. Structural body membership is deliberately left to
	#refresh so frame presentation cannot mutate the world membership."
	contactPass refresh.
	self refreshSelectedObject.
	^ self
]

{ #category : 'private - selection' }
CFPhysicsOverlay >> refreshSelectedObject [
	| physics body |
	selectedElement ifNil: [ ^ self ].
	physics := selectedElement existingPhysics.
	physics ifNil: [ ^ self clearSelection ].
	body := physics bodyState.
	(body isNil or: [ body world ~~ world ])
		ifTrue: [ ^ self clearSelection ].
	objectInspector selectedPhysics == physics
		ifFalse: [ objectInspector inspect: physics ].
	objectInspector refresh.
	^ self
]

{ #category : 'updating' }
CFPhysicsOverlay >> refresh [
	| bodies live |
	world synchroniseMembership.
	bodies := world bodyStatesInOrder.
	live := IdentitySet new.
	live addAll: bodies.
	(bodyElements keys reject: [ :each | live includes: each ]) do: [ :body |
		| anElement |
		anElement := bodyElements removeKey: body.
		anElement release.
		anElement removeFromParent ].
	bodies do: [ :body |
		| anElement |
		anElement := bodyElements
			at: body
			ifAbsentPut: [
				| created |
				created := body physicsOverlayElementIn: context.
				root addChild: created.
				created ].
		anElement refresh ].
	contactPass refresh.
	self refreshSelectedObject.
	self refreshSelectionHighlight.
	^ self
]

{ #category : 'controlling' }
CFPhysicsOverlay >> release [
	self clearSelection.
	selectionHandler ifNotNil: [ host removeEventFilter: selectionHandler ].
	framePresentedHandler ifNotNil: [ host removeEventHandler: framePresentedHandler ].
	contactPass ifNotNil: #release.
	objectInspector ifNotNil: #release.
	controlRoot ifNotNil: [
		controlRoot detach.
		controlRoot hasParent ifTrue: [ controlRoot removeFromParent ] ].
	bodyElements valuesDo: [ :each | each release ].
	bodyElements removeAll.
	root detach.
	root hasParent ifTrue: [ root removeFromParent ]
]

{ #category : 'actions' }
CFPhysicsOverlay class >> hostFor: anObject [
	^ (anObject respondsTo: #physicsOverlayHost)
		ifTrue: [ anObject physicsOverlayHost ]
		ifFalse: [ nil ]
]

{ #category : 'testing' }
CFPhysicsOverlay class >> hasWorldFor: anObject [
	| aHost physics |
	aHost := self hostFor: anObject.
	aHost ifNil: [ ^ false ].
	physics := aHost existingPhysics.
	^ physics notNil and: [ physics isWorld ]
]

{ #category : 'actions' }
CFPhysicsOverlay class >> toggleFor: anObject [
	| aHost |
	aHost := self hostFor: anObject.
	(self hasWorldFor: anObject)
		ifFalse: [ ^ nil ].
	^ aHost togglePhysicsOverlay
]

{ #category : 'actions' }
CFPhysicsOverlay class >> gtToggleActionFor: anObject action: anAction [
	^ anAction explicit stencil: [ self toggleButtonFor: anObject ]
]

{ #category : 'actions' }
CFPhysicsOverlay class >> toggleButtonFor: anObject [
	| aButton aHost aWorldChangedHandler |
	aHost := self hostFor: anObject.
	aButton := BrButton new
		aptitude: BrGlamorousButtonWithIconAptitude;
		icon: ([ (FontAwesomeIcons defaultStyle icon: #atom) height: 16 ] asStencil);
		label: 'Toggle physics overlay';
		action: [ self toggleFor: anObject ].

	aHost ifNil: [
		aButton visibility: BlVisibility gone.
		^ aButton ].

	aWorldChangedHandler := BlEventHandler
		on: CFPhysicsWorldAttachmentChanged
		do: [ :anEvent | aButton phlow fireToolUpdateWish ].
	aHost addEventHandler: aWorldChangedHandler.
	aButton
		when: BlElementRemovedFromParentEvent
		do: [ :anEvent | aHost removeEventHandler: aWorldChangedHandler ].
	aButton visibility: ((self hasWorldFor: anObject)
		ifTrue: [ BlVisibility visible ]
		ifFalse: [ BlVisibility gone ]).
	^ aButton
]
