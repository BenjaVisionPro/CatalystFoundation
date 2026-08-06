Class {
	#name : 'CFPhysicsCollisionTests',
	#superclass : 'CFPhysicsTestCase',
	#category : 'BVC-Physics-Tests-Core',
	#package : 'BVC-Physics-Tests-Core'
}

{ #category : 'tests - polygon manifolds' }
CFPhysicsCollisionTests >> testFaceContactProducesTwoPoints [
	<gtExample>
	| ground box manifold |
	ground := CFPhysicsPolygonShape rectangleExtent: 100 @ 20.
	box := CFPhysicsPolygonShape rectangleExtent: 60 @ 20.
	manifold := CFPhysicsPolygonManifoldBuilder
		manifoldBetweenShape: ground bodyOrigin: ground rotationCentre rotation: 0
		andShape: box bodyOrigin: (20 @ 15) + box rotationCentre rotation: 0.
	self assert: manifold notNil.
	self assert: manifold contactPoints size equals: 2.
	self assert: manifold normal equals: 0 @ 1.
	manifold contactPoints do: [ :point |
		self assert: (point separation closeTo: -5.0).
		self assert: point featureId notNil.
		self assert: point localAnchorA notNil.
		self assert: point localAnchorB notNil ].
	^ manifold
]
{ #category : 'tests - polygon manifolds' }
CFPhysicsCollisionTests >> testFaceContactIdentityPersistsAcrossTangentialMotion [
	<gtExample>
	| ground box first second firstIds secondIds |
	ground := CFPhysicsPolygonShape rectangleExtent: 100 @ 20.
	box := CFPhysicsPolygonShape rectangleExtent: 60 @ 20.
	first := CFPhysicsPolygonManifoldBuilder
		manifoldBetweenShape: ground bodyOrigin: ground rotationCentre rotation: 0
		andShape: box bodyOrigin: (20 @ 15) + box rotationCentre rotation: 0.
	second := CFPhysicsPolygonManifoldBuilder
		manifoldBetweenShape: ground bodyOrigin: ground rotationCentre rotation: 0
		andShape: box bodyOrigin: (21 @ 15) + box rotationCentre rotation: 0.
	firstIds := first contactPoints collect: [ :point | point featureId ].
	secondIds := second contactPoints collect: [ :point | point featureId ].
	self assert: firstIds asSet equals: secondIds asSet.
	^ second
]
{ #category : 'tests - polygon manifolds' }
CFPhysicsCollisionTests >> testRoundedPolygonUsesCoreAndRadius [
	<gtExample>
	| ground box manifold |
	ground := CFPhysicsPolygonShape rectangleExtent: 100 @ 20 radius: 5.
	box := CFPhysicsPolygonShape rectangleExtent: 60 @ 20 radius: 5.
	manifold := CFPhysicsPolygonManifoldBuilder
		manifoldBetweenShape: ground bodyOrigin: ground rotationCentre rotation: 0
		andShape: box bodyOrigin: (20 @ 15) + box rotationCentre rotation: 0.
	self assert: manifold notNil.
	self assert: manifold contactPoints size equals: 2.
	manifold contactPoints do: [ :point |
		self assert: (point separation closeTo: -5.0) ].
	^ manifold
]
{ #category : 'tests - polygon manifolds' }
CFPhysicsCollisionTests >> testSeparatedPolygonCoresRespectCombinedRadius [
	<gtExample>
	| first second touching separated |
	first := CFPhysicsPolygonShape rectangleExtent: 100 @ 20 radius: 5.
	second := CFPhysicsPolygonShape rectangleExtent: 60 @ 20 radius: 5.
	touching := CFPhysicsPolygonManifoldBuilder
		manifoldBetweenShape: first bodyOrigin: first rotationCentre rotation: 0
		andShape: second bodyOrigin: (20 @ 20) + second rotationCentre rotation: 0.
	separated := CFPhysicsPolygonManifoldBuilder
		manifoldBetweenShape: first bodyOrigin: first rotationCentre rotation: 0
		andShape: second bodyOrigin: (20 @ 21) + second rotationCentre rotation: 0.
	self assert: touching notNil.
	self assert: separated isNil.
	^ touching
]
{ #category : 'tests - polygon manifolds' }
CFPhysicsCollisionTests >> testPolygonRotationUsesItsCentre [
	<gtExample>
	| shape vertices |
	shape := CFPhysicsPolygonShape rectangleExtent: 80 @ 30.
	vertices := shape worldVerticesAtBodyOrigin: 140 @ 65 rotation: Float pi / 2.0.
	self assert: shape rotationCentre equals: 40.0 @ 15.0.
	self assert: (vertices first closeTo: 155.0 @ 25.0).
	self assert: (vertices second closeTo: 155.0 @ 105.0).
	self assert: (vertices third closeTo: 125.0 @ 105.0).
	self assert: (vertices fourth closeTo: 125.0 @ 25.0).
	^ shape
]
{ #category : 'tests - polygon manifolds' }
CFPhysicsCollisionTests >> testPolygonWorldAndLocalTransformsRoundTripAroundCentre [
	<gtExample>
	| shape localPoint worldPoint recoveredPoint |
	shape := CFPhysicsPolygonShape rectangleExtent: 80 @ 30.
	localPoint := 70 @ 10.
	worldPoint := 100 @ 50
		+ (shape rotate: localPoint around: shape rotationCentre by: Float pi / 3.0).
	recoveredPoint := shape
		localPointForWorldPoint: worldPoint
		bodyOrigin: 140 @ 65
		rotation: Float pi / 3.0.
	self assert: (recoveredPoint closeTo: localPoint).
	^ shape
]
{ #category : 'tests - Bloc geometry' }
CFPhysicsCollisionTests >> testBlocPolygonShapeUsesElementCentreAsRotationCentre [
	<gtExample>
	| element polygon |
	element := BlElement new
		geometry: BlRoundedRectangleGeometry new;
		size: 80 @ 30;
		yourself.
	polygon := (CFPhysicsShapeState on: element) polygonShape.
	self assert: polygon rotationCentre equals: 40.0 @ 15.0.
	^ polygon
]
{ #category : 'tests - Bloc geometry' }
CFPhysicsCollisionTests >> testRectangleElementProducesPolygonShape [
	<gtExample>
	| element shapeState polygon |
	element := BlElement new
		geometry: BlRoundedRectangleGeometry new;
		size: 80 @ 30;
		yourself.
	shapeState := CFPhysicsShapeState on: element.
	polygon := shapeState polygonShape.
	self assert: polygon notNil.
	self assert: polygon radius equals: 0.0.
	self assert: polygon vertices equals: { 0.0 @ 0.0. 80.0 @ 0.0. 80.0 @ 30.0. 0.0 @ 30.0 }.
	^ polygon
]
{ #category : 'tests - Bloc geometry' }
CFPhysicsCollisionTests >> testRoundedRectangleElementProducesInsetCoreAndRadius [
	<gtExample>
	| element shapeState polygon |
	element := BlElement new
		geometry: (BlRoundedRectangleGeometry cornerRadii: (BlCornerRadii radius: 6));
		size: 80 @ 30;
		yourself.
	shapeState := CFPhysicsShapeState on: element.
	polygon := shapeState polygonShape.
	self assert: polygon radius equals: 6.0.
	self assert: polygon vertices equals: { 6.0 @ 6.0. 74.0 @ 6.0. 74.0 @ 24.0. 6.0 @ 24.0 }.
	^ polygon
]
{ #category : 'tests - Bloc geometry' }
CFPhysicsCollisionTests >> testNormalizedPolygonElementUsesItsRenderedExtent [
	<gtExample>
	| element shapeState polygon |
	element := BlElement new
		geometry: (BlNormalizedPolygonGeometry vertices: { 0 @ 0. 1 @ 0. 0.5 @ 1 });
		size: 80 @ 30;
		yourself.
	shapeState := CFPhysicsShapeState on: element.
	polygon := shapeState polygonShape.
	self assert: polygon vertices equals: { 0 @ 0. 80 @ 0. 40.0 @ 30 }.
	^ polygon
]
{ #category : 'tests - Bloc geometry' }
CFPhysicsCollisionTests >> testBlocGeometryRoutesToPolygonManifold [
	<gtExample>
	| ground box manifold |
	ground := CFPhysicsShapeState on: (BlElement new
		geometry: BlRoundedRectangleGeometry new;
		size: 100 @ 20;
		yourself).
	box := CFPhysicsShapeState on: (BlElement new
		geometry: (BlRoundedRectangleGeometry cornerRadii: (BlCornerRadii radius: 5));
		size: 60 @ 20;
		yourself).
	manifold := CFPhysicsManifoldGenerator new
		manifoldBetweenShapeState: ground bodyOrigin: (0 @ 0) + (ground extent / 2.0) rotation: 0
		andShapeState: box bodyOrigin: (20 @ 15) + (box extent / 2.0) rotation: 0.
	self assert: manifold notNil.
	self assert: manifold contactPoints size equals: 2.
	self assert: manifold normal equals: 0 @ 1.
	^ manifold
]
{ #category : 'tests - Bloc geometry' }
CFPhysicsCollisionTests >> testCircleDoesNotPretendToBeAPolygon [
	<gtExample>
	| element shapeState |
	element := BlElement new
		geometry: BlCircleGeometry new;
		size: 30 @ 30;
		yourself.
	shapeState := CFPhysicsShapeState on: element.
	self assert: shapeState polygonShape isNil.
	^ shapeState
]
{ #category : 'tests - circle manifolds' }
CFPhysicsCollisionTests >> testOverlappingCirclesProducePersistentSinglePointManifold [
	<gtExample>
	| first second firstManifold secondManifold |
	first := CFPhysicsShapeState on: (BlElement new
		geometry: BlCircleGeometry new;
		size: 30 @ 30;
		yourself).
	second := CFPhysicsShapeState on: (BlElement new
		geometry: BlCircleGeometry new;
		size: 30 @ 30;
		yourself).
	firstManifold := CFPhysicsManifoldGenerator new
		manifoldBetweenShapeState: first bodyOrigin: (0 @ 0) + (first extent / 2.0) rotation: 0
		andShapeState: second bodyOrigin: (25 @ 0) + (second extent / 2.0) rotation: 0.
	secondManifold := CFPhysicsManifoldGenerator new
		manifoldBetweenShapeState: first bodyOrigin: (1 @ 0) + (first extent / 2.0) rotation: 0
		andShapeState: second bodyOrigin: (25 @ 0) + (second extent / 2.0) rotation: 0.
	self assert: firstManifold notNil.
	self assert: firstManifold contactPoints size equals: 1.
	self assert: firstManifold normal equals: 1 @ 0.
	self assert: (firstManifold contactPoints first separation closeTo: -5.0).
	self assert: firstManifold contactPoints first featureId equals: secondManifold contactPoints first featureId.
	^ firstManifold
]
{ #category : 'tests - circle manifolds' }
CFPhysicsCollisionTests >> testSeparatedCirclesDoNotProduceAManifold [
	<gtExample>
	| first second manifold |
	first := CFPhysicsShapeState on: (BlElement new geometry: BlCircleGeometry new; size: 30 @ 30; yourself).
	second := CFPhysicsShapeState on: (BlElement new geometry: BlCircleGeometry new; size: 30 @ 30; yourself).
	manifold := CFPhysicsManifoldGenerator new
		manifoldBetweenShapeState: first bodyOrigin: (0 @ 0) + (first extent / 2.0) rotation: 0
		andShapeState: second bodyOrigin: (31 @ 0) + (second extent / 2.0) rotation: 0.
	self assert: manifold isNil.
	^ manifold
]
{ #category : 'tests - circle manifolds' }
CFPhysicsCollisionTests >> testCircleAgainstRectangleProducesMixedShapeManifold [
	<gtExample>
	| circle rectangle manifold |
	circle := CFPhysicsShapeState on: (BlElement new geometry: BlCircleGeometry new; size: 20 @ 20; yourself).
	rectangle := CFPhysicsShapeState on: (BlElement new geometry: BlRoundedRectangleGeometry new; size: 80 @ 20; yourself).
	manifold := CFPhysicsManifoldGenerator new
		manifoldBetweenShapeState: circle bodyOrigin: (30 @ 12) + (circle extent / 2.0) rotation: 0
		andShapeState: rectangle bodyOrigin: (0 @ 20) + (rectangle extent / 2.0) rotation: 0.
	self assert: manifold notNil.
	self assert: manifold contactPoints size equals: 1.
	self assert: manifold normal equals: 0 @ 1.
	self assert: (manifold contactPoints first separation closeTo: -8.0).
	self assert: manifold contactPoints first localAnchorA notNil.
	self assert: manifold contactPoints first localAnchorB notNil.
	^ manifold
]
{ #category : 'tests - circle manifolds' }
CFPhysicsCollisionTests >> testMixedShapeOrderingReversesOnlyTheManifoldOrientation [
	<gtExample>
	| circle rectangle circleFirst polygonFirst |
	circle := CFPhysicsShapeState on: (BlElement new geometry: BlCircleGeometry new; size: 20 @ 20; yourself).
	rectangle := CFPhysicsShapeState on: (BlElement new geometry: BlRoundedRectangleGeometry new; size: 80 @ 20; yourself).
	circleFirst := CFPhysicsManifoldGenerator new
		manifoldBetweenShapeState: circle bodyOrigin: (30 @ 12) + (circle extent / 2.0) rotation: 0
		andShapeState: rectangle bodyOrigin: (0 @ 20) + (rectangle extent / 2.0) rotation: 0.
	polygonFirst := CFPhysicsManifoldGenerator new
		manifoldBetweenShapeState: rectangle bodyOrigin: (0 @ 20) + (rectangle extent / 2.0) rotation: 0
		andShapeState: circle bodyOrigin: (30 @ 12) + (circle extent / 2.0) rotation: 0.
	self assert: polygonFirst notNil.
	self assert: polygonFirst normal equals: circleFirst normal negated.
	self assert: polygonFirst contactPoints first position equals: circleFirst contactPoints first position.
	self assert: polygonFirst contactPoints first separation equals: circleFirst contactPoints first separation.
	^ polygonFirst
]
{ #category : 'tests - circle manifolds' }
CFPhysicsCollisionTests >> testCircleContactsFlowThroughTheOrdinaryStepPipeline [
	<gtExample>
	| first second step pipeline result |
	first := self newBodyWithSequence: 1 position: 0 @ 0 extent: 30 @ 30.
	second := self newBodyWithSequence: 2 position: 25 @ 0 extent: 30 @ 30.
	first element geometry: BlCircleGeometry new.
	second element geometry: BlCircleGeometry new.
	step := CFPhysicsStep
		timeStep: 0.016
		substeps: 4
		contactHertz: 30.0
		dampingRatio: 10.0.
	pipeline := CFPhysicsStepPipeline manifoldGenerator: CFPhysicsManifoldGenerator new.
	result := pipeline
		stepBodies: { second. first }
		fromContacts: #()
		step: step
		gravity: 0 @ 0
		restitutionThreshold: 1.0.
	self assert: result activeContacts size equals: 1.
	self assert: result beganContacts size equals: 1.
	self assert: result contactConstraints size equals: 1.
	self assert: result contactSolveResults size equals: 1.
	^ result
]
{ #category : 'tests - anchors' }
CFPhysicsCollisionTests >> testLocalAnchorFollowsBodyTranslationAndRotation [
	<gtExample>
	| body anchor |
	body := self newBodyWithSequence: 1 position: 100 @ 50 extent: 40 @ 20.
	anchor := CFPhysicsLocalAnchor on: body at: 20 @ 0.
	self assert: anchor body == body.
	self assert: anchor localPoint equals: 20 @ 0.
	self assert: anchor worldPoint equals: 120 @ 50.
	body position: 110 @ 60.
	self assert: anchor worldPoint equals: 130 @ 60.
	body rotation: Float pi / 2.
	self assert: (anchor worldPoint closeTo: 140 @ 70).
	^ anchor
]
{ #category : 'tests - anchors' }
CFPhysicsCollisionTests >> testElementCanCreateALocalAnchor [
	<gtExample>
	| owner element world anchor |
	owner := BlElement new size: 400 @ 300; yourself.
	element := BlElement new size: 40 @ 20; yourself.
	owner addChild: element.
	world := owner physics beWorld.
	world owner physics makeChildrenDynamic.
	element physics position: 100 @ 50.
	anchor := element physics localAnchorAt: 40 @ 10.
	self assert: anchor class equals: CFPhysicsLocalAnchor.
	self assert: anchor body == element physics body.
	self assert: anchor worldPoint equals: 140 @ 60.
	^ anchor
]
{ #category : 'tests - anchors' }
CFPhysicsCollisionTests >> testRelationshipsCanResolveBodyLocalAnchors [
	<gtExample>
	| first second anchorA anchorB spring attraction repulsion |
	first := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self newBodyWithSequence: 2 position: 100 @ 0 extent: 20 @ 20.
	anchorA := CFPhysicsLocalAnchor on: first at: 20 @ 10.
	anchorB := CFPhysicsLocalAnchor on: second at: 0 @ 10.
	spring := CFPhysicsDistanceJoint betweenAnchor: anchorA andAnchor: anchorB.
	spring springEnabled: true; hertz: 3.0; dampingRatio: 1.0.
	attraction := CFPhysicsAttractionConstraint betweenAnchor: anchorA andAnchor: anchorB.
	repulsion := CFPhysicsRepulsionConstraint betweenAnchor: anchorA andAnchor: anchorB.
	self assert: spring anchorA == anchorA.
	self assert: spring anchorB == anchorB.
	self assert: attraction anchorA == anchorA.
	self assert: attraction anchorB == anchorB.
	self assert: repulsion anchorA == anchorA.
	self assert: repulsion anchorB == anchorB.
	self assert: anchorA worldPoint equals: 20 @ 10.
	self assert: anchorB worldPoint equals: 100 @ 10.
	^ { spring. attraction. repulsion }
]
{ #category : 'tests - anchors' }
CFPhysicsCollisionTests >> testNormalisedAnchorFollowsBodyGeometry [
	<gtExample>
	| body anchor |
	body := self newBodyWithSequence: 1 position: 100 @ 50 extent: 40 @ 20.
	anchor := CFPhysicsNormalisedAnchor on: body at: 1 @ 0.5.
	self assert: anchor body == body.
	self assert: anchor normalisedPoint equals: 1 @ 0.5.
	self assert: anchor worldPoint equals: 140 @ 60.
	body element size: 80 @ 40.
	self assert: anchor worldPoint equals: 160 @ 60.
	body rotation: Float pi / 2.
	self assert: (anchor worldPoint closeTo: 120 @ 100).
	^ anchor
]
{ #category : 'tests - anchors' }
CFPhysicsCollisionTests >> testElementCanCreateANormalisedAnchor [
	<gtExample>
	| owner element world anchor |
	owner := BlElement new size: 400 @ 300; yourself.
	element := BlElement new size: 40 @ 20; yourself.
	owner addChild: element.
	world := owner physics beWorld.
	world owner physics makeChildrenDynamic.
	element physics position: 100 @ 50.
	anchor := element physics normalisedAnchorAt: 1 @ 1.
	self assert: anchor class equals: CFPhysicsNormalisedAnchor.
	self assert: anchor body == element physics body.
	self assert: anchor worldPoint equals: 140 @ 70.
	^ anchor
]
{ #category : 'tests - anchors' }
CFPhysicsCollisionTests >> testRelationshipsCanResolveNormalisedAnchors [
	<gtExample>
	| first second anchorA anchorB spring attraction repulsion |
	first := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self newBodyWithSequence: 2 position: 100 @ 0 extent: 40 @ 20.
	anchorA := CFPhysicsNormalisedAnchor on: first at: 1 @ 0.5.
	anchorB := CFPhysicsNormalisedAnchor on: second at: 0 @ 0.5.
	spring := CFPhysicsDistanceJoint betweenAnchor: anchorA andAnchor: anchorB.
	spring springEnabled: true; hertz: 3.0; dampingRatio: 1.0.
	attraction := CFPhysicsAttractionConstraint betweenAnchor: anchorA andAnchor: anchorB.
	repulsion := CFPhysicsRepulsionConstraint betweenAnchor: anchorA andAnchor: anchorB.
	self assert: spring anchorA == anchorA.
	self assert: attraction anchorA == anchorA.
	self assert: repulsion anchorA == anchorA.
	self assert: anchorA worldPoint equals: 20 @ 10.
	self assert: anchorB worldPoint equals: 100 @ 10.
	^ { spring. attraction. repulsion }
]
{ #category : 'tests - anchors' }
CFPhysicsCollisionTests >> testExplicitAnchorsCanCreateWorldOwnedRelationships [
	<gtExample>
	| owner first second world anchorA anchorB spring attraction repulsion |
	owner := BlElement new size: 400 @ 300; yourself.
	first := BlElement new size: 40 @ 20; yourself.
	second := BlElement new size: 60 @ 30; yourself.
	owner addChildren: { first. second }.
	world := owner physics beWorld.
	world owner physics makeChildrenDynamic.
	first physics position: 20 @ 30.
	second physics position: 200 @ 80.
	anchorA := first physics localAnchorAt: 40 @ 10.
	anchorB := second physics normalisedAnchorAt: 0 @ 0.5.
	spring := anchorA distanceJointTo: anchorB.
	spring springEnabled: true; hertz: 3.0; dampingRatio: 1.0.
	attraction := anchorA attract: anchorB.
	repulsion := anchorA repel: anchorB.
	self assert: spring anchorA == anchorA.
	self assert: spring anchorB == anchorB.
	self assert: attraction anchorA == anchorA.
	self assert: attraction anchorB == anchorB.
	self assert: repulsion anchorA == anchorA.
	self assert: repulsion anchorB == anchorB.
	self assert: world springs equals: { spring }.
	self assert: world attractions equals: { attraction }.
	self assert: world repulsions equals: { repulsion }.
	^ { spring. attraction. repulsion }
]
{ #category : 'tests - anchors' }
CFPhysicsCollisionTests >> testWorldAnchorRemainsAtItsWorldPoint [
	<gtExample>
	| world anchor |
	world := CFPhysicsWorld new.
	anchor := world anchorAt: 75 @ 40.
	self assert: anchor body isNil.
	self assert: anchor world == world.
	self assert: anchor worldPoint equals: 75 @ 40.
	anchor point: 90 @ 55.
	self assert: anchor worldPoint equals: 90 @ 55.
	^ anchor
]
{ #category : 'tests - anchors' }
CFPhysicsCollisionTests >> testAttractionAndRepulsionCanUseWorldAnchors [
	<gtExample>
	| world attracted repelled attraction repulsion |
	world := CFPhysicsWorld new.
	attracted := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	repelled := self newBodyWithSequence: 2 position: 0 @ 40 extent: 20 @ 20.
	attracted world: world.
	repelled world: world.
	attraction := (CFPhysicsBodyCentreAnchor on: attracted)
		attract: (world anchorAt: 110 @ 10).
	repulsion := (CFPhysicsBodyCentreAnchor on: repelled)
		repel: (world anchorAt: 110 @ 50).
	attraction prepareForStep: 0.1.
	repulsion prepareForStep: 0.1.
	self assert: attracted velocity x > 0.
	self assert: repelled velocity x < 0.
	^ { attraction. repulsion }
]
{ #category : 'tests - anchors' }
CFPhysicsCollisionTests >> testWorldAnchorRelationshipsStillCleanUpWithTheirBody [
	<gtExample>
	| world body spring |
	world := CFPhysicsWorld new.
	body := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	body world: world.
	spring := (CFPhysicsBodyCentreAnchor on: body)
		distanceJointTo: (world anchorAt: 100 @ 10).
	spring springEnabled: true; hertz: 3.0; dampingRatio: 1.0.
	world removeDistanceJointsUsingBody: body.
	self assert: world springs isEmpty.
	self assert: spring isActive not.
	^ spring
]
{ #category : 'tests - coordinate contract' }
CFPhysicsCollisionTests >> testBodyLocalPointRoundTripsThroughWorld [
	<gtExample>
	| body localPoint worldPoint recoveredPoint |
	body := CFPhysicsBody
		element: (BlElement new size: 80 @ 30; yourself)
		world: nil.
	body
		position: 120 @ 75;
		rotation: Float pi / 3.0.
	localPoint := 30 @ -12.
	worldPoint := body worldPointForBodyLocalPoint: localPoint.
	recoveredPoint := body bodyLocalPointForWorldPoint: worldPoint.
	self assert: (recoveredPoint closeTo: localPoint).
	^ body
]
{ #category : 'tests - coordinate contract' }
CFPhysicsCollisionTests >> testBodyLocalVectorRoundTripsWithoutTranslation [
	<gtExample>
	| body localVector worldVector recoveredVector |
	body := CFPhysicsBody
		element: (BlElement new size: 80 @ 30; yourself)
		world: nil.
	body
		position: 120 @ 75;
		rotation: Float pi / 3.0.
	localVector := 14 @ -9.
	worldVector := body worldVectorForBodyLocalVector: localVector.
	recoveredVector := body bodyLocalVectorForWorldVector: worldVector.
	self assert: (recoveredVector closeTo: localVector).
	body position: 900 @ -240.
	self assert: ((body worldVectorForBodyLocalVector: localVector) closeTo: worldVector).
	^ body
]
{ #category : 'tests - coordinate contract' }
CFPhysicsCollisionTests >> testBodyAndCapturedStateUseTheSameCoordinateContract [
	<gtExample>
	| body state localPoint localVector |
	body := CFPhysicsBody
		element: (BlElement new size: 80 @ 30; yourself)
		world: nil.
	body
		position: 120 @ 75;
		rotation: Float pi / 3.0.
	state := CFPhysicsBodyStepState on: body.
	localPoint := 30 @ -12.
	localVector := 14 @ -9.
	self assert: ((state worldPointForBodyLocalPoint: localPoint)
		closeTo: (body worldPointForBodyLocalPoint: localPoint)).
	self assert: ((state worldVectorForBodyLocalVector: localVector)
		closeTo: (body worldVectorForBodyLocalVector: localVector)).
	^ state
]
{ #category : 'tests - coordinate contract' }
CFPhysicsCollisionTests >> testElementLocalAndBodyLocalPointsRoundTrip [
	<gtExample>
	| shapeState elementPoint bodyPoint recoveredPoint |
	shapeState := CFPhysicsShapeState on: (BlElement new size: 80 @ 30; yourself).
	elementPoint := 70 @ 10.
	bodyPoint := shapeState bodyLocalPointForElementLocalPoint: elementPoint.
	recoveredPoint := shapeState elementLocalPointForBodyLocalPoint: bodyPoint.
	self assert: bodyPoint equals: 30.0 @ -5.0.
	self assert: recoveredPoint equals: elementPoint.
	^ shapeState
]
{ #category : 'tests - coordinate contract' }
CFPhysicsCollisionTests >> testNormalisedPointsResolveIntoTheBodyLocalFrame [
	<gtExample>
	| shapeState |
	shapeState := CFPhysicsShapeState on: (BlElement new size: 80 @ 30; yourself).
	self assert: (shapeState bodyLocalPointForNormalisedPoint: 0 @ 0)
		equals: -40.0 @ -15.0.
	self assert: (shapeState bodyLocalPointForNormalisedPoint: 0.5 @ 0.5)
		equals: 0.0 @ 0.0.
	self assert: (shapeState bodyLocalPointForNormalisedPoint: 1 @ 1)
		equals: 40.0 @ 15.0.
	^ shapeState
]
{ #category : 'tests - coordinate contract' }
CFPhysicsCollisionTests >> testEquivalentLocalAndNormalisedAnchorsShareTheCoordinateContract [
	<gtExample>
	| body localAnchor normalisedAnchor centreAnchor |
	body := self newBodyWithSequence: 1 position: 100 @ 50 extent: 40 @ 20.
	body rotation: Float pi / 3.0.
	localAnchor := CFPhysicsLocalAnchor on: body at: 40 @ 10.
	normalisedAnchor := CFPhysicsNormalisedAnchor on: body at: 1 @ 0.5.
	centreAnchor := CFPhysicsBodyCentreAnchor on: body.
	self assert: (localAnchor worldPoint closeTo: normalisedAnchor worldPoint).
	self assert: (centreAnchor worldPoint closeTo: body worldBodyOrigin).
	^ { localAnchor. normalisedAnchor. centreAnchor }
]
{ #category : 'tests - coordinate contract' }
CFPhysicsCollisionTests >> testBodyStoresItsWorldOriginWithoutChangingTheElementPositionContract [
	<gtExample>
	| body |
	body := CFPhysicsBody
		element: (BlElement new size: 80 @ 30; yourself)
		world: nil.
	self assert: body position equals: 0 @ 0.
	self assert: body worldBodyOrigin equals: 40.0 @ 15.0.
	body position: 120 @ 75.
	self assert: body position equals: 120.0 @ 75.0.
	self assert: body previousPosition equals: 120.0 @ 75.0.
	self assert: body worldBodyOrigin equals: 160.0 @ 90.0.
	body translateBy: 15 @ -10.
	self assert: body position equals: 135.0 @ 65.0.
	self assert: body worldBodyOrigin equals: 175.0 @ 80.0.
	^ body
]
{ #category : 'tests - coordinates' }
CFPhysicsCollisionTests >> testBodyStepStateCapturesBodyOriginWithoutChangingTransformContract [
	<gtExample>
	| body state |
	body := self newBodyWithSequence: 1 position: 100 @ 50 extent: 40 @ 20.
	state := CFPhysicsBodyStepState on: body.
	self assert: state startBodyOrigin equals: 120 @ 60.
	self assert: state currentBodyOrigin equals: 120 @ 60.
	self assert: state currentTransform bodyOrigin equals: 120 @ 60.
	state translateBy: 10 @ 5.
	self assert: state currentBodyOrigin equals: 130 @ 65.
	self assert: state currentTransform bodyOrigin equals: 130 @ 65.
	^ state
]
{ #category : 'tests - polygon manifolds' }
CFPhysicsCollisionTests >> testSeparatedPolygonCoresWithinSpeculativeDistanceProduceAManifold [
	<gtExample>
	| first second manifold |
	first := CFPhysicsPolygonShape rectangleExtent: 100 @ 20.
	second := CFPhysicsPolygonShape rectangleExtent: 60 @ 20.
	manifold := CFPhysicsPolygonManifoldBuilder
		manifoldBetweenShape: first
		bodyOrigin: first rotationCentre
		rotation: 0
		andShape: second
		bodyOrigin: (20 @ 21) + second rotationCentre
		rotation: 0
		speculativeDistance: 2.0.
	self assert: manifold notNil.
	self assert: manifold contactPoints size equals: 2.
	manifold contactPoints do: [ :point |
		self assert: (point separation closeTo: 1.0) ].
	^ manifold
]
{ #category : 'tests - polygon manifolds' }
CFPhysicsCollisionTests >> testPolygonSeparationBeyondSpeculativeDistanceDoesNotProduceAManifold [
	<gtExample>
	| first second manifold |
	first := CFPhysicsPolygonShape rectangleExtent: 100 @ 20.
	second := CFPhysicsPolygonShape rectangleExtent: 60 @ 20.
	manifold := CFPhysicsPolygonManifoldBuilder
		manifoldBetweenShape: first
		bodyOrigin: first rotationCentre
		rotation: 0
		andShape: second
		bodyOrigin: (20 @ 23) + second rotationCentre
		rotation: 0
		speculativeDistance: 2.0.
	self assert: manifold isNil.
	^ manifold
]
{ #category : 'tests - polygon manifolds' }
CFPhysicsCollisionTests >> testClippedIntersectionUsesReferenceVertexAndIncidentFaceIdentity [
	<gtExample>
	| firstFeature secondFeature first second clipped intersectionFeature |
	firstFeature := CFPhysicsContactFeatureId
		featureA: #face index: 3
		featureB: #vertex index: 2.
	secondFeature := CFPhysicsContactFeatureId
		featureA: #face index: 3
		featureB: #vertex index: 3.
	first := CFPhysicsClipVertex
		position: -1 @ 0
		featureId: firstFeature
		incidentEdgeIndex: 2.
	second := CFPhysicsClipVertex
		position: 1 @ 0
		featureId: secondFeature
		incidentEdgeIndex: 2.
	clipped := CFPhysicsPolygonManifoldBuilder
		clip: { first. second }
		toNormal: 1 @ 0
		offset: 0
		referenceVertexIndex: 4
		referenceIsA: true.
	self assert: clipped size equals: 2.
	intersectionFeature := clipped second featureId.
	self assert: intersectionFeature featureA equals: #vertex.
	self assert: intersectionFeature indexA equals: 4.
	self assert: intersectionFeature featureB equals: #face.
	self assert: intersectionFeature indexB equals: 2.
	^ clipped
]
{ #category : 'tests - polygon manifolds' }
CFPhysicsCollisionTests >> testClippedFaceContactIdentityPersistsAcrossTangentialMotion [
	<gtExample>
	| ground box first second firstIds secondIds |
	ground := CFPhysicsPolygonShape rectangleExtent: 100 @ 20.
	box := CFPhysicsPolygonShape rectangleExtent: 60 @ 20.
	first := CFPhysicsPolygonManifoldBuilder
		manifoldBetweenShape: ground bodyOrigin: ground rotationCentre rotation: 0
		andShape: box bodyOrigin: (-10 @ 15) + box rotationCentre rotation: 0.
	second := CFPhysicsPolygonManifoldBuilder
		manifoldBetweenShape: ground bodyOrigin: ground rotationCentre rotation: 0
		andShape: box bodyOrigin: (-9 @ 15) + box rotationCentre rotation: 0.
	firstIds := first contactPoints collect: #featureId.
	secondIds := second contactPoints collect: #featureId.
	self assert: firstIds asSet equals: secondIds asSet.
	self assert: (firstIds anySatisfy: [ :featureId |
		featureId featureA = #vertex and: [ featureId featureB = #face ] ]).
	^ second
]
{ #category : 'tests - circle manifolds' }
CFPhysicsCollisionTests >> testSeparatedCirclesWithinSpeculativeDistanceProduceAStableManifoldPoint [
	<gtExample>
	| first second firstManifold secondManifold |
	first := CFPhysicsShapeState on: (BlElement new geometry: BlCircleGeometry new; size: 30 @ 30; yourself).
	second := CFPhysicsShapeState on: (BlElement new geometry: BlCircleGeometry new; size: 30 @ 30; yourself).
	firstManifold := CFPhysicsManifoldGenerator new
		manifoldBetweenShapeState: first
		bodyOrigin: first extent / 2.0
		rotation: 0
		andShapeState: second
		bodyOrigin: (31 @ 0) + (second extent / 2.0)
		rotation: 0
		speculativeDistance: 2.0.
	secondManifold := CFPhysicsManifoldGenerator new
		manifoldBetweenShapeState: first
		bodyOrigin: first extent / 2.0
		rotation: 0
		andShapeState: second
		bodyOrigin: (30.5 @ 0) + (second extent / 2.0)
		rotation: 0
		speculativeDistance: 2.0.
	self assert: firstManifold notNil.
	self assert: (firstManifold contactPoints first separation closeTo: 1.0).
	self assert: firstManifold contactPoints first featureId equals: secondManifold contactPoints first featureId.
	^ firstManifold
]
{ #category : 'tests - circle manifolds' }
CFPhysicsCollisionTests >> testCircleSeparationBeyondSpeculativeDistanceDoesNotProduceAManifold [
	<gtExample>
	| first second manifold |
	first := CFPhysicsShapeState on: (BlElement new geometry: BlCircleGeometry new; size: 30 @ 30; yourself).
	second := CFPhysicsShapeState on: (BlElement new geometry: BlCircleGeometry new; size: 30 @ 30; yourself).
	manifold := CFPhysicsManifoldGenerator new
		manifoldBetweenShapeState: first
		bodyOrigin: first extent / 2.0
		rotation: 0
		andShapeState: second
		bodyOrigin: (33 @ 0) + (second extent / 2.0)
		rotation: 0
		speculativeDistance: 2.0.
	self assert: manifold isNil.
	^ manifold
]
{ #category : 'tests - Bloc geometry' }
CFPhysicsCollisionTests >> testEllipseElementUsesBox2DMaximumVertexPolygon [
	<gtExample>
	| element shapeState polygon |
	element := BlElement new
		geometry: BlEllipseGeometry new;
		size: 80 @ 40;
		yourself.
	shapeState := (CFPhysicsShapeState on: element) capturedForStep.
	polygon := shapeState polygonShape.
	self assert: polygon vertices size equals: 8.
	self assert: polygon rotationCentre equals: 40.0 @ 20.0.
	self assert: (polygon vertices first closeTo: 80.0 @ 20.0).
	self assert: (polygon vertices third closeTo: 40.0 @ 40.0).
	^ polygon
]
{ #category : 'tests - Bloc geometry' }
CFPhysicsCollisionTests >> testCapturedGeometryDoesNotRetainBlocGeometry [
	<gtExample>
	| element shapeState geometry |
	element := BlElement new
		geometry: BlEllipseGeometry new;
		size: 80 @ 40;
		yourself.
	shapeState := (CFPhysicsShapeState on: element) capturedForStep.
	geometry := shapeState capturedCollisionGeometry.
	self assert: geometry class equals: CFPhysicsCapturedPolygonGeometry.
	self assert: geometry ~~ element geometry.
	^ geometry
]
{ #category : 'tests - chains' }
CFPhysicsCollisionTests >> testChainLoopBuildsBox2DGhostVertices [
	<gtExample>
	| vertices chain first second fourth |
	vertices := { 0 @ 0. 10 @ 0. 10 @ 10. 0 @ 10 }.
	chain := CFPhysicsChainBuilder
		loopFrom: vertices
		material: nil
		collisionFilter: nil.
	self assert: chain isLoop.
	self assert: chain vertices equals: vertices.
	self assert: chain segments size equals: 4.
	first := chain segments first.
	second := chain segments second.
	fourth := chain segments fourth.
	self assert: first segmentIndex equals: 1.
	self assert: first ghost1 equals: 0 @ 10.
	self assert: first point1 equals: 0 @ 0.
	self assert: first point2 equals: 10 @ 0.
	self assert: first ghost2 equals: 10 @ 10.
	self assert: second ghost1 equals: 0 @ 0.
	self assert: second point1 equals: 10 @ 0.
	self assert: second point2 equals: 10 @ 10.
	self assert: second ghost2 equals: 0 @ 10.
	self assert: fourth ghost1 equals: 10 @ 10.
	self assert: fourth point1 equals: 0 @ 10.
	self assert: fourth point2 equals: 0 @ 0.
	self assert: fourth ghost2 equals: 10 @ 0.
	self assert: first chain == chain.
	^ chain
]
{ #category : 'tests - chains' }
CFPhysicsCollisionTests >> testInwardChainLoopReversesBoundaryVertices [
	<gtExample>
	| vertices chain |
	vertices := { 0 @ 0. 10 @ 0. 10 @ 10. 0 @ 10 }.
	chain := CFPhysicsChainBuilder
		inwardLoopFrom: vertices
		material: nil
		collisionFilter: nil.
	self assert: chain vertices equals: vertices reversed asArray.
	self assert: chain segments first point1 equals: 0 @ 10.
	self assert: chain segments first point2 equals: 10 @ 10.
	^ chain
]
{ #category : 'tests - chains' }
CFPhysicsCollisionTests >> testChainLoopRequiresFourVertices [
	<gtExample>
	| raised |
	raised := false.
	[ CFPhysicsChainBuilder
		loopFrom: { 0 @ 0. 10 @ 0. 0 @ 10 }
		material: nil
		collisionFilter: nil ]
		on: Error
		do: [ :error | raised := true ].
	self assert: raised.
	^ raised
]
{ #category : 'tests - shapes' }
CFPhysicsCollisionTests >> testBodyOwnsItsPrimaryShapeThroughACollection [
	<gtExample>
	| body collection primary |
	body := CFPhysicsBody
		element: (BlElement new size: 20 @ 10; yourself)
		world: nil.
	collection := body shapeCollection.
	primary := body shapeState.
	self assert: collection size equals: 1.
	self assert: collection primaryShape == primary.
	self assert: body shapes equals: { primary }.
	^ collection
]
{ #category : 'tests - shapes' }
CFPhysicsCollisionTests >> testShapeCollectionPreservesShapeOrder [
	<gtExample>
	| first second collection |
	first := CFPhysicsShapeState on: (BlElement new size: 10 @ 10; yourself).
	second := CFPhysicsShapeState on: (BlElement new size: 20 @ 20; yourself).
	collection := CFPhysicsShapeCollection with: first.
	collection add: second.
	self assert: collection shapes equals: { first. second }.
	self assert: collection primaryShape == first.
	^ collection
]
{ #category : 'tests - shapes' }
CFPhysicsCollisionTests >> testShapeCollectionCanOwnChainSegmentShapes [
	<gtExample>
	| primary chain collection |
	primary := CFPhysicsShapeState on: (BlElement new size: 10 @ 10; yourself).
	chain := CFPhysicsChainBuilder
		loopFrom: { 0 @ 0. 20 @ 0. 20 @ 20. 0 @ 20 }
		material: nil
		collisionFilter: nil.
	collection := CFPhysicsShapeCollection with: primary.
	chain segments do: [ :segment | collection add: segment ].
	self assert: collection size equals: 5.
	self assert: collection primaryShape == primary.
	self assert: collection shapes second == chain segments first.
	self assert: collection shapes last == chain segments last.
	^ collection
]
{ #category : 'tests - chains' }
CFPhysicsCollisionTests >> testChainAttachesItsSegmentShapesToOneBody [
	<gtExample>
	| body chain |
	body := CFPhysicsBody
		element: (BlElement new size: 40 @ 40; yourself)
		world: nil.
	chain := CFPhysicsChainBuilder
		loopFrom: { 0 @ 0. 40 @ 0. 40 @ 40. 0 @ 40 }
		material: nil
		collisionFilter: nil
		body: body.
	self assert: chain body == body.
	self assert: body shapeCollection size equals: 5.
	chain segments do: [ :segment |
		self assert: segment body == body.
		self assert: (body shapeCollection includes: segment) ].
	^ chain
]
{ #category : 'tests - chains' }
CFPhysicsCollisionTests >> testChainSegmentAABBUsesOnlyItsSolidEdge [
	<gtExample>
	| chain segment bounds |
	chain := CFPhysicsChainBuilder
		loopFrom: { 0 @ 0. 10 @ 0. 10 @ 10. 0 @ 10 }
		material: nil
		collisionFilter: nil.
	segment := chain segments first.
	bounds := segment aabbAtBodyOrigin: 5 @ 7 rotation: 0.
	self assert: bounds minimum equals: 5 @ 7.
	self assert: bounds maximum equals: 15 @ 7.
	^ bounds
]
{ #category : 'tests - chains' }
CFPhysicsCollisionTests >> testChainSegmentAABBTracksBodyRotation [
	<gtExample>
	| chain segment bounds |
	chain := CFPhysicsChainBuilder
		loopFrom: { 0 @ 0. 10 @ 0. 10 @ 10. 0 @ 10 }
		material: nil
		collisionFilter: nil.
	segment := chain segments first.
	bounds := segment aabbAtBodyOrigin: 5 @ 7 rotation: Float pi / 2.0.
	self assert: (bounds minimum closeTo: 5 @ 7).
	self assert: (bounds maximum closeTo: 5 @ 17).
	^ bounds
]
{ #category : 'tests - chains' }
CFPhysicsCollisionTests >> testChainSegmentPairsHaveDistinctPersistentKeys [
	<gtExample>
	| worldBody dynamicBody chain firstPair secondPair |
	worldBody := CFPhysicsBody
		element: (BlElement new size: 40 @ 40; yourself)
		world: nil.
	dynamicBody := CFPhysicsBody
		element: (BlElement new size: 10 @ 10; yourself)
		world: nil.
	worldBody sequence: 1.
	dynamicBody sequence: 2.
	chain := CFPhysicsChainBuilder
		loopFrom: { 0 @ 0. 40 @ 0. 40 @ 40. 0 @ 40 }
		material: nil
		collisionFilter: nil
		body: worldBody.
	firstPair := CFPhysicsPair
		firstBody: worldBody
		shape: chain segments first
		shapeIndex: chain segments first segmentIndex
		secondBody: dynamicBody
		shape: dynamicBody shapeState
		shapeIndex: 0.
	secondPair := CFPhysicsPair
		firstBody: worldBody
		shape: chain segments second
		shapeIndex: chain segments second segmentIndex
		secondBody: dynamicBody
		shape: dynamicBody shapeState
		shapeIndex: 0.
	self assert: firstPair key ~= secondPair key.
	self assert: (firstPair comesBefore: secondPair).
	^ { firstPair. secondPair }
]
{ #category : 'tests - collision' }
CFPhysicsCollisionTests >> testPrimaryBodyPairsKeepZeroShapeIndexes [
	<gtExample>
	| first second pair |
	first := CFPhysicsBody element: (BlElement new size: 10 @ 10; yourself) world: nil.
	second := CFPhysicsBody element: (BlElement new size: 10 @ 10; yourself) world: nil.
	first sequence: 1.
	second sequence: 2.
	pair := CFPhysicsPair first: first second: second.
	self assert: pair firstShape == first shapeState.
	self assert: pair secondShape == second shapeState.
	self assert: pair key firstShapeIndex equals: 0.
	self assert: pair key secondShapeIndex equals: 0.
	^ pair
]
{ #category : 'tests - chains' }
CFPhysicsCollisionTests >> testBroadphaseRegistersChainSegmentsAsDistinctShapes [
	<gtExample>
	| worldBody dynamicBody chain broadphase pairs segmentPair |
	worldBody := CFPhysicsBody
		element: (BlElement new size: 1 @ 1; yourself)
		world: nil.
	worldBody sequence: 1.
	worldBody beStatic.
	chain := CFPhysicsChainBuilder
		loopFrom: { 10 @ 0. 30 @ 0. 30 @ 20. 10 @ 20 }
		material: nil
		collisionFilter: nil
		body: worldBody.
	dynamicBody := CFPhysicsBody
		element: (BlElement new size: 4 @ 4; yourself)
		world: nil.
	dynamicBody sequence: 2.
	dynamicBody position: 18 @ -2.
	dynamicBody beDynamic.
	broadphase := CFPhysicsBroadphase new.
	pairs := broadphase
		pairsAmongSolvedStepStates: {
			CFPhysicsBodyStepState on: worldBody.
			CFPhysicsBodyStepState on: dynamicBody }
		collisionSuppressedBodyPairs: #()
		step: nil.
	segmentPair := pairs
		detect: [ :pair | pair firstShape isChainSegment ]
		ifNone: [ nil ].
	self assert: broadphase proxyCount equals: worldBody shapes size + dynamicBody shapes size.
	self assert: segmentPair isNotNil.
	self assert: segmentPair firstBody == worldBody.
	self assert: segmentPair firstShape == chain segments first.
	self assert: segmentPair firstShapeIndex equals: 1.
	self assert: segmentPair secondBody == dynamicBody.
	self assert: segmentPair secondShape == dynamicBody shapeState.
	^ pairs
]
{ #category : 'tests - chains' }
CFPhysicsCollisionTests >> testChainSegmentCircleManifoldUsesOneSidedCollision [
	<gtExample>
	| worldElement worldBody circleElement circleBody chain segment pair states manifold |
	worldElement := BlElement new size: 100 @ 100; yourself.
	circleElement := BlElement new geometry: BlCircleGeometry new; size: 10 @ 10; yourself.
	worldBody := CFPhysicsBody element: worldElement world: nil.
	circleBody := CFPhysicsBody element: circleElement world: nil.
	worldBody sequence: 1.
	circleBody sequence: 2.
	worldBody beStatic.
	circleBody position: 50 @ -6.
	chain := CFPhysicsChainBuilder
		loopFrom: { -50 @ -50. 50 @ -50. 50 @ 50. -50 @ 50 }
		material: nil
		collisionFilter: nil
		body: worldBody.
	segment := chain segments first.
	pair := CFPhysicsPair
		firstBody: worldBody
		shape: segment
		shapeIndex: segment segmentIndex
		secondBody: circleBody
		shape: circleBody shapeState
		shapeIndex: 0.
	states := IdentityDictionary new
		at: worldBody put: (CFPhysicsBodyStepState on: worldBody);
		at: circleBody put: (CFPhysicsBodyStepState on: circleBody);
		yourself.
	manifold := CFPhysicsManifoldGenerator new
		manifoldForPair: pair
		bodyStates: states
		speculativeDistance: 0.0.
	self assert: manifold notNil.
	self assert: manifold normal y < 0.0.
	^ manifold
]
{ #category : 'tests - chains' }
CFPhysicsCollisionTests >> testChainSegmentCircleRejectsBackSide [
	<gtExample>
	| worldElement worldBody circleElement circleBody chain segment pair states manifold |
	worldElement := BlElement new size: 100 @ 100; yourself.
	circleElement := BlElement new geometry: BlCircleGeometry new; size: 10 @ 10; yourself.
	worldBody := CFPhysicsBody element: worldElement world: nil.
	circleBody := CFPhysicsBody element: circleElement world: nil.
	worldBody sequence: 1.
	circleBody sequence: 2.
	worldBody beStatic.
	circleBody position: 50 @ 4.
	chain := CFPhysicsChainBuilder
		loopFrom: { -50 @ -50. 50 @ -50. 50 @ 50. -50 @ 50 }
		material: nil
		collisionFilter: nil
		body: worldBody.
	segment := chain segments first.
	pair := CFPhysicsPair
		firstBody: worldBody
		shape: segment
		shapeIndex: segment segmentIndex
		secondBody: circleBody
		shape: circleBody shapeState
		shapeIndex: 0.
	states := IdentityDictionary new
		at: worldBody put: (CFPhysicsBodyStepState on: worldBody);
		at: circleBody put: (CFPhysicsBodyStepState on: circleBody);
		yourself.
	manifold := CFPhysicsManifoldGenerator new
		manifoldForPair: pair
		bodyStates: states
		speculativeDistance: 0.0.
	self assert: manifold isNil.
	^ manifold
]
{ #category : 'tests - chains' }
CFPhysicsCollisionTests >> testChainSegmentPolygonManifoldUsesOneSidedCollision [
	<gtExample>
	| worldElement worldBody boxElement boxBody chain segment pair states manifold |
	worldElement := BlElement new size: 100 @ 100; yourself.
	boxElement := BlElement new size: 10 @ 10; yourself.
	worldBody := CFPhysicsBody element: worldElement world: nil.
	boxBody := CFPhysicsBody element: boxElement world: nil.
	worldBody sequence: 1.
	boxBody sequence: 2.
	worldBody beStatic.
	boxBody position: 45 @ -6.
	chain := CFPhysicsChainBuilder
		loopFrom: { -50 @ -50. 50 @ -50. 50 @ 50. -50 @ 50 }
		material: nil
		collisionFilter: nil
		body: worldBody.
	segment := chain segments first.
	pair := CFPhysicsPair
		firstBody: worldBody
		shape: segment
		shapeIndex: segment segmentIndex
		secondBody: boxBody
		shape: boxBody shapeState
		shapeIndex: 0.
	states := IdentityDictionary new
		at: worldBody put: (CFPhysicsBodyStepState on: worldBody);
		at: boxBody put: (CFPhysicsBodyStepState on: boxBody);
		yourself.
	manifold := CFPhysicsManifoldGenerator new
		manifoldForPair: pair
		bodyStates: states
		speculativeDistance: 0.0.
	self assert: manifold notNil.
	self assert: manifold normal y < 0.0.
	self assert: manifold contactPoints notEmpty.
	^ manifold
]
{ #category : 'tests - chains' }
CFPhysicsCollisionTests >> testChainSegmentPolygonRejectsBackSide [
	<gtExample>
	| worldElement worldBody boxElement boxBody chain segment pair states manifold |
	worldElement := BlElement new size: 100 @ 100; yourself.
	boxElement := BlElement new size: 10 @ 10; yourself.
	worldBody := CFPhysicsBody element: worldElement world: nil.
	boxBody := CFPhysicsBody element: boxElement world: nil.
	worldBody sequence: 1.
	boxBody sequence: 2.
	worldBody beStatic.
	boxBody position: 45 @ 4.
	chain := CFPhysicsChainBuilder
		loopFrom: { -50 @ -50. 50 @ -50. 50 @ 50. -50 @ 50 }
		material: nil
		collisionFilter: nil
		body: worldBody.
	segment := chain segments first.
	pair := CFPhysicsPair
		firstBody: worldBody
		shape: segment
		shapeIndex: segment segmentIndex
		secondBody: boxBody
		shape: boxBody shapeState
		shapeIndex: 0.
	states := IdentityDictionary new
		at: worldBody put: (CFPhysicsBodyStepState on: worldBody);
		at: boxBody put: (CFPhysicsBodyStepState on: boxBody);
		yourself.
	manifold := CFPhysicsManifoldGenerator new
		manifoldForPair: pair
		bodyStates: states
		speculativeDistance: 0.0.
	self assert: manifold isNil.
	^ manifold
]
{ #category : 'tests - chains' }
CFPhysicsCollisionTests >> testChainSegmentDistanceProxyMatchesBox2DSegment [
	<gtExample>
	| chain segment proxy |
	chain := CFPhysicsChainBuilder
		loopFrom: { 0 @ 0. 10 @ 0. 10 @ 10. 0 @ 10 }
		material: nil
		collisionFilter: nil.
	segment := chain segments first.
	proxy := segment distanceProxy.
	self assert: proxy points equals: { segment point1. segment point2 }.
	self assert: proxy radius equals: 0.0.
	^ proxy
]
{ #category : 'tests - chain shapes' }
CFPhysicsCollisionTests >> testChainSegmentImplementsGenericCollisionShapeQueries [
	<gtExample>
	| material filter body chain segment sweep bounds |
	material := CFPhysicsMaterial new.
	filter := CFPhysicsCollisionFilter new.
	body := CFPhysicsBody new.
	chain := CFPhysicsChainBuilder
		loopFrom: { -10 @ -10. 10 @ -10. 10 @ 10. -10 @ 10 }
		material: material
		collisionFilter: filter
		body: body.
	segment := chain segments first.

	self assert: segment material == material.
	self assert: segment collisionFilter == filter.
	self assert: segment boundingRadius >= segment minimumExtent.
	self assert: segment rollingResistanceRadius equals: 0.0.

	sweep := CFPhysicsSweep
		from: (CFPhysicsTransform bodyOrigin: 0 @ 0 rotation: 0.0)
		to: (CFPhysicsTransform bodyOrigin: 5 @ 0 rotation: 0.0).
	bounds := segment sweptAABBAlong: sweep.
	self assert: bounds minimum x <= -10.
	self assert: bounds maximum x >= 15
]
{ #category : 'tests - chains' }
CFPhysicsCollisionTests >> testChainPolygonNormalClassificationMatchesBox2DTailBranches [
	<gtExample>
	| builder edge normal2 |
	builder := CFPhysicsChainPolygonManifoldBuilder.
	edge := 1 @ 0.
	normal2 := 0 @ -1.
	self
		assert: (builder
			classifyNormal: -1 @ 0
			edge: edge
			normal0: 0 @ -1
			normal2: normal2
			convex1: true
			convex2: true)
		equals: #skip.
	self
		assert: (builder
			classifyNormal: -1 @ 0
			edge: edge
			normal0: 0 @ 1
			normal2: normal2
			convex1: true
			convex2: true)
		equals: #admit.
	self
		assert: (builder
			classifyNormal: -1 @ 0
			edge: edge
			normal0: 0 @ -1
			normal2: normal2
			convex1: false
			convex2: true)
		equals: #snap.
	^ builder
]
{ #category : 'tests - chains' }
CFPhysicsCollisionTests >> testChainPolygonNormalClassificationMatchesBox2DHeadBranches [
	<gtExample>
	| builder edge normal0 |
	builder := CFPhysicsChainPolygonManifoldBuilder.
	edge := 1 @ 0.
	normal0 := 0 @ -1.
	self
		assert: (builder
			classifyNormal: 1 @ 0
			edge: edge
			normal0: normal0
			normal2: 0 @ -1
			convex1: true
			convex2: true)
		equals: #skip.
	self
		assert: (builder
			classifyNormal: 1 @ 0
			edge: edge
			normal0: normal0
			normal2: 0 @ 1
			convex1: true
			convex2: true)
		equals: #admit.
	self
		assert: (builder
			classifyNormal: 1 @ 0
			edge: edge
			normal0: normal0
			normal2: 0 @ -1
			convex1: true
			convex2: false)
		equals: #snap.
	^ builder
]
{ #category : 'tests - geometry lifecycle' }
CFPhysicsCollisionTests >> testRuntimeGeometryChangeRecreatesContactAndWakesBothBodies [
	<gtExample>
	| owner first second world firstBody secondBody firstResult secondResult oldContact |
	owner := BlElement new size: 200 @ 200; yourself.
	first := BlElement new geometry: BlCircleGeometry new; size: 20 @ 20; yourself.
	second := BlElement new geometry: BlCircleGeometry new; size: 20 @ 20; yourself.
	owner addChildren: { first. second }.
	world := owner physics beWorld.
	world containment disable.
	world gravity: 0 @ 0.
	world owner physics makeChildrenDynamic.
	firstBody := world bodyStateFor: first.
	secondBody := world bodyStateFor: second.
	firstBody position: 0 @ 0.
	secondBody position: 10 @ 0.
	firstResult := world step.
	self assert: firstResult activeContacts size equals: 1.
	oldContact := firstResult activeContacts first.
	firstBody sleep.
	secondBody sleep.
	first geometry: BlRoundedRectangleGeometry new.
	secondResult := world step.
	self assert: firstBody isAwake.
	self assert: secondBody isAwake.
	self assert: secondResult endedContacts size equals: 1.
	self assert: secondResult beganContacts size equals: 1.
	self assert: secondResult activeContacts size equals: 1.
	self assert: secondResult activeContacts first key = oldContact key equals: false.
	^ secondResult
]
{ #category : 'tests - geometry lifecycle' }
CFPhysicsCollisionTests >> testRuntimeGeometryExpansionCreatesContactWithoutBodyMovement [
	<gtExample>
	| owner first second world firstBody secondBody firstResult secondResult |
	owner := BlElement new size: 300 @ 200; yourself.
	first := BlElement new geometry: BlCircleGeometry new; size: 10 @ 10; yourself.
	second := BlElement new geometry: BlCircleGeometry new; size: 10 @ 10; yourself.
	owner addChildren: { first. second }.
	world := owner physics beWorld.
	world containment disable.
	world gravity: 0 @ 0.
	world owner physics makeChildrenDynamic.
	firstBody := world bodyStateFor: first.
	secondBody := world bodyStateFor: second.
	firstBody position: 0 @ 0.
	secondBody position: 30 @ 0.
	firstResult := world step.
	self assert: firstResult activeContacts isEmpty.
	first size: 60 @ 60.
	secondResult := world step.
	self assert: secondResult beganContacts size equals: 1.
	self assert: secondResult activeContacts size equals: 1.
	^ secondResult
]
