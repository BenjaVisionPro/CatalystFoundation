Class {
	#name : 'CFPhysicsMondrianTests',
	#superclass : 'TestCase',
	#category : 'BVC-Physics-Tests-Mondrian',
	#package : 'BVC-Physics-Tests-Mondrian'
}

{ #category : 'examples' }
CFPhysicsMondrianTests >> testMondrianPhysicsBeWorldAdoptsExistingNodes [
	<gtExample>
	| mondrian nodes world |
	mondrian := GtMondrian new.
	nodes := mondrian nodes with: #(one two three).
	nodes withIndexDo: [ :each :index | each relocate: (index * 30) @ (index * 20) ].
	world := mondrian physics beWorld.
	self assert: world owner == mondrian root.
	self assert: world members size equals: 3.
	nodes do: [ :each |
		self assert: each physics position equals: each position ].
	^ mondrian
]

{ #category : 'examples' }
CFPhysicsMondrianTests >> testMondrianPhysicsExcludesNodePresentationChildren [
	<gtExample>
	| mondrian nodes world |
	mondrian := GtMondrian new.
	mondrian nodes
		stencil: [ :each |
			BlElement new
				size: 40 @ 30;
				addChild: BlElement new;
				yourself ];
		with: #(one two).
	nodes := mondrian nodeElements.
	world := mondrian physics beWorld.
	self assert: world members size equals: 2.
	nodes do: [ :each |
		self assert: (world includes: each).
		self assert: (world includes: each children first) not ].
	^ mondrian
]

{ #category : 'examples' }
CFPhysicsMondrianTests >> testMondrianPhysicsExampleGraphBuilderIsPhysicsAgnostic [
	<gtExample>
	| mondrian world |
	mondrian := CFPhysicsMondrianExampleGraphBuilder new build.
	world := mondrian physics beWorld.
	self assert: world members size equals: mondrian nodeElements size.
	^ mondrian
]

{ #category : 'examples' }
CFPhysicsMondrianTests >> testMondrianPhysicsBeWorldTracksAddedAndRemovedNodes [
	<gtExample>
	| mondrian initial added world |
	mondrian := GtMondrian new.
	initial := mondrian nodes with: #(one two).
	world := mondrian physics beWorld.
	added := (mondrian nodes with: #(three)) first.
	self assert: (world includes: added).
	mondrian root removeChild: initial first.
	self assert: (world includes: initial first) not.
	^ mondrian
]

{ #category : 'examples' }
CFPhysicsMondrianTests >> testMondrianPhysicsBeWorldExcludesEdges [
	<gtExample>
	| mondrian edgeElements world |
	mondrian := GtMondrian new.
	mondrian nodes with: #(one two three).
	edgeElements := mondrian edges
		connectAssociations: { #one -> #two }.
	world := mondrian physics beWorld.
	self assert: (world includes: edgeElements first) not.
	mondrian edges connectAssociations: { #two -> #three }.
	self assert: world members size equals: 3.
	^ mondrian
]

{ #category : 'examples' }
CFPhysicsMondrianTests >> testMondrianPhysicsBeWorldIsIdempotent [
	<gtExample>
	| mondrian firstWorld secondWorld |
	mondrian := GtMondrian new.
	mondrian nodes with: #(one two).
	firstWorld := mondrian physics beWorld.
	secondWorld := mondrian physics beWorld.
	self assert: firstWorld == secondWorld.
	^ mondrian
]

{ #category : 'examples' }
CFPhysicsMondrianTests >> testMondrianPhysicsCeaseBeingWorldRestoresTheOriginalGraph [
	<gtExample>
	| mondrian nodes edge originalLayout originalAutoScale originalScale originalTranslation physics world |
	mondrian := GtMondrian new.
	nodes := mondrian nodes with: #(one two).
	edge := (mondrian edges
		fromNearestCircle;
		toNearestCircle;
		connectAssociations: { #one -> #two }) first.
	originalLayout := mondrian root layout.
	originalAutoScale := mondrian root autoScaleEnabled.
	originalScale := mondrian root childrenScaleFactor.
	originalTranslation := mondrian root childrenTranslationFactor.
	physics := mondrian physics.
	world := physics beWorld.
	physics ceaseBeingWorld.
	self assert: physics world isNil.
	self assert: mondrian root layout == originalLayout.
	self assert: mondrian root autoScaleEnabled equals: originalAutoScale.
	self assert: mondrian root childrenScaleFactor equals: originalScale.
	self assert: mondrian root childrenTranslationFactor equals: originalTranslation.
	self assert: edge fromAnchor class equals: BlNearestPositionLooseCircleAnchor.
	self assert: edge toAnchor class equals: BlNearestPositionLooseCircleAnchor.
	self assert: mondrian edges class equals: GtMondrianEdgeBuilder.
	self assert: mondrian root existingPhysics isNil.
	nodes do: [ :each | self assert: each existingPhysics isNil ].
	self assert: edge existingPhysics isNil.
	self assert: world members isEmpty.
	^ mondrian
]

{ #category : 'examples' }
CFPhysicsMondrianTests >> testMondrianPhysicsCeaseBeingWorldIsIdempotent [
	<gtExample>
	| mondrian physics |
	mondrian := GtMondrian new.
	mondrian nodes with: #(one two).
	physics := mondrian physics.
	physics beWorld.
	physics ceaseBeingWorld.
	physics ceaseBeingWorld.
	self assert: physics world isNil.
	self assert: mondrian root existingPhysics isNil.
	^ mondrian
]

{ #category : 'examples' }
CFPhysicsMondrianTests >> testMondrianPhysicsCeaseBeingWorldPreservesPreexistingPhysics [
	<gtExample>
	| mondrian node preexistingPhysics preexistingHandler physics |
	mondrian := GtMondrian new.
	node := (mondrian nodes with: #(one)) first.
	preexistingPhysics := node physics.
	preexistingHandler := preexistingPhysics pointerJointHandler.
	physics := mondrian physics.
	physics beWorld.
	physics ceaseBeingWorld.
	self assert: node existingPhysics == preexistingPhysics.
	self assert: node existingPhysics world isNil.
	self assert: preexistingHandler element == node.
	self assert: preexistingHandler isEnabled.
	^ mondrian
]

{ #category : 'examples' }
CFPhysicsMondrianTests >> testMondrianPhysicsRepeatedWorldSessionsReleaseSessionPullInteraction [
	<gtExample>
	| mondrian node firstPhysics firstHandler secondPhysics secondHandler |
	mondrian := GtMondrian new.
	node := (mondrian nodes with: #(one)) first.
	mondrian physics beWorld.
	firstPhysics := node existingPhysics.
	firstHandler := firstPhysics pointerJointHandler.
	mondrian physics ceaseBeingWorld.
	self assert: node existingPhysics isNil.
	self assert: firstHandler element isNil.
	self deny: firstHandler isEnabled.
	mondrian physics beWorld.
	secondPhysics := node existingPhysics.
	secondHandler := secondPhysics pointerJointHandler.
	self deny: secondPhysics == firstPhysics.
	self deny: secondHandler == firstHandler.
	self assert: secondHandler element == node.
	self assert: secondHandler isEnabled.
	mondrian physics ceaseBeingWorld.
	self assert: node existingPhysics isNil.
	^ mondrian
]

{ #category : 'examples' }
CFPhysicsMondrianTests >> testMondrianPhysicsCeaseBeingWorldReleasesRetiredSessionNodes [
	<gtExample>
	| mondrian added physics |
	mondrian := GtMondrian new.
	mondrian nodes with: #(one).
	physics := mondrian physics.
	physics beWorld.
	added := (mondrian nodes with: #(two)) first.
	self assert: added existingPhysics notNil.
	mondrian root removeChild: added.
	physics ceaseBeingWorld.
	self assert: added existingPhysics isNil.
	^ mondrian
]

{ #category : 'examples' }
CFPhysicsMondrianTests >> testMondrianPhysicsBeginsSteppingWhenAddedToASceneGraph [
	<gtExample>
	| mondrian space world |
	space := BlSpace new.
	space time: BlTime simulated.
	mondrian := GtMondrian new.
	mondrian nodes with: #(one two).
	world := mondrian physics beWorld.
	[
		space root addChild: mondrian root.
		space pulse.
		self assert: world isStepping ] ensure: [
		world stopStepping ].
	self assert: world isStepping not.
	^ mondrian
]

{ #category : 'examples' }
CFPhysicsMondrianTests >> testMondrianPhysicsBeWorldUsesFixedCanvasCoordinates [
	<gtExample>
	| mondrian |
	mondrian := GtMondrian new.
	mondrian nodes with: #(one two).
	self assert: mondrian root autoScaleEnabled.
	mondrian physics beWorld.
	self assert: mondrian root autoScaleEnabled not.
	^ mondrian
]

{ #category : 'examples' }
CFPhysicsMondrianTests >> testMondrianPhysicsEdgesUsePresentationAwareAnchors [
	<gtExample>
	| mondrian edge |
	mondrian := GtMondrian new.
	mondrian nodes with: #(one two).
	edge := (mondrian edges
		fromNearestCircle;
		toNearestCircle;
		connectAssociations: { #one -> #two }) first.
	self assert: edge fromAnchor class equals: BlNearestPositionLooseCircleAnchor.
	self assert: edge toAnchor class equals: BlNearestPositionLooseCircleAnchor.
	mondrian physics beWorld.
	self assert: edge fromAnchor class equals: CFPhysicsMondrianPresentationAnchor.
	self assert: edge toAnchor class equals: CFPhysicsMondrianPresentationAnchor.
	self assert: edge fromAnchor anchor class equals: BlNearestPositionLooseCircleAnchor.
	self assert: edge toAnchor anchor class equals: BlNearestPositionLooseCircleAnchor.
	self assert: (CFPhysicsMondrianPresentationAnchor on: edge fromAnchor) == edge fromAnchor.
	^ mondrian
]

{ #category : 'examples' }
CFPhysicsMondrianTests >> testMondrianPhysicsPreservesStandardAndCustomAnchors [
	<gtExample>
	| mondrian standardEdge customEdge |
	mondrian := GtMondrian new.
	mondrian nodes with: #(one two three).
	standardEdge := (mondrian edges
		fromCenterTop;
		toRightCenter;
		connectAssociations: { #one -> #two }) first.
	customEdge := (mondrian edges
		connectAssociations: { #two -> #three }) first.
	customEdge
		fromAnchor: (CFPhysicsMondrianTestAnchor element: customEdge graph model fromElement);
		toAnchor: (CFPhysicsMondrianTestAnchor element: customEdge graph model toElement).
	mondrian physics beWorld.
	self assert: standardEdge fromAnchor class equals: CFPhysicsMondrianPresentationAnchor.
	self assert: standardEdge fromAnchor anchor class equals: BlElementTopCenterAnchor.
	self assert: standardEdge toAnchor anchor class equals: BlElementCenterRightAnchor.
	self assert: customEdge fromAnchor anchor class equals: CFPhysicsMondrianTestAnchor.
	self assert: customEdge toAnchor anchor class equals: CFPhysicsMondrianTestAnchor.
	^ mondrian
]

{ #category : 'examples' }
CFPhysicsMondrianTests >> testMondrianUsesStandardEdgesUntilPhysicsIsEnabled [
	<gtExample>
	| mondrian |
	mondrian := GtMondrian new.
	self assert: mondrian edges class equals: GtMondrianEdgeBuilder.
	mondrian physics.
	self assert: mondrian edges class equals: GtMondrianEdgeBuilder.
	mondrian physics beWorld.
	self assert: mondrian edges class equals: CFPhysicsMondrianEdgeBuilder.
	^ mondrian
]

{ #category : 'examples' }
CFPhysicsMondrianTests >> testMondrianPhysicsUsesDefaultGravityWithoutABehaviour [
	<gtExample>
	| mondrian nodes initialPositions world |
	mondrian := GtMondrian new.
	mondrian root
		size: 920 @ 620;
		background: Color veryVeryLightGray.
	mondrian nodes with: (1 to: 12).
	nodes := mondrian nodeElements.
	nodes do: [ :each | each size: 62 @ 34 ].
	world := mondrian physics beWorld.
	nodes withIndexDo: [ :each :index |
		each physics position: 80 + ((index - 1) * 65) @ 100 ].
	initialPositions := nodes collect: [ :each | each physics position ].
	self assert: world gravity equals: 0 @ 10.0.
	world step: 3.
	nodes with: initialPositions do: [ :each :initialPosition |
		self assert: each physics position y > initialPosition y ].
	^ mondrian
]

{ #category : 'examples' }
CFPhysicsMondrianTests >> testMondrianPhysicsForceDirectedUsesLiveMondrianConnections [
	<gtExample>
	| mondrian world behaviour |
	mondrian := GtMondrian new.
	mondrian nodes with: #(one two three).
	mondrian edges connectAssociations: { #one -> #two }.
	world := mondrian physics beWorld.
	world gravity: 0 @ 0.
	behaviour := mondrian physics forceDirected.
	world step.
	self assert: behaviour springsByEdge size equals: 1.
	self assert: behaviour repulsionForce bodies size equals: 3.
	self assert: behaviour orientationForcesByElement size equals: 3.
	mondrian edges connectAssociations: { #two -> #three }.
	world step.
	self assert: behaviour springsByEdge size equals: 2.
	^ mondrian
]

{ #category : 'examples' }
CFPhysicsMondrianTests >> testMondrianPhysicsForceDirectedUsesMondrianForceLayoutAsStartingPositions [
	<gtExample>
	| mondrian nodes initialPositions world |
	mondrian := GtMondrian new.
	mondrian root size: 920 @ 620.
	mondrian nodes with: #(one two three four five six).
	mondrian edges connectAssociations: {
		#one -> #two.
		#one -> #three.
		#two -> #four.
		#three -> #five.
		#three -> #six }.
	nodes := mondrian nodeElements.
	nodes do: [ :each | each size: 62 @ 34 ].
	nodes withIndexDo: [ :each :index | each relocate: (index * 70) @ 100 ].
	initialPositions := nodes collect: #position.
	world := mondrian physics beWorld.
	world gravity: 0 @ 0.
	mondrian physics forceDirected.
	self assert: (nodes collect: #position) ~= initialPositions.
	nodes do: [ :each |
		self assert: each physics position equals: each position ].
	^ mondrian
]

{ #category : 'examples' }
CFPhysicsMondrianTests >> testMondrianPhysicsForceDirectedTracksAddedNodes [
	<gtExample>
	| mondrian added addedEdge world behaviour |
	mondrian := GtMondrian new.
	mondrian nodes with: #(one two).
	mondrian edges connectAssociations: { #one -> #two }.
	world := mondrian physics beWorld.
	world gravity: 0 @ 0.
	behaviour := mondrian physics forceDirected.
	world step.
	self assert: world members size equals: 2.
	self assert: behaviour springsByEdge size equals: 1.
	self assert: behaviour repulsionForce bodies size equals: 2.
	self assert: behaviour orientationForcesByElement size equals: 2.
	added := (mondrian nodes with: #(three)) first.
	addedEdge := (mondrian edges connectAssociations: { #two -> #three }) first.
	world step.
	self assert: (world includes: added).
	self assert: world members size equals: 3.
	self assert: behaviour springsByEdge size equals: 2.
	self assert: behaviour repulsionForce bodies size equals: 3.
	self assert: behaviour orientationForcesByElement size equals: 3.
	mondrian root removeChild: addedEdge.
	world step.
	self assert: behaviour springsByEdge size equals: 1.
	self assert: behaviour repulsionForce bodies size equals: 3.
	mondrian root removeChild: added.
	world step.
	self assert: world members size equals: 2.
	self assert: behaviour springsByEdge size equals: 1.
	self assert: behaviour repulsionForce bodies size equals: 2.
	self assert: behaviour orientationForcesByElement size equals: 2.
	^ mondrian
]


{ #category : 'examples - physics overlay' }
CFPhysicsMondrianTests >> testMondrianPhysicsDisplayedAndWorldOverlayCoordinatesAgree [
	<gtExample>
	| space mondrian node world overlay body physicsPosition context displayedPoint worldPoint |
	space := BlSpace new.
	space time: BlTime simulated.
	mondrian := GtMondrian new.
	node := (mondrian nodes with: #(one)) first.
	space root addChild: mondrian root.
	space pulse.
	world := mondrian physics beWorld.
	world stopStepping.
	space pulse.
	self assert: world isStepping not.
	overlay := mondrian root showPhysicsOverlay.
	body := world bodyStateFor: node.
	physicsPosition := 180 @ 120.
	body position: physicsPosition.
	world presentAtAlpha: 1.0.
	space pulse.
	context := CFPhysicsOverlayContext
		host: mondrian root
		world: world
		overlay: overlay.
	displayedPoint := context overlayPoint: 0 @ 0 from: node.
	worldPoint := context overlayPointFromWorld: physicsPosition.
	self assert: displayedPoint equals: worldPoint.
	mondrian root hidePhysicsOverlay.
	world stopStepping.
	^ mondrian
]


{ #category : 'examples - physics overlay' }
CFPhysicsMondrianTests >> testMondrianPhysicsWorldOverlayCoordinatesFollowGraphScaleAndTranslation [
	<gtExample>
	| space mondrian node world overlay body physicsPosition context displayedPoint worldPoint directHostPoint |
	space := BlSpace new.
	space time: BlTime simulated.
	mondrian := GtMondrian new.
	node := (mondrian nodes with: #(one)) first.
	space root addChild: mondrian root.
	space pulse.
	world := mondrian physics beWorld.
	world stopStepping.
	mondrian root
		childrenScaleFactor: 1.5;
		childrenTranslationFactor: 70 @ 45.
	space pulse.
	overlay := mondrian root showPhysicsOverlay.
	body := world bodyStateFor: node.
	physicsPosition := 180 @ 120.
	body position: physicsPosition.
	world presentAtAlpha: 1.0.
	space pulse.
	context := CFPhysicsOverlayContext
		host: mondrian root
		world: world
		overlay: overlay.
	displayedPoint := context overlayPoint: 0 @ 0 from: node.
	worldPoint := context overlayPointFromWorld: physicsPosition.
	directHostPoint := overlay root globalPointToLocal: (mondrian root localPointToGlobal: physicsPosition).
	self assert: displayedPoint equals: worldPoint.
	self
		assert: worldPoint
		equals: (overlay root globalPointToLocal: (mondrian root localPointToGlobal: (mondrian root childrenPointToLocal: physicsPosition))).
	self assert: (worldPoint = directHostPoint) not.
	mondrian root hidePhysicsOverlay.
	world stopStepping.
	^ mondrian
]

{ #category : 'tests - containment' }
CFPhysicsMondrianTests >> testMondrianContainmentExpandsWithVisibleCanvasAndDoesNotShrink [
	<gtExample>
	| space mondrian world initialExtent expandedExtent retainedExtent |
	space := BlSpace new.
	space time: BlTime simulated.
	mondrian := GtMondrian new.
	mondrian nodes with: #(one two three).
	space root addChild: mondrian root.
	space pulse.
	world := mondrian physics beWorld.
	world stopStepping.
	world step.
	initialExtent := self containmentExtentOf: world.
	mondrian root childrenScaleFactor: 0.5.
	space pulse.
	world step.
	expandedExtent := self containmentExtentOf: world.
	self assert: expandedExtent x > initialExtent x.
	self assert: expandedExtent y > initialExtent y.
	mondrian root childrenScaleFactor: 1.0.
	space pulse.
	world step.
	retainedExtent := self containmentExtentOf: world.
	self assert: retainedExtent equals: expandedExtent.
	^ mondrian
]

{ #category : 'private - containment' }
CFPhysicsMondrianTests >> containmentExtentOf: aWorld [
	| origin vertices minimum maximum |
	origin := aWorld containmentBoundaryBody worldBodyOrigin.
	vertices := aWorld containmentBoundaryChain vertices collect: [ :each | each + origin ].
	minimum := (vertices collect: #x) min @ (vertices collect: #y) min.
	maximum := (vertices collect: #x) max @ (vertices collect: #y) max.
	^ maximum - minimum
]


{ #category : 'examples' }
CFPhysicsMondrianTests >> testMondrianForceDirectedUsesBodyDampingAndRestoresItOnStop [
	<gtExample>
	| mondrian world behaviour nodes |
	mondrian := GtMondrian new.
	mondrian nodes with: #(one two).
	mondrian edges connectAssociations: { #one -> #two }.
	world := mondrian physics beWorld.
	world gravity: 0 @ 0.
	nodes := mondrian nodeElements.
	nodes first physics beDynamic; linearDamping: 0.75.
	nodes second physics beDynamic; linearDamping: 1.25.
	behaviour := mondrian physics forceDirected.
	world step.
	self assert: nodes first physics linearDamping equals: behaviour linearDamping.
	self assert: nodes second physics linearDamping equals: behaviour linearDamping.
	self assert: behaviour repulsionForce wakesBodies not.
	self assert: behaviour positioningForce wakesBodies not.
	behaviour stop.
	self assert: nodes first physics linearDamping equals: 0.75.
	self assert: nodes second physics linearDamping equals: 1.25.
	^ mondrian
]


{ #category : 'examples' }
CFPhysicsMondrianTests >> testMondrianForceDirectedGentlyCentresDisconnectedComponents [
	<gtExample>
	| mondrian world behaviour componentSizes |
	mondrian := GtMondrian new.
	mondrian nodes with: #(one two three four five).
	mondrian edges connectAssociations: {
		#one -> #two.
		#two -> #three.
		#four -> #five }.
	world := mondrian physics beWorld.
	world gravity: 0 @ 0.
	behaviour := mondrian physics forceDirected.
	world step.
	self assert: behaviour componentForces size equals: 2.
	componentSizes := (behaviour componentForces collect: [ :force | force bodies size ]) sorted.
	self assert: componentSizes equals: #(2 3).
	behaviour componentForces do: [ :force |
		self assert: force centre equals: world owner extent / 2.0.
		self assert: force stiffness equals: behaviour componentCentringStiffness.
		self assert: force wakesBodies not ].
	behaviour stop.
	^ mondrian
]

{ #category : 'examples' }
CFPhysicsMondrianTests >> testMondrianForceDirectedParameterChangesWakeSleepingBodies [
	<gtExample>
	| mondrian world behaviour nodes bodies |
	mondrian := GtMondrian new.
	mondrian nodes with: #(one two three).
	mondrian edges connectAssociations: { #one -> #two. #two -> #three }.
	world := mondrian physics beWorld.
	world gravity: 0 @ 0.
	world containment disable.
	behaviour := mondrian physics forceDirected.
	world step.
	nodes := mondrian nodeElements.
	bodies := nodes collect: [ :element | element physics body ].
	bodies do: #sleepLocally.
	behaviour repulsionAtOneMetre: behaviour repulsionAtOneMetre + 1.0.
	behaviour step: nil.
	self assert: (bodies allSatisfy: #isAwake).
	bodies do: #sleepLocally.
	behaviour orientationStiffness: behaviour orientationStiffness + 1.0.
	behaviour step: nil.
	self assert: (bodies allSatisfy: #isAwake).
	^ mondrian
]

{ #category : 'examples' }
CFPhysicsMondrianTests >> testMondrianForceDirectedReusesRepulsionDistanceResponse [
	<gtExample>
	| mondrian world behaviour response |
	mondrian := GtMondrian new.
	mondrian nodes with: #(one two three).
	mondrian edges connectAssociations: { #one -> #two }.
	world := mondrian physics beWorld.
	world gravity: 0 @ 0.
	behaviour := mondrian physics forceDirected.
	world step.
	response := behaviour repulsionForce distanceResponse.
	behaviour repulsionAtOneMetre: behaviour repulsionAtOneMetre + 1.0.
	behaviour step: nil.
	self assert: behaviour repulsionForce distanceResponse == response.
	self assert: behaviour repulsionForce force equals: behaviour repulsionAtOneMetre.
	self assert: behaviour repulsionForce maximumDistance equals: behaviour maximumRepulsionDistance.
	^ mondrian
]

