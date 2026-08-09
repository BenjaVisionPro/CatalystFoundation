Class {
	#name : 'CFPhysicsWorldTests',
	#superclass : 'CFPhysicsWorldTestCase',
	#category : 'BVC-Physics-Tests-Core',
	#package : 'BVC-Physics-Tests-Core'
}

{ #category : 'tests - world cutover' }
CFPhysicsWorldTests >> testWorldDelegatesOneStepToTheExplicitPipeline [
	<gtExample>
	| world result |
	world := self newWorldAfterOneStep.
	result := world lastStepResult.
	self assert: result == world lastStepResult.
	self assert: result bodies equals: world bodyStatesInOrder.
	self assert: result activeContacts size equals: 1.
	self assert: world activeContacts equals: result activeContacts.
	self assert: result step substepCount equals: world substepCount.
	^ world
]
{ #category : 'tests - world cutover' }
CFPhysicsWorldTests >> testWorldCarriesActiveContactsExplicitlyBetweenSteps [
	<gtExample>
	| world firstResult secondResult |
	world := self newWorldAfterOneStep.
	firstResult := world lastStepResult.
	secondResult := world step.
	self assert: firstResult beganContacts size equals: 1.
	self assert: secondResult beganContacts isEmpty.
	self assert: secondResult continuedContacts size equals: 1.
	self assert: world activeContacts equals: secondResult activeContacts.
	^ secondResult
]
{ #category : 'tests - world cutover' }
CFPhysicsWorldTests >> testPreparedContactConstraintsAreStepLocal [
	<gtExample>
	| world firstContact firstConstraint firstPoint secondContact secondConstraint secondPoint |
	world := self newWorldAfterOneStep.
	firstContact := world activeContacts first.
	firstConstraint := (world lastStepResult contactConstraints detect: [ :each | each isKindOf: CFPhysicsPreparedConstraint ]).
	firstPoint := firstConstraint points first.
	world step.
	secondContact := world activeContacts first.
	secondConstraint := (world lastStepResult contactConstraints detect: [ :each | each isKindOf: CFPhysicsPreparedConstraint ]).
	secondPoint := secondConstraint points first.
	self assert: secondContact ~~ firstContact.
	self assert: secondConstraint ~~ firstConstraint.
	self assert: secondPoint ~~ firstPoint.
	self assert: firstConstraint contact == firstContact.
	self assert: secondConstraint contact == secondContact.
	^ secondConstraint
]
{ #category : 'tests - world cutover' }
CFPhysicsWorldTests >> testReturningContactBuildsFreshPreparedConstraint [
	<gtExample>
	| world movingBody contact constraint returnedContact returnedConstraint returnedPoint returnedManifoldPoint |
	world := self newWorldAfterOneStep.
	movingBody := world bodyStatesInOrder second.
	contact := world activeContacts first.
	constraint := (world lastStepResult contactConstraints detect: [ :each | each isKindOf: CFPhysicsPreparedConstraint ]).
	movingBody position: 20 @ 100.
	world step.
	self assert: world activeContacts isEmpty.
	movingBody position: 20 @ 15.
	world step.
	self assert: world activeContacts size equals: 1.
	returnedContact := world activeContacts first.
	returnedConstraint := (world lastStepResult contactConstraints detect: [ :each | each isKindOf: CFPhysicsPreparedConstraint ]).
	returnedPoint := returnedConstraint points first.
	returnedManifoldPoint := returnedContact manifold contactPoints first.
	self assert: returnedContact == contact.
	self assert: returnedConstraint ~~ constraint.
	self assert: returnedConstraint contact == returnedContact.
	self assert: returnedPoint manifoldPoint == returnedManifoldPoint.
	self assert: returnedPoint featureId equals: returnedManifoldPoint featureId.
	self assert: returnedPoint normalImpulse equals: returnedManifoldPoint normalImpulse.
	self assert: returnedPoint tangentImpulse equals: returnedManifoldPoint tangentImpulse.
	^ returnedContact
]
{ #category : 'tests - world membership' }
CFPhysicsWorldTests >> testOnlyElementsThatEnterPhysicsParticipateInTheWorld [
	<gtExample>
	| owner button label world |
	owner := BlElement new size: 200 @ 120; yourself.
	button := BrButton new
		aptitude: BrGlamorousButtonWithLabelAptitude new;
		label: 'Click Me';
		yourself.
	label := button childWithId: #label.
	owner addChild: button.
	world := owner physics beWorld.
	button physics beDynamic.
	self assert: world members size equals: 1.
	self assert: (world includes: button).
	self assert: (world includes: label) not.
	^ world
]

{ #category : 'tests - world membership' }
CFPhysicsWorldTests >> testBodyTypeSelectorsEnterAnElementIntoPhysics [
	<gtExample>
	| owner dynamicElement staticElement kinematicElement world |
	owner := BlElement new.
	dynamicElement := BlElement new extent: 20 @ 20.
	staticElement := BlElement new extent: 20 @ 20.
	kinematicElement := BlElement new extent: 20 @ 20.
	owner addChildren: { dynamicElement. staticElement. kinematicElement }.
	world := owner physics beWorld.
	dynamicElement physics beDynamic.
	staticElement physics beStatic.
	kinematicElement physics beKinematic.
	self assert: (world includes: dynamicElement).
	self assert: (world includes: staticElement).
	self assert: (world includes: kinematicElement).
	self assert: dynamicElement physics isDynamic.
	self assert: staticElement physics isStatic.
	self assert: kinematicElement physics isKinematic.
	^ world
]

{ #category : 'tests - world membership' }
CFPhysicsWorldTests >> testMakeChildrenDynamicAddsOnlyDirectChildren [
	<gtExample>
	| owner child nested world |
	owner := BlElement new.
	child := BlElement new extent: 20 @ 20.
	nested := BlElement new extent: 10 @ 10.
	child addChild: nested.
	owner addChild: child.
	world := owner physics beWorld.
	owner physics makeChildrenDynamic.
	self assert: (world includes: child).
	self assert: (world includes: nested) not.
	self assert: child physics isDynamic.
	^ world
]

{ #category : 'tests - world membership' }
CFPhysicsWorldTests >> testMakeChildrenDynamicMatchingAddsOnlyMatchingChildren [
	<gtExample>
	| owner included ignored world |
	owner := BlElement new.
	included := BlElement new extent: 20 @ 20.
	ignored := BlElement new extent: 20 @ 20.
	owner addChildren: { included. ignored }.
	world := owner physics beWorld.
	owner physics makeChildrenDynamicMatching: [ :each | each == included ].
	self assert: (world includes: included).
	self assert: (world includes: ignored) not.
	^ world
]

{ #category : 'tests - worlds' }
CFPhysicsWorldTests >> testBeWorldInstallsWorldAlongsidePhysics [
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
{ #category : 'tests - worlds' }
CFPhysicsWorldTests >> testWorldAnswersNearestExplicitWorld [
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
{ #category : 'tests - worlds' }
CFPhysicsWorldTests >> testBeWorldInstallsOnReceiverWhenNoWorldExists [
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
{ #category : 'tests - inspection' }
CFPhysicsWorldTests >> testPhysicsMagritteDescriptionsAreReadOnly [
	<gtExample>
	| owner element world physics descriptions expectedAccessors |
	owner := BlElement new size: 400 @ 300; yourself.
	element := BlElement new size: 20 @ 20; yourself.
	owner addChild: element.
	world := owner physics beWorld.
	world owner physics makeChildrenDynamic.
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
{ #category : 'tests - world state capture' }
CFPhysicsWorldTests >> testWorldStateOwnsCapturedBodyStatesBeforeSolve [
	<gtExample>
	| owner element world body state solution |
	owner := BlElement new size: 200 @ 200; yourself.
	element := BlElement new
		geometry: BlRoundedRectangleGeometry new;
		size: 20 @ 20;
		yourself.
	owner addChild: element.
	world := owner physics beWorld.
	world owner physics makeChildrenDynamic.
	body := element physics body.
	body position: 0 @ 0.
	state := world capturePreparedState.
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
{ #category : 'tests - world state capture' }
CFPhysicsWorldTests >> testWorldStateOwnsCapturedJointConfigurationBeforeSolve [
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
	world owner physics makeChildrenDynamic.
	first := firstElement physics body.
	second := secondElement physics body.
	first position: 0 @ 0.
	second position: 40 @ 0.
	joint := CFPhysicsDistanceJoint between: first and: second.
	joint
		length: 25;
		impulse: 3.0.
	world addJoint: joint.
	state := world capturePreparedState.
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
{ #category : 'tests - world state capture' }
CFPhysicsWorldTests >> testSolvingCapturedStateBuildsIndependentPreparedConstraint [
	<gtExample>
	| world committedContact committedManifold state solution calculationContact calculationConstraint |
	world := self newWorldAfterOneStep.
	committedContact := world activeContacts first.
	committedManifold := committedContact manifold.
	state := world capturePreparedState.
	solution := world stepPipeline solve: state.
	calculationContact := solution pipelineResult activeContacts first.
	calculationConstraint := (solution pipelineResult contactConstraints detect: [ :each | each isKindOf: CFPhysicsPreparedConstraint ]).
	self assert: world activeContacts first == committedContact.
	self assert: committedContact manifold == committedManifold.
	self assert: calculationContact ~~ committedContact.
	self assert: calculationConstraint contact == calculationContact.
	^ solution
]
{ #category : 'tests - world state capture' }
CFPhysicsWorldTests >> testSolvingCapturedStateBuildsIndependentConstraintPoint [
	<gtExample>
	| world committedContact committedManifoldPoint state solution calculationContact calculationConstraint calculationPoint |
	world := self newWorldAfterOneStep.
	committedContact := world activeContacts first.
	committedManifoldPoint := committedContact manifold contactPoints first.
	state := world capturePreparedState.
	solution := world stepPipeline solve: state.
	calculationContact := solution pipelineResult activeContacts first.
	calculationConstraint := (solution pipelineResult contactConstraints detect: [ :each | each isKindOf: CFPhysicsPreparedConstraint ]).
	calculationPoint := calculationConstraint points first.
	self assert: world activeContacts first == committedContact.
	self assert: committedContact manifold contactPoints first == committedManifoldPoint.
	self assert: calculationPoint manifoldPoint == calculationContact manifold contactPoints first.
	self assert: calculationPoint manifoldPoint ~~ committedManifoldPoint.
	^ solution
]
{ #category : 'tests - world state capture' }
CFPhysicsWorldTests >> testWorldSolutionCarriesCommitIdentity [
	<gtExample>
	| world state solution |
	world := self newWorldAfterOneStep.
	state := world capturePreparedState.
	solution := world stepPipeline solve: state.
	self assert: solution world == world.
	self assert: solution lifetimeGeneration equals: state lifetimeGeneration.
	self assert: solution topologyRevision equals: state topologyRevision.
	self assert: solution solveTicket equals: state solveTicket.
	^ solution
]
{ #category : 'tests - world state capture' }
CFPhysicsWorldTests >> testNewerCaptureRejectsOlderSolution [
	<gtExample>
	| world firstState firstSolution stepBefore |
	world := self newWorldAfterOneStep.
	firstState := world capturePreparedState.
	firstSolution := world stepPipeline solve: firstState.
	stepBefore := world stepNumber.
	world capturePreparedState.
	self assert: (world commit: firstSolution) isNil.
	self assert: world stepNumber equals: stepBefore.
	^ world
]
{ #category : 'tests - world state capture' }
CFPhysicsWorldTests >> testReleasedWorldRejectsCapturedSolution [
	<gtExample>
	| world state solution |
	world := self newWorldAfterOneStep.
	state := world capturePreparedState.
	solution := world stepPipeline solve: state.
	world release.
	self assert: (world commit: solution) isNil.
	self assert: world activeSolveTicket isNil.
	^ world
]
{ #category : 'tests - world state capture' }
CFPhysicsWorldTests >> testWorldCapturesAtMostOneSolveAtATime [
	<gtExample>
	| world firstState secondState thirdState |
	world := self newWorldAfterOneStep.
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
{ #category : 'tests - world state capture' }
CFPhysicsWorldTests >> testAbandoningTheActiveSolveAllowsImmediateRecapture [
	<gtExample>
	| world firstState secondState |
	world := self newWorldAfterOneStep.
	firstState := world captureStateIfIdle.
	self assert: world hasSolveInFlight.
	world abandonActiveSolve.
	self assert: world hasSolveInFlight not.
	secondState := world captureStateIfIdle.
	self assert: secondState notNil.
	self assert: secondState solveTicket ~= firstState solveTicket.
	^ secondState
]
{ #category : 'tests - world state capture' }
CFPhysicsWorldTests >> testAbandoningAnOlderSolveDoesNotReleaseTheCurrentSolve [
	<gtExample>
	| world firstState secondState |
	world := self newWorldAfterOneStep.
	firstState := world capturePreparedState.
	secondState := world capturePreparedState.
	self assert: secondState solveTicket > firstState solveTicket.
	world abandonSolveTicket: firstState solveTicket.
	self assert: world hasSolveInFlight.
	self assert: world activeSolveTicket equals: secondState solveTicket.
	world abandonSolveTicket: secondState solveTicket.
	self assert: world hasSolveInFlight not.
	^ world
]

{ #category : 'tests - background stepping' }
CFPhysicsWorldTests >> testWorldUsesBackgroundSteppingByDefault [
	self assert: CFPhysicsWorld new backgroundStepping
]

{ #category : 'tests - background stepping' }
CFPhysicsWorldTests >> testBackgroundStepClaimsTheSingleSolveSlotWithoutWaiting [
	<gtExample>
	| world space startedAgain |
	world := self newWorldAfterOneStep.
	space := BlSpace new.
	space root addChild: world owner.
	self assert: world startBackgroundStep.
	self assert: world hasSolveInFlight.
	startedAgain := world startBackgroundStep.
	self assert: startedAgain not.
	^ world
]
{ #category : 'tests - world state capture' }
CFPhysicsWorldTests >> testTopologyInvalidationReleasesTheSolveSlotImmediately [
	<gtExample>
	| world firstState firstSolution secondState |
	world := self newWorldAfterOneStep.
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
{ #category : 'tests - background stepping' }
CFPhysicsWorldTests >> testDetachedCaptureSolveCommitMatchesSynchronousStep [
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
	synchronousWorld gravity: 0 @ 0.1.
	synchronousWorld owner physics makeChildrenDynamic.
	detachedWorld gravity: 0 @ 0.1.
	detachedWorld owner physics makeChildrenDynamic.
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
{ #category : 'tests - background stepping' }
CFPhysicsWorldTests >> testBackgroundStepResolvesItsPipelineBeforeDispatch [
	<gtExample>
	| world space backgroundStep capturedPipeline replacementPipeline |
	world := self newWorldAfterOneStep.
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
{ #category : 'tests - background stepping' }
CFPhysicsWorldTests >> testStaleSolveCannotCompeteWithRestartedWorldProgress [
	<gtExample>
	| world oldState oldSolution newState newSolution committed |
	world := self newWorldAfterOneStep.
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
{ #category : 'tests - background stepping' }
CFPhysicsWorldTests >> testDetachedOwnerCannotClaimABackgroundSolveSlot [
	<gtExample>
	| world backgroundStep |
	world := self newWorldAfterOneStep.
	self assert: world owner isAttachedToSceneGraph not.
	backgroundStep := CFPhysicsWorldBackgroundStep on: world.
	self assert: backgroundStep start not.
	self assert: backgroundStep state isNil.
	self assert: world hasSolveInFlight not.
	^ world
]
{ #category : 'tests - background telemetry' }
CFPhysicsWorldTests >> testDetachedSolvePublishesTelemetryOnlyAfterCommit [
	<gtExample>
	| world state backgroundStep solution committed |
	world := self newWorldAfterOneStep.
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
{ #category : 'tests - background telemetry' }
CFPhysicsWorldTests >> testStaleDetachedSolvePublishesNoTelemetry [
	<gtExample>
	| world state backgroundStep solution |
	world := self newWorldAfterOneStep.
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
{ #category : 'tests - background telemetry' }
CFPhysicsWorldTests >> testFailedBackgroundStartDoesNotDiscardPendingTelemetry [
	<gtExample>
	| world space state backgroundStep solution secondBackgroundStep |
	world := self newWorldAfterOneStep.
	space := BlSpace new.
	space root addChild: world owner.
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
	secondBackgroundStep := CFPhysicsWorldBackgroundStep on: world.
	self assert: secondBackgroundStep start not.
	self assert: world telemetryRecordings isEmpty.
	self assert: (world commit: solution) notNil.
	self assert: world telemetryRecordings size equals: 1.
	world telemetryEnabled: false.
	^ world
]

{ #category : 'tests - background telemetry' }
CFPhysicsWorldTests >> testTelemetryResetDiscardsPendingBackgroundRecording [
	<gtExample>
	| world state backgroundStep solution |
	world := self newWorldAfterOneStep.
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
	world resetTelemetry.
	self assert: (world commit: solution) notNil.
	self assert: world telemetryRecordings isEmpty.
	world telemetryEnabled: false.
	^ world
]

{ #category : 'tests - background telemetry' }
CFPhysicsWorldTests >> testBackgroundStepCapturesTelemetryModeBeforeDispatch [
	<gtExample>
	| world space backgroundStep |
	world := self newWorldAfterOneStep.
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
{ #category : 'tests - background telemetry' }
CFPhysicsWorldTests >> testBackgroundStepDefaultsToTheUnmeasuredSolver [
	<gtExample>
	| world space backgroundStep |
	world := self newWorldAfterOneStep.
	space := BlSpace new.
	space root addChild: world owner.
	self assert: world telemetryEnabled not.
	backgroundStep := CFPhysicsWorldBackgroundStep on: world.
	self assert: backgroundStep start.
	self assert: backgroundStep telemetryEnabled not.
	^ backgroundStep
]
{ #category : 'tests - telemetry testing' }
CFPhysicsWorldTests >> testTelemetryTestRunCollectsOnlyMeasuredSteps [
	<gtExample>
	| world run initialStepNumber |
	world := self newWorldAfterOneStep.
	initialStepNumber := world stepNumber.
	run := CFPhysicsTelemetryTestRun
		world: world
		warmUpSteps: 2
		measuredSteps: 3.
	self assert: run sampleCount equals: 3.
	self assert: (run physicsData allSatisfy: [ :each | (each at: #kind) = #step ]).
	self
		assert: (run valuesAt: #stepNumber)
		equals: (initialStepNumber + 3 to: initialStepNumber + 5) asArray.
	self assert: run analysis sampleCount equals: 3.
	self assert: (run valuesAt: #beganContactCount) size equals: 3.
	self assert: (run valuesAt: #continuedContactCount) size equals: 3.
	self assert: (run valuesAt: #endedContactCount) size equals: 3.
	self assert: world telemetryEnabled not.
	^ run
]
{ #category : 'tests - telemetry testing' }
CFPhysicsWorldTests >> testTelemetryTestRunRestoresWorldTelemetryConfiguration [
	<gtExample>
	| world run |
	world := self newWorldAfterOneStep.
	world
		telemetryCapacity: 17;
		telemetryEnabled: true.
	run := CFPhysicsTelemetryTestRun
		world: world
		warmUpSteps: 0
		measuredSteps: 2.
	self assert: run sampleCount equals: 2.
	self assert: world telemetryEnabled.
	self assert: world telemetryCapacity equals: 17.
	world telemetryEnabled: false.
	^ run
]
{ #category : 'tests - telemetry testing' }
CFPhysicsWorldTests >> testTelemetryResetPreservesRecordingBuffer [
	<gtExample>
	| world |
	world := self newWorldAfterOneStep.
	world telemetryEnabled: true.
	world step.
	self assert: world telemetryRecordings size equals: 1.
	world resetTelemetry.
	self assert: world telemetryRecordings isEmpty.
	world step.
	self assert: world telemetryRecordings size equals: 1.
	world telemetryEnabled: false.
	^ world
]
{ #category : 'tests - telemetry testing' }
CFPhysicsWorldTests >> testTelemetryCapacitySurvivesReset [
	<gtExample>
	| world initialStepNumber |
	world := self newWorldAfterOneStep.
	initialStepNumber := world stepNumber.
	world
		telemetryCapacity: 3;
		telemetryEnabled: true;
		resetTelemetry;
		step: 5.
	self assert: world telemetryCapacity equals: 3.
	self assert: world telemetryRecordings size equals: 3.
	self
		assert: (world telemetryRecordings collect: [ :each | each physicsData at: #stepNumber ])
		equals: (initialStepNumber + 3 to: initialStepNumber + 5) asArray.
	world telemetryEnabled: false.
	^ world
]


{ #category : 'tests - geometry lifecycle' }
CFPhysicsWorldTests >> testParticipatingElementResizeRefreshesCollisionGeometryAutomatically [
	<gtExample>
	| owner element world body initialRevision |
	owner := BlElement new size: 300 @ 200; yourself.
	element := BlElement new size: 20 @ 30; yourself.
	owner addChild: element.
	world := owner physics beWorld.
	element physics beDynamic.
	body := element physics body.
	initialRevision := body shapeState geometryRevision.
	element size: 60 @ 40.
	world step.
	self assert: body shapeState extent equals: 60 @ 40.
	self assert: body shapeState geometryRevision equals: initialRevision + 1.
	^ world
]

{ #category : 'tests - geometry lifecycle' }
CFPhysicsWorldTests >> testParticipatingElementGeometryReplacementRefreshesCollisionGeometryAutomatically [
	<gtExample>
	| owner element world body initialRevision |
	owner := BlElement new size: 300 @ 200; yourself.
	element := BlElement new
		geometry: BlRoundedRectangleGeometry new;
		size: 40 @ 40;
		yourself.
	owner addChild: element.
	world := owner physics beWorld.
	element physics beDynamic.
	body := element physics body.
	initialRevision := body shapeState geometryRevision.
	self assert: body shapeState isCircle not.
	element geometry: BlCircleGeometry new.
	world step.
	self assert: body shapeState isCircle.
	self assert: body shapeState geometryRevision equals: initialRevision + 1.
	^ world
]

{ #category : 'tests - geometry lifecycle' }
CFPhysicsWorldTests >> testUnchangedGeometryDoesNotAdvanceRuntimeIdentity [
	<gtExample>
	| owner element world body initialRevision |
	owner := BlElement new size: 300 @ 200; yourself.
	element := BlElement new size: 40 @ 40; yourself.
	owner addChild: element.
	world := owner physics beWorld.
	element physics beDynamic.
	body := element physics body.
	initialRevision := body shapeState geometryRevision.
	world step.
	world step.
	self assert: body shapeState geometryRevision equals: initialRevision.
	^ world
]


{ #category : 'tests - world membership' }
CFPhysicsWorldTests >> testMembershipRevisionChangesOnlyWhenBodyMembershipChanges [
	<gtExample>
	| owner element world initialRevision |
	owner := BlElement new size: 200 @ 120; yourself.
	element := BlElement new size: 20 @ 20; yourself.
	owner addChild: element.
	world := owner physics beWorld.
	initialRevision := world membershipRevision.
	element physics beDynamic.
	self assert: world membershipRevision equals: initialRevision + 1.
	element physics beKinematic.
	self assert: world membershipRevision equals: initialRevision + 1.
	element removeFromParent.
	self assert: world membershipRevision equals: initialRevision + 2.
	^ world
]

{ #category : 'tests - visual state' }
CFPhysicsWorldTests >> testSleepingRetainedContactsSkipVisualStateCapture [
	<gtExample>
	| world state solution |
	world := self newWorldAfterOneStep.
	world enableVisualState.
	world bodyStatesInOrder do: [ :body |
		body isStatic ifFalse: [ body sleep ] ].
	state := world capturePreparedState.
	solution := world stepPipeline solve: state.
	self assert: solution pipelineResult contactResult visualStateMayHaveChanged not.
	self assert: solution visualState isNil.
	^ solution
]

{ #category : 'tests - visual state' }
CFPhysicsWorldTests >> testSleepingRetainedContactsSkipVisualStateCaptureWithTelemetry [
	<gtExample>
	| world state solution |
	world := self newWorldAfterOneStep.
	world enableVisualState.
	world bodyStatesInOrder do: [ :body |
		body isStatic ifFalse: [ body sleep ] ].
	state := world capturePreparedState.
	solution := world stepPipeline solveWithTelemetry: state.
	self assert: solution pipelineResult contactResult visualStateMayHaveChanged not.
	self assert: solution visualState isNil.
	^ solution
]

{ #category : 'tests - visual state' }
CFPhysicsWorldTests >> testVisualStateRebuildsAfterSkippedSleepingCapture [
	<gtExample>
	| world movingBody sleepingState sleepingSolution changedState changedSolution |
	world := self newWorldAfterOneStep.
	world enableVisualState.
	movingBody := world bodyStatesInOrder detect: [ :body | body isStatic not ].
	movingBody sleep.
	sleepingState := world capturePreparedState.
	sleepingSolution := world stepPipeline solve: sleepingState.
	self assert: sleepingSolution visualState isNil.
	world commit: sleepingSolution.
	movingBody position: 20 @ 100.
	changedState := world capturePreparedState.
	changedSolution := world stepPipeline solve: changedState.
	self assert: changedSolution pipelineResult contactResult visualStateMayHaveChanged.
	self assert: changedSolution visualState notNil.
	world commit: changedSolution.
	self assert: world committedVisualState contacts isEmpty.
	^ world
]

