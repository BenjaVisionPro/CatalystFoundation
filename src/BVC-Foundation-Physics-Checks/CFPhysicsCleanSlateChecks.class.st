Class {
	#name : 'CFPhysicsCleanSlateChecks',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Physics-Checks',
	#package : 'BVC-Foundation-Physics-Checks'
}

{ #category : 'examples - step' }
CFPhysicsCleanSlateChecks >> softStepUsesSubstepDuration [
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
CFPhysicsCleanSlateChecks >> contactFeatureIdentityIsStructural [
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
CFPhysicsCleanSlateChecks >> manifoldPreservesImpulsesByFeatureIdentity [
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
CFPhysicsCleanSlateChecks >> manifoldDoesNotUsePositionAsIdentity [
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
CFPhysicsCleanSlateChecks >> faceContactProducesTwoPoints [
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
CFPhysicsCleanSlateChecks >> faceContactIdentityPersistsAcrossTangentialMotion [
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
CFPhysicsCleanSlateChecks >> roundedPolygonUsesCoreAndRadius [
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
CFPhysicsCleanSlateChecks >> separatedPolygonCoresRespectCombinedRadius [
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
CFPhysicsCleanSlateChecks >> rectangleElementProducesPolygonShape [
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
CFPhysicsCleanSlateChecks >> roundedRectangleElementProducesInsetCoreAndRadius [
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
CFPhysicsCleanSlateChecks >> normalizedPolygonElementUsesItsRenderedExtent [
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
CFPhysicsCleanSlateChecks >> BlocGeometryRoutesToPolygonManifold [
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
CFPhysicsCleanSlateChecks >> circleDoesNotPretendToBeAPolygon [
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
CFPhysicsCleanSlateChecks >> contactPipelineOrdersPairsDeterministically [
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
CFPhysicsCleanSlateChecks >> contactPipelineReportsBeginContinueAndEnd [
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
CFPhysicsCleanSlateChecks >> contactPipelinePersistsImpulsesByFeatureIdentity [
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

{ #category : 'examples - constraints' }
CFPhysicsCleanSlateChecks >> constraintBuilderPreparesSolverData [
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
CFPhysicsCleanSlateChecks >> preparedConstraintWritesSolvedImpulsesBackExplicitly [
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
CFPhysicsCleanSlateChecks >> cleanSlateBodyWithSequence: anInteger [
	^ (CFPhysicsBodyState element: (BlElement new size: 10 @ 10; yourself) world: nil)
		sequence: anInteger;
		yourself
]

{ #category : 'private - contact pipeline' }
CFPhysicsCleanSlateChecks >> cleanSlateManifoldWithFeatureIndex: anInteger [
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
CFPhysicsCleanSlateChecks >> pairFinderReturnsOverlappingPairsInSequenceOrder [
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
CFPhysicsCleanSlateChecks >> pairFinderRejectsSeparatedBodies [
	<gtExample>
	| first second pairs |
	first := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self cleanSlateBodyWithSequence: 2 position: 30 @ 0 extent: 20 @ 20.
	pairs := CFPhysicsPairFinder new pairsAmong: { first. second }.
	self assert: pairs isEmpty.
	^ pairs
]

{ #category : 'examples - pair discovery' }
CFPhysicsCleanSlateChecks >> pairFinderRejectsStaticStaticPairs [
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
CFPhysicsCleanSlateChecks >> contactPipelineFeedsDiscoveredPairsThroughBlocManifolds [
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
CFPhysicsCleanSlateChecks >> cleanSlateBodyWithSequence: anInteger position: aPoint extent: anExtent [
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
CFPhysicsCleanSlateChecks >> stepPipelineExposesTheComposedStep [
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
CFPhysicsCleanSlateChecks >> stepPipelineCarriesActiveContactsIntoTheNextStep [
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
CFPhysicsCleanSlateChecks >> worldDelegatesOneStepToTheExplicitPipeline [
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
CFPhysicsCleanSlateChecks >> worldCarriesActiveContactsExplicitlyBetweenSteps [
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
CFPhysicsCleanSlateChecks >> islandBuilderSeparatesDisconnectedDynamicGroups [
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
CFPhysicsCleanSlateChecks >> staticBodyDoesNotBridgeDynamicIslands [
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
CFPhysicsCleanSlateChecks >> stepPipelineSolvesExplicitIslands [
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
CFPhysicsCleanSlateChecks >> cleanSlateConstraintBetween: firstBody and: secondBody [
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
CFPhysicsCleanSlateChecks >> islandWakePropagatesAcrossConnectedDynamicBodies [
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
CFPhysicsCleanSlateChecks >> islandSleepsAsOneDecision [
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
CFPhysicsCleanSlateChecks >> movingMemberKeepsTheWholeIslandAwake [
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
CFPhysicsCleanSlateChecks >> stepPipelineExposesIslandSleepDecisions [
	<gtExample>
	| result |
	result := self stepPipelineExposesTheComposedStep.
	self assert: result sleepDecisions size equals: result islands size.
	self assert: result sleepDecisions first island == result islands first.
	^ result sleepDecisions
]

{ #category : 'examples - contact events' }
CFPhysicsCleanSlateChecks >> contactEventStagePublishesLifecycleEvents [
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
CFPhysicsCleanSlateChecks >> continuedContactsDoNotPublishLifecycleEvents [
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
CFPhysicsCleanSlateChecks >> stepPipelineExposesContactEvents [
	<gtExample>
	| result |
	result := self stepPipelineExposesTheComposedStep.
	self assert: result contactEvents size equals: result beganContacts size + result endedContacts size.
	self assert: result contactBeganEvents size equals: result beganContacts size.
	self assert: result contactEndedEvents size equals: result endedContacts size.
	^ result contactEvents
]

{ #category : 'examples - step stages' }
CFPhysicsCleanSlateChecks >> stepPipelineExecutesExplicitOrderedStages [
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
CFPhysicsCleanSlateChecks >> stepPipelineExposesReplaceableStageList [
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
CFPhysicsCleanSlateChecks >> postSolveCollectorCapturesSolvedImpulses [
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
CFPhysicsCleanSlateChecks >> hitEventsAreDerivedAfterSolving [
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
CFPhysicsCleanSlateChecks >> hitEventThresholdSuppressesSmallApproaches [
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
CFPhysicsCleanSlateChecks >> stepPipelineExposesPostSolveStage [
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
CFPhysicsCleanSlateChecks >> sensorContactParticipatesInLifecycleButNotSolving [
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
CFPhysicsCleanSlateChecks >> sensorContactDoesNotJoinDynamicBodiesIntoOneIsland [
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
CFPhysicsCleanSlateChecks >> sensorContactPublishesEndedEventWithoutSolveData [
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
CFPhysicsCleanSlateChecks >> collisionFiltersAllowOrdinaryOverlappingBodies [
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
CFPhysicsCleanSlateChecks >> collisionMasksRejectBodiesBeforeManifoldConstruction [
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
CFPhysicsCleanSlateChecks >> positiveCollisionGroupOverridesMasks [
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
CFPhysicsCleanSlateChecks >> negativeCollisionGroupSuppressesCollision [
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
CFPhysicsCleanSlateChecks >> elementFacingCollisionFilteringConfiguresItsBody [
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
CFPhysicsCleanSlateChecks >> overlappingCirclesProducePersistentSinglePointManifold [
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
CFPhysicsCleanSlateChecks >> separatedCirclesDoNotProduceAManifold [
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
CFPhysicsCleanSlateChecks >> circleAgainstRectangleProducesMixedShapeManifold [
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
CFPhysicsCleanSlateChecks >> mixedShapeOrderingReversesOnlyTheManifoldOrientation [
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
CFPhysicsCleanSlateChecks >> circleContactsFlowThroughTheOrdinaryStepPipeline [
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
