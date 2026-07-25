Class {
	#name : 'CFPhysicsOverlayTests',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Physics-Tests',
	#package : 'BVC-Foundation-Physics-Tests'
}

{ #category : 'examples - physics overlay' }
CFPhysicsOverlayTests >> physicsHost [
	<gtExample>
	| space container host first second world |
	space := BlSpace new.
	container := BlElement new
		size: 500 @ 320;
		yourself.
	host := BlElement new
		size: 420 @ 260;
		yourself.
	first := BlElement new
		geometry: BlCircleGeometry new;
		size: 40 @ 40;
		background: Color lightBlue;
		yourself.
	second := BlElement new
		geometry: (BlRoundedRectangleGeometry cornerRadii: (BlCornerRadii radius: 8));
		size: 90 @ 50;
		background: Color lightGreen;
		yourself.
	space root addChild: container.
	container addChild: host.
	host addChild: first.
	host addChild: second.
	world := host physics beWorld.
	world synchroniseMembership.
	(world bodyStateFor: first) position: 40 @ 50.
	(world bodyStateFor: second)
		position: 180 @ 120;
		rotation: Float pi / 8.0.
	space pulse.
	self assert: host existingPhysicsOverlay isNil.
	self assert: host children size equals: 2.
	^ host
]

{ #category : 'examples - physics overlay' }
CFPhysicsOverlayTests >> physicsOverlayCanBeInstalled [
	<gtExample>
	| host overlay |
	host := self physicsHost.
	overlay := host showPhysicsOverlay.
	host space pulse.
	self assert: overlay isInstalled.
	self assert: host existingPhysicsOverlay == overlay.
	self assert: overlay bodyElements size equals: 2.
	self assert: host children size equals: 2.
	self assert: overlay root parent == host parent.
	^ host
]


{ #category : 'examples - physics overlay' }
CFPhysicsOverlayTests >> physicsOverlayRendersAboveItsHost [
	<gtExample>
	| host overlay |
	host := self physicsHost.
	host zIndex: 7.
	overlay := host showPhysicsOverlay.
	host space pulse.
	self
		assert: (overlay root elevation relatedTo: 0)
		equals: (host elevation relatedTo: 0) + 1.
	^ host
]

{ #category : 'examples - physics overlay' }
CFPhysicsOverlayTests >> physicsOverlayCanBeRemovedWithoutChangingTheHost [
	<gtExample>
	| host overlay |
	host := self physicsOverlayCanBeInstalled.
	overlay := host existingPhysicsOverlay.
	host hidePhysicsOverlay.
	self assert: host existingPhysicsOverlay isNil.
	self assert: overlay isInstalled not.
	self assert: host children size equals: 2.
	^ host
]

{ #category : 'examples - physics overlay' }
CFPhysicsOverlayTests >> physicsBodyOverlayPreservesItsIdentityWhileRefreshing [
	<gtExample>
	| host overlay world body representation |
	host := self physicsOverlayCanBeInstalled.
	overlay := host existingPhysicsOverlay.
	world := host physics existingWorld.
	body := world bodyStatesInOrder first.
	representation := overlay bodyElements
		detect: [ :each | each body == body ].
	body
		position: 85 @ 70;
		rotation: Float pi / 4.0.
	overlay refresh.
	host space pulse.
	self assert: (overlay bodyElements includes: representation).
	self
		assert: representation position
		equals: (overlay root globalPointToLocal:
			(body shapeState element localPointToGlobal: 0 @ 0)).
	self assert: representation extent equals: body shapeState extent.
	self assert: (representation geometry == body shapeState element geometry) not.
	^ host
]

{ #category : 'examples - physics overlay' }
CFPhysicsOverlayTests >> physicsOverlayRemovesRetiredBodyRepresentations [
	<gtExample>
	| host overlay world retiredElement retiredBody |
	host := self physicsOverlayCanBeInstalled.
	overlay := host existingPhysicsOverlay.
	world := host physics existingWorld.
	retiredElement := host children first.
	retiredBody := world bodyStateFor: retiredElement.
	retiredElement removeFromParent.
	overlay refresh.
	self assert: (world bodyStatesInOrder includes: retiredBody) not.
	self assert: (overlay bodyElements anySatisfy: [ :each | each body == retiredBody ]) not.
	self assert: overlay bodyElements size equals: 1.
	^ host
]

{ #category : 'examples - physics overlay' }
CFPhysicsOverlayTests >> physicsOverlayCanBeToggledRepeatedly [
	<gtExample>
	| host firstOverlay secondOverlay |
	host := self physicsHost.
	firstOverlay := host togglePhysicsOverlay.
	host space pulse.
	self assert: firstOverlay isInstalled.
	self assert: host existingPhysicsOverlay == firstOverlay.
	host togglePhysicsOverlay.
	self assert: host existingPhysicsOverlay isNil.
	self assert: firstOverlay isInstalled not.
	secondOverlay := host togglePhysicsOverlay.
	host space pulse.
	self assert: secondOverlay isInstalled.
	self assert: host existingPhysicsOverlay == secondOverlay.
	self assert: secondOverlay ~~ firstOverlay.
	^ host
]


{ #category : 'examples - physics overlay' }
CFPhysicsOverlayTests >> physicsOverlayCapabilityResolvesAnElementHost [
	<gtExample>
	| host |
	host := self physicsHost.
	self assert: (CFPhysicsOverlay hostFor: host) == host.
	self assert: (CFPhysicsOverlay hasWorldFor: host).
	^ host
]

{ #category : 'examples - physics overlay' }
CFPhysicsOverlayTests >> physicsOverlayCapabilityRejectsAnObjectWithoutAHost [
	<gtExample>
	| object |
	object := Object new.
	self assert: (CFPhysicsOverlay hostFor: object) isNil.
	self assert: (CFPhysicsOverlay hasWorldFor: object) not.
	^ object
]

{ #category : 'examples - physics overlay' }
CFPhysicsOverlayTests >> physicsOverlayActionTracksWorldLifecycle [
	<gtExample>
	| host button |
	host := BlElement new.
	button := CFPhysicsOverlay toggleButtonFor: host.
	self assert: button visibility equals: BlVisibility gone.
	host physics beWorld.
	button := CFPhysicsOverlay toggleButtonFor: host.
	self assert: button visibility equals: BlVisibility visible.
	host physics ceaseBeingWorld.
	button := CFPhysicsOverlay toggleButtonFor: host.
	self assert: button visibility equals: BlVisibility gone.
	^ button
]


{ #category : 'examples - physics overlay' }
CFPhysicsOverlayTests >> physicsOverlayOwnsOneContactRenderingPass [
	<gtExample>
	| host overlay |
	host := self physicsOverlayCanBeInstalled.
	overlay := host existingPhysicsOverlay.
	self assert: overlay contactPass notNil.
	self assert: overlay contactPass elements isEmpty.
	^ overlay
]

{ #category : 'examples - physics overlay' }
CFPhysicsOverlayTests >> physicsOverlayWorldCoordinatesResolveThroughItsHost [
	<gtExample>
	| host overlay context point |
	host := self physicsOverlayCanBeInstalled.
	overlay := host existingPhysicsOverlay.
	context := CFPhysicsOverlayContext host: host world: overlay world overlay: overlay.
	point := 75 @ 55.
	self
		assert: (context overlayPointFromWorld: point)
		equals: (overlay root globalPointToLocal: (host localPointToGlobal: point)).
	^ overlay
]


{ #category : 'examples - physics overlay' }
CFPhysicsOverlayTests >> physicsOverlayRefreshesContactsAfterEachPresentedFrame [
	<gtExample>
	| host overlay world first second |
	host := self physicsOverlayCanBeInstalled.
	overlay := host existingPhysicsOverlay.
	world := host physics existingWorld.
	first := host children first.
	second := host children second.
	first physics position: 80 @ 80.
	second physics position: 80 @ 80.
	world step.
	host fireEvent: (CFPhysicsFramePresentedEvent new alpha: 0.0; yourself).
	self assert: overlay contactPass elements isNotEmpty.
	second physics position: 260 @ 180.
	world step.
	host fireEvent: (CFPhysicsFramePresentedEvent new alpha: 0.0; yourself).
	self assert: overlay contactPass elements isEmpty.
	^ overlay
]


{ #category : 'examples - physics overlay' }
CFPhysicsOverlayTests >> physicsPresentationAndWorldCoordinatesAgreeForPositionedElements [
	<gtExample>
	| host overlay world body element physicsPosition displayedPoint worldPoint context |
	host := self physicsOverlayCanBeInstalled.
	overlay := host existingPhysicsOverlay.
	world := host physics existingWorld.
	element := host children first.
	element relocate: 35 @ 25.
	"Commit the ordinary Bloc position before Physics calculates its Motion
	translation relative to that position."
	host space pulse.
	body := world bodyStateFor: element.
	physicsPosition := 140 @ 90.
	body position: physicsPosition.
	(CFPhysicsWorldPresentation on: world in: host space cfMotionCoordinator)
		presentAtAlpha: 1.0.
	host space pulse.
	context := CFPhysicsOverlayContext host: host world: world overlay: overlay.
	displayedPoint := context overlayPoint: 0 @ 0 from: element.
	worldPoint := context overlayPointFromWorld: physicsPosition.
	self assert: displayedPoint equals: worldPoint.
	^ overlay
]

{ #category : 'examples - physics overlay' }
CFPhysicsOverlayTests >> physicsPresentationAnnouncesOnlySuccessfullyPresentedFrames [
	<gtExample>
	| host world presentation handler presentedCount |
	host := self physicsHost.
	world := host physics existingWorld.
	presentedCount := 0.
	handler := BlEventHandler
		on: CFPhysicsFramePresentedEvent
		do: [ :anEvent | presentedCount := presentedCount + 1 ].
	host addEventHandler: handler.
	presentation := CFPhysicsWorldPresentation
		on: world
		in: host space cfMotionCoordinator.
	presentation frameReadyAtAlpha: 0.5.
	self assert: presentedCount equals: 1.
	presentation release.
	host removeFromParent.
	(CFPhysicsWorldPresentation on: world) frameReadyAtAlpha: 0.5.
	self assert: presentedCount equals: 1.
	host removeEventHandler: handler.
	^ host
]

{ #category : 'examples - physics overlay' }
CFPhysicsOverlayTests >> physicsOverlayFrameHandlerFollowsShowHideShowLifecycle [
	<gtExample>
	| host world first second firstOverlay secondOverlay |
	host := self physicsOverlayCanBeInstalled.
	world := host physics existingWorld.
	first := host children first.
	second := host children second.
	first physics position: 80 @ 80.
	second physics position: 80 @ 80.
	world step.
	firstOverlay := host existingPhysicsOverlay.
	host fireEvent: (CFPhysicsFramePresentedEvent new alpha: 0.0; yourself).
	self assert: firstOverlay contactPass elements isNotEmpty.
	host hidePhysicsOverlay.
	self assert: firstOverlay contactPass elements isEmpty.
	secondOverlay := host showPhysicsOverlay.
	host fireEvent: (CFPhysicsFramePresentedEvent new alpha: 0.0; yourself).
	self assert: secondOverlay contactPass elements isNotEmpty.
	self assert: firstOverlay contactPass elements isEmpty.
	second physics position: 260 @ 180.
	world step.
	host fireEvent: (CFPhysicsFramePresentedEvent new alpha: 0.0; yourself).
	self assert: secondOverlay contactPass elements isEmpty.
	self assert: firstOverlay contactPass elements isEmpty.
	^ host
]

{ #category : 'examples - physics object inspector' }
CFPhysicsOverlayTests >> physicsObjectInspectorCanBeInstalledAndReleased [
	<gtExample>
	| host inspector |
	host := self physicsHost.
	inspector := CFPhysicsObjectInspector on: host.
	self assert: inspector isInstalled not.
	inspector install.
	self assert: inspector isInstalled.
	self assert: inspector root parent == host parent.
	inspector release.
	self assert: inspector isInstalled not.
	^ inspector
]

{ #category : 'examples - physics object inspector' }
CFPhysicsOverlayTests >> physicsObjectInspectorBuildsTheStandardMagritteForm [
	<gtExample>
	| host inspector physics |
	host := self physicsHost.
	physics := host children first existingPhysics.
	inspector := CFPhysicsObjectInspector on: host.
	inspector inspect: physics.
	self assert: inspector selectedPhysics == physics.
	self assert: inspector form notNil.
	self assert: inspector form parent == inspector root.
	self assert: (inspector includesEventTarget: inspector form).
	^ inspector
]

{ #category : 'examples - physics object inspector' }
CFPhysicsOverlayTests >> physicsObjectInspectorIgnoresStaleFormCompletion [
	<gtExample>
	| host inspector firstPhysics secondPhysics staleFrame staleMemento generation |
	host := self physicsHost.
	firstPhysics := host children first existingPhysics.
	secondPhysics := host children second existingPhysics.
	inspector := CFPhysicsObjectInspector on: host.
	inspector inspect: firstPhysics.
	generation := inspector formGeneration.
	staleFrame := inspector form.
	staleMemento := Object new.
	staleFrame userData at: GtMagritteViewModel gtMementoSymbol put: staleMemento.
	inspector inspect: secondPhysics.
	inspector
		formCreated: staleFrame
		for: firstPhysics
		generation: generation.
	self assert: inspector selectedPhysics == secondPhysics.
	self assert: inspector memento isNil.
	^ inspector
]

{ #category : 'examples - physics object inspector' }
CFPhysicsOverlayTests >> physicsObjectInspectorCanClearItsObject [
	<gtExample>
	| host inspector physics previousForm |
	host := self physicsHost.
	physics := host children first existingPhysics.
	inspector := CFPhysicsObjectInspector on: host.
	inspector inspect: physics.
	previousForm := inspector form.
	inspector clear.
	self assert: inspector selectedPhysics isNil.
	self assert: inspector form isNil.
	self assert: inspector memento isNil.
	self assert: previousForm hasParent not.
	^ inspector
]

{ #category : 'examples - physics overlay' }
CFPhysicsOverlayTests >> physicsOverlayOwnsAndInstallsItsObjectInspector [
	<gtExample>
	| host overlay inspector |
	host := self physicsOverlayCanBeInstalled.
	overlay := host existingPhysicsOverlay.
	inspector := overlay objectInspector.
	self assert: inspector notNil.
	self assert: inspector isInstalled.
	self assert: inspector host == host.
	self assert: inspector root parent == host parent.
	^ overlay
]

{ #category : 'examples - physics overlay' }
CFPhysicsOverlayTests >> physicsOverlayReleasesItsObjectInspector [
	<gtExample>
	| host overlay inspector |
	host := self physicsOverlayCanBeInstalled.
	overlay := host existingPhysicsOverlay.
	inspector := overlay objectInspector.
	host hidePhysicsOverlay.
	self assert: inspector isInstalled not.
	self assert: inspector selectedPhysics isNil.
	self assert: inspector form isNil.
	self assert: inspector memento isNil.
	^ host
]


{ #category : 'examples - physics object selection' }
CFPhysicsOverlayTests >> physicsOverlaySelectsAnActivePhysicalElementOnClick [
	<gtExample>
	| host overlay element physics |
	host := self physicsOverlayCanBeInstalled.
	overlay := host existingPhysicsOverlay.
	element := host children first.
	physics := element existingPhysics.
	element fireEvent: BlClickEvent new.
	self assert: overlay selectedElement == element.
	self assert: overlay objectInspector selectedPhysics == physics.
	^ overlay
]

{ #category : 'examples - physics object selection' }
CFPhysicsOverlayTests >> physicsOverlayReplacesTheSelectedPhysicalElement [
	<gtExample>
	| host overlay first second |
	host := self physicsOverlayCanBeInstalled.
	overlay := host existingPhysicsOverlay.
	first := host children first.
	second := host children second.
	first fireEvent: BlClickEvent new.
	second fireEvent: BlClickEvent new.
	self assert: overlay selectedElement == second.
	self assert: overlay objectInspector selectedPhysics == second existingPhysics.
	^ overlay
]

{ #category : 'examples - physics object selection' }
CFPhysicsOverlayTests >> physicsOverlayClearsSelectionWhenTheSelectedElementIsClickedAgain [
	<gtExample>
	| host overlay element |
	host := self physicsOverlayCanBeInstalled.
	overlay := host existingPhysicsOverlay.
	element := host children first.
	element fireEvent: BlClickEvent new.
	element fireEvent: BlClickEvent new.
	self assert: overlay selectedElement isNil.
	self assert: overlay objectInspector selectedPhysics isNil.
	^ overlay
]

{ #category : 'examples - physics object selection' }
CFPhysicsOverlayTests >> physicsOverlayDoesNotCreatePhysicsWhenAPlainElementIsClicked [
	<gtExample>
	| host overlay element |
	host := self physicsOverlayCanBeInstalled.
	overlay := host existingPhysicsOverlay.
	element := BlElement new size: 20 @ 20.
	host addChild: element.
	self assert: element existingPhysics isNil.
	element fireEvent: BlClickEvent new.
	self assert: element existingPhysics isNil.
	self assert: overlay selectedElement isNil.
	self assert: overlay objectInspector selectedPhysics isNil.
	^ overlay
]


{ #category : 'examples - physics object selection' }
CFPhysicsOverlayTests >> physicsOverlayClearsSelectionWhenTheSelectedBodyRetires [
	<gtExample>
	| host overlay element physics |
	host := self physicsOverlayCanBeInstalled.
	overlay := host existingPhysicsOverlay.
	element := host children first.
	physics := element existingPhysics.
	element fireEvent: BlClickEvent new.
	self assert: overlay selectedElement == element.
	self assert: overlay objectInspector selectedPhysics == physics.
	element removeFromParent.
	overlay refresh.
	self assert: physics bodyState world isNil.
	self assert: overlay selectedElement isNil.
	self assert: overlay objectInspector selectedPhysics isNil.
	self assert: overlay objectInspector form isNil.
	^ overlay
]

{ #category : 'examples - physics object selection' }
CFPhysicsOverlayTests >> physicsOverlayKeepsRefreshingAnActiveSelection [
	<gtExample>
	| host overlay element physics |
	host := self physicsOverlayCanBeInstalled.
	overlay := host existingPhysicsOverlay.
	element := host children first.
	physics := element existingPhysics.
	element fireEvent: BlClickEvent new.
	overlay refreshFrameDiagnostics.
	self assert: overlay selectedElement == element.
	self assert: overlay objectInspector selectedPhysics == physics.
	^ overlay
]

{ #category : 'examples - physics object selection' }
CFPhysicsOverlayTests >> physicsOverlaySelectionPreservesPullDragging [
	<gtExample>
	| host overlay element scripter |
	host := self physicsOverlayCanBeInstalled.
	overlay := host existingPhysicsOverlay.
	element := host children first.
	element addEventHandler: BlPullHandler new.
	element fireEvent: BlClickEvent new.
	self assert: overlay selectedElement == element.
	self assert: overlay objectInspector selectedPhysics == element existingPhysics.
	scripter := BlScripter new element: host.
	scripter mouseMoveOver
		onChildAt: 1;
		play.
	scripter mouseDown play.
	scripter mouseMove
		by: 30 @ 0;
		play.
	self assert: overlay selectedElement == element.
	self assert: overlay objectInspector selectedPhysics == element existingPhysics.
	scripter mouseUp play.
	self assert: overlay selectedElement == element.
	self assert: overlay objectInspector selectedPhysics == element existingPhysics.
	^ overlay
]


{ #category : 'examples - physics object inspector' }
CFPhysicsOverlayTests >> physicsObjectInspectorOnlyHandlesMouseEventsInItsForm [
	<gtExample>
	| host inspector physics |
	host := self physicsHost.
	physics := host children first existingPhysics.
	inspector := CFPhysicsObjectInspector on: host.
	inspector inspect: physics.
	self assert: inspector root shouldHandleMouseEvents not.
	self assert: inspector root shouldChildrenHandleMouseEvents.
	self assert: inspector form shouldHandleMouseEvents.
	^ inspector
]

{ #category : 'examples - physics object selection' }
CFPhysicsOverlayTests >> physicsOverlayClearsSelectionWhenTheBackgroundIsClicked [
	<gtExample>
	| host overlay element |
	host := self physicsOverlayCanBeInstalled.
	overlay := host existingPhysicsOverlay.
	element := host children first.
	element fireEvent: BlClickEvent new.
	self assert: overlay selectedElement == element.
	host fireEvent: BlClickEvent new.
	self assert: overlay selectedElement isNil.
	self assert: overlay objectInspector selectedPhysics isNil.
	^ overlay
]

{ #category : 'examples - physics object selection' }
CFPhysicsOverlayTests >> physicsOverlayObservesConsumedButtonClicks [
	<gtExample>
	| space host button overlay scripter actionCount |
	space := BlSpace new.
	space time: BlTime simulated.
	host := BlElement new
		size: 400 @ 300;
		yourself.
	button := BrButton new
		label: 'Physical';
		size: 100 @ 40;
		addEventHandler: BlPullHandler new;
		yourself.
	actionCount := 0.
	button action: [ actionCount := actionCount + 1 ].
	host addChild: button.
	space root addChild: host.
	space pulse.
	host physics beWorld synchroniseMembership.
	overlay := host showPhysicsOverlay.
	scripter := BlScripter new.
	scripter element: host.
	scripter click
		onChildAt: 1;
		play.
	self assert: actionCount equals: 1.
	self assert: overlay selectedElement == button.
	self assert: overlay objectInspector selectedPhysics == button existingPhysics.
	^ overlay
]

{ #category : 'examples - physics object selection' }
CFPhysicsOverlayTests >> physicsOverlayIgnoresClicksInsideItsObjectInspector [
	<gtExample>
	| host overlay element event |
	host := self physicsOverlayCanBeInstalled.
	overlay := host existingPhysicsOverlay.
	element := host children first.
	element fireEvent: BlClickEvent new.
	self assert: overlay selectedElement == element.
	event := BlClickEvent new.
	event target: overlay objectInspector form.
	overlay clickEvent: event.
	self assert: overlay selectedElement == element.
	self assert: overlay objectInspector selectedPhysics == element existingPhysics.
	^ overlay
]
