Class {
	#name : 'CFPhysicsCleanSlateTests',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Physics-Tests',
	#package : 'BVC-Foundation-Physics-Tests'
}

{ #category : 'examples - step' }
CFPhysicsCleanSlateTests >> softStepUsesSubstepDuration [
	<gtExample>
	| step |
	step := CFPhysicsStep
		timeStep: 0.016
		substeps: 4
		contactHertz: 30.0
		dampingRatio: 10.0.
	self assert: (step substepTime closeTo: 0.004).
	self assert: (step inverseSubstepTime closeTo: 250.0).
	self assert: step massCoefficient > 0.0.
	self assert: step impulseCoefficient > 0.0.
	^ step
]

{ #category : 'examples - contacts' }
CFPhysicsCleanSlateTests >> contactFeatureIdentityIsStructural [
	<gtExample>
	| first second different |
	first := CFPhysicsContactFeatureId
		featureA: #face index: 2 featureB: #vertex index: 1.
	second := CFPhysicsContactFeatureId
		featureA: #face index: 2 featureB: #vertex index: 1.
	different := CFPhysicsContactFeatureId
		featureA: #face index: 3 featureB: #vertex index: 1.
	self assert: first equals: second.
	self assert: first hash equals: second hash.
	self assert: (first = different) not.
	^ first
]

{ #category : 'examples - contacts' }
CFPhysicsCleanSlateTests >> manifoldPreservesImpulsesByFeatureIdentity [
	<gtExample>
	| retainedId oldPoint oldManifold retainedPoint newPoint newManifold |
	retainedId := CFPhysicsContactFeatureId
		featureA: #face index: 0 featureB: #vertex index: 1.
	oldPoint := CFPhysicsManifoldPoint at: 10 @ 20.
	oldPoint
		featureId: retainedId;
		normalImpulse: 7.5;
		tangentImpulse: -1.25.
	oldManifold := CFPhysicsManifold new contactPoints: { oldPoint }; yourself.

	retainedPoint := CFPhysicsManifoldPoint at: 11 @ 20.
	retainedPoint featureId: retainedId.
	newPoint := CFPhysicsManifoldPoint at: 30 @ 20.
	newPoint featureId: (CFPhysicsContactFeatureId
		featureA: #face index: 0 featureB: #vertex index: 2).
	newManifold := CFPhysicsManifold new
		contactPoints: { retainedPoint. newPoint };
		preserveImpulsesFrom: oldManifold;
		yourself.

	self assert: retainedPoint normalImpulse equals: 7.5.
	self assert: retainedPoint tangentImpulse equals: -1.25.
	self assert: newPoint normalImpulse equals: 0.0.
	self assert: newPoint tangentImpulse equals: 0.0.
	^ newManifold
]

{ #category : 'examples - contacts' }
CFPhysicsCleanSlateTests >> manifoldDoesNotUsePositionAsIdentity [
	<gtExample>
	| oldPoint oldManifold newPoint newManifold |
	oldPoint := CFPhysicsManifoldPoint at: 10 @ 20.
	oldPoint
		featureId: (CFPhysicsContactFeatureId
			featureA: #face index: 0 featureB: #vertex index: 0);
		normalImpulse: 4.0.
	oldManifold := CFPhysicsManifold new contactPoints: { oldPoint }; yourself.

	newPoint := CFPhysicsManifoldPoint at: 10 @ 20.
	newPoint featureId: (CFPhysicsContactFeatureId
		featureA: #face index: 1 featureB: #vertex index: 0).
	newManifold := CFPhysicsManifold new
		contactPoints: { newPoint };
		preserveImpulsesFrom: oldManifold;
		yourself.

	self assert: newPoint normalImpulse equals: 0.0.
	^ newManifold
]

{ #category : 'examples - polygon manifolds' }
CFPhysicsCleanSlateTests >> faceContactProducesTwoPoints [
	<gtExample>
	| ground box manifold |
	ground := CFPhysicsPolygonShape rectangleExtent: 100 @ 20.
	box := CFPhysicsPolygonShape rectangleExtent: 60 @ 20.
	manifold := CFPhysicsPolygonManifoldBuilder
		manifoldBetweenShape: ground position: 0 @ 0 rotation: 0
		andShape: box position: 20 @ 15 rotation: 0.
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

{ #category : 'examples - polygon manifolds' }
CFPhysicsCleanSlateTests >> faceContactIdentityPersistsAcrossTangentialMotion [
	<gtExample>
	| ground box first second firstIds secondIds |
	ground := CFPhysicsPolygonShape rectangleExtent: 100 @ 20.
	box := CFPhysicsPolygonShape rectangleExtent: 60 @ 20.
	first := CFPhysicsPolygonManifoldBuilder
		manifoldBetweenShape: ground position: 0 @ 0 rotation: 0
		andShape: box position: 20 @ 15 rotation: 0.
	second := CFPhysicsPolygonManifoldBuilder
		manifoldBetweenShape: ground position: 0 @ 0 rotation: 0
		andShape: box position: 21 @ 15 rotation: 0.
	firstIds := first contactPoints collect: [ :point | point featureId ].
	secondIds := second contactPoints collect: [ :point | point featureId ].
	self assert: firstIds asSet equals: secondIds asSet.
	^ second
]

{ #category : 'examples - polygon manifolds' }
CFPhysicsCleanSlateTests >> roundedPolygonUsesCoreAndRadius [
	<gtExample>
	| ground box manifold |
	ground := CFPhysicsPolygonShape rectangleExtent: 100 @ 20 radius: 5.
	box := CFPhysicsPolygonShape rectangleExtent: 60 @ 20 radius: 5.
	manifold := CFPhysicsPolygonManifoldBuilder
		manifoldBetweenShape: ground position: 0 @ 0 rotation: 0
		andShape: box position: 20 @ 15 rotation: 0.
	self assert: manifold notNil.
	self assert: manifold contactPoints size equals: 2.
	manifold contactPoints do: [ :point |
		self assert: (point separation closeTo: -5.0) ].
	^ manifold
]

{ #category : 'examples - polygon manifolds' }
CFPhysicsCleanSlateTests >> separatedPolygonCoresRespectCombinedRadius [
	<gtExample>
	| first second touching separated |
	first := CFPhysicsPolygonShape rectangleExtent: 100 @ 20 radius: 5.
	second := CFPhysicsPolygonShape rectangleExtent: 60 @ 20 radius: 5.
	touching := CFPhysicsPolygonManifoldBuilder
		manifoldBetweenShape: first position: 0 @ 0 rotation: 0
		andShape: second position: 20 @ 20 rotation: 0.
	separated := CFPhysicsPolygonManifoldBuilder
		manifoldBetweenShape: first position: 0 @ 0 rotation: 0
		andShape: second position: 20 @ 21 rotation: 0.
	self assert: touching notNil.
	self assert: separated isNil.
	^ touching
]

{ #category : 'examples - polygon manifolds' }
CFPhysicsCleanSlateTests >> polygonRotationUsesItsCentre [
	<gtExample>
	| shape vertices |
	shape := CFPhysicsPolygonShape rectangleExtent: 80 @ 30.
	vertices := shape worldVerticesAt: 100 @ 50 rotation: Float pi / 2.0.
	self assert: shape rotationCentre equals: 40.0 @ 15.0.
	self assert: (vertices first closeTo: 155.0 @ 25.0).
	self assert: (vertices second closeTo: 155.0 @ 105.0).
	self assert: (vertices third closeTo: 125.0 @ 105.0).
	self assert: (vertices fourth closeTo: 125.0 @ 25.0).
	^ shape
]

{ #category : 'examples - polygon manifolds' }
CFPhysicsCleanSlateTests >> polygonWorldAndLocalTransformsRoundTripAroundCentre [
	<gtExample>
	| shape localPoint worldPoint recoveredPoint |
	shape := CFPhysicsPolygonShape rectangleExtent: 80 @ 30.
	localPoint := 70 @ 10.
	worldPoint := 100 @ 50
		+ (shape rotate: localPoint around: shape rotationCentre by: Float pi / 3.0).
	recoveredPoint := shape
		localPointForWorldPoint: worldPoint
		position: 100 @ 50
		rotation: Float pi / 3.0.
	self assert: (recoveredPoint closeTo: localPoint).
	^ shape
]

{ #category : 'examples - Bloc geometry' }
CFPhysicsCleanSlateTests >> blocPolygonShapeUsesElementCentreAsRotationCentre [
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

{ #category : 'examples - Bloc geometry' }
CFPhysicsCleanSlateTests >> rectangleElementProducesPolygonShape [
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

{ #category : 'examples - Bloc geometry' }
CFPhysicsCleanSlateTests >> roundedRectangleElementProducesInsetCoreAndRadius [
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

{ #category : 'examples - Bloc geometry' }
CFPhysicsCleanSlateTests >> normalizedPolygonElementUsesItsRenderedExtent [
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

{ #category : 'examples - Bloc geometry' }
CFPhysicsCleanSlateTests >> BlocGeometryRoutesToPolygonManifold [
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
	manifold := CFPhysicsBlocManifoldBuilder
		manifoldBetweenShapeState: ground position: 0 @ 0 rotation: 0
		andShapeState: box position: 20 @ 15 rotation: 0.
	self assert: manifold notNil.
	self assert: manifold contactPoints size equals: 2.
	self assert: manifold normal equals: 0 @ 1.
	^ manifold
]

{ #category : 'examples - Bloc geometry' }
CFPhysicsCleanSlateTests >> circleDoesNotPretendToBeAPolygon [
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

{ #category : 'examples - contact pipeline' }
CFPhysicsCleanSlateTests >> contactPipelineOrdersPairsDeterministically [
	<gtExample>
	| first second third pairs |
	first := self cleanSlateBodyWithSequence: 1.
	second := self cleanSlateBodyWithSequence: 2.
	third := self cleanSlateBodyWithSequence: 3.
	pairs := {
		CFPhysicsPair first: third second: first.
		CFPhysicsPair first: third second: second.
		CFPhysicsPair first: second second: first }
		sorted: [ :left :right | left comesBefore: right ].
	self assert: (pairs collect: [ :pair | { pair firstBody sequence. pair secondBody sequence } ])
		equals: { { 1. 2 }. { 1. 3 }. { 2. 3 } }.
	^ pairs
]

{ #category : 'examples - contact pipeline' }
CFPhysicsCleanSlateTests >> contactPipelineReportsBeginContinueAndEnd [
	<gtExample>
	| first second pair manifold updater firstBatch secondBatch thirdBatch |
	first := self cleanSlateBodyWithSequence: 1.
	second := self cleanSlateBodyWithSequence: 2.
	pair := CFPhysicsPair first: first second: second.
	manifold := self cleanSlateManifoldWithFeatureIndex: 1.
	updater := CFPhysicsContactUpdater manifoldBuilder: [ :each | manifold ].
	firstBatch := updater updatePairs: { pair } fromContacts: #().
	self assert: firstBatch beganContacts size equals: 1.
	self assert: firstBatch continuedContacts isEmpty.
	secondBatch := updater updatePairs: { pair } fromContacts: firstBatch activeContacts.
	self assert: secondBatch beganContacts isEmpty.
	self assert: secondBatch continuedContacts size equals: 1.
	thirdBatch := updater updatePairs: #() fromContacts: secondBatch activeContacts.
	self assert: thirdBatch activeContacts isEmpty.
	self assert: thirdBatch endedContacts size equals: 1.
	^ thirdBatch
]

{ #category : 'examples - contact pipeline' }
CFPhysicsCleanSlateTests >> contactPipelinePersistsImpulsesByFeatureIdentity [
	<gtExample>
	| first second pair oldManifold newManifold updater initial next oldPoint newPoint |
	first := self cleanSlateBodyWithSequence: 1.
	second := self cleanSlateBodyWithSequence: 2.
	pair := CFPhysicsPair first: first second: second.
	oldManifold := self cleanSlateManifoldWithFeatureIndex: 1.
	oldPoint := oldManifold contactPoints first.
	oldPoint normalImpulse: 7.0; tangentImpulse: 2.0.
	updater := CFPhysicsContactUpdater manifoldBuilder: [ :each | oldManifold ].
	initial := updater updatePairs: { pair } fromContacts: #().
	newManifold := self cleanSlateManifoldWithFeatureIndex: 1.
	updater := CFPhysicsContactUpdater manifoldBuilder: [ :each | newManifold ].
	next := updater updatePairs: { pair } fromContacts: initial activeContacts.
	newPoint := next activeContacts first manifold contactPoints first.
	self assert: newPoint normalImpulse equals: 7.0.
	self assert: newPoint tangentImpulse equals: 2.0.
	^ next
]

{ #category : 'examples - contact pipeline' }
CFPhysicsCleanSlateTests >> sensorContactClearsRetainedImpulses [
	<gtExample>
	| first second pair oldManifold newManifold updater initial next point |
	first := self cleanSlateBodyWithSequence: 1.
	second := self cleanSlateBodyWithSequence: 2.
	pair := CFPhysicsPair first: first second: second.
	oldManifold := self cleanSlateManifoldWithFeatureIndex: 1.
	oldManifold contactPoints first
		normalImpulse: 7.0;
		tangentImpulse: 2.0.
	updater := CFPhysicsContactUpdater manifoldBuilder: [ :each | oldManifold ].
	initial := updater updatePairs: { pair } fromContacts: #().

	second beSensor.
	newManifold := self cleanSlateManifoldWithFeatureIndex: 1.
	updater := CFPhysicsContactUpdater manifoldBuilder: [ :each | newManifold ].
	next := updater updatePairs: { pair } fromContacts: initial activeContacts.
	point := next activeContacts first manifold contactPoints first.

	self assert: point normalImpulse equals: 0.0.
	self assert: point tangentImpulse equals: 0.0.
	^ next
]

{ #category : 'examples - constraints' }
CFPhysicsCleanSlateTests >> constraintBuilderPreparesSolverData [
	<gtExample>
	| first second pair manifold contact bodyStates constraints constraint point |
	first := self cleanSlateBodyWithSequence: 1.
	first beStatic.
	second := self cleanSlateBodyWithSequence: 2.
	pair := CFPhysicsPair first: first second: second.
	manifold := self cleanSlateManifoldWithFeatureIndex: 1.
	contact := CFPhysicsContact pair: pair manifold: manifold.
	bodyStates := IdentityDictionary new
		at: first put: (CFPhysicsBodyStepState on: first);
		at: second put: (CFPhysicsBodyStepState on: second);
		yourself.
	constraints := CFPhysicsConstraintBuilder new
		constraintsFrom: { contact }
		bodyStates: bodyStates.
	constraint := constraints first.
	point := constraint points first.
	self assert: constraint contact == contact.
	self assert: constraint firstBody == first.
	self assert: constraint secondBody == second.
	self assert: constraint bodyStateA == (bodyStates at: first).
	self assert: constraint bodyStateB == (bodyStates at: second).
	self assert: constraint normal equals: 0 @ 1.
	self assert: constraint tangent equals: -1 @ 0.
	self assert: point featureId equals: manifold contactPoints first featureId.
	self assert: point normalMass > 0.0.
	self assert: point tangentMass > 0.0.
	self assert: point baseSeparation equals: -1.0.
	^ constraint
]

{ #category : 'examples - constraints' }
CFPhysicsCleanSlateTests >> preparedConstraintWritesSolvedImpulsesBackExplicitly [
	<gtExample>
	| constraint manifoldPoint preparedPoint |
	constraint := self constraintBuilderPreparesSolverData.
	manifoldPoint := constraint contact manifold contactPoints first.
	preparedPoint := constraint points first.
	preparedPoint normalImpulse: 4.0; tangentImpulse: 1.5.
	self assert: manifoldPoint normalImpulse equals: 0.0.
	self assert: manifoldPoint tangentImpulse equals: 0.0.
	constraint writeImpulsesBack.
	self assert: manifoldPoint normalImpulse equals: 4.0.
	self assert: manifoldPoint tangentImpulse equals: 1.5.
	^ constraint
]

{ #category : 'private - contact pipeline' }
CFPhysicsCleanSlateTests >> cleanSlateBodyWithSequence: anInteger [
	^ (CFPhysicsBody element: (BlElement new size: 10 @ 10; yourself) world: nil)
		sequence: anInteger;
		yourself
]

{ #category : 'private - contact pipeline' }
CFPhysicsCleanSlateTests >> cleanSlateManifoldWithFeatureIndex: anInteger [
	| point manifold |
	point := CFPhysicsManifoldPoint at: 5 @ 5.
	point
		featureId: (CFPhysicsContactFeatureId featureA: #face index: 0 featureB: #vertex index: anInteger);
		localAnchorA: 5 @ 5;
		localAnchorB: 5 @ 0;
		separation: -1.0.
	manifold := CFPhysicsManifold normal: 0 @ 1 penetration: 1.0.
	manifold contactPoints: { point }.
	^ manifold
]

{ #category : 'examples - pair discovery' }
CFPhysicsCleanSlateTests >> pairFinderReturnsOverlappingPairsInSequenceOrder [
	<gtExample>
	| first second third pairs |
	first := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self cleanSlateBodyWithSequence: 2 position: 15 @ 0 extent: 20 @ 20.
	third := self cleanSlateBodyWithSequence: 3 position: 10 @ 10 extent: 20 @ 20.
	pairs := CFPhysicsPairFinder new pairsAmong: { third. first. second }.
	self assert: (pairs collect: [ :pair | { pair firstBody sequence. pair secondBody sequence } ])
		equals: { { 1. 2 }. { 1. 3 }. { 2. 3 } }.
	^ pairs
]

{ #category : 'examples - pair discovery' }
CFPhysicsCleanSlateTests >> pairFinderRejectsSeparatedBodies [
	<gtExample>
	| first second pairs |
	first := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self cleanSlateBodyWithSequence: 2 position: 30 @ 0 extent: 20 @ 20.
	pairs := CFPhysicsPairFinder new pairsAmong: { first. second }.
	self assert: pairs isEmpty.
	^ pairs
]

{ #category : 'examples - pair discovery' }
CFPhysicsCleanSlateTests >> pairFinderRejectsStaticStaticPairs [
	<gtExample>
	| first second pairs |
	first := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self cleanSlateBodyWithSequence: 2 position: 10 @ 0 extent: 20 @ 20.
	first beStatic.
	second beStatic.
	pairs := CFPhysicsPairFinder new pairsAmong: { first. second }.
	self assert: pairs isEmpty.
	^ pairs
]

{ #category : 'examples - contact pipeline' }
CFPhysicsCleanSlateTests >> contactPipelineFeedsDiscoveredPairsThroughBlocManifolds [
	<gtExample>
	| ground box pipeline firstResult secondResult |
	ground := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 100 @ 20.
	ground beStatic.
	box := self cleanSlateBodyWithSequence: 2 position: 20 @ 15 extent: 60 @ 20.
	pipeline := CFPhysicsContactPipeline manifoldBuilder: [ :pair |
		CFPhysicsBlocManifoldBuilder
			manifoldBetweenBody: pair firstBody
			andBody: pair secondBody ].
	firstResult := pipeline updateBodies: { box. ground } fromContacts: #().
	self assert: firstResult pairs size equals: 1.
	self assert: firstResult beganContacts size equals: 1.
	self assert: firstResult activeContacts first manifold contactPoints size equals: 2.
	box position: 20 @ 50.
	secondResult := pipeline updateBodies: { ground. box } fromContacts: firstResult activeContacts.
	self assert: secondResult pairs isEmpty.
	self assert: secondResult activeContacts isEmpty.
	self assert: secondResult endedContacts size equals: 1.
	^ secondResult
]

{ #category : 'private - pair discovery' }
CFPhysicsCleanSlateTests >> cleanSlateBodyWithSequence: anInteger position: aPoint extent: anExtent [
	^ (CFPhysicsBody
		element: (BlElement new
			geometry: BlRoundedRectangleGeometry new;
			size: anExtent;
			yourself)
		world: nil)
		sequence: anInteger;
		position: aPoint;
		yourself
]

{ #category : 'examples - step pipeline' }
CFPhysicsCleanSlateTests >> stepPipelineExposesTheComposedStep [
	<gtExample>
	| ground box step pipeline result |
	ground := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 100 @ 20.
	ground beStatic.
	box := self cleanSlateBodyWithSequence: 2 position: 20 @ 15 extent: 60 @ 20.
	step := CFPhysicsStep
		timeStep: 0.016
		substeps: 4
		contactHertz: 30.0
		dampingRatio: 10.0.
	pipeline := CFPhysicsStepPipeline manifoldBuilder: [ :pair |
		CFPhysicsBlocManifoldBuilder
			manifoldBetweenBody: pair firstBody
			andBody: pair secondBody ].
	result := pipeline
		stepBodies: { box. ground }
		fromContacts: #()
		step: step
		gravity: 0 @ 0
		restitutionThreshold: 1.0.
	self assert: result step == step.
	self assert: (result bodies collect: #sequence) equals: #(1 2).
	self assert: result pairs size equals: 1.
	self assert: result beganContacts size equals: 1.
	self assert: result activeContacts size equals: 1.
	self assert: result bodyStates size equals: 2.
	self assert: result constraints size equals: 1.
	self assert: result constraints first contact == result activeContacts first.
	self assert: result solver notNil.
	^ result
]

{ #category : 'examples - step pipeline' }
CFPhysicsCleanSlateTests >> stepPipelineProjectsOverlappingBodiesApart [
	<gtExample>
	| ground box step pipeline result manifold |
	ground := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 100 @ 20.
	ground beStatic.
	box := self cleanSlateBodyWithSequence: 2 position: 20 @ 15 extent: 60 @ 20.
	step := CFPhysicsStep
		timeStep: 0.016
		substeps: 4
		contactHertz: 30.0
		dampingRatio: 10.0.
	pipeline := CFPhysicsStepPipeline manifoldBuilder: [ :pair |
		CFPhysicsBlocManifoldBuilder
			manifoldBetweenBody: pair firstBody
			andBody: pair secondBody ].
	result := pipeline
		stepBodies: { box. ground }
		fromContacts: #()
		step: step
		gravity: 0 @ 0
		restitutionThreshold: 1.0.
	manifold := CFPhysicsBlocManifoldBuilder
		manifoldBetweenBody: ground
		andBody: box.
	self assert: result activeContacts size equals: 1.
	self assert: box position y > 15.0.
	self assert: manifold notNil.
	self assert: manifold contactPoints first separation > -5.0.
	^ result
]

{ #category : 'examples - step pipeline' }
CFPhysicsCleanSlateTests >> stepPipelineCarriesActiveContactsIntoTheNextStep [
	<gtExample>
	| firstResult ground box step pipeline secondResult |
	firstResult := self stepPipelineExposesTheComposedStep.
	ground := firstResult bodies first.
	box := firstResult bodies second.
	step := CFPhysicsStep
		timeStep: 0.016
		substeps: 4
		contactHertz: 30.0
		dampingRatio: 10.0.
	pipeline := CFPhysicsStepPipeline manifoldBuilder: [ :pair |
		CFPhysicsBlocManifoldBuilder
			manifoldBetweenBody: pair firstBody
			andBody: pair secondBody ].
	secondResult := pipeline
		stepBodies: { box. ground }
		fromContacts: firstResult activeContacts
		step: step
		gravity: 0 @ 0
		restitutionThreshold: 1.0.
	self assert: secondResult beganContacts isEmpty.
	self assert: secondResult continuedContacts size equals: 1.
	self assert: secondResult activeContacts size equals: 1.
	^ secondResult
]

{ #category : 'examples - world cutover' }
CFPhysicsCleanSlateTests >> worldDelegatesOneStepToTheExplicitPipeline [
	<gtExample>
	| owner ground box world groundBody boxBody result |
	owner := BlElement new.
	ground := BlElement new size: 100 @ 20; yourself.
	box := BlElement new size: 60 @ 20; yourself.
	owner addChild: ground.
	owner addChild: box.
	world := owner physics beWorld.
	world
		gravity: 0 @ 0;
		synchroniseMembership.
	groundBody := world bodyStateFor: ground.
	boxBody := world bodyStateFor: box.
	groundBody
		position: 0 @ 0;
		beStatic.
	boxBody position: 20 @ 15.
	result := world step.
	self assert: result == world lastStepResult.
	self assert: result bodies equals: world bodyStatesInOrder.
	self assert: result activeContacts size equals: 1.
	self assert: world contacts equals: result activeContacts.
	self assert: result step substepCount equals: world substepCount.
	^ world
]

{ #category : 'examples - world cutover' }
CFPhysicsCleanSlateTests >> worldCarriesActiveContactsExplicitlyBetweenSteps [
	<gtExample>
	| world firstResult secondResult |
	world := self worldDelegatesOneStepToTheExplicitPipeline.
	firstResult := world lastStepResult.
	secondResult := world step.
	self assert: firstResult beganContacts size equals: 1.
	self assert: secondResult beganContacts isEmpty.
	self assert: secondResult continuedContacts size equals: 1.
	self assert: world activeContacts equals: secondResult activeContacts.
	^ secondResult
]

{ #category : 'examples - islands' }
CFPhysicsCleanSlateTests >> islandBuilderSeparatesDisconnectedDynamicGroups [
	<gtExample>
	| first second third fourth constraints islands |
	first := self cleanSlateBodyWithSequence: 1.
	second := self cleanSlateBodyWithSequence: 2.
	third := self cleanSlateBodyWithSequence: 3.
	fourth := self cleanSlateBodyWithSequence: 4.
	constraints := {
		self cleanSlateConstraintBetween: first and: second.
		self cleanSlateConstraintBetween: third and: fourth }.
	islands := CFPhysicsIslandBuilder new
		islandsFromBodies: { fourth. second. third. first }
		constraints: constraints.
	self assert: islands size equals: 2.
	self assert: (islands first dynamicBodies collect: #sequence) equals: #(1 2).
	self assert: (islands second dynamicBodies collect: #sequence) equals: #(3 4).
	self assert: islands first constraints size equals: 1.
	self assert: islands second constraints size equals: 1.
	^ islands
]

{ #category : 'examples - islands' }
CFPhysicsCleanSlateTests >> staticBodyDoesNotBridgeDynamicIslands [
	<gtExample>
	| first ground second constraints islands |
	first := self cleanSlateBodyWithSequence: 1.
	ground := self cleanSlateBodyWithSequence: 2.
	ground beStatic.
	second := self cleanSlateBodyWithSequence: 3.
	constraints := {
		self cleanSlateConstraintBetween: first and: ground.
		self cleanSlateConstraintBetween: ground and: second }.
	islands := CFPhysicsIslandBuilder new
		islandsFromBodies: { second. ground. first }
		constraints: constraints.
	self assert: islands size equals: 2.
	self assert: (islands first dynamicBodies collect: #sequence) equals: #(1).
	self assert: (islands second dynamicBodies collect: #sequence) equals: #(3).
	self assert: islands first staticBodies equals: { ground }.
	self assert: islands second staticBodies equals: { ground }.
	self assert: islands first constraints size equals: 1.
	self assert: islands second constraints size equals: 1.
	^ islands
]

{ #category : 'examples - islands' }
CFPhysicsCleanSlateTests >> stepPipelineSolvesExplicitIslands [
	<gtExample>
	| result |
	result := self stepPipelineExposesTheComposedStep.
	self assert: result islands size equals: 1.
	self assert: result islands first constraints equals: result constraints.
	self assert: result solver islands equals: result islands.
	self assert: result solver softStepSolvers size equals: result islands size.
	^ result
]

{ #category : 'private - islands' }
CFPhysicsCleanSlateTests >> cleanSlateConstraintBetween: firstBody and: secondBody [
	| contact |
	contact := CFPhysicsContact
		pair: (CFPhysicsPair first: firstBody second: secondBody)
		manifold: (self cleanSlateManifoldWithFeatureIndex: secondBody sequence).
	^ CFPhysicsPreparedConstraint new
		contact: contact;
		points: #();
		yourself
]

{ #category : 'examples - island sleeping' }
CFPhysicsCleanSlateTests >> islandWakePropagatesAcrossConnectedDynamicBodies [
	<gtExample>
	| first second island stage decisions |
	first := self cleanSlateBodyWithSequence: 1.
	second := self cleanSlateBodyWithSequence: 2.
	second sleep.
	island := CFPhysicsIsland new
		addBody: first;
		addBody: second;
		yourself.
	stage := CFPhysicsIslandSleepStage new.
	stage propagateWakeAcross: { island }.
	decisions := stage
		updateIslands: { island }
		bodyStates: (IdentityDictionary new
			at: first put: (CFPhysicsBodyStepState on: first);
			at: second put: (CFPhysicsBodyStepState on: second);
			yourself)
		elapsed: 0.0.
	self assert: first isAwake.
	self assert: second isAwake.
	self assert: decisions first wokeBodies equals: { second }.
	^ decisions first
]

{ #category : 'examples - island sleeping' }
CFPhysicsCleanSlateTests >> islandSleepsAsOneDecision [
	<gtExample>
	| first second island stage configuration bodyStates firstDecision secondDecision |
	first := self cleanSlateBodyWithSequence: 1.
	second := self cleanSlateBodyWithSequence: 2.
	island := CFPhysicsIsland new
		addBody: first;
		addBody: second;
		yourself.
	configuration := CFPhysicsSleepConfiguration standard
		linearVelocityThreshold: 1.0;
		angularVelocityThreshold: 1.0;
		timeToSleep: 0.02;
		yourself.
	stage := CFPhysicsIslandSleepStage new configuration: configuration; yourself.
	bodyStates := IdentityDictionary new
		at: first put: (CFPhysicsBodyStepState on: first);
		at: second put: (CFPhysicsBodyStepState on: second);
		yourself.
	stage propagateWakeAcross: { island }.
	firstDecision := (stage updateIslands: { island } bodyStates: bodyStates elapsed: 0.01) first.
	self assert: firstDecision eligible.
	self assert: firstDecision slept not.
	self assert: first isAwake.
	self assert: second isAwake.
	stage propagateWakeAcross: { island }.
	secondDecision := (stage updateIslands: { island } bodyStates: bodyStates elapsed: 0.01) first.
	self assert: secondDecision eligible.
	self assert: secondDecision slept.
	self assert: first isSleeping.
	self assert: second isSleeping.
	^ secondDecision
]

{ #category : 'examples - island sleeping' }
CFPhysicsCleanSlateTests >> movingMemberKeepsTheWholeIslandAwake [
	<gtExample>
	| first second island stage bodyStates decision |
	first := self cleanSlateBodyWithSequence: 1.
	second := self cleanSlateBodyWithSequence: 2.
	first advanceSleepTimeBy: 0.25.
	second advanceSleepTimeBy: 0.25.
	second velocity: 10 @ 0.
	island := CFPhysicsIsland new
		addBody: first;
		addBody: second;
		yourself.
	stage := CFPhysicsIslandSleepStage new.
	bodyStates := IdentityDictionary new
		at: first put: (CFPhysicsBodyStepState on: first);
		at: second put: (CFPhysicsBodyStepState on: second);
		yourself.
	stage propagateWakeAcross: { island }.
	decision := (stage updateIslands: { island } bodyStates: bodyStates elapsed: 0.016) first.
	self assert: decision eligible not.
	self assert: first isAwake.
	self assert: second isAwake.
	self assert: first sleepTime equals: 0.0.
	self assert: second sleepTime equals: 0.0.
	^ decision
]


{ #category : 'examples - island sleeping' }
CFPhysicsCleanSlateTests >> positionCorrectionKeepsAnIslandAwake [
	<gtExample>
	| body island stage configuration state decision |
	body := self cleanSlateBodyWithSequence: 1.
	island := CFPhysicsIsland new addBody: body; yourself.
	configuration := CFPhysicsSleepConfiguration standard
		linearVelocityThreshold: 1.0;
		angularVelocityThreshold: 1.0;
		timeToSleep: 0.01;
		yourself.
	stage := CFPhysicsIslandSleepStage new configuration: configuration; yourself.
	state := CFPhysicsBodyStepState on: body.
	state translateBy: 1 @ 0.
	stage propagateWakeAcross: { island }.
	decision := (stage
		updateIslands: { island }
		bodyStates: (IdentityDictionary new at: body put: state; yourself)
		elapsed: 0.02) first.
	self assert: decision eligible not.
	self assert: body isAwake.
	self assert: body sleepTime equals: 0.0.
	^ decision
]

{ #category : 'examples - island sleeping' }
CFPhysicsCleanSlateTests >> smallPositionCorrectionMayAccumulateSleepTime [
	<gtExample>
	| body island stage configuration state decision |
	body := self cleanSlateBodyWithSequence: 1.
	island := CFPhysicsIsland new addBody: body; yourself.
	configuration := CFPhysicsSleepConfiguration standard
		linearVelocityThreshold: 1.0;
		angularVelocityThreshold: 1.0;
		timeToSleep: 1.0;
		yourself.
	stage := CFPhysicsIslandSleepStage new configuration: configuration; yourself.
	state := CFPhysicsBodyStepState on: body.
	state translateBy: 0.01 @ 0.
	stage propagateWakeAcross: { island }.
	decision := (stage
		updateIslands: { island }
		bodyStates: (IdentityDictionary new at: body put: state; yourself)
		elapsed: 0.02) first.
	self assert: decision eligible.
	self assert: decision slept not.
	self assert: (body sleepTime closeTo: 0.02).
	^ decision
]


{ #category : 'examples - island sleeping' }
CFPhysicsCleanSlateTests >> endingAContactWakesBothBodies [
	<gtExample>
	| first second pair manifold previousContact batch stage result |
	first := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self cleanSlateBodyWithSequence: 2 position: 10 @ 0 extent: 20 @ 20.
	pair := CFPhysicsPair first: first second: second.
	manifold := self cleanSlateManifoldWithFeatureIndex: 1.
	previousContact := CFPhysicsContact pair: pair manifold: manifold.
	first sleep.
	second sleep.
	batch := CFPhysicsContactUpdater new
		updatePairs: #()
		includingImpactContacts: #()
		fromContacts: { previousContact }.
	stage := CFPhysicsContactUpdateStage new.
	stage wakeBodiesForEndedContacts: batch endedContacts.
	result := batch endedContacts first.
	self assert: result ended.
	self assert: first isAwake.
	self assert: second isAwake.
	^ result
]

{ #category : 'examples - island sleeping' }
CFPhysicsCleanSlateTests >> bodyMayOptOutOfSleeping [
	<gtExample>
	| body |
	body := self cleanSlateBodyWithSequence: 1.
	body preventSleeping.
	body sleep.
	self assert: body allowsSleeping not.
	self assert: body isAwake.
	self assert: body isSleeping not.
	body allowSleeping.
	body sleep.
	self assert: body allowsSleeping.
	self assert: body isSleeping.
	^ body
]

{ #category : 'examples - island sleeping' }
CFPhysicsCleanSlateTests >> impulseWakesSleepingBody [
	<gtExample>
	| body centre |
	body := self cleanSlateBodyWithSequence: 1.
	body sleep.
	centre := body centre.
	body applyImpulse: 10 @ 0 atWorldPoint: centre.
	self assert: body isAwake.
	self assert: body velocity equals: 10 @ 0 * body inverseMass.
	^ body
]

{ #category : 'examples - island sleeping' }
CFPhysicsCleanSlateTests >> bodyThatPreventsSleepingKeepsItsIslandAwake [
	<gtExample>
	| first second island stage configuration bodyStates decision |
	first := self cleanSlateBodyWithSequence: 1.
	second := self cleanSlateBodyWithSequence: 2.
	second preventSleeping.
	island := CFPhysicsIsland new
		addBody: first;
		addBody: second;
		yourself.
	configuration := CFPhysicsSleepConfiguration standard
		linearVelocityThreshold: 1.0;
		angularVelocityThreshold: 1.0;
		timeToSleep: 0.01;
		yourself.
	stage := CFPhysicsIslandSleepStage new configuration: configuration; yourself.
	bodyStates := IdentityDictionary new
		at: first put: (CFPhysicsBodyStepState on: first);
		at: second put: (CFPhysicsBodyStepState on: second);
		yourself.
	stage propagateWakeAcross: { island }.
	decision := (stage updateIslands: { island } bodyStates: bodyStates elapsed: 0.02) first.
	self assert: decision eligible not.
	self assert: decision slept not.
	self assert: first isAwake.
	self assert: second isAwake.
	self assert: first sleepTime equals: 0.0.
	self assert: second sleepTime equals: 0.0.
	^ decision
]

{ #category : 'examples - island sleeping' }
CFPhysicsCleanSlateTests >> stepPipelineExposesIslandSleepDecisions [
	<gtExample>
	| result |
	result := self stepPipelineExposesTheComposedStep.
	self assert: result sleepDecisions size equals: result islands size.
	self assert: result sleepDecisions first island == result islands first.
	^ result sleepDecisions
]

{ #category : 'examples - contact events' }
CFPhysicsCleanSlateTests >> contactEventStagePublishesLifecycleEvents [
	<gtExample>
	| first second pair manifold beganContact endedContact batch result events |
	first := self cleanSlateBodyWithSequence: 1.
	second := self cleanSlateBodyWithSequence: 2.
	pair := CFPhysicsPair first: first second: second.
	manifold := self cleanSlateManifoldWithFeatureIndex: 1.
	beganContact := CFPhysicsContact pair: pair manifold: manifold.
	endedContact := beganContact copyForUpdate.
	endedContact updateWith: nil.
	batch := CFPhysicsContactUpdateBatch
		active: { beganContact }
		began: { beganContact }
		continued: #()
		ended: { endedContact }.
	result := CFPhysicsContactPipelineResult pairs: { pair } contactBatch: batch.
	events := CFPhysicsContactEventStage new eventsFrom: result.
	self assert: events size equals: 2.
	self assert: events first began.
	self assert: events second ended.
	self assert: events first manifold == manifold.
	self assert: events second manifold == manifold.
	^ events
]

{ #category : 'examples - contact events' }
CFPhysicsCleanSlateTests >> continuedContactsDoNotPublishLifecycleEvents [
	<gtExample>
	| first second pair contact batch result events |
	first := self cleanSlateBodyWithSequence: 1.
	second := self cleanSlateBodyWithSequence: 2.
	pair := CFPhysicsPair first: first second: second.
	contact := CFPhysicsContact pair: pair manifold: (self cleanSlateManifoldWithFeatureIndex: 1).
	contact := contact copyForUpdate
		updateWith: (self cleanSlateManifoldWithFeatureIndex: 1);
		yourself.
	batch := CFPhysicsContactUpdateBatch
		active: { contact }
		began: #()
		continued: { contact }
		ended: #().
	result := CFPhysicsContactPipelineResult pairs: { pair } contactBatch: batch.
	events := CFPhysicsContactEventStage new eventsFrom: result.
	self assert: events isEmpty.
	^ events
]

{ #category : 'examples - contact events' }
CFPhysicsCleanSlateTests >> stepPipelineExposesContactEvents [
	<gtExample>
	| result |
	result := self stepPipelineExposesTheComposedStep.
	self assert: result contactEvents size equals: result beganContacts size + result endedContacts size.
	self assert: result contactBeganEvents size equals: result beganContacts size.
	self assert: result contactEndedEvents size equals: result endedContacts size.
	^ result contactEvents
]

{ #category : 'examples - step stages' }
CFPhysicsCleanSlateTests >> stepPipelineExecutesExplicitOrderedStages [
	<gtExample>
	| result expectedTypes |
	result := self stepPipelineExposesTheComposedStep.
	expectedTypes := {
		CFPhysicsBodyStateCaptureStage.
		CFPhysicsVelocityIntegrationStage.
		CFPhysicsPairFinderStage.
		CFPhysicsContactUpdateStage.
		CFPhysicsConstraintPreparationStage.
		CFPhysicsIslandBuilderStage.
		CFPhysicsIslandWakeStage.
		CFPhysicsIslandSolverStage.
		CFPhysicsPostSolveStage.
		CFPhysicsContinuousStepStage.
		CFPhysicsIslandSleepingStage.
		CFPhysicsBodyCommitStage.
		CFPhysicsContactEventsStage }.
	self assert: result executedStages size equals: expectedTypes size.
	expectedTypes withIndexDo: [ :stageType :index |
		self assert: ((result executedStages at: index) isKindOf: stageType) ].
	self assert: result stageExecutions first output == result bodyStates.
	self assert: result stageExecutions second output == result bodyStates.
	self assert: result stageExecutions third output equals: result pairs.
	self assert: result stageExecutions fourth output == result contactResult.
	self assert: result stageExecutions fifth output equals: result constraints.
	self assert: result stageExecutions sixth output equals: result islands.
	self assert: (result stageExecutions at: 8) output == result solver.
	self assert: (result stageExecutions at: 9) output contactResults equals: result contactSolveResults.
	self assert: (result stageExecutions at: 9) output hitEvents equals: result hitEvents.
	self assert: (result stageExecutions at: 13) output equals: result contactEvents.
	^ result stageExecutions
]

{ #category : 'examples - step stages' }
CFPhysicsCleanSlateTests >> stepPipelineExposesReplaceableStageList [
	<gtExample>
	| pipeline stages |
	pipeline := CFPhysicsStepPipeline manifoldBuilder: [ :pair |
		CFPhysicsBlocManifoldBuilder
			manifoldBetweenBody: pair firstBody
			andBody: pair secondBody ].
	stages := pipeline stages.
	self assert: stages size equals: 13.
	self assert: stages first class equals: CFPhysicsBodyStateCaptureStage.
	self assert: stages second class equals: CFPhysicsVelocityIntegrationStage.
	self assert: stages third class equals: CFPhysicsPairFinderStage.
	self assert: (stages at: 10) class equals: CFPhysicsContinuousStepStage.
	self assert: (stages at: 12) class equals: CFPhysicsBodyCommitStage.
	self assert: stages last class equals: CFPhysicsContactEventsStage.
	self assert: (pipeline stageOfType: CFPhysicsConstraintPreparationStage) == (stages at: 5).
	self assert: pipeline sleepConfiguration == (pipeline stageOfType: CFPhysicsIslandSleepingStage) configuration.
	^ pipeline
]


{ #category : 'examples - post solve' }
CFPhysicsCleanSlateTests >> postSolveCollectorCapturesSolvedImpulses [
	<gtExample>
	| result solveResult pointResult constraint |
	result := self stepPipelineExposesTheComposedStep.
	self assert: result contactSolveResults size equals: result constraints size.
	solveResult := result contactSolveResults first.
	constraint := result constraints first.
	self assert: solveResult contact == constraint contact.
	self assert: solveResult normal equals: constraint normal.
	self assert: solveResult points size equals: constraint points size.
	pointResult := solveResult points first.
	self assert: pointResult featureId equals: constraint points first featureId.
	self assert: pointResult normalImpulse equals: constraint points first normalImpulse.
	self assert: pointResult tangentImpulse equals: constraint points first tangentImpulse.
	^ solveResult
]

{ #category : 'examples - post solve' }
CFPhysicsCleanSlateTests >> hitEventsAreDerivedAfterSolving [
	<gtExample>
	| result stage |
	stage := CFPhysicsPostSolveStage new.
	stage hitEventThreshold: 0.0.
	result := self stepPipelineExposesTheComposedStep.
	stage executeOn: result.
	self assert: (result hitEvents allSatisfy: [ :event |
		event normalImpulse > 0.0 and: [ event approachSpeed > 0.0 ] ]).
	self assert: (result hitEvents allSatisfy: [ :event |
		result activeContacts includes: event contact ]).
	^ result hitEvents
]

{ #category : 'examples - post solve' }
CFPhysicsCleanSlateTests >> hitEventThresholdSuppressesSmallApproaches [
	<gtExample>
	| result stage |
	result := self stepPipelineExposesTheComposedStep.
	stage := CFPhysicsPostSolveStage new.
	stage hitEventThreshold: 1.0e100.
	stage executeOn: result.
	self assert: result hitEvents isEmpty.
	^ result hitEvents
]

{ #category : 'examples - post solve' }
CFPhysicsCleanSlateTests >> stepPipelineExposesPostSolveStage [
	<gtExample>
	| result execution |
	result := self stepPipelineExposesTheComposedStep.
	execution := result executionForStageType: CFPhysicsPostSolveStage.
	self assert: execution notNil.
	self assert: execution output contactResults equals: result contactSolveResults.
	self assert: execution output hitEvents equals: result hitEvents.
	^ execution
]


{ #category : 'examples - sensors' }
CFPhysicsCleanSlateTests >> sensorContactParticipatesInLifecycleButNotSolving [
	<gtExample>
	| ground sensor step pipeline result |
	ground := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 100 @ 20.
	ground beStatic.
	sensor := self cleanSlateBodyWithSequence: 2 position: 20 @ 15 extent: 60 @ 20.
	sensor beSensor.
	step := CFPhysicsStep
		timeStep: 0.016
		substeps: 4
		contactHertz: 30.0
		dampingRatio: 10.0.
	pipeline := CFPhysicsStepPipeline manifoldBuilder: [ :pair |
		CFPhysicsBlocManifoldBuilder
			manifoldBetweenBody: pair firstBody
			andBody: pair secondBody ].
	result := pipeline
		stepBodies: { sensor. ground }
		fromContacts: #()
		step: step
		gravity: 0 @ 0
		restitutionThreshold: 1.0.
	self assert: result activeContacts size equals: 1.
	self assert: result activeContacts first isSensor.
	self assert: result beganContacts size equals: 1.
	self assert: result constraints isEmpty.
	self assert: result contactSolveResults isEmpty.
	self assert: result hitEvents isEmpty.
	self assert: result contactBeganEvents size equals: 1.
	self assert: result contactBeganEvents first isSensor.
	^ result
]

{ #category : 'examples - sensors' }
CFPhysicsCleanSlateTests >> sensorContactDoesNotJoinDynamicBodiesIntoOneIsland [
	<gtExample>
	| first second sensor step pipeline result dynamicIslands |
	first := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self cleanSlateBodyWithSequence: 2 position: 30 @ 0 extent: 20 @ 20.
	sensor := self cleanSlateBodyWithSequence: 3 position: 0 @ 0 extent: 50 @ 20.
	sensor beStatic; beSensor.
	step := CFPhysicsStep
		timeStep: 0.016
		substeps: 4
		contactHertz: 30.0
		dampingRatio: 10.0.
	pipeline := CFPhysicsStepPipeline manifoldBuilder: [ :pair |
		CFPhysicsBlocManifoldBuilder
			manifoldBetweenBody: pair firstBody
			andBody: pair secondBody ].
	result := pipeline
		stepBodies: { second. sensor. first }
		fromContacts: #()
		step: step
		gravity: 0 @ 0
		restitutionThreshold: 1.0.
	dynamicIslands := result islands select: [ :island |
		island bodies anySatisfy: [ :body | body isDynamic ] ].
	self assert: result activeContacts size equals: 2.
	self assert: result constraints isEmpty.
	self assert: dynamicIslands size equals: 2.
	self assert: (dynamicIslands allSatisfy: [ :island |
		(island bodies select: [ :body | body isDynamic ]) size = 1 ]).
	^ result
]

{ #category : 'examples - sensors' }
CFPhysicsCleanSlateTests >> sensorContactPublishesEndedEventWithoutSolveData [
	<gtExample>
	| firstResult sensor ground secondResult step pipeline |
	firstResult := self sensorContactParticipatesInLifecycleButNotSolving.
	ground := firstResult bodies first.
	sensor := firstResult bodies second.
	sensor position: 0 @ 100.
	step := CFPhysicsStep
		timeStep: 0.016
		substeps: 4
		contactHertz: 30.0
		dampingRatio: 10.0.
	pipeline := CFPhysicsStepPipeline manifoldBuilder: [ :pair |
		CFPhysicsBlocManifoldBuilder
			manifoldBetweenBody: pair firstBody
			andBody: pair secondBody ].
	secondResult := pipeline
		stepBodies: { sensor. ground }
		fromContacts: firstResult activeContacts
		step: step
		gravity: 0 @ 0
		restitutionThreshold: 1.0.
	self assert: secondResult activeContacts isEmpty.
	self assert: secondResult endedContacts size equals: 1.
	self assert: secondResult contactEndedEvents size equals: 1.
	self assert: secondResult contactEndedEvents first isSensor.
	self assert: secondResult contactSolveResults isEmpty.
	^ secondResult
]

{ #category : 'examples - collision filtering' }
CFPhysicsCleanSlateTests >> collisionFiltersAllowOrdinaryOverlappingBodies [
	<gtExample>
	| first second pairs |
	first := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self cleanSlateBodyWithSequence: 2 position: 10 @ 0 extent: 20 @ 20.
	pairs := CFPhysicsPairFinder new pairsAmong: { first. second }.
	self assert: pairs size equals: 1.
	self assert: first collisionCategoryBits equals: 1.
	self assert: first collisionMaskBits equals: 16rFFFFFFFF.
	self assert: first collisionGroupIndex equals: 0.
	^ pairs
]

{ #category : 'examples - collision filtering' }
CFPhysicsCleanSlateTests >> collisionMasksRejectBodiesBeforeManifoldConstruction [
	<gtExample>
	| first second pairs |
	first := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self cleanSlateBodyWithSequence: 2 position: 10 @ 0 extent: 20 @ 20.
	first collisionCategoryBits: 2r0001.
	first collisionMaskBits: 2r0010.
	second collisionCategoryBits: 2r0100.
	second collisionMaskBits: 2r0001.
	pairs := CFPhysicsPairFinder new pairsAmong: { first. second }.
	self assert: pairs isEmpty.
	^ pairs
]

{ #category : 'examples - collision filtering' }
CFPhysicsCleanSlateTests >> positiveCollisionGroupOverridesMasks [
	<gtExample>
	| first second pairs |
	first := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self cleanSlateBodyWithSequence: 2 position: 10 @ 0 extent: 20 @ 20.
	first collisionMaskBits: 0; collisionGroupIndex: 7.
	second collisionMaskBits: 0; collisionGroupIndex: 7.
	pairs := CFPhysicsPairFinder new pairsAmong: { first. second }.
	self assert: pairs size equals: 1.
	^ pairs
]

{ #category : 'examples - collision filtering' }
CFPhysicsCleanSlateTests >> negativeCollisionGroupSuppressesCollision [
	<gtExample>
	| first second pairs |
	first := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self cleanSlateBodyWithSequence: 2 position: 10 @ 0 extent: 20 @ 20.
	first collisionGroupIndex: -3.
	second collisionGroupIndex: -3.
	pairs := CFPhysicsPairFinder new pairsAmong: { first. second }.
	self assert: pairs isEmpty.
	^ pairs
]

{ #category : 'examples - collision filtering' }
CFPhysicsCleanSlateTests >> elementFacingCollisionFilteringConfiguresItsBody [
	<gtExample>
	| owner child world body |
	owner := BlElement new size: 200 @ 200; yourself.
	child := BlElement new size: 30 @ 30; yourself.
	owner addChild: child.
	world := owner physics beWorld.
	world synchroniseMembership.
	child physics
		collisionCategoryBits: 2r0010;
		collisionMaskBits: 2r0101;
		collisionGroupIndex: -4.
	body := world bodyStateFor: child.
	self assert: body collisionCategoryBits equals: 2r0010.
	self assert: body collisionMaskBits equals: 2r0101.
	self assert: body collisionGroupIndex equals: -4.
	^ child
]

{ #category : 'examples - circle manifolds' }
CFPhysicsCleanSlateTests >> overlappingCirclesProducePersistentSinglePointManifold [
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
	firstManifold := CFPhysicsBlocManifoldBuilder
		manifoldBetweenShapeState: first position: 0 @ 0 rotation: 0
		andShapeState: second position: 25 @ 0 rotation: 0.
	secondManifold := CFPhysicsBlocManifoldBuilder
		manifoldBetweenShapeState: first position: 1 @ 0 rotation: 0
		andShapeState: second position: 25 @ 0 rotation: 0.
	self assert: firstManifold notNil.
	self assert: firstManifold contactPoints size equals: 1.
	self assert: firstManifold normal equals: 1 @ 0.
	self assert: (firstManifold contactPoints first separation closeTo: -5.0).
	self assert: firstManifold contactPoints first featureId equals: secondManifold contactPoints first featureId.
	^ firstManifold
]

{ #category : 'examples - circle manifolds' }
CFPhysicsCleanSlateTests >> separatedCirclesDoNotProduceAManifold [
	<gtExample>
	| first second manifold |
	first := CFPhysicsShapeState on: (BlElement new geometry: BlCircleGeometry new; size: 30 @ 30; yourself).
	second := CFPhysicsShapeState on: (BlElement new geometry: BlCircleGeometry new; size: 30 @ 30; yourself).
	manifold := CFPhysicsBlocManifoldBuilder
		manifoldBetweenShapeState: first position: 0 @ 0 rotation: 0
		andShapeState: second position: 31 @ 0 rotation: 0.
	self assert: manifold isNil.
	^ manifold
]

{ #category : 'examples - circle manifolds' }
CFPhysicsCleanSlateTests >> circleAgainstRectangleProducesMixedShapeManifold [
	<gtExample>
	| circle rectangle manifold |
	circle := CFPhysicsShapeState on: (BlElement new geometry: BlCircleGeometry new; size: 20 @ 20; yourself).
	rectangle := CFPhysicsShapeState on: (BlElement new geometry: BlRoundedRectangleGeometry new; size: 80 @ 20; yourself).
	manifold := CFPhysicsBlocManifoldBuilder
		manifoldBetweenShapeState: circle position: 30 @ 12 rotation: 0
		andShapeState: rectangle position: 0 @ 20 rotation: 0.
	self assert: manifold notNil.
	self assert: manifold contactPoints size equals: 1.
	self assert: manifold normal equals: 0 @ 1.
	self assert: (manifold contactPoints first separation closeTo: -8.0).
	self assert: manifold contactPoints first localAnchorA notNil.
	self assert: manifold contactPoints first localAnchorB notNil.
	^ manifold
]

{ #category : 'examples - circle manifolds' }
CFPhysicsCleanSlateTests >> mixedShapeOrderingReversesOnlyTheManifoldOrientation [
	<gtExample>
	| circle rectangle circleFirst polygonFirst |
	circle := CFPhysicsShapeState on: (BlElement new geometry: BlCircleGeometry new; size: 20 @ 20; yourself).
	rectangle := CFPhysicsShapeState on: (BlElement new geometry: BlRoundedRectangleGeometry new; size: 80 @ 20; yourself).
	circleFirst := CFPhysicsBlocManifoldBuilder
		manifoldBetweenShapeState: circle position: 30 @ 12 rotation: 0
		andShapeState: rectangle position: 0 @ 20 rotation: 0.
	polygonFirst := CFPhysicsBlocManifoldBuilder
		manifoldBetweenShapeState: rectangle position: 0 @ 20 rotation: 0
		andShapeState: circle position: 30 @ 12 rotation: 0.
	self assert: polygonFirst notNil.
	self assert: polygonFirst normal equals: circleFirst normal negated.
	self assert: polygonFirst contactPoints first position equals: circleFirst contactPoints first position.
	self assert: polygonFirst contactPoints first separation equals: circleFirst contactPoints first separation.
	^ polygonFirst
]

{ #category : 'examples - circle manifolds' }
CFPhysicsCleanSlateTests >> circleContactsFlowThroughTheOrdinaryStepPipeline [
	<gtExample>
	| first second step pipeline result |
	first := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 30 @ 30.
	second := self cleanSlateBodyWithSequence: 2 position: 25 @ 0 extent: 30 @ 30.
	first element geometry: BlCircleGeometry new.
	second element geometry: BlCircleGeometry new.
	step := CFPhysicsStep
		timeStep: 0.016
		substeps: 4
		contactHertz: 30.0
		dampingRatio: 10.0.
	pipeline := CFPhysicsStepPipeline manifoldBuilder: [ :pair |
		CFPhysicsBlocManifoldBuilder manifoldBetweenBody: pair firstBody andBody: pair secondBody ].
	result := pipeline
		stepBodies: { second. first }
		fromContacts: #()
		step: step
		gravity: 0 @ 0
		restitutionThreshold: 1.0.
	self assert: result activeContacts size equals: 1.
	self assert: result beganContacts size equals: 1.
	self assert: result constraints size equals: 1.
	self assert: result contactSolveResults size equals: 1.
	^ result
]



{ #category : 'examples - pointer interaction' }
CFPhysicsCleanSlateTests >> pointerConstraintOwnsTimingWhenNoEventTimestampExists [
	<gtExample>
	| body constraint |
	body := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 40 @ 40.
	constraint := CFPhysicsPointerConstraint
		body: body
		pointerPosition: 10 @ 10.
	constraint updatePointerPosition: 30 @ 10.
	self assert: constraint isActive.
	self assert: constraint pointerPosition equals: 30 @ 10.
	^ constraint
]

{ #category : 'examples - pointer interaction' }
CFPhysicsCleanSlateTests >> pointerConstraintInitialTargetMovementDoesNotCreateVelocity [
	<gtExample>
	| body constraint timestamp |
	body := self cleanSlateBodyWithSequence: 1 position: 20 @ 30 extent: 40 @ 40.
	timestamp := DateAndTime now.
	constraint := CFPhysicsPointerConstraint
		body: body
		pointerPosition: 25 @ 35
		timestamp: timestamp.
	constraint
		movePointerPositionTo: 80 @ 90
		timestamp: timestamp + 1 milliSecond.
	self assert: constraint pointerPosition equals: 80 @ 90.
	self assert: constraint pointerVelocity equals: 0 @ 0.
	constraint release.
	self assert: body velocity equals: 0 @ 0.
	^ constraint
]

{ #category : 'examples - pointer interaction' }
CFPhysicsCleanSlateTests >> pointerConstraintReleasePreservesSimulatedVelocityWithoutAPointerSample [
	<gtExample>
	| body constraint timestamp |
	body := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 40 @ 40.
	timestamp := DateAndTime now.
	constraint := CFPhysicsPointerConstraint
		body: body
		pointerPosition: 10 @ 10
		timestamp: timestamp.
	constraint movePointerPositionTo: 30 @ 10 timestamp: timestamp + 1 milliSecond.
	body velocity: 420 @ 35.
	constraint release.
	self assert: body velocity equals: 420 @ 35.
	^ constraint
]

{ #category : 'examples - pointer interaction' }
CFPhysicsCleanSlateTests >> pointerConstraintPreservesTheGrabOffset [
	<gtExample>
	| body constraint timestamp |
	body := self cleanSlateBodyWithSequence: 1 position: 20 @ 30 extent: 40 @ 40.
	timestamp := DateAndTime now.
	constraint := CFPhysicsPointerConstraint
		body: body
		pointerPosition: 35 @ 42
		timestamp: timestamp.
	self assert: constraint grabOffset equals: 15 @ 12.
	constraint updatePointerPosition: 75 @ 62 timestamp: timestamp + 20 milliSeconds.
	constraint prepareForStep: 0.016.
	self assert: body velocity x > 0.
	self assert: body velocity y > 0.
	self assert: body position equals: 20 @ 30.
	^ constraint
]

{ #category : 'examples - pointer interaction' }
CFPhysicsCleanSlateTests >> pointerConstraintReleasesWithPointerVelocity [
	<gtExample>
	| body constraint timestamp |
	body := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 40 @ 40.
	timestamp := DateAndTime now.
	constraint := CFPhysicsPointerConstraint
		body: body
		pointerPosition: 10 @ 10
		timestamp: timestamp.
	constraint updatePointerPosition: 30 @ 10 timestamp: timestamp + 20 milliSeconds.
	constraint release.
	self assert: constraint isActive not.
	self assert: body velocity equals: 1000 @ 0.
	^ constraint
]

{ #category : 'examples - pointer interaction' }
CFPhysicsCleanSlateTests >> worldPreparesPointerConstraintsBeforeSolving [
	<gtExample>
	| owner child world body constraint timestamp |
	owner := BlElement new size: 400 @ 300; yourself.
	child := BlElement new size: 40 @ 40; yourself.
	owner addChild: child.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world synchroniseMembership.
	body := world bodyStateFor: child.
	body position: 20 @ 20.
	timestamp := DateAndTime now.
	constraint := CFPhysicsPointerConstraint
		body: body
		pointerPosition: 30 @ 30
		timestamp: timestamp.
	constraint updatePointerPosition: 90 @ 30 timestamp: timestamp + 20 milliSeconds.
	world addPointerConstraint: constraint.
	world step.
	self assert: body position x > 20.
	self assert: world pointerConstraints size equals: 1.
	world removePointerConstraint: constraint.
	self assert: world pointerConstraints isEmpty.
	^ world
]

{ #category : 'examples - pull interaction' }
CFPhysicsCleanSlateTests >> pullInteractionIsInstalledThroughThePhysicsFacade [
	<gtExample>
	| element handler |
	element := BlElement new size: 40 @ 40; yourself.
	handler := element physics pullInteractionHandler.
	self assert: handler element equals: element.
	self assert: element physics isPullInteractionEnabled.
	element physics disablePullInteraction.
	self assert: element physics isPullInteractionEnabled not.
	element physics enablePullInteraction.
	self assert: element physics isPullInteractionEnabled.
	^ element
]

{ #category : 'examples - world membership' }
CFPhysicsCleanSlateTests >> compositeElementCanExcludeItsDecorativeDescendantsFromTheWorld [
	<gtExample>
	| owner button label world |
	owner := BlElement new size: 200 @ 120; yourself.
	button := BrButton new
		aptitude: BrGlamorousButtonWithLabelAptitude new;
		label: 'Click Me';
		yourself.
	label := button childWithId: #label.
	button physics excludeDescendantsFromWorld.
	owner addChild: button.
	world := owner physics beWorld.
	world synchroniseMembership.
	self assert: world members size equals: 1.
	self assert: (world includes: button).
	self assert: (world includes: label) not.
	^ world
]

{ #category : 'examples - pull interaction' }
CFPhysicsCleanSlateTests >> configuredPullDrivesAGlamorousButtonThroughPhysics [
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
	button physics excludeDescendantsFromWorld.
	owner addChild: button.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world synchroniseMembership.
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
	self assert: world pointerConstraints size equals: 1.
	self assert: button constraints position equals: 20 @ 20.
	world step.
	self assert: button physics position x > 20.
	scripter mouseUp play.
	self assert: world pointerConstraints isEmpty.
	self assert: button physics bodyState velocity x > 0.
	^ button
]


{ #category : 'examples - spring interaction' }
CFPhysicsCleanSlateTests >> springAtItsRestLengthDoesNotChangeVelocity [
	<gtExample>
	| first second spring |
	first := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self cleanSlateBodyWithSequence: 2 position: 100 @ 0 extent: 20 @ 20.
	spring := CFPhysicsSpringConstraint between: first and: second.
	spring prepareForStep: 0.016.
	self assert: first velocity equals: 0 @ 0.
	self assert: second velocity equals: 0 @ 0.
	^ spring
]

{ #category : 'examples - spring interaction' }
CFPhysicsCleanSlateTests >> stretchedSpringPullsBodiesTogether [
	<gtExample>
	| first second spring |
	first := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self cleanSlateBodyWithSequence: 2 position: 100 @ 0 extent: 20 @ 20.
	spring := CFPhysicsSpringConstraint between: first and: second.
	spring restLength: 50.
	spring stiffness: 100.
	spring damping: 0.
	spring prepareForStep: 0.016.
	self assert: first velocity x > 0.
	self assert: second velocity x < 0.
	self assert: first velocity y equals: 0.
	self assert: second velocity y equals: 0.
	^ spring
]

{ #category : 'examples - spring interaction' }
CFPhysicsCleanSlateTests >> springCanConnectADynamicElementToAStaticAnchor [
	<gtExample>
	| first second spring |
	first := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self cleanSlateBodyWithSequence: 2 position: 100 @ 0 extent: 20 @ 20.
	first beStatic.
	spring := CFPhysicsSpringConstraint between: first and: second.
	spring restLength: 50.
	spring prepareForStep: 0.016.
	self assert: first velocity equals: 0 @ 0.
	self assert: second velocity x < 0.
	^ spring
]

{ #category : 'examples - spring interaction' }
CFPhysicsCleanSlateTests >> springsAreInstalledThroughBlocElements [
	<gtExample>
	| owner first second world spring |
	owner := BlElement new size: 400 @ 300; yourself.
	first := BlElement new size: 20 @ 20; yourself.
	second := BlElement new size: 20 @ 20; yourself.
	owner addChild: first.
	owner addChild: second.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world synchroniseMembership.
	first physics position: 0 @ 0.
	second physics position: 100 @ 0.
	spring := first physics springTo: second.
	spring restLength: 50.
	world step.
	self assert: world springConstraints size equals: 1.
	self assert: first physics velocity x > 0.
	self assert: second physics velocity x < 0.
	first physics removeSpring: spring.
	self assert: world springConstraints isEmpty.
	^ world
]

{ #category : 'examples - distance joints' }
CFPhysicsCleanSlateTests >> distanceJointCapturesItsEndpointDistance [
	<gtExample>
	| first second joint |
	first := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self cleanSlateBodyWithSequence: 2 position: 100 @ 0 extent: 20 @ 20.
	joint := CFPhysicsDistanceJoint between: first and: second.
	self assert: joint anchorA class equals: CFPhysicsBodyCentreAnchor.
	self assert: joint anchorB class equals: CFPhysicsBodyCentreAnchor.
	self assert: joint firstBody == first.
	self assert: joint secondBody == second.
	self assert: joint restLength equals: 100.0.
	^ joint
]

{ #category : 'examples - distance joints' }
CFPhysicsCleanSlateTests >> distanceJointsAreOwnedAndRetiredByThePhysicsWorld [
	<gtExample>
	| owner first second third world attached unrelated |
	owner := BlElement new size: 400 @ 300; yourself.
	first := BlElement new size: 20 @ 20; yourself.
	second := BlElement new size: 20 @ 20; yourself.
	third := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { first. second. third }.
	world := owner physics beWorld.
	world synchroniseMembership.
	attached := first physics distanceJointTo: second.
	unrelated := second physics distanceJointTo: third.
	self assert: first physics distanceJoints equals: { attached }.
	self assert: second physics distanceJoints equals: { attached. unrelated }.
	owner removeChild: first.
	world synchroniseMembership.
	self assert: world distanceJoints equals: { unrelated }.
	self assert: attached isActive not.
	self assert: unrelated isActive.
	^ world
]

{ #category : 'examples - distance joints' }
CFPhysicsCleanSlateTests >> distanceJointParticipatesInTheIslandSolver [
	<gtExample>
	| owner first second world joint result |
	owner := BlElement new size: 400 @ 300; yourself.
	first := BlElement new size: 20 @ 20; yourself.
	second := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { first. second }.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world synchroniseMembership.
	first physics position: 0 @ 0.
	second physics position: 100 @ 0.
	joint := first physics distanceJointTo: second.
	joint restLength: 50.
	result := world step.
	self assert: result constraints size equals: 1.
	self assert: result constraints first class equals: CFPhysicsPreparedDistanceJoint.
	self assert: result islands size equals: 1.
	self assert: result islands first constraints equals: result constraints.
	self assert: first physics position x > 0.
	self assert: second physics position x < 100.
	self assert: result contactSolveResults isEmpty.
	self assert: result hitEvents isEmpty.
	^ result
]

{ #category : 'examples - distance joints' }
CFPhysicsCleanSlateTests >> distanceJointCanAnchorABodyToTheWorld [
	<gtExample>
	| owner element world bodyAnchor worldAnchor joint result |
	owner := BlElement new size: 400 @ 300; yourself.
	element := BlElement new size: 20 @ 20; yourself.
	owner addChild: element.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world synchroniseMembership.
	element physics position: 0 @ 0.
	bodyAnchor := element physics localAnchorAt: 10 @ 10.
	worldAnchor := world anchorAt: 100 @ 10.
	joint := bodyAnchor distanceJointTo: worldAnchor.
	joint restLength: 50.
	result := world step.
	self assert: joint firstBody == element physics bodyState.
	self assert: joint secondBody isNil.
	self assert: result constraints size equals: 1.
	self assert: result islands size equals: 1.
	self assert: element physics position x > 0.
	^ result
]

{ #category : 'examples - distance joints' }
CFPhysicsCleanSlateTests >> movingAWorldAnchorWakesItsSleepingDistanceJointBody [
	<gtExample>
	| owner element world bodyAnchor worldAnchor joint |
	owner := BlElement new size: 400 @ 300; yourself.
	element := BlElement new size: 20 @ 20; yourself.
	owner addChild: element.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world synchroniseMembership.
	element physics position: 0 @ 0.
	bodyAnchor := element physics localAnchorAt: 10 @ 10.
	worldAnchor := world anchorAt: 10 @ 10.
	joint := bodyAnchor distanceJointTo: worldAnchor.
	joint restLength: 0.
	element physics bodyState sleep.
	worldAnchor point: 110 @ 10.
	self assert: element physics bodyState isAwake.
	world step.
	self assert: element physics position x > 0.
	^ joint
]

{ #category : 'examples - distance joints' }
CFPhysicsCleanSlateTests >> retuningDistanceJointRestLengthWakesItsSleepingEndpoints [
	<gtExample>
	| owner first second world joint |
	owner := BlElement new size: 400 @ 300; yourself.
	first := BlElement new size: 20 @ 20; yourself.
	second := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { first. second }.
	world := owner physics beWorld.
	world synchroniseMembership.
	joint := first physics distanceJointTo: second.
	first physics bodyState sleep.
	second physics bodyState sleep.
	joint restLength: joint restLength + 10.
	self assert: first physics bodyState isAwake.
	self assert: second physics bodyState isAwake.
	^ joint
]

{ #category : 'examples - distance joints' }
CFPhysicsCleanSlateTests >> offCentreDistanceJointProducesAngularResponse [
	<gtExample>
	| owner first second world firstAnchor secondAnchor joint |
	owner := BlElement new size: 400 @ 300; yourself.
	first := BlElement new size: 20 @ 20; yourself.
	second := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { first. second }.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world synchroniseMembership.
	first physics position: 0 @ 0.
	second physics position: 100 @ 0.
	second physics beStatic.
	firstAnchor := first physics localAnchorAt: 20 @ 0.
	secondAnchor := second physics localAnchorAt: 0 @ 20.
	joint := firstAnchor distanceJointTo: secondAnchor.
	joint restLength: 20.
	world step.
	self assert: first physics angularVelocity abs > 0.0.
	self assert: second physics angularVelocity equals: 0.0.
	^ joint
]

{ #category : 'examples - revolute joints' }
CFPhysicsCleanSlateTests >> revoluteJointCapturesItsAnchoredPivot [
	<gtExample>
	| first second firstAnchor secondAnchor joint |
	first := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self cleanSlateBodyWithSequence: 2 position: 30 @ 0 extent: 20 @ 20.
	firstAnchor := CFPhysicsLocalAnchor on: first at: 30 @ 10.
	secondAnchor := CFPhysicsLocalAnchor on: second at: 0 @ 10.
	joint := CFPhysicsRevoluteJoint betweenAnchor: firstAnchor andAnchor: secondAnchor.
	self assert: joint firstBody == first.
	self assert: joint secondBody == second.
	self assert: joint anchorA == firstAnchor.
	self assert: joint anchorB == secondAnchor.
	self assert: joint accumulatedImpulse equals: 0 @ 0.
	^ joint
]

{ #category : 'examples - revolute joints' }
CFPhysicsCleanSlateTests >> revoluteJointParticipatesInTheIslandSolver [
	<gtExample>
	| owner first second world firstAnchor secondAnchor joint result |
	owner := BlElement new size: 400 @ 300; yourself.
	first := BlElement new size: 20 @ 20; yourself.
	second := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { first. second }.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world synchroniseMembership.
	first physics position: 0 @ 0.
	second physics position: 30 @ 0.
	second physics beStatic.
	firstAnchor := first physics localAnchorAt: 30 @ 10.
	secondAnchor := second physics localAnchorAt: 0 @ 10.
	joint := firstAnchor revoluteJointTo: secondAnchor.
	first physics velocity: 100 @ 0.
	result := world step.
	self assert: world revoluteJoints equals: { joint }.
	self assert: result constraints size equals: 1.
	self assert: result constraints first class equals: CFPhysicsPreparedRevoluteJoint.
	self assert: result islands size equals: 1.
	self assert: first physics velocity x abs < 1.0e-6.
	^ result
]

{ #category : 'examples - revolute joints' }
CFPhysicsCleanSlateTests >> revoluteJointCanAnchorABodyToTheWorld [
	<gtExample>
	| owner element world bodyAnchor worldAnchor joint result |
	owner := BlElement new size: 400 @ 300; yourself.
	element := BlElement new size: 20 @ 20; yourself.
	owner addChild: element.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world synchroniseMembership.
	element physics position: 0 @ 0.
	bodyAnchor := element physics localAnchorAt: 10 @ 10.
	worldAnchor := world anchorAt: 10 @ 10.
	joint := bodyAnchor revoluteJointTo: worldAnchor.
	element physics velocity: 100 @ 0.
	result := world step.
	self assert: joint firstBody == element physics bodyState.
	self assert: joint secondBody isNil.
	self assert: result constraints size equals: 1.
	self assert: result islands size equals: 1.
	self assert: element physics velocity x abs < 1.0e-6.
	^ result
]

{ #category : 'examples - revolute joints' }
CFPhysicsCleanSlateTests >> movingAWorldAnchorWakesItsSleepingRevoluteJointBody [
	<gtExample>
	| owner element world bodyAnchor worldAnchor joint |
	owner := BlElement new size: 400 @ 300; yourself.
	element := BlElement new size: 20 @ 20; yourself.
	owner addChild: element.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world synchroniseMembership.
	element physics position: 0 @ 0.
	bodyAnchor := element physics localAnchorAt: 10 @ 10.
	worldAnchor := world anchorAt: 10 @ 10.
	joint := bodyAnchor revoluteJointTo: worldAnchor.
	element physics bodyState sleep.
	worldAnchor point: 110 @ 10.
	self assert: element physics bodyState isAwake.
	world step.
	self assert: element physics position x > 0.
	^ joint
]

{ #category : 'examples - revolute joints' }
CFPhysicsCleanSlateTests >> revoluteJointMotorDrivesRelativeAngularVelocity [
	<gtExample>
	| owner first second world firstAnchor secondAnchor joint result |
	owner := BlElement new size: 400 @ 300; yourself.
	first := BlElement new size: 20 @ 20; yourself.
	second := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { first. second }.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world synchroniseMembership.
	first physics position: 0 @ 0.
	second physics position: 30 @ 0.
	second physics beStatic.
	firstAnchor := first physics localAnchorAt: 30 @ 10.
	secondAnchor := second physics localAnchorAt: 0 @ 10.
	joint := firstAnchor revoluteJointTo: secondAnchor.
	joint
		motorEnabled: true;
		motorSpeed: 10.0;
		maximumMotorImpulse: 1000.0.
	result := world step.
	self assert: result constraints first motorEnabled.
	self assert: first physics angularVelocity < 0.0.
	self assert: second physics angularVelocity equals: 0.0.
	^ result
]

{ #category : 'examples - revolute joints' }
CFPhysicsCleanSlateTests >> revoluteJointLimitsBoundAnAnchoredElementRotation [
	<gtExample>
	| owner element world bodyAnchor worldAnchor joint result |
	owner := BlElement new size: 400 @ 300; yourself.
	element := BlElement new size: 20 @ 20; yourself.
	owner addChild: element.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world synchroniseMembership.
	element physics position: 0 @ 0.
	bodyAnchor := element physics localAnchorAt: 10 @ 10.
	worldAnchor := world anchorAt: 10 @ 10.
	joint := bodyAnchor revoluteJointTo: worldAnchor.
	joint
		limitAnglesFrom: -0.25 to: 0.25;
		limitsEnabled: true.
	element physics rotation: 0.5.
	result := world step.
	self assert: result constraints first limitsEnabled.
	self assert: result constraints first limitBaseAngle equals: -0.5.
	self assert: element physics rotation abs < 0.5.
	self assert: (element physics angularVelocity closeTo: 0.0).
	self assert: result constraints first limitImpulse > 0.0.
	^ result
]

{ #category : 'examples - rail joints' }
CFPhysicsCleanSlateTests >> railJointConstrainsAnAnchoredElementToItsAxis [
	<gtExample>
	| owner element world bodyAnchor worldAnchor joint result |
	owner := BlElement new size: 400 @ 300; yourself.
	element := BlElement new size: 20 @ 20; yourself.
	owner addChild: element.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world synchroniseMembership.
	element physics position: 0 @ 0.
	bodyAnchor := element physics localAnchorAt: 10 @ 10.
	worldAnchor := world anchorAt: 10 @ 10.
	joint := bodyAnchor railJointTo: worldAnchor along: 1 @ 0.
	element physics velocity: 100 @ 100.
	element physics angularVelocity: 10.0.
	result := world step.
	self assert: world railJoints equals: { joint }.
	self assert: result constraints size equals: 1.
	self assert: result constraints first class equals: CFPhysicsPreparedRailJoint.
	self assert: element physics velocity y abs < 1.0e-6.
	self assert: element physics angularVelocity abs < 1.0e-6.
	^ result
]

{ #category : 'examples - rail joints' }
CFPhysicsCleanSlateTests >> railJointLimitsBoundAnAnchoredElementTravel [
	<gtExample>
	| owner element world bodyAnchor worldAnchor joint result |
	owner := BlElement new size: 400 @ 300; yourself.
	element := BlElement new size: 20 @ 20; yourself.
	owner addChild: element.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world synchroniseMembership.
	element physics position: 0 @ 0.
	bodyAnchor := element physics localAnchorAt: 10 @ 10.
	worldAnchor := world anchorAt: 10 @ 10.
	joint := bodyAnchor railJointTo: worldAnchor along: 1 @ 0.
	joint
		limitTranslationFrom: -10 to: 10;
		limitsEnabled: true.
	element physics position: 20 @ 0.
	result := world step.
	self assert: result constraints first limitsEnabled.
	self assert: result constraints first baseTranslation equals: 20.0.
	self assert: element physics position x <= (10.0 + 1.0e-6).
	self assert: element physics velocity x abs < 1.0e-6.
	^ result
]

{ #category : 'examples - rail joints' }
CFPhysicsCleanSlateTests >> pointerDraggingRespectsARailAxis [
	<gtExample>
	| owner element world bodyAnchor worldAnchor joint timestamp pointerConstraint result |
	owner := BlElement new size: 400 @ 300; yourself.
	element := BlElement new size: 20 @ 20; yourself.
	owner addChild: element.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world synchroniseMembership.
	element physics position: 0 @ 0.
	bodyAnchor := element physics localAnchorAt: 10 @ 10.
	worldAnchor := world anchorAt: 10 @ 10.
	joint := bodyAnchor railJointTo: worldAnchor along: 1 @ 0.
	joint
		limitTranslationFrom: -10 to: 10;
		limitsEnabled: true.
	timestamp := DateAndTime now.
	pointerConstraint := CFPhysicsPointerConstraint
		body: element physics bodyState
		pointerPosition: 10 @ 10
		timestamp: timestamp.
	pointerConstraint
		updatePointerPosition: 1000 @ 1000
		timestamp: timestamp + 20 milliSeconds.
	world addPointerConstraint: pointerConstraint.
	result := world step.
	self assert: result constraints first class equals: CFPhysicsPreparedRailJoint.
	self assert: (element physics velocity y closeTo: 0.0).
	self assert: element physics position y abs < element physics position x abs.
	self assert: result constraints first perpendicularImpulse abs > 0.0.
	self assert: element physics position x <= (10.0 + 1.0e-6).
	^ result
]

{ #category : 'examples - fixed joints' }
CFPhysicsCleanSlateTests >> fixedJointCapturesItsReferenceAngle [
	<gtExample>
	| first second joint |
	first := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self cleanSlateBodyWithSequence: 2 position: 30 @ 0 extent: 20 @ 20.
	first rotation: 0.25.
	second rotation: 0.75.
	joint := CFPhysicsFixedJoint between: first and: second.
	self assert: joint firstBody == first.
	self assert: joint secondBody == second.
	self assert: joint referenceAngle equals: 0.5.
	self assert: joint accumulatedAngularImpulse equals: 0.0.
	^ joint
]

{ #category : 'examples - fixed joints' }
CFPhysicsCleanSlateTests >> fixedJointAnchorsABodyOrientationToTheWorld [
	<gtExample>
	| owner element world bodyAnchor worldAnchor joint result |
	owner := BlElement new size: 400 @ 300; yourself.
	element := BlElement new size: 20 @ 20; yourself.
	owner addChild: element.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world synchroniseMembership.
	element physics position: 0 @ 0.
	bodyAnchor := element physics localAnchorAt: 10 @ 10.
	worldAnchor := world anchorAt: 10 @ 10.
	joint := bodyAnchor fixedJointTo: worldAnchor.
	element physics angularVelocity: 10.0.
	result := world step.
	self assert: world fixedJoints equals: { joint }.
	self assert: result constraints size equals: 1.
	self assert: result constraints first class equals: CFPhysicsPreparedFixedJoint.
	self assert: result islands size equals: 1.
	self assert: element physics angularVelocity abs < 1.0e-6.
	^ result
]

{ #category : 'examples - constraint graph' }
CFPhysicsCleanSlateTests >> mixedJointConstraintsKeepTheWorldOrdering [
	<gtExample>
	| owner element world bodyAnchor revoluteAnchor distanceAnchor revolute distance result |
	owner := BlElement new size: 400 @ 300; yourself.
	element := BlElement new size: 20 @ 20; yourself.
	owner addChild: element.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world synchroniseMembership.
	element physics position: 0 @ 0.
	bodyAnchor := element physics localAnchorAt: 10 @ 10.
	revoluteAnchor := world anchorAt: 10 @ 10.
	distanceAnchor := world anchorAt: 10 @ 10.
	revolute := bodyAnchor revoluteJointTo: revoluteAnchor.
	distance := bodyAnchor distanceJointTo: distanceAnchor.
	result := world step.
	self assert: result joints equals: { distance. revolute }.
	self assert: (result constraints collect: #joint) equals: result joints.
	self assert: (result constraints collect: #class) equals: {
		CFPhysicsPreparedDistanceJoint.
		CFPhysicsPreparedRevoluteJoint }.
	^ result
]

{ #category : 'examples - constraint graph' }
CFPhysicsCleanSlateTests >> retiringABodyRetiresAllOfItsJointTypes [
	<gtExample>
	| owner first second third fourth world revolute fixed unrelated |
	owner := BlElement new size: 400 @ 300; yourself.
	first := BlElement new size: 20 @ 20; yourself.
	second := BlElement new size: 20 @ 20; yourself.
	third := BlElement new size: 20 @ 20; yourself.
	fourth := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { first. second. third. fourth }.
	world := owner physics beWorld.
	world synchroniseMembership.
	revolute := first physics revoluteJointTo: second.
	fixed := first physics fixedJointTo: third.
	unrelated := second physics distanceJointTo: fourth.
	owner removeChild: first.
	world synchroniseMembership.
	self assert: world revoluteJoints isEmpty.
	self assert: world fixedJoints isEmpty.
	self assert: world distanceJoints equals: { unrelated }.
	self assert: revolute isActive not.
	self assert: fixed isActive not.
	self assert: unrelated isActive.
	^ world
]

{ #category : 'examples - collision filtering' }
CFPhysicsCleanSlateTests >> distanceJointCanSuppressCollisionBetweenItsEndpoints [
	<gtExample>
	| owner first second world joint pairs |
	owner := BlElement new size: 400 @ 300; yourself.
	first := BlElement new size: 20 @ 20; yourself.
	second := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { first. second }.
	world := owner physics beWorld.
	world synchroniseMembership.
	first physics position: 0 @ 0.
	second physics position: 10 @ 0.
	joint := first physics distanceJointTo: second.
	self assert: joint collideConnected.
	pairs := CFPhysicsPairFinder new pairsAmong: {
		first physics bodyState.
		second physics bodyState }.
	self assert: pairs size equals: 1.
	joint collideConnected: false.
	pairs := CFPhysicsPairFinder new pairsAmong: {
		first physics bodyState.
		second physics bodyState }.
	self assert: pairs isEmpty.
	^ joint
]

{ #category : 'examples - collision filtering' }
CFPhysicsCleanSlateTests >> revoluteJointCanSuppressCollisionBetweenItsEndpoints [
	<gtExample>
	| owner first second world joint pairs |
	owner := BlElement new size: 400 @ 300; yourself.
	first := BlElement new size: 20 @ 20; yourself.
	second := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { first. second }.
	world := owner physics beWorld.
	world synchroniseMembership.
	first physics position: 0 @ 0.
	second physics position: 10 @ 0.
	joint := first physics revoluteJointTo: second.
	self assert: joint collideConnected.
	pairs := CFPhysicsPairFinder new pairsAmong: {
		first physics bodyState.
		second physics bodyState }.
	self assert: pairs size equals: 1.
	joint collideConnected: false.
	pairs := CFPhysicsPairFinder new pairsAmong: {
		first physics bodyState.
		second physics bodyState }.
	self assert: pairs isEmpty.
	^ joint
]

{ #category : 'examples - collision filtering' }
CFPhysicsCleanSlateTests >> fixedJointCanSuppressCollisionBetweenItsEndpoints [
	<gtExample>
	| owner first second world joint pairs |
	owner := BlElement new size: 400 @ 300; yourself.
	first := BlElement new size: 20 @ 20; yourself.
	second := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { first. second }.
	world := owner physics beWorld.
	world synchroniseMembership.
	first physics position: 0 @ 0.
	second physics position: 10 @ 0.
	joint := first physics fixedJointTo: second.
	self assert: joint collideConnected.
	pairs := CFPhysicsPairFinder new pairsAmong: {
		first physics bodyState.
		second physics bodyState }.
	self assert: pairs size equals: 1.
	joint collideConnected: false.
	pairs := CFPhysicsPairFinder new pairsAmong: {
		first physics bodyState.
		second physics bodyState }.
	self assert: pairs isEmpty.
	^ joint
]

{ #category : 'examples - collision filtering' }
CFPhysicsCleanSlateTests >> railJointCanSuppressCollisionBetweenItsEndpoints [
	<gtExample>
	| owner first second world joint pairs |
	owner := BlElement new size: 400 @ 300; yourself.
	first := BlElement new size: 20 @ 20; yourself.
	second := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { first. second }.
	world := owner physics beWorld.
	world synchroniseMembership.
	first physics position: 0 @ 0.
	second physics position: 10 @ 0.
	joint := first physics railJointTo: second along: 1 @ 0.
	self assert: joint collideConnected.
	pairs := CFPhysicsPairFinder new pairsAmong: {
		first physics bodyState.
		second physics bodyState }.
	self assert: pairs size equals: 1.
	joint collideConnected: false.
	pairs := CFPhysicsPairFinder new pairsAmong: {
		first physics bodyState.
		second physics bodyState }.
	self assert: pairs isEmpty.
	^ joint
]

{ #category : 'examples - collision filtering' }
CFPhysicsCleanSlateTests >> disablingDistanceJointCollisionEndsAnActiveContact [
	<gtExample>
	| owner first second world joint firstResult secondResult |
	owner := BlElement new size: 400 @ 300; yourself.
	first := BlElement new size: 20 @ 20; yourself.
	second := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { first. second }.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world synchroniseMembership.
	first physics position: 0 @ 0.
	second physics position: 10 @ 0.
	firstResult := world step.
	self assert: firstResult activeContacts size equals: 1.
	joint := first physics distanceJointTo: second.
	joint collideConnected: false.
	secondResult := world step.
	self assert: secondResult activeContacts isEmpty.
	self assert: secondResult endedContacts size equals: 1.
	self assert: secondResult contactEndedEvents size equals: 1.
	^ secondResult
]

{ #category : 'examples - collision filtering' }
CFPhysicsCleanSlateTests >> changingDistanceJointCollisionPolicyWakesItsBodies [
	<gtExample>
	| owner first second world joint |
	owner := BlElement new size: 400 @ 300; yourself.
	first := BlElement new size: 20 @ 20; yourself.
	second := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { first. second }.
	world := owner physics beWorld.
	world synchroniseMembership.
	joint := first physics distanceJointTo: second.
	first physics bodyState sleep.
	second physics bodyState sleep.
	joint collideConnected: false.
	self assert: first physics bodyState isAwake.
	self assert: second physics bodyState isAwake.
	^ joint
]


{ #category : 'examples - containment interaction' }
CFPhysicsCleanSlateTests >> containmentCorrectsABodyOutsideTheWorld [
	<gtExample>
	| body containment |
	body := self cleanSlateBodyWithSequence: 1 position: -10 @ 95 extent: 20 @ 20.
	containment := CFPhysicsContainmentConstraint on: body.
	containment prepareForBounds: (0 @ 0 extent: 100 @ 100).
	self assert: body position equals: 0 @ 80.
	^ containment
]

{ #category : 'examples - containment interaction' }
CFPhysicsCleanSlateTests >> containmentStopsOutwardVelocity [
	<gtExample>
	| body containment |
	body := self cleanSlateBodyWithSequence: 1 position: 90 @ 20 extent: 20 @ 20.
	body velocity: 50 @ 0.
	containment := CFPhysicsContainmentConstraint on: body.
	containment prepareForBounds: (0 @ 0 extent: 100 @ 100).
	self assert: body position equals: 80 @ 20.
	self assert: body velocity equals: 0 @ 0.
	^ containment
]

{ #category : 'examples - containment interaction' }
CFPhysicsCleanSlateTests >> containmentCanBounceAtTheWorldEdge [
	<gtExample>
	| body containment |
	body := self cleanSlateBodyWithSequence: 1 position: 90 @ 20 extent: 20 @ 20.
	body velocity: 50 @ 0.
	containment := CFPhysicsContainmentConstraint on: body.
	containment restitution: 0.5.
	containment prepareForBounds: (0 @ 0 extent: 100 @ 100).
	self assert: body velocity equals: -25 @ 0.
	^ containment
]

{ #category : 'examples - containment interaction' }
CFPhysicsCleanSlateTests >> containmentBouncesUsingRotatedBodyBounds [
	<gtExample>
	| body containment |
	body := self cleanSlateBodyWithSequence: 1 position: 80 @ 20 extent: 40 @ 20.
	body
		rotation: Float pi / 2.0;
		velocity: 50 @ 0.
	containment := CFPhysicsContainmentConstraint on: body.
	containment restitution: 0.5.
	containment prepareForBounds: (0 @ 0 extent: 100 @ 100).
	self assert: (body position x closeTo: 70.0).
	self assert: (body position y closeTo: 20.0).
	self assert: body velocity equals: -25 @ 0.
	^ containment
]

{ #category : 'examples - containment interaction' }
CFPhysicsCleanSlateTests >> containmentIsInstalledThroughTheBlocElement [
	<gtExample>
	| owner element world containment |
	owner := BlElement new size: 100 @ 100; yourself.
	element := BlElement new size: 20 @ 20; yourself.
	owner addChild: element.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world synchroniseMembership.
	element physics position: 90 @ 90.
	containment := element physics containWithinWorld.
	world step.
	self assert: element physics position equals: 80 @ 80.
	self assert: world containmentConstraints size equals: 1.
	element physics removeContainment: containment.
	self assert: world containmentConstraints isEmpty.
	^ world
]

{ #category : 'examples - containment interaction' }
CFPhysicsCleanSlateTests >> containmentUsesTheCurrentWorldExtent [
	<gtExample>
	| owner element world |
	owner := BlElement new size: 100 @ 100; yourself.
	element := BlElement new size: 20 @ 20; yourself.
	owner addChild: element.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world synchroniseMembership.
	element physics containWithinWorld.
	element physics position: 130 @ 20.
	owner size: 160 @ 100.
	world step.
	self assert: element physics position equals: 130 @ 20.
	^ world
]

{ #category : 'examples - spring interaction' }
CFPhysicsCleanSlateTests >> springEndpointsAreResolvedThroughAnchors [
	<gtExample>
	| first second spring |
	first := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self cleanSlateBodyWithSequence: 2 position: 100 @ 0 extent: 20 @ 20.
	spring := CFPhysicsSpringConstraint between: first and: second.
	self assert: spring anchorA class equals: CFPhysicsBodyCentreAnchor.
	self assert: spring anchorB class equals: CFPhysicsBodyCentreAnchor.
	self assert: spring anchorA worldPoint equals: 10 @ 10.
	self assert: spring anchorB worldPoint equals: 110 @ 10.
	self assert: spring bodyA == first.
	self assert: spring bodyB == second.
	^ spring
]

{ #category : 'examples - spring interaction' }
CFPhysicsCleanSlateTests >> oneElementCanOwnManyIndependentSpringRelationships [
	<gtExample>
	| owner first second third fourth world firstSpring secondSpring thirdSpring |
	owner := BlElement new size: 400 @ 300; yourself.
	first := BlElement new size: 20 @ 20; yourself.
	second := BlElement new size: 20 @ 20; yourself.
	third := BlElement new size: 20 @ 20; yourself.
	fourth := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { first. second. third. fourth }.
	world := owner physics beWorld.
	world synchroniseMembership.
	firstSpring := first physics springTo: second.
	secondSpring := first physics springTo: third.
	thirdSpring := first physics springTo: fourth.
	self assert: first physics springs equals: { firstSpring. secondSpring. thirdSpring }.
	self assert: second physics springs equals: { firstSpring }.
	first physics removeSpring: secondSpring.
	self assert: first physics springs equals: { firstSpring. thirdSpring }.
	self assert: world springConstraints equals: { firstSpring. thirdSpring }.
	^ world
]

{ #category : 'examples - spring interaction' }
CFPhysicsCleanSlateTests >> duplicateSpringEndpointsRemainIndependent [
	<gtExample>
	| owner first second world firstSpring secondSpring |
	owner := BlElement new size: 400 @ 300; yourself.
	first := BlElement new size: 20 @ 20; yourself.
	second := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { first. second }.
	world := owner physics beWorld.
	world synchroniseMembership.
	firstSpring := first physics springTo: second.
	secondSpring := first physics springTo: second.
	self assert: (firstSpring == secondSpring) not.
	self assert: first physics springs equals: { firstSpring. secondSpring }.
	first physics removeSpring: firstSpring.
	self assert: first physics springs equals: { secondSpring }.
	self assert: secondSpring isActive.
	^ world
]

{ #category : 'examples - spring interaction' }
CFPhysicsCleanSlateTests >> retiringABodyRemovesOnlyItsSprings [
	<gtExample>
	| owner first second third fourth world attachedA attachedB unrelated |
	owner := BlElement new size: 400 @ 300; yourself.
	first := BlElement new size: 20 @ 20; yourself.
	second := BlElement new size: 20 @ 20; yourself.
	third := BlElement new size: 20 @ 20; yourself.
	fourth := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { first. second. third. fourth }.
	world := owner physics beWorld.
	world synchroniseMembership.
	attachedA := first physics springTo: second.
	attachedB := first physics springTo: third.
	unrelated := third physics springTo: fourth.
	owner removeChild: first.
	world synchroniseMembership.
	self assert: world springConstraints equals: { unrelated }.
	self assert: attachedA isActive not.
	self assert: attachedB isActive not.
	self assert: unrelated isActive.
	self assert: third physics springs equals: { unrelated }.
	^ world
]

{ #category : 'examples - attraction interaction' }
CFPhysicsCleanSlateTests >> constantForceResponseCanBeLimitedByDistance [
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

{ #category : 'examples - attraction interaction' }
CFPhysicsCleanSlateTests >> attractionEndpointsAreResolvedThroughAnchors [
	<gtExample>
	| first second attraction |
	first := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self cleanSlateBodyWithSequence: 2 position: 100 @ 0 extent: 20 @ 20.
	attraction := CFPhysicsAttractionConstraint between: first and: second.
	self assert: attraction anchorA class equals: CFPhysicsBodyCentreAnchor.
	self assert: attraction anchorB class equals: CFPhysicsBodyCentreAnchor.
	self assert: attraction anchorA worldPoint equals: 10 @ 10.
	self assert: attraction anchorB worldPoint equals: 110 @ 10.
	self assert: attraction bodyA == first.
	self assert: attraction bodyB == second.
	^ attraction
]

{ #category : 'examples - attraction interaction' }
CFPhysicsCleanSlateTests >> attractionAppliesEqualAndOppositeImpulse [
	<gtExample>
	| first second attraction |
	first := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self cleanSlateBodyWithSequence: 2 position: 100 @ 0 extent: 20 @ 20.
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

{ #category : 'examples - attraction interaction' }
CFPhysicsCleanSlateTests >> attractionCanPullTowardAStaticBody [
	<gtExample>
	| dynamicBody staticBody attraction |
	dynamicBody := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	staticBody := self cleanSlateBodyWithSequence: 2 position: 100 @ 0 extent: 20 @ 20.
	staticBody beStatic.
	attraction := CFPhysicsAttractionConstraint between: dynamicBody and: staticBody.
	attraction force: 1000.
	attraction prepareForStep: 0.1.
	self assert: dynamicBody velocity x > 0.
	self assert: staticBody velocity equals: 0 @ 0.
	^ attraction
]

{ #category : 'examples - attraction interaction' }
CFPhysicsCleanSlateTests >> attractionsAreInstalledAndDiscoveredThroughBlocElements [
	<gtExample>
	| owner first second third world firstAttraction secondAttraction |
	owner := BlElement new size: 400 @ 300; yourself.
	first := BlElement new size: 20 @ 20; yourself.
	second := BlElement new size: 20 @ 20; yourself.
	third := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { first. second. third }.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world synchroniseMembership.
	firstAttraction := first physics attract: second.
	secondAttraction := first physics attract: third.
	self assert: first physics attractions equals: { firstAttraction. secondAttraction }.
	self assert: second physics attractions equals: { firstAttraction }.
	self assert: world attractionConstraints equals: { firstAttraction. secondAttraction }.
	first physics removeAttraction: firstAttraction.
	self assert: first physics attractions equals: { secondAttraction }.
	self assert: firstAttraction isActive not.
	self assert: secondAttraction isActive.
	^ world
]

{ #category : 'examples - attraction interaction' }
CFPhysicsCleanSlateTests >> duplicateAttractionsRemainIndependent [
	<gtExample>
	| owner first second world firstAttraction secondAttraction |
	owner := BlElement new size: 400 @ 300; yourself.
	first := BlElement new size: 20 @ 20; yourself.
	second := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { first. second }.
	world := owner physics beWorld.
	world synchroniseMembership.
	firstAttraction := first physics attract: second.
	secondAttraction := first physics attract: second.
	self assert: (firstAttraction == secondAttraction) not.
	self assert: first physics attractions equals: { firstAttraction. secondAttraction }.
	first physics removeAttraction: firstAttraction.
	self assert: first physics attractions equals: { secondAttraction }.
	self assert: secondAttraction isActive.
	^ world
]

{ #category : 'examples - attraction interaction' }
CFPhysicsCleanSlateTests >> retiringABodyRemovesOnlyItsAttractions [
	<gtExample>
	| owner first second third fourth world attachedA attachedB unrelated |
	owner := BlElement new size: 400 @ 300; yourself.
	first := BlElement new size: 20 @ 20; yourself.
	second := BlElement new size: 20 @ 20; yourself.
	third := BlElement new size: 20 @ 20; yourself.
	fourth := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { first. second. third. fourth }.
	world := owner physics beWorld.
	world synchroniseMembership.
	attachedA := first physics attract: second.
	attachedB := first physics attract: third.
	unrelated := third physics attract: fourth.
	owner removeChild: first.
	world synchroniseMembership.
	self assert: world attractionConstraints equals: { unrelated }.
	self assert: attachedA isActive not.
	self assert: attachedB isActive not.
	self assert: unrelated isActive.
	self assert: third physics attractions equals: { unrelated }.
	^ world
]

{ #category : 'examples - attraction interaction' }
CFPhysicsCleanSlateTests >> worldStepAppliesAttractionBeforeIntegration [
	<gtExample>
	| owner first second world attraction |
	owner := BlElement new size: 400 @ 300; yourself.
	first := BlElement new size: 20 @ 20; yourself.
	second := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { first. second }.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world synchroniseMembership.
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



{ #category : 'examples - repulsion interaction' }
CFPhysicsCleanSlateTests >> repulsionEndpointsAreResolvedThroughAnchors [
	<gtExample>
	| first second repulsion |
	first := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self cleanSlateBodyWithSequence: 2 position: 100 @ 0 extent: 20 @ 20.
	repulsion := CFPhysicsRepulsionConstraint between: first and: second.
	self assert: repulsion anchorA class equals: CFPhysicsBodyCentreAnchor.
	self assert: repulsion anchorB class equals: CFPhysicsBodyCentreAnchor.
	self assert: repulsion anchorA worldPoint equals: 10 @ 10.
	self assert: repulsion anchorB worldPoint equals: 110 @ 10.
	self assert: repulsion bodyA == first.
	self assert: repulsion bodyB == second.
	^ repulsion
]

{ #category : 'examples - repulsion interaction' }
CFPhysicsCleanSlateTests >> repulsionAppliesEqualAndOppositeImpulse [
	<gtExample>
	| first second repulsion |
	first := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self cleanSlateBodyWithSequence: 2 position: 100 @ 0 extent: 20 @ 20.
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

{ #category : 'examples - repulsion interaction' }
CFPhysicsCleanSlateTests >> repulsionCanPushAwayFromAStaticBody [
	<gtExample>
	| dynamicBody staticBody repulsion |
	dynamicBody := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	staticBody := self cleanSlateBodyWithSequence: 2 position: 100 @ 0 extent: 20 @ 20.
	staticBody beStatic.
	repulsion := CFPhysicsRepulsionConstraint between: dynamicBody and: staticBody.
	repulsion force: 1000.
	repulsion prepareForStep: 0.1.
	self assert: dynamicBody velocity x < 0.
	self assert: staticBody velocity equals: 0 @ 0.
	^ repulsion
]

{ #category : 'examples - repulsion interaction' }
CFPhysicsCleanSlateTests >> repulsionsAreInstalledAndDiscoveredThroughBlocElements [
	<gtExample>
	| owner first second third world firstRepulsion secondRepulsion |
	owner := BlElement new size: 400 @ 300; yourself.
	first := BlElement new size: 20 @ 20; yourself.
	second := BlElement new size: 20 @ 20; yourself.
	third := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { first. second. third }.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world synchroniseMembership.
	firstRepulsion := first physics repel: second.
	secondRepulsion := first physics repel: third.
	self assert: first physics repulsions equals: { firstRepulsion. secondRepulsion }.
	self assert: second physics repulsions equals: { firstRepulsion }.
	self assert: world repulsionConstraints equals: { firstRepulsion. secondRepulsion }.
	first physics removeRepulsion: firstRepulsion.
	self assert: first physics repulsions equals: { secondRepulsion }.
	self assert: firstRepulsion isActive not.
	self assert: secondRepulsion isActive.
	^ world
]

{ #category : 'examples - repulsion interaction' }
CFPhysicsCleanSlateTests >> duplicateRepulsionsRemainIndependent [
	<gtExample>
	| owner first second world firstRepulsion secondRepulsion |
	owner := BlElement new size: 400 @ 300; yourself.
	first := BlElement new size: 20 @ 20; yourself.
	second := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { first. second }.
	world := owner physics beWorld.
	world synchroniseMembership.
	firstRepulsion := first physics repel: second.
	secondRepulsion := first physics repel: second.
	self assert: (firstRepulsion == secondRepulsion) not.
	self assert: first physics repulsions equals: { firstRepulsion. secondRepulsion }.
	first physics removeRepulsion: firstRepulsion.
	self assert: first physics repulsions equals: { secondRepulsion }.
	self assert: secondRepulsion isActive.
	^ world
]

{ #category : 'examples - repulsion interaction' }
CFPhysicsCleanSlateTests >> retiringABodyRemovesOnlyItsRepulsions [
	<gtExample>
	| owner first second third fourth world attachedA attachedB unrelated |
	owner := BlElement new size: 400 @ 300; yourself.
	first := BlElement new size: 20 @ 20; yourself.
	second := BlElement new size: 20 @ 20; yourself.
	third := BlElement new size: 20 @ 20; yourself.
	fourth := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { first. second. third. fourth }.
	world := owner physics beWorld.
	world synchroniseMembership.
	attachedA := first physics repel: second.
	attachedB := first physics repel: third.
	unrelated := third physics repel: fourth.
	owner removeChild: first.
	world synchroniseMembership.
	self assert: world repulsionConstraints equals: { unrelated }.
	self assert: attachedA isActive not.
	self assert: attachedB isActive not.
	self assert: unrelated isActive.
	self assert: third physics repulsions equals: { unrelated }.
	^ world
]

{ #category : 'examples - repulsion interaction' }
CFPhysicsCleanSlateTests >> worldStepAppliesRepulsionBeforeIntegration [
	<gtExample>
	| owner first second world repulsion |
	owner := BlElement new size: 400 @ 300; yourself.
	first := BlElement new size: 20 @ 20; yourself.
	second := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { first. second }.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world synchroniseMembership.
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

{ #category : 'examples - anchors' }
CFPhysicsCleanSlateTests >> localAnchorFollowsBodyTranslationAndRotation [
	<gtExample>
	| body anchor |
	body := self cleanSlateBodyWithSequence: 1 position: 100 @ 50 extent: 40 @ 20.
	anchor := CFPhysicsLocalAnchor on: body at: 20 @ 0.
	self assert: anchor body == body.
	self assert: anchor localPoint equals: 20 @ 0.
	self assert: anchor worldPoint equals: 120 @ 50.
	body position: 110 @ 60.
	self assert: anchor worldPoint equals: 130 @ 60.
	body rotation: Float pi / 2.
	self assert: (anchor worldPoint closeTo: 110 @ 80).
	^ anchor
]

{ #category : 'examples - anchors' }
CFPhysicsCleanSlateTests >> elementCanCreateALocalAnchor [
	<gtExample>
	| owner element world anchor |
	owner := BlElement new size: 400 @ 300; yourself.
	element := BlElement new size: 40 @ 20; yourself.
	owner addChild: element.
	world := owner physics beWorld.
	world synchroniseMembership.
	element physics position: 100 @ 50.
	anchor := element physics localAnchorAt: 40 @ 10.
	self assert: anchor class equals: CFPhysicsLocalAnchor.
	self assert: anchor body == element physics bodyState.
	self assert: anchor worldPoint equals: 140 @ 60.
	^ anchor
]

{ #category : 'examples - anchors' }
CFPhysicsCleanSlateTests >> relationshipsCanResolveBodyLocalAnchors [
	<gtExample>
	| first second anchorA anchorB spring attraction repulsion |
	first := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self cleanSlateBodyWithSequence: 2 position: 100 @ 0 extent: 20 @ 20.
	anchorA := CFPhysicsLocalAnchor on: first at: 20 @ 10.
	anchorB := CFPhysicsLocalAnchor on: second at: 0 @ 10.
	spring := CFPhysicsSpringConstraint betweenAnchor: anchorA andAnchor: anchorB.
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

{ #category : 'examples - anchors' }
CFPhysicsCleanSlateTests >> normalisedAnchorFollowsBodyGeometry [
	<gtExample>
	| body anchor |
	body := self cleanSlateBodyWithSequence: 1 position: 100 @ 50 extent: 40 @ 20.
	anchor := CFPhysicsNormalisedAnchor on: body at: 1 @ 0.5.
	self assert: anchor body == body.
	self assert: anchor normalisedPoint equals: 1 @ 0.5.
	self assert: anchor worldPoint equals: 120 @ 50.
	body element size: 80 @ 40.
	self assert: anchor worldPoint equals: 140 @ 50.
	body rotation: Float pi / 2.
	self assert: (anchor worldPoint closeTo: 100 @ 90).
	^ anchor
]

{ #category : 'examples - anchors' }
CFPhysicsCleanSlateTests >> elementCanCreateANormalisedAnchor [
	<gtExample>
	| owner element world anchor |
	owner := BlElement new size: 400 @ 300; yourself.
	element := BlElement new size: 40 @ 20; yourself.
	owner addChild: element.
	world := owner physics beWorld.
	world synchroniseMembership.
	element physics position: 100 @ 50.
	anchor := element physics normalisedAnchorAt: 1 @ 1.
	self assert: anchor class equals: CFPhysicsNormalisedAnchor.
	self assert: anchor body == element physics bodyState.
	self assert: anchor worldPoint equals: 120 @ 60.
	^ anchor
]

{ #category : 'examples - anchors' }
CFPhysicsCleanSlateTests >> relationshipsCanResolveNormalisedAnchors [
	<gtExample>
	| first second anchorA anchorB spring attraction repulsion |
	first := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self cleanSlateBodyWithSequence: 2 position: 100 @ 0 extent: 40 @ 20.
	anchorA := CFPhysicsNormalisedAnchor on: first at: 1 @ 0.5.
	anchorB := CFPhysicsNormalisedAnchor on: second at: 0 @ 0.5.
	spring := CFPhysicsSpringConstraint betweenAnchor: anchorA andAnchor: anchorB.
	attraction := CFPhysicsAttractionConstraint betweenAnchor: anchorA andAnchor: anchorB.
	repulsion := CFPhysicsRepulsionConstraint betweenAnchor: anchorA andAnchor: anchorB.
	self assert: spring anchorA == anchorA.
	self assert: attraction anchorA == anchorA.
	self assert: repulsion anchorA == anchorA.
	self assert: anchorA worldPoint equals: 10 @ 0.
	self assert: anchorB worldPoint equals: 80 @ 0.
	^ { spring. attraction. repulsion }
]

{ #category : 'examples - anchors' }
CFPhysicsCleanSlateTests >> explicitAnchorsCanCreateWorldOwnedRelationships [
	<gtExample>
	| owner first second world anchorA anchorB spring attraction repulsion |
	owner := BlElement new size: 400 @ 300; yourself.
	first := BlElement new size: 40 @ 20; yourself.
	second := BlElement new size: 60 @ 30; yourself.
	owner addChildren: { first. second }.
	world := owner physics beWorld.
	world synchroniseMembership.
	first physics position: 20 @ 30.
	second physics position: 200 @ 80.
	anchorA := first physics localAnchorAt: 40 @ 10.
	anchorB := second physics normalisedAnchorAt: 0 @ 0.5.
	spring := anchorA springTo: anchorB.
	attraction := anchorA attract: anchorB.
	repulsion := anchorA repel: anchorB.
	self assert: spring anchorA == anchorA.
	self assert: spring anchorB == anchorB.
	self assert: attraction anchorA == anchorA.
	self assert: attraction anchorB == anchorB.
	self assert: repulsion anchorA == anchorA.
	self assert: repulsion anchorB == anchorB.
	self assert: world springConstraints equals: { spring }.
	self assert: world attractionConstraints equals: { attraction }.
	self assert: world repulsionConstraints equals: { repulsion }.
	^ { spring. attraction. repulsion }
]

{ #category : 'examples - attraction interaction' }
CFPhysicsCleanSlateTests >> linearFalloffResponseVariesSmoothlyWithDistance [
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

{ #category : 'examples - attraction interaction' }
CFPhysicsCleanSlateTests >> attractionCanUseLinearFalloffResponse [
	<gtExample>
	| first second attraction response |
	first := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self cleanSlateBodyWithSequence: 2 position: 90 @ 0 extent: 20 @ 20.
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

{ #category : 'examples - repulsion interaction' }
CFPhysicsCleanSlateTests >> repulsionCanUseLinearFalloffResponse [
	<gtExample>
	| first second repulsion response |
	first := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self cleanSlateBodyWithSequence: 2 position: 90 @ 0 extent: 20 @ 20.
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


{ #category : 'examples - attraction interaction' }
CFPhysicsCleanSlateTests >> softenedInverseSquareResponseFallsOffWithoutSingularity [
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

{ #category : 'examples - attraction interaction' }
CFPhysicsCleanSlateTests >> attractionCanUseSoftenedInverseSquareResponse [
	<gtExample>
	| first second attraction response |
	first := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self cleanSlateBodyWithSequence: 2 position: 90 @ 0 extent: 20 @ 20.
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

{ #category : 'examples - repulsion interaction' }
CFPhysicsCleanSlateTests >> repulsionCanUseSoftenedInverseSquareResponse [
	<gtExample>
	| first second repulsion response |
	first := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self cleanSlateBodyWithSequence: 2 position: 90 @ 0 extent: 20 @ 20.
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


{ #category : 'examples - relationship endpoints' }
CFPhysicsCleanSlateTests >> anchoredEndpointPairResolvesBothEndpointsTogether [
	<gtExample>
	| first second anchorA anchorB endpoints points |
	first := self cleanSlateBodyWithSequence: 1 position: 10 @ 20 extent: 40 @ 20.
	second := self cleanSlateBodyWithSequence: 2 position: 100 @ 50 extent: 60 @ 30.
	anchorA := CFPhysicsLocalAnchor on: first at: 20 @ 0.
	anchorB := CFPhysicsNormalisedAnchor on: second at: 0 @ 0.5.
	endpoints := CFPhysicsAnchoredEndpointPair anchorA: anchorA anchorB: anchorB.
	self assert: endpoints anchorA == anchorA.
	self assert: endpoints anchorB == anchorB.
	self assert: endpoints bodyA == first.
	self assert: endpoints bodyB == second.
	points := endpoints worldPoints.
	self assert: points first equals: 30 @ 20.
	self assert: points second equals: 70 @ 50.
	self assert: endpoints worldPointA equals: points first.
	self assert: endpoints worldPointB equals: points second.
	^ endpoints
]

{ #category : 'examples - relationship endpoints' }
CFPhysicsCleanSlateTests >> relationshipsResolveThroughAnEndpointPair [
	<gtExample>
	| first second endpoints spring attraction repulsion |
	first := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self cleanSlateBodyWithSequence: 2 position: 100 @ 0 extent: 20 @ 20.
	endpoints := CFPhysicsAnchoredEndpointPair
		anchorA: (CFPhysicsLocalAnchor on: first at: 10 @ 0)
		anchorB: (CFPhysicsLocalAnchor on: second at: -10 @ 0).
	spring := CFPhysicsSpringConstraint betweenEndpoints: endpoints.
	attraction := CFPhysicsAttractionConstraint betweenEndpoints: endpoints.
	repulsion := CFPhysicsRepulsionConstraint betweenEndpoints: endpoints.
	self assert: spring endpointPair == endpoints.
	self assert: attraction endpointPair == endpoints.
	self assert: repulsion endpointPair == endpoints.
	self assert: spring restLength equals: 80.0.
	self assert: spring bodyA == first.
	self assert: spring bodyB == second.
	self assert: attraction bodyA == first.
	self assert: repulsion bodyB == second.
	^ { spring. attraction. repulsion }
]


{ #category : 'examples - anchors' }
CFPhysicsCleanSlateTests >> worldAnchorRemainsAtItsWorldPoint [
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

{ #category : 'examples - anchors' }
CFPhysicsCleanSlateTests >> springCanAttachABodyToAWorldPoint [
	<gtExample>
	| world body bodyAnchor worldAnchor spring |
	world := CFPhysicsWorld new.
	body := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	body world: world.
	bodyAnchor := CFPhysicsBodyCentreAnchor on: body.
	worldAnchor := world anchorAt: 110 @ 10.
	spring := bodyAnchor springTo: worldAnchor.
	spring restLength: 50; damping: 0.
	spring prepareForStep: 0.1.
	self assert: spring bodyA == body.
	self assert: spring bodyB isNil.
	self assert: body velocity x > 0.
	^ spring
]

{ #category : 'examples - anchors' }
CFPhysicsCleanSlateTests >> attractionAndRepulsionCanUseWorldAnchors [
	<gtExample>
	| world attracted repelled attraction repulsion |
	world := CFPhysicsWorld new.
	attracted := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	repelled := self cleanSlateBodyWithSequence: 2 position: 0 @ 40 extent: 20 @ 20.
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

{ #category : 'examples - anchors' }
CFPhysicsCleanSlateTests >> worldAnchorRelationshipsStillCleanUpWithTheirBody [
	<gtExample>
	| world body spring |
	world := CFPhysicsWorld new.
	body := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	body world: world.
	spring := (CFPhysicsBodyCentreAnchor on: body)
		springTo: (world anchorAt: 100 @ 10).
	world removeSpringsUsingBody: body.
	self assert: world springConstraints isEmpty.
	self assert: spring isActive not.
	^ spring
]


{ #category : 'examples - relationship endpoints' }
CFPhysicsCleanSlateTests >> nearestGeometryEndpointsResolveCircleBoundaries [
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

{ #category : 'examples - relationship endpoints' }
CFPhysicsCleanSlateTests >> nearestGeometryEndpointsResolveRectangleEdges [
	<gtExample>
	| first second endpoints points |
	first := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 40 @ 40.
	second := self cleanSlateBodyWithSequence: 2 position: 100 @ 10 extent: 30 @ 20.
	endpoints := CFPhysicsNearestGeometryEndpointPair between: first and: second.
	points := endpoints worldPoints.
	self assert: points first equals: 40 @ 20.
	self assert: points second equals: 100 @ 20.
	^ endpoints
]

{ #category : 'examples - relationship endpoints' }
CFPhysicsCleanSlateTests >> nearestGeometryEndpointPairTracksCurrentGeometry [
	<gtExample>
	| first second endpoints initial moved |
	first := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self cleanSlateBodyWithSequence: 2 position: 100 @ 0 extent: 20 @ 20.
	endpoints := CFPhysicsNearestGeometryEndpointPair between: first and: second.
	initial := endpoints worldPoints.
	second position: 60 @ 40.
	moved := endpoints worldPoints.
	self assert: initial equals: { 20 @ 10. 100 @ 10 }.
	self assert: moved ~= initial.
	self assert: ((moved second - moved first) r) < ((initial second - initial first) r).
	^ endpoints
]

{ #category : 'examples - relationship endpoints' }
CFPhysicsCleanSlateTests >> nearestGeometryEndpointsCreateWorldOwnedRelationships [
	<gtExample>
	| world first second endpoints spring attraction repulsion |
	world := CFPhysicsWorld new.
	first := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self cleanSlateBodyWithSequence: 2 position: 100 @ 0 extent: 20 @ 20.
	first world: world.
	second world: world.
	endpoints := CFPhysicsNearestGeometryEndpointPair between: first and: second.
	spring := endpoints spring.
	attraction := endpoints attraction.
	repulsion := endpoints repulsion.
	self assert: spring endpointPair == endpoints.
	self assert: attraction endpointPair == endpoints.
	self assert: repulsion endpointPair == endpoints.
	self assert: world springConstraints equals: { spring }.
	self assert: world attractionConstraints equals: { attraction }.
	self assert: world repulsionConstraints equals: { repulsion }.
	^ { spring. attraction. repulsion }
]


{ #category : 'examples - constraints' }
CFPhysicsCleanSlateTests >> constraintBuilderScalesRetainedImpulsesForChangedTimeStep [
	<gtExample>
	| first second pair manifold contact bodyStates constraint point |
	first := self cleanSlateBodyWithSequence: 1.
	first beStatic.
	second := self cleanSlateBodyWithSequence: 2.
	pair := CFPhysicsPair first: first second: second.
	manifold := self cleanSlateManifoldWithFeatureIndex: 1.
	manifold contactPoints first
		normalImpulse: 8.0;
		tangentImpulse: -2.0.
	contact := CFPhysicsContact pair: pair manifold: manifold.
	bodyStates := IdentityDictionary new
		at: first put: (CFPhysicsBodyStepState on: first);
		at: second put: (CFPhysicsBodyStepState on: second);
		yourself.
	constraint := (CFPhysicsConstraintBuilder new
		constraintsFrom: { contact }
		bodyStates: bodyStates
		warmStartRatio: 0.5) first.
	point := constraint points first.
	self assert: point normalImpulse equals: 4.0.
	self assert: point tangentImpulse equals: -1.0.
	^ constraint
]

{ #category : 'examples - stepping' }
CFPhysicsCleanSlateTests >> worldSimulationIdentityStartsAtZero [
	<gtExample>
	| world step |
	world := CFPhysicsWorld on: BlElement new.
	self assert: world simulationTime equals: 0.0.
	self assert: world stepNumber equals: 0.
	step := world newStep.
	self assert: step simulationTime equals: 0.0.
	self assert: step stepNumber equals: 1.
	self assert: world simulationTime equals: 0.0.
	self assert: world stepNumber equals: 0.
	^ world
]

{ #category : 'examples - stepping' }
CFPhysicsCleanSlateTests >> worldAdvancesSimulationIdentityAfterSuccessfulSteps [
	<gtExample>
	| world firstResult secondResult |
	world := CFPhysicsWorld on: BlElement new.
	firstResult := world step.
	self assert: firstResult step simulationTime equals: 0.0.
	self assert: firstResult step stepNumber equals: 1.
	self assert: (world simulationTime closeTo: 0.016).
	self assert: world stepNumber equals: 1.
	secondResult := world step.
	self assert: (secondResult step simulationTime closeTo: 0.016).
	self assert: secondResult step stepNumber equals: 2.
	self assert: (world simulationTime closeTo: 0.032).
	self assert: world stepNumber equals: 2.
	^ secondResult
]

{ #category : 'examples - stepping' }
CFPhysicsCleanSlateTests >> changingStepDurationPreservesAccumulatedSimulationTime [
	<gtExample>
	| world result |
	world := CFPhysicsWorld on: BlElement new.
	world step.
	world stepDuration: 8 milliseconds.
	result := world step.
	self assert: (result step simulationTime closeTo: 0.016).
	self assert: result step stepNumber equals: 2.
	self assert: (world simulationTime closeTo: 0.024).
	self assert: world stepNumber equals: 2.
	^ result
]

{ #category : 'examples - stepping' }
CFPhysicsCleanSlateTests >> worldScalesWarmStartingWhenStepDurationChanges [
	<gtExample>
	| world firstStep secondStep |
	world := CFPhysicsWorld on: BlElement new.
	firstStep := world newStep.
	self assert: firstStep warmStartRatio equals: 1.0.
	world step.
	world stepDuration: 8 milliseconds.
	secondStep := world newStep.
	self assert: secondStep warmStartRatio equals: 0.5.
	^ secondStep
]

{ #category : 'examples - stepping' }
CFPhysicsCleanSlateTests >> worldWarmStartingDefaultsToEnabled [
	<gtExample>
	| world |
	world := CFPhysicsWorld new.
	self assert: world warmStarting.
	^ world
]

{ #category : 'examples - stepping' }
CFPhysicsCleanSlateTests >> worldCanDisableAndResumeWarmStarting [
	<gtExample>
	| world disabledStep resumedStep |
	world := CFPhysicsWorld on: BlElement new.
	world step.

	world warmStarting: false.
	world stepDuration: 8 milliseconds.
	disabledStep := world newStep.
	self assert: disabledStep warmStartRatio equals: 0.0.
	world step.

	world warmStarting: true.
	world stepDuration: 4 milliseconds.
	resumedStep := world newStep.
	self assert: resumedStep warmStartRatio equals: 0.5.
	^ resumedStep
]

{ #category : 'examples - contacts' }
CFPhysicsCleanSlateTests >> manifoldRejectsImpulsesWhenNormalReverses [
	<gtExample>
	| featureId oldPoint oldManifold newPoint newManifold |
	featureId := CFPhysicsContactFeatureId
		featureA: #face index: 0 featureB: #vertex index: 1.
	oldPoint := CFPhysicsManifoldPoint at: 10 @ 20.
	oldPoint
		featureId: featureId;
		normalImpulse: 7.5;
		tangentImpulse: -1.25.
	oldManifold := CFPhysicsManifold new
		normal: 0 @ 1;
		contactPoints: { oldPoint };
		yourself.

	newPoint := CFPhysicsManifoldPoint at: 10 @ 20.
	newPoint featureId: featureId.
	newManifold := CFPhysicsManifold new
		normal: 0 @ -1;
		contactPoints: { newPoint };
		preserveImpulsesFrom: oldManifold;
		yourself.

	self assert: newPoint normalImpulse equals: 0.0.
	self assert: newPoint tangentImpulse equals: 0.0.
	^ newManifold
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> aabbMergesBothBounds [
	<gtExample>
	| first second merged |
	first := CFPhysicsAABB position: 10 @ 20 extent: 30 @ 40.
	second := CFPhysicsAABB position: -5 @ 35 extent: 25 @ 50.
	merged := first mergedWith: second.
	self assert: merged minimum equals: -5 @ 20.
	self assert: merged maximum equals: 40 @ 85.
	^ merged
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> bodySweptAABBCoversTranslation [
	<gtExample>
	| element body bounds |
	element := BlElement new extent: 20 @ 10.
	body := CFPhysicsBody element: element world: nil.
	body
		position: 10 @ 20;
		beginStep;
		addVelocity: 30 @ -5;
		advanceBy: 1.0 gravity: 0 @ 0.
	bounds := body sweptAABB.
	self assert: bounds minimum equals: 10 @ 15.
	self assert: bounds maximum equals: 60 @ 30.
	^ bounds
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> bodySweptAABBCoversRotationBetweenTransforms [
	<gtExample>
	| element body bounds previousBounds currentBounds |
	element := BlElement new extent: 40 @ 10.
	body := CFPhysicsBody element: element world: nil.
	body
		position: 10 @ 20;
		beginStep;
		addAngularVelocity: Float pi / 2.0;
		advanceBy: 1.0 gravity: 0 @ 0.
	previousBounds := body shapeState aabbAt: body previousPosition rotation: body previousRotation.
	currentBounds := body aabb.
	bounds := body sweptAABB.
	self assert: (bounds overlaps: previousBounds).
	self assert: (bounds overlaps: currentBounds).
	self assert: ((bounds extent x >= (body shapeState boundingRadius * 2.0)) or: [
		bounds extent x closeTo: body shapeState boundingRadius * 2.0 ]).
	self assert: ((bounds extent y >= (body shapeState boundingRadius * 2.0)) or: [
		bounds extent y closeTo: body shapeState boundingRadius * 2.0 ]).
	^ bounds
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> pairFinderReturnsCandidateAcrossSweptPath [
	<gtExample>
	| moving obstacle pairs |
	moving := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 10 @ 10.
	moving
		beginStep;
		addVelocity: 100 @ 0;
		advanceBy: 1.0 gravity: 0 @ 0.
	obstacle := self cleanSlateBodyWithSequence: 2 position: 50 @ 0 extent: 10 @ 10.
	obstacle beStatic.

	self assert: (moving aabb overlaps: obstacle aabb) not.
	self assert: (moving sweptAABB overlaps: obstacle sweptAABB).
	pairs := CFPhysicsPairFinder new pairsAmong: { obstacle. moving }.
	self assert: pairs size equals: 1.
	self assert: pairs first firstBody equals: moving.
	self assert: pairs first secondBody equals: obstacle.
	^ pairs
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> pairFinderRejectsSeparatedSweptPaths [
	<gtExample>
	| moving obstacle pairs |
	moving := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 10 @ 10.
	moving
		beginStep;
		addVelocity: 100 @ 0;
		advanceBy: 1.0 gravity: 0 @ 0.
	obstacle := self cleanSlateBodyWithSequence: 2 position: 50 @ 30 extent: 10 @ 10.
	obstacle beStatic.

	self assert: (moving sweptAABB overlaps: obstacle sweptAABB) not.
	pairs := CFPhysicsPairFinder new pairsAmong: { moving. obstacle }.
	self assert: pairs isEmpty.
	^ pairs
]


{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> bodySweepCapturesStepTransforms [
	<gtExample>
	| body sweep |
	body := self cleanSlateBodyWithSequence: 1 position: 10 @ 20 extent: 10 @ 10.
	body
		beginStep;
		addVelocity: 20 @ 0;
		angularVelocity: Float pi;
		advanceBy: 0.5 gravity: 0 @ 0.
	sweep := body sweep.
	self assert: sweep startTransform position equals: 10 @ 20.
	self assert: sweep startTransform rotation equals: 0.
	self assert: sweep endTransform position equals: 20 @ 20.
	self assert: (sweep endTransform rotation closeTo: Float pi / 2.0).
	^ sweep
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> beginningStepProducesStationarySweep [
	<gtExample>
	| body sweep |
	body := self cleanSlateBodyWithSequence: 1 position: 10 @ 20 extent: 10 @ 10.
	body
		rotation: Float pi / 3.0;
		beginStep.
	sweep := body sweep.
	self assert: sweep startTransform position equals: 10 @ 20.
	self assert: sweep endTransform position equals: 10 @ 20.
	self assert: (sweep startTransform rotation closeTo: Float pi / 3.0).
	self assert: (sweep endTransform rotation closeTo: Float pi / 3.0).
	^ sweep
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> settingTransformResetsSweepEndpoints [
	<gtExample>
	| body sweep |
	body := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 10 @ 10.
	body
		beginStep;
		addVelocity: 20 @ 0;
		addAngularVelocity: Float pi;
		advanceBy: 0.5 gravity: 0 @ 0;
		translation: 40 @ 50 rotation: Float pi / 4.0.
	sweep := body sweep.
	self assert: sweep startTransform position equals: 40 @ 50.
	self assert: sweep endTransform position equals: 40 @ 50.
	self assert: (sweep startTransform rotation closeTo: Float pi / 4.0).
	self assert: (sweep endTransform rotation closeTo: Float pi / 4.0).
	^ sweep
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> sweepInterpolationPreservesIntegratedAngularDisplacement [
	<gtExample>
	| sweep transform |
	sweep := CFPhysicsSweep
		from: (CFPhysicsTransform position: 0 @ 0 rotation: 0.0)
		to: (CFPhysicsTransform position: 0 @ 0 rotation: Float pi * 3.0).
	transform := sweep transformAt: 0.5.
	self assert: (transform rotation closeTo: Float pi * 1.5).
	^ transform
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> sweepInterpolatesTransform [
	<gtExample>
	| sweep transform |
	sweep := CFPhysicsSweep
		from: (CFPhysicsTransform position: 0 @ 10 rotation: 0.0)
		to: (CFPhysicsTransform position: 20 @ 30 rotation: Float pi).
	transform := sweep transformAt: 0.25.
	self assert: transform position equals: 5 @ 15.
	self assert: (transform rotation closeTo: Float pi / 4.0).
	^ transform
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> sweptAABBDelegatesToShapeState [
	<gtExample>
	| body bodyBounds sweepBounds |
	body := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 10 @ 10.
	body
		beginStep;
		addVelocity: 100 @ 0;
		advanceBy: 1.0 gravity: 0 @ 0.
	bodyBounds := body sweptAABB.
	sweepBounds := body shapeState sweptAABBAlong: body sweep.
	self assert: bodyBounds minimum equals: sweepBounds minimum.
	self assert: bodyBounds maximum equals: sweepBounds maximum.
	^ bodyBounds
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> stepStatePredictsLinearMovement [
	<gtExample>
	| body state transform |
	body := self cleanSlateBodyWithSequence: 1 position: 10 @ 20 extent: 10 @ 10.
	body velocity: 12 @ -4.
	state := CFPhysicsBodyStepState on: body.
	transform := state predictedTransformAfter: 0.5.
	self assert: transform position equals: 16 @ 18.
	self assert: transform rotation equals: 0.
	self assert: body position equals: 10 @ 20.
	^ transform
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> stepStatePredictsAngularMovement [
	<gtExample>
	| body state transform |
	body := self cleanSlateBodyWithSequence: 1 position: 10 @ 20 extent: 10 @ 10.
	body angularVelocity: Float pi.
	state := CFPhysicsBodyStepState on: body.
	transform := state predictedTransformAfter: 0.5.
	self assert: transform position equals: 10 @ 20.
	self assert: (transform rotation closeTo: Float pi / 2.0).
	self assert: body rotation equals: 0.
	^ transform
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> stepStatePredictsCombinedMovementSweep [
	<gtExample>
	| body state sweep |
	body := self cleanSlateBodyWithSequence: 1 position: 10 @ 20 extent: 10 @ 10.
	body
		rotation: Float pi / 4.0;
		velocity: 8 @ 6;
		angularVelocity: Float pi / 2.0.
	state := CFPhysicsBodyStepState on: body.
	sweep := state predictedSweepFor: 2.0.
	self assert: sweep startTransform position equals: 10 @ 20.
	self assert: (sweep startTransform rotation closeTo: Float pi / 4.0).
	self assert: sweep endTransform position equals: 26 @ 32.
	self assert: (sweep endTransform rotation closeTo: Float pi * 1.25).
	^ sweep
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> staticStepStatePredictsStationarySweep [
	<gtExample>
	| body state sweep |
	body := self cleanSlateBodyWithSequence: 1 position: 10 @ 20 extent: 10 @ 10.
	body beStatic.
	state := CFPhysicsBodyStepState on: body.
	state
		linearVelocity: 100 @ 50;
		angularVelocity: Float pi.
	sweep := state predictedSweepFor: 1.0.
	self assert: sweep startTransform position equals: 10 @ 20.
	self assert: sweep endTransform position equals: 10 @ 20.
	self assert: sweep startTransform rotation equals: 0.
	self assert: sweep endTransform rotation equals: 0.
	^ sweep
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> sleepingStepStatePredictsStationarySweep [
	<gtExample>
	| body state sweep |
	body := self cleanSlateBodyWithSequence: 1 position: 10 @ 20 extent: 10 @ 10.
	body sleep.
	state := CFPhysicsBodyStepState on: body.
	state
		linearVelocity: 100 @ 50;
		angularVelocity: Float pi.
	sweep := state predictedSweepFor: 1.0.
	self assert: sweep startTransform position equals: 10 @ 20.
	self assert: sweep endTransform position equals: 10 @ 20.
	self assert: sweep startTransform rotation equals: 0.
	self assert: sweep endTransform rotation equals: 0.
	^ sweep
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> zeroDurationPredictionProducesStationarySweep [
	<gtExample>
	| body state sweep |
	body := self cleanSlateBodyWithSequence: 1 position: 10 @ 20 extent: 10 @ 10.
	body
		rotation: Float pi / 3.0;
		velocity: 100 @ 50;
		angularVelocity: Float pi.
	state := CFPhysicsBodyStepState on: body.
	sweep := state predictedSweepFor: 0.0.
	self assert: sweep startTransform position equals: sweep endTransform position.
	self assert: (sweep startTransform rotation closeTo: sweep endTransform rotation).
	^ sweep
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> stepPipelineDiscoversCandidateAcrossPredictedPath [
	<gtExample>
	| moving obstacle step pipeline result predictedEndBounds impact |
	moving := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 10 @ 10.
	moving velocity: 100 @ 0.
	obstacle := self cleanSlateBodyWithSequence: 2 position: 50 @ 0 extent: 10 @ 10.
	obstacle beStatic.
	step := CFPhysicsStep
		timeStep: 1.0
		substeps: 1
		contactHertz: 30.0
		dampingRatio: 10.0.
	pipeline := CFPhysicsStepPipeline manifoldBuilder: [ :pair |
		CFPhysicsBlocManifoldBuilder
			manifoldBetweenBody: pair firstBody
			andBody: pair secondBody ].
	result := pipeline
		stepBodies: { obstacle. moving }
		fromContacts: #()
		step: step
		gravity: 0 @ 0
		restitutionThreshold: 1.0.
	predictedEndBounds := moving shapeState
		aabbAt: 100 @ 0
		rotation: moving rotation.
	self assert: ((moving shapeState aabbAt: 0 @ 0 rotation: 0.0) overlaps: obstacle aabb) not.
	self assert: (predictedEndBounds overlaps: obstacle aabb) not.
	self assert: result pairs isEmpty.
	self assert: result activeContacts isEmpty.
	self assert: result hasContinuousImpact.
	impact := result continuousStepResult impacts first.
	self assert: impact pair firstBody equals: moving.
	self assert: impact pair secondBody equals: obstacle.
	^ result
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> discretePairDiscoveryDoesNotMutateBodies [
	<gtExample>
	| moving obstacle step result |
	moving := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 10 @ 10.
	moving velocity: 100 @ 0.
	obstacle := self cleanSlateBodyWithSequence: 2 position: 50 @ 0 extent: 10 @ 10.
	obstacle beStatic.
	step := CFPhysicsStep
		timeStep: 1.0
		substeps: 1
		contactHertz: 30.0
		dampingRatio: 10.0.
	result := CFPhysicsStepPipelineResult new
		step: step;
		bodies: { obstacle. moving };
		previousContacts: #();
		gravity: 0 @ 0;
		restitutionThreshold: 1.0;
		yourself.
	CFPhysicsBodyStateCaptureStage new executeOn: result.
	CFPhysicsVelocityIntegrationStage new executeOn: result.
	CFPhysicsPairFinderStage new executeOn: result.
	self assert: moving position equals: 0 @ 0.
	self assert: moving rotation equals: 0.0.
	self assert: result pairs isEmpty.
	^ result
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> discretePairDiscoveryDoesNotUsePreparedVelocityForSweeps [
	<gtExample>
	| moving obstacle step result state |
	moving := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 10 @ 10.
	obstacle := self cleanSlateBodyWithSequence: 2 position: 50 @ 0 extent: 10 @ 10.
	obstacle beStatic.
	step := CFPhysicsStep
		timeStep: 1.0
		substeps: 1
		contactHertz: 30.0
		dampingRatio: 10.0.
	result := CFPhysicsStepPipelineResult new
		step: step;
		bodies: { obstacle. moving };
		previousContacts: #();
		gravity: 100 @ 0;
		restitutionThreshold: 1.0;
		yourself.
	CFPhysicsBodyStateCaptureStage new executeOn: result.
	CFPhysicsVelocityIntegrationStage new executeOn: result.
	CFPhysicsPairFinderStage new executeOn: result.
	state := result bodyStates at: moving.
	self assert: state linearVelocity equals: 100 @ 0.
	self assert: moving velocity equals: 0 @ 0.
	self assert: result pairs isEmpty.
	^ result
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> predictedPairDiscoveryPreservesDeterministicOrder [
	<gtExample>
	| first second third step result sequences |
	first := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 10 @ 10.
	second := self cleanSlateBodyWithSequence: 2 position: 0 @ 0 extent: 10 @ 10.
	third := self cleanSlateBodyWithSequence: 3 position: 0 @ 0 extent: 10 @ 10.
	step := CFPhysicsStep
		timeStep: 1.0
		substeps: 1
		contactHertz: 30.0
		dampingRatio: 10.0.
	result := CFPhysicsStepPipelineResult new
		step: step;
		bodies: { third. first. second };
		previousContacts: #();
		gravity: 0 @ 0;
		restitutionThreshold: 1.0;
		yourself.
	CFPhysicsBodyStateCaptureStage new executeOn: result.
	CFPhysicsVelocityIntegrationStage new executeOn: result.
	CFPhysicsPairFinderStage new executeOn: result.
	sequences := result pairs collect: [ :pair |
		{ pair firstBody sequence. pair secondBody sequence } ].
	self assert: sequences equals: #(#(1 2) #(1 3) #(2 3)).
	^ result
]


{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> gjkUsesExplicitTransformsForOverlapQueries [
	<gtExample>
	| first second firstTransform overlappingTransform separatedTransform overlappingSimplex separatedSimplex |
	first := CFPhysicsShapeState on: (BlElement new size: 20 @ 20; yourself).
	second := CFPhysicsShapeState on: (BlElement new size: 20 @ 20; yourself).
	firstTransform := CFPhysicsTransform position: 0 @ 0 rotation: 0.
	overlappingTransform := CFPhysicsTransform position: 10 @ 0 rotation: 0.
	separatedTransform := CFPhysicsTransform position: 30 @ 0 rotation: 0.
	overlappingSimplex := CFPhysicsGJK
		simplexBetweenShapeState: first
		transform: firstTransform
		andShapeState: second
		transform: overlappingTransform.
	separatedSimplex := CFPhysicsGJK
		simplexBetweenShapeState: first
		transform: firstTransform
		andShapeState: second
		transform: separatedTransform.
	self assert: overlappingSimplex notNil.
	self assert: separatedSimplex isNil.
	^ overlappingSimplex
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> gjkExplicitTransformQueryIncludesRotation [
	<gtExample>
	| first second firstTransform secondTransform simplex |
	first := CFPhysicsShapeState on: (BlElement new size: 40 @ 10; yourself).
	second := CFPhysicsShapeState on: (BlElement new size: 10 @ 10; yourself).
	firstTransform := CFPhysicsTransform position: 0 @ 0 rotation: Float pi / 2.0.
	secondTransform := CFPhysicsTransform position: 14 @ 14 rotation: 0.
	simplex := CFPhysicsGJK
		simplexBetweenShapeState: first
		transform: firstTransform
		andShapeState: second
		transform: secondTransform.
	self assert: simplex notNil.
	^ simplex
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> gjkDistanceReportsSeparationAndWitnessPoints [
	<gtExample>
	| first second result separation |
	first := CFPhysicsShapeState on: (BlElement new size: 20 @ 20; yourself).
	second := CFPhysicsShapeState on: (BlElement new size: 20 @ 20; yourself).
	result := CFPhysicsGJK
		distanceBetweenShapeState: first
		transform: (CFPhysicsTransform position: 0 @ 0 rotation: 0)
		andShapeState: second
		transform: (CFPhysicsTransform position: 30 @ 0 rotation: 0).
	separation := result secondPoint - result firstPoint.
	self assert: result isSeparated.
	self assert: (result distance closeTo: 10.0).
	self assert: (separation r closeTo: result distance).
	self assert: (result axis x closeTo: 1.0).
	self assert: (result axis y closeTo: 0.0).
	^ result
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> gjkDistanceUsesExplicitRotation [
	<gtExample>
	| first second result |
	first := CFPhysicsShapeState on: (BlElement new size: 40 @ 10; yourself).
	second := CFPhysicsShapeState on: (BlElement new size: 10 @ 10; yourself).
	result := CFPhysicsGJK
		distanceBetweenShapeState: first
		transform: (CFPhysicsTransform position: 0 @ 0 rotation: Float pi / 2.0)
		andShapeState: second
		transform: (CFPhysicsTransform position: 30 @ 0 rotation: 0).
	self assert: result isSeparated.
	self assert: result distance > 0.
	self assert: ((result secondPoint - result firstPoint) r closeTo: result distance).
	^ result
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> gjkDistanceReportsOverlap [
	<gtExample>
	| first second result |
	first := CFPhysicsShapeState on: (BlElement new size: 20 @ 20; yourself).
	second := CFPhysicsShapeState on: (BlElement new size: 20 @ 20; yourself).
	result := CFPhysicsGJK
		distanceBetweenShapeState: first
		transform: (CFPhysicsTransform position: 0 @ 0 rotation: 0)
		andShapeState: second
		transform: (CFPhysicsTransform position: 10 @ 0 rotation: 0).
	self assert: result isOverlapping.
	self assert: (result distance closeTo: 0.0).
	self assert: result axis equals: 0 @ 0.
	^ result
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> conservativeAdvancementFindsLinearImpact [
	<gtExample>
	| first second firstSweep secondSweep result |
	first := CFPhysicsShapeState on: (BlElement new size: 20 @ 20; yourself).
	second := CFPhysicsShapeState on: (BlElement new size: 20 @ 20; yourself).
	firstSweep := CFPhysicsSweep
		from: (CFPhysicsTransform position: 0 @ 0 rotation: 0)
		to: (CFPhysicsTransform position: 40 @ 0 rotation: 0).
	secondSweep := CFPhysicsSweep
		from: (CFPhysicsTransform position: 30 @ 0 rotation: 0)
		to: (CFPhysicsTransform position: 30 @ 0 rotation: 0).
	result := CFPhysicsConservativeAdvancement
		betweenShapeState: first
		sweep: firstSweep
		andShapeState: second
		sweep: secondSweep.
	self assert: result hasImpact.
	self assert: (result fraction closeTo: 0.25).
	self assert: result distanceResult distance <= 1.0e-7.
	^ result
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> conservativeAdvancementReportsInitialOverlap [
	<gtExample>
	| first second firstSweep secondSweep result |
	first := CFPhysicsShapeState on: (BlElement new size: 20 @ 20; yourself).
	second := CFPhysicsShapeState on: (BlElement new size: 20 @ 20; yourself).
	firstSweep := CFPhysicsSweep
		from: (CFPhysicsTransform position: 0 @ 0 rotation: 0)
		to: (CFPhysicsTransform position: 10 @ 0 rotation: 0).
	secondSweep := CFPhysicsSweep
		from: (CFPhysicsTransform position: 10 @ 0 rotation: 0)
		to: (CFPhysicsTransform position: 10 @ 0 rotation: 0).
	result := CFPhysicsConservativeAdvancement
		betweenShapeState: first
		sweep: firstSweep
		andShapeState: second
		sweep: secondSweep.
	self assert: result hasImpact.
	self assert: (result fraction closeTo: 0.0).
	^ result
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> conservativeAdvancementReportsSeparatingMotion [
	<gtExample>
	| first second firstSweep secondSweep result |
	first := CFPhysicsShapeState on: (BlElement new size: 20 @ 20; yourself).
	second := CFPhysicsShapeState on: (BlElement new size: 20 @ 20; yourself).
	firstSweep := CFPhysicsSweep
		from: (CFPhysicsTransform position: 0 @ 0 rotation: 0)
		to: (CFPhysicsTransform position: -20 @ 0 rotation: 0).
	secondSweep := CFPhysicsSweep
		from: (CFPhysicsTransform position: 30 @ 0 rotation: 0)
		to: (CFPhysicsTransform position: 30 @ 0 rotation: 0).
	result := CFPhysicsConservativeAdvancement
		betweenShapeState: first
		sweep: firstSweep
		andShapeState: second
		sweep: secondSweep.
	self assert: result isSeparated.
	self assert: (result fraction closeTo: 1.0).
	^ result
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> conservativeAdvancementUsesRelativeMotion [
	<gtExample>
	| first second firstSweep secondSweep result |
	first := CFPhysicsShapeState on: (BlElement new size: 20 @ 20; yourself).
	second := CFPhysicsShapeState on: (BlElement new size: 20 @ 20; yourself).
	firstSweep := CFPhysicsSweep
		from: (CFPhysicsTransform position: 0 @ 0 rotation: 0)
		to: (CFPhysicsTransform position: 20 @ 0 rotation: 0).
	secondSweep := CFPhysicsSweep
		from: (CFPhysicsTransform position: 40 @ 0 rotation: 0)
		to: (CFPhysicsTransform position: 20 @ 0 rotation: 0).
	result := CFPhysicsConservativeAdvancement
		betweenShapeState: first
		sweep: firstSweep
		andShapeState: second
		sweep: secondSweep.
	self assert: result hasImpact.
	self assert: (result fraction closeTo: 0.5).
	^ result
]


{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> earliestImpactFinderSelectsSmallestFraction [
	<gtExample>
	| moving near far bodyStates nearPair farPair result |
	moving := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	near := self cleanSlateBodyWithSequence: 2 position: 30 @ 0 extent: 20 @ 20.
	far := self cleanSlateBodyWithSequence: 3 position: 50 @ 0 extent: 20 @ 20.
	near beStatic.
	far beStatic.
	bodyStates := IdentityDictionary new
		at: moving put: (CFPhysicsBodyStepState on: moving);
		at: near put: (CFPhysicsBodyStepState on: near);
		at: far put: (CFPhysicsBodyStepState on: far);
		yourself.
	(bodyStates at: moving) linearVelocity: 40 @ 0.
	nearPair := CFPhysicsPair first: moving second: near.
	farPair := CFPhysicsPair first: moving second: far.
	result := CFPhysicsEarliestImpactFinder new
		earliestAmong: { farPair. nearPair }
		bodyStates: bodyStates
		for: 1.0.
	self assert: result pair equals: nearPair.
	self assert: (result fraction closeTo: 0.25).
	^ result
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> earliestImpactFinderBreaksFractionTiesByPairOrder [
	<gtExample>
	| moving firstObstacle secondObstacle bodyStates firstPair secondPair result |
	moving := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	firstObstacle := self cleanSlateBodyWithSequence: 2 position: 30 @ 0 extent: 20 @ 20.
	secondObstacle := self cleanSlateBodyWithSequence: 3 position: 30 @ 0 extent: 20 @ 20.
	firstObstacle beStatic.
	secondObstacle beStatic.
	bodyStates := IdentityDictionary new
		at: moving put: (CFPhysicsBodyStepState on: moving);
		at: firstObstacle put: (CFPhysicsBodyStepState on: firstObstacle);
		at: secondObstacle put: (CFPhysicsBodyStepState on: secondObstacle);
		yourself.
	(bodyStates at: moving) linearVelocity: 40 @ 0.
	firstPair := CFPhysicsPair first: moving second: firstObstacle.
	secondPair := CFPhysicsPair first: moving second: secondObstacle.
	result := CFPhysicsEarliestImpactFinder new
		earliestAmong: { secondPair. firstPair }
		bodyStates: bodyStates
		for: 1.0.
	self assert: result pair equals: firstPair.
	self assert: (result fraction closeTo: 0.25).
	^ result
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> earliestImpactFinderIgnoresSeparatedPairs [
	<gtExample>
	| moving obstacle bodyStates pair result |
	moving := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	obstacle := self cleanSlateBodyWithSequence: 2 position: 30 @ 0 extent: 20 @ 20.
	obstacle beStatic.
	bodyStates := IdentityDictionary new
		at: moving put: (CFPhysicsBodyStepState on: moving);
		at: obstacle put: (CFPhysicsBodyStepState on: obstacle);
		yourself.
	(bodyStates at: moving) linearVelocity: -20 @ 0.
	pair := CFPhysicsPair first: moving second: obstacle.
	result := CFPhysicsEarliestImpactFinder new
		earliestAmong: { pair }
		bodyStates: bodyStates
		for: 1.0.
	self assert: result isNil.
	^ result
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> earliestImpactFinderDoesNotMutateBodies [
	<gtExample>
	| moving obstacle originalMovingPosition originalObstaclePosition bodyStates pair result |
	moving := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	obstacle := self cleanSlateBodyWithSequence: 2 position: 30 @ 0 extent: 20 @ 20.
	obstacle beStatic.
	originalMovingPosition := moving position.
	originalObstaclePosition := obstacle position.
	bodyStates := IdentityDictionary new
		at: moving put: (CFPhysicsBodyStepState on: moving);
		at: obstacle put: (CFPhysicsBodyStepState on: obstacle);
		yourself.
	(bodyStates at: moving) linearVelocity: 40 @ 0.
	pair := CFPhysicsPair first: moving second: obstacle.
	result := CFPhysicsEarliestImpactFinder new
		earliestAmong: { pair }
		bodyStates: bodyStates
		for: 1.0.
	self assert: result timeOfImpactResult hasImpact.
	self assert: moving position equals: originalMovingPosition.
	self assert: obstacle position equals: originalObstaclePosition.
	^ result
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> impactAdvancerMovesStepStatesToSelectedFraction [
	<gtExample>
	| moving obstacle bodyStates pair impact result |
	moving := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	obstacle := self cleanSlateBodyWithSequence: 2 position: 30 @ 0 extent: 20 @ 20.
	obstacle beStatic.
	bodyStates := IdentityDictionary new
		at: moving put: (CFPhysicsBodyStepState on: moving);
		at: obstacle put: (CFPhysicsBodyStepState on: obstacle);
		yourself.
	(bodyStates at: moving) linearVelocity: 40 @ 0.
	pair := CFPhysicsPair first: moving second: obstacle.
	impact := CFPhysicsEarliestImpactFinder new
		earliestAmong: { pair }
		bodyStates: bodyStates
		for: 1.0.
	result := CFPhysicsImpactAdvancer new
		advanceBodyStates: bodyStates
		to: impact
		for: 1.0.
	self assert: ((bodyStates at: moving) deltaPosition closeTo: 10 @ 0).
	self assert: ((bodyStates at: obstacle) deltaPosition closeTo: 0 @ 0).
	self assert: (result elapsedTime closeTo: 0.25).
	self assert: (result remainingTime closeTo: 0.75).
	self assert: (result fraction closeTo: 0.25).
	^ result
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> impactAdvancerDoesNotCommitAuthoritativeBodies [
	<gtExample>
	| moving obstacle originalMovingPosition originalObstaclePosition bodyStates pair impact result |
	moving := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	obstacle := self cleanSlateBodyWithSequence: 2 position: 30 @ 0 extent: 20 @ 20.
	obstacle beStatic.
	originalMovingPosition := moving position.
	originalObstaclePosition := obstacle position.
	bodyStates := IdentityDictionary new
		at: moving put: (CFPhysicsBodyStepState on: moving);
		at: obstacle put: (CFPhysicsBodyStepState on: obstacle);
		yourself.
	(bodyStates at: moving) linearVelocity: 40 @ 0.
	pair := CFPhysicsPair first: moving second: obstacle.
	impact := CFPhysicsEarliestImpactFinder new
		earliestAmong: { pair }
		bodyStates: bodyStates
		for: 1.0.
	result := CFPhysicsImpactAdvancer new
		advanceBodyStates: bodyStates
		to: impact
		for: 1.0.
	self assert: moving position equals: originalMovingPosition.
	self assert: obstacle position equals: originalObstaclePosition.
	^ result
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> impactAdvancerAdvancesAllMovingStatesThroughSameElapsedTime [
	<gtExample>
	| first second obstacle bodyStates pair impact result |
	first := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self cleanSlateBodyWithSequence: 2 position: 100 @ 0 extent: 20 @ 20.
	obstacle := self cleanSlateBodyWithSequence: 3 position: 30 @ 0 extent: 20 @ 20.
	obstacle beStatic.
	bodyStates := IdentityDictionary new
		at: first put: (CFPhysicsBodyStepState on: first);
		at: second put: (CFPhysicsBodyStepState on: second);
		at: obstacle put: (CFPhysicsBodyStepState on: obstacle);
		yourself.
	(bodyStates at: first) linearVelocity: 40 @ 0.
	(bodyStates at: second) linearVelocity: -8 @ 0.
	pair := CFPhysicsPair first: first second: obstacle.
	impact := CFPhysicsEarliestImpactFinder new
		earliestAmong: { pair }
		bodyStates: bodyStates
		for: 1.0.
	result := CFPhysicsImpactAdvancer new
		advanceBodyStates: bodyStates
		to: impact
		for: 1.0.
	self assert: ((bodyStates at: first) deltaPosition closeTo: 10 @ 0).
	self assert: ((bodyStates at: second) deltaPosition closeTo: -2 @ 0).
	^ result
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> impactManifoldUsesAdvancedStepTransforms [
	<gtExample>
	| moving obstacle bodyStates pair impact advancement manifold |
	moving := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	obstacle := self cleanSlateBodyWithSequence: 2 position: 30 @ 0 extent: 20 @ 20.
	obstacle beStatic.
	bodyStates := IdentityDictionary new
		at: moving put: (CFPhysicsBodyStepState on: moving);
		at: obstacle put: (CFPhysicsBodyStepState on: obstacle);
		yourself.
	(bodyStates at: moving) linearVelocity: 40 @ 0.
	pair := CFPhysicsPair first: moving second: obstacle.
	impact := CFPhysicsEarliestImpactFinder new
		earliestAmong: { pair }
		bodyStates: bodyStates
		for: 1.0.
	advancement := CFPhysicsImpactAdvancer new
		advanceBodyStates: bodyStates
		to: impact
		for: 1.0.
	manifold := CFPhysicsCollision
		manifoldBetweenShapeState: moving shapeState
		transform: (bodyStates at: moving) currentTransform
		andShapeState: obstacle shapeState
		transform: (bodyStates at: obstacle) currentTransform.
	self assert: manifold notNil.
	self assert: (advancement fraction closeTo: 0.25).
	self assert: moving position equals: 0 @ 0.
	self assert: obstacle position equals: 30 @ 0.
	^ manifold
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> transformExplicitManifoldDoesNotUseAuthoritativeTransforms [
	<gtExample>
	| first second manifold |
	first := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self cleanSlateBodyWithSequence: 2 position: 100 @ 0 extent: 20 @ 20.
	manifold := CFPhysicsCollision
		manifoldBetweenShapeState: first shapeState
		transform: (CFPhysicsTransform position: 0 @ 0 rotation: 0.0)
		andShapeState: second shapeState
		transform: (CFPhysicsTransform position: 20 @ 0 rotation: 0.0).
	self assert: manifold notNil.
	self assert: first position equals: 0 @ 0.
	self assert: second position equals: 100 @ 0.
	^ manifold
]


{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> transformExplicitTouchingManifoldProvidesLocalAnchors [
	<gtExample>
	| first second firstTransform secondTransform manifold point |
	first := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self cleanSlateBodyWithSequence: 2 position: 100 @ 0 extent: 20 @ 20.
	firstTransform := CFPhysicsTransform position: 0 @ 0 rotation: 0.0.
	secondTransform := CFPhysicsTransform position: 20 @ 0 rotation: 0.0.
	manifold := CFPhysicsCollision
		manifoldBetweenShapeState: first shapeState
		transform: firstTransform
		andShapeState: second shapeState
		transform: secondTransform.
	point := manifold contactPoints first.
	self assert: point localAnchorA notNil.
	self assert: point localAnchorB notNil.
	self assert: (point localAnchorA closeTo: 20 @ 10).
	self assert: (point localAnchorB closeTo: 0 @ 10).
	^ manifold
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> constraintBuilderUsesAdvancedStepRotation [
	<gtExample>
	| first second firstState secondState bodyStates manifoldPoint manifold contact constraint anchor |
	first := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self cleanSlateBodyWithSequence: 2 position: 20 @ 0 extent: 20 @ 20.
	firstState := CFPhysicsBodyStepState on: first.
	secondState := CFPhysicsBodyStepState on: second.
	firstState angularVelocity: Float pi / 2.0.
	firstState integratePositionBy: 1.0.
	bodyStates := IdentityDictionary new
		at: first put: firstState;
		at: second put: secondState;
		yourself.
	manifoldPoint := CFPhysicsManifoldPoint at: 20 @ 10.
	manifoldPoint
		localAnchorA: 20 @ 10;
		localAnchorB: 0 @ 10.
	manifold := (CFPhysicsManifold normal: 1 @ 0 penetration: 0.0)
		contactPoints: { manifoldPoint };
		yourself.
	contact := CFPhysicsContact
		pair: (CFPhysicsPair first: first second: second)
		manifold: manifold.
	constraint := (CFPhysicsConstraintBuilder new
		constraintsFrom: { contact }
		bodyStates: bodyStates) first.
	anchor := constraint points first anchorA.
	self assert: (anchor closeTo: 0 @ 10).
	^ constraint
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> impactSolverStopsClosingVelocityAtAdvancedTransform [
	<gtExample>
	| moving obstacle bodyStates pair impact advancement step result movingState |
	moving := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	obstacle := self cleanSlateBodyWithSequence: 2 position: 30 @ 0 extent: 20 @ 20.
	obstacle beStatic.
	bodyStates := IdentityDictionary new
		at: moving put: (CFPhysicsBodyStepState on: moving);
		at: obstacle put: (CFPhysicsBodyStepState on: obstacle);
		yourself.
	movingState := bodyStates at: moving.
	movingState linearVelocity: 40 @ 0.
	pair := CFPhysicsPair first: moving second: obstacle.
	impact := CFPhysicsEarliestImpactFinder new
		earliestAmong: { pair }
		bodyStates: bodyStates
		for: 1.0.
	advancement := CFPhysicsImpactAdvancer new
		advanceBodyStates: bodyStates
		to: impact
		for: 1.0.
	step := CFPhysicsStep
		timeStep: advancement remainingTime
		substeps: 4
		contactHertz: 30.0
		dampingRatio: 10.0.
	result := CFPhysicsImpactSolver new
		solveAdvancement: advancement
		bodyStates: bodyStates
		step: step
		restitutionThreshold: 1.0.
	self assert: result hasContact.
	self assert: (movingState linearVelocity x abs < 1.0e-6).
	self assert: (movingState deltaPosition closeTo: 10 @ 0).
	self assert: (result remainingTime closeTo: 0.75).
	^ result
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> impactSolverDoesNotCommitAuthoritativeBodies [
	<gtExample>
	| moving obstacle bodyStates pair impact advancement step result |
	moving := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	obstacle := self cleanSlateBodyWithSequence: 2 position: 30 @ 0 extent: 20 @ 20.
	obstacle beStatic.
	bodyStates := IdentityDictionary new
		at: moving put: (CFPhysicsBodyStepState on: moving);
		at: obstacle put: (CFPhysicsBodyStepState on: obstacle);
		yourself.
	(bodyStates at: moving) linearVelocity: 40 @ 0.
	pair := CFPhysicsPair first: moving second: obstacle.
	impact := CFPhysicsEarliestImpactFinder new
		earliestAmong: { pair }
		bodyStates: bodyStates
		for: 1.0.
	advancement := CFPhysicsImpactAdvancer new
		advanceBodyStates: bodyStates
		to: impact
		for: 1.0.
	step := CFPhysicsStep
		timeStep: advancement remainingTime
		substeps: 4
		contactHertz: 30.0
		dampingRatio: 10.0.
	result := CFPhysicsImpactSolver new
		solveAdvancement: advancement
		bodyStates: bodyStates
		step: step
		restitutionThreshold: 1.0.
	self assert: moving position equals: 0 @ 0.
	self assert: obstacle position equals: 30 @ 0.
	self assert: ((bodyStates at: moving) currentTransform position closeTo: 10 @ 0).
	^ result
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> remainingTimeIntegrationUsesPostImpactVelocity [
	<gtExample>
	| moving obstacle bodyStates pair impact advancement step solveResult movingState |
	moving := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	obstacle := self cleanSlateBodyWithSequence: 2 position: 30 @ 0 extent: 20 @ 20.
	obstacle beStatic.
	bodyStates := IdentityDictionary new
		at: moving put: (CFPhysicsBodyStepState on: moving);
		at: obstacle put: (CFPhysicsBodyStepState on: obstacle);
		yourself.
	movingState := bodyStates at: moving.
	movingState linearVelocity: 40 @ 0.
	pair := CFPhysicsPair first: moving second: obstacle.
	impact := CFPhysicsEarliestImpactFinder new
		earliestAmong: { pair }
		bodyStates: bodyStates
		for: 1.0.
	advancement := CFPhysicsImpactAdvancer new
		advanceBodyStates: bodyStates
		to: impact
		for: 1.0.
	step := CFPhysicsStep
		timeStep: advancement remainingTime
		substeps: 4
		contactHertz: 30.0
		dampingRatio: 10.0.
	solveResult := CFPhysicsImpactSolver new
		solveAdvancement: advancement
		bodyStates: bodyStates
		step: step
		restitutionThreshold: 1.0.
	CFPhysicsRemainingTimeIntegrator new
		integrateBodyStates: bodyStates
		after: solveResult.
	self assert: (movingState linearVelocity x abs < 1.0e-6).
	self assert: (movingState currentTransform position closeTo: 10 @ 0).
	self assert: moving position equals: 0 @ 0.
	^ solveResult
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> remainingTimeIntegrationAdvancesOtherBodiesThroughFullStep [
	<gtExample>
	| moving obstacle other bodyStates pair impact advancement step solveResult otherState |
	moving := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	obstacle := self cleanSlateBodyWithSequence: 2 position: 30 @ 0 extent: 20 @ 20.
	other := self cleanSlateBodyWithSequence: 3 position: 0 @ 100 extent: 20 @ 20.
	obstacle beStatic.
	bodyStates := IdentityDictionary new
		at: moving put: (CFPhysicsBodyStepState on: moving);
		at: obstacle put: (CFPhysicsBodyStepState on: obstacle);
		at: other put: (CFPhysicsBodyStepState on: other);
		yourself.
	(bodyStates at: moving) linearVelocity: 40 @ 0.
	otherState := bodyStates at: other.
	otherState linearVelocity: 8 @ 0.
	pair := CFPhysicsPair first: moving second: obstacle.
	impact := CFPhysicsEarliestImpactFinder new
		earliestAmong: { pair }
		bodyStates: bodyStates
		for: 1.0.
	advancement := CFPhysicsImpactAdvancer new
		advanceBodyStates: bodyStates
		to: impact
		for: 1.0.
	step := CFPhysicsStep
		timeStep: advancement remainingTime
		substeps: 4
		contactHertz: 30.0
		dampingRatio: 10.0.
	solveResult := CFPhysicsImpactSolver new
		solveAdvancement: advancement
		bodyStates: bodyStates
		step: step
		restitutionThreshold: 1.0.
	CFPhysicsRemainingTimeIntegrator new
		integrateBodyStates: bodyStates
		after: solveResult.
	self assert: (otherState currentTransform position closeTo: 8 @ 100).
	self assert: other position equals: 0 @ 100.
	^ solveResult
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> continuousStepExecutorCommitsImpactOnce [
	<gtExample>
	| moving obstacle bodyStates pair step result |
	moving := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	obstacle := self cleanSlateBodyWithSequence: 2 position: 30 @ 0 extent: 20 @ 20.
	obstacle beStatic.
	bodyStates := IdentityDictionary new
		at: moving put: (CFPhysicsBodyStepState on: moving);
		at: obstacle put: (CFPhysicsBodyStepState on: obstacle);
		yourself.
	(bodyStates at: moving) linearVelocity: 40 @ 0.
	pair := CFPhysicsPair first: moving second: obstacle.
	step := CFPhysicsStep
		timeStep: 1.0
		substeps: 4
		contactHertz: 30.0
		dampingRatio: 10.0.
	result := CFPhysicsContinuousStepExecutor new
		executePairs: { pair }
		bodyStates: bodyStates
		step: step
		restitutionThreshold: 1.0.
	self assert: result hasImpact.
	self assert: (result fraction closeTo: 0.25).
	self assert: (moving position closeTo: 10 @ 0).
	self assert: (moving velocity x abs < 1.0e-6).
	self assert: obstacle position equals: 30 @ 0.
	^ result
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> continuousStepExecutorCommitsOtherBodiesAfterFullStep [
	<gtExample>
	| moving obstacle other bodyStates pair step result |
	moving := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	obstacle := self cleanSlateBodyWithSequence: 2 position: 30 @ 0 extent: 20 @ 20.
	other := self cleanSlateBodyWithSequence: 3 position: 0 @ 100 extent: 20 @ 20.
	obstacle beStatic.
	bodyStates := IdentityDictionary new
		at: moving put: (CFPhysicsBodyStepState on: moving);
		at: obstacle put: (CFPhysicsBodyStepState on: obstacle);
		at: other put: (CFPhysicsBodyStepState on: other);
		yourself.
	(bodyStates at: moving) linearVelocity: 40 @ 0.
	(bodyStates at: other) linearVelocity: 8 @ 0.
	pair := CFPhysicsPair first: moving second: obstacle.
	step := CFPhysicsStep
		timeStep: 1.0
		substeps: 4
		contactHertz: 30.0
		dampingRatio: 10.0.
	result := CFPhysicsContinuousStepExecutor new
		executePairs: { pair }
		bodyStates: bodyStates
		step: step
		restitutionThreshold: 1.0.
	self assert: result hasImpact.
	self assert: (moving position closeTo: 10 @ 0).
	self assert: (other position closeTo: 8 @ 100).
	^ result
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> continuousStepExecutorLeavesSeparatedStatesUncommitted [
	<gtExample>
	| first second bodyStates pair step result |
	first := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self cleanSlateBodyWithSequence: 2 position: 100 @ 0 extent: 20 @ 20.
	bodyStates := IdentityDictionary new
		at: first put: (CFPhysicsBodyStepState on: first);
		at: second put: (CFPhysicsBodyStepState on: second);
		yourself.
	(bodyStates at: first) linearVelocity: -10 @ 0.
	pair := CFPhysicsPair first: first second: second.
	step := CFPhysicsStep
		timeStep: 1.0
		substeps: 4
		contactHertz: 30.0
		dampingRatio: 10.0.
	result := CFPhysicsContinuousStepExecutor new
		executePairs: { pair }
		bodyStates: bodyStates
		step: step
		restitutionThreshold: 1.0.
	self assert: result isNil.
	self assert: first position equals: 0 @ 0.
	self assert: second position equals: 100 @ 0.
	^ bodyStates
]


{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> stepPipelineUsesContinuousPathForSweptImpact [
	<gtExample>
	| moving obstacle pipeline step result |
	moving := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	obstacle := self cleanSlateBodyWithSequence: 2 position: 30 @ 0 extent: 20 @ 20.
	obstacle beStatic.
	moving velocity: 40 @ 0.
	moving beginStep.
	obstacle beginStep.
	pipeline := CFPhysicsStepPipeline manifoldBuilder: [ :pair |
		CFPhysicsCollision
			manifoldBetween: pair firstBody
			and: pair secondBody ].
	step := CFPhysicsStep
		timeStep: 1.0
		substeps: 4
		contactHertz: 30.0
		dampingRatio: 10.0.
	result := pipeline
		stepBodies: { moving. obstacle }
		fromContacts: #()
		step: step
		gravity: 0 @ 0
		restitutionThreshold: 1.0.
	self assert: result hasContinuousImpact.
	self assert: (result continuousStepResult fraction closeTo: 0.25).
	self assert: (moving position closeTo: 10 @ 0).
	self assert: (moving velocity closeTo: 40 @ 0).
	self assert: result activeContacts isEmpty.
	self assert: result constraints isEmpty.
	^ result
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> continuousImpactAppliesDistanceJointImpulseAtTheImpactSlice [
	<gtExample>
	| moving obstacle tether joint pipeline step result |
	moving := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	obstacle := self cleanSlateBodyWithSequence: 2 position: 30 @ 0 extent: 20 @ 20.
	tether := self cleanSlateBodyWithSequence: 3 position: 100 @ 100 extent: 20 @ 20.
	obstacle beStatic.
	tether beStatic.
	moving velocity: 40 @ 0.
	moving beginStep.
	obstacle beginStep.
	tether beginStep.
	joint := CFPhysicsDistanceJoint between: moving and: tether.
	joint restLength: 50.
	pipeline := CFPhysicsStepPipeline manifoldBuilder: [ :pair |
		CFPhysicsCollision
			manifoldBetween: pair firstBody
			and: pair secondBody ].
	step := CFPhysicsStep
		timeStep: 1.0
		substeps: 4
		contactHertz: 30.0
		dampingRatio: 10.0.
	result := pipeline
		stepBodies: { moving. obstacle. tether }
		fromContacts: #()
		joints: { joint }
		step: step
		gravity: 0 @ 0
		restitutionThreshold: 1.0.
	self assert: result hasContinuousImpact.
	self assert: joint accumulatedImpulse isZero not.
	^ result
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> stepPipelinePreservesDiscretePathWithoutTOI [
	<gtExample>
	| moving obstacle pipeline step result |
	moving := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	obstacle := self cleanSlateBodyWithSequence: 2 position: 100 @ 0 extent: 20 @ 20.
	obstacle beStatic.
	moving velocity: 10 @ 0.
	moving beginStep.
	obstacle beginStep.
	pipeline := CFPhysicsStepPipeline manifoldBuilder: [ :pair |
		CFPhysicsCollision
			manifoldBetween: pair firstBody
			and: pair secondBody ].
	step := CFPhysicsStep
		timeStep: 1.0
		substeps: 4
		contactHertz: 30.0
		dampingRatio: 10.0.
	result := pipeline
		stepBodies: { moving. obstacle }
		fromContacts: #()
		step: step
		gravity: 0 @ 0
		restitutionThreshold: 1.0.
	self assert: result hasContinuousImpact not.
	self assert: (moving position closeTo: 10 @ 0).
	self assert: result solver notNil.
	^ result
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> predictedSweepContinuesFromAdvancedStepState [
	<gtExample>
	| body state sweep |
	body := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	state := CFPhysicsBodyStepState on: body.
	state linearVelocity: 40 @ 0.
	state integratePositionBy: 0.25.
	sweep := state predictedSweepFor: 0.75.
	self assert: (sweep startTransform position closeTo: 10 @ 0).
	self assert: (sweep endTransform position closeTo: 40 @ 0).
	self assert: body position equals: 0 @ 0.
	^ sweep
]


{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> continuousImpactLoopSolvesMultipleImpactsInTimeOrder [
	<gtExample>
	| firstMoving firstObstacle secondMoving secondObstacle bodyStates step result |
	firstMoving := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	firstObstacle := self cleanSlateBodyWithSequence: 2 position: 30 @ 0 extent: 20 @ 20.
	secondMoving := self cleanSlateBodyWithSequence: 3 position: 0 @ 100 extent: 20 @ 20.
	secondObstacle := self cleanSlateBodyWithSequence: 4 position: 40 @ 100 extent: 20 @ 20.
	firstObstacle beStatic.
	secondObstacle beStatic.
	bodyStates := IdentityDictionary new
		at: firstMoving put: (CFPhysicsBodyStepState on: firstMoving);
		at: firstObstacle put: (CFPhysicsBodyStepState on: firstObstacle);
		at: secondMoving put: (CFPhysicsBodyStepState on: secondMoving);
		at: secondObstacle put: (CFPhysicsBodyStepState on: secondObstacle);
		yourself.
	(bodyStates at: firstMoving) linearVelocity: 40 @ 0.
	(bodyStates at: secondMoving) linearVelocity: 40 @ 0.
	step := CFPhysicsStep
		timeStep: 1.0
		substeps: 4
		contactHertz: 30.0
		dampingRatio: 10.0.
	result := CFPhysicsContinuousImpactLoop new
		executeBodyStates: bodyStates
		step: step
		restitutionThreshold: 1.0.
	self assert: result impacts size equals: 2.
	self assert: result impacts first pair firstBody equals: firstMoving.
	self assert: result impacts first pair secondBody equals: firstObstacle.
	self assert: result impacts second pair firstBody equals: secondMoving.
	self assert: result impacts second pair secondBody equals: secondObstacle.
	self assert: ((bodyStates at: firstMoving) currentTransform position closeTo: 10 @ 0).
	self assert: ((bodyStates at: secondMoving) currentTransform position closeTo: 20 @ 100).
	self assert: ((bodyStates at: firstMoving) linearVelocity x abs < 1.0e-6).
	self assert: ((bodyStates at: secondMoving) linearVelocity x abs < 1.0e-6).
	self assert: (result remainingTime closeTo: 0.0).
	self assert: result iterationLimitReached not.
	self assert: firstMoving position equals: 0 @ 0.
	self assert: secondMoving position equals: 0 @ 100.
	^ result
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> continuousImpactLoopSolvesSimultaneousImpactsAsOneTimeSlice [
	<gtExample>
	| firstMoving firstObstacle secondMoving secondObstacle bodyStates step result |
	firstMoving := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	firstObstacle := self cleanSlateBodyWithSequence: 2 position: 30 @ 0 extent: 20 @ 20.
	secondMoving := self cleanSlateBodyWithSequence: 3 position: 0 @ 100 extent: 20 @ 20.
	secondObstacle := self cleanSlateBodyWithSequence: 4 position: 30 @ 100 extent: 20 @ 20.
	firstObstacle beStatic.
	secondObstacle beStatic.
	bodyStates := IdentityDictionary new
		at: firstMoving put: (CFPhysicsBodyStepState on: firstMoving);
		at: firstObstacle put: (CFPhysicsBodyStepState on: firstObstacle);
		at: secondMoving put: (CFPhysicsBodyStepState on: secondMoving);
		at: secondObstacle put: (CFPhysicsBodyStepState on: secondObstacle);
		yourself.
	(bodyStates at: firstMoving) linearVelocity: 40 @ 0.
	(bodyStates at: secondMoving) linearVelocity: 40 @ 0.
	step := CFPhysicsStep
		timeStep: 1.0
		substeps: 4
		contactHertz: 30.0
		dampingRatio: 10.0.
	result := CFPhysicsContinuousImpactLoop new
		executeBodyStates: bodyStates
		step: step
		restitutionThreshold: 1.0.
	self assert: result impacts size equals: 2.
	self assert: result impacts first pair firstBody equals: firstMoving.
	self assert: result impacts second pair firstBody equals: secondMoving.
	self assert: ((bodyStates at: firstMoving) currentTransform position closeTo: 10 @ 0).
	self assert: ((bodyStates at: secondMoving) currentTransform position closeTo: 10 @ 100).
	self assert: ((bodyStates at: firstMoving) linearVelocity x abs < 1.0e-6).
	self assert: ((bodyStates at: secondMoving) linearVelocity x abs < 1.0e-6).
	self assert: (result remainingTime closeTo: 0.0).
	self assert: result iterationLimitReached not.
	^ result
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> continuousImpactLoopLeavesRemainderExplicitAtIterationLimit [
	<gtExample>
	| firstMoving firstObstacle secondMoving secondObstacle bodyStates step loop result |
	firstMoving := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	firstObstacle := self cleanSlateBodyWithSequence: 2 position: 30 @ 0 extent: 20 @ 20.
	secondMoving := self cleanSlateBodyWithSequence: 3 position: 0 @ 100 extent: 20 @ 20.
	secondObstacle := self cleanSlateBodyWithSequence: 4 position: 40 @ 100 extent: 20 @ 20.
	firstObstacle beStatic.
	secondObstacle beStatic.
	bodyStates := IdentityDictionary new
		at: firstMoving put: (CFPhysicsBodyStepState on: firstMoving);
		at: firstObstacle put: (CFPhysicsBodyStepState on: firstObstacle);
		at: secondMoving put: (CFPhysicsBodyStepState on: secondMoving);
		at: secondObstacle put: (CFPhysicsBodyStepState on: secondObstacle);
		yourself.
	(bodyStates at: firstMoving) linearVelocity: 40 @ 0.
	(bodyStates at: secondMoving) linearVelocity: 40 @ 0.
	step := CFPhysicsStep
		timeStep: 1.0
		substeps: 4
		contactHertz: 30.0
		dampingRatio: 10.0.
	loop := CFPhysicsContinuousImpactLoop new.
	loop maximumIterations: 1.
	result := loop
		executeBodyStates: bodyStates
		step: step
		restitutionThreshold: 1.0.
	self assert: result impacts size equals: 1.
	self assert: result iterationLimitReached.
	self assert: (result remainingTime closeTo: 0.75).
	self assert: ((bodyStates at: firstMoving) currentTransform position closeTo: 10 @ 0).
	self assert: ((bodyStates at: secondMoving) currentTransform position closeTo: 10 @ 100).
	self assert: firstMoving position equals: 0 @ 0.
	self assert: secondMoving position equals: 0 @ 100.
	^ result
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> stepPipelineSolvesMultipleContinuousImpactsInTimeOrder [
	<gtExample>
	| firstMoving firstObstacle secondMoving secondObstacle pipeline step result |
	firstMoving := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	firstObstacle := self cleanSlateBodyWithSequence: 2 position: 30 @ 0 extent: 20 @ 20.
	secondMoving := self cleanSlateBodyWithSequence: 3 position: 0 @ 100 extent: 20 @ 20.
	secondObstacle := self cleanSlateBodyWithSequence: 4 position: 40 @ 100 extent: 20 @ 20.
	firstObstacle beStatic.
	secondObstacle beStatic.
	firstMoving velocity: 40 @ 0.
	secondMoving velocity: 40 @ 0.
	firstMoving beginStep.
	firstObstacle beginStep.
	secondMoving beginStep.
	secondObstacle beginStep.
	pipeline := CFPhysicsStepPipeline manifoldBuilder: [ :pair |
		CFPhysicsCollision
			manifoldBetween: pair firstBody
			and: pair secondBody ].
	step := CFPhysicsStep
		timeStep: 1.0
		substeps: 4
		contactHertz: 30.0
		dampingRatio: 10.0.
	result := pipeline
		stepBodies: { secondObstacle. firstMoving. secondMoving. firstObstacle }
		fromContacts: #()
		step: step
		gravity: 0 @ 0
		restitutionThreshold: 1.0.
	self assert: result hasContinuousImpact.
	self assert: result continuousStepResult impacts size equals: 2.
	self assert: result continuousStepResult impacts first pair firstBody equals: firstMoving.
	self assert: result continuousStepResult impacts second pair firstBody equals: secondMoving.
	self assert: (firstMoving position closeTo: 10 @ 0).
	self assert: (secondMoving position closeTo: 20 @ 100).
	self assert: result activeContacts isEmpty.
	self assert: result constraints isEmpty.
	self assert: result solver notNil.
	^ result
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> stepPipelineKeepsDiscretePathWhenNoPositiveImpactExists [
	<gtExample>
	| moving obstacle pipeline step result |
	moving := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	obstacle := self cleanSlateBodyWithSequence: 2 position: 100 @ 0 extent: 20 @ 20.
	obstacle beStatic.
	moving velocity: 10 @ 0.
	moving beginStep.
	obstacle beginStep.
	pipeline := CFPhysicsStepPipeline manifoldBuilder: [ :pair |
		CFPhysicsCollision
			manifoldBetween: pair firstBody
			and: pair secondBody ].
	step := CFPhysicsStep
		timeStep: 1.0
		substeps: 4
		contactHertz: 30.0
		dampingRatio: 10.0.
	result := pipeline
		stepBodies: { moving. obstacle }
		fromContacts: #()
		step: step
		gravity: 0 @ 0
		restitutionThreshold: 1.0.
	self assert: result hasContinuousImpact not.
	self assert: result continuousStepResult isNil.
	self assert: result solver notNil.
	self assert: (moving position closeTo: 10 @ 0).
	^ result
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> stepPipelineKeepsInitialOverlapOnDiscretePath [
	<gtExample>
	| moving obstacle pipeline step result |
	moving := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	obstacle := self cleanSlateBodyWithSequence: 2 position: 10 @ 0 extent: 20 @ 20.
	obstacle beStatic.
	moving velocity: 10 @ 0.
	moving beginStep.
	obstacle beginStep.
	pipeline := CFPhysicsStepPipeline manifoldBuilder: [ :pair |
		CFPhysicsCollision
			manifoldBetween: pair firstBody
			and: pair secondBody ].
	step := CFPhysicsStep
		timeStep: 1.0
		substeps: 4
		contactHertz: 30.0
		dampingRatio: 10.0.
	result := pipeline
		stepBodies: { moving. obstacle }
		fromContacts: #()
		step: step
		gravity: 0 @ 0
		restitutionThreshold: 1.0.
	self assert: result hasContinuousImpact not.
	self assert: result solver notNil.
	self assert: result activeContacts size equals: 1.
	self assert: result activeContacts first manifold contactPoints first localAnchorA notNil.
	self assert: result activeContacts first manifold contactPoints first localAnchorB notNil.
	^ result
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> continuousImpactDoesNotSuppressSeparateOverlapRecovery [
	<gtExample>
	| moving wall overlapping obstacle pipeline step result |
	moving := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	wall := self cleanSlateBodyWithSequence: 2 position: 30 @ 0 extent: 20 @ 20.
	overlapping := self cleanSlateBodyWithSequence: 3 position: 0 @ 100 extent: 20 @ 20.
	obstacle := self cleanSlateBodyWithSequence: 4 position: 10 @ 100 extent: 20 @ 20.
	wall beStatic.
	obstacle beStatic.
	moving velocity: 40 @ 0.
	{ moving. wall. overlapping. obstacle } do: #beginStep.
	pipeline := CFPhysicsStepPipeline manifoldBuilder: [ :pair |
		CFPhysicsCollision
			manifoldBetween: pair firstBody
			and: pair secondBody ].
	step := CFPhysicsStep
		timeStep: 1.0
		substeps: 4
		contactHertz: 30.0
		dampingRatio: 10.0.
	result := pipeline
		stepBodies: { moving. wall. overlapping. obstacle }
		fromContacts: #()
		step: step
		gravity: 0 @ 0
		restitutionThreshold: 1.0.
	self assert: result hasContinuousImpact.
	self assert: result activeContacts size equals: 1.
	self assert: result activeContacts first pair firstBody equals: overlapping.
	self assert: result activeContacts first pair secondBody equals: obstacle.
	self assert: result solver notNil.
	self assert: overlapping position x < 0.0.
	^ result
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> continuousImpactDoesNotDoubleIntegrateSeparateMovingBody [
	<gtExample>
	| moving wall separate pipeline step result |
	moving := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	wall := self cleanSlateBodyWithSequence: 2 position: 30 @ 0 extent: 20 @ 20.
	separate := self cleanSlateBodyWithSequence: 3 position: 0 @ 100 extent: 20 @ 20.
	wall beStatic.
	moving velocity: 40 @ 0.
	separate velocity: 5 @ 0.
	{ moving. wall. separate } do: #beginStep.
	pipeline := CFPhysicsStepPipeline manifoldBuilder: [ :pair |
		CFPhysicsCollision
			manifoldBetween: pair firstBody
			and: pair secondBody ].
	step := CFPhysicsStep
		timeStep: 1.0
		substeps: 4
		contactHertz: 30.0
		dampingRatio: 10.0.
	result := pipeline
		stepBodies: { moving. wall. separate }
		fromContacts: #()
		step: step
		gravity: 0 @ 0
		restitutionThreshold: 1.0.
	self assert: result hasContinuousImpact.
	self assert: separate position x equals: 5.0.
	^ result
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> stepPipelineKeepsOverlappingSensorOnDiscretePath [
	<gtExample>
	| moving sensor pipeline step result |
	moving := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	sensor := self cleanSlateBodyWithSequence: 2 position: 10 @ 0 extent: 20 @ 20.
	sensor beStatic; beSensor.
	moving velocity: 10 @ 0.
	moving beginStep.
	sensor beginStep.
	pipeline := CFPhysicsStepPipeline manifoldBuilder: [ :pair |
		CFPhysicsCollision
			manifoldBetween: pair firstBody
			and: pair secondBody ].
	step := CFPhysicsStep
		timeStep: 1.0
		substeps: 4
		contactHertz: 30.0
		dampingRatio: 10.0.
	result := pipeline
		stepBodies: { sensor. moving }
		fromContacts: #()
		step: step
		gravity: 0 @ 0
		restitutionThreshold: 1.0.
	self assert: result hasContinuousImpact not.
	self assert: result activeContacts size equals: 1.
	self assert: result activeContacts first isSensor.
	self assert: result constraints isEmpty.
	^ result
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> continuousContactsPublishInDeterministicPairOrder [
	<gtExample>
	| result impacts |
	result := self stepPipelineSolvesMultipleContinuousImpactsInTimeOrder.
	impacts := result continuousStepResult impacts.
	self assert: impacts size equals: 2.
	self assert: impacts first pair firstBody sequence equals: 1.
	self assert: impacts first pair secondBody sequence equals: 2.
	self assert: impacts second pair firstBody sequence equals: 3.
	self assert: impacts second pair secondBody sequence equals: 4.
	^ impacts
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> continuousImpactLoopReportsIterationCapDeterministically [
	<gtExample>
	| result |
	result := self continuousImpactLoopLeavesRemainderExplicitAtIterationLimit.
	self assert: result impacts size equals: 1.
	self assert: result impacts first pair firstBody sequence equals: 1.
	self assert: result impacts first pair secondBody sequence equals: 2.
	self assert: result iterationLimitReached.
	self assert: (result remainingTime closeTo: 0.75).
	^ result
]


{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> stepPipelinePublishesSweptSensorWithoutSolvingOrBlockingMotion [
	<gtExample>
	| moving sensor pipeline step result |
	moving := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	sensor := self cleanSlateBodyWithSequence: 2 position: 30 @ 0 extent: 20 @ 20.
	sensor beStatic; beSensor.
	moving velocity: 60 @ 0.
	moving beginStep.
	sensor beginStep.
	pipeline := CFPhysicsStepPipeline manifoldBuilder: [ :pair |
		CFPhysicsCollision
			manifoldBetween: pair firstBody
			and: pair secondBody ].
	step := CFPhysicsStep
		timeStep: 1.0
		substeps: 4
		contactHertz: 30.0
		dampingRatio: 10.0.
	result := pipeline
		stepBodies: { sensor. moving }
		fromContacts: #()
		step: step
		gravity: 0 @ 0
		restitutionThreshold: 1.0.
	self assert: result hasContinuousImpact not.
	self assert: result continuousSensorContacts size equals: 1.
	self assert: result activeContacts isEmpty.
	self assert: result constraints isEmpty.
	self assert: result solver notNil.
	self assert: (moving position closeTo: 60 @ 0).
	self assert: result contactBeganEvents isEmpty.
	^ result
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> continuousSolidImpactDoesNotPublishSensorBeyondResolvedPath [
	<gtExample>
	| moving wall sensor pipeline step result |
	moving := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	wall := self cleanSlateBodyWithSequence: 2 position: 30 @ 0 extent: 20 @ 20.
	sensor := self cleanSlateBodyWithSequence: 3 position: 70 @ 0 extent: 20 @ 20.
	wall beStatic.
	sensor beStatic; beSensor.
	moving velocity: 100 @ 0.
	moving beginStep.
	wall beginStep.
	sensor beginStep.
	pipeline := CFPhysicsStepPipeline manifoldBuilder: [ :pair |
		CFPhysicsCollision
			manifoldBetween: pair firstBody
			and: pair secondBody ].
	step := CFPhysicsStep
		timeStep: 1.0
		substeps: 4
		contactHertz: 30.0
		dampingRatio: 10.0.
	result := pipeline
		stepBodies: { sensor. wall. moving }
		fromContacts: #()
		step: step
		gravity: 0 @ 0
		restitutionThreshold: 1.0.
	self assert: result hasContinuousImpact.
	self assert: result continuousStepResult impacts size equals: 1.
	self assert: result continuousStepResult impacts first pair firstBody equals: moving.
	self assert: result continuousStepResult impacts first pair secondBody equals: wall.
	self assert: result continuousSensorContacts isEmpty.
	self assert: result activeContacts isEmpty.
	self assert: result constraints isEmpty.
	self assert: (moving position closeTo: 10 @ 0).
	^ result
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> continuousSolidImpactPublishesSensorBeforeResolvedImpact [
	<gtExample>
	| moving sensor wall pipeline step result |
	moving := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	sensor := self cleanSlateBodyWithSequence: 2 position: 30 @ 0 extent: 20 @ 20.
	wall := self cleanSlateBodyWithSequence: 3 position: 70 @ 0 extent: 20 @ 20.
	sensor beStatic; beSensor.
	wall beStatic.
	moving velocity: 100 @ 0.
	moving beginStep.
	sensor beginStep.
	wall beginStep.
	pipeline := CFPhysicsStepPipeline manifoldBuilder: [ :pair |
		CFPhysicsCollision
			manifoldBetween: pair firstBody
			and: pair secondBody ].
	step := CFPhysicsStep
		timeStep: 1.0
		substeps: 4
		contactHertz: 30.0
		dampingRatio: 10.0.
	result := pipeline
		stepBodies: { wall. sensor. moving }
		fromContacts: #()
		step: step
		gravity: 0 @ 0
		restitutionThreshold: 1.0.
	self assert: result hasContinuousImpact.
	self assert: result continuousStepResult impacts size equals: 1.
	self assert: result continuousStepResult impacts first pair firstBody equals: moving.
	self assert: result continuousStepResult impacts first pair secondBody equals: wall.
	self assert: result continuousSensorContacts size equals: 1.
	self assert: result continuousSensorContacts first isSensor.
	self assert: result activeContacts isEmpty.
	self assert: result constraints isEmpty.
	self assert: (moving position closeTo: 50 @ 0).
	^ result
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> sweptSensorCrossingEndsOnFollowingStep [
	<gtExample>
	| firstResult moving sensor pipeline step secondResult |
	firstResult := self stepPipelinePublishesSweptSensorWithoutSolvingOrBlockingMotion.
	moving := firstResult bodies first.
	sensor := firstResult bodies second.
	moving velocity: 0 @ 0.
	moving beginStep.
	sensor beginStep.
	pipeline := CFPhysicsStepPipeline manifoldBuilder: [ :pair |
		CFPhysicsCollision
			manifoldBetween: pair firstBody
			and: pair secondBody ].
	step := CFPhysicsStep
		timeStep: 1.0
		substeps: 4
		contactHertz: 30.0
		dampingRatio: 10.0.
	secondResult := pipeline
		stepBodies: { sensor. moving }
		fromContacts: firstResult activeContacts
		step: step
		gravity: 0 @ 0
		restitutionThreshold: 1.0.
	self assert: secondResult pairs isEmpty.
	self assert: secondResult activeContacts isEmpty.
	self assert: secondResult beganContacts isEmpty.
	self assert: secondResult continuedContacts isEmpty.
	self assert: secondResult endedContacts isEmpty.
	self assert: secondResult constraints isEmpty.
	self assert: secondResult contactBeganEvents isEmpty.
	self assert: secondResult contactEndedEvents isEmpty.
	self assert: secondResult continuousSensorContacts isEmpty.
	self assert: (moving position closeTo: 60 @ 0).
	^ secondResult
]



{ #category : 'examples - velocity integration' }
CFPhysicsCleanSlateTests >> stepStateIntegratesAccumulatedForceByInverseMass [
	<gtExample>
	| body state |
	body := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 10 @ 10.
	body applyForce: 200 @ -100.
	state := CFPhysicsBodyStepState on: body.
	state integrateVelocityBy: 0.5 gravity: 0 @ 0.
	self assert: (state linearVelocity x closeTo: 1.0).
	self assert: (state linearVelocity y closeTo: -0.5).
	^ state
]

{ #category : 'examples - velocity integration' }
CFPhysicsCleanSlateTests >> stepStateAppliesPerBodyGravityScale [
	<gtExample>
	| body state |
	body := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 10 @ 10.
	body gravityScale: 0.25.
	state := CFPhysicsBodyStepState on: body.
	state integrateVelocityBy: 2.0 gravity: 0 @ 10.
	self assert: state linearVelocity equals: 0 @ 5.
	^ state
]

{ #category : 'examples - velocity integration' }
CFPhysicsCleanSlateTests >> stepStateAppliesPadeLinearDamping [
	<gtExample>
	| body state |
	body := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 10 @ 10.
	body
		velocity: 12 @ -6;
		linearDamping: 2.0.
	state := CFPhysicsBodyStepState on: body.
	state integrateVelocityBy: 0.5 gravity: 0 @ 0.
	self assert: state linearVelocity equals: 6 @ -3.
	^ state
]

{ #category : 'examples - velocity integration' }
CFPhysicsCleanSlateTests >> bodyCommitClearsAccumulatedForceAndTorque [
	<gtExample>
	| body state |
	body := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 10 @ 10.
	body
		applyForce: 20 @ 30;
		applyTorque: 40.
	state := CFPhysicsBodyStepState on: body.
	state commit.
	self assert: body force equals: 0 @ 0.
	self assert: body torque equals: 0.0.
	^ body
]

{ #category : 'examples - islands' }
CFPhysicsCleanSlateTests >> islandRebuildSplitsRemovedConnectivityDeterministically [
	<gtExample>
	| first second third firstConstraint removedConstraint builder connected split |
	first := self cleanSlateBodyWithSequence: 1.
	second := self cleanSlateBodyWithSequence: 2.
	third := self cleanSlateBodyWithSequence: 3.
	firstConstraint := self cleanSlateConstraintBetween: first and: second.
	removedConstraint := self cleanSlateConstraintBetween: second and: third.
	builder := CFPhysicsIslandBuilder new.
	connected := builder
		islandsFromBodies: { third. second. first }
		constraints: { removedConstraint. firstConstraint }.
	self assert: connected size equals: 1.
	self assert: (connected first dynamicBodies collect: #sequence) equals: #(1 2 3).
	split := builder
		islandsFromBodies: { third. second. first }
		constraints: { firstConstraint }.
	self assert: split size equals: 2.
	self assert: (split first dynamicBodies collect: #sequence) equals: #(1 2).
	self assert: (split second dynamicBodies collect: #sequence) equals: #(3).
	^ split
]

{ #category : 'examples - constraint preparation' }
CFPhysicsCleanSlateTests >> preparedJointConstraintsShareTheirJointStateContract [
	<gtExample>
	self assert: CFPhysicsPreparedDistanceJoint superclass equals: CFPhysicsPreparedJointConstraint.
	self assert: CFPhysicsPreparedRevoluteJoint superclass equals: CFPhysicsPreparedJointConstraint.
	self assert: CFPhysicsPreparedRailJoint superclass equals: CFPhysicsPreparedJointConstraint.
	self assert: (CFPhysicsPreparedFixedJoint inheritsFrom: CFPhysicsPreparedJointConstraint).
	^ CFPhysicsPreparedJointConstraint
]

{ #category : 'examples - body types' }
CFPhysicsCleanSlateTests >> changingBodyTypeWakesContactNeighbours [
	<gtExample>
	| first second contact |
	first := self cleanSlateBodyWithSequence: 1.
	second := self cleanSlateBodyWithSequence: 2.
	contact := CFPhysicsContact
		pair: (CFPhysicsPair first: first second: second)
		manifold: nil.
	first addContact: contact.
	second addContact: contact.
	second sleep.
	self assert: second isSleeping.
	first beStatic.
	self assert: second isAwake.
	second sleep.
	self assert: second isSleeping.
	first beDynamic.
	self assert: second isAwake.
	^ first
]



{ #category : 'examples - body types' }
CFPhysicsCleanSlateTests >> kinematicBodyIntegratesItsPrescribedVelocityWithoutForces [
	<gtExample>
	| body state |
	body := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 10 @ 10.
	body
		beKinematic;
		velocity: 4 @ -2;
		angularVelocity: 0.5;
		linearDamping: 10.0;
		angularDamping: 10.0;
		applyForce: 1000 @ 1000;
		applyTorque: 1000.
	state := CFPhysicsBodyStepState on: body.
	state integrateVelocityBy: 2.0 gravity: 0 @ 100.
	self assert: state linearVelocity equals: 4 @ -2.
	self assert: (state angularVelocity closeTo: 0.5).
	state integratePositionBy: 2.0.
	state commit.
	self assert: (body position closeTo: 8 @ -4).
	self assert: (body rotation closeTo: 1.0).
	^ body
]

{ #category : 'examples - body types' }
CFPhysicsCleanSlateTests >> kinematicBodyHasInfiniteMassAndCannotSleep [
	<gtExample>
	| body |
	body := self cleanSlateBodyWithSequence: 1.
	body beKinematic.
	self assert: body isKinematic.
	self assert: body isDynamic not.
	self assert: body isStatic not.
	self assert: body inverseMass equals: 0.0.
	self assert: body inverseInertia equals: 0.0.
	body sleep.
	self assert: body isAwake.
	self assert: body isSleeping not.
	^ body
]

{ #category : 'examples - body types' }
CFPhysicsCleanSlateTests >> broadphaseRequiresADynamicBodyInKinematicPairs [
	<gtExample>
	| dynamic kinematic static finder pairs |
	dynamic := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	kinematic := self cleanSlateBodyWithSequence: 2 position: 0 @ 0 extent: 20 @ 20.
	static := self cleanSlateBodyWithSequence: 3 position: 0 @ 0 extent: 20 @ 20.
	kinematic beKinematic.
	static beStatic.
	finder := CFPhysicsPairFinder new.
	pairs := finder pairsAmong: { static. kinematic. dynamic }.
	self assert: pairs size equals: 2.
	self assert: (pairs anySatisfy: [ :pair |
		pair firstBody == dynamic and: [ pair secondBody == kinematic ] ]).
	self assert: (pairs anySatisfy: [ :pair |
		pair firstBody == dynamic and: [ pair secondBody == static ] ]).
	self assert: (pairs anySatisfy: [ :pair |
		(pair firstBody == kinematic and: [ pair secondBody == static ]) or: [
			pair firstBody == static and: [ pair secondBody == kinematic ] ] ]) not.
	^ pairs
]

{ #category : 'examples - worlds' }
CFPhysicsCleanSlateTests >> beWorldInstallsWorldAlongsidePhysics [
	<gtExample>
	| element physics world |
	element := BlElement new.
	physics := element physics.
	world := physics beWorld.
	self assert: (element userData at: CFPhysics) == physics.
	self assert: (element userData at: CFPhysicsWorld) == world.
	self assert: physics world == world.
	^ world
]

{ #category : 'examples - worlds' }
CFPhysicsCleanSlateTests >> worldAnswersNearestExplicitWorld [
	<gtExample>
	| root child world |
	root := BlElement new.
	child := BlElement new.
	root addChild: child.
	world := root physics beWorld.
	self assert: child physics world == world.
	self assert: child physics isWorld not.
	^ world
]

{ #category : 'examples - worlds' }
CFPhysicsCleanSlateTests >> worldInstallsAtRootWhenNoWorldExists [
	<gtExample>
	| root parent child world |
	root := BlElement new.
	parent := BlElement new.
	child := BlElement new.
	root addChild: parent.
	parent addChild: child.
	world := child physics world.
	self assert: root physics existingWorld == world.
	self assert: parent physics existingWorld isNil.
	self assert: child physics existingWorld isNil.
	^ world
]


{ #category : 'tests - behaviours' }
CFPhysicsCleanSlateTests >> testPhysicsOwnsAddedBehaviourAndWorldParticipates [
	| root element world behaviour |
	root := BlElement new.
	element := BlElement new.
	root addChild: element.
	world := root physics beWorld.
	behaviour := CFPhysicsRecordingBehaviour physics: element physics.
	element physics addBehaviour: behaviour.
	self assert: element physics behaviours equals: { behaviour }.
	self assert: world behaviours equals: { behaviour }.
	self assert: behaviour physics identicalTo: element physics.
	self assert: behaviour world identicalTo: world.
	self assert: behaviour element identicalTo: element
]

{ #category : 'tests - behaviours' }
CFPhysicsCleanSlateTests >> testDetachedElementCannotAddPhysicsBehaviour [
	| element behaviour |
	element := BlElement new.
	behaviour := CFPhysicsRecordingBehaviour physics: element physics.
	self
		should: [ element physics addBehaviour: behaviour ]
		raise: Error
]

{ #category : 'tests - behaviours' }
CFPhysicsCleanSlateTests >> testWorldUpdatesBehavioursInInsertionOrder [
	| root element world order first second |
	root := BlElement new.
	element := BlElement new.
	root addChild: element.
	world := root physics beWorld.
	world gravity: 0 @ 0.
	order := OrderedCollection new.
	first := CFPhysicsRecordingBehaviour physics: element physics.
	first updateBlock: [ :behaviour :step | order add: #first ].
	second := CFPhysicsRecordingBehaviour physics: element physics.
	second updateBlock: [ :behaviour :step | order add: #second ].
	element physics
		addBehaviour: first;
		addBehaviour: second.
	world step.
	self assert: order asArray equals: #(first second).
	self assert: first updates first stepNumber equals: 1.
	self assert: second updates first simulationTime equals: 0.0
]

{ #category : 'tests - behaviours' }
CFPhysicsCleanSlateTests >> testBehaviourRemovalIsIdempotentAndClearsBothOwners [
	| root element world behaviour |
	root := BlElement new.
	element := BlElement new.
	root addChild: element.
	world := root physics beWorld.
	behaviour := CFPhysicsRecordingBehaviour physics: element physics.
	element physics addBehaviour: behaviour.
	behaviour remove; remove.
	self assert: behaviour isRemoved.
	self assert: behaviour removalCount equals: 1.
	self assert: element physics behaviours isEmpty.
	self assert: world behaviours isEmpty
]

{ #category : 'tests - behaviours' }
CFPhysicsCleanSlateTests >> testBehaviourCanRemoveItselfDuringWorldUpdate [
	| root element world behaviour |
	root := BlElement new.
	element := BlElement new.
	root addChild: element.
	world := root physics beWorld.
	world gravity: 0 @ 0.
	behaviour := CFPhysicsRecordingBehaviour physics: element physics.
	behaviour updateBlock: [ :each :step | each remove ].
	element physics addBehaviour: behaviour.
	world step; step.
	self assert: behaviour updates size equals: 1.
	self assert: behaviour removalCount equals: 1.
	self assert: world behaviours isEmpty
]

{ #category : 'tests - behaviours' }
CFPhysicsCleanSlateTests >> testBehaviourAddedDuringUpdateBeginsOnNextStep [
	| root element world first second |
	root := BlElement new.
	element := BlElement new.
	root addChild: element.
	world := root physics beWorld.
	world gravity: 0 @ 0.
	second := CFPhysicsRecordingBehaviour physics: element physics.
	first := CFPhysicsRecordingBehaviour physics: element physics.
	first updateBlock: [ :behaviour :step |
		element physics addBehaviour: second ].
	element physics addBehaviour: first.
	world step.
	self assert: first updates size equals: 1.
	self assert: second updates isEmpty.
	world step.
	self assert: second updates size equals: 1
]

{ #category : 'tests - behaviours' }
CFPhysicsCleanSlateTests >> testBehaviourIsRemovedWhenElementLeavesItsWorld [
	| root element world behaviour |
	root := BlElement new.
	element := BlElement new.
	root addChild: element.
	world := root physics beWorld.
	world gravity: 0 @ 0.
	behaviour := CFPhysicsRecordingBehaviour physics: element physics.
	element physics addBehaviour: behaviour.
	root removeChild: element.
	world step.
	self assert: behaviour isRemoved.
	self assert: behaviour removalCount equals: 1.
	self assert: element physics behaviours isEmpty.
	self assert: world behaviours isEmpty
]

{ #category : 'tests - behaviours' }
CFPhysicsCleanSlateTests >> testWorldOwningElementCanOwnBehaviour [
	| root world behaviour |
	root := BlElement new.
	world := root physics beWorld.
	world gravity: 0 @ 0.
	behaviour := CFPhysicsRecordingBehaviour physics: root physics.
	root physics addBehaviour: behaviour.
	world step.
	self assert: behaviour updates size equals: 1.
	self assert: behaviour stillBelongsToWorld
]


{ #category : 'tests - angular dynamics' }
CFPhysicsCleanSlateTests >> testAngularImpulseChangesDynamicAngularVelocityByInverseInertia [
	| body impulse expected |
	body := self cleanSlateBodyWithSequence: 1.
	impulse := 12.0.
	expected := impulse * body inverseInertia.
	body applyAngularImpulse: impulse.
	self assert: (body angularVelocity closeTo: expected)
]

{ #category : 'tests - angular dynamics' }
CFPhysicsCleanSlateTests >> testZeroAngularImpulseDoesNotWakeSleepingBody [
	| body |
	body := self cleanSlateBodyWithSequence: 1.
	body sleep.
	body applyAngularImpulse: 0.0.
	self deny: body isAwake
]

{ #category : 'tests - angular dynamics' }
CFPhysicsCleanSlateTests >> testStaticBodyIgnoresAngularImpulse [
	| body |
	body := self cleanSlateBodyWithSequence: 1.
	body beStatic.
	body applyAngularImpulse: 12.0.
	self assert: body angularVelocity equals: 0.0
]

{ #category : 'tests - behaviours' }
CFPhysicsCleanSlateTests >> testJumpingBeanIsImmediatelyOwnedAndParticipating [
	| root element world behaviour |
	root := BlElement new.
	element := BlElement new.
	root addChild: element.
	world := root physics beWorld.
	behaviour := element physics jumpingBean.
	self assert: element physics behaviours equals: { behaviour }.
	self assert: world behaviours equals: { behaviour }.
	self assert: behaviour physics identicalTo: element physics.
	self assert: behaviour world identicalTo: world
]

{ #category : 'tests - behaviours' }
CFPhysicsCleanSlateTests >> testJumpingBeanSchedulesThenAppliesLinearAndAngularImpulse [
	| root element world behaviour body initialAngularVelocity |
	root := BlElement new.
	element := BlElement new.
	element extent: 20 @ 20.
	root addChild: element.
	world := root physics beWorld.
	world gravity: 0 @ 0.
	behaviour := element physics jumpingBean.
	behaviour
		random: (CFPhysicsSequenceRandom values: #(0.0 0.0 0.0 0.0 0.0));
		minimumDelay: world stepDuration;
		maximumDelay: world stepDuration;
		minimumImpulse: 10.0;
		maximumImpulse: 10.0;
		minimumAngularImpulse: 2.0;
		maximumAngularImpulse: 2.0.
	world step.
	body := element physics requireBodyState.
	initialAngularVelocity := body angularVelocity.
	self assert: body velocity equals: 0 @ 0.
	self assert: behaviour nextJoltTime equals: world stepDuration.
	world step.
	self assert: body velocity x > 0.0.
	self assert: (body velocity y closeTo: 0.0).
	self assert: body angularVelocity > initialAngularVelocity
]

{ #category : 'tests - behaviours' }
CFPhysicsCleanSlateTests >> testRemovingJumpingBeanPreventsFutureJolts [
	| root element world behaviour body |
	root := BlElement new.
	element := BlElement new.
	element extent: 20 @ 20.
	root addChild: element.
	world := root physics beWorld.
	world gravity: 0 @ 0.
	behaviour := element physics jumpingBean.
	behaviour
		random: (CFPhysicsSequenceRandom values: #(0.0));
		minimumDelay: world stepDuration;
		maximumDelay: world stepDuration.
	world step.
	body := element physics requireBodyState.
	behaviour remove.
	world step.
	self assert: body velocity equals: 0 @ 0.
	self assert: body angularVelocity equals: 0.0
]

{ #category : 'tests - behaviours' }
CFPhysicsCleanSlateTests >> testMultipleJumpingBeansKeepIndependentSchedules [
	| root element world first second |
	root := BlElement new.
	element := BlElement new.
	element extent: 20 @ 20.
	root addChild: element.
	world := root physics beWorld.
	world gravity: 0 @ 0.
	first := element physics jumpingBean.
	second := element physics jumpingBean.
	first
		random: (CFPhysicsSequenceRandom values: #(0.0));
		minimumDelay: world stepDuration;
		maximumDelay: world stepDuration.
	second
		random: (CFPhysicsSequenceRandom values: #(0.0));
		minimumDelay: world stepDuration * 2;
		maximumDelay: world stepDuration * 2.
	world step.
	self assert: first nextJoltTime equals: world stepDuration.
	self assert: second nextJoltTime equals: world stepDuration * 2
]

{ #category : 'tests - behaviours' }
CFPhysicsCleanSlateTests >> testForceDirectedCreatesSpringsAndRepulsionsInSourceOrder [
	| root first second third world edge source behaviour |
	root := BlElement new.
	first := BlElement new extent: 20 @ 20.
	second := BlElement new extent: 20 @ 20.
	third := BlElement new extent: 20 @ 20.
	root addChildren: { first. second. third }.
	world := root physics beWorld.
	world gravity: 0 @ 0.
	edge := first -> second.
	source := CFPhysicsGraphSource
		nodes: [ { first. second. third } ]
		edges: [ { edge } ]
		source: [ :each | each key ]
		target: [ :each | each value ].
	behaviour := root physics forceDirectedUsing: source.
	world step.
	self assert: behaviour springsByEdge size equals: 1.
	self assert: behaviour repulsionsByPair size equals: 3.
	self assert: world springConstraints size equals: 1.
	self assert: world repulsionConstraints size equals: 3
]

{ #category : 'tests - behaviours' }
CFPhysicsCleanSlateTests >> testForceDirectedRetainsExistingConstraintsWhileReconcilingChanges [
	| root first second third world nodes edges firstEdge secondEdge source behaviour retainedSpring retainedRepulsion |
	root := BlElement new.
	first := BlElement new extent: 20 @ 20.
	second := BlElement new extent: 20 @ 20.
	third := BlElement new extent: 20 @ 20.
	root addChildren: { first. second. third }.
	world := root physics beWorld.
	world gravity: 0 @ 0.
	nodes := OrderedCollection with: first with: second.
	firstEdge := first -> second.
	secondEdge := second -> third.
	edges := OrderedCollection with: firstEdge.
	source := CFPhysicsGraphSource
		nodes: [ nodes ]
		edges: [ edges ]
		source: [ :each | each key ]
		target: [ :each | each value ].
	behaviour := root physics forceDirectedUsing: source.
	world step.
	retainedSpring := behaviour springsByEdge at: firstEdge.
	retainedRepulsion := behaviour repulsionsByPair values anyOne.
	nodes add: third.
	edges add: secondEdge.
	world step.
	self assert: (behaviour springsByEdge at: firstEdge) identicalTo: retainedSpring.
	self assert: (behaviour repulsionsByPair values includes: retainedRepulsion).
	self assert: behaviour springsByEdge size equals: 2.
	self assert: behaviour repulsionsByPair size equals: 3.
	edges remove: firstEdge.
	nodes remove: first.
	world step.
	self deny: (behaviour springsByEdge includesKey: firstEdge).
	self assert: behaviour springsByEdge size equals: 1.
	self assert: behaviour repulsionsByPair size equals: 1.
	self deny: retainedSpring isActive
]

{ #category : 'tests - behaviours' }
CFPhysicsCleanSlateTests >> testForceDirectedConfigurationUpdatesSharedPrimitiveValues [
	| root first second world edge source behaviour spring repulsion |
	root := BlElement new.
	first := BlElement new extent: 20 @ 20.
	second := BlElement new extent: 20 @ 20.
	root addChildren: { first. second }.
	world := root physics beWorld.
	edge := first -> second.
	source := CFPhysicsGraphSource
		nodes: [ { first. second } ]
		edges: [ { edge } ]
		source: [ :each | each key ]
		target: [ :each | each value ].
	behaviour := root physics forceDirectedUsing: source.
	world step.
	spring := behaviour springsByEdge at: edge.
	repulsion := behaviour repulsionsByPair values anyOne.
	behaviour
		restLength: 175;
		stiffness: 25;
		damping: 4;
		maximumSpringForce: 500;
		repulsion: 700;
		maximumRepulsionDistance: 250.
	self assert: spring restLength physicsValue equals: 175.0.
	self assert: spring stiffness physicsValue equals: 25.0.
	self assert: spring damping physicsValue equals: 4.0.
	self assert: spring maximumForce physicsValue equals: 500.0.
	self assert: repulsion force physicsValue equals: 700.0.
	self assert: repulsion maximumDistance physicsValue equals: 250.0
]

{ #category : 'tests - behaviours' }
CFPhysicsCleanSlateTests >> testRemovingForceDirectedRemovesOnlyItsOwnedConstraints [
	| root first second world edge source firstBehaviour secondBehaviour firstSpring secondSpring |
	root := BlElement new.
	first := BlElement new extent: 20 @ 20.
	second := BlElement new extent: 20 @ 20.
	root addChildren: { first. second }.
	world := root physics beWorld.
	edge := first -> second.
	source := CFPhysicsGraphSource
		nodes: [ { first. second } ]
		edges: [ { edge } ]
		source: [ :each | each key ]
		target: [ :each | each value ].
	firstBehaviour := root physics forceDirectedUsing: source.
	secondBehaviour := root physics forceDirectedUsing: source.
	world step.
	firstSpring := firstBehaviour springsByEdge at: edge.
	secondSpring := secondBehaviour springsByEdge at: edge.
	firstBehaviour remove.
	self deny: firstSpring isActive.
	self assert: secondSpring isActive.
	self assert: world springConstraints equals: { secondSpring }.
	self assert: world repulsionConstraints size equals: 1
]

{ #category : 'tests - behaviours' }
CFPhysicsCleanSlateTests >> testForceDirectedRejectsEndpointsOutsideItsNodeSelection [
	| root first second world edge source |
	root := BlElement new.
	first := BlElement new extent: 20 @ 20.
	second := BlElement new extent: 20 @ 20.
	root addChildren: { first. second }.
	world := root physics beWorld.
	edge := first -> second.
	source := CFPhysicsGraphSource
		nodes: [ { first } ]
		edges: [ { edge } ]
		source: [ :each | each key ]
		target: [ :each | each value ].
	root physics forceDirectedUsing: source.
	self
		should: [ world step ]
		raise: Error
		withExceptionDo: [ :error |
			self assert: error messageText equals:
				'Every force-directed edge endpoint must occur in the graph nodes' ]
]
