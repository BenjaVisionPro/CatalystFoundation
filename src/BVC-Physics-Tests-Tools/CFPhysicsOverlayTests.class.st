Class {
	#name : 'CFPhysicsOverlayTests',
	#superclass : 'Object',
	#category : 'BVC-Physics-Tests-Tools',
	#package : 'BVC-Physics-Tests-Tools'
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
CFPhysicsOverlayTests >> physicsCanvassableHost [
	<gtExample>
	| space container host first second world |
	space := BlSpace new.
	container := BlElement new
		size: 500 @ 320;
		yourself.
	host := BlCanvassableElement new
		size: 420 @ 260;
		disableAutoScale;
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
	self assert: overlay bodyOverlay visuals size equals: 2.
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
	host := self physicsCanvassableHost.
	overlay := host showPhysicsOverlay.
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
	world := host physics world.
	body := world bodyStatesInOrder first.
	representation := overlay bodyOverlay visuals
		detect: [ :each | each body == body ].
	body
		position: 85 @ 70;
		rotation: Float pi / 4.0.
	overlay refresh.
	host space pulse.
	self assert: (overlay bodyOverlay visuals includes: representation).
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
	world := host physics world.
	retiredElement := host children first.
	retiredBody := world bodyStateFor: retiredElement.
	retiredElement removeFromParent.
	overlay refresh.
	self assert: (world bodyStatesInOrder includes: retiredBody) not.
	self assert: (overlay bodyOverlay visuals anySatisfy: [ :each | each body == retiredBody ]) not.
	self assert: overlay bodyOverlay visuals size equals: 1.
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
	self assert: overlay contactOverlay notNil.
	self assert: overlay contactOverlay visuals isEmpty.
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
	world := host physics world.
	first := host children first.
	second := host children second.
	first physics position: 80 @ 80.
	second physics position: 80 @ 80.
	world step.
	host fireEvent: CFPhysicsFramePresentedEvent new.
	self assert: overlay contactOverlay visuals isNotEmpty.
	second physics position: 260 @ 180.
	world step.
	host fireEvent: CFPhysicsFramePresentedEvent new.
	self assert: overlay contactOverlay visuals isEmpty.
	^ overlay
]

{ #category : 'examples - physics overlay' }
CFPhysicsOverlayTests >> physicsOverlayPresentsContactGeometryWithItsReferenceBody [
	<gtExample>
	| host overlay world first second firstBody visual initialPosition state expectedPosition context |
	host := self physicsOverlayCanBeInstalled.
	overlay := host existingPhysicsOverlay.
	world := host physics world.
	first := host children first.
	second := host children second.
	first physics position: 80 @ 80.
	second physics position: 80 @ 80.
	world step.
	host fireEvent: CFPhysicsFramePresentedEvent new.
	visual := overlay contactOverlay visuals first.
	initialPosition := visual firstPointPosition.
	firstBody := world activeContacts first firstBody.
	firstBody beginStep.
	firstBody translateBy: 100 @ 0.
	world presentAtAlpha: 0.5.
	host space pulse.
	host fireEvent: CFPhysicsFramePresentedEvent new.
	host space pulse.
	state := visual state.
	context := CFPhysicsOverlayContext host: host world: world overlay: overlay.
	expectedPosition := context
		overlayPointFromWorld: state firstPoint
		attachedTo: state firstBody.
	self assert: visual firstPointPosition equals: expectedPosition.
	self assert: (visual firstPointPosition = initialPosition) not.
	^ visual
]

{ #category : 'examples - physics overlay' }
CFPhysicsOverlayTests >> physicsOverlayNodeSelectionLeavesPhlowToTheNode [
	<gtExample>
	| host overlay node clickEvent phlowSelectionRequested |
	host := self physicsOverlayCanBeInstalled.
	overlay := host existingPhysicsOverlay.
	node := host children first.
	phlowSelectionRequested := false.
	node when: GtPhlowObjectToSelect do: [ :anEvent | phlowSelectionRequested := true ].
	clickEvent := BlClickEvent new.
	node fireEvent: clickEvent.
	self assert: overlay selectedElement == node.
	self assert: clickEvent isConsumed not.
	self assert: phlowSelectionRequested not.
	^ overlay
]


{ #category : 'examples - physics overlay' }
CFPhysicsOverlayTests >> physicsPresentationAndWorldCoordinatesAgreeForPositionedElements [
	<gtExample>
	| host overlay world body element physicsPosition displayedPoint worldPoint context |
	host := self physicsOverlayCanBeInstalled.
	overlay := host existingPhysicsOverlay.
	world := host physics world.
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
	world := host physics world.
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
	world := host physics world.
	first := host children first.
	second := host children second.
	first physics position: 80 @ 80.
	second physics position: 80 @ 80.
	world step.
	firstOverlay := host existingPhysicsOverlay.
	host fireEvent: CFPhysicsFramePresentedEvent new.
	self assert: firstOverlay contactOverlay visuals isNotEmpty.
	host hidePhysicsOverlay.
	self assert: firstOverlay contactOverlay visuals isEmpty.
	secondOverlay := host showPhysicsOverlay.
	host fireEvent: CFPhysicsFramePresentedEvent new.
	self assert: secondOverlay contactOverlay visuals isNotEmpty.
	self assert: firstOverlay contactOverlay visuals isEmpty.
	second physics position: 260 @ 180.
	world step.
	host fireEvent: CFPhysicsFramePresentedEvent new.
	self assert: secondOverlay contactOverlay visuals isEmpty.
	self assert: firstOverlay contactOverlay visuals isEmpty.
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
CFPhysicsOverlayTests >> physicsObjectInspectorBuildsItsSynchronousPanel [
	<gtExample>
	| host inspector physics |
	host := self physicsHost.
	physics := host children first existingPhysics.
	inspector := CFPhysicsObjectInspector on: host.
	inspector inspect: physics.
	self assert: inspector selectedPhysics == physics.
	self assert: inspector panel notNil.
	self assert: inspector panel parent == inspector root.
	self assert: (inspector includesEventTarget: inspector panel).
	self assert: inspector panel visibility equals: BlVisibility visible.
	^ inspector
]

 { #category : 'examples - physics object inspector' }
CFPhysicsOverlayTests >> physicsObjectInspectorReusesItsPanelWhenSelectionChanges [
	<gtExample>
	| host inspector firstPhysics secondPhysics originalPanel |
	host := self physicsHost.
	firstPhysics := host children first existingPhysics.
	secondPhysics := host children second existingPhysics.
	inspector := CFPhysicsObjectInspector on: host.
	originalPanel := inspector panel.
	inspector inspect: firstPhysics.
	inspector inspect: secondPhysics.
	self assert: inspector selectedPhysics == secondPhysics.
	self assert: inspector panel == originalPanel.
	self assert: inspector root children size equals: 1.
	^ inspector
]

{ #category : 'examples - physics object inspector' }
CFPhysicsOverlayTests >> physicsObjectInspectorContentTransition [
	<gtExample>
	| host world spring inspector physics outgoingElement motion |
	host := self physicsHost.
	world := host physics world.
	spring := CFPhysicsDistanceJoint
		between: world bodyStatesInOrder first
		and: world bodyStatesInOrder second.
	spring springEnabled: true; hertz: 3.0; dampingRatio: 1.0.
	world addDistanceJoint: spring.
	inspector := CFPhysicsObjectInspector on: host.
	inspector install.
	host space time: BlTime simulated.
	physics := host children first existingPhysics.
	inspector inspect: physics.
	host space pulse.
	outgoingElement := inspector content element.
	inspector inspect: spring.
	motion := inspector contentTransitionMotion.
	self assert: motion notNil.
	self assert: motion isRunning.
	self assert: motion tracks size equals: 3.
	self assert: inspector panel extent equals: motion tracks third sourceExtent.
	self assert: inspector panel children size equals: 1.
	self assert: inspector contentContainer children size equals: 2.
	self assert: outgoingElement opacity equals: 1.0.
	self assert: inspector content element opacity equals: 0.0.
	host space time wait: 200 milliSeconds.
	host space pulse.
	self assert: motion isCompleted.
	self assert: inspector panel children size equals: 1.
	self assert: inspector contentContainer children size equals: 1.
	self assert: inspector content element opacity equals: 1.0.
	^ inspector
]

 { #category : 'examples - physics object inspector' }
CFPhysicsOverlayTests >> physicsObjectInspectorCanClearItsObject [
	<gtExample>
	| host inspector physics panel |
	host := self physicsHost.
	physics := host children first existingPhysics.
	inspector := CFPhysicsObjectInspector on: host.
	panel := inspector panel.
	inspector inspect: physics.
	inspector clear.
	self assert: inspector selectedPhysics isNil.
	self assert: inspector panel == panel.
	self assert: inspector panel visibility equals: BlVisibility gone.
	self assert: (inspector valueElementAt: #bodyType) text asString equals: ''.
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
	self assert: inspector panel visibility equals: BlVisibility gone.
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
CFPhysicsOverlayTests >> physicsOverlayKeepsSelectionWhenTheSelectedElementIsClickedAgain [
	<gtExample>
	| host overlay element selectionVisual |
	host := self physicsOverlayCanBeInstalled.
	overlay := host existingPhysicsOverlay.
	element := host children first.
	element fireEvent: BlClickEvent new.
	selectionVisual := overlay selectionVisual.
	element fireEvent: BlClickEvent new.
	self assert: overlay selectedElement == element.
	self assert: overlay objectInspector selectedPhysics == element existingPhysics.
	self assert: overlay selectionVisual == selectionVisual.
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
	self assert: physics body world isNil.
	self assert: overlay selectedElement isNil.
	self assert: overlay objectInspector selectedPhysics isNil.
	self assert: overlay objectInspector panel visibility equals: BlVisibility gone.
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

{ #category : 'examples - physics object inspector' }
CFPhysicsOverlayTests >> physicsObjectInspectorRefreshesSynchronously [
	<gtExample>
	| host inspector physics |
	host := self physicsHost.
	physics := host children first existingPhysics.
	inspector := CFPhysicsObjectInspector on: host.
	inspector inspect: physics.
	physics
		translation: -12.1234 @ 34.4566 rotation: 123.1234;
		velocity: 12.3456 @ -34.5678;
		angularVelocity: 123.1234.
	inspector refresh.
	self assert: (inspector valueElementAt: #positionX) text asString equals: '-12.1234'.
	self assert: (inspector valueElementAt: #positionY) text asString equals: '34.4566'.
	self assert: (inspector valueElementAt: #rotation) text asString equals: '123.1234'.
	self assert: (inspector valueElementAt: #velocityX) text asString equals: '12.3456'.
	self assert: (inspector valueElementAt: #velocityY) text asString equals: '-34.5678'.
	self assert: (inspector valueElementAt: #angularVelocity) text asString equals: '123.1234'.
	^ inspector
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
CFPhysicsOverlayTests >> physicsObjectInspectorOnlyHandlesMouseEventsInItsPanel [
	<gtExample>
	| host inspector physics |
	host := self physicsHost.
	physics := host children first existingPhysics.
	inspector := CFPhysicsObjectInspector on: host.
	inspector inspect: physics.
	self assert: inspector root shouldHandleMouseEvents not.
	self assert: inspector root shouldChildrenHandleMouseEvents.
	self assert: inspector panel shouldHandleMouseEvents.
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
	event target: overlay objectInspector panel.
	overlay clickEvent: event.
	self assert: overlay selectedElement == element.
	self assert: overlay objectInspector selectedPhysics == element existingPhysics.
	^ overlay
]


{ #category : 'examples - physics object selection' }
CFPhysicsOverlayTests >> physicsOverlayHighlightsTheSelectedBody [
	<gtExample>
	| host overlay element selectedBody |
	host := self physicsOverlayCanBeInstalled.
	overlay := host existingPhysicsOverlay.
	element := host children first.
	selectedBody := element existingPhysics bodyOrNil.
	self assert: overlay selectionVisual isNil.
	element fireEvent: BlClickEvent new.
	self assert: overlay selectionVisual notNil.
	self assert: overlay selectionVisual body == selectedBody.
	^ overlay
]

{ #category : 'examples - physics object selection' }
CFPhysicsOverlayTests >> physicsOverlayMovesTheSelectionHighlight [
	<gtExample>
	| host overlay first second firstBody secondBody selection |
	host := self physicsOverlayCanBeInstalled.
	overlay := host existingPhysicsOverlay.
	first := host children first.
	second := host children second.
	firstBody := first existingPhysics bodyOrNil.
	secondBody := second existingPhysics bodyOrNil.
	first fireEvent: BlClickEvent new.
	selection := overlay selectionVisual.
	self assert: selection body == firstBody.
	second fireEvent: BlClickEvent new.
	self assert: overlay selectionVisual ~~ selection.
	self assert: overlay selectionVisual body == secondBody.
	^ overlay
]

{ #category : 'examples - physics object selection' }
CFPhysicsOverlayTests >> physicsOverlayClearsSelectionHighlightWhenTheBackgroundIsClicked [
	<gtExample>
	| host overlay element |
	host := self physicsOverlayCanBeInstalled.
	overlay := host existingPhysicsOverlay.
	element := host children first.
	element fireEvent: BlClickEvent new.
	self assert: overlay selectionVisual notNil.
	host fireEvent: BlClickEvent new.
	self assert: overlay selectionVisual isNil.
	^ overlay
]




{ #category : 'examples - physics object selection' }
CFPhysicsOverlayTests >> physicsOverlayKeepsSelectionVisibleWhenBodiesAreHidden [
	<gtExample>
	| host overlay element selectedBody |
	host := self physicsOverlayCanBeInstalled.
	overlay := host existingPhysicsOverlay.
	element := host children first.
	selectedBody := element existingPhysics bodyOrNil.
	element fireEvent: BlClickEvent new.
	self assert: overlay selectedElement == element.
	overlay bodiesEnabled: false.
	self assert: overlay bodyOverlay visuals isEmpty.
	self assert: overlay selectedElement == element.
	self assert: overlay selectionVisual notNil.
	self assert: overlay selectionVisual body == selectedBody.
	^ overlay
]


{ #category : 'examples - physics overlay' }
CFPhysicsOverlayTests >> physicsOverlayCreatesOneRetainedVisualPerSpring [
	<gtExample>
	| host world spring overlay |
	host := self physicsHost.
	world := host physics world.
	spring := CFPhysicsDistanceJoint
		between: world bodyStatesInOrder first
		and: world bodyStatesInOrder second.
	spring springEnabled: true; hertz: 3.0; dampingRatio: 1.0.
	world addDistanceJoint: spring.
	overlay := host showPhysicsOverlay.
	self assert: overlay springOverlay visuals size equals: 1.
	self assert: overlay springOverlay visuals first spring == spring.
	self assert: overlay springOverlay visuals first hasParent.
	^ overlay
]

{ #category : 'examples - physics overlay' }
CFPhysicsOverlayTests >> physicsSpringOverlayPreservesVisualIdentity [
	<gtExample>
	| host world spring overlay visual |
	host := self physicsHost.
	world := host physics world.
	spring := CFPhysicsDistanceJoint
		between: world bodyStatesInOrder first
		and: world bodyStatesInOrder second.
	spring springEnabled: true; hertz: 3.0; dampingRatio: 1.0.
	world addDistanceJoint: spring.
	overlay := host showPhysicsOverlay.
	visual := overlay springOverlay visuals first.
	overlay refresh.
	self assert: overlay springOverlay visuals first == visual.
	^ overlay
]

{ #category : 'examples - physics overlay' }
CFPhysicsOverlayTests >> physicsSpringVisualUsesItsAnchoredEndpointPair [
	<gtExample>
	| host world first second spring overlay visual firstPoint secondPoint context |
	host := self physicsHost.
	world := host physics world.
	first := world bodyStatesInOrder first.
	second := world bodyStatesInOrder second.
	spring := CFPhysicsDistanceJoint
		betweenAnchor: (CFPhysicsLocalAnchor on: first at: 0 @ 0)
		andAnchor: (CFPhysicsLocalAnchor on: second at: 90 @ 50).
	spring springEnabled: true; hertz: 3.0; dampingRatio: 1.0.
	world addDistanceJoint: spring.
	overlay := host showPhysicsOverlay.
	visual := overlay springOverlay visuals first.
	context := CFPhysicsOverlayContext host: host world: world overlay: overlay.
	firstPoint := context
		overlayPointFromWorld: spring endpointPair worldPointA
		attachedTo: spring endpointPair bodyA.
	secondPoint := context
		overlayPointFromWorld: spring endpointPair worldPointB
		attachedTo: spring endpointPair bodyB.
	self assert: visual fromPosition equals: firstPoint.
	self assert: visual toPosition equals: secondPoint.
	^ overlay
]

{ #category : 'examples - physics overlay' }
CFPhysicsOverlayTests >> physicsSpringVisualRefreshesOnPresentedFrame [
	<gtExample>
	| host world first second spring overlay visual originalPosition expectedPosition context |
	host := self physicsHost.
	world := host physics world.
	first := world bodyStatesInOrder first.
	second := world bodyStatesInOrder second.
	spring := CFPhysicsDistanceJoint between: first and: second.
	spring springEnabled: true; hertz: 3.0; dampingRatio: 1.0.
	world addDistanceJoint: spring.
	overlay := host showPhysicsOverlay.
	visual := overlay springOverlay visuals first.
	originalPosition := visual fromPosition.
	first beginStep.
	first translateBy: 45 @ 30.
	(CFPhysicsWorldPresentation on: world in: host space cfMotionCoordinator) presentAtAlpha: 0.5.
	host space pulse.
	host fireEvent: CFPhysicsFramePresentedEvent new.
	context := CFPhysicsOverlayContext host: host world: world overlay: overlay.
	expectedPosition := context
		overlayPointFromWorld: spring endpointPair worldPointA
		attachedTo: spring endpointPair bodyA.
	self assert: (visual fromPosition = originalPosition) not.
	self assert: visual fromPosition equals: expectedPosition.
	^ overlay
]

{ #category : 'examples - physics overlay' }
CFPhysicsOverlayTests >> physicsOverlayPresentationDiagnosticsFollowHostTransformation [
	<gtExample>
	| host overlay world first second spring springVisual contactVisual initialSpringPoint initialContactPoint context contactState expectedSpringPoint expectedContactPoint |
	host := self physicsCanvassableHost.
	overlay := host showPhysicsOverlay.
	host space pulse.
	overlay := host existingPhysicsOverlay.
	world := host physics world.
	first := host children first.
	second := host children second.
	spring := CFPhysicsDistanceJoint between: first physics body and: second physics body.
	spring
		springEnabled: true;
		hertz: 3.0;
		dampingRatio: 1.0;
		collideConnected: true.
	world addDistanceJoint: spring.
	overlay refresh.
	first physics position: 80 @ 80.
	second physics position: 80 @ 80.
	world step.
	host fireEvent: CFPhysicsFramePresentedEvent new.
	springVisual := overlay springOverlay visuals first.
	contactVisual := overlay contactOverlay visuals first.
	initialSpringPoint := springVisual fromPosition.
	initialContactPoint := contactVisual firstPointPosition.
	host childrenTranslationFactor: 70 @ 45.
	host space pulse.
	"The transformation event relocates contact markers during this pulse; commit those relocations before reading their positions."
	host space pulse.
	context := CFPhysicsOverlayContext host: host world: world overlay: overlay.
	expectedSpringPoint := context
		overlayPointFromWorld: spring endpointPair worldPointA
		attachedTo: spring endpointPair bodyA.
	contactState := contactVisual state.
	expectedContactPoint := context
		overlayPointFromWorld: contactState firstPoint
		attachedTo: contactState firstBody.
	self assert: (springVisual fromPosition = initialSpringPoint) not.
	self assert: (contactVisual firstPointPosition = initialContactPoint) not.
	self assert: springVisual fromPosition equals: expectedSpringPoint.
	self assert: contactVisual firstPointPosition equals: expectedContactPoint.
	^ overlay
]

{ #category : 'examples - physics object selection' }
CFPhysicsOverlayTests >> physicsOverlaySelectsASpringFromItsOverlayHitTarget [
	<gtExample>
	| host world spring overlay visual |
	host := self physicsHost.
	world := host physics world.
	spring := CFPhysicsDistanceJoint
		between: world bodyStatesInOrder first
		and: world bodyStatesInOrder second.
	spring springEnabled: true; hertz: 3.0; dampingRatio: 1.0.
	world addDistanceJoint: spring.
	overlay := host showPhysicsOverlay.
	host space pulse.
	visual := overlay springOverlay visuals first.
	BlSpace simulateClickOn: visual hitTarget.
	self assert: overlay selectedSpring == spring.
	self assert: overlay selectedElement isNil.
	self assert: overlay selectionVisual isSelection.
	self assert: overlay selectionVisual spring == spring.
	^ overlay
]

{ #category : 'examples - physics object selection' }
CFPhysicsOverlayTests >> physicsOverlayMaintainsSingleSelectionAcrossBodiesSpringsAndJoints [
	<gtExample>
	| host overlay world first spring joint springVisual jointVisual |
	host := self physicsOverlayCanBeInstalled.
	overlay := host existingPhysicsOverlay.
	world := host physics world.
	first := host children first.
	spring := CFPhysicsDistanceJoint
		between: world bodyStatesInOrder first
		and: world bodyStatesInOrder second.
	spring springEnabled: true; hertz: 3.0; dampingRatio: 1.0.
	world addDistanceJoint: spring.
	joint := (first physics localAnchorAt: 20 @ 20)
		distanceJointTo: (world anchorAt: 240 @ 40).
	overlay refresh.
	host space pulse.
	first fireEvent: BlClickEvent new.
	self assert: overlay selectedElement == first.
	self assert: overlay selectedSpring isNil.
	self assert: overlay selectedJoint isNil.
	springVisual := overlay springOverlay visuals first.
	springVisual hitTarget fireEvent: BlClickEvent new.
	self assert: overlay selectedElement isNil.
	self assert: overlay selectedSpring == spring.
	self assert: overlay selectedJoint isNil.
	jointVisual := overlay jointOverlay visuals first.
	jointVisual hitTarget fireEvent: BlClickEvent new.
	self assert: overlay selectedElement isNil.
	self assert: overlay selectedSpring isNil.
	self assert: overlay selectedJoint == joint.
	host fireEvent: BlClickEvent new.
	self assert: overlay selectedElement isNil.
	self assert: overlay selectedSpring isNil.
	self assert: overlay selectedJoint isNil.
	self assert: overlay selectionVisual isNil.
	self assert: overlay objectInspector selectedObject isNil.
	^ overlay
]

CFPhysicsOverlayTests >> physicsSpringVisualMarksBothAnchoredEndpoints [
	<gtExample>
	| host world first second spring overlay visual |
	host := self physicsHost.
	world := host physics world.
	first := world bodyStatesInOrder first.
	second := world bodyStatesInOrder second.
	spring := CFPhysicsDistanceJoint
		betweenAnchor: (CFPhysicsLocalAnchor on: first at: 0 @ 0)
		andAnchor: (CFPhysicsLocalAnchor on: second at: 90 @ 50).
	spring springEnabled: true; hertz: 3.0; dampingRatio: 1.0.
	world addDistanceJoint: spring.
	overlay := host showPhysicsOverlay.
	visual := overlay springOverlay visuals first.
	self assert: visual fromHead class equals: BlArrowheadCircle.
	self assert: visual toHead class equals: BlArrowheadCircle.
	self assert: visual fromHead parent == visual.
	self assert: visual toHead parent == visual.
	^ overlay
]

{ #category : 'examples - physics overlay' }
CFPhysicsOverlayTests >> physicsSpringVisualMarksItsRestLength [
	<gtExample>
	| host world first second spring overlay visual firstPoint secondPoint direction expectedMarkerPosition |
	host := self physicsHost.
	world := host physics world.
	first := world bodyStatesInOrder first.
	second := world bodyStatesInOrder second.
	spring := CFPhysicsDistanceJoint
		betweenAnchor: (CFPhysicsLocalAnchor on: first at: 0 @ 0)
		andAnchor: (CFPhysicsLocalAnchor on: second at: 90 @ 50).
	spring springEnabled: true; hertz: 3.0; dampingRatio: 1.0.
	spring length: 24.
	world addDistanceJoint: spring.
	overlay := host showPhysicsOverlay.
	visual := overlay springOverlay visuals first.
	host space pulse.
	firstPoint := visual fromPosition.
	secondPoint := visual toPosition.
	direction := secondPoint - firstPoint.
	expectedMarkerPosition := firstPoint
		+ (direction * (spring length asFloat / (spring endpointPair worldPointB - spring endpointPair worldPointA) r))
		- (4 @ 4).
	self assert: visual restLengthMarker hasParent.
	self assert: visual restLengthMarker position equals: expectedMarkerPosition.
	^ overlay
]

{ #category : 'examples - physics overlay' }
CFPhysicsOverlayTests >> physicsSpringOverlayRemovesReleasedSprings [
	<gtExample>
	| host world spring overlay visual |
	host := self physicsHost.
	world := host physics world.
	spring := CFPhysicsDistanceJoint
		between: world bodyStatesInOrder first
		and: world bodyStatesInOrder second.
	spring springEnabled: true; hertz: 3.0; dampingRatio: 1.0.
	world addDistanceJoint: spring.
	overlay := host showPhysicsOverlay.
	visual := overlay springOverlay visuals first.
	world removeDistanceJoint: spring.
	overlay refresh.
	self assert: overlay springOverlay visuals isEmpty.
	self assert: visual hasParent not.
	^ overlay
]

{ #category : 'examples - physics overlay' }
CFPhysicsOverlayTests >> physicsSpringOverlayIsEmptyWhileDisabled [
	<gtExample>
	| host world spring overlay |
	host := self physicsHost.
	world := host physics world.
	spring := CFPhysicsDistanceJoint
		between: world bodyStatesInOrder first
		and: world bodyStatesInOrder second.
	spring springEnabled: true; hertz: 3.0; dampingRatio: 1.0.
	world addDistanceJoint: spring.
	overlay := host showPhysicsOverlay.
	overlay controls element children third deactivate.
	self assert: overlay controls springsEnabled not.
	self assert: overlay springOverlay visuals isEmpty.
	overlay refresh.
	self assert: overlay springOverlay visuals isEmpty.
	^ overlay
]

{ #category : 'examples - physics overlay - joints' }
CFPhysicsOverlayTests >> physicsJointOverlayCreatesVisualsForWorldJoints [
	<gtExample>
	| host overlay world first joint visual |
	host := self physicsOverlayCanBeInstalled.
	overlay := host existingPhysicsOverlay.
	world := host physics world.
	first := host children first.
	joint := (first physics localAnchorAt: 20 @ 20)
		distanceJointTo: (world anchorAt: 20 @ 20).
	overlay refresh.
	host space pulse.
	self assert: overlay jointOverlay visuals size equals: 1.
	visual := overlay jointOverlay visuals first.
	self assert: visual joint == joint.
	^ host
]

{ #category : 'examples - physics overlay - joints' }
CFPhysicsOverlayTests >> physicsJointOverlayPreservesVisualIdentity [
	<gtExample>
	| host overlay world first joint visual |
	host := self physicsOverlayCanBeInstalled.
	overlay := host existingPhysicsOverlay.
	world := host physics world.
	first := host children first.
	joint := (first physics localAnchorAt: 20 @ 20)
		distanceJointTo: (world anchorAt: 20 @ 20).
	overlay refresh.
	visual := overlay jointOverlay visuals first.
	overlay refresh.
	self assert: overlay jointOverlay visuals first == visual.
	^ host
]

{ #category : 'examples - physics overlay - joints' }
CFPhysicsOverlayTests >> physicsJointOverlayRemovesRetiredVisuals [
	<gtExample>
	| host overlay world first joint visual |
	host := self physicsOverlayCanBeInstalled.
	overlay := host existingPhysicsOverlay.
	world := host physics world.
	first := host children first.
	joint := (first physics localAnchorAt: 20 @ 20)
		distanceJointTo: (world anchorAt: 20 @ 20).
	overlay refresh.
	visual := overlay jointOverlay visuals first.
	world removeDistanceJoint: joint.
	overlay refresh.
	self assert: overlay jointOverlay visuals isEmpty.
	self assert: visual hasParent not.
	self assert: visual hitTarget hasParent not.
	^ host
]

{ #category : 'examples - physics overlay - joints' }
CFPhysicsOverlayTests >> physicsJointOverlayUsesDisplayedAnchorCoordinates [
	<gtExample>
	| host overlay world first joint visual context points expectedFirst expectedSecond |
	host := self physicsOverlayCanBeInstalled.
	overlay := host existingPhysicsOverlay.
	world := host physics world.
	first := host children first.
	joint := (first physics localAnchorAt: 10 @ 12)
		distanceJointTo: (world anchorAt: 280 @ 60).
	overlay refresh.
	host space pulse.
	visual := overlay jointOverlay visuals first.
	points := joint endpointPair worldPoints.
	context := CFPhysicsOverlayContext host: host world: world overlay: overlay.
	expectedFirst := context
		overlayPointFromWorld: points first
		attachedTo: joint endpointPair bodyA.
	expectedSecond := context
		overlayPointFromWorld: points second
		attachedTo: joint endpointPair bodyB.
	self assert: visual fromPosition equals: expectedFirst.
	self assert: visual toPosition equals: expectedSecond.
	^ host
]

{ #category : 'examples - physics overlay - joints' }
CFPhysicsOverlayTests >> physicsJointOverlayClearsWhenDisabled [
	<gtExample>
	| host overlay world first visual |
	host := self physicsOverlayCanBeInstalled.
	overlay := host existingPhysicsOverlay.
	world := host physics world.
	first := host children first.
	(first physics localAnchorAt: 20 @ 20)
		distanceJointTo: (world anchorAt: 20 @ 20).
	overlay refresh.
	visual := overlay jointOverlay visuals first.
	overlay jointsEnabled: false.
	self assert: overlay jointOverlay visuals isEmpty.
	self assert: visual hasParent not.
	self assert: visual hitTarget hasParent not.
	^ host
]

{ #category : 'examples - physics object selection' }
CFPhysicsOverlayTests >> physicsOverlaySelectsAJointFromItsOverlayHitTarget [
	<gtExample>
	| host overlay world first joint visual |
	host := self physicsOverlayCanBeInstalled.
	overlay := host existingPhysicsOverlay.
	world := host physics world.
	first := host children first.
	joint := (first physics localAnchorAt: 20 @ 20)
		distanceJointTo: (world anchorAt: 240 @ 40).
	overlay refresh.
	host space pulse.
	visual := overlay jointOverlay visuals first.
	BlSpace simulateClickOn: visual hitTarget.
	self assert: overlay selectedJoint == joint.
	self assert: overlay selectedSpring isNil.
	self assert: overlay selectedElement isNil.
	self assert: overlay selectionVisual isSelection.
	self assert: overlay selectionVisual joint == joint.
	^ overlay
]

{ #category : 'examples - physics object selection' }
CFPhysicsOverlayTests >> physicsOverlayKeepsSelectedJointWhenClickedAgain [
	<gtExample>
	| overlay diagnostic joint selectionVisual |
	overlay := self physicsOverlaySelectsAJointFromItsOverlayHitTarget.
	diagnostic := overlay jointOverlay visuals first.
	joint := overlay selectedJoint.
	selectionVisual := overlay selectionVisual.
	BlSpace simulateClickOn: diagnostic hitTarget.
	self assert: overlay selectedJoint == joint.
	self assert: overlay selectionVisual == selectionVisual.
	^ overlay
]

{ #category : 'examples - physics object selection' }
CFPhysicsOverlayTests >> physicsOverlayClearsSelectionWhenSelectedJointIsRemoved [
	<gtExample>
	| overlay world joint |
	overlay := self physicsOverlaySelectsAJointFromItsOverlayHitTarget.
	world := overlay world.
	joint := overlay selectedJoint.
	world removeDistanceJoint: joint.
	overlay refresh.
	self assert: overlay selectedJoint isNil.
	self assert: overlay selectionVisual isNil.
	^ overlay
]

{ #category : 'examples - physics object selection' }
CFPhysicsOverlayTests >> physicsOverlayClearsSelectedJointWhenJointsAreDisabled [
	<gtExample>
	| overlay |
	overlay := self physicsOverlaySelectsAJointFromItsOverlayHitTarget.
	overlay jointsEnabled: false.
	self assert: overlay selectedJoint isNil.
	self assert: overlay selectionVisual isNil.
	self assert: overlay jointOverlay visuals isEmpty.
	^ overlay
]


{ #category : 'examples - physics object inspector' }
CFPhysicsOverlayTests >> physicsOverlayInspectsSelectedJoint [
	<gtExample>
	| overlay joint inspector content |
	overlay := self physicsOverlaySelectsAJointFromItsOverlayHitTarget.
	joint := overlay selectedJoint.
	inspector := overlay objectInspector.
	content := inspector content.
	self assert: inspector selectedObject == joint.
	self assert: content class equals: CFPhysicsJointInspectorContent.
	self assert: content joint == joint.
	self assert: (content valueElementAt: #jointType) text asString equals: 'Distance'.
	self assert: (content valueElementAt: #active) text asString equals: joint isActive printString.
	self assert: (content valueElementAt: #sequence) text asString equals: joint sequence printString.
	^ overlay
]

{ #category : 'examples - physics object inspector' }
CFPhysicsOverlayTests >> physicsOverlayRefreshesSelectedJointInspector [
	<gtExample>
	| overlay joint content initialAnchor |
	overlay := self physicsOverlayInspectsSelectedJoint.
	joint := overlay selectedJoint.
	content := overlay objectInspector content.
	initialAnchor := (content valueElementAt: #anchorA) text asString.
	joint bodyA beginStep.
	joint bodyA translateBy: 40 @ 0.
	overlay world presentAtAlpha: 1.0.
	overlay host fireEvent: CFPhysicsFramePresentedEvent new.
	self assert: ((content valueElementAt: #anchorA) text asString = initialAnchor) not.
	self assert: overlay objectInspector selectedObject == joint.
	^ overlay
]

{ #category : 'examples - physics object inspector' }
CFPhysicsOverlayTests >> physicsOverlayClearsJointInspectorWhenJointIsRemoved [
	<gtExample>
	| overlay world joint |
	overlay := self physicsOverlayInspectsSelectedJoint.
	world := overlay world.
	joint := overlay selectedJoint.
	world removeDistanceJoint: joint.
	overlay refresh.
	self assert: overlay objectInspector selectedObject isNil.
	self assert: overlay objectInspector content joint isNil.
	^ overlay
]

{ #category : 'examples - physics overlay - joints' }
CFPhysicsOverlayTests >> physicsDistanceJointVisualShowsItsRestLength [
	<gtExample>
	| host overlay world first joint visual points context firstPoint secondPoint distance expectedPosition |
	host := self physicsOverlayCanBeInstalled.
	overlay := host existingPhysicsOverlay.
	world := host physics world.
	first := host children first.
	joint := (first physics localAnchorAt: 10 @ 12)
		distanceJointTo: (world anchorAt: 280 @ 60).
	joint length: 120.0.
	overlay refresh.
	host space pulse.
	visual := overlay jointOverlay visuals first.
	points := joint endpointPair worldPoints.
	context := CFPhysicsOverlayContext host: host world: world overlay: overlay.
	firstPoint := context
		overlayPointFromWorld: points first
		attachedTo: joint bodyA.
	secondPoint := context
		overlayPointFromWorld: points second
		attachedTo: joint bodyB.
	distance := (points second - points first) r.
	expectedPosition := firstPoint
		+ ((secondPoint - firstPoint) * (joint length / distance))
		- (4 @ 4).
	self assert: visual restLengthMarker visibility equals: BlVisibility visible.
	self assert: visual restLengthMarker position equals: expectedPosition.
	^ visual
]

{ #category : 'examples - physics overlay - joints' }
CFPhysicsOverlayTests >> physicsNonDistanceJointVisualHidesTheRestLengthMarker [
	<gtExample>
	| host overlay world first second joint visual |
	host := self physicsOverlayCanBeInstalled.
	overlay := host existingPhysicsOverlay.
	world := host physics world.
	first := host children first.
	second := host children second.
	joint := (first physics localAnchorAt: 20 @ 20)
		weldJointTo: (second physics localAnchorAt: 20 @ 20).
	overlay refresh.
	host space pulse.
	visual := overlay jointOverlay visuals first.
	self assert: visual joint == joint.
	self assert: visual restLengthMarker visibility equals: BlVisibility gone.
	^ visual
]


{ #category : 'examples - physics overlay - joints' }
CFPhysicsOverlayTests >> physicsPrismaticJointVisualShowsItsAxisAndLimits [
	<gtExample>
	| host overlay world first joint visual points context secondPoint axisStart axisEnd displayedAxis expectedStart expectedEnd normal |
	host := self physicsOverlayCanBeInstalled.
	overlay := host existingPhysicsOverlay.
	world := host physics world.
	first := host children first.
	joint := (first physics localAnchorAt: 20 @ 20)
		prismaticJointTo: (world anchorAt: 180 @ 80)
		along: 1 @ 0.
	joint
		limitTranslationFrom: -30 to: 50;
		limitsEnabled: true.
	overlay refresh.
	host space pulse.
	visual := overlay jointOverlay visuals first.
	points := joint endpointPair worldPoints.
	context := CFPhysicsOverlayContext host: host world: world overlay: overlay.
	secondPoint := context
		overlayPointFromWorld: points first
		attachedTo: joint bodyA.
	axisStart := context overlayPointFromWorld: points first.
	axisEnd := context overlayPointFromWorld: points first + joint physicsOverlayWorldAxis.
	displayedAxis := axisEnd - axisStart.
	displayedAxis := displayedAxis / displayedAxis r.
	expectedStart := secondPoint + (displayedAxis * (joint lowerTranslation)).
	expectedEnd := secondPoint + (displayedAxis * (joint upperTranslation)).
	normal := displayedAxis y negated @ displayedAxis x.
	self assert: visual rail visibility equals: BlVisibility visible.
	self assert: visual rail fromPosition equals: expectedStart.
	self assert: visual rail toPosition equals: expectedEnd.
	self assert: visual lowerLimitMarker visibility equals: BlVisibility visible.
	self assert: visual lowerLimitMarker fromPosition equals: expectedStart - (normal * 6.0).
	self assert: visual lowerLimitMarker toPosition equals: expectedStart + (normal * 6.0).
	self assert: visual upperLimitMarker visibility equals: BlVisibility visible.
	self assert: visual upperLimitMarker fromPosition equals: expectedEnd - (normal * 6.0).
	self assert: visual upperLimitMarker toPosition equals: expectedEnd + (normal * 6.0).
	^ visual
]

{ #category : 'examples - physics overlay - joints' }
CFPhysicsOverlayTests >> physicsPrismaticJointVisualHidesLimitMarkersWhenLimitsAreDisabled [
	<gtExample>
	| host overlay world first joint visual |
	host := self physicsOverlayCanBeInstalled.
	overlay := host existingPhysicsOverlay.
	world := host physics world.
	first := host children first.
	joint := (first physics localAnchorAt: 20 @ 20)
		prismaticJointTo: (world anchorAt: 180 @ 80)
		along: 1 @ 0.
	overlay refresh.
	host space pulse.
	visual := overlay jointOverlay visuals first.
	self assert: visual rail visibility equals: BlVisibility visible.
	self assert: visual lowerLimitMarker visibility equals: BlVisibility gone.
	self assert: visual upperLimitMarker visibility equals: BlVisibility gone.
	^ visual
]

{ #category : 'examples - physics overlay - joints' }
CFPhysicsOverlayTests >> physicsRevoluteJointVisualShowsPivotAndReferenceDirection [
	<gtExample>
	| host overlay world first joint visual points context firstPoint secondPoint pivotPoint |
	host := self physicsOverlayCanBeInstalled.
	overlay := host existingPhysicsOverlay.
	world := host physics world.
	first := host children first.
	joint := (first physics localAnchorAt: 20 @ 20)
		revoluteJointTo: (world anchorAt: 180 @ 80).
	overlay refresh.
	host space pulse.
	visual := overlay jointOverlay visuals first.
	points := joint endpointPair worldPoints.
	context := CFPhysicsOverlayContext host: host world: world overlay: overlay.
	firstPoint := context
		overlayPointFromWorld: points first
		attachedTo: joint bodyA.
	secondPoint := context
		overlayPointFromWorld: points second
		attachedTo: joint bodyB.
	pivotPoint := (firstPoint + secondPoint) / 2.0.
	self assert: visual pivotMarker visibility equals: BlVisibility visible.
	self assert: visual pivotMarker position equals: pivotPoint - (5 @ 5).
	self assert: visual referenceRay visibility equals: BlVisibility visible.
	self assert: visual referenceRay fromPosition equals: pivotPoint.
	self assert: visual lowerAngleMarker visibility equals: BlVisibility gone.
	self assert: visual upperAngleMarker visibility equals: BlVisibility gone.
	self assert: visual allowedAngleArc visibility equals: BlVisibility gone.
	^ visual
]

{ #category : 'examples - physics overlay - joints' }
CFPhysicsOverlayTests >> physicsRevoluteJointVisualShowsConfiguredAngularLimits [
	<gtExample>
	| host overlay world first joint visual |
	host := self physicsOverlayCanBeInstalled.
	overlay := host existingPhysicsOverlay.
	world := host physics world.
	first := host children first.
	joint := (first physics localAnchorAt: 20 @ 20)
		revoluteJointTo: (world anchorAt: 180 @ 80).
	joint
		limitAnglesFrom: Float pi negated / 4.0 to: Float pi / 3.0;
		limitsEnabled: true.
	overlay refresh.
	host space pulse.
	visual := overlay jointOverlay visuals first.
	self assert: visual lowerAngleMarker visibility equals: BlVisibility visible.
	self assert: visual upperAngleMarker visibility equals: BlVisibility visible.
	self assert: visual allowedAngleArc visibility equals: BlVisibility visible.
	self assert: visual allowedAngleArc geometry startAngle < visual allowedAngleArc geometry endAngle.
	^ visual
]

{ #category : 'examples - physics overlay - joints' }
CFPhysicsOverlayTests >> physicsRevoluteJointVisualShowsMotorDirectionOnlyWhenEnabled [
	<gtExample>
	| host overlay world first joint visual |
	host := self physicsOverlayCanBeInstalled.
	overlay := host existingPhysicsOverlay.
	world := host physics world.
	first := host children first.
	joint := (first physics localAnchorAt: 20 @ 20)
		revoluteJointTo: (world anchorAt: 180 @ 80).
	overlay refresh.
	host space pulse.
	visual := overlay jointOverlay visuals first.
	self assert: visual motorCue visibility equals: BlVisibility gone.
	joint
		motorSpeed: 1.5;
		maximumMotorImpulse: 2.0;
		motorEnabled: true.
	overlay refreshPresentationGeometry.
	host space pulse.
	self assert: visual motorCue visibility equals: BlVisibility visible.
	joint motorEnabled: false.
	overlay refreshPresentationGeometry.
	host space pulse.
	self assert: visual motorCue visibility equals: BlVisibility gone.
	^ visual
]

{ #category : 'examples - physics overlay - joints' }
CFPhysicsOverlayTests >> physicsWeldJointVisualShowsItsLockedReferenceOrientation [
	<gtExample>
	| host overlay world first second joint visual points context firstPoint secondPoint pivotPoint |
	host := self physicsOverlayCanBeInstalled.
	overlay := host existingPhysicsOverlay.
	world := host physics world.
	first := host children first.
	second := host children second.
	joint := (first physics localAnchorAt: 20 @ 20)
		weldJointTo: (second physics localAnchorAt: 20 @ 20).
	overlay refresh.
	host space pulse.
	visual := overlay jointOverlay visuals first.
	points := joint endpointPair worldPoints.
	context := CFPhysicsOverlayContext host: host world: world overlay: overlay.
	firstPoint := context
		overlayPointFromWorld: points first
		attachedTo: joint bodyA.
	secondPoint := context
		overlayPointFromWorld: points second
		attachedTo: joint bodyB.
	pivotPoint := (firstPoint + secondPoint) / 2.0.
	self assert: visual pivotMarker visibility equals: BlVisibility visible.
	self assert: visual pivotMarker position equals: pivotPoint - (5 @ 5).
	self assert: visual referenceRay visibility equals: BlVisibility visible.
	self assert: visual referenceRay fromPosition equals: pivotPoint.
	self assert: visual lowerAngleMarker visibility equals: BlVisibility visible.
	self assert: visual upperAngleMarker visibility equals: BlVisibility visible.
	self assert: visual allowedAngleArc visibility equals: BlVisibility gone.
	self assert: visual motorCue visibility equals: BlVisibility gone.
	^ visual
]

{ #category : 'examples - physics overlay - joints' }
CFPhysicsOverlayTests >> physicsWeldJointVisualTracksReferenceAngleChanges [
	<gtExample>
	| visual overlay joint initialEnd |
	visual := self physicsWeldJointVisualShowsItsLockedReferenceOrientation.
	overlay := visual context overlay.
	joint := visual joint.
	initialEnd := visual referenceRay toPosition.
	joint referenceAngle: joint referenceAngle + (Float pi / 4.0).
	overlay refreshPresentationGeometry.
	overlay host space pulse.
	self assert: visual referenceRay toPosition ~= initialEnd.
	self assert: visual lowerAngleMarker visibility equals: BlVisibility visible.
	self assert: visual upperAngleMarker visibility equals: BlVisibility visible.
	^ visual
]

{ #category : 'examples - physics object selection' }
CFPhysicsOverlayTests >> physicsOverlaySelectsAWeldJointAcrossItsVisibleGlyph [
	<gtExample>
	| visual overlay joint |
	visual := self physicsWeldJointVisualShowsItsLockedReferenceOrientation.
	overlay := visual context overlay.
	joint := visual joint.
	BlSpace simulateClickOn: visual hitTarget.
	self assert: overlay selectedJoint == joint.
	self assert: overlay selectedElement isNil.
	self assert: overlay selectedSpring isNil.
	^ overlay
]

{ #category : 'examples - physics object selection' }
CFPhysicsOverlayTests >> physicsOverlaySelectsARevoluteJointAcrossItsVisibleGlyph [
	<gtExample>
	| visual overlay joint |
	visual := self physicsRevoluteJointVisualShowsPivotAndReferenceDirection.
	overlay := visual context overlay.
	joint := visual joint.
	BlSpace simulateClickOn: visual hitTarget.
	self assert: overlay selectedJoint == joint.
	self assert: overlay selectedElement isNil.
	self assert: overlay selectedSpring isNil.
	^ overlay
]

{ #category : 'examples - physics object inspector' }
CFPhysicsOverlayTests >> physicsOverlayDistanceJointInspectorShowsConfigurationAndSolverState [
	<gtExample>
	| overlay joint content points |
	overlay := self physicsOverlayInspectsSelectedJoint.
	joint := overlay selectedJoint.
	content := overlay objectInspector content.
	points := joint endpointPair worldPoints.
	self assert: (content valueElementAt: #length) text asString equals: (content formatDiagnosticNumber: joint length).
	self assert: (content valueElementAt: #currentLength) text asString equals: (content formatDiagnosticNumber: (points second - points first) r).
	self assert: (content valueElementAt: #impulse) text asString equals: (content formatDiagnosticNumber: joint impulse).
	^ overlay
]

{ #category : 'examples - physics object inspector' }
CFPhysicsOverlayTests >> physicsOverlayRevoluteJointInspectorShowsLimitsAndMotor [
	<gtExample>
	| host overlay world first joint content |
	host := self physicsOverlayCanBeInstalled.
	overlay := host existingPhysicsOverlay.
	world := host physics world.
	first := host children first.
	joint := (first physics localAnchorAt: 20 @ 20)
		revoluteJointTo: (world anchorAt: 180 @ 80).
	joint
		limitAnglesFrom: -0.4 to: 0.7;
		limitsEnabled: true;
		motorSpeed: 1.5;
		maximumMotorImpulse: 2.0;
		motorEnabled: true.
	overlay refresh.
	overlay selectJoint: joint.
	content := overlay objectInspector content.
	self assert: (content valueElementAt: #limitsEnabled) text asString equals: 'true'.
	self assert: (content valueElementAt: #lowerAngle) text asString equals: (content formatDiagnosticNumber: joint lowerAngle).
	self assert: (content valueElementAt: #upperAngle) text asString equals: (content formatDiagnosticNumber: joint upperAngle).
	self assert: (content valueElementAt: #motorEnabled) text asString equals: 'true'.
	self assert: (content valueElementAt: #motorSpeed) text asString equals: (content formatDiagnosticNumber: joint motorSpeed).
	^ overlay
]

{ #category : 'examples - physics object inspector' }
CFPhysicsOverlayTests >> physicsOverlayPrismaticJointInspectorShowsAxisLimitsAndSolverState [
	<gtExample>
	| host overlay world first joint content |
	host := self physicsOverlayCanBeInstalled.
	overlay := host existingPhysicsOverlay.
	world := host physics world.
	first := host children first.
	joint := (first physics localAnchorAt: 20 @ 20)
		prismaticJointTo: (world anchorAt: 180 @ 80)
		along: 1 @ 0.
	joint
		limitTranslationFrom: -25.0 to: 40.0;
		limitsEnabled: true.
	overlay refresh.
	overlay selectJoint: joint.
	content := overlay objectInspector content.
	self assert: (content valueElementAt: #localAxisA) text asString equals: (content formatPoint: joint localAxisA).
	self assert: (content valueElementAt: #limitsEnabled) text asString equals: 'true'.
	self assert: (content valueElementAt: #lowerTranslation) text asString equals: (content formatDiagnosticNumber: joint lowerTranslation).
	self assert: (content valueElementAt: #upperTranslation) text asString equals: (content formatDiagnosticNumber: joint upperTranslation).
	^ overlay
]

{ #category : 'examples - physics object inspector' }
CFPhysicsOverlayTests >> physicsOverlayWeldJointInspectorDoesNotExposeRevoluteMotorFields [
	<gtExample>
	| host overlay world first joint content |
	host := self physicsOverlayCanBeInstalled.
	overlay := host existingPhysicsOverlay.
	world := host physics world.
	first := host children first.
	joint := (first physics localAnchorAt: 20 @ 20)
		weldJointTo: (world anchorAt: 180 @ 80).
	overlay refresh.
	overlay selectJoint: joint.
	content := overlay objectInspector content.
	self assert: (content valueElementAt: #referenceAngle) text asString equals: (content formatDiagnosticNumber: joint referenceAngle).
	self assert: (content valueElementAt: #accumulatedAngularImpulse) text asString equals: (content formatDiagnosticNumber: joint angularImpulse).
	self assert: (content valueElements includesKey: #motorEnabled) not.
	^ overlay
]


{ #category : 'examples - physics overlay - joints' }
CFPhysicsOverlayTests >> physicsWeldJointDiagnosticFollowsHostTransformation [
	<gtExample>
	| host overlay first second joint visual initialPivot |
	host := self physicsCanvassableHost.
	overlay := host showPhysicsOverlay.
	host space pulse.
	first := host children first.
	second := host children second.
	joint := (first physics localAnchorAt: 20 @ 20)
		weldJointTo: (second physics localAnchorAt: 20 @ 20).
	overlay refresh.
	host space pulse.
	visual := overlay jointOverlay visuals first.
	initialPivot := visual pivotMarker position.
	host childrenTranslationFactor: 70 @ 45.
	host space pulse.
	host space pulse.
	self assert: visual pivotMarker position ~= initialPivot.
	self assert: visual pivotMarker position equals: visual referenceRay fromPosition - (5 @ 5).
	^ overlay
]

{ #category : 'examples - physics overlay - joints' }
CFPhysicsOverlayTests >> physicsJointVisualReleasesEveryRetainedPrimitiveWhenDisabled [
	<gtExample>
	| visual overlay primitives |
	visual := self physicsWeldJointVisualShowsItsLockedReferenceOrientation.
	overlay := visual context overlay.
	primitives := {
		visual.
		visual rail.
		visual lowerLimitMarker.
		visual upperLimitMarker.
		visual restLengthMarker.
		visual pivotMarker.
		visual referenceRay.
		visual lowerAngleMarker.
		visual upperAngleMarker.
		visual allowedAngleArc.
		visual motorCue.
		visual hitTarget }.
	self assert: (primitives allSatisfy: #hasParent).
	overlay jointsEnabled: false.
	self assert: overlay jointOverlay visuals isEmpty.
	self assert: (primitives noneSatisfy: #hasParent).
	^ overlay
]

{ #category : 'examples - physics object inspector' }
CFPhysicsOverlayTests >> physicsOverlayReplacesJointInspectorContentAcrossJointTypes [
	<gtExample>
	| host overlay world first second distanceJoint weldJoint distanceVisual fixedVisual firstContent secondContent |
	host := self physicsOverlayCanBeInstalled.
	overlay := host existingPhysicsOverlay.
	world := host physics world.
	first := host children first.
	second := host children second.
	distanceJoint := (first physics localAnchorAt: 10 @ 12)
		distanceJointTo: (world anchorAt: 260 @ 60).
	weldJoint := (first physics localAnchorAt: 20 @ 20)
		weldJointTo: (second physics localAnchorAt: 20 @ 20).
	overlay refresh.
	host space pulse.
	distanceVisual := overlay jointOverlay visuals
		detect: [ :each | each joint == distanceJoint ].
	fixedVisual := overlay jointOverlay visuals
		detect: [ :each | each joint == weldJoint ].
	distanceVisual hitTarget fireEvent: BlClickEvent new.
	firstContent := overlay objectInspector content.
	self assert: overlay selectedJoint == distanceJoint.
	self assert: (firstContent valueElements includesKey: #length).
	self assert: (firstContent valueElements includesKey: #motorSpeed) not.
	fixedVisual hitTarget fireEvent: BlClickEvent new.
	secondContent := overlay objectInspector content.
	self assert: overlay selectedJoint == weldJoint.
	self assert: secondContent ~= firstContent.
	self assert: secondContent joint == weldJoint.
	self assert: (secondContent valueElements includesKey: #referenceAngle).
	self assert: (secondContent valueElements includesKey: #length) not.
	self assert: (secondContent valueElements includesKey: #motorSpeed) not.
	self assert: firstContent joint == distanceJoint.
	^ overlay
]
