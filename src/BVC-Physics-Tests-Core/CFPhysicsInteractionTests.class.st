Class {
	#name : 'CFPhysicsInteractionTests',
	#superclass : 'CFPhysicsTestCase',
	#category : 'BVC-Physics-Tests-Core',
	#package : 'BVC-Physics-Tests-Core'
}

{ #category : 'tests - pull interaction' }
CFPhysicsInteractionTests >> testPullInteractionIsInstalledThroughThePhysicsFacade [
	<gtExample>
	| element handler |
	element := BlElement new size: 40 @ 40; yourself.
	handler := element physics pointerJointHandler.
	self assert: handler element equals: element.
	self assert: element physics isPullInteractionEnabled.
	element physics disablePullInteraction.
	self assert: element physics isPullInteractionEnabled not.
	element physics enablePullInteraction.
	self assert: element physics isPullInteractionEnabled.
	^ element
]
{ #category : 'tests - pull interaction' }
CFPhysicsInteractionTests >> testConfiguredPullDrivesAGlamorousButtonThroughPhysics [
	<gtExample>
	| scripter owner button world pullEvents |
	owner := BlElement new size: 200 @ 120; yourself.
	button := BrButton new
		aptitude: BrGlamorousButtonWithLabelAptitude new;
		label: 'Drag me';
		size: 90 @ 32;
		addEventHandler: BlPullHandler new;
		yourself.
	pullEvents := OrderedCollection new.
	button addEventHandler: (BlEventHandler
		on: BlPullEvent
		do: [ :anEvent | pullEvents add: anEvent ]).
	owner addChild: button.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world owner physics makeChildrenDynamic.
	button physics position: 20 @ 20.
	button relocate: 20 @ 20.
	scripter := BlScripter new element: owner.
	scripter mouseMoveOver
		onChildAt: 1;
		play.
	scripter mouseDown play.
	scripter mouseMove
		by: 30 @ 0;
		play.
	self assert: pullEvents size equals: 1.
	self assert: world mouseJoints size equals: 1.
	self assert: (world mouseJoints first maximumForce closeTo: button physics body mass * 1000000.0).
	self assert: (world mouseJoints first localAnchorB closeTo: 0 @ -4).
	self assert: button constraints position equals: 20 @ 20.
	world step.
	self assert: button physics position x > 20.
	scripter mouseUp play.
	self assert: world mouseJoints isEmpty.
	self assert: button physics body velocity x > 0.
	^ button
]
{ #category : 'tests - containment interaction' }
CFPhysicsInteractionTests >> testNewWorldConfiguresContainmentByDefault [
	<gtExample>
	| owner world |
	owner := BlElement new size: 100 @ 100; yourself.
	world := owner physics beWorld.
	self assert: world containment isEnabled.
	self assert: world containment margin equals: 0.0.
	self assert: world containment material friction equals: 0.3.
	self assert: world containment material restitution equals: 0.0.
	^ world
]
{ #category : 'tests - containment interaction' }
CFPhysicsInteractionTests >> testWorldContainmentCanBeConfigured [
	<gtExample>
	| owner world |
	owner := BlElement new size: 100 @ 100; yourself.
	world := owner physics beWorld.
	world containment
		disable;
		margin: 8;
		friction: 0.4;
		restitution: 0.5.
	self assert: world containment isEnabled not.
	self assert: world containment margin equals: 8.0.
	self assert: world containment material friction equals: 0.4.
	self assert: world containment material restitution equals: 0.5.
	world containment enable.
	self assert: world containment isEnabled.
	^ world
]
{ #category : 'tests - spring interaction' }
CFPhysicsInteractionTests >> testSpringEndpointsAreResolvedThroughAnchors [
	<gtExample>
	| first second spring |
	first := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self newBodyWithSequence: 2 position: 100 @ 0 extent: 20 @ 20.
	spring := CFPhysicsDistanceJoint between: first and: second.
	spring springEnabled: true; hertz: 3.0; dampingRatio: 1.0.
	self assert: spring anchorA class equals: CFPhysicsBodyCentreAnchor.
	self assert: spring anchorB class equals: CFPhysicsBodyCentreAnchor.
	self assert: spring anchorA worldPoint equals: 10 @ 10.
	self assert: spring anchorB worldPoint equals: 110 @ 10.
	self assert: spring bodyA == first.
	self assert: spring bodyB == second.
	^ spring
]
{ #category : 'tests - attraction interaction' }
CFPhysicsInteractionTests >> testConstantForceResponseCanBeLimitedByDistance [
	<gtExample>
	| response |
	response := CFPhysicsConstantForceResponse force: 250.
	self assert: (response forceMagnitudeAtDistance: 10) equals: 250.0.
	response maximumDistance: 100.
	self assert: (response forceMagnitudeAtDistance: 100) equals: 250.0.
	self assert: (response forceMagnitudeAtDistance: 101) equals: 0.0.
	response maximumDistance: nil.
	self assert: (response forceMagnitudeAtDistance: 1000) equals: 250.0.
	^ response
]
{ #category : 'tests - attraction interaction' }
CFPhysicsInteractionTests >> testAttractionEndpointsAreResolvedThroughAnchors [
	<gtExample>
	| first second attraction |
	first := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self newBodyWithSequence: 2 position: 100 @ 0 extent: 20 @ 20.
	attraction := CFPhysicsAttractionConstraint between: first and: second.
	self assert: attraction anchorA class equals: CFPhysicsBodyCentreAnchor.
	self assert: attraction anchorB class equals: CFPhysicsBodyCentreAnchor.
	self assert: attraction anchorA worldPoint equals: 10 @ 10.
	self assert: attraction anchorB worldPoint equals: 110 @ 10.
	self assert: attraction bodyA == first.
	self assert: attraction bodyB == second.
	^ attraction
]
{ #category : 'tests - attraction interaction' }
CFPhysicsInteractionTests >> testAttractionAppliesEqualAndOppositeImpulse [
	<gtExample>
	| first second attraction |
	first := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self newBodyWithSequence: 2 position: 100 @ 0 extent: 20 @ 20.
	attraction := CFPhysicsAttractionConstraint between: first and: second.
	attraction force: 1000.
	attraction prepareForStep: 0.1.
	self assert: first velocity x > 0.
	self assert: second velocity x < 0.
	self assert: first velocity y equals: 0.
	self assert: second velocity y equals: 0.
	self assert: first velocity equals: second velocity negated.
	^ attraction
]
{ #category : 'tests - attraction interaction' }
CFPhysicsInteractionTests >> testAttractionCanPullTowardAStaticBody [
	<gtExample>
	| dynamicBody staticBody attraction |
	dynamicBody := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	staticBody := self newBodyWithSequence: 2 position: 100 @ 0 extent: 20 @ 20.
	staticBody beStatic.
	attraction := CFPhysicsAttractionConstraint between: dynamicBody and: staticBody.
	attraction force: 1000.
	attraction prepareForStep: 0.1.
	self assert: dynamicBody velocity x > 0.
	self assert: staticBody velocity equals: 0 @ 0.
	^ attraction
]
{ #category : 'tests - attraction interaction' }
CFPhysicsInteractionTests >> testAttractionsAreInstalledAndDiscoveredThroughBlocElements [
	<gtExample>
	| owner first second third world firstAttraction secondAttraction |
	owner := BlElement new size: 400 @ 300; yourself.
	first := BlElement new size: 20 @ 20; yourself.
	second := BlElement new size: 20 @ 20; yourself.
	third := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { first. second. third }.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world owner physics makeChildrenDynamic.
	firstAttraction := first physics attract: second.
	secondAttraction := first physics attract: third.
	self assert: first physics attractions equals: { firstAttraction. secondAttraction }.
	self assert: second physics attractions equals: { firstAttraction }.
	self assert: world attractions equals: { firstAttraction. secondAttraction }.
	first physics removeAttraction: firstAttraction.
	self assert: first physics attractions equals: { secondAttraction }.
	self assert: firstAttraction isActive not.
	self assert: secondAttraction isActive.
	^ world
]
{ #category : 'tests - attraction interaction' }
CFPhysicsInteractionTests >> testDuplicateAttractionsRemainIndependent [
	<gtExample>
	| owner first second world firstAttraction secondAttraction |
	owner := BlElement new size: 400 @ 300; yourself.
	first := BlElement new size: 20 @ 20; yourself.
	second := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { first. second }.
	world := owner physics beWorld.
	world owner physics makeChildrenDynamic.
	firstAttraction := first physics attract: second.
	secondAttraction := first physics attract: second.
	self assert: (firstAttraction == secondAttraction) not.
	self assert: first physics attractions equals: { firstAttraction. secondAttraction }.
	first physics removeAttraction: firstAttraction.
	self assert: first physics attractions equals: { secondAttraction }.
	self assert: secondAttraction isActive.
	^ world
]
{ #category : 'tests - attraction interaction' }
CFPhysicsInteractionTests >> testRetiringABodyRemovesOnlyItsAttractions [
	<gtExample>
	| owner first second third fourth world attachedA attachedB unrelated |
	owner := BlElement new size: 400 @ 300; yourself.
	first := BlElement new size: 20 @ 20; yourself.
	second := BlElement new size: 20 @ 20; yourself.
	third := BlElement new size: 20 @ 20; yourself.
	fourth := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { first. second. third. fourth }.
	world := owner physics beWorld.
	world owner physics makeChildrenDynamic.
	attachedA := first physics attract: second.
	attachedB := first physics attract: third.
	unrelated := third physics attract: fourth.
	owner removeChild: first.
	world refreshMemberState.
	self assert: world attractions equals: { unrelated }.
	self assert: attachedA isActive not.
	self assert: attachedB isActive not.
	self assert: unrelated isActive.
	self assert: third physics attractions equals: { unrelated }.
	^ world
]
{ #category : 'tests - attraction interaction' }
CFPhysicsInteractionTests >> testWorldStepAppliesAttractionBeforeIntegration [
	<gtExample>
	| owner first second world attraction |
	owner := BlElement new size: 400 @ 300; yourself.
	first := BlElement new size: 20 @ 20; yourself.
	second := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { first. second }.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world owner physics makeChildrenDynamic.
	first physics position: 0 @ 0.
	second physics position: 100 @ 0.
	attraction := first physics attract: second.
	attraction force: 1000.
	world step.
	self assert: first physics velocity x > 0.
	self assert: second physics velocity x < 0.
	self assert: first physics position x > 0.
	self assert: second physics position x < 100.
	^ world
]
{ #category : 'tests - repulsion interaction' }
CFPhysicsInteractionTests >> testRepulsionEndpointsAreResolvedThroughAnchors [
	<gtExample>
	| first second repulsion |
	first := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self newBodyWithSequence: 2 position: 100 @ 0 extent: 20 @ 20.
	repulsion := CFPhysicsRepulsionConstraint between: first and: second.
	self assert: repulsion anchorA class equals: CFPhysicsBodyCentreAnchor.
	self assert: repulsion anchorB class equals: CFPhysicsBodyCentreAnchor.
	self assert: repulsion anchorA worldPoint equals: 10 @ 10.
	self assert: repulsion anchorB worldPoint equals: 110 @ 10.
	self assert: repulsion bodyA == first.
	self assert: repulsion bodyB == second.
	^ repulsion
]
{ #category : 'tests - repulsion interaction' }
CFPhysicsInteractionTests >> testRepulsionAppliesEqualAndOppositeImpulse [
	<gtExample>
	| first second repulsion |
	first := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self newBodyWithSequence: 2 position: 100 @ 0 extent: 20 @ 20.
	repulsion := CFPhysicsRepulsionConstraint between: first and: second.
	repulsion force: 1000.
	repulsion prepareForStep: 0.1.
	self assert: first velocity x < 0.
	self assert: second velocity x > 0.
	self assert: first velocity y equals: 0.
	self assert: second velocity y equals: 0.
	self assert: first velocity equals: second velocity negated.
	^ repulsion
]
{ #category : 'tests - repulsion interaction' }
CFPhysicsInteractionTests >> testRepulsionCanPushAwayFromAStaticBody [
	<gtExample>
	| dynamicBody staticBody repulsion |
	dynamicBody := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	staticBody := self newBodyWithSequence: 2 position: 100 @ 0 extent: 20 @ 20.
	staticBody beStatic.
	repulsion := CFPhysicsRepulsionConstraint between: dynamicBody and: staticBody.
	repulsion force: 1000.
	repulsion prepareForStep: 0.1.
	self assert: dynamicBody velocity x < 0.
	self assert: staticBody velocity equals: 0 @ 0.
	^ repulsion
]
{ #category : 'tests - repulsion interaction' }
CFPhysicsInteractionTests >> testRepulsionsAreInstalledAndDiscoveredThroughBlocElements [
	<gtExample>
	| owner first second third world firstRepulsion secondRepulsion |
	owner := BlElement new size: 400 @ 300; yourself.
	first := BlElement new size: 20 @ 20; yourself.
	second := BlElement new size: 20 @ 20; yourself.
	third := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { first. second. third }.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world owner physics makeChildrenDynamic.
	firstRepulsion := first physics repel: second.
	secondRepulsion := first physics repel: third.
	self assert: first physics repulsions equals: { firstRepulsion. secondRepulsion }.
	self assert: second physics repulsions equals: { firstRepulsion }.
	self assert: world repulsions equals: { firstRepulsion. secondRepulsion }.
	first physics removeRepulsion: firstRepulsion.
	self assert: first physics repulsions equals: { secondRepulsion }.
	self assert: firstRepulsion isActive not.
	self assert: secondRepulsion isActive.
	^ world
]
{ #category : 'tests - repulsion interaction' }
CFPhysicsInteractionTests >> testDuplicateRepulsionsRemainIndependent [
	<gtExample>
	| owner first second world firstRepulsion secondRepulsion |
	owner := BlElement new size: 400 @ 300; yourself.
	first := BlElement new size: 20 @ 20; yourself.
	second := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { first. second }.
	world := owner physics beWorld.
	world owner physics makeChildrenDynamic.
	firstRepulsion := first physics repel: second.
	secondRepulsion := first physics repel: second.
	self assert: (firstRepulsion == secondRepulsion) not.
	self assert: first physics repulsions equals: { firstRepulsion. secondRepulsion }.
	first physics removeRepulsion: firstRepulsion.
	self assert: first physics repulsions equals: { secondRepulsion }.
	self assert: secondRepulsion isActive.
	^ world
]
{ #category : 'tests - repulsion interaction' }
CFPhysicsInteractionTests >> testRetiringABodyRemovesOnlyItsRepulsions [
	<gtExample>
	| owner first second third fourth world attachedA attachedB unrelated |
	owner := BlElement new size: 400 @ 300; yourself.
	first := BlElement new size: 20 @ 20; yourself.
	second := BlElement new size: 20 @ 20; yourself.
	third := BlElement new size: 20 @ 20; yourself.
	fourth := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { first. second. third. fourth }.
	world := owner physics beWorld.
	world owner physics makeChildrenDynamic.
	attachedA := first physics repel: second.
	attachedB := first physics repel: third.
	unrelated := third physics repel: fourth.
	owner removeChild: first.
	world refreshMemberState.
	self assert: world repulsions equals: { unrelated }.
	self assert: attachedA isActive not.
	self assert: attachedB isActive not.
	self assert: unrelated isActive.
	self assert: third physics repulsions equals: { unrelated }.
	^ world
]
{ #category : 'tests - repulsion interaction' }
CFPhysicsInteractionTests >> testWorldStepAppliesRepulsionBeforeIntegration [
	<gtExample>
	| owner first second world repulsion |
	owner := BlElement new size: 400 @ 300; yourself.
	first := BlElement new size: 20 @ 20; yourself.
	second := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { first. second }.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world containment disable.
	world owner physics makeChildrenDynamic.
	first physics position: 0 @ 0.
	second physics position: 100 @ 0.
	repulsion := first physics repel: second.
	repulsion force: 1000.
	world step.
	self assert: first physics velocity x < 0.
	self assert: second physics velocity x > 0.
	self assert: first physics position x < 0.
	self assert: second physics position x > 100.
	^ world
]
{ #category : 'tests - attraction interaction' }
CFPhysicsInteractionTests >> testLinearFalloffResponseVariesSmoothlyWithDistance [
	<gtExample>
	| response |
	response := CFPhysicsLinearFalloffResponse force: 400 maximumDistance: 200.
	self assert: (response forceMagnitudeAtDistance: 0) equals: 400.0.
	self assert: (response forceMagnitudeAtDistance: 50) equals: 300.0.
	self assert: (response forceMagnitudeAtDistance: 100) equals: 200.0.
	self assert: (response forceMagnitudeAtDistance: 200) equals: 0.0.
	self assert: (response forceMagnitudeAtDistance: 250) equals: 0.0.
	^ response
]
{ #category : 'tests - attraction interaction' }
CFPhysicsInteractionTests >> testAttractionCanUseLinearFalloffResponse [
	<gtExample>
	| first second attraction response |
	first := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self newBodyWithSequence: 2 position: 90 @ 0 extent: 20 @ 20.
	response := CFPhysicsLinearFalloffResponse force: 1000 maximumDistance: 200.
	attraction := CFPhysicsAttractionConstraint between: first and: second.
	attraction distanceResponse: response.
	attraction prepareForStep: 0.1.
	self assert: attraction distanceResponse == response.
	self assert: first velocity x > 0.
	self assert: second velocity x < 0.
	self assert: first velocity equals: second velocity negated.
	^ attraction
]
{ #category : 'tests - repulsion interaction' }
CFPhysicsInteractionTests >> testRepulsionCanUseLinearFalloffResponse [
	<gtExample>
	| first second repulsion response |
	first := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self newBodyWithSequence: 2 position: 90 @ 0 extent: 20 @ 20.
	response := CFPhysicsLinearFalloffResponse force: 1000 maximumDistance: 200.
	repulsion := CFPhysicsRepulsionConstraint between: first and: second.
	repulsion distanceResponse: response.
	repulsion prepareForStep: 0.1.
	self assert: repulsion distanceResponse == response.
	self assert: first velocity x < 0.
	self assert: second velocity x > 0.
	self assert: first velocity equals: second velocity negated.
	^ repulsion
]
{ #category : 'tests - attraction interaction' }
CFPhysicsInteractionTests >> testSoftenedInverseSquareResponseFallsOffWithoutSingularity [
	<gtExample>
	| response |
	response := CFPhysicsSoftenedInverseSquareResponse
		force: 400
		softeningDistance: 20.
	self assert: (response forceMagnitudeAtDistance: 0) equals: 400.0.
	self assert: (response forceMagnitudeAtDistance: 20) equals: 200.0.
	self assert: (response forceMagnitudeAtDistance: 40) equals: 80.0.
	response maximumDistance: 50.
	self assert: (response forceMagnitudeAtDistance: 51) equals: 0.0.
	^ response
]
{ #category : 'tests - attraction interaction' }
CFPhysicsInteractionTests >> testAttractionCanUseSoftenedInverseSquareResponse [
	<gtExample>
	| first second attraction response |
	first := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self newBodyWithSequence: 2 position: 90 @ 0 extent: 20 @ 20.
	response := CFPhysicsSoftenedInverseSquareResponse
		force: 1000
		softeningDistance: 100.
	attraction := CFPhysicsAttractionConstraint between: first and: second.
	attraction distanceResponse: response.
	attraction prepareForStep: 0.1.
	self assert: attraction distanceResponse == response.
	self assert: first velocity x > 0.
	self assert: second velocity x < 0.
	self assert: first velocity equals: second velocity negated.
	^ attraction
]
{ #category : 'tests - repulsion interaction' }
CFPhysicsInteractionTests >> testRepulsionCanUseSoftenedInverseSquareResponse [
	<gtExample>
	| first second repulsion response |
	first := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self newBodyWithSequence: 2 position: 90 @ 0 extent: 20 @ 20.
	response := CFPhysicsSoftenedInverseSquareResponse
		force: 1000
		softeningDistance: 100.
	repulsion := CFPhysicsRepulsionConstraint between: first and: second.
	repulsion distanceResponse: response.
	repulsion prepareForStep: 0.1.
	self assert: repulsion distanceResponse == response.
	self assert: first velocity x < 0.
	self assert: second velocity x > 0.
	self assert: first velocity equals: second velocity negated.
	^ repulsion
]
{ #category : 'tests - relationship endpoints' }
CFPhysicsInteractionTests >> testAnchoredEndpointPairResolvesBothEndpointsTogether [
	<gtExample>
	| first second anchorA anchorB endpoints points |
	first := self newBodyWithSequence: 1 position: 10 @ 20 extent: 40 @ 20.
	second := self newBodyWithSequence: 2 position: 100 @ 50 extent: 60 @ 30.
	anchorA := CFPhysicsLocalAnchor on: first at: 20 @ 0.
	anchorB := CFPhysicsNormalisedAnchor on: second at: 0 @ 0.5.
	endpoints := CFPhysicsAnchoredEndpointPair anchorA: anchorA anchorB: anchorB.
	self assert: endpoints anchorA == anchorA.
	self assert: endpoints anchorB == anchorB.
	self assert: endpoints bodyA == first.
	self assert: endpoints bodyB == second.
	points := endpoints worldPoints.
	self assert: points first equals: 30 @ 20.
	self assert: points second equals: 100 @ 65.
	self assert: endpoints worldPointA equals: points first.
	self assert: endpoints worldPointB equals: points second.
	^ endpoints
]
{ #category : 'tests - relationship endpoints' }
CFPhysicsInteractionTests >> testRelationshipsResolveThroughAnEndpointPair [
	<gtExample>
	| first second endpoints spring attraction repulsion |
	first := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self newBodyWithSequence: 2 position: 100 @ 0 extent: 20 @ 20.
	endpoints := CFPhysicsAnchoredEndpointPair
		anchorA: (CFPhysicsLocalAnchor on: first at: 10 @ 0)
		anchorB: (CFPhysicsLocalAnchor on: second at: -10 @ 0).
	spring := CFPhysicsDistanceJoint betweenEndpoints: endpoints.
	spring springEnabled: true; hertz: 3.0; dampingRatio: 1.0.
	attraction := CFPhysicsAttractionConstraint betweenEndpoints: endpoints.
	repulsion := CFPhysicsRepulsionConstraint betweenEndpoints: endpoints.
	self assert: spring endpointPair == endpoints.
	self assert: attraction endpointPair == endpoints.
	self assert: repulsion endpointPair == endpoints.
	self assert: spring length equals: 80.0.
	self assert: spring bodyA == first.
	self assert: spring bodyB == second.
	self assert: attraction bodyA == first.
	self assert: repulsion bodyB == second.
	^ { spring. attraction. repulsion }
]
{ #category : 'tests - relationship endpoints' }
CFPhysicsInteractionTests >> testNearestGeometryEndpointsResolveCircleBoundaries [
	<gtExample>
	| first second endpoints points |
	first := (CFPhysicsBody
		element: (BlElement new geometry: BlCircleGeometry new; size: 20 @ 20; yourself)
		world: nil)
		sequence: 1;
		position: 0 @ 0;
		yourself.
	second := (CFPhysicsBody
		element: (BlElement new geometry: BlCircleGeometry new; size: 40 @ 40; yourself)
		world: nil)
		sequence: 2;
		position: 100 @ -10;
		yourself.
	endpoints := CFPhysicsNearestGeometryEndpointPair between: first and: second.
	points := endpoints worldPoints.
	self assert: points first equals: 20 @ 10.
	self assert: points second equals: 100 @ 10.
	^ endpoints
]
{ #category : 'tests - relationship endpoints' }
CFPhysicsInteractionTests >> testNearestGeometryEndpointsResolveRectangleEdges [
	<gtExample>
	| first second endpoints points |
	first := self newBodyWithSequence: 1 position: 0 @ 0 extent: 40 @ 40.
	second := self newBodyWithSequence: 2 position: 100 @ 10 extent: 30 @ 20.
	endpoints := CFPhysicsNearestGeometryEndpointPair between: first and: second.
	points := endpoints worldPoints.
	self assert: points first equals: 40 @ 20.
	self assert: points second equals: 100 @ 20.
	^ endpoints
]
{ #category : 'tests - relationship endpoints' }
CFPhysicsInteractionTests >> testNearestGeometryEndpointPairTracksCurrentGeometry [
	<gtExample>
	| first second endpoints initial moved |
	first := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self newBodyWithSequence: 2 position: 100 @ 0 extent: 20 @ 20.
	endpoints := CFPhysicsNearestGeometryEndpointPair between: first and: second.
	initial := endpoints worldPoints.
	second position: 60 @ 40.
	moved := endpoints worldPoints.
	self assert: initial equals: { 20 @ 10. 100 @ 10 }.
	self assert: moved ~= initial.
	self assert: ((moved second - moved first) r) < ((initial second - initial first) r).
	^ endpoints
]
{ #category : 'tests - relationship endpoints' }
CFPhysicsInteractionTests >> testNearestGeometryEndpointsCreateWorldOwnedRelationships [
	<gtExample>
	| world first second endpoints spring attraction repulsion |
	world := CFPhysicsWorld new.
	first := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self newBodyWithSequence: 2 position: 100 @ 0 extent: 20 @ 20.
	first world: world.
	second world: world.
	endpoints := CFPhysicsNearestGeometryEndpointPair between: first and: second.
	spring := (CFPhysicsDistanceJoint betweenEndpoints: endpoints)
		springEnabled: true;
		yourself.
	world addDistanceJoint: spring.
	attraction := endpoints attraction.
	repulsion := endpoints repulsion.
	self assert: spring endpointPair == endpoints.
	self assert: attraction endpointPair == endpoints.
	self assert: repulsion endpointPair == endpoints.
	self assert: world springs equals: { spring }.
	self assert: world attractions equals: { attraction }.
	self assert: world repulsions equals: { repulsion }.
	^ { spring. attraction. repulsion }
]
