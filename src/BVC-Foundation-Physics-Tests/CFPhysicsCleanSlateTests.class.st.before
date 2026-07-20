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
	^ (CFPhysicsBodyState element: (BlElement new size: 10 @ 10; yourself) world: nil)
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
	^ (CFPhysicsBodyState
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
		CFPhysicsPairFinderStage.
		CFPhysicsContactUpdateStage.
		CFPhysicsBodyStateCaptureStage.
		CFPhysicsConstraintPreparationStage.
		CFPhysicsIslandBuilderStage.
		CFPhysicsIslandWakeStage.
		CFPhysicsIslandSolverStage.
		CFPhysicsPostSolveStage.
		CFPhysicsIslandSleepingStage.
		CFPhysicsContactEventsStage }.
	self assert: result executedStages size equals: expectedTypes size.
	expectedTypes withIndexDo: [ :stageType :index |
		self assert: ((result executedStages at: index) isKindOf: stageType) ].
	self assert: result stageExecutions first output equals: result pairs.
	self assert: result stageExecutions second output == result contactResult.
	self assert: result stageExecutions fourth output equals: result constraints.
	self assert: result stageExecutions fifth output equals: result islands.
	self assert: ((result stageExecutions at: 7) output == result solver).
	self assert: (result stageExecutions at: 8) output contactResults equals: result contactSolveResults.
	self assert: (result stageExecutions at: 8) output hitEvents equals: result hitEvents.
	self assert: (result stageExecutions at: 10) output equals: result contactEvents.
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
	self assert: stages size equals: 10.
	self assert: stages first class equals: CFPhysicsPairFinderStage.
	self assert: stages last class equals: CFPhysicsContactEventsStage.
	self assert: (pipeline stageOfType: CFPhysicsConstraintPreparationStage) == (stages at: 4).
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

{ #category : 'examples - pointer interaction' }
CFPhysicsCleanSlateTests >> pointerDraggingIsInstalledThroughThePhysicsFacade [
	<gtExample>
	| element handler |
	element := BlElement new size: 40 @ 40; yourself.
	handler := element physics enablePointerDragging.
	self assert: handler element equals: element.
	self assert: element physics isPointerDraggingEnabled.
	element physics disablePointerDragging.
	self assert: element physics isPointerDraggingEnabled not.
	^ element
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
	first := (CFPhysicsBodyState
		element: (BlElement new geometry: BlCircleGeometry new; size: 20 @ 20; yourself)
		world: nil)
		sequence: 1;
		position: 0 @ 0;
		yourself.
	second := (CFPhysicsBodyState
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
	body := CFPhysicsBodyState element: element world: nil.
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
	body := CFPhysicsBodyState element: element world: nil.
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
	self assert: sweep endTransform rotation closeTo: Float pi / 2.0.
	^ sweep
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
	self assert: transform rotation closeTo: Float pi / 4.0.
	^ transform
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> sweptAABBDelegatesToSweep [
	<gtExample>
	| body |
	body := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 10 @ 10.
	body
		beginStep;
		addVelocity: 100 @ 0;
		advanceBy: 1.0 gravity: 0 @ 0.
	| bodyBounds sweepBounds |
	bodyBounds := body sweptAABB.
	sweepBounds := body sweep sweptAABBFor: body shapeState.
	self assert: bodyBounds minimum equals: sweepBounds minimum.
	self assert: bodyBounds maximum equals: sweepBounds maximum.
	^ bodyBounds
]
