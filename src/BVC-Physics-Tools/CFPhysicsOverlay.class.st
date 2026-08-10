"I coordinate the diagnostic overlay for one Physics world host. I own the specialised overlays, controls, selection and inspector, and refresh them from presentation and camera changes."
Class {
	#name : 'CFPhysicsOverlay',
	#superclass : 'Object',
	#instVars : [ 'host', 'world', 'root', 'context', 'bodyOverlay', 'springOverlay', 'jointOverlay', 'contactOverlay', 'objectInspector', 'selectedElement', 'selectedSpring', 'selectedJoint', 'selectionHandler', 'framePresentedHandler', 'hostTransformationHandler', 'controlRoot', 'statusPanel', 'worldInspectorButton', 'behaviourPanel', 'controls', 'selectionVisual', 'selectedBehaviour', 'scopedBodies', 'scopedBodySet', 'scopedConstraints'  ],
	#category : 'BVC-Physics-Tools',
	#package : 'BVC-Physics-Tools'
}

{ #category : 'instance creation' }
CFPhysicsOverlay class >> on: aHostElement [
	| physics |
	physics := aHostElement existingPhysics.
	(physics notNil and: [ physics isWorld ])
		ifFalse: [ self error: 'A physics overlay requires an element that owns a physics world' ].
	^ self new
		host: aHostElement;
		world: physics world;
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
CFPhysicsOverlay >> bodyOverlay [ ^ bodyOverlay ]
{ #category : 'accessing' }
CFPhysicsOverlay >> bodyElements [ ^ bodyOverlay visuals ]
{ #category : 'accessing' }
CFPhysicsOverlay >> springOverlay [ ^ springOverlay ]
{ #category : 'accessing' }
CFPhysicsOverlay >> jointOverlay [ ^ jointOverlay ]
{ #category : 'accessing' }
CFPhysicsOverlay >> contactOverlay [ ^ contactOverlay ]
{ #category : 'accessing' }
CFPhysicsOverlay >> objectInspector [ ^ objectInspector ]
{ #category : 'accessing' }
CFPhysicsOverlay >> controlRoot [ ^ controlRoot ]
{ #category : 'accessing' }
CFPhysicsOverlay >> statusPanel [ ^ statusPanel ]
{ #category : 'accessing' }
CFPhysicsOverlay >> worldInspectorButton [ ^ worldInspectorButton ]
{ #category : 'accessing' }
CFPhysicsOverlay >> behaviourPanel [ ^ behaviourPanel ]
{ #category : 'accessing' }
CFPhysicsOverlay >> selectedBehaviour [ ^ selectedBehaviour ]
{ #category : 'accessing' }
CFPhysicsOverlay >> controls [ ^ controls ]
{ #category : 'accessing' }
CFPhysicsOverlay >> selectedElement [ ^ selectedElement ]
{ #category : 'accessing' }
CFPhysicsOverlay >> selectedSpring [ ^ selectedSpring ]
{ #category : 'accessing' }
CFPhysicsOverlay >> selectedJoint [ ^ selectedJoint ]
{ #category : 'accessing' }
CFPhysicsOverlay >> selectionVisual [ ^ selectionVisual ]
{ #category : 'accessing' }
CFPhysicsOverlay >> selectionElement [ ^ selectionVisual ]

{ #category : 'private - selection' }
CFPhysicsOverlay >> clickEvent: anEvent [
	| anElement physics joint spring |
	(objectInspector includesEventTarget: anEvent target) ifTrue: [ ^ self ].
	joint := self jointFrom: anEvent target.
	joint ifNotNil: [ ^ self selectJoint: joint ].
	spring := self springFrom: anEvent target.
	spring ifNotNil: [ ^ self selectSpring: spring ].
	anElement := self physicalElementFrom: anEvent target.
	anElement ifNil: [
		self clearSelection.
		self clearBehaviourFocus.
		^ self ].
	selectedElement == anElement ifTrue: [ ^ self ].
	selectedSpring := nil.
	selectedJoint := nil.
	selectedElement := anElement.
	physics := anElement existingPhysics.
	self refreshSelectionVisual.
	objectInspector inspect: physics.
	^ self
]


{ #category : 'private - selection' }
CFPhysicsOverlay >> jointFrom: anElement [
	| resolvedJoint |
	resolvedJoint := selectionVisual
		ifNil: [ nil ]
		ifNotNil: [
			(selectionVisual respondsTo: #jointForEventTarget:)
				ifTrue: [ selectionVisual jointForEventTarget: anElement ]
				ifFalse: [ nil ] ].
	^ resolvedJoint ifNil: [ jointOverlay jointForEventTarget: anElement ]
]

{ #category : 'private - selection' }
CFPhysicsOverlay >> selectJoint: aJoint [
	selectedJoint == aJoint ifTrue: [ ^ self ].
	selectedElement := nil.
	selectedSpring := nil.
	selectedJoint := aJoint.
	self refreshSelectionVisual.
	objectInspector inspect: aJoint.
	^ self
]

{ #category : 'private - selection' }
CFPhysicsOverlay >> springFrom: anElement [
	| resolvedSpring |
	resolvedSpring := selectionVisual
		ifNil: [ nil ]
		ifNotNil: [
			(selectionVisual respondsTo: #springForEventTarget:)
				ifTrue: [ selectionVisual springForEventTarget: anElement ]
				ifFalse: [ nil ] ].
	^ resolvedSpring ifNil: [ springOverlay springForEventTarget: anElement ]
]

{ #category : 'private - selection' }
CFPhysicsOverlay >> selectSpring: aSpring [
	selectedSpring == aSpring ifTrue: [ ^ self ].
	selectedElement := nil.
	selectedJoint := nil.
	selectedSpring := aSpring.
	self refreshSelectionVisual.
	objectInspector inspect: aSpring.
	^ self
]

{ #category : 'private - selection' }
CFPhysicsOverlay >> physicalElementFrom: anElement [
	| current physics body |
	current := anElement.
	[ current notNil ] whileTrue: [
		physics := current existingPhysics.
		physics ifNotNil: [
			body := physics bodyOrNil.
			(body notNil and: [ body world == world ]) ifTrue: [
				(scopedBodySet isNil or: [ scopedBodySet includes: body ]) ifTrue: [ ^ current ] ] ].
		current == host ifTrue: [ ^ nil ].
		current := current parent ].
	^ nil
]

{ #category : 'private - selection' }
CFPhysicsOverlay >> clearSelection [
	selectedElement := nil.
	selectedSpring := nil.
	selectedJoint := nil.
	self refreshSelectionVisual.
	objectInspector clear.
	^ self
]

{ #category : 'private - selection' }
CFPhysicsOverlay >> clearSelectionVisual [
	selectionVisual ifNil: [ ^ self ].
	selectionVisual release.
	selectionVisual := nil.
	^ self
]

{ #category : 'private - selection' }
CFPhysicsOverlay >> refreshSelectionVisual [
	| selectedBody |
	selectedJoint ifNotNil: [
		(selectionVisual notNil and: [ selectionVisual matchesSelection: selectedJoint ])
			ifTrue: [ selectionVisual update. ^ self ].
		self clearSelectionVisual.
		selectionVisual := CFPhysicsJointVisual selectionOn: selectedJoint context: context.
		selectionVisual
			update;
			addTo: root.
		^ self ].
	selectedSpring ifNotNil: [
		(selectionVisual notNil and: [ selectionVisual matchesSelection: selectedSpring ])
			ifTrue: [ selectionVisual update. ^ self ].
		self clearSelectionVisual.
		selectionVisual := CFPhysicsSpringVisual selectionOn: selectedSpring context: context.
		selectionVisual
			update;
			addTo: root.
		^ self ].
	selectedBody := selectedElement
		ifNil: [ nil ]
		ifNotNil: [ | physics | physics := selectedElement existingPhysics. physics ifNotNil: [ physics bodyOrNil ] ].
	selectedBody ifNil: [ ^ self clearSelectionVisual ].
	(selectionVisual notNil and: [ selectionVisual matchesSelection: selectedBody ])
		ifTrue: [ selectionVisual update. ^ self ].
	self clearSelectionVisual.
	selectionVisual := CFPhysicsBodyVisual selectionOn: selectedBody context: context.
	selectionVisual
		update;
		addTo: root.
	^ self
]

{ #category : 'initialization' }
CFPhysicsOverlay >> initializeOverlay [
		root := BlOverlayElement on: host.
	root
		id: #cfPhysicsOverlay;
		layout: BlFrameLayout new;
		zIndex: (host elevation relatedTo: 0) + 1;
		clipChildren: false;
		preventMouseEvents.
	context := CFPhysicsOverlayContext host: host world: world overlay: self.
	bodyOverlay := CFPhysicsBodyOverlay in: root world: world context: context.
	springOverlay := CFPhysicsSpringOverlay in: root world: world context: context.
	jointOverlay := CFPhysicsJointOverlay in: root world: world context: context.
	contactOverlay := CFPhysicsContactOverlay in: root context: context.
	objectInspector := CFPhysicsObjectInspector on: host.
	selectedBehaviour := nil.
	scopedBodies := nil.
	scopedBodySet := nil.
	scopedConstraints := nil.
	self initializeControls.
	selectionHandler := BlEventHandler on: BlClickEvent do: [ :anEvent | self clickEvent: anEvent ].
	framePresentedHandler := BlEventHandler on: CFPhysicsFramePresentedEvent do: [ :anEvent | self refreshFrameDiagnosticsFor: anEvent ].
	hostTransformationHandler := BlEventHandler
		on: BlElementTransformationChangedEvent
		do: [ :anEvent | self refreshPresentationGeometry ]
]

{ #category : 'initialization' }
CFPhysicsOverlay >> initializeControls [
	controlRoot := BlOverlayElement on: host.
	controlRoot
		id: #cfPhysicsOverlayControls;
		layout: BlFrameLayout new;
		zIndex: (host elevation relatedTo: 0) + 3;
		clipChildren: false;
		preventMouseEvents.
	statusPanel := CFPhysicsOverlayStatusPanel on: self.
	worldInspectorButton := statusPanel worldButton.
	behaviourPanel := CFPhysicsOverlayBehaviourPanel on: self.
	controls := CFPhysicsOverlayControls on: self.
	controlRoot
		addChild: statusPanel element;
		addChild: behaviourPanel element;
		addChild: controls element
]

{ #category : 'testing' }
CFPhysicsOverlay >> isInstalled [ ^ root hasParent ]

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
	root addEventFilter: selectionHandler.
	host addEventHandler: framePresentedHandler.
	host addEventHandler: hostTransformationHandler.
	controls contactsEnabled ifTrue: [ world enableVisualState ].
	self refresh.
	^ self
]

{ #category : 'updating' }
CFPhysicsOverlay >> refreshFrameDiagnostics [
	self refreshPresentationGeometry.
	self refreshSelectedObject.
	^ self
]

{ #category : 'updating' }
CFPhysicsOverlay >> refreshFrameDiagnosticsFor: anEvent [
	anEvent behaviourChanged ifTrue: [
		self refresh.
		^ self ].
	anEvent presentationChanged ifTrue: [
		self refreshPresentationGeometryWithoutContacts ].
	controls contactsEnabled ifTrue: [
		anEvent contactStateChanged
			ifTrue: [
				contactOverlay
					reconcileFrom: world committedVisualState
					scopedToBodies: scopedBodySet ]
			ifFalse: [
				anEvent presentationChanged ifTrue: [
					contactOverlay updateGeometry ] ] ].
	self refreshSelectedObject.
	^ self
]

{ #category : 'private - updating' }
CFPhysicsOverlay >> refreshPresentationGeometryWithoutContacts [
	controls constraintsEnabled ifTrue: [
		springOverlay updateGeometry.
		jointOverlay updateGeometry ].
	self refreshSelectionVisual.
	^ self
]

{ #category : 'updating' }
CFPhysicsOverlay >> refreshPresentationGeometry [
	"Camera transforms alter the displayed coordinate system even when Physics
	presentation is unchanged. Body visuals observe their source elements directly;
	aggregate diagnostics refresh here for the owning host."
	behaviourPanel refresh.
	self validateBehaviourFocus.
	self refreshPresentationGeometryWithoutContacts.
	controls contactsEnabled ifTrue: [ contactOverlay updateGeometry ].
	^ self
]

{ #category : 'private - selection' }
CFPhysicsOverlay >> refreshSelectedObject [
	| physics body |
	(selectedBehaviour notNil and: [ objectInspector selectedObject == selectedBehaviour ]) ifTrue: [
		objectInspector refresh.
		^ self ].
	selectedJoint ifNotNil: [
		(selectedJoint world == world)
			ifFalse: [ self clearSelection ]
			ifTrue: [
				objectInspector selectedObject == selectedJoint
					ifFalse: [ objectInspector inspect: selectedJoint ].
				objectInspector refresh ].
		^ self ].
	selectedSpring ifNotNil: [
		(selectedSpring world == world)
			ifFalse: [ self clearSelection ]
			ifTrue: [
				objectInspector selectedObject == selectedSpring
					ifFalse: [ objectInspector inspect: selectedSpring ].
				objectInspector refresh ].
		^ self ].
	selectedElement ifNil: [ ^ self ].
	physics := selectedElement existingPhysics.
	physics ifNil: [ ^ self clearSelection ].
	body := physics bodyOrNil.
	(body isNil or: [ body world ~~ world ]) ifTrue: [ ^ self clearSelection ].
	objectInspector selectedObject == physics ifFalse: [ objectInspector inspect: physics ].
	objectInspector refresh.
	^ self
]


{ #category : 'updating' }
CFPhysicsOverlay >> refresh [
	"A structural refresh is the explicit boundary at which Bloc membership
	changes are reconciled with the Physics world. Frame diagnostics deliberately
	do not perform this work."
	world refreshExistingMembers.
	behaviourPanel refresh.
	self validateBehaviourFocus.
	self refreshScope.
	controls bodiesEnabled
		ifTrue: [ self updateBodyOverlay ]
		ifFalse: [ bodyOverlay clear ].
	controls constraintsEnabled
		ifTrue: [ self updateConstraintOverlays ]
		ifFalse: [ springOverlay clear. jointOverlay clear ].
	controls contactsEnabled ifTrue: [
		contactOverlay updateFrom: world committedVisualState scopedToBodies: scopedBodySet ].
	self refreshSelectedObject.
	self refreshSelectionVisual.
	^ self
]


{ #category : 'controlling - diagnostics' }
CFPhysicsOverlay >> bodiesEnabled: aBoolean [
	aBoolean
		ifTrue: [
			world refreshExistingMembers.
			self refreshScope.
			self updateBodyOverlay.
			self refreshSelectionVisual ]
		ifFalse: [ bodyOverlay clear ].
	^ self
]

{ #category : 'controlling - diagnostics' }
CFPhysicsOverlay >> constraintsEnabled: aBoolean [
	aBoolean
		ifTrue: [
			world refreshExistingMembers.
			self refreshScope.
			self updateConstraintOverlays ]
		ifFalse: [
			(selectedSpring notNil or: [ selectedJoint notNil ]) ifTrue: [ self clearSelection ].
			springOverlay clear.
			jointOverlay clear ].
	^ self
]

{ #category : 'controlling - diagnostics' }
CFPhysicsOverlay >> springsEnabled: aBoolean [
	^ self constraintsEnabled: aBoolean
]

{ #category : 'controlling - diagnostics' }
CFPhysicsOverlay >> jointsEnabled: aBoolean [
	^ self constraintsEnabled: aBoolean
]

{ #category : 'controlling - diagnostics' }
CFPhysicsOverlay >> contactsEnabled: aBoolean [
	aBoolean
		ifTrue: [
			world enableVisualState.
			contactOverlay updateFrom: world committedVisualState scopedToBodies: scopedBodies ]
		ifFalse: [
			contactOverlay clear.
			world disableVisualState ].
	^ self
]


{ #category : 'private - behaviour scope' }
CFPhysicsOverlay >> validateBehaviourFocus [
	selectedBehaviour ifNil: [ ^ self ].
	(world includesBehaviour: selectedBehaviour) ifFalse: [
		objectInspector selectedObject == selectedBehaviour ifTrue: [ objectInspector clear ].
		selectedBehaviour := nil.
		scopedBodies := nil.
		scopedBodySet := nil.
		scopedConstraints := nil.
		behaviourPanel rebuild ].
	^ self
]

{ #category : 'private - behaviour scope' }
CFPhysicsOverlay >> refreshScope [
	selectedBehaviour
		ifNil: [
			scopedBodies := nil.
			scopedBodySet := nil.
			scopedConstraints := nil ]
		ifNotNil: [
			scopedBodies := selectedBehaviour physicsBodies asArray.
			scopedBodySet := scopedBodies asIdentitySet.
			scopedConstraints := selectedBehaviour physicsConstraints asArray ].
	^ self
]

{ #category : 'private - behaviour scope' }
CFPhysicsOverlay >> scopedSprings [
	^ scopedConstraints select: [ :joint |
		(joint isKindOf: CFPhysicsDistanceJoint) and: [ joint springEnabled ] ]
]

{ #category : 'private - behaviour scope' }
CFPhysicsOverlay >> scopedJoints [
	^ scopedConstraints reject: [ :joint |
		(joint isKindOf: CFPhysicsDistanceJoint) and: [ joint springEnabled ] ]
]

{ #category : 'private - behaviour scope' }
CFPhysicsOverlay >> updateBodyOverlay [
	scopedBodies
		ifNil: [ bodyOverlay update ]
		ifNotNil: [ bodyOverlay updateFrom: scopedBodies ].
	^ self
]

{ #category : 'private - behaviour scope' }
CFPhysicsOverlay >> updateConstraintOverlays [
	scopedConstraints
		ifNil: [ springOverlay update. jointOverlay update ]
		ifNotNil: [
			springOverlay updateFrom: self scopedSprings.
			jointOverlay updateFrom: self scopedJoints ].
	^ self
]

{ #category : 'controlling - behaviour scope' }
CFPhysicsOverlay >> selectBehaviour: aBehaviour [
	selectedElement := nil.
	selectedSpring := nil.
	selectedJoint := nil.
	self clearSelectionVisual.
	selectedBehaviour := aBehaviour.
	self refreshScope.
	behaviourPanel rebuild.
	self refresh.
	objectInspector inspect: aBehaviour.
	^ self
]

{ #category : 'controlling - behaviour scope' }
CFPhysicsOverlay >> clearBehaviourFocus [
	selectedBehaviour ifNil: [ ^ self ].
	selectedBehaviour := nil.
	self refreshScope.
	behaviourPanel rebuild.
	self refresh.
	^ self
]

{ #category : 'controlling' }
CFPhysicsOverlay >> release [
	| contactsWereEnabled |
	contactsWereEnabled := controls notNil and: [ controls contactsEnabled ].
	self clearSelection.
	selectionHandler ifNotNil: [ host removeEventFilter: selectionHandler ].
	selectionHandler ifNotNil: [ root removeEventFilter: selectionHandler ].
	framePresentedHandler ifNotNil: [ host removeEventHandler: framePresentedHandler ].
	hostTransformationHandler ifNotNil: [ host removeEventHandler: hostTransformationHandler ].
	contactsWereEnabled ifTrue: [ world ifNotNil: #disableVisualState ].
	statusPanel ifNotNil: #release.
	behaviourPanel ifNotNil: #release.
	controls ifNotNil: #release.
	bodyOverlay ifNotNil: #release.
	springOverlay ifNotNil: #release.
	jointOverlay ifNotNil: #release.
	contactOverlay ifNotNil: #release.
	objectInspector ifNotNil: #release.
	controlRoot ifNotNil: [ controlRoot hasParent ifTrue: [ controlRoot removeFromParent ] ].
	self clearSelectionVisual.
	root hasParent ifTrue: [ root removeFromParent ].
	^ self
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
	(self hasWorldFor: anObject) ifFalse: [ ^ nil ].
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
