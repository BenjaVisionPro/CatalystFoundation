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
