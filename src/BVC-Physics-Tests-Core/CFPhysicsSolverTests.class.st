Class {
	#name : 'CFPhysicsSolverTests',
	#superclass : 'CFPhysicsContactTestCase',
	#category : 'BVC-Physics-Tests-Core',
	#package : 'BVC-Physics-Tests-Core'
}

{ #category : 'tests - step' }
CFPhysicsSolverTests >> testSoftStepUsesSubstepDuration [
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
{ #category : 'tests - constraints' }
CFPhysicsSolverTests >> testConstraintPreparationMeasuresReusableContactWork [
	<gtExample>
	| first second pair updater firstBatch secondBatch stage |
	first := self newBodyWithSequence: 1.
	second := self newBodyWithSequence: 2.
	pair := CFPhysicsPair first: first second: second.
	updater := CFPhysicsContactUpdater manifoldGenerator: (CFPhysicsFixedManifoldGenerator manifold: (self newManifoldWithFeatureIndex: 1)).
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
{ #category : 'tests - constraints' }
CFPhysicsSolverTests >> testConstraintPreparationMeasuresChangedContactWork [
	<gtExample>
	| first second pair updater firstBatch secondBatch stage |
	first := self newBodyWithSequence: 1.
	second := self newBodyWithSequence: 2.
	pair := CFPhysicsPair first: first second: second.
	updater := CFPhysicsContactUpdater manifoldGenerator: (CFPhysicsFixedManifoldGenerator manifold: (self newManifoldWithFeatureIndex: 1)).
	firstBatch := updater updatePairs: { pair } fromContacts: #().
	updater := CFPhysicsContactUpdater manifoldGenerator: (CFPhysicsFixedManifoldGenerator manifold: (self newManifoldWithFeatureIndex: 2)).
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
{ #category : 'tests - constraints' }
CFPhysicsSolverTests >> testConstraintPreparationTelemetryMeasuresOnlyActiveSimulationContacts [
	<gtExample>
	| first second pair manifold contact result stage bodyStates batch contactResult |
	first := self newBodyWithSequence: 1.
	second := self newBodyWithSequence: 2.
	first sleep.
	second sleep.
	pair := CFPhysicsPair first: first second: second.
	manifold := self newManifoldWithFeatureIndex: 1.
	contact := CFPhysicsContact pair: pair manifold: manifold.
	batch := CFPhysicsContactUpdateBatch
		contacts: { contact }
		touching: { contact }
		began: { contact }
		continued: #()
		ended: #().
	contactResult := CFPhysicsContactUpdateResult pairs: { pair } contactBatch: batch.
	bodyStates := IdentityDictionary new
		at: first put: (CFPhysicsBodyStepState on: first);
		at: second put: (CFPhysicsBodyStepState on: second);
		yourself.
	result := CFPhysicsStepPipelineResult new
		bodies: { first. second };
		bodyStates: bodyStates;
		contactResult: contactResult;
		yourself.
	stage := CFPhysicsConstraintPreparationStage new.
	stage measureContacts: result activeSimulationContacts.
	self assert: result activeContacts size equals: 1.
	self assert: result activeSimulationContacts isEmpty.
	self assert: stage preparedContactConstraintCount equals: 0.
	self assert: stage preparedContactPointCount equals: 0.
	^ stage
]

{ #category : 'tests - constraints' }
CFPhysicsSolverTests >> testConstraintBuilderPreparesSolverData [
	<gtExample>
	| constraint point manifoldPoint |
	constraint := self newPreparedConstraint.
	point := constraint points first.
	manifoldPoint := constraint contact manifold contactPoints first.
	self assert: constraint bodyA isStatic.
	self assert: constraint bodyB isDynamic.
	self assert: constraint bodyStateA body == constraint bodyA.
	self assert: constraint bodyStateB body == constraint bodyB.
	self assert: constraint normal equals: 0 @ 1.
	self assert: constraint tangent equals: 1 @ 0.
	self assert: point featureId equals: manifoldPoint featureId.
	self assert: point normalMass > 0.0.
	self assert: point tangentMass > 0.0.
	self assert: (point baseSeparation closeTo: 4.0).
	^ constraint
]
{ #category : 'tests - constraints' }
CFPhysicsSolverTests >> testConstraintBuilderBaseSeparationMatchesBox2DAnchorDecomposition [
	<gtExample>
	| first second pair manifold contact bodyStates constraint point expected |
	first := self newBodyWithSequence: 1.
	first beStatic.
	second := self newBodyWithSequence: 2.
	pair := CFPhysicsPair first: first second: second.
	manifold := self newManifoldWithFeatureIndex: 1.
	contact := CFPhysicsContact pair: pair manifold: manifold.
	bodyStates := IdentityDictionary new
		at: first put: (CFPhysicsBodyStepState on: first);
		at: second put: (CFPhysicsBodyStepState on: second);
		yourself.
	constraint := (CFPhysicsConstraintBuilder new
		constraintsFrom: { contact }
		bodyStates: bodyStates) first.
	point := constraint points first.
	expected := manifold contactPoints first separation
		- ((point anchorB - point anchorA) dotProduct: constraint normal).
	self assert: (point baseSeparation closeTo: expected).
	self assert: (point baseSeparation closeTo: 4.0).
	^ point
]
{ #category : 'tests - constraints' }
CFPhysicsSolverTests >> testConstraintBuilderUsesCapturedBodyProperties [
	<gtExample>
	| first second pair manifold bodyStates builder initialConstraint capturedConstraint |
	first := self newBodyWithSequence: 1.
	first
		friction: 0.25;
		restitution: 0.2;
		tangentSpeed: 2.0.
	second := self newBodyWithSequence: 2.
	second
		friction: 0.81;
		restitution: 0.6;
		tangentSpeed: -0.5.
	pair := CFPhysicsPair first: first second: second.
	manifold := self newManifoldWithFeatureIndex: 1.
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
{ #category : 'tests - constraints' }
CFPhysicsSolverTests >> testContactTangentSpeedDefaultsToZero [
	<gtExample>
	| body |
	body := self newBodyWithSequence: 1.
	self assert: body tangentSpeed equals: 0.0.
	^ body
]
{ #category : 'tests - constraints' }
CFPhysicsSolverTests >> testPreparedConstraintWritesSolvedImpulsesBackExplicitly [
	<gtExample>
	| constraint manifoldPoint preparedPoint |
	constraint := self newPreparedConstraint.
	manifoldPoint := constraint contact manifold contactPoints first.
	preparedPoint := constraint points first.
	preparedPoint
		normalImpulse: 4.0;
		tangentImpulse: 1.5;
		totalNormalImpulse: 7.0;
		relativeNormalVelocity: -3.0.
	self assert: manifoldPoint normalImpulse equals: 0.0.
	self assert: manifoldPoint tangentImpulse equals: 0.0.
	constraint writeImpulsesBack.
	self assert: manifoldPoint normalImpulse equals: 4.0.
	self assert: manifoldPoint tangentImpulse equals: 1.5.
	self assert: manifoldPoint totalNormalImpulse equals: 7.0.
	self assert: manifoldPoint normalVelocity equals: -3.0.
	^ constraint
]
{ #category : 'tests - step pipeline' }
CFPhysicsSolverTests >> testStepPipelineExposesTheComposedStep [
	<gtExample>
	| result |
	result := self newComposedStepResult.
	self assert: result step timeStep equals: 0.016.
	self assert: result step substepCount equals: 4.
	self assert: (result bodies collect: #sequence) equals: #(1 2).
	self assert: result pairs size equals: 1.
	self assert: result beganContacts size equals: 1.
	self assert: result activeContacts size equals: 1.
	self assert: result bodyStates size equals: 2.
	self assert: result contactConstraints size equals: 1.
	self assert: result contactConstraints first contact == result activeContacts first.
	self assert: result solver notNil.
	^ result
]
{ #category : 'tests - step pipeline' }
CFPhysicsSolverTests >> testStepPipelineProjectsOverlappingBodiesApart [
	<gtExample>
	| ground box step pipeline result manifold |
	ground := self newBodyWithSequence: 1 position: 0 @ 0 extent: 100 @ 20.
	ground beStatic.
	box := self newBodyWithSequence: 2 position: 20 @ 15 extent: 60 @ 20.
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
{ #category : 'tests - step pipeline' }
CFPhysicsSolverTests >> testStepPipelineCarriesActiveContactsIntoTheNextStep [
	<gtExample>
	| firstResult ground box step pipeline secondResult |
	firstResult := self newComposedStepResult.
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
{ #category : 'tests - step stages' }
CFPhysicsSolverTests >> testStepPipelineExecutesExplicitOrderedStages [
	<gtExample>
	| result expectedTypes |
	result := self newComposedStepResult.
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
	self assert: result stageExecutions fourth output equals: result solverConstraints.
	self assert: result stageExecutions fifth output equals: result islands.
	self assert: (result stageExecutions at: 7) output == result solver.
	self assert: (result stageExecutions at: 8) output contactResults equals: result contactSolveResults.
	self assert: (result stageExecutions at: 8) output hitEvents equals: result hitEvents.
	self assert: (result stageExecutions at: 11) output equals: result contactEvents.
	^ result stageExecutions
]
{ #category : 'tests - step stages' }
CFPhysicsSolverTests >> testStepPipelineExposesReplaceableStageList [
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
{ #category : 'tests - constraints' }
CFPhysicsSolverTests >> testConstraintBuilderScalesRetainedImpulsesForChangedTimeStep [
	<gtExample>
	| first second pair manifold contact bodyStates constraint point |
	first := self newBodyWithSequence: 1.
	first beStatic.
	second := self newBodyWithSequence: 2.
	pair := CFPhysicsPair first: first second: second.
	manifold := self newManifoldWithFeatureIndex: 1.
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
{ #category : 'tests - stepping' }
CFPhysicsSolverTests >> testWorldSimulationIdentityStartsAtZero [
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
{ #category : 'tests - stepping' }
CFPhysicsSolverTests >> testWorldAdvancesSimulationIdentityAfterSuccessfulSteps [
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
{ #category : 'tests - stepping' }
CFPhysicsSolverTests >> testChangingStepDurationPreservesAccumulatedSimulationTime [
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
{ #category : 'tests - stepping' }
CFPhysicsSolverTests >> testWorldKeepsBox2DWarmStartingWhenStepDurationChanges [
	<gtExample>
	| world firstStep secondStep |
	world := CFPhysicsWorld on: BlElement new.
	firstStep := world newStep.
	self assert: firstStep warmStartRatio equals: 1.0.
	world step.
	world stepDuration: 8 milliseconds.
	secondStep := world newStep.
	self assert: secondStep warmStartRatio equals: 1.0.
	^ secondStep
]
{ #category : 'tests - stepping' }
CFPhysicsSolverTests >> testWorldWarmStartingDefaultsToEnabled [
	<gtExample>
	| world |
	world := CFPhysicsWorld new.
	self assert: world warmStarting.
	^ world
]
{ #category : 'tests - stepping' }
CFPhysicsSolverTests >> testWorldCanDisableAndResumeWarmStarting [
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
	self assert: resumedStep warmStartRatio equals: 1.0.
	^ resumedStep
]
{ #category : 'tests - stepping' }
CFPhysicsSolverTests >> testWorldConvertsBox2DMaximumLinearSpeedToPhysicsUnits [
	<gtExample>
	| world step |
	world := CFPhysicsWorld new.
	world maximumLinearSpeed: 5.0.
	step := world newStep.
	self assert: step maximumLinearSpeed equals: 500.0.
	^ step
]
{ #category : 'tests - solver' }
CFPhysicsSolverTests >> testSoftStepIntegratesVelocityPerSubstep [
	<gtExample>
	| host world element body |
	host := BlElement new size: 2000 @ 2000; yourself.
	world := host physics beWorld.
	world
		gravity: 0 @ 0;
		stepDuration: 1000 milliseconds;
		substepCount: 2.
	element := BlElement new
		size: 10 @ 10;
		position: 1000 @ 1000;
		yourself.
	host addChild: element.
	element physics beDynamic.
	world owner physics makeChildrenDynamic.
	element physics
		velocity: 100 @ 0;
		linearDamping: 1.0.
	body := element physics body.
	world step.
	self assert: (body velocity x closeTo: (100.0 / 1.5 / 1.5)).
	self assert: (body velocity y closeTo: 0.0).
	^ body
]
{ #category : 'tests - velocity integration' }
CFPhysicsSolverTests >> testStepStateIntegratesAccumulatedForceByInverseMass [
	<gtExample>
	| body state |
	body := self newBodyWithSequence: 1 position: 0 @ 0 extent: 100 @ 100.
	body applyForce: 2 @ -1.
	state := CFPhysicsBodyStepState on: body.
	state integrateVelocityBy: 0.5 gravity: 0 @ 0.
	self assert: (state linearVelocity x closeTo: 100.0).
	self assert: (state linearVelocity y closeTo: -50.0).
	^ state
]
{ #category : 'tests - velocity integration' }
CFPhysicsSolverTests >> testStepStateAppliesPerBodyGravityScale [
	<gtExample>
	| body state |
	body := self newBodyWithSequence: 1 position: 0 @ 0 extent: 10 @ 10.
	body gravityScale: 0.25.
	state := CFPhysicsBodyStepState on: body.
	state integrateVelocityBy: 2.0 gravity: 0 @ 10.
	self assert: state linearVelocity equals: 0 @ 5.
	^ state
]
{ #category : 'tests - velocity integration' }
CFPhysicsSolverTests >> testStepStateAppliesPadeLinearDamping [
	<gtExample>
	| body state |
	body := self newBodyWithSequence: 1 position: 0 @ 0 extent: 10 @ 10.
	body
		velocity: 12 @ -6;
		linearDamping: 2.0.
	state := CFPhysicsBodyStepState on: body.
	state integrateVelocityBy: 0.5 gravity: 0 @ 0.
	self assert: state linearVelocity equals: 6 @ -3.
	^ state
]
{ #category : 'tests - velocity integration' }
CFPhysicsSolverTests >> testStepStateCapsLinearVelocityLikeBox2D [
	<gtExample>
	| body state |
	body := self newBodyWithSequence: 1 position: 0 @ 0 extent: 10 @ 10.
	body velocity: 6 @ 8.
	state := CFPhysicsBodyStepState on: body.
	state integrateVelocityBy: 1.0 gravity: 0 @ 0 maximumLinearSpeed: 5.0.
	self assert: (state linearVelocity closeTo: 3 @ 4).
	^ state
]
{ #category : 'tests - velocity integration' }
CFPhysicsSolverTests >> testStepStateCapsAngularVelocityUnlessFastRotationIsAllowed [
	<gtExample>
	| body cappedState uncappedState maximumAngularSpeed |
	body := self newBodyWithSequence: 1 position: 0 @ 0 extent: 10 @ 10.
	maximumAngularSpeed := Float pi * 0.25.
	body angularVelocity: Float pi.
	cappedState := CFPhysicsBodyStepState on: body.
	cappedState integrateVelocityBy: 1.0 gravity: 0 @ 0 maximumLinearSpeed: 400.0.
	self assert: (cappedState angularVelocity closeTo: maximumAngularSpeed).

	body
		allowFastRotation: true;
		angularVelocity: Float pi.
	uncappedState := CFPhysicsBodyStepState on: body.
	uncappedState integrateVelocityBy: 1.0 gravity: 0 @ 0 maximumLinearSpeed: 400.0.
	self assert: uncappedState angularVelocity equals: Float pi.
	^ uncappedState
]
{ #category : 'tests - velocity integration' }
CFPhysicsSolverTests >> testStepStateUsesWholeStepAngularVelocityLimitAcrossSubsteps [
	<gtExample>
	| body state maximumAngularSpeed |
	body := self newBodyWithSequence: 1 position: 0 @ 0 extent: 10 @ 10.
	maximumAngularSpeed := Float pi * 0.25.
	body angularVelocity: Float pi.
	state := CFPhysicsBodyStepState on: body.
	state
		integrateVelocityBy: 0.125
		gravity: 0 @ 0
		maximumLinearSpeed: 400.0
		maximumAngularSpeed: maximumAngularSpeed.
	self assert: (state angularVelocity closeTo: maximumAngularSpeed).
	^ state
]
{ #category : 'tests - velocity integration' }
CFPhysicsSolverTests >> testStepStateDoesNotDampCurrentForceContribution [
	<gtExample>
	| body state |
	body := self newBodyWithSequence: 1 position: 0 @ 0 extent: 100 @ 100.
	body
		velocity: 12 @ -6;
		linearDamping: 2.0;
		applyForce: 2 @ -1.
	state := CFPhysicsBodyStepState on: body.
	state integrateVelocityBy: 0.5 gravity: 0 @ 0.
	self assert: (state linearVelocity closeTo: 106 @ -53).
	^ state
]
{ #category : 'tests - velocity integration' }
CFPhysicsSolverTests >> testBodyCommitClearsAccumulatedForceAndTorque [
	<gtExample>
	| body state |
	body := self newBodyWithSequence: 1 position: 0 @ 0 extent: 10 @ 10.
	body
		applyForce: 20 @ 30;
		applyTorque: 40.
	state := CFPhysicsBodyStepState on: body.
	state commit.
	self assert: body force equals: 0 @ 0.
	self assert: body torque equals: 0.0.
	^ body
]
{ #category : 'tests - step pipeline' }
CFPhysicsSolverTests >> testSolvedBodyStateRemainsDetachedUntilPipelineResultCommit [
	<gtExample>
	| body state result |
	body := self newBodyWithSequence: 1 position: 10 @ 20 extent: 30 @ 40.
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
{ #category : 'tests - constraint preparation' }
CFPhysicsSolverTests >> testPreparedJointImpulseRemainsDetachedUntilPipelineResultCommit [
	<gtExample>
	| first second joint prepared result |
	first := self newBodyWithSequence: 1.
	second := self newBodyWithSequence: 2.
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
{ #category : 'tests - constraint preparation' }
CFPhysicsSolverTests >> testPreparedJointConstraintsShareTheirJointStateContract [
	<gtExample>
	self assert: CFPhysicsPreparedDistanceJoint superclass equals: CFPhysicsPreparedJointConstraint.
	self assert: CFPhysicsPreparedRevoluteJoint superclass equals: CFPhysicsPreparedJointConstraint.
	self assert: CFPhysicsPreparedPrismaticJoint superclass equals: CFPhysicsPreparedJointConstraint.
	self assert: (CFPhysicsPreparedWeldJoint inheritsFrom: CFPhysicsPreparedJointConstraint).
	^ CFPhysicsPreparedJointConstraint
]
{ #category : 'tests - constraints' }
CFPhysicsSolverTests >> testConstraintBuilderCreatesStepLocalPreparedContactObjects [
	<gtExample>
	| first second pair updater firstBatch secondBatch bodyStates builder firstConstraint secondConstraint firstPoint secondPoint |
	first := self newBodyWithSequence: 1.
	first beStatic.
	second := self newBodyWithSequence: 2.
	pair := CFPhysicsPair first: first second: second.
	updater := CFPhysicsContactUpdater manifoldGenerator: (CFPhysicsFixedManifoldGenerator manifold: (self newManifoldWithFeatureIndex: 1)).
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
	secondBatch := updater updatePairs: { pair } fromContacts: firstBatch contacts.
	secondConstraint := (builder
		constraintsFrom: secondBatch activeContacts
		bodyStates: bodyStates) first.
	secondPoint := secondConstraint points first.
	self assert: secondConstraint ~~ firstConstraint.
	self assert: secondPoint ~~ firstPoint.
	self assert: secondConstraint contact == secondBatch activeContacts first.
	self assert: secondPoint manifoldPoint == secondBatch activeContacts first manifold contactPoints first.
	self assert: builder createdConstraintCount equals: 1.
	self assert: builder reusedConstraintCount equals: 0.
	self assert: builder createdPointCount equals: 1.
	self assert: builder reusedPointCount equals: 0.
	^ secondConstraint
]
{ #category : 'tests - constraints' }
CFPhysicsSolverTests >> testContactRollingResistanceDefaultsToZero [
	<gtExample>
	| body |
	body := self newBodyWithSequence: 1.
	self assert: body rollingResistance equals: 0.0.
	^ body
]
{ #category : 'tests - constraints' }
CFPhysicsSolverTests >> testConstraintBuilderPreparesRollingResistance [
	<gtExample>
	| first second pair manifold bodyStates constraint |
	first := self newBodyWithSequence: 1.
	first element geometry: BlCircleGeometry new; size: 20 @ 20.
	first rollingResistance: 0.2.
	second := self newBodyWithSequence: 2.
	second element geometry: BlCircleGeometry new; size: 40 @ 40.
	second rollingResistance: 0.5.
	pair := CFPhysicsPair first: first second: second.
	manifold := self newManifoldWithFeatureIndex: 1.
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
{ #category : 'tests - constraints' }
CFPhysicsSolverTests >> testPreparedConstraintWritesRollingImpulseBack [
	<gtExample>
	| constraint |
	constraint := self newPreparedConstraint.
	constraint rollingImpulse: 2.5.
	constraint writeImpulsesBack.
	self assert: (constraint contact manifold rollingImpulse closeTo: 2.5).
	^ constraint
]
{ #category : 'tests - solver' }
CFPhysicsSolverTests >> testZeroRestitutionSkipsRestitutionPass [
	<gtExample>
	| first second step result |
	first := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	first
		velocity: 0 @ 100;
		restitution: 0.0.
	second := self newBodyWithSequence: 2 position: 0 @ 19 extent: 20 @ 20.
	second
		beStatic;
		restitution: 0.0.
	step := CFPhysicsStep
		timeStep: 1.0 / 60.0
		substeps: 4
		contactHertz: 30.0
		dampingRatio: 10.0.
	result := (CFPhysicsStepPipeline manifoldGenerator: CFPhysicsManifoldGenerator new)
		stepBodies: { first. second }
		fromContacts: #()
		step: step
		gravity: 0 @ 0
		restitutionThreshold: 1.0.
	self assert: result activeContacts isNotEmpty.
	self assert: result solver restitutionCandidatePointCount equals: 0.
	^ result
]
{ #category : 'tests - solver' }
CFPhysicsSolverTests >> testContactHertzIsCappedForLargeSubsteps [
	<gtExample>
	| step capped |
	step := CFPhysicsStep
		timeStep: 1.0
		substeps: 1
		contactHertz: 120.0
		dampingRatio: 1.0.
	capped := CFPhysicsStep
		timeStep: 1.0
		substeps: 1
		contactHertz: 0.125
		dampingRatio: 1.0.
	self assert: (step biasRate closeTo: capped biasRate).
	self assert: (step massCoefficient closeTo: capped massCoefficient).
	self assert: (step impulseCoefficient closeTo: capped impulseCoefficient).
	^ step
]
{ #category : 'tests - solver' }
CFPhysicsSolverTests >> testStaticContactUsesStifferSoftness [
	<gtExample>
	| step |
	step := CFPhysicsStep
		timeStep: 1.0 / 60.0
		substeps: 4
		contactHertz: 30.0
		dampingRatio: 1.0.
	self assert: step staticBiasRate > step biasRate.
	self assert: step staticMassCoefficient > step massCoefficient.
	self assert: step staticImpulseCoefficient < step impulseCoefficient.
	^ step
]
