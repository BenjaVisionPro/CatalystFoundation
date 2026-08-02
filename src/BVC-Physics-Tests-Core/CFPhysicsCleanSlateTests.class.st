Class {
	#name : 'CFPhysicsCleanSlateTests',
	#superclass : 'Object',
	#category : 'BVC-Physics-Tests-Core',
	#package : 'BVC-Physics-Tests-Core'
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

{ #category : 'examples - polygon manifolds' }
CFPhysicsCleanSlateTests >> faceContactIdentityPersistsAcrossTangentialMotion [
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

{ #category : 'examples - polygon manifolds' }
CFPhysicsCleanSlateTests >> roundedPolygonUsesCoreAndRadius [
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

{ #category : 'examples - polygon manifolds' }
CFPhysicsCleanSlateTests >> separatedPolygonCoresRespectCombinedRadius [
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

{ #category : 'examples - polygon manifolds' }
CFPhysicsCleanSlateTests >> polygonRotationUsesItsCentre [
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
		bodyOrigin: 140 @ 65
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
	manifold := CFPhysicsManifoldGenerator new
		manifoldBetweenShapeState: ground bodyOrigin: (0 @ 0) + (ground extent / 2.0) rotation: 0
		andShapeState: box bodyOrigin: (20 @ 15) + (box extent / 2.0) rotation: 0.
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
	updater := CFPhysicsContactUpdater manifoldGenerator: (CFPhysicsFixedManifoldGenerator manifold: manifold).
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
	updater := CFPhysicsContactUpdater manifoldGenerator: (CFPhysicsFixedManifoldGenerator manifold: oldManifold).
	initial := updater updatePairs: { pair } fromContacts: #().
	newManifold := self cleanSlateManifoldWithFeatureIndex: 1.
	updater := CFPhysicsContactUpdater manifoldGenerator: (CFPhysicsFixedManifoldGenerator manifold: newManifold).
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
	updater := CFPhysicsContactUpdater manifoldGenerator: (CFPhysicsFixedManifoldGenerator manifold: oldManifold).
	initial := updater updatePairs: { pair } fromContacts: #().

	second beSensor.
	newManifold := self cleanSlateManifoldWithFeatureIndex: 1.
	updater := CFPhysicsContactUpdater manifoldGenerator: (CFPhysicsFixedManifoldGenerator manifold: newManifold).
	next := updater updatePairs: { pair } fromContacts: initial activeContacts.
	point := next activeContacts first manifold contactPoints first.

	self assert: point normalImpulse equals: 0.0.
	self assert: point tangentImpulse equals: 0.0.
	^ next
]

{ #category : 'examples - constraints' }
CFPhysicsCleanSlateTests >> constraintPreparationMeasuresReusableContactWork [
	<gtExample>
	| first second pair updater firstBatch secondBatch stage |
	first := self cleanSlateBodyWithSequence: 1.
	second := self cleanSlateBodyWithSequence: 2.
	pair := CFPhysicsPair first: first second: second.
	updater := CFPhysicsContactUpdater manifoldGenerator: (CFPhysicsFixedManifoldGenerator manifold: (self cleanSlateManifoldWithFeatureIndex: 1)).
	firstBatch := updater updatePairs: { pair } fromContacts: #().
	secondBatch := updater updatePairs: { pair } fromContacts: firstBatch activeContacts.
	stage := CFPhysicsConstraintPreparationStage new.
	stage measureContacts: secondBatch activeContacts.
	self assert: stage preparedContactConstraintCount equals: 1.
	self assert: stage continuedContactConstraintCount equals: 1.
	self assert: stage beganContactConstraintCount equals: 0.
	self assert: stage preparedContactPointCount equals: 1.
	self assert: stage reusableContactPointCount equals: 1.
	self assert: stage newContactPointCount equals: 0.
	self assert: stage stableManifoldCount equals: 1.
	self assert: stage changedManifoldCount equals: 0.
	self assert: stage preparedObjectCount equals: 0.
	^ stage
]

{ #category : 'examples - constraints' }
CFPhysicsCleanSlateTests >> constraintPreparationMeasuresChangedContactWork [
	<gtExample>
	| first second pair updater firstBatch secondBatch stage |
	first := self cleanSlateBodyWithSequence: 1.
	second := self cleanSlateBodyWithSequence: 2.
	pair := CFPhysicsPair first: first second: second.
	updater := CFPhysicsContactUpdater manifoldGenerator: (CFPhysicsFixedManifoldGenerator manifold: (self cleanSlateManifoldWithFeatureIndex: 1)).
	firstBatch := updater updatePairs: { pair } fromContacts: #().
	updater := CFPhysicsContactUpdater manifoldGenerator: (CFPhysicsFixedManifoldGenerator manifold: (self cleanSlateManifoldWithFeatureIndex: 2)).
	secondBatch := updater updatePairs: { pair } fromContacts: firstBatch activeContacts.
	stage := CFPhysicsConstraintPreparationStage new.
	stage measureContacts: secondBatch activeContacts.
	self assert: stage preparedContactPointCount equals: 1.
	self assert: stage reusableContactPointCount equals: 0.
	self assert: stage newContactPointCount equals: 1.
	self assert: stage stableManifoldCount equals: 0.
	self assert: stage changedManifoldCount equals: 1.
	^ stage
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
	self assert: constraint bodyA == first.
	self assert: constraint bodyB == second.
	self assert: constraint bodyStateA == (bodyStates at: first).
	self assert: constraint bodyStateB == (bodyStates at: second).
	self assert: constraint normal equals: 0 @ 1.
	self assert: constraint tangent equals: 1 @ 0.
	self assert: point featureId equals: manifold contactPoints first featureId.
	self assert: point normalMass > 0.0.
	self assert: point tangentMass > 0.0.
	self assert: (point baseSeparation closeTo: -1.0).
	^ constraint
]

{ #category : 'examples - constraints' }
CFPhysicsCleanSlateTests >> constraintBuilderUsesCapturedBodyProperties [
	<gtExample>
	| first second pair manifold bodyStates builder initialConstraint capturedConstraint |
	first := self cleanSlateBodyWithSequence: 1.
	first
		friction: 0.25;
		restitution: 0.2;
		tangentSpeed: 2.0.
	second := self cleanSlateBodyWithSequence: 2.
	second
		friction: 0.81;
		restitution: 0.6;
		tangentSpeed: -0.5.
	pair := CFPhysicsPair first: first second: second.
	manifold := self cleanSlateManifoldWithFeatureIndex: 1.
	bodyStates := IdentityDictionary new
		at: first put: (CFPhysicsBodyStepState on: first);
		at: second put: (CFPhysicsBodyStepState on: second);
		yourself.
	builder := CFPhysicsConstraintBuilder new.
	initialConstraint := (builder
		constraintsFrom: { CFPhysicsContact pair: pair manifold: manifold }
		bodyStates: bodyStates) first.
	first
		friction: 1.0;
		restitution: 1.0;
		tangentSpeed: 10.0;
		density: 10.0.
	second
		friction: 1.0;
		restitution: 0.0;
		tangentSpeed: 20.0;
		density: 20.0.
	capturedConstraint := (builder
		constraintsFrom: { CFPhysicsContact pair: pair manifold: manifold }
		bodyStates: bodyStates) first.
	self assert: capturedConstraint friction equals: initialConstraint friction.
	self assert: capturedConstraint restitution equals: initialConstraint restitution.
	self assert: capturedConstraint tangentSpeed equals: initialConstraint tangentSpeed.
	self assert: initialConstraint tangentSpeed equals: 1.5.
	self assert: capturedConstraint points first normalMass equals: initialConstraint points first normalMass.
	self assert: capturedConstraint points first tangentMass equals: initialConstraint points first tangentMass.
	^ capturedConstraint
]

{ #category : 'examples - constraints' }
CFPhysicsCleanSlateTests >> contactTangentSpeedDefaultsToZero [
	<gtExample>
	| body |
	body := self cleanSlateBodyWithSequence: 1.
	self assert: body tangentSpeed equals: 0.0.
	^ body
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
CFPhysicsCleanSlateTests >> pairFinderExpiresInactiveSweepEntriesInPlace [
	<gtExample>
	| first second third pairFinder pairs |
	first := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 10 @ 10.
	second := self cleanSlateBodyWithSequence: 2 position: 100 @ 0 extent: 10 @ 10.
	third := self cleanSlateBodyWithSequence: 3 position: 105 @ 0 extent: 10 @ 10.
	pairFinder := CFPhysicsPairFinder new.
	pairs := pairFinder pairsAmong: { third. first. second }.
	self assert: pairFinder comparisonCount equals: 1.
	self assert: pairs size equals: 1.
	self assert: pairs first firstBody equals: second.
	self assert: pairs first secondBody equals: third.
	^ pairs
]

{ #category : 'examples - pair discovery' }
CFPhysicsCleanSlateTests >> pairFinderStageUsesCapturedBodyState [
	<gtExample>
	| first second result stage pairs |
	first := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self cleanSlateBodyWithSequence: 2 position: 15 @ 0 extent: 20 @ 20.
	result := CFPhysicsStepPipelineResult new bodies: { first. second }; yourself.
	CFPhysicsBodyStateCaptureStage new executeOn: result.
	second
		position: 100 @ 0;
		collisionMaskBits: 0.
	stage := CFPhysicsPairFinderStage new.
	pairs := stage executeOn: result.
	self assert: pairs size equals: 1.
	self assert: pairs first firstBody equals: first.
	self assert: pairs first secondBody equals: second.
	^ pairs
]


{ #category : 'examples - collision filtering' }
CFPhysicsCleanSlateTests >> pairFinderStageUsesCapturedJointCollisionPolicy [
	<gtExample>
	| first second result pairs |
	first := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self cleanSlateBodyWithSequence: 2 position: 15 @ 0 extent: 20 @ 20.
	result := CFPhysicsStepPipelineResult new
		bodies: { first. second };
		collisionSuppressedBodyPairs: { { first. second } };
		yourself.
	CFPhysicsBodyStateCaptureStage new executeOn: result.
	pairs := CFPhysicsPairFinderStage new executeOn: result.
	self assert: pairs isEmpty.
	result collisionSuppressedBodyPairs: #().
	pairs := CFPhysicsPairFinderStage new executeOn: result.
	self assert: pairs size equals: 1.
	^ pairs
]

{ #category : 'examples - pair discovery' }
CFPhysicsCleanSlateTests >> bodyStepStateCapturesBlocGeometry [
	<gtExample>
	| first second result pairs |
	first := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self cleanSlateBodyWithSequence: 2 position: 15 @ 0 extent: 20 @ 20.
	result := CFPhysicsStepPipelineResult new bodies: { first. second }; yourself.
	CFPhysicsBodyStateCaptureStage new executeOn: result.
	second element size: 1 @ 1.
	pairs := CFPhysicsPairFinderStage new executeOn: result.
	self assert: pairs size equals: 1.
	self assert: (result bodyStates at: second) shapeState extent equals: 20 @ 20.
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
	pipeline := CFPhysicsStepPipeline manifoldGenerator: CFPhysicsManifoldGenerator new.
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
	pipeline := CFPhysicsStepPipeline manifoldGenerator: CFPhysicsManifoldGenerator new.
	result := pipeline
		stepBodies: { box. ground }
		fromContacts: #()
		step: step
		gravity: 0 @ 0
		restitutionThreshold: 1.0.
	manifold := CFPhysicsManifoldGenerator new
		manifoldBetweenBody: ground
		andBody: box.
	self assert: result activeContacts size equals: 1.
	self assert: box position y equals: 15.0.
	result commitBodyStates.
	self assert: box position y > 15.0.
	self assert: manifold notNil.
	self assert: manifold contactPoints first separation >= -5.0.
	^ result
]

{ #category : 'examples - step pipeline' }
CFPhysicsCleanSlateTests >> stepPipelineCarriesActiveContactsIntoTheNextStep [
	<gtExample>
	| firstResult ground box step pipeline secondResult |
	firstResult := self stepPipelineExposesTheComposedStep.
	firstResult commitBodyStates.
	ground := firstResult bodies first.
	box := firstResult bodies second.
	step := CFPhysicsStep
		timeStep: 0.016
		substeps: 4
		contactHertz: 30.0
		dampingRatio: 10.0.
	pipeline := CFPhysicsStepPipeline manifoldGenerator: CFPhysicsManifoldGenerator new.
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
	self assert: world activeContacts equals: result activeContacts.
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

{ #category : 'examples - world cutover' }
CFPhysicsCleanSlateTests >> persistentContactStorageAlternatesBetweenTwoGenerations [
	<gtExample>
	| world firstContact firstConstraint firstPoint secondContact secondConstraint secondPoint thirdContact fourthContact |
	world := self worldDelegatesOneStepToTheExplicitPipeline.
	firstContact := world activeContacts first.
	firstConstraint := firstContact preparedConstraint.
	firstPoint := firstConstraint points first.
	world step.
	secondContact := world activeContacts first.
	secondConstraint := secondContact preparedConstraint.
	secondPoint := secondConstraint points first.
	self assert: secondContact ~~ firstContact.
	self assert: secondConstraint ~~ firstConstraint.
	self assert: secondPoint ~~ firstPoint.
	world step.
	thirdContact := world activeContacts first.
	self assert: thirdContact == firstContact.
	self assert: thirdContact preparedConstraint == firstConstraint.
	self assert: thirdContact preparedConstraint points first == firstPoint.
	world step.
	fourthContact := world activeContacts first.
	self assert: fourthContact == secondContact.
	self assert: fourthContact preparedConstraint == secondConstraint.
	self assert: fourthContact preparedConstraint points first == secondPoint.
	^ fourthContact
]


{ #category : 'examples - world cutover' }
CFPhysicsCleanSlateTests >> disappearingContactReusesItsGenerationWhenItReturns [
	<gtExample>
	| world movingBody contact constraint point returnedContact returnedPoint returnedManifoldPoint |
	world := self worldDelegatesOneStepToTheExplicitPipeline.
	movingBody := world bodyStatesInOrder second.
	contact := world activeContacts first.
	constraint := contact preparedConstraint.
	point := constraint points first.
	movingBody position: 20 @ 100.
	world step.
	self assert: world activeContacts isEmpty.
	movingBody position: 20 @ 15.
	world step.
	self assert: world activeContacts size equals: 1.
	returnedContact := world activeContacts first.
	returnedPoint := returnedContact preparedConstraint points first.
	returnedManifoldPoint := returnedContact manifold contactPoints first.
	self assert: returnedContact == contact.
	self assert: returnedContact preparedConstraint == constraint.
	self assert: returnedPoint ~~ point.
	self assert: returnedPoint manifoldPoint == returnedManifoldPoint.
	self assert: returnedPoint featureId equals: returnedManifoldPoint featureId.
	self assert: returnedPoint normalImpulse equals: returnedManifoldPoint normalImpulse.
	self assert: returnedPoint tangentImpulse equals: returnedManifoldPoint tangentImpulse.
	^ returnedContact
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
	self assert: (bodyStates at: first) isAwake not.
	self assert: (bodyStates at: second) isAwake not.
	self assert: first isAwake.
	self assert: second isAwake.
	(bodyStates at: first) commit.
	(bodyStates at: second) commit.
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
	self assert: (bodyStates at: first) isAwake.
	self assert: (bodyStates at: second) isAwake.
	self assert: (bodyStates at: first) sleepTime equals: 0.0.
	self assert: (bodyStates at: second) sleepTime equals: 0.0.
	self assert: first sleepTime equals: 0.25.
	self assert: second sleepTime equals: 0.0.
	(bodyStates at: first) commit.
	(bodyStates at: second) commit.
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
	self assert: (state sleepTime closeTo: 0.02).
	self assert: body sleepTime equals: 0.0.
	state commit.
	self assert: (body sleepTime closeTo: 0.02).
	^ decision
]


{ #category : 'examples - island sleeping' }
CFPhysicsCleanSlateTests >> endingAContactWakesBothBodies [
	<gtExample>
	| first second pair manifold previousContact batch stage result bodyStates |
	first := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self cleanSlateBodyWithSequence: 2 position: 10 @ 0 extent: 20 @ 20.
	pair := CFPhysicsPair first: first second: second.
	manifold := self cleanSlateManifoldWithFeatureIndex: 1.
	previousContact := CFPhysicsContact pair: pair manifold: manifold.
	first sleep.
	second sleep.
	bodyStates := IdentityDictionary new
		at: first put: (CFPhysicsBodyStepState on: first);
		at: second put: (CFPhysicsBodyStepState on: second);
		yourself.
	batch := CFPhysicsContactUpdater new
		updatePairs: #()
		includingImpactContacts: #()
		fromContacts: { previousContact }.
	stage := CFPhysicsContactUpdateStage new.
	stage
		wakeBodiesForEndedContacts: batch endedContacts
		bodyStates: bodyStates.
	result := batch endedContacts first.
	self assert: result ended.
	self assert: (bodyStates at: first) isAwake.
	self assert: (bodyStates at: second) isAwake.
	self assert: (bodyStates at: first) sleepTime equals: 0.0.
	self assert: (bodyStates at: second) sleepTime equals: 0.0.
	self assert: first isSleeping.
	self assert: second isSleeping.
	(bodyStates at: first) commit.
	(bodyStates at: second) commit.
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
	| body |
	body := self cleanSlateBodyWithSequence: 1.
	body sleep.
	body applyImpulse: 10 @ 0 atWorldPoint: body worldBodyOrigin.
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
	result := CFPhysicsContactUpdateResult pairs: { pair } contactBatch: batch.
	events := CFPhysicsContactEventBuilder new eventsFrom: result.
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
	result := CFPhysicsContactUpdateResult pairs: { pair } contactBatch: batch.
	events := CFPhysicsContactEventBuilder new eventsFrom: result.
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
		CFPhysicsContactEventStage }.
	self assert: result executedStages size equals: expectedTypes size.
	expectedTypes withIndexDo: [ :stageType :index |
		self assert: ((result executedStages at: index) isKindOf: stageType) ].
	self assert: result stageExecutions first output == result bodyStates.
	self assert: result stageExecutions second output equals: result pairs.
	self assert: result stageExecutions third output == result contactResult.
	self assert: result stageExecutions fourth output equals: result constraints.
	self assert: result stageExecutions fifth output equals: result islands.
	self assert: (result stageExecutions at: 7) output == result solver.
	self assert: (result stageExecutions at: 8) output contactResults equals: result contactSolveResults.
	self assert: (result stageExecutions at: 8) output hitEvents equals: result hitEvents.
	self assert: (result stageExecutions at: 11) output equals: result contactEvents.
	^ result stageExecutions
]

{ #category : 'examples - step stages' }
CFPhysicsCleanSlateTests >> stepPipelineExposesReplaceableStageList [
	<gtExample>
	| pipeline stages |
	pipeline := CFPhysicsStepPipeline manifoldGenerator: CFPhysicsManifoldGenerator new.
	stages := pipeline stages.
	self assert: stages size equals: 11.
	self assert: stages first class equals: CFPhysicsVelocityIntegrationStage.
	self assert: stages second class equals: CFPhysicsPairFinderStage.
	self assert: (stages at: 9) class equals: CFPhysicsContinuousStepStage.
	self assert: (stages at: 10) class equals: CFPhysicsIslandSleepingStage.
	self assert: stages last class equals: CFPhysicsContactEventStage.
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
	self assert: pointResult totalNormalImpulse equals: constraint points first totalNormalImpulse.
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
	pipeline := CFPhysicsStepPipeline manifoldGenerator: CFPhysicsManifoldGenerator new.
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
	pipeline := CFPhysicsStepPipeline manifoldGenerator: CFPhysicsManifoldGenerator new.
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
	pipeline := CFPhysicsStepPipeline manifoldGenerator: CFPhysicsManifoldGenerator new.
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

{ #category : 'examples - circle manifolds' }
CFPhysicsCleanSlateTests >> separatedCirclesDoNotProduceAManifold [
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

{ #category : 'examples - circle manifolds' }
CFPhysicsCleanSlateTests >> circleAgainstRectangleProducesMixedShapeManifold [
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

{ #category : 'examples - circle manifolds' }
CFPhysicsCleanSlateTests >> mixedShapeOrderingReversesOnlyTheManifoldOrientation [
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
	pipeline := CFPhysicsStepPipeline manifoldGenerator: CFPhysicsManifoldGenerator new.
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











{ #category : 'examples - pull interaction' }
CFPhysicsCleanSlateTests >> pullInteractionIsInstalledThroughThePhysicsFacade [
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


{ #category : 'examples - distance joints' }
CFPhysicsCleanSlateTests >> distanceJointSpringUsesBox2DSoftConstraint [
	<gtExample>
	| owner first second world joint result prepared |
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
	joint
		length: 50;
		springEnabled: true;
		hertz: 3;
		dampingRatio: 1.
	result := world step.
	prepared := result constraints first.
	self assert: prepared springEnabled.
	self assert: prepared biasRate > 0.0.
	self assert: prepared massCoefficient > 0.0.
	self assert: first physics velocity x > 0.0.
	self assert: second physics velocity x < 0.0.
	^ result
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
	self assert: joint bodyA == first.
	self assert: joint bodyB == second.
	self assert: joint length equals: 100.0.
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
	joint length: 50.
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
	joint length: 50.
	result := world step.
	self assert: joint bodyA == element physics body.
	self assert: joint bodyB isNil.
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
	joint length: 0.
	element physics body sleep.
	worldAnchor point: 110 @ 10.
	self assert: element physics body isAwake.
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
	first physics body sleep.
	second physics body sleep.
	joint length: joint length + 10.
	self assert: first physics body isAwake.
	self assert: second physics body isAwake.
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
	joint length: 20.
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
	self assert: joint bodyA == first.
	self assert: joint bodyB == second.
	self assert: joint anchorA == firstAnchor.
	self assert: joint anchorB == secondAnchor.
	self assert: joint accumulatedImpulse equals: 0 @ 0.
	self assert: joint springEnabled not.
	self assert: joint hertz equals: 0.0.
	self assert: joint dampingRatio equals: 0.0.
	self assert: joint targetAngle equals: 0.0.
	self assert: joint springImpulse equals: 0.0.
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
	self assert: (first physics velocity x closeTo: 0.0).
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
	self assert: joint bodyA == element physics body.
	self assert: joint bodyB isNil.
	self assert: result constraints size equals: 1.
	self assert: result islands size equals: 1.
	self assert: (element physics velocity x closeTo: 0.0).
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
	element physics body sleep.
	worldAnchor point: 110 @ 10.
	self assert: element physics body isAwake.
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
		maximumMotorTorque: 1000.0.
	result := world step.
	self assert: result constraints first motorEnabled.
	self assert: first physics angularVelocity < 0.0.
	self assert: second physics angularVelocity equals: 0.0.
	^ result
]


{ #category : 'examples - revolute joints' }
CFPhysicsCleanSlateTests >> revoluteJointMotorTorqueIsConvertedToASubstepImpulse [
	<gtExample>
	| owner first second world firstAnchor secondAnchor joint result prepared |
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
		maximumMotorTorque: 1000.0.
	result := world step.
	prepared := result constraints first.
	self assert: (prepared maximumMotorImpulse closeTo: 1000.0 * result step substepTime).
	^ result
]

{ #category : 'examples - revolute joints' }
CFPhysicsCleanSlateTests >> revoluteJointMotorConfigurationPreservesItsAccumulatedImpulse [
	<gtExample>
	| first second joint |
	first := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self cleanSlateBodyWithSequence: 2 position: 30 @ 0 extent: 20 @ 20.
	joint := CFPhysicsRevoluteJoint between: first and: second.
	joint motorImpulse: 3.0.
	joint motorSpeed: 7.0.
	self assert: (joint motorImpulse closeTo: 3.0).
	joint maximumMotorTorque: 11.0.
	self assert: (joint motorImpulse closeTo: 3.0).
	joint motorEnabled: true.
	self assert: (joint motorImpulse closeTo: 0.0).
	^ joint
]

{ #category : 'examples - revolute joints' }
CFPhysicsCleanSlateTests >> revoluteJointAllowsEqualLimitAngles [
	<gtExample>
	| first second joint |
	first := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self cleanSlateBodyWithSequence: 2 position: 30 @ 0 extent: 20 @ 20.
	joint := CFPhysicsRevoluteJoint between: first and: second.
	joint limitAnglesFrom: 0.25 to: 0.25.
	self assert: (joint lowerAngle closeTo: 0.25).
	self assert: (joint upperAngle closeTo: 0.25).
	^ joint
]


{ #category : 'examples - revolute joints' }
CFPhysicsCleanSlateTests >> revoluteJointSpringDrivesRelativeAngleTowardItsTarget [
	<gtExample>
	| owner element world bodyAnchor worldAnchor joint initialRotation result |
	owner := BlElement new size: 400 @ 300; yourself.
	element := BlElement new size: 20 @ 20; yourself.
	owner addChild: element.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world synchroniseMembership.
	element physics position: 0 @ 0.
	element physics rotation: 0.5.
	bodyAnchor := element physics localAnchorAt: 10 @ 10.
	worldAnchor := world anchorAt: 10 @ 10.
	joint := bodyAnchor revoluteJointTo: worldAnchor.
	joint
		springEnabled: true;
		targetAngle: 0.0;
		hertz: 5.0;
		dampingRatio: 1.0.
	initialRotation := element physics rotation abs.
	result := world step.
	self assert: result constraints first springEnabled.
	self assert: joint springImpulse abs > 0.0.
	self assert: element physics rotation abs < initialRotation.
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
	^ result
]

{ #category : 'examples - prismatic joints' }
CFPhysicsCleanSlateTests >> prismaticJointConstrainsAnAnchoredElementToItsAxis [
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
	joint := bodyAnchor prismaticJointTo: worldAnchor along: 1 @ 0.
	element physics velocity: 100 @ 100.
	element physics angularVelocity: 10.0.
	result := world step.
	self assert: world prismaticJoints equals: { joint }.
	self assert: result constraints size equals: 1.
	self assert: result constraints first class equals: CFPhysicsPreparedPrismaticJoint.
	self assert: (element physics velocity y closeTo: 0.0).
	self assert: (element physics angularVelocity closeTo: 0.0).
	^ result
]

{ #category : 'examples - prismatic joints' }
CFPhysicsCleanSlateTests >> prismaticJointLimitsBoundAnAnchoredElementTravel [
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
	joint := bodyAnchor prismaticJointTo: worldAnchor along: 1 @ 0.
	joint
		limitTranslationFrom: -10 to: 10;
		limitsEnabled: true.
	element physics position: 20 @ 0.
	result := world step.
	self assert: result constraints first limitsEnabled.
	self assert: result constraints first baseTranslation equals: 20.0.
	self assert: (element physics position x < 20.0).
	self assert: (element physics velocity x closeTo: 0.0).
	^ result
]

{ #category : 'examples - prismatic joints' }
CFPhysicsCleanSlateTests >> mouseJointRespectsAPrismaticAxis [
	<gtExample>
	| owner element world bodyAnchor worldAnchor joint mouseJoint result |
	owner := BlElement new size: 400 @ 300; yourself.
	element := BlElement new size: 20 @ 20; yourself.
	owner addChild: element.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world synchroniseMembership.
	element physics position: 0 @ 0.
	bodyAnchor := element physics localAnchorAt: 10 @ 10.
	worldAnchor := world anchorAt: 10 @ 10.
	joint := bodyAnchor prismaticJointTo: worldAnchor along: 1 @ 0.
	joint
		limitTranslationFrom: -10 to: 10;
		limitsEnabled: true.
	mouseJoint := CFPhysicsMouseJoint body: element physics body target: 10 @ 10.
	mouseJoint
		target: 1000 @ 1000;
		maximumForce: 100000.0.
	world addMouseJoint: mouseJoint.
	result := world step.
	self assert: (element physics velocity y closeTo: 0.0).
	self assert: (element physics position y abs < element physics position x abs).
	self assert: (element physics position x > 0.0).
	self assert: (element physics position x < 10.0).
	^ result
]

{ #category : 'examples - weld joints' }
CFPhysicsCleanSlateTests >> weldJointCapturesItsReferenceAngle [
	<gtExample>
	| first second joint |
	first := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self cleanSlateBodyWithSequence: 2 position: 30 @ 0 extent: 20 @ 20.
	first rotation: 0.25.
	second rotation: 0.75.
	joint := CFPhysicsWeldJoint between: first and: second.
	self assert: joint bodyA == first.
	self assert: joint bodyB == second.
	self assert: joint referenceAngle equals: 0.5.
	self assert: joint accumulatedAngularImpulse equals: 0.0.
	self assert: joint linearHertz equals: 0.0.
	self assert: joint linearDampingRatio equals: 0.0.
	self assert: joint angularHertz equals: 0.0.
	self assert: joint angularDampingRatio equals: 0.0.
	^ joint
]

{ #category : 'examples - weld joints' }
CFPhysicsCleanSlateTests >> weldJointPreparesIndependentLinearAndAngularSoftness [
	<gtExample>
	| owner element world bodyAnchor worldAnchor joint result prepared |
	owner := BlElement new size: 400 @ 300; yourself.
	element := BlElement new size: 20 @ 20; yourself.
	owner addChild: element.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world synchroniseMembership.
	element physics position: 0 @ 0.
	bodyAnchor := element physics localAnchorAt: 10 @ 10.
	worldAnchor := world anchorAt: 10 @ 10.
	joint := bodyAnchor weldJointTo: worldAnchor.
	joint
		linearHertz: 4.0;
		linearDampingRatio: 0.5;
		angularHertz: 7.0;
		angularDampingRatio: 0.75.
	result := world step.
	prepared := result constraints first.
	self assert: prepared linearSoftnessEnabled.
	self assert: prepared angularSoftnessEnabled.
	self assert: (prepared linearBiasRate > 0.0).
	self assert: (prepared angularBiasRate > 0.0).
	self assert: ((prepared linearBiasRate closeTo: prepared angularBiasRate) not).
	^ prepared
]

{ #category : 'examples - weld joints' }
CFPhysicsCleanSlateTests >> weldJointAnchorsABodyOrientationToTheWorld [
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
	joint := bodyAnchor weldJointTo: worldAnchor.
	element physics angularVelocity: 10.0.
	result := world step.
	self assert: world weldJoints equals: { joint }.
	self assert: result constraints size equals: 1.
	self assert: result constraints first class equals: CFPhysicsPreparedWeldJoint.
	self assert: result islands size equals: 1.
	self assert: (element physics angularVelocity closeTo: 0.0).
	^ result
]

{ #category : 'examples - weld joints' }
CFPhysicsCleanSlateTests >> weldJointPreparationUnwindsTheReferenceAngleError [
	<gtExample>
	| first second firstAnchor secondAnchor joint builder bodyStates step prepared |
	first := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self cleanSlateBodyWithSequence: 2 position: 20 @ 0 extent: 20 @ 20.
	first rotation: 3.1.
	second rotation: -3.1.
	firstAnchor := CFPhysicsLocalAnchor on: first at: 10 @ 10.
	secondAnchor := CFPhysicsLocalAnchor on: second at: 10 @ 10.
	joint := CFPhysicsWeldJoint betweenAnchor: firstAnchor andAnchor: secondAnchor.
	joint referenceAngle: 0.0.
	bodyStates := IdentityDictionary new
		at: first put: (CFPhysicsBodyStepState on: first);
		at: second put: (CFPhysicsBodyStepState on: second);
		yourself.
	step := CFPhysicsStep
		timeStep: 1.0 / 60.0
		substeps: 4
		contactHertz: 30.0
		dampingRatio: 10.0.
	builder := CFPhysicsWeldJointConstraintBuilder new.
	prepared := builder constraintFrom: joint bodyStates: bodyStates step: step.
	self assert: (prepared baseAngle closeTo: (2.0 * Float pi) - 6.2).
	^ prepared
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
	self
		assert: (result joints collect: #solverCommitTarget)
		equals: { distance. revolute }.
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
	fixed := first physics weldJointTo: third.
	unrelated := second physics distanceJointTo: fourth.
	owner removeChild: first.
	world synchroniseMembership.
	self assert: world revoluteJoints isEmpty.
	self assert: world weldJoints isEmpty.
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
	self assert: joint collideConnected not.
	pairs := CFPhysicsPairFinder new pairsAmong: {
		first physics body.
		second physics body }.
	self assert: pairs isEmpty.
	joint collideConnected: true.
	pairs := CFPhysicsPairFinder new pairsAmong: {
		first physics body.
		second physics body }.
	self assert: pairs size equals: 1.
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
	self assert: joint collideConnected not.
	pairs := CFPhysicsPairFinder new pairsAmong: {
		first physics body.
		second physics body }.
	self assert: pairs isEmpty.
	joint collideConnected: true.
	pairs := CFPhysicsPairFinder new pairsAmong: {
		first physics body.
		second physics body }.
	self assert: pairs size equals: 1.
	^ joint
]

{ #category : 'examples - collision filtering' }
CFPhysicsCleanSlateTests >> weldJointCanSuppressCollisionBetweenItsEndpoints [
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
	joint := first physics weldJointTo: second.
	self assert: joint collideConnected not.
	pairs := CFPhysicsPairFinder new pairsAmong: {
		first physics body.
		second physics body }.
	self assert: pairs isEmpty.
	joint collideConnected: true.
	pairs := CFPhysicsPairFinder new pairsAmong: {
		first physics body.
		second physics body }.
	self assert: pairs size equals: 1.
	^ joint
]

{ #category : 'examples - collision filtering' }
CFPhysicsCleanSlateTests >> prismaticJointCanSuppressCollisionBetweenItsEndpoints [
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
	joint := first physics prismaticJointTo: second along: 1 @ 0.
	self assert: joint collideConnected not.
	pairs := CFPhysicsPairFinder new pairsAmong: {
		first physics body.
		second physics body }.
	self assert: pairs isEmpty.
	joint collideConnected: true.
	pairs := CFPhysicsPairFinder new pairsAmong: {
		first physics body.
		second physics body }.
	self assert: pairs size equals: 1.
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
	joint collideConnected: true.
	first physics body sleep.
	second physics body sleep.
	joint collideConnected: false.
	self assert: first physics body isAwake.
	self assert: second physics body isAwake.
	^ joint
]


{ #category : 'examples - containment interaction' }
CFPhysicsCleanSlateTests >> worldBoundaryContainsBodiesByDefault [
	<gtExample>
	| owner element world |
	owner := BlElement new size: 100 @ 100; yourself.
	element := BlElement new size: 20 @ 20; yourself.
	owner addChild: element.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world synchroniseMembership.
	element physics position: 90 @ 90.
	world step.
	self assert: element physics position equals: 80 @ 80.
	self assert: world boundary enabled.
	^ world
]

{ #category : 'examples - containment interaction' }
CFPhysicsCleanSlateTests >> worldBoundaryCanBeDisabled [
	<gtExample>
	| owner element world |
	owner := BlElement new size: 100 @ 100; yourself.
	element := BlElement new size: 20 @ 20; yourself.
	owner addChild: element.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world boundary enabled: false.
	world synchroniseMembership.
	element physics position: 90 @ 90.
	world step.
	self assert: element physics position equals: 90 @ 90.
	^ world
]

{ #category : 'examples - containment interaction' }
CFPhysicsCleanSlateTests >> worldBoundaryCanBounceAtTheWorldEdge [
	<gtExample>
	| owner element world |
	owner := BlElement new size: 100 @ 100; yourself.
	element := BlElement new size: 20 @ 20; yourself.
	owner addChild: element.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world boundary restitution: 0.5.
	world synchroniseMembership.
	element physics
		position: 90 @ 20;
		velocity: 50 @ 0.
	world step.
	self assert: (element physics position x closeTo: 79.6).
	self assert: element physics position y equals: 20.
	self assert: element physics velocity equals: -25 @ 0.
	^ world
]

{ #category : 'examples - containment interaction' }
CFPhysicsCleanSlateTests >> worldBoundaryUsesItsMargin [
	<gtExample>
	| owner element world |
	owner := BlElement new size: 100 @ 100; yourself.
	element := BlElement new size: 20 @ 20; yourself.
	owner addChild: element.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world boundary margin: 10.
	world synchroniseMembership.
	element physics position: 0 @ 0.
	world step.
	self assert: element physics position equals: 10 @ 10.
	^ world
]

{ #category : 'examples - containment interaction' }
CFPhysicsCleanSlateTests >> worldBoundaryUsesTheCurrentWorldExtent [
	<gtExample>
	| owner element world |
	owner := BlElement new size: 100 @ 100; yourself.
	element := BlElement new size: 20 @ 20; yourself.
	owner addChild: element.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world synchroniseMembership.
	element physics position: 130 @ 20.
	owner size: 160 @ 100.
	world step.
	self assert: element physics position equals: 130 @ 20.
	^ world
]

{ #category : 'examples - containment interaction' }
CFPhysicsCleanSlateTests >> explicitContainmentOverridesTheWorldBoundary [
	<gtExample>
	| owner element world containment |
	owner := BlElement new size: 100 @ 100; yourself.
	element := BlElement new size: 20 @ 20; yourself.
	owner addChild: element.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world boundary restitution: 0.0.
	world synchroniseMembership.
	containment := element physics containWithinWorld.
	containment restitution: 0.5.
	element physics
		position: 90 @ 20;
		velocity: 50 @ 0.
	world step.
	self assert: (element physics position x closeTo: 79.6).
	self assert: element physics position y equals: 20.
	self assert: element physics velocity equals: -25 @ 0.
	^ containment
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
	self assert: world attractions equals: { firstAttraction. secondAttraction }.
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
	self assert: world attractions equals: { unrelated }.
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
	self assert: world repulsions equals: { firstRepulsion. secondRepulsion }.
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
	self assert: world repulsions equals: { unrelated }.
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
	world boundary enabled: false.
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
	self assert: (anchor worldPoint closeTo: 140 @ 70).
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
	self assert: anchor body == element physics body.
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

{ #category : 'examples - anchors' }
CFPhysicsCleanSlateTests >> normalisedAnchorFollowsBodyGeometry [
	<gtExample>
	| body anchor |
	body := self cleanSlateBodyWithSequence: 1 position: 100 @ 50 extent: 40 @ 20.
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
	self assert: anchor body == element physics body.
	self assert: anchor worldPoint equals: 140 @ 70.
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
	self assert: points second equals: 100 @ 65.
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
		distanceJointTo: (world anchorAt: 100 @ 10).
	spring springEnabled: true; hertz: 3.0; dampingRatio: 1.0.
	world removeDistanceJointsUsingBody: body.
	self assert: world springs isEmpty.
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
	element := BlElement new size: 20 @ 10.
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
	element := BlElement new size: 40 @ 10.
	body := CFPhysicsBody element: element world: nil.
	body
		position: 10 @ 20;
		beginStep;
		addAngularVelocity: Float pi / 2.0;
		advanceBy: 1.0 gravity: 0 @ 0.
	previousBounds := body shapeState
		aabbAtBodyOrigin: body sweep startTransform bodyOrigin
		rotation: body previousRotation.
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
	self assert: sweep startTransform bodyOrigin equals: 15 @ 25.
	self assert: sweep startTransform rotation equals: 0.
	self assert: sweep endTransform bodyOrigin equals: 25 @ 25.
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
	self assert: sweep startTransform bodyOrigin equals: 15 @ 25.
	self assert: sweep endTransform bodyOrigin equals: 15 @ 25.
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
	self assert: sweep startTransform bodyOrigin equals: 45 @ 55.
	self assert: sweep endTransform bodyOrigin equals: 45 @ 55.
	self assert: (sweep startTransform rotation closeTo: Float pi / 4.0).
	self assert: (sweep endTransform rotation closeTo: Float pi / 4.0).
	^ sweep
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> sweepInterpolationPreservesIntegratedAngularDisplacement [
	<gtExample>
	| sweep transform |
	sweep := CFPhysicsSweep
		from: (CFPhysicsTransform bodyOrigin: 0 @ 0 rotation: 0.0)
		to: (CFPhysicsTransform bodyOrigin: 0 @ 0 rotation: Float pi * 3.0).
	transform := sweep transformAt: 0.5.
	self assert: (transform rotation closeTo: Float pi * 1.5).
	^ transform
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> sweepInterpolatesTransform [
	<gtExample>
	| sweep transform |
	sweep := CFPhysicsSweep
		from: (CFPhysicsTransform bodyOrigin: 0 @ 10 rotation: 0.0)
		to: (CFPhysicsTransform bodyOrigin: 20 @ 30 rotation: Float pi).
	transform := sweep transformAt: 0.25.
	self assert: transform bodyOrigin equals: 5 @ 15.
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
	self assert: transform bodyOrigin equals: 21 @ 23.
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
	self assert: transform bodyOrigin equals: 15 @ 25.
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
	self assert: sweep startTransform bodyOrigin equals: 15 @ 25.
	self assert: (sweep startTransform rotation closeTo: Float pi / 4.0).
	self assert: sweep endTransform bodyOrigin equals: 31 @ 37.
	self assert: (sweep endTransform rotation closeTo: Float pi * 1.25).
	^ sweep
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> stepStateUsesCapturedBodyValues [
	<gtExample>
	| body state transform |
	body := self cleanSlateBodyWithSequence: 1 position: 10 @ 20 extent: 10 @ 10.
	body velocity: 12 @ -4.
	state := CFPhysicsBodyStepState on: body.
	body
		position: 100 @ 200;
		velocity: 50 @ 50.
	transform := state predictedTransformAfter: 0.5.
	self assert: transform bodyOrigin equals: 21 @ 23.
	^ transform
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
	self assert: sweep startTransform bodyOrigin equals: 15 @ 25.
	self assert: sweep endTransform bodyOrigin equals: 15 @ 25.
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
	self assert: sweep startTransform bodyOrigin equals: 15 @ 25.
	self assert: sweep endTransform bodyOrigin equals: 15 @ 25.
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
	self assert: sweep startTransform bodyOrigin equals: sweep endTransform bodyOrigin.
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
	pipeline := CFPhysicsStepPipeline manifoldGenerator: CFPhysicsManifoldGenerator new.
	result := pipeline
		stepBodies: { obstacle. moving }
		fromContacts: #()
		step: step
		gravity: 0 @ 0
		restitutionThreshold: 1.0.
	predictedEndBounds := moving shapeState
		aabbAtBodyOrigin: 105 @ 5
		rotation: moving rotation.
	self assert: ((moving shapeState aabbAtBodyOrigin: 5 @ 5 rotation: 0.0) overlaps: obstacle aabb) not.
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
	firstTransform := CFPhysicsTransform bodyOrigin: 0 @ 0 rotation: 0.
	overlappingTransform := CFPhysicsTransform bodyOrigin: 10 @ 0 rotation: 0.
	separatedTransform := CFPhysicsTransform bodyOrigin: 30 @ 0 rotation: 0.
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
	firstTransform := CFPhysicsTransform bodyOrigin: 20 @ 5 rotation: Float pi / 2.0.
	secondTransform := CFPhysicsTransform bodyOrigin: 19 @ 19 rotation: 0.
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
		transform: (CFPhysicsTransform bodyOrigin: 0 @ 0 rotation: 0)
		andShapeState: second
		transform: (CFPhysicsTransform bodyOrigin: 30 @ 0 rotation: 0).
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
		transform: (CFPhysicsTransform bodyOrigin: 0 @ 0 rotation: Float pi / 2.0)
		andShapeState: second
		transform: (CFPhysicsTransform bodyOrigin: 30 @ 0 rotation: 0).
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
		transform: (CFPhysicsTransform bodyOrigin: 0 @ 0 rotation: 0)
		andShapeState: second
		transform: (CFPhysicsTransform bodyOrigin: 10 @ 0 rotation: 0).
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
		from: (CFPhysicsTransform bodyOrigin: 0 @ 0 rotation: 0)
		to: (CFPhysicsTransform bodyOrigin: 40 @ 0 rotation: 0).
	secondSweep := CFPhysicsSweep
		from: (CFPhysicsTransform bodyOrigin: 30 @ 0 rotation: 0)
		to: (CFPhysicsTransform bodyOrigin: 30 @ 0 rotation: 0).
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
		from: (CFPhysicsTransform bodyOrigin: 0 @ 0 rotation: 0)
		to: (CFPhysicsTransform bodyOrigin: 10 @ 0 rotation: 0).
	secondSweep := CFPhysicsSweep
		from: (CFPhysicsTransform bodyOrigin: 10 @ 0 rotation: 0)
		to: (CFPhysicsTransform bodyOrigin: 10 @ 0 rotation: 0).
	result := CFPhysicsConservativeAdvancement
		betweenShapeState: first
		sweep: firstSweep
		andShapeState: second
		sweep: secondSweep.
	self assert: result isOverlapped.
	self assert: result hasImpact not.
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
		from: (CFPhysicsTransform bodyOrigin: 0 @ 0 rotation: 0)
		to: (CFPhysicsTransform bodyOrigin: -20 @ 0 rotation: 0).
	secondSweep := CFPhysicsSweep
		from: (CFPhysicsTransform bodyOrigin: 30 @ 0 rotation: 0)
		to: (CFPhysicsTransform bodyOrigin: 30 @ 0 rotation: 0).
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
		from: (CFPhysicsTransform bodyOrigin: 0 @ 0 rotation: 0)
		to: (CFPhysicsTransform bodyOrigin: 20 @ 0 rotation: 0).
	secondSweep := CFPhysicsSweep
		from: (CFPhysicsTransform bodyOrigin: 40 @ 0 rotation: 0)
		to: (CFPhysicsTransform bodyOrigin: 20 @ 0 rotation: 0).
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
CFPhysicsCleanSlateTests >> transformExplicitManifoldDoesNotUseAuthoritativeTransforms [
	<gtExample>
	| first second manifold |
	first := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self cleanSlateBodyWithSequence: 2 position: 100 @ 0 extent: 20 @ 20.
	manifold := CFPhysicsManifoldGenerator new
		manifoldBetweenShapeState: first shapeState
		transform: (CFPhysicsTransform bodyOrigin: 0 @ 0 rotation: 0.0)
		andShapeState: second shapeState
		transform: (CFPhysicsTransform bodyOrigin: 20 @ 0 rotation: 0.0).
	self assert: manifold notNil.
	self assert: first position equals: 0 @ 0.
	self assert: second position equals: 100 @ 0.
	^ manifold
]


{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> transformExplicitTouchingManifoldProvidesLocalAnchors [
	<gtExample>
	| first second firstTransform secondTransform manifold |
	first := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self cleanSlateBodyWithSequence: 2 position: 100 @ 0 extent: 20 @ 20.
	firstTransform := CFPhysicsTransform bodyOrigin: 0 @ 0 rotation: 0.0.
	secondTransform := CFPhysicsTransform bodyOrigin: 20 @ 0 rotation: 0.0.
	manifold := CFPhysicsManifoldGenerator new
		manifoldBetweenShapeState: first shapeState
		transform: firstTransform
		andShapeState: second shapeState
		transform: secondTransform.
	self assert: manifold contactPoints size equals: 2.
	manifold contactPoints do: [ :each |
		self assert: each localAnchorA notNil.
		self assert: each localAnchorB notNil.
		self assert: (each localAnchorA x closeTo: 20).
		self assert: (each localAnchorB x closeTo: 0) ].
	self assert: (manifold contactPoints collect: [ :each | each localAnchorA y ]) asSet equals: #(0 20) asSet.
	self assert: (manifold contactPoints collect: [ :each | each localAnchorB y ]) asSet equals: #(0 20) asSet.
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
CFPhysicsCleanSlateTests >> stepPipelineUsesContinuousPathForSweptImpact [
	<gtExample>
	| moving obstacle pipeline step result |
	moving := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	obstacle := self cleanSlateBodyWithSequence: 2 position: 30 @ 0 extent: 20 @ 20.
	obstacle beStatic.
	moving velocity: 40 @ 0.
	moving beginStep.
	obstacle beginStep.
	pipeline := CFPhysicsStepPipeline manifoldGenerator: CFPhysicsManifoldGenerator new.
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
	self assert: moving position equals: 0 @ 0.
	result commitBodyStates.
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
	joint length: 50.
	pipeline := CFPhysicsStepPipeline manifoldGenerator: CFPhysicsManifoldGenerator new.
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
	self assert: joint impulse isZero.
	result commitJointConstraints.
	self assert: joint impulse isZero not.
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
	pipeline := CFPhysicsStepPipeline manifoldGenerator: CFPhysicsManifoldGenerator new.
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
	self assert: moving position equals: 0 @ 0.
	result commitBodyStates.
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
	self assert: (sweep startTransform bodyOrigin closeTo: 20 @ 10).
	self assert: (sweep endTransform bodyOrigin closeTo: 50 @ 10).
	self assert: body position equals: 0 @ 0.
	^ sweep
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
	pipeline := CFPhysicsStepPipeline manifoldGenerator: CFPhysicsManifoldGenerator new.
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
	result commitBodyStates.
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
	pipeline := CFPhysicsStepPipeline manifoldGenerator: CFPhysicsManifoldGenerator new.
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
	result commitBodyStates.
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
	pipeline := CFPhysicsStepPipeline manifoldGenerator: CFPhysicsManifoldGenerator new.
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
	pipeline := CFPhysicsStepPipeline manifoldGenerator: CFPhysicsManifoldGenerator new.
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
	result commitBodyStates.
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
	pipeline := CFPhysicsStepPipeline manifoldGenerator: CFPhysicsManifoldGenerator new.
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
	result commitBodyStates.
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
	pipeline := CFPhysicsStepPipeline manifoldGenerator: CFPhysicsManifoldGenerator new.
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
CFPhysicsCleanSlateTests >> stepPipelinePublishesSweptSensorWithoutSolvingOrBlockingMotion [
	<gtExample>
	| moving sensor pipeline step result |
	moving := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	sensor := self cleanSlateBodyWithSequence: 2 position: 30 @ 0 extent: 20 @ 20.
	sensor beStatic; beSensor.
	moving velocity: 60 @ 0.
	moving beginStep.
	sensor beginStep.
	pipeline := CFPhysicsStepPipeline manifoldGenerator: CFPhysicsManifoldGenerator new.
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
	result commitBodyStates.
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
	pipeline := CFPhysicsStepPipeline manifoldGenerator: CFPhysicsManifoldGenerator new.
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
	result commitBodyStates.
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
	pipeline := CFPhysicsStepPipeline manifoldGenerator: CFPhysicsManifoldGenerator new.
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
	result commitBodyStates.
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
	pipeline := CFPhysicsStepPipeline manifoldGenerator: CFPhysicsManifoldGenerator new.
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
	secondResult commitBodyStates.
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

{ #category : 'examples - step pipeline' }
CFPhysicsCleanSlateTests >> solvedBodyStateRemainsDetachedUntilPipelineResultCommit [
	<gtExample>
	| body state result |
	body := self cleanSlateBodyWithSequence: 1 position: 10 @ 20 extent: 30 @ 40.
	state := CFPhysicsBodyStepState on: body.
	state
		translateBy: 60 @ 60;
		linearVelocity: 3 @ 4.
	result := CFPhysicsStepPipelineResult new
		orderedBodyStates: { state };
		yourself.
	self assert: body position equals: 10 @ 20.
	self assert: body velocity equals: 0 @ 0.
	result commitBodyStates.
	self assert: body position equals: 70 @ 80.
	self assert: body velocity equals: 3 @ 4.
	^ result
]

{ #category : 'examples - constraint preparation' }
CFPhysicsCleanSlateTests >> preparedJointImpulseRemainsDetachedUntilPipelineResultCommit [
	<gtExample>
	| first second joint prepared result |
	first := self cleanSlateBodyWithSequence: 1.
	second := self cleanSlateBodyWithSequence: 2.
	joint := CFPhysicsDistanceJoint between: first and: second.
	prepared := CFPhysicsPreparedDistanceJoint new
		joint: joint;
		impulse: 3.0;
		yourself.
	result := CFPhysicsStepPipelineResult new
		jointConstraints: { prepared };
		yourself.
	self assert: joint impulse equals: 0.0.
	result commitJointConstraints.
	self assert: joint impulse equals: 3.0.
	^ result
]

{ #category : 'examples - constraint preparation' }
CFPhysicsCleanSlateTests >> preparedJointConstraintsShareTheirJointStateContract [
	<gtExample>
	self assert: CFPhysicsPreparedDistanceJoint superclass equals: CFPhysicsPreparedJointConstraint.
	self assert: CFPhysicsPreparedRevoluteJoint superclass equals: CFPhysicsPreparedJointConstraint.
	self assert: CFPhysicsPreparedPrismaticJoint superclass equals: CFPhysicsPreparedJointConstraint.
	self assert: (CFPhysicsPreparedWeldJoint inheritsFrom: CFPhysicsPreparedJointConstraint).
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
	self assert: physics beWorld == world.
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
	self assert: child physics beWorld == world.
	self assert: child physics isWorld not.
	^ world
]

{ #category : 'examples - worlds' }
CFPhysicsCleanSlateTests >> beWorldInstallsOnReceiverWhenNoWorldExists [
	<gtExample>
	| root parent child world |
	root := BlElement new.
	parent := BlElement new.
	child := BlElement new.
	root addChild: parent.
	parent addChild: child.
	world := child physics beWorld.
	self assert: root physics world isNil.
	self assert: parent physics world isNil.
	self assert: child physics world == world.
	self assert: child physics isWorld.
	^ world
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
CFPhysicsCleanSlateTests >> testForceDirectedDefaultsFavourQuickSettling [
	| behaviour |
	behaviour := CFPhysicsForceDirectedBehaviour new.
	self assert: behaviour length equals: 80.0.
	self assert: behaviour hertz equals: 3.0.
	self assert: behaviour dampingRatio equals: 1.0.
	self assert: behaviour repulsion equals: 100000.0.
	self assert: behaviour repulsionSofteningDistance equals: 50.0.
	self assert: behaviour maximumRepulsionDistance equals: 200.0.
	self assert: behaviour velocityDamping equals: 8.0
]

{ #category : 'tests - worlds' }
CFPhysicsCleanSlateTests >> testCeaseBeingWorldReleasesItsBodiesAndConstraints [
	| root first second world spring repulsion |
	root := BlElement new.
	first := BlElement new extent: 20 @ 20.
	second := BlElement new extent: 20 @ 20.
	root addChildren: { first. second }.
	world := root physics beWorld.
	world synchroniseMembership.
	spring := first physics distanceJointTo: second.
	spring springEnabled: true; hertz: 3.0; dampingRatio: 1.0.
	repulsion := first physics repel: second.
	root physics ceaseBeingWorld.
	self assert: root physics world isNil.
	self assert: world members isEmpty.
	self assert: world springs isEmpty.
	self assert: world repulsions isEmpty.
	self deny: spring isActive.
	self deny: repulsion isActive
]

{ #category : 'tests - behaviours' }
CFPhysicsCleanSlateTests >> testForceDirectedCreatesSpringsAndRepulsionsInConnectionOrder [
	| root first second third world edge behaviour |
	root := BlElement new.
	first := BlElement new extent: 20 @ 20.
	second := BlElement new extent: 20 @ 20.
	third := BlElement new extent: 20 @ 20.
	root addChildren: { first. second. third }.
	world := root physics beWorld.
	world gravity: 0 @ 0.
	edge := first -> second.
	behaviour := root physics forceDirected.
	behaviour
		nodes: [ { first. second. third } ];
		connections: [ { edge } ].
	world step.
	self assert: behaviour springsByConnection size equals: 1.
	self assert: behaviour repulsionsByPair size equals: 3.
	self assert: world springs size equals: 1.
	self assert: world repulsions size equals: 3
]

{ #category : 'tests - behaviours' }
CFPhysicsCleanSlateTests >> testForceDirectedRetainsExistingConstraintsWhileReconcilingChanges [
	| root first second third world nodes connections firstConnection secondConnection behaviour retainedSpring retainedRepulsion |
	root := BlElement new.
	first := BlElement new extent: 20 @ 20.
	second := BlElement new extent: 20 @ 20.
	third := BlElement new extent: 20 @ 20.
	root addChildren: { first. second. third }.
	world := root physics beWorld.
	world gravity: 0 @ 0.
	nodes := OrderedCollection with: first with: second.
	firstConnection := first -> second.
	secondConnection := second -> third.
	connections := OrderedCollection with: firstConnection.
	behaviour := root physics forceDirected.
	behaviour
		nodes: [ nodes ];
		connections: [ connections ].
	world step.
	retainedSpring := behaviour springsByConnection at: firstConnection.
	retainedRepulsion := behaviour repulsionsByPair values anyOne.
	nodes add: third.
	connections add: secondConnection.
	world step.
	self assert: (behaviour springsByConnection at: firstConnection) identicalTo: retainedSpring.
	self assert: (behaviour repulsionsByPair values includes: retainedRepulsion).
	self assert: behaviour springsByConnection size equals: 2.
	self assert: behaviour repulsionsByPair size equals: 3.
	connections remove: firstConnection.
	nodes remove: first.
	world step.
	self deny: (behaviour springsByConnection includesKey: firstConnection).
	self assert: behaviour springsByConnection size equals: 1.
	self assert: behaviour repulsionsByPair size equals: 1.
	self deny: retainedSpring isActive
]

{ #category : 'tests - behaviours' }
CFPhysicsCleanSlateTests >> testForceDirectedConfigurationUpdatesSharedPrimitiveValues [
	| root first second world connection behaviour spring repulsion |
	root := BlElement new.
	first := BlElement new extent: 20 @ 20.
	second := BlElement new extent: 20 @ 20.
	root addChildren: { first. second }.
	world := root physics beWorld.
	connection := first -> second.
	behaviour := root physics forceDirected.
	behaviour
		nodes: [ { first. second } ];
		connections: [ { connection } ].
	world step.
	spring := behaviour springsByConnection at: connection.
	repulsion := behaviour repulsionsByPair values anyOne.
	behaviour
		length: 175;
		hertz: 25;
		dampingRatio: 4;
		repulsion: 700;
		repulsionSofteningDistance: 35;
		maximumRepulsionDistance: 250;
		velocityDamping: 12.
	world step.
	self assert: spring length equals: 175.0.
	self assert: spring hertz equals: 25.0.
	self assert: spring dampingRatio equals: 4.0.
	self assert: repulsion force value equals: 700.0.
	self assert: repulsion distanceResponse class equals: CFPhysicsSoftenedInverseSquareResponse.
	self assert: repulsion distanceResponse softeningDistance value equals: 35.0.
	self assert: repulsion maximumDistance value equals: 250.0.
	self assert: behaviour velocityDamping equals: 12.0
]

{ #category : 'tests - behaviours' }
CFPhysicsCleanSlateTests >> testRemovingForceDirectedRemovesOnlyItsOwnedConstraints [
	| root first second world connection firstBehaviour secondBehaviour firstSpring secondSpring |
	root := BlElement new.
	first := BlElement new extent: 20 @ 20.
	second := BlElement new extent: 20 @ 20.
	root addChildren: { first. second }.
	world := root physics beWorld.
	connection := first -> second.
	firstBehaviour := root physics forceDirected.
	firstBehaviour
		nodes: [ { first. second } ];
		connections: [ { connection } ].
	secondBehaviour := root physics forceDirected.
	secondBehaviour
		nodes: [ { first. second } ];
		connections: [ { connection } ].
	world step.
	firstSpring := firstBehaviour springsByConnection at: connection.
	secondSpring := secondBehaviour springsByConnection at: connection.
	firstBehaviour remove.
	self deny: firstSpring isActive.
	self assert: secondSpring isActive.
	self assert: world springs equals: { secondSpring }.
	self assert: world repulsions size equals: 1
]

{ #category : 'tests - behaviours' }
CFPhysicsCleanSlateTests >> testForceDirectedRejectsEndpointsOutsideItsNodeSelection [
	| root first second world connection behaviour |
	root := BlElement new.
	first := BlElement new extent: 20 @ 20.
	second := BlElement new extent: 20 @ 20.
	root addChildren: { first. second }.
	world := root physics beWorld.
	connection := first -> second.
	behaviour := root physics forceDirected.
	behaviour
		nodes: [ { first } ];
		connections: [ { connection } ].
	self
		should: [ world step ]
		raise: Error
		withExceptionDo: [ :error |
			self assert: error messageText equals:
				'Every force-directed connection endpoint must occur in the selected nodes' ]
]


{ #category : 'examples - hierarchy collision diagnosis' }
CFPhysicsCleanSlateTests >> threeOverlappingBodiesAnchoredIndependentlyToWorldCentre [
	<gtExample>
	| owner elements world centreAnchor joints result |
	owner := BlElement new size: 500 @ 360; yourself.
	elements := (1 to: 3) collect: [ :index |
		BlElement new
			size: 60 @ 40;
			background: (Color lightBlue alpha: 0.65);
			yourself ].
	owner addChildren: elements.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world synchroniseMembership.
	elements do: [ :element | element physics position: 220 @ 160 ].
	centreAnchor := world anchorAt: 250 @ 180.
	joints := elements collect: [ :element |
		| joint |
		joint := (element physics localAnchorAt: 30 @ 20)
			distanceJointTo: centreAnchor.
		joint length: 0.0.
		joint ].
	result := world step.
	self assert: joints size equals: 3.
	self assert: world distanceJoints size equals: 3.
	self assert: result activeContacts isEmpty not.
	self assert: result constraints size >= 3.
	^ owner
]


{ #category : 'examples - body types' }
CFPhysicsCleanSlateTests >> physicsFacadeExposesTheExistingBodyType [
	<gtExample>
	| owner element world physics |
	owner := BlElement new size: 400 @ 300; yourself.
	element := BlElement new size: 20 @ 20; yourself.
	owner addChild: element.
	world := owner physics beWorld.
	world synchroniseMembership.
	physics := element physics.
	self assert: physics bodyType == physics body bodyType.
	self assert: physics bodyType class equals: CFPhysicsDynamicBodyType.
	physics beKinematic.
	self assert: physics bodyType class equals: CFPhysicsKinematicBodyType.
	physics beStatic.
	self assert: physics bodyType class equals: CFPhysicsStaticBodyType.
	^ physics
]


{ #category : 'examples - inspection' }
CFPhysicsCleanSlateTests >> physicsMagritteDescriptionsAreReadOnly [
	<gtExample>
	| owner element world physics descriptions expectedAccessors |
	owner := BlElement new size: 400 @ 300; yourself.
	element := BlElement new size: 20 @ 20; yourself.
	owner addChild: element.
	world := owner physics beWorld.
	world synchroniseMembership.
	physics := element physics.
	descriptions := physics magritteDescription children.
	expectedAccessors := #(bodyTypeName isAwake isSensor density friction restitution velocityX velocityY angularVelocity).
	self assert: descriptions size equals: expectedAccessors size.
	self assert: (descriptions collect: [ :each | each accessor selector ]) asArray equals: expectedAccessors.
	self assert: (descriptions allSatisfy: #isReadOnly).
	self assert: (descriptions collect: #priority) asArray equals: #(10 20 30 40 50 60 70 80 90).
	self assert: physics bodyTypeName equals: 'Dynamic'.
	self assert: physics velocityX equals: physics velocity x.
	self assert: physics velocityY equals: physics velocity y.
	^ descriptions
]


{ #category : 'examples - constraints' }
CFPhysicsCleanSlateTests >> constraintBuilderReusesPreparedContactObjects [
	<gtExample>
	| first second pair updater firstBatch secondBatch bodyStates builder firstConstraint secondConstraint firstPoint secondPoint |
	first := self cleanSlateBodyWithSequence: 1.
	first beStatic.
	second := self cleanSlateBodyWithSequence: 2.
	pair := CFPhysicsPair first: first second: second.
	updater := CFPhysicsContactUpdater manifoldGenerator: (CFPhysicsFixedManifoldGenerator manifold: (self cleanSlateManifoldWithFeatureIndex: 1)).
	firstBatch := updater updatePairs: { pair } fromContacts: #().
	bodyStates := IdentityDictionary new
		at: first put: (CFPhysicsBodyStepState on: first);
		at: second put: (CFPhysicsBodyStepState on: second);
		yourself.
	builder := CFPhysicsConstraintBuilder new.
	firstConstraint := (builder
		constraintsFrom: firstBatch activeContacts
		bodyStates: bodyStates) first.
	firstPoint := firstConstraint points first.
	secondBatch := updater updatePairs: { pair } fromContacts: firstBatch activeContacts.
	secondConstraint := (builder
		constraintsFrom: secondBatch activeContacts
		bodyStates: bodyStates) first.
	secondPoint := secondConstraint points first.
	self assert: secondConstraint == firstConstraint.
	self assert: secondPoint == firstPoint.
	self assert: secondConstraint contact == secondBatch activeContacts first.
	self assert: secondPoint manifoldPoint == secondBatch activeContacts first manifold contactPoints first.
	self assert: builder createdConstraintCount equals: 0.
	self assert: builder reusedConstraintCount equals: 1.
	self assert: builder createdPointCount equals: 0.
	self assert: builder reusedPointCount equals: 1.
	^ secondConstraint
]

{ #category : 'examples - island sleeping' }
CFPhysicsCleanSlateTests >> islandWakeUpdatesCapturedBodyState [
	<gtExample>
	| first second island stage bodyStates |
	first := self cleanSlateBodyWithSequence: 1.
	second := self cleanSlateBodyWithSequence: 2.
	second sleep.
	bodyStates := IdentityDictionary new
		at: first put: (CFPhysicsBodyStepState on: first);
		at: second put: (CFPhysicsBodyStepState on: second);
		yourself.
	island := CFPhysicsIsland new
		addBody: first;
		addBody: second;
		yourself.
	stage := CFPhysicsIslandSleepStage new.
	stage propagateWakeAcross: { island } bodyStates: bodyStates.
	self assert: (bodyStates at: first) isAwake.
	self assert: (bodyStates at: second) isAwake.
	self assert: second isAwake not.
	(bodyStates at: second) commit.
	self assert: second isAwake.
	^ bodyStates at: second
]



{ #category : 'examples - contacts' }
CFPhysicsCleanSlateTests >> contactUpdateStageUsesCapturedTransformsForManifolds [
	<gtExample>
	| first second result stage contacts |
	first := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self cleanSlateBodyWithSequence: 2 position: 15 @ 0 extent: 20 @ 20.
	result := CFPhysicsStepPipelineResult new
		bodies: { first. second };
		previousContacts: #();
		yourself.
	CFPhysicsBodyStateCaptureStage new executeOn: result.
	result pairs: { CFPhysicsPair first: first second: second }.
	second position: 100 @ 0.
	stage := CFPhysicsContactUpdateStage manifoldGenerator: CFPhysicsManifoldGenerator new.
	contacts := stage executeOn: result.
	self assert: contacts activeContacts size equals: 1.
	self assert: second position equals: 100 @ 0.
	^ contacts
]


{ #category : 'examples - contacts' }
CFPhysicsCleanSlateTests >> contactUpdateStageUsesCapturedSensorClassification [
	<gtExample>
	| first second result stage contacts |
	first := self cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self cleanSlateBodyWithSequence: 2 position: 15 @ 0 extent: 20 @ 20.
	first beSensor.
	result := CFPhysicsStepPipelineResult new
		bodies: { first. second };
		previousContacts: #();
		yourself.
	CFPhysicsBodyStateCaptureStage new executeOn: result.
	result pairs: { CFPhysicsPair first: first second: second }.
	first beSolid.
	stage := CFPhysicsContactUpdateStage manifoldGenerator: CFPhysicsManifoldGenerator new.
	contacts := stage executeOn: result.
	self assert: contacts activeContacts size equals: 1.
	self assert: contacts activeContacts first isSensor.
	self assert: contacts beganContacts first isSensor.
	self assert: first isSensor not.
	^ contacts
]


{ #category : 'examples - world state capture' }
CFPhysicsCleanSlateTests >> worldStateOwnsCapturedBodyStatesBeforeSolve [
	<gtExample>
	| owner element world body state solution |
	owner := BlElement new size: 200 @ 200; yourself.
	element := BlElement new
		geometry: BlRoundedRectangleGeometry new;
		size: 20 @ 20;
		yourself.
	owner addChild: element.
	world := owner physics beWorld.
	world synchroniseMembership.
	body := element physics body.
	body position: 0 @ 0.
	state := world captureStateAfterSynchronisation.
	body
		position: 100 @ 0;
		velocity: 50 @ 0.
	solution := world stepPipeline solve: state.
	self assert: state orderedBodyStates size equals: 1.
	self assert: (state bodyStates at: body) == state orderedBodyStates first.
	self assert: state orderedBodyStates first startTransform bodyOrigin equals: 10 @ 10.
	self assert: body position equals: 100 @ 0.
	^ solution
]


{ #category : 'examples - world state capture' }
CFPhysicsCleanSlateTests >> worldStateOwnsCapturedJointConfigurationBeforeSolve [
	<gtExample>
	| owner firstElement secondElement world first second joint state capturedJoint prepared solution solvedPrepared |
	owner := BlElement new size: 200 @ 200; yourself.
	firstElement := BlElement new
		geometry: BlRoundedRectangleGeometry new;
		size: 20 @ 20;
		yourself.
	secondElement := BlElement new
		geometry: BlRoundedRectangleGeometry new;
		size: 20 @ 20;
		yourself.
	owner addChildren: { firstElement. secondElement }.
	world := owner physics beWorld.
	world synchroniseMembership.
	first := firstElement physics body.
	second := secondElement physics body.
	first position: 0 @ 0.
	second position: 40 @ 0.
	joint := CFPhysicsDistanceJoint between: first and: second.
	joint
		length: 25;
		impulse: 3.0.
	world addDistanceJoint: joint.
	state := world captureStateAfterSynchronisation.
	capturedJoint := state joints first.
	joint
		length: 100;
		impulse: 0.0.
	prepared := (CFPhysicsDistanceJointConstraintBuilder new
		constraintsFrom: state joints
		bodyStates: state bodyStates
		step: state step) first.
	self assert: capturedJoint ~~ joint.
	self assert: capturedJoint solverCommitTarget == joint.
	self assert: capturedJoint length equals: 25.
	self assert: capturedJoint impulse equals: 3.0.
	self assert: prepared baseLength equals: 40.0.
	self assert: prepared impulse equals: 3.0 * state step warmStartRatio.
	self assert: joint impulse equals: 0.0.
	solution := world stepPipeline solve: state.
	solvedPrepared := solution pipelineResult jointConstraints first.
	self assert: joint impulse equals: 0.0.
	solution pipelineResult commitJointConstraints.
	self assert: joint impulse equals: solvedPrepared impulse.
	^ solution
]

{ #category : 'examples - world state capture' }
CFPhysicsCleanSlateTests >> solvingCapturedStateDoesNotRetargetCommittedPreparedConstraint [
	<gtExample>
	| world committedContact committedConstraint state solution calculationContact calculationConstraint |
	world := self worldDelegatesOneStepToTheExplicitPipeline.
	committedContact := world activeContacts first.
	committedConstraint := committedContact preparedConstraint.
	self assert: committedConstraint notNil.
	self assert: committedConstraint contact == committedContact.
	state := world captureStateAfterSynchronisation.
	solution := world stepPipeline solve: state.
	calculationContact := solution pipelineResult activeContacts first.
	calculationConstraint := calculationContact preparedConstraint.
	self assert: world activeContacts first == committedContact.
	self assert: committedContact preparedConstraint == committedConstraint.
	self assert: committedConstraint contact == committedContact.
	self assert: calculationContact ~~ committedContact.
	self assert: calculationConstraint ~~ committedConstraint.
	^ solution
]

{ #category : 'examples - world state capture' }
CFPhysicsCleanSlateTests >> solvingCapturedStateDoesNotRetargetCommittedConstraintPoint [
	<gtExample>
	| world committedContact committedConstraint committedPoint committedManifoldPoint state solution calculationContact calculationPoint |
	world := self worldDelegatesOneStepToTheExplicitPipeline.
	committedContact := world activeContacts first.
	committedConstraint := committedContact preparedConstraint.
	committedPoint := committedConstraint points first.
	committedManifoldPoint := committedContact manifold contactPoints first.
	self assert: committedPoint manifoldPoint == committedManifoldPoint.
	state := world captureStateAfterSynchronisation.
	solution := world stepPipeline solve: state.
	calculationContact := solution pipelineResult activeContacts first.
	calculationPoint := calculationContact preparedConstraint points first.
	self assert: world activeContacts first == committedContact.
	self assert: committedConstraint points first == committedPoint.
	self assert: committedPoint manifoldPoint == committedManifoldPoint.
	self assert: calculationPoint ~~ committedPoint.
	self assert: calculationPoint manifoldPoint == calculationContact manifold contactPoints first.
	^ solution
]


{ #category : 'examples - world state capture' }
CFPhysicsCleanSlateTests >> worldSolutionCarriesCommitIdentity [
	<gtExample>
	| world state solution |
	world := self worldDelegatesOneStepToTheExplicitPipeline.
	state := world captureStateAfterSynchronisation.
	solution := world stepPipeline solve: state.
	self assert: solution world == world.
	self assert: solution lifetimeGeneration equals: state lifetimeGeneration.
	self assert: solution topologyRevision equals: state topologyRevision.
	self assert: solution solveTicket equals: state solveTicket.
	^ solution
]

{ #category : 'examples - world state capture' }
CFPhysicsCleanSlateTests >> newerCaptureRejectsOlderSolution [
	<gtExample>
	| world firstState firstSolution stepBefore |
	world := self worldDelegatesOneStepToTheExplicitPipeline.
	firstState := world captureStateAfterSynchronisation.
	firstSolution := world stepPipeline solve: firstState.
	stepBefore := world stepNumber.
	world captureStateAfterSynchronisation.
	self assert: (world commit: firstSolution) isNil.
	self assert: world stepNumber equals: stepBefore.
	^ world
]

{ #category : 'examples - world state capture' }
CFPhysicsCleanSlateTests >> releasedWorldRejectsCapturedSolution [
	<gtExample>
	| world state solution |
	world := self worldDelegatesOneStepToTheExplicitPipeline.
	state := world captureStateAfterSynchronisation.
	solution := world stepPipeline solve: state.
	world release.
	self assert: (world commit: solution) isNil.
	self assert: world activeSolveTicket isNil.
	^ world
]

{ #category : 'examples - world state capture' }
CFPhysicsCleanSlateTests >> worldCapturesAtMostOneSolveAtATime [
	<gtExample>
	| world firstState secondState thirdState |
	world := self worldDelegatesOneStepToTheExplicitPipeline.
	firstState := world captureStateIfIdle.
	secondState := world captureStateIfIdle.
	self assert: firstState notNil.
	self assert: world hasSolveInFlight.
	self assert: secondState isNil.
	world abandonSolveTicket: firstState solveTicket.
	self assert: world hasSolveInFlight not.
	thirdState := world captureStateIfIdle.
	self assert: thirdState notNil.
	self assert: thirdState solveTicket > firstState solveTicket.
	^ thirdState
]

{ #category : 'examples - world state capture' }
CFPhysicsCleanSlateTests >> abandoningTheActiveSolveAllowsImmediateRecapture [
	<gtExample>
	| world firstState secondState |
	world := self worldDelegatesOneStepToTheExplicitPipeline.
	firstState := world captureStateIfIdle.
	self assert: world hasSolveInFlight.
	world abandonActiveSolve.
	self assert: world hasSolveInFlight not.
	secondState := world captureStateIfIdle.
	self assert: secondState notNil.
	self assert: secondState solveTicket ~= firstState solveTicket.
	^ secondState
]

{ #category : 'examples - world state capture' }
CFPhysicsCleanSlateTests >> abandoningAnOlderSolveDoesNotReleaseTheCurrentSolve [
	<gtExample>
	| world firstState secondState |
	world := self worldDelegatesOneStepToTheExplicitPipeline.
	firstState := world captureStateAfterSynchronisation.
	secondState := world captureStateAfterSynchronisation.
	self assert: secondState solveTicket > firstState solveTicket.
	world abandonSolveTicket: firstState solveTicket.
	self assert: world hasSolveInFlight.
	self assert: world activeSolveTicket equals: secondState solveTicket.
	world abandonSolveTicket: secondState solveTicket.
	self assert: world hasSolveInFlight not.
	^ world
]


{ #category : 'examples - background stepping' }
CFPhysicsCleanSlateTests >> backgroundStepClaimsTheSingleSolveSlotWithoutWaiting [
	<gtExample>
	| world space startedAgain |
	world := self worldDelegatesOneStepToTheExplicitPipeline.
	space := BlSpace new.
	space root addChild: world owner.
	self assert: world startBackgroundStep.
	self assert: world hasSolveInFlight.
	startedAgain := world startBackgroundStep.
	self assert: startedAgain not.
	^ world
]


{ #category : 'examples - world state capture' }
CFPhysicsCleanSlateTests >> topologyInvalidationReleasesTheSolveSlotImmediately [
	<gtExample>
	| world firstState firstSolution secondState |
	world := self worldDelegatesOneStepToTheExplicitPipeline.
	firstState := world captureStateIfIdle.
	firstSolution := world stepPipeline solve: firstState.
	self assert: world hasSolveInFlight.
	world invalidateTopology.
	self assert: world hasSolveInFlight not.
	secondState := world captureStateIfIdle.
	self assert: secondState notNil.
	self assert: secondState solveTicket ~= firstState solveTicket.
	self assert: (world commit: firstSolution) isNil.
	self assert: world activeSolveTicket equals: secondState solveTicket.
	^ secondState
]

{ #category : 'examples - background stepping' }
CFPhysicsCleanSlateTests >> detachedCaptureSolveCommitMatchesSynchronousStep [
	<gtExample>
	| synchronousOwner detachedOwner synchronousElement detachedElement synchronousWorld detachedWorld synchronousBody detachedBody synchronousResult state solution detachedResult |
	synchronousOwner := BlElement new.
	detachedOwner := BlElement new.
	synchronousElement := BlElement new size: 20 @ 20; yourself.
	detachedElement := BlElement new size: 20 @ 20; yourself.
	synchronousOwner addChild: synchronousElement.
	detachedOwner addChild: detachedElement.
	synchronousWorld := synchronousOwner physics beWorld.
	detachedWorld := detachedOwner physics beWorld.
	synchronousWorld
		gravity: 0 @ 0.1;
		synchroniseMembership.
	detachedWorld
		gravity: 0 @ 0.1;
		synchroniseMembership.
	synchronousBody := synchronousWorld bodyStateFor: synchronousElement.
	detachedBody := detachedWorld bodyStateFor: detachedElement.
	synchronousBody
		position: 12 @ 18;
		velocity: 3 @ -2.
	detachedBody
		position: 12 @ 18;
		velocity: 3 @ -2.
	synchronousResult := synchronousWorld step.
	state := detachedWorld captureStateIfIdle.
	solution := detachedWorld stepPipeline solve: state.
	detachedResult := detachedWorld commit: solution.
	self assert: detachedResult notNil.
	self
		assert: (detachedResult bodies collect: #position)
		equals: (synchronousResult bodies collect: #position).
	self
		assert: (detachedResult bodies collect: #velocity)
		equals: (synchronousResult bodies collect: #velocity).
	self assert: detachedResult activeContacts isEmpty.
	self assert: synchronousResult activeContacts isEmpty.
	self assert: detachedWorld stepNumber equals: synchronousWorld stepNumber.
	self assert: detachedWorld simulationTime equals: synchronousWorld simulationTime.
	^ detachedResult
]


{ #category : 'examples - background stepping' }
CFPhysicsCleanSlateTests >> backgroundStepResolvesItsPipelineBeforeDispatch [
	<gtExample>
	| world space backgroundStep capturedPipeline replacementPipeline |
	world := self worldDelegatesOneStepToTheExplicitPipeline.
	space := BlSpace new.
	space root addChild: world owner.
	capturedPipeline := world stepPipeline.
	backgroundStep := CFPhysicsWorldBackgroundStep on: world.
	self assert: backgroundStep start.
	self assert: backgroundStep pipeline == capturedPipeline.
	replacementPipeline := CFPhysicsStepPipeline manifoldGenerator: CFPhysicsManifoldGenerator new.
	world stepPipeline: replacementPipeline.
	self assert: backgroundStep pipeline == capturedPipeline.
	self assert: backgroundStep pipeline ~~ world stepPipeline.
	^ backgroundStep
]

{ #category : 'examples - background stepping' }
CFPhysicsCleanSlateTests >> staleSolveCannotCompeteWithRestartedWorldProgress [
	<gtExample>
	| world oldState oldSolution newState newSolution committed |
	world := self worldDelegatesOneStepToTheExplicitPipeline.
	oldState := world captureStateIfIdle.
	self assert: oldState notNil.
	oldSolution := world stepPipeline solve: oldState.
	world invalidateTopology.
	self assert: world hasSolveInFlight not.
	world abandonActiveSolve.
	newState := world captureStateIfIdle.
	self assert: newState notNil.
	newSolution := world stepPipeline solve: newState.
	self assert: (world commit: oldSolution) isNil.
	self assert: world hasSolveInFlight.
	committed := world commit: newSolution.
	self assert: committed notNil.
	self assert: world hasSolveInFlight not.
	self assert: world lastStepResult == committed.
	self assert: world stepNumber equals: newState step stepNumber.
	^ committed
]


{ #category : 'examples - background stepping' }
CFPhysicsCleanSlateTests >> detachedOwnerCannotClaimABackgroundSolveSlot [
	<gtExample>
	| world backgroundStep |
	world := self worldDelegatesOneStepToTheExplicitPipeline.
	self assert: world owner isAttachedToSceneGraph not.
	backgroundStep := CFPhysicsWorldBackgroundStep on: world.
	self assert: backgroundStep start not.
	self assert: backgroundStep state isNil.
	self assert: world hasSolveInFlight not.
	^ world
]


{ #category : 'examples - background telemetry' }
CFPhysicsCleanSlateTests >> detachedSolvePublishesTelemetryOnlyAfterCommit [
	<gtExample>
	| world state backgroundStep solution committed |
	world := self worldDelegatesOneStepToTheExplicitPipeline.
	world telemetryEnabled: true.
	world resetTelemetry.
	state := world captureStateIfIdle.
	backgroundStep := CFPhysicsWorldBackgroundStep on: world.
	backgroundStep
		instVarNamed: 'pipeline' put: world stepPipeline;
		instVarNamed: 'state' put: state;
		instVarNamed: 'telemetryEnabled' put: true;
		instVarNamed: 'telemetryContext' put: (world telemetryContextForState: state).
	solution := backgroundStep solveCapturedState.
	self assert: world telemetryRecordings isEmpty.
	committed := world commit: solution.
	self assert: committed notNil.
	self assert: world telemetryRecordings isNotEmpty.
	self assert: (world latestTelemetryRecording data includesKey: #physicsFrame).
	world telemetryEnabled: false.
	^ committed
]


{ #category : 'examples - background telemetry' }
CFPhysicsCleanSlateTests >> staleDetachedSolvePublishesNoTelemetry [
	<gtExample>
	| world state backgroundStep solution |
	world := self worldDelegatesOneStepToTheExplicitPipeline.
	world telemetryEnabled: true.
	world resetTelemetry.
	state := world captureStateIfIdle.
	backgroundStep := CFPhysicsWorldBackgroundStep on: world.
	backgroundStep
		instVarNamed: 'pipeline' put: world stepPipeline;
		instVarNamed: 'state' put: state;
		instVarNamed: 'telemetryEnabled' put: true;
		instVarNamed: 'telemetryContext' put: (world telemetryContextForState: state).
	solution := backgroundStep solveCapturedState.
	world invalidateTopology.
	self assert: (world commit: solution) isNil.
	self assert: world telemetryRecordings isEmpty.
	world telemetryEnabled: false.
	^ world
]


{ #category : 'examples - background telemetry' }
CFPhysicsCleanSlateTests >> backgroundStepCapturesTelemetryModeBeforeDispatch [
	<gtExample>
	| world space backgroundStep |
	world := self worldDelegatesOneStepToTheExplicitPipeline.
	space := BlSpace new.
	space root addChild: world owner.
	world telemetryEnabled: true.
	backgroundStep := CFPhysicsWorldBackgroundStep on: world.
	self assert: backgroundStep start.
	self assert: backgroundStep telemetryEnabled.
	world telemetryEnabled: false.
	self assert: backgroundStep telemetryEnabled.
	^ backgroundStep
]

{ #category : 'examples - background telemetry' }
CFPhysicsCleanSlateTests >> backgroundStepDefaultsToTheUnmeasuredSolver [
	<gtExample>
	| world space backgroundStep |
	world := self worldDelegatesOneStepToTheExplicitPipeline.
	space := BlSpace new.
	space root addChild: world owner.
	self assert: world telemetryEnabled not.
	backgroundStep := CFPhysicsWorldBackgroundStep on: world.
	self assert: backgroundStep start.
	self assert: backgroundStep telemetryEnabled not.
	^ backgroundStep
]

{ #category : 'examples - coordinate contract' }
CFPhysicsCleanSlateTests >> bodyLocalPointRoundTripsThroughWorld [
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

{ #category : 'examples - coordinate contract' }
CFPhysicsCleanSlateTests >> bodyLocalVectorRoundTripsWithoutTranslation [
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

{ #category : 'examples - coordinate contract' }
CFPhysicsCleanSlateTests >> bodyAndCapturedStateUseTheSameCoordinateContract [
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

{ #category : 'examples - coordinate contract' }
CFPhysicsCleanSlateTests >> elementLocalAndBodyLocalPointsRoundTrip [
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

{ #category : 'examples - coordinate contract' }
CFPhysicsCleanSlateTests >> normalisedPointsResolveIntoTheBodyLocalFrame [
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


{ #category : 'examples - coordinate contract' }
CFPhysicsCleanSlateTests >> equivalentLocalAndNormalisedAnchorsShareTheCoordinateContract [
	<gtExample>
	| body localAnchor normalisedAnchor centreAnchor |
	body := self cleanSlateBodyWithSequence: 1 position: 100 @ 50 extent: 40 @ 20.
	body rotation: Float pi / 3.0.
	localAnchor := CFPhysicsLocalAnchor on: body at: 40 @ 10.
	normalisedAnchor := CFPhysicsNormalisedAnchor on: body at: 1 @ 0.5.
	centreAnchor := CFPhysicsBodyCentreAnchor on: body.
	self assert: (localAnchor worldPoint closeTo: normalisedAnchor worldPoint).
	self assert: (centreAnchor worldPoint closeTo: body worldBodyOrigin).
	^ { localAnchor. normalisedAnchor. centreAnchor }
]

{ #category : 'examples - coordinate contract' }
CFPhysicsCleanSlateTests >> bodyStoresItsWorldOriginWithoutChangingTheElementPositionContract [
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


{ #category : 'examples - coordinates' }
CFPhysicsCleanSlateTests >> bodyStepStateCapturesBodyOriginWithoutChangingTransformContract [
	<gtExample>
	| body state |
	body := self cleanSlateBodyWithSequence: 1 position: 100 @ 50 extent: 40 @ 20.
	state := CFPhysicsBodyStepState on: body.
	self assert: state startBodyOrigin equals: 120 @ 60.
	self assert: state currentBodyOrigin equals: 120 @ 60.
	self assert: state currentTransform bodyOrigin equals: 120 @ 60.
	state translateBy: 10 @ 5.
	self assert: state currentBodyOrigin equals: 130 @ 65.
	self assert: state currentTransform bodyOrigin equals: 130 @ 65.
	^ state
]




{ #category : 'tests - pull interaction' }
CFPhysicsCleanSlateTests >> testPullInteractionCanEndAfterItsWorldIsReleased [
	| root child world body handler constraint |
	root := BlElement new.
	child := BlElement new extent: 20 @ 20.
	root addChild: child.
	world := root physics beWorld.
	world synchroniseMembership.
	body := child physics body.
	handler := child physics pointerJointHandler.
	constraint := CFPhysicsMouseJoint body: body target: 10 @ 10.
	world addMouseJoint: constraint.
	handler instVarNamed: 'mouseJoint' put: constraint.
	root physics ceaseBeingWorld.
	self assert: body world isNil.
	self deny: constraint isActive.
	handler endFrom: nil.
	self assert: handler mouseJoint isNil
]


{ #category : 'tests - pull interaction' }
CFPhysicsCleanSlateTests >> testPullInteractionPreservesBodyVelocityWhenReleased [
	| root child world body handler joint |
	root := BlElement new.
	child := BlElement new extent: 20 @ 20.
	root addChild: child.
	world := root physics beWorld.
	world synchroniseMembership.
	body := child physics body.
	body
		velocity: 800 @ -200;
		angularVelocity: 3.5.
	handler := child physics pointerJointHandler.
	joint := CFPhysicsMouseJoint body: body target: 10 @ 10.
	world addMouseJoint: joint.
	handler instVarNamed: 'mouseJoint' put: joint.
	handler finishMouseJoint.
	self assert: body velocity equals: 800 @ -200.
	self assert: body angularVelocity equals: 3.5.
	self assert: world mouseJoints isEmpty
]


{ #category : 'examples - motor joints' }
CFPhysicsCleanSlateTests >> motorJointPreservesConfiguredRelativeTransform [
	<gtExample>
	| owner firstElement secondElement world first second joint |
	owner := BlElement new size: 200 @ 200; yourself.
	firstElement := BlElement new size: 20 @ 20; yourself.
	secondElement := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { firstElement. secondElement }.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world synchroniseMembership.
	first := firstElement physics body.
	second := secondElement physics body.
	first position: 0 @ 0.
	first beStatic.
	second position: 40 @ 0.
	joint := CFPhysicsMotorJoint between: first and: second.
	joint maximumForce: 100000.0; maximumTorque: 100000.0.
	world addMotorJoint: joint.
	second position: 80 @ 0.
	10 timesRepeat: [ world step ].
	self assert: second position x < 80.
	^ joint
]

{ #category : 'examples - motor joints' }
CFPhysicsCleanSlateTests >> motorJointPreservesRelativeTransformBetweenDynamicBodies [
	<gtExample>
	| owner firstElement secondElement world first second joint initialCentre |
	owner := BlElement new size: 200 @ 200; yourself.
	firstElement := BlElement new size: 20 @ 20; yourself.
	secondElement := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { firstElement. secondElement }.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world synchroniseMembership.
	first := firstElement physics body.
	second := secondElement physics body.
	first position: 0 @ 0.
	second position: 40 @ 0.
	initialCentre := (first position + second position) / 2.0.
	joint := CFPhysicsMotorJoint between: first and: second.
	joint maximumForce: 100000.0; maximumTorque: 100000.0.
	world addMotorJoint: joint.
	second position: 80 @ 0.
	10 timesRepeat: [ world step ].
	self assert: (second position - first position) x < 80.0.
	self assert: (second position - first position) x > 40.0.
	self assert: (((first position + second position) / 2.0) x closeTo: initialCentre x + 20.0).
	^ joint
]

{ #category : 'examples - motor joints' }
CFPhysicsCleanSlateTests >> motorJointLinearImpulseIsCappedBySubstepForce [
	<gtExample>
	| owner firstElement secondElement world first second joint state solution prepared expectedMaximum |
	owner := BlElement new size: 200 @ 200; yourself.
	firstElement := BlElement new size: 20 @ 20; yourself.
	secondElement := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { firstElement. secondElement }.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world synchroniseMembership.
	first := firstElement physics body.
	second := secondElement physics body.
	first position: 0 @ 0.
	first beStatic.
	second position: 40 @ 0.
	joint := CFPhysicsMotorJoint between: first and: second.
	joint maximumForce: 100.0; maximumTorque: 0.0.
	world addMotorJoint: joint.
	second position: 80 @ 0.
	state := world captureStateAfterSynchronisation.
	solution := world stepPipeline solve: state.
	prepared := solution pipelineResult jointConstraints
		detect: [ :each | each class == CFPhysicsPreparedMotorJoint ].
	expectedMaximum := state step substepTime * joint maximumForce.
	self assert: (prepared maximumLinearImpulse closeTo: expectedMaximum).
	self assert: prepared linearImpulse r <= expectedMaximum.
	self assert: prepared linearImpulse r > 0.0.
	^ prepared
]

{ #category : 'examples - motor joints' }
CFPhysicsCleanSlateTests >> motorJointLinearOffsetMatchesBox2DWithRotatedBodyA [
	<gtExample>
	| owner firstElement secondElement world first second joint state prepared |
	owner := BlElement new size: 200 @ 200; yourself.
	firstElement := BlElement new size: 20 @ 20; yourself.
	secondElement := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { firstElement. secondElement }.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world synchroniseMembership.
	first := firstElement physics body.
	second := secondElement physics body.
	first position: 0 @ 0; rotation: Float pi / 2.0.
	second position: 40 @ 0.
	joint := CFPhysicsMotorJoint between: first and: second.
	world addMotorJoint: joint.
	state := world captureStateAfterSynchronisation.
	prepared := (CFPhysicsMotorJointConstraintBuilder new
		constraintsFrom: state joints
		bodyStates: state bodyStates
		step: state step) first.
	self assert: joint linearOffset equals: 40 @ 0.
	self assert: (prepared baseLinearSeparation closeTo: 0 @ 0).
	^ prepared
]



{ #category : 'examples - prismatic joints' }
CFPhysicsCleanSlateTests >> prismaticJointMotorDrivesAlongItsLocalAxis [
	<gtExample>
	| owner element world joint |
	owner := BlElement new size: 400 @ 300; yourself.
	element := BlElement new size: 20 @ 20; yourself.
	owner addChild: element.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world synchroniseMembership.
	joint := (element physics localAnchorAt: 10 @ 10)
		prismaticJointTo: (world anchorAt: 10 @ 10)
		along: 1 @ 0.
	joint motorEnabled: true; motorSpeed: 100.0; maximumMotorForce: 100000.0.
	world step.
	self assert: element physics velocity x > 0.0.
	self assert: (element physics velocity y closeTo: 0.0).
	^ joint
]

{ #category : 'examples - prismatic joints' }
CFPhysicsCleanSlateTests >> prismaticJointSpringTargetsTranslation [
	<gtExample>
	| owner element world joint initialError |
	owner := BlElement new size: 400 @ 300; yourself.
	element := BlElement new size: 20 @ 20; yourself.
	owner addChild: element.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world synchroniseMembership.
	joint := (element physics localAnchorAt: 10 @ 10)
		prismaticJointTo: (world anchorAt: 10 @ 10)
		along: 1 @ 0.
	joint springEnabled: true; targetTranslation: 20.0; hertz: 5.0; dampingRatio: 1.0.
	initialError := 20.0.
	10 timesRepeat: [ world step ].
	self assert: (20.0 - element physics position x) abs < initialError.
	^ joint
]

{ #category : 'examples - prismatic joints' }
CFPhysicsCleanSlateTests >> prismaticJointAxisRotatesWithBodyA [
	<gtExample>
	| owner firstElement secondElement world joint state prepared |
	owner := BlElement new size: 400 @ 300; yourself.
	firstElement := BlElement new size: 20 @ 20; yourself.
	secondElement := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { firstElement. secondElement }.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world synchroniseMembership.
	firstElement physics rotation: Float pi / 2.0.
	joint := (firstElement physics localAnchorAt: 10 @ 10)
		prismaticJointTo: (secondElement physics localAnchorAt: 10 @ 10)
		along: 0 @ 1.
	state := world captureStateAfterSynchronisation.
	prepared := (CFPhysicsPrismaticJointConstraintBuilder new constraintsFrom: state joints bodyStates: state bodyStates step: state step) first.
	self assert: (joint localAxisA closeTo: 1 @ 0).
	self assert: (prepared axis closeTo: 0 @ 1).
	^ prepared
]


{ #category : 'examples - contact solver' }
CFPhysicsCleanSlateTests >> contactPushSpeedDefaultsAndPropagatesIntoStep [
	<gtExample>
	| world step |
	world := CFPhysicsWorld new.
	self assert: (world lengthUnitsPerMetre closeTo: 100.0).
	self assert: (world maximumContactPushSpeed closeTo: 3.0).
	step := world newStep.
	self assert: (step maximumContactPushSpeed closeTo: 300.0).
	world
		lengthUnitsPerMetre: 200.0;
		maximumContactPushSpeed: 7.5.
	step := world newStep.
	self assert: (world maximumContactPushSpeed closeTo: 7.5).
	self assert: (step maximumContactPushSpeed closeTo: 1500.0).
	^ step
]

{ #category : 'examples - contact solver' }
CFPhysicsCleanSlateTests >> worldScaleConvertsMutableConfigurationWhenStateIsCaptured [
	<gtExample>
	| owner world state |
	owner := BlElement new size: 200 @ 200; yourself.
	world := owner physics beWorld.
	world
		lengthUnitsPerMetre: 200.0;
		gravity: 0 @ 5.0;
		restitutionThreshold: 2.0;
		hitEventThreshold: 1.5.
	world synchroniseMembership.
	state := world captureStateAfterSynchronisation.
	self assert: (world gravity closeTo: 0 @ 5.0).
	self assert: (world restitutionThreshold closeTo: 2.0).
	self assert: (world hitEventThreshold closeTo: 1.5).
	self assert: (state gravity closeTo: 0 @ 1000.0).
	self assert: (state restitutionThreshold closeTo: 400.0).
	self assert: (state step hitEventThreshold closeTo: 300.0).
	^ state
]

{ #category : 'examples - constraints' }
CFPhysicsCleanSlateTests >> contactRollingResistanceDefaultsToZero [
	<gtExample>
	| body |
	body := self cleanSlateBodyWithSequence: 1.
	self assert: body rollingResistance equals: 0.0.
	^ body
]

{ #category : 'examples - constraints' }
CFPhysicsCleanSlateTests >> constraintBuilderPreparesRollingResistance [
	<gtExample>
	| first second pair manifold bodyStates constraint |
	first := self cleanSlateBodyWithSequence: 1.
	first element geometry: BlCircleGeometry new; size: 20 @ 20.
	first rollingResistance: 0.2.
	second := self cleanSlateBodyWithSequence: 2.
	second element geometry: BlCircleGeometry new; size: 40 @ 40.
	second rollingResistance: 0.5.
	pair := CFPhysicsPair first: first second: second.
	manifold := self cleanSlateManifoldWithFeatureIndex: 1.
	bodyStates := IdentityDictionary new
		at: first put: (CFPhysicsBodyStepState on: first);
		at: second put: (CFPhysicsBodyStepState on: second);
		yourself.
	constraint := (CFPhysicsConstraintBuilder new
		constraintsFrom: { CFPhysicsContact pair: pair manifold: manifold }
		bodyStates: bodyStates) first.
	self assert: (constraint rollingResistance closeTo: 10.0).
	self assert: constraint rollingMass >= 0.0.
	^ constraint
]

{ #category : 'examples - constraints' }
CFPhysicsCleanSlateTests >> preparedConstraintWritesRollingImpulseBack [
	<gtExample>
	| constraint |
	constraint := self constraintBuilderPreparesSolverData.
	constraint rollingImpulse: 2.5.
	constraint writeImpulsesBack.
	self assert: (constraint contact manifold rollingImpulse closeTo: 2.5).
	^ constraint
]


{ #category : 'examples - post solve' }
CFPhysicsCleanSlateTests >> hitEventsUseConfirmedImpulseRatherThanWarmStartedImpulse [
	<gtExample>
	| constraint point result collector |
	point := CFPhysicsConstraintPoint new
		featureId: 1;
		manifoldPoint: (CFPhysicsManifoldPoint new position: 3 @ 4; yourself);
		relativeNormalVelocity: -5.0;
		normalImpulse: 2.0;
		tangentImpulse: 0.0;
		totalNormalImpulse: 0.0;
		yourself.
	constraint := CFPhysicsPreparedConstraint new
		contact: Object new;
		normal: 0 @ 1;
		points: { point };
		yourself.
	collector := CFPhysicsPostSolveCollector new.
	collector hitEventThreshold: 0.0.
	result := collector collectFrom: { constraint }.
	self assert: result hitEvents isEmpty.
	^ result
]

{ #category : 'examples - post solve' }
CFPhysicsCleanSlateTests >> hitEventsChooseFastestPointPerContact [
	<gtExample>
	| constraint firstPoint secondPoint result collector |
	firstPoint := CFPhysicsConstraintPoint new
		featureId: 1;
		manifoldPoint: (CFPhysicsManifoldPoint new position: 1 @ 2; yourself);
		relativeNormalVelocity: -3.0;
		normalImpulse: 1.0;
		tangentImpulse: 0.0;
		totalNormalImpulse: 1.0;
		yourself.
	secondPoint := CFPhysicsConstraintPoint new
		featureId: 2;
		manifoldPoint: (CFPhysicsManifoldPoint new position: 5 @ 6; yourself);
		relativeNormalVelocity: -7.0;
		normalImpulse: 2.0;
		tangentImpulse: 0.0;
		totalNormalImpulse: 2.0;
		yourself.
	constraint := CFPhysicsPreparedConstraint new
		contact: Object new;
		normal: 0 @ 1;
		points: { firstPoint. secondPoint };
		yourself.
	collector := CFPhysicsPostSolveCollector new.
	collector hitEventThreshold: 0.0.
	result := collector collectFrom: { constraint }.
	self assert: result hitEvents size equals: 1.
	self assert: result hitEvents first featureId equals: 2.
	self assert: (result hitEvents first approachSpeed closeTo: 7.0).
	^ result
]


{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> continuousCollisionUsesBox2DBodyTypePolicy [
	<gtExample>
	| dynamic static kinematic dynamicState staticState kinematicState |
	dynamic := self cleanSlateBodyWithSequence: 1.
	static := self cleanSlateBodyWithSequence: 2.
	static beStatic.
	kinematic := self cleanSlateBodyWithSequence: 3.
	kinematic beKinematic.
	dynamicState := CFPhysicsBodyStepState on: dynamic.
	staticState := CFPhysicsBodyStepState on: static.
	kinematicState := CFPhysicsBodyStepState on: kinematic.
	self assert: (dynamicState requiresContinuousCollisionAgainst: staticState).
	self assert: (dynamicState requiresContinuousCollisionAgainst: kinematicState) not.
	^ dynamicState
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> bulletContinuousCollisionIncludesMovableNonBulletBodies [
	<gtExample>
	| bullet dynamic otherBullet bulletState dynamicState otherBulletState |
	bullet := self cleanSlateBodyWithSequence: 1.
	bullet beBullet.
	dynamic := self cleanSlateBodyWithSequence: 2.
	otherBullet := self cleanSlateBodyWithSequence: 3.
	otherBullet beBullet.
	bulletState := CFPhysicsBodyStepState on: bullet.
	dynamicState := CFPhysicsBodyStepState on: dynamic.
	otherBulletState := CFPhysicsBodyStepState on: otherBullet.
	self assert: (bulletState requiresContinuousCollisionAgainst: dynamicState).
	self assert: (bulletState requiresContinuousCollisionAgainst: otherBulletState) not.
	^ bulletState
]


{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> sweepInterpolatesSolvedBodyOriginAndRotation [
	<gtExample>
	| sweep midpoint |
	sweep := CFPhysicsSweep
		from: (CFPhysicsTransform bodyOrigin: 10 @ 20 rotation: 3.0)
		to: (CFPhysicsTransform bodyOrigin: 30 @ 60 rotation: 4.0).
	midpoint := sweep transformAt: 0.5.
	self assert: (midpoint bodyOrigin closeTo: 20 @ 40).
	self assert: (midpoint rotation closeTo: 3.5).
	^ midpoint
]

{ #category : 'examples - continuous collision' }
CFPhysicsCleanSlateTests >> continuousClampUsesTheSolvedSweepFraction [
	<gtExample>
	| body state |
	body := self cleanSlateBodyWithSequence: 1.
	state := CFPhysicsBodyStepState on: body.
	state translateBy: 40 @ 20.
	state angularVelocity: 2.0.
	state integratePositionBy: 1.0.
	state clampSolvedTransformToFraction: 0.25.
	self assert: (state currentBodyOrigin closeTo: body worldBodyOrigin + (10 @ 5)).
	self assert: (state currentTransform rotation closeTo: body rotation + 0.5).
	^ state
]


{ #category : 'examples - broadphase' }
CFPhysicsCleanSlateTests >> aabbExpansionPreservesCentreAndAddsMargin [
	<gtExample>
	| bounds expanded |
	bounds := CFPhysicsAABB position: 10 @ 20 extent: 30 @ 40.
	expanded := bounds expandedBy: 5.0.
	self assert: expanded minimum equals: 5 @ 15.
	self assert: expanded maximum equals: 45 @ 65.
	self assert: expanded centre equals: bounds centre.
	^ expanded
]

{ #category : 'examples - broadphase' }
CFPhysicsCleanSlateTests >> worldScalesBroadphaseDistancesIntoEachStep [
	<gtExample>
	| owner world firstStep secondStep |
	owner := BlElement new size: 100 @ 100.
	world := owner physics beWorld.
	firstStep := world newStep.
	self assert: (firstStep speculativeDistance closeTo: 2.0).
	self assert: (firstStep broadphaseAABBMargin closeTo: 5.0).
	world lengthUnitsPerMetre: 200.0.
	secondStep := world newStep.
	self assert: (secondStep speculativeDistance closeTo: 4.0).
	self assert: (secondStep broadphaseAABBMargin closeTo: 10.0).
	^ secondStep
]

{ #category : 'examples - broadphase' }
CFPhysicsCleanSlateTests >> dynamicTreeQueriesOnlyOverlappingProxies [
	<gtExample>
	| tree first second third result |
	tree := CFPhysicsDynamicTree new.
	first := tree createProxyFor: #first aabb: (CFPhysicsAABB position: 0 @ 0 extent: 10 @ 10).
	second := tree createProxyFor: #second aabb: (CFPhysicsAABB position: 8 @ 8 extent: 10 @ 10).
	third := tree createProxyFor: #third aabb: (CFPhysicsAABB position: 100 @ 100 extent: 10 @ 10).
	result := tree query: (CFPhysicsAABB position: 5 @ 5 extent: 10 @ 10).
	self assert: result asArray equals: #(first second).
	self assert: tree proxyCount equals: 3.
	self assert: first isLeaf.
	self assert: second isLeaf.
	self assert: third isLeaf.
	^ tree
]

{ #category : 'examples - broadphase' }
CFPhysicsCleanSlateTests >> dynamicTreeMovesProxyOnlyOutsideItsFatBounds [
	<gtExample>
	| tree proxy moved |
	tree := CFPhysicsDynamicTree new.
	proxy := tree createProxyFor: #body aabb: (CFPhysicsAABB position: 0 @ 0 extent: 20 @ 20).
	moved := tree moveProxy: proxy to: (CFPhysicsAABB position: 5 @ 5 extent: 5 @ 5).
	self assert: moved not.
	moved := tree moveProxy: proxy to: (CFPhysicsAABB position: 30 @ 30 extent: 5 @ 5).
	self assert: moved.
	self assert: (tree query: (CFPhysicsAABB position: 30 @ 30 extent: 5 @ 5)) asArray equals: #(body).
	^ tree
]

{ #category : 'examples - broadphase' }
CFPhysicsCleanSlateTests >> dynamicTreeReusesReleasedNodes [
	<gtExample>
	| tree first second pooledBefore third |
	tree := CFPhysicsDynamicTree new.
	first := tree createProxyFor: #first aabb: (CFPhysicsAABB position: 0 @ 0 extent: 10 @ 10).
	second := tree createProxyFor: #second aabb: (CFPhysicsAABB position: 20 @ 0 extent: 10 @ 10).
	tree destroyProxy: second.
	pooledBefore := tree pooledNodeCount.
	third := tree createProxyFor: #third aabb: (CFPhysicsAABB position: 40 @ 0 extent: 10 @ 10).
	self assert: pooledBefore > 0.
	self assert: tree proxyCount equals: 2.
	self assert: third identifier equals: second identifier.
	self assert: first isLeaf.
	^ tree
]

{ #category : 'examples - broadphase' }
CFPhysicsCleanSlateTests >> dynamicTreeMaintainsBox2DStructuralInvariants [
	<gtExample>
	| tree proxies |
	tree := CFPhysicsDynamicTree new.
	proxies := (1 to: 24) collect: [ :index |
		tree
			createProxyFor: index
			aabb: (CFPhysicsAABB
				position: (index * 7) @ ((index \\ 5) * 11)
				extent: 12 @ 9) ].
	self assert: tree validate.
	proxies withIndexDo: [ :proxy :index |
		index even ifTrue: [ tree destroyProxy: proxy ] ].
	self assert: tree validate.
	self assert: tree proxyCount equals: 12.
	^ tree
]


{ #category : 'examples - broadphase' }
CFPhysicsCleanSlateTests >> dynamicTreeQueryCanTerminateWithoutCollectingResults [
	<gtExample>
	| tree visited completed |
	tree := CFPhysicsDynamicTree new.
	tree createProxyFor: #first aabb: (CFPhysicsAABB position: 0 @ 0 extent: 10 @ 10).
	tree createProxyFor: #second aabb: (CFPhysicsAABB position: 5 @ 5 extent: 10 @ 10).
	visited := 0.
	completed := tree
		query: (CFPhysicsAABB position: 0 @ 0 extent: 20 @ 20)
		do: [ :each |
			visited := visited + 1.
			false ].
	self assert: completed not.
	self assert: visited equals: 1.
	self assert: tree queryLeafVisitCount equals: 1.
	^ tree
]

{ #category : 'examples - broadphase' }
CFPhysicsCleanSlateTests >> dynamicTreeReportsBox2DAreaRatio [
	<gtExample>
	| tree |
	tree := CFPhysicsDynamicTree new.
	1 to: 8 do: [ :index |
		tree
			createProxyFor: index
			aabb: (CFPhysicsAABB position: (index * 10) @ 0 extent: 8 @ 8) ].
	self assert: tree areaRatio >= 0.0.
	self assert: tree validate.
	^ tree
]

{ #category : 'examples - broadphase' }
CFPhysicsCleanSlateTests >> dynamicTreeRayCastClipsAndVisitsNearestProxyFirst [
	<gtExample>
	| tree visited completed |
	tree := CFPhysicsDynamicTree new.
	tree createProxyFor: #near aabb: (CFPhysicsAABB position: 10 @ -2 extent: 4 @ 4).
	tree createProxyFor: #far aabb: (CFPhysicsAABB position: 30 @ -2 extent: 4 @ 4).
	tree createProxyFor: #outside aabb: (CFPhysicsAABB position: 10 @ 20 extent: 4 @ 4).
	visited := OrderedCollection new.
	completed := tree
		rayCastFrom: 0 @ 0
		translation: 50 @ 0
		maxFraction: 1.0
		do: [ :each :currentMaximum |
			visited add: each.
			each = #near ifTrue: [ 0.3 ] ifFalse: [ currentMaximum ] ].
	self assert: completed.
	self assert: visited asArray equals: #(near).
	self assert: tree queryLeafVisitCount equals: 1.
	^ tree
]

{ #category : 'examples - broadphase' }
CFPhysicsCleanSlateTests >> dynamicTreeRayCastCallbackCanTerminateTraversal [
	<gtExample>
	| tree visited completed |
	tree := CFPhysicsDynamicTree new.
	tree createProxyFor: #body aabb: (CFPhysicsAABB position: 10 @ -2 extent: 4 @ 4).
	visited := 0.
	completed := tree
		rayCastFrom: 0 @ 0
		translation: 50 @ 0
		maxFraction: 1.0
		do: [ :each :currentMaximum |
			visited := visited + 1.
			0.0 ].
	self assert: completed not.
	self assert: visited equals: 1.
	^ tree
]
