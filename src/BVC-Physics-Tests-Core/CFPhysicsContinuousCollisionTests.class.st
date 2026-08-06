Class {
	#name : 'CFPhysicsContinuousCollisionTests',
	#superclass : 'CFPhysicsTestCase',
	#category : 'BVC-Physics-Tests-Core',
	#package : 'BVC-Physics-Tests-Core'
}

{ #category : 'tests - continuous collision' }
CFPhysicsContinuousCollisionTests >> testDistanceProxySeparatesRoundedShapeCoreFromRadius [
	<gtExample>
	| state proxy |
	state := CFPhysicsShapeState on: (BlElement new
		size: 20 @ 10;
		geometry: (BlRoundedRectangleGeometry cornerRadius: 3);
		yourself).
	proxy := CFPhysicsDistanceProxy fromShapeState: state.
	self assert: proxy points equals: { -7 @ -2. 7 @ -2. 7 @ 2. -7 @ 2 }.
	self assert: (proxy radius closeTo: 3.0).
	^ proxy
]
{ #category : 'tests - continuous collision' }
CFPhysicsContinuousCollisionTests >> testDistanceProxyUsesBodyCentredCircleCore [
	<gtExample>
	| state proxy |
	state := CFPhysicsShapeState on: (BlElement new
		size: 20 @ 20;
		geometry: BlCircleGeometry new;
		yourself).
	proxy := CFPhysicsDistanceProxy fromShapeState: state.
	self assert: proxy points equals: { 0 @ 0 }.
	self assert: (proxy radius closeTo: 10.0).
	^ proxy
]
{ #category : 'tests - continuous collision' }
CFPhysicsContinuousCollisionTests >> testAabbMergesBothBounds [
	<gtExample>
	| first second merged |
	first := CFPhysicsAABB position: 10 @ 20 extent: 30 @ 40.
	second := CFPhysicsAABB position: -5 @ 35 extent: 25 @ 50.
	merged := first mergedWith: second.
	self assert: merged minimum equals: -5 @ 20.
	self assert: merged maximum equals: 40 @ 85.
	^ merged
]
{ #category : 'tests - continuous collision' }
CFPhysicsContinuousCollisionTests >> testBodySweptAABBCoversTranslation [
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
{ #category : 'tests - continuous collision' }
CFPhysicsContinuousCollisionTests >> testBodySweptAABBCoversRotationBetweenTransforms [
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
{ #category : 'tests - continuous collision' }
CFPhysicsContinuousCollisionTests >> testPairFinderReturnsCandidateAcrossSweptPath [
	<gtExample>
	| moving obstacle pairs |
	moving := self newBodyWithSequence: 1 position: 0 @ 0 extent: 10 @ 10.
	moving
		beginStep;
		addVelocity: 100 @ 0;
		advanceBy: 1.0 gravity: 0 @ 0.
	obstacle := self newBodyWithSequence: 2 position: 50 @ 0 extent: 10 @ 10.
	obstacle beStatic.

	self assert: (moving aabb overlaps: obstacle aabb) not.
	self assert: (moving sweptAABB overlaps: obstacle sweptAABB).
	pairs := CFPhysicsPairFinder new pairsAmong: { obstacle. moving }.
	self assert: pairs size equals: 1.
	self assert: pairs first firstBody equals: moving.
	self assert: pairs first secondBody equals: obstacle.
	^ pairs
]
{ #category : 'tests - continuous collision' }
CFPhysicsContinuousCollisionTests >> testPairFinderRejectsSeparatedSweptPaths [
	<gtExample>
	| moving obstacle pairs |
	moving := self newBodyWithSequence: 1 position: 0 @ 0 extent: 10 @ 10.
	moving
		beginStep;
		addVelocity: 100 @ 0;
		advanceBy: 1.0 gravity: 0 @ 0.
	obstacle := self newBodyWithSequence: 2 position: 50 @ 30 extent: 10 @ 10.
	obstacle beStatic.

	self assert: (moving sweptAABB overlaps: obstacle sweptAABB) not.
	pairs := CFPhysicsPairFinder new pairsAmong: { moving. obstacle }.
	self assert: pairs isEmpty.
	^ pairs
]
{ #category : 'tests - continuous collision' }
CFPhysicsContinuousCollisionTests >> testBodySweepCapturesStepTransforms [
	<gtExample>
	| body sweep |
	body := self newBodyWithSequence: 1 position: 10 @ 20 extent: 10 @ 10.
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
{ #category : 'tests - continuous collision' }
CFPhysicsContinuousCollisionTests >> testBeginningStepProducesStationarySweep [
	<gtExample>
	| body sweep |
	body := self newBodyWithSequence: 1 position: 10 @ 20 extent: 10 @ 10.
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
{ #category : 'tests - continuous collision' }
CFPhysicsContinuousCollisionTests >> testSettingTransformResetsSweepEndpoints [
	<gtExample>
	| body sweep |
	body := self newBodyWithSequence: 1 position: 0 @ 0 extent: 10 @ 10.
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
{ #category : 'tests - continuous collision' }
CFPhysicsContinuousCollisionTests >> testSweepInterpolationPreservesIntegratedAngularDisplacement [
	<gtExample>
	| sweep transform |
	sweep := CFPhysicsSweep
		from: (CFPhysicsTransform bodyOrigin: 0 @ 0 rotation: 0.0)
		to: (CFPhysicsTransform bodyOrigin: 0 @ 0 rotation: Float pi * 3.0).
	transform := sweep transformAt: 0.5.
	self assert: (transform rotation closeTo: Float pi * 1.5).
	^ transform
]
{ #category : 'tests - continuous collision' }
CFPhysicsContinuousCollisionTests >> testSweepInterpolatesTransform [
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
{ #category : 'tests - continuous collision' }
CFPhysicsContinuousCollisionTests >> testSweptAABBDelegatesToShapeState [
	<gtExample>
	| body bodyBounds sweepBounds |
	body := self newBodyWithSequence: 1 position: 0 @ 0 extent: 10 @ 10.
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
{ #category : 'tests - continuous collision' }
CFPhysicsContinuousCollisionTests >> testStepStatePredictsLinearMovement [
	<gtExample>
	| body state transform |
	body := self newBodyWithSequence: 1 position: 10 @ 20 extent: 10 @ 10.
	body velocity: 12 @ -4.
	state := CFPhysicsBodyStepState on: body.
	transform := state predictedTransformAfter: 0.5.
	self assert: transform bodyOrigin equals: 21 @ 23.
	self assert: transform rotation equals: 0.
	self assert: body position equals: 10 @ 20.
	^ transform
]
{ #category : 'tests - continuous collision' }
CFPhysicsContinuousCollisionTests >> testStepStatePredictsAngularMovement [
	<gtExample>
	| body state transform |
	body := self newBodyWithSequence: 1 position: 10 @ 20 extent: 10 @ 10.
	body angularVelocity: Float pi.
	state := CFPhysicsBodyStepState on: body.
	transform := state predictedTransformAfter: 0.5.
	self assert: transform bodyOrigin equals: 15 @ 25.
	self assert: (transform rotation closeTo: Float pi / 2.0).
	self assert: body rotation equals: 0.
	^ transform
]
{ #category : 'tests - continuous collision' }
CFPhysicsContinuousCollisionTests >> testStepStatePredictsCombinedMovementSweep [
	<gtExample>
	| body state sweep |
	body := self newBodyWithSequence: 1 position: 10 @ 20 extent: 10 @ 10.
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
{ #category : 'tests - continuous collision' }
CFPhysicsContinuousCollisionTests >> testStepStateUsesCapturedBodyValues [
	<gtExample>
	| body state transform |
	body := self newBodyWithSequence: 1 position: 10 @ 20 extent: 10 @ 10.
	body velocity: 12 @ -4.
	state := CFPhysicsBodyStepState on: body.
	body
		position: 100 @ 200;
		velocity: 50 @ 50.
	transform := state predictedTransformAfter: 0.5.
	self assert: transform bodyOrigin equals: 21 @ 23.
	^ transform
]
{ #category : 'tests - continuous collision' }
CFPhysicsContinuousCollisionTests >> testStaticStepStatePredictsStationarySweep [
	<gtExample>
	| body state sweep |
	body := self newBodyWithSequence: 1 position: 10 @ 20 extent: 10 @ 10.
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
{ #category : 'tests - continuous collision' }
CFPhysicsContinuousCollisionTests >> testSleepingStepStatePredictsStationarySweep [
	<gtExample>
	| body state sweep |
	body := self newBodyWithSequence: 1 position: 10 @ 20 extent: 10 @ 10.
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
{ #category : 'tests - continuous collision' }
CFPhysicsContinuousCollisionTests >> testZeroDurationPredictionProducesStationarySweep [
	<gtExample>
	| body state sweep |
	body := self newBodyWithSequence: 1 position: 10 @ 20 extent: 10 @ 10.
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
{ #category : 'tests - continuous collision' }
CFPhysicsContinuousCollisionTests >> testStepPipelineDiscoversCandidateAcrossPredictedPath [
	<gtExample>
	| moving obstacle step pipeline result predictedEndBounds impact |
	moving := self newBodyWithSequence: 1 position: 0 @ 0 extent: 10 @ 10.
	moving velocity: 100 @ 0.
	obstacle := self newBodyWithSequence: 2 position: 50 @ 0 extent: 10 @ 10.
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
{ #category : 'tests - continuous collision' }
CFPhysicsContinuousCollisionTests >> testDiscretePairDiscoveryDoesNotMutateBodies [
	<gtExample>
	| moving obstacle step result |
	moving := self newBodyWithSequence: 1 position: 0 @ 0 extent: 10 @ 10.
	moving velocity: 100 @ 0.
	obstacle := self newBodyWithSequence: 2 position: 50 @ 0 extent: 10 @ 10.
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
{ #category : 'tests - continuous collision' }
CFPhysicsContinuousCollisionTests >> testDiscretePairDiscoveryDoesNotUsePreparedVelocityForSweeps [
	<gtExample>
	| moving obstacle step result state |
	moving := self newBodyWithSequence: 1 position: 0 @ 0 extent: 10 @ 10.
	obstacle := self newBodyWithSequence: 2 position: 50 @ 0 extent: 10 @ 10.
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
	self assert: state linearVelocity equals: 0 @ 0.
	self assert: moving velocity equals: 0 @ 0.
	self assert: result pairs isEmpty.
	^ result
]
{ #category : 'tests - continuous collision' }
CFPhysicsContinuousCollisionTests >> testPredictedPairDiscoveryPreservesDeterministicOrder [
	<gtExample>
	| first second third step result sequences |
	first := self newBodyWithSequence: 1 position: 0 @ 0 extent: 10 @ 10.
	second := self newBodyWithSequence: 2 position: 0 @ 0 extent: 10 @ 10.
	third := self newBodyWithSequence: 3 position: 0 @ 0 extent: 10 @ 10.
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
{ #category : 'tests - continuous collision' }
CFPhysicsContinuousCollisionTests >> testGjkUsesExplicitTransformsForOverlapQueries [
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
{ #category : 'tests - continuous collision' }
CFPhysicsContinuousCollisionTests >> testGjkExplicitTransformQueryIncludesRotation [
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
{ #category : 'tests - continuous collision' }
CFPhysicsContinuousCollisionTests >> testGjkDistanceReportsSeparationAndWitnessPoints [
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
{ #category : 'tests - continuous collision' }
CFPhysicsContinuousCollisionTests >> testGjkDistanceUsesExplicitRotation [
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
{ #category : 'tests - continuous collision' }
CFPhysicsContinuousCollisionTests >> testGjkDistanceReportsOverlap [
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
{ #category : 'tests - continuous collision' }
CFPhysicsContinuousCollisionTests >> testConservativeAdvancementFindsLinearImpact [
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
{ #category : 'tests - continuous collision' }
CFPhysicsContinuousCollisionTests >> testConservativeAdvancementReportsInitialOverlap [
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
{ #category : 'tests - continuous collision' }
CFPhysicsContinuousCollisionTests >> testConservativeAdvancementReportsSeparatingMotion [
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
{ #category : 'tests - continuous collision' }
CFPhysicsContinuousCollisionTests >> testConservativeAdvancementUsesRelativeMotion [
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
{ #category : 'tests - continuous collision' }
CFPhysicsContinuousCollisionTests >> testBox2DTimeOfImpactUsesCoreDistanceAndLinearSlop [
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
	result := CFPhysicsBox2DTimeOfImpact
		betweenShapeState: first
		sweep: firstSweep
		andShapeState: second
		sweep: secondSweep
		linearSlop: 0.005.
	self assert: result hasImpact.
	self assert: result fraction < 0.25.
	self assert: result fraction > 0.249.
	^ result
]
{ #category : 'tests - continuous collision' }
CFPhysicsContinuousCollisionTests >> testEarliestImpactFinderSelectsSmallestFraction [
	<gtExample>
	| moving near far bodyStates nearPair farPair result |
	moving := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	near := self newBodyWithSequence: 2 position: 30 @ 0 extent: 20 @ 20.
	far := self newBodyWithSequence: 3 position: 50 @ 0 extent: 20 @ 20.
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
{ #category : 'tests - continuous collision' }
CFPhysicsContinuousCollisionTests >> testEarliestImpactFinderBreaksFractionTiesByPairOrder [
	<gtExample>
	| moving firstObstacle secondObstacle bodyStates firstPair secondPair result |
	moving := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	firstObstacle := self newBodyWithSequence: 2 position: 30 @ 0 extent: 20 @ 20.
	secondObstacle := self newBodyWithSequence: 3 position: 30 @ 0 extent: 20 @ 20.
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
{ #category : 'tests - continuous collision' }
CFPhysicsContinuousCollisionTests >> testEarliestImpactFinderIgnoresSeparatedPairs [
	<gtExample>
	| moving obstacle bodyStates pair result |
	moving := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	obstacle := self newBodyWithSequence: 2 position: 30 @ 0 extent: 20 @ 20.
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
{ #category : 'tests - continuous collision' }
CFPhysicsContinuousCollisionTests >> testEarliestImpactFinderDoesNotMutateBodies [
	<gtExample>
	| moving obstacle originalMovingPosition originalObstaclePosition bodyStates pair result |
	moving := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	obstacle := self newBodyWithSequence: 2 position: 30 @ 0 extent: 20 @ 20.
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
{ #category : 'tests - continuous collision' }
CFPhysicsContinuousCollisionTests >> testTransformExplicitManifoldDoesNotUseAuthoritativeTransforms [
	<gtExample>
	| first second manifold |
	first := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self newBodyWithSequence: 2 position: 100 @ 0 extent: 20 @ 20.
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
{ #category : 'tests - continuous collision' }
CFPhysicsContinuousCollisionTests >> testTransformExplicitTouchingManifoldProvidesLocalAnchors [
	<gtExample>
	| first second firstTransform secondTransform manifold |
	first := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self newBodyWithSequence: 2 position: 100 @ 0 extent: 20 @ 20.
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
{ #category : 'tests - continuous collision' }
CFPhysicsContinuousCollisionTests >> testConstraintBuilderUsesAdvancedStepRotation [
	<gtExample>
	| first second firstState secondState bodyStates manifoldPoint manifold contact constraint anchor |
	first := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self newBodyWithSequence: 2 position: 20 @ 0 extent: 20 @ 20.
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
{ #category : 'tests - continuous collision' }
CFPhysicsContinuousCollisionTests >> testStepPipelineUsesContinuousPathForSweptImpact [
	<gtExample>
	| moving obstacle pipeline step result |
	moving := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	obstacle := self newBodyWithSequence: 2 position: 30 @ 0 extent: 20 @ 20.
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
	"Box2D TOI stops at the linear-slop target, before the exact touching fraction."
	self assert: result continuousStepResult fraction < 0.25.
	self assert: result continuousStepResult fraction > 0.249.
	self assert: moving position equals: 0 @ 0.
	result commitBodyStates.
	self assert: (moving position closeTo: 9.995 @ 0).
	self assert: (moving velocity closeTo: 40 @ 0).
	self assert: result activeContacts isEmpty.
	self assert: result constraints isEmpty.
	^ result
]
{ #category : 'tests - continuous collision' }
CFPhysicsContinuousCollisionTests >> testContinuousImpactAppliesDistanceJointImpulseAtTheImpactSlice [
	<gtExample>
	| moving obstacle tether joint pipeline step result |
	moving := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	obstacle := self newBodyWithSequence: 2 position: 30 @ 0 extent: 20 @ 20.
	tether := self newBodyWithSequence: 3 position: 100 @ 100 extent: 20 @ 20.
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
{ #category : 'tests - continuous collision' }
CFPhysicsContinuousCollisionTests >> testStepPipelinePreservesDiscretePathWithoutTOI [
	<gtExample>
	| moving obstacle pipeline step result |
	moving := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	obstacle := self newBodyWithSequence: 2 position: 100 @ 0 extent: 20 @ 20.
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
{ #category : 'tests - continuous collision' }
CFPhysicsContinuousCollisionTests >> testPredictedSweepContinuesFromAdvancedStepState [
	<gtExample>
	| body state sweep |
	body := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	state := CFPhysicsBodyStepState on: body.
	state linearVelocity: 40 @ 0.
	state integratePositionBy: 0.25.
	sweep := state predictedSweepFor: 0.75.
	self assert: (sweep startTransform bodyOrigin closeTo: 20 @ 10).
	self assert: (sweep endTransform bodyOrigin closeTo: 50 @ 10).
	self assert: body position equals: 0 @ 0.
	^ sweep
]
{ #category : 'tests - continuous collision' }
CFPhysicsContinuousCollisionTests >> testStepPipelineSolvesMultipleContinuousImpactsInTimeOrder [
	<gtExample>
	| firstMoving firstObstacle secondMoving secondObstacle pipeline step result |
	firstMoving := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	firstObstacle := self newBodyWithSequence: 2 position: 30 @ 0 extent: 20 @ 20.
	secondMoving := self newBodyWithSequence: 3 position: 0 @ 100 extent: 20 @ 20.
	secondObstacle := self newBodyWithSequence: 4 position: 40 @ 100 extent: 20 @ 20.
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
	self assert: (firstMoving position closeTo: 9.995 @ 0).
	self assert: (secondMoving position closeTo: 19.995 @ 100).
	self assert: result activeContacts isEmpty.
	self assert: result constraints isEmpty.
	self assert: result solver notNil.
	^ result
]
{ #category : 'tests - continuous collision' }
CFPhysicsContinuousCollisionTests >> testStepPipelineKeepsDiscretePathWhenNoPositiveImpactExists [
	<gtExample>
	| moving obstacle pipeline step result |
	moving := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	obstacle := self newBodyWithSequence: 2 position: 100 @ 0 extent: 20 @ 20.
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
{ #category : 'tests - continuous collision' }
CFPhysicsContinuousCollisionTests >> testStepPipelineKeepsInitialOverlapOnDiscretePath [
	<gtExample>
	| moving obstacle pipeline step result |
	moving := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	obstacle := self newBodyWithSequence: 2 position: 10 @ 0 extent: 20 @ 20.
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
{ #category : 'tests - continuous collision' }
CFPhysicsContinuousCollisionTests >> testContinuousImpactDoesNotSuppressSeparateOverlapRecovery [
	<gtExample>
	| moving wall overlapping obstacle pipeline step result |
	moving := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	wall := self newBodyWithSequence: 2 position: 30 @ 0 extent: 20 @ 20.
	overlapping := self newBodyWithSequence: 3 position: 0 @ 100 extent: 20 @ 20.
	obstacle := self newBodyWithSequence: 4 position: 10 @ 100 extent: 20 @ 20.
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
{ #category : 'tests - continuous collision' }
CFPhysicsContinuousCollisionTests >> testContinuousImpactDoesNotDoubleIntegrateSeparateMovingBody [
	<gtExample>
	| moving wall separate pipeline step result |
	moving := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	wall := self newBodyWithSequence: 2 position: 30 @ 0 extent: 20 @ 20.
	separate := self newBodyWithSequence: 3 position: 0 @ 100 extent: 20 @ 20.
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
{ #category : 'tests - continuous collision' }
CFPhysicsContinuousCollisionTests >> testStepPipelineKeepsOverlappingSensorOnDiscretePath [
	<gtExample>
	| moving sensor pipeline step result |
	moving := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	sensor := self newBodyWithSequence: 2 position: 10 @ 0 extent: 20 @ 20.
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
{ #category : 'tests - continuous collision' }
CFPhysicsContinuousCollisionTests >> testContinuousContactsPublishInDeterministicPairOrder [
	<gtExample>
	| result impacts |
	result := self testStepPipelineSolvesMultipleContinuousImpactsInTimeOrder.
	impacts := result continuousStepResult impacts.
	self assert: impacts size equals: 2.
	self assert: impacts first pair firstBody sequence equals: 1.
	self assert: impacts first pair secondBody sequence equals: 2.
	self assert: impacts second pair firstBody sequence equals: 3.
	self assert: impacts second pair secondBody sequence equals: 4.
	^ impacts
]
{ #category : 'tests - continuous collision' }
CFPhysicsContinuousCollisionTests >> testStepPipelineIgnoresSweptSensorWithoutSolvingOrBlockingMotion [
	<gtExample>
	| moving sensor pipeline step result |
	moving := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	sensor := self newBodyWithSequence: 2 position: 30 @ 0 extent: 20 @ 20.
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
	self assert: result continuousSensorContacts isEmpty.
	self assert: result activeContacts isEmpty.
	self assert: result constraints isEmpty.
	self assert: result solver notNil.
	result commitBodyStates.
	self assert: (moving position closeTo: 60 @ 0).
	self assert: result contactBeganEvents isEmpty.
	^ result
]
{ #category : 'tests - continuous collision' }
CFPhysicsContinuousCollisionTests >> testContinuousSolidImpactDoesNotPublishSensorBeyondResolvedPath [
	<gtExample>
	| moving wall sensor pipeline step result |
	moving := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	wall := self newBodyWithSequence: 2 position: 30 @ 0 extent: 20 @ 20.
	sensor := self newBodyWithSequence: 3 position: 70 @ 0 extent: 20 @ 20.
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
	self assert: (moving position closeTo: 9.995 @ 0).
	^ result
]
{ #category : 'tests - continuous collision' }
CFPhysicsContinuousCollisionTests >> testContinuousSolidImpactIgnoresSweptSensorBeforeResolvedImpact [
	<gtExample>
	| moving sensor wall pipeline step result |
	moving := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	sensor := self newBodyWithSequence: 2 position: 30 @ 0 extent: 20 @ 20.
	wall := self newBodyWithSequence: 3 position: 70 @ 0 extent: 20 @ 20.
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
	self assert: result continuousSensorContacts isEmpty.
	self assert: result activeContacts isEmpty.
	self assert: result constraints isEmpty.
	result commitBodyStates.
	self assert: (moving position closeTo: 49.995 @ 0).
	^ result
]
{ #category : 'tests - continuous collision' }
CFPhysicsContinuousCollisionTests >> testIgnoredSweptSensorProducesNoFollowingEndEvent [
	<gtExample>
	| firstResult moving sensor pipeline step secondResult |
	firstResult := self testStepPipelineIgnoresSweptSensorWithoutSolvingOrBlockingMotion.
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
{ #category : 'tests - continuous collision' }
CFPhysicsContinuousCollisionTests >> testContinuousCollisionUsesBox2DBodyTypePolicy [
	<gtExample>
	| dynamic static kinematic dynamicState staticState kinematicState |
	dynamic := self newBodyWithSequence: 1.
	static := self newBodyWithSequence: 2.
	static beStatic.
	kinematic := self newBodyWithSequence: 3.
	kinematic beKinematic.
	dynamicState := CFPhysicsBodyStepState on: dynamic.
	staticState := CFPhysicsBodyStepState on: static.
	kinematicState := CFPhysicsBodyStepState on: kinematic.
	self assert: (dynamicState requiresContinuousCollisionAgainst: staticState).
	self assert: (dynamicState requiresContinuousCollisionAgainst: kinematicState) not.
	^ dynamicState
]
{ #category : 'tests - continuous collision' }
CFPhysicsContinuousCollisionTests >> testBulletContinuousCollisionIncludesMovableNonBulletBodies [
	<gtExample>
	| bullet dynamic otherBullet bulletState dynamicState otherBulletState |
	bullet := self newBodyWithSequence: 1.
	bullet beBullet.
	dynamic := self newBodyWithSequence: 2.
	otherBullet := self newBodyWithSequence: 3.
	otherBullet beBullet.
	bulletState := CFPhysicsBodyStepState on: bullet.
	dynamicState := CFPhysicsBodyStepState on: dynamic.
	otherBulletState := CFPhysicsBodyStepState on: otherBullet.
	self assert: (bulletState requiresContinuousCollisionAgainst: dynamicState).
	self assert: (bulletState requiresContinuousCollisionAgainst: otherBulletState) not.
	^ bulletState
]
{ #category : 'tests - continuous collision' }
CFPhysicsContinuousCollisionTests >> testSweepInterpolatesSolvedBodyOriginAndRotation [
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
{ #category : 'tests - continuous collision' }
CFPhysicsContinuousCollisionTests >> testContinuousClampUsesTheSolvedSweepFraction [
	<gtExample>
	| body state |
	body := self newBodyWithSequence: 1.
	state := CFPhysicsBodyStepState on: body.
	state translateBy: 40 @ 20.
	state angularVelocity: 2.0.
	state integratePositionBy: 1.0.
	state clampSolvedTransformToFraction: 0.25.
	self assert: (state currentBodyOrigin closeTo: body worldBodyOrigin + (10 @ 5)).
	self assert: (state currentTransform rotation closeTo: body rotation + 0.5).
	^ state
]
{ #category : 'tests - continuous collision' }
CFPhysicsContinuousCollisionTests >> testShapeStateDistanceProxyPreservesExistingCircleGeometry [
	<gtExample>
	| element state proxy |
	element := BlElement new
		geometry: BlCircleGeometry new;
		size: 20 @ 20;
		yourself.
	state := (CFPhysicsShapeState on: element) capturedForStep.
	proxy := state distanceProxy.
	self assert: proxy points equals: { 0 @ 0 }.
	self assert: proxy radius equals: 10.0.
	^ proxy
]
