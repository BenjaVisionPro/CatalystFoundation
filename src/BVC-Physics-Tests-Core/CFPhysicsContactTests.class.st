Class {
	#name : 'CFPhysicsContactTests',
	#superclass : 'CFPhysicsContactTestCase',
	#category : 'BVC-Physics-Tests-Core',
	#package : 'BVC-Physics-Tests-Core'
}

{ #category : 'tests - contacts' }
CFPhysicsContactTests >> testContactFeatureIdentityIsStructural [
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
{ #category : 'tests - contacts' }
CFPhysicsContactTests >> testManifoldPreservesImpulsesByFeatureIdentity [
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
{ #category : 'tests - contacts' }
CFPhysicsContactTests >> testManifoldDoesNotUsePositionAsIdentity [
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
{ #category : 'tests - contacts' }
CFPhysicsContactTests >> testManifoldConsumesEachPreviousFeatureImpulseOnlyOnce [
	<gtExample>
	| featureId firstOldPoint secondOldPoint oldManifold firstNewPoint secondNewPoint newManifold |
	featureId := CFPhysicsContactFeatureId
		featureA: #face index: 0 featureB: #vertex index: 0.
	firstOldPoint := CFPhysicsManifoldPoint at: 10 @ 20.
	firstOldPoint
		featureId: featureId;
		normalImpulse: 7.5;
		tangentImpulse: -1.25.
	secondOldPoint := CFPhysicsManifoldPoint at: 20 @ 20.
	secondOldPoint
		featureId: featureId;
		normalImpulse: 4.0;
		tangentImpulse: 0.5.
	oldManifold := CFPhysicsManifold new
		contactPoints: { firstOldPoint. secondOldPoint };
		yourself.

	firstNewPoint := CFPhysicsManifoldPoint at: 11 @ 20.
	firstNewPoint featureId: featureId.
	secondNewPoint := CFPhysicsManifoldPoint at: 21 @ 20.
	secondNewPoint featureId: featureId.
	newManifold := CFPhysicsManifold new
		contactPoints: { firstNewPoint. secondNewPoint };
		preserveImpulsesFrom: oldManifold;
		yourself.

	self assert: firstNewPoint normalImpulse equals: 7.5.
	self assert: firstNewPoint tangentImpulse equals: -1.25.
	self assert: secondNewPoint normalImpulse equals: 0.0.
	self assert: secondNewPoint tangentImpulse equals: 0.0.
	^ newManifold
]
{ #category : 'tests - contact pipeline' }
CFPhysicsContactTests >> testContactPipelineOrdersPairsDeterministically [
	<gtExample>
	| first second third pairs |
	first := self newBodyWithSequence: 1.
	second := self newBodyWithSequence: 2.
	third := self newBodyWithSequence: 3.
	pairs := {
		CFPhysicsPair first: third second: first.
		CFPhysicsPair first: third second: second.
		CFPhysicsPair first: second second: first }
		sorted: [ :left :right | left comesBefore: right ].
	self assert: (pairs collect: [ :pair | { pair firstBody sequence. pair secondBody sequence } ])
		equals: { { 1. 2 }. { 1. 3 }. { 2. 3 } }.
	^ pairs
]
{ #category : 'tests - contact pipeline' }
CFPhysicsContactTests >> testContactPipelineReportsBeginContinueAndEnd [
	<gtExample>
	| first second pair manifold updater firstBatch secondBatch thirdBatch |
	first := self newBodyWithSequence: 1.
	second := self newBodyWithSequence: 2.
	pair := CFPhysicsPair first: first second: second.
	manifold := self newManifoldWithFeatureIndex: 1.
	updater := CFPhysicsContactUpdater manifoldGenerator: (CFPhysicsFixedManifoldGenerator manifold: manifold).
	firstBatch := updater updatePairs: { pair } fromContacts: #().
	self assert: firstBatch beganContacts size equals: 1.
	self assert: firstBatch continuedContacts isEmpty.
	self assert: firstBatch visualStateMayHaveChanged.
	secondBatch := updater updatePairs: { pair } fromContacts: firstBatch activeContacts.
	self assert: secondBatch beganContacts isEmpty.
	self assert: secondBatch continuedContacts size equals: 1.
	self assert: secondBatch visualStateMayHaveChanged.
	thirdBatch := updater updatePairs: #() fromContacts: secondBatch activeContacts.
	self assert: thirdBatch activeContacts isEmpty.
	self assert: thirdBatch endedContacts size equals: 1.
	self assert: thirdBatch visualStateMayHaveChanged.
	^ thirdBatch
]
{ #category : 'tests - contact pipeline' }
CFPhysicsContactTests >> testContactPipelinePersistsImpulsesByFeatureIdentity [
	<gtExample>
	| first second pair oldManifold newManifold updater initial next oldPoint newPoint |
	first := self newBodyWithSequence: 1.
	second := self newBodyWithSequence: 2.
	pair := CFPhysicsPair first: first second: second.
	oldManifold := self newManifoldWithFeatureIndex: 1.
	oldPoint := oldManifold contactPoints first.
	oldPoint
		normalImpulse: 7.0;
		tangentImpulse: 2.0;
		totalNormalImpulse: 9.0;
		normalVelocity: -4.0.
	updater := CFPhysicsContactUpdater manifoldGenerator: (CFPhysicsFixedManifoldGenerator manifold: oldManifold).
	initial := updater updatePairs: { pair } fromContacts: #().
	newManifold := self newManifoldWithFeatureIndex: 1.
	updater := CFPhysicsContactUpdater manifoldGenerator: (CFPhysicsFixedManifoldGenerator manifold: newManifold).
	next := updater updatePairs: { pair } fromContacts: initial activeContacts.
	newPoint := next activeContacts first manifold contactPoints first.
	self assert: newPoint normalImpulse equals: 7.0.
	self assert: newPoint tangentImpulse equals: 2.0.
	self assert: newPoint totalNormalImpulse equals: 0.0.
	self assert: newPoint normalVelocity equals: 0.0.
	^ next
]
{ #category : 'tests - contact pipeline' }
CFPhysicsContactTests >> testSensorContactClearsRetainedImpulses [
	<gtExample>
	| first second pair oldManifold newManifold updater initial next point |
	first := self newBodyWithSequence: 1.
	second := self newBodyWithSequence: 2.
	pair := CFPhysicsPair first: first second: second.
	oldManifold := self newManifoldWithFeatureIndex: 1.
	oldManifold contactPoints first
		normalImpulse: 7.0;
		tangentImpulse: 2.0;
		totalNormalImpulse: 9.0;
		normalVelocity: -4.0.
	updater := CFPhysicsContactUpdater manifoldGenerator: (CFPhysicsFixedManifoldGenerator manifold: oldManifold).
	initial := updater updatePairs: { pair } fromContacts: #().

	second beSensor.
	newManifold := self newManifoldWithFeatureIndex: 1.
	updater := CFPhysicsContactUpdater manifoldGenerator: (CFPhysicsFixedManifoldGenerator manifold: newManifold).
	next := updater updatePairs: { pair } fromContacts: initial activeContacts.
	point := next activeContacts first manifold contactPoints first.

	self assert: point normalImpulse equals: 0.0.
	self assert: point tangentImpulse equals: 0.0.
	self assert: point totalNormalImpulse equals: 0.0.
	self assert: point normalVelocity equals: 0.0.
	^ next
]
{ #category : 'tests - contact pipeline' }
CFPhysicsContactTests >> testSleepingTouchingContactRetainsItsPersistentStateWithoutNarrowPhase [
	<gtExample>
	| first second pair manifold previous calculation updater bodyStates batch retained |
	first := self newBodyWithSequence: 1.
	second := self newBodyWithSequence: 2.
	pair := CFPhysicsPair first: first second: second.
	manifold := self newManifoldWithFeatureIndex: 1.
	previous := CFPhysicsContact pair: pair manifold: manifold.
	calculation := previous copyForUpdate.
	first sleep.
	second sleep.
	bodyStates := IdentityDictionary new
		at: first put: (CFPhysicsBodyStepState on: first);
		at: second put: (CFPhysicsBodyStepState on: second);
		yourself.
	updater := CFPhysicsContactUpdater
		manifoldGenerator: (CFPhysicsFixedManifoldGenerator manifold: nil).
	batch := updater
		updatePairs: { pair }
		includingImpactContacts: #()
		fromContacts: { previous }
		reusingContacts: { calculation }
		bodyStates: bodyStates
		speculativeDistance: 0.0.
	retained := batch contacts first.
	self assert: retained == calculation.
	self assert: retained manifold == manifold.
	self assert: batch touchingContacts equals: { retained }.
	self assert: batch continuedContacts equals: { retained }.
	self assert: batch beganContacts isEmpty.
	self assert: batch endedContacts isEmpty.
	self assert: updater bothSleepingPairCount equals: 1.
	self assert: updater manifoldGenerationCount equals: 0.
	self assert: batch visualStateMayHaveChanged not.
	^ retained
]
{ #category : 'tests - contact pipeline' }
CFPhysicsContactTests >> testSleepingContactRefreshesLaggedReusableContactFromPreviousTouchingState [
	<gtExample>
	| first second pair manifold previous calculation updater bodyStates batch retained |
	first := self newBodyWithSequence: 1.
	second := self newBodyWithSequence: 2.
	pair := CFPhysicsPair first: first second: second.
	manifold := self newManifoldWithFeatureIndex: 1.
	previous := CFPhysicsContact pair: pair manifold: manifold.
	calculation := CFPhysicsContact pair: pair manifold: nil.
	first sleep.
	second sleep.
	bodyStates := IdentityDictionary new
		at: first put: (CFPhysicsBodyStepState on: first);
		at: second put: (CFPhysicsBodyStepState on: second);
		yourself.
	updater := CFPhysicsContactUpdater
		manifoldGenerator: (CFPhysicsFixedManifoldGenerator manifold: nil).
	batch := updater
		updatePairs: { pair }
		includingImpactContacts: #()
		fromContacts: { previous }
		reusingContacts: { calculation }
		bodyStates: bodyStates
		speculativeDistance: 0.0.
	retained := batch contacts first.
	self assert: retained == calculation.
	self assert: retained manifold == manifold.
	self assert: retained previousManifold == manifold.
	self assert: retained continued.
	self assert: batch touchingContacts equals: { retained }.
	self assert: batch continuedContacts equals: { retained }.
	self assert: batch endedContacts isEmpty.
	^ retained
]

{ #category : 'tests - contact pipeline' }
CFPhysicsContactTests >> testSleepingSensorContactStillRunsNarrowPhase [
	<gtExample>
	| first second pair previousManifold nextManifold previous updater bodyStates batch |
	first := self newBodyWithSequence: 1.
	second := self newBodyWithSequence: 2.
	second beSensor.
	pair := CFPhysicsPair first: first second: second.
	previousManifold := self newManifoldWithFeatureIndex: 1.
	nextManifold := self newManifoldWithFeatureIndex: 2.
	previous := CFPhysicsContact pair: pair manifold: previousManifold.
	first sleep.
	second sleep.
	bodyStates := IdentityDictionary new
		at: first put: (CFPhysicsBodyStepState on: first);
		at: second put: (CFPhysicsBodyStepState on: second);
		yourself.
	updater := CFPhysicsContactUpdater
		manifoldGenerator: (CFPhysicsFixedManifoldGenerator manifold: nextManifold).
	batch := updater
		updatePairs: { pair }
		includingImpactContacts: #()
		fromContacts: { previous }
		reusingContacts: #()
		bodyStates: bodyStates
		speculativeDistance: 0.0.
	self assert: updater bothSleepingPairCount equals: 1.
	self assert: updater manifoldGenerationCount equals: 1.
	self assert: batch contacts first manifold == nextManifold.
	^ batch contacts first
]
{ #category : 'tests - contact pipeline' }
CFPhysicsContactTests >> testWakingEndpointReturnsSleepingContactToNarrowPhase [
	<gtExample>
	| first second pair previousManifold nextManifold previous calculation updater bodyStates batch updated |
	first := self newBodyWithSequence: 1.
	second := self newBodyWithSequence: 2.
	pair := CFPhysicsPair first: first second: second.
	previousManifold := self newManifoldWithFeatureIndex: 1.
	nextManifold := self newManifoldWithFeatureIndex: 2.
	previous := CFPhysicsContact pair: pair manifold: previousManifold.
	calculation := previous copyForUpdate.
	second sleep.
	bodyStates := IdentityDictionary new
		at: first put: (CFPhysicsBodyStepState on: first);
		at: second put: (CFPhysicsBodyStepState on: second);
		yourself.
	updater := CFPhysicsContactUpdater
		manifoldGenerator: (CFPhysicsFixedManifoldGenerator manifold: nextManifold).
	batch := updater
		updatePairs: { pair }
		includingImpactContacts: #()
		fromContacts: { previous }
		reusingContacts: { calculation }
		bodyStates: bodyStates
		speculativeDistance: 0.0.
	updated := batch contacts first.
	self assert: updated manifold == nextManifold.
	self assert: updater bothSleepingPairCount equals: 0.
	self assert: updater manifoldGenerationCount equals: 1.
	^ updated
]
{ #category : 'tests - contact events' }
CFPhysicsContactTests >> testContactEventStagePublishesLifecycleEvents [
	<gtExample>
	| first second pair manifold beganContact endedContact batch result events |
	first := self newBodyWithSequence: 1.
	second := self newBodyWithSequence: 2.
	pair := CFPhysicsPair first: first second: second.
	manifold := self newManifoldWithFeatureIndex: 1.
	beganContact := CFPhysicsContact pair: pair manifold: manifold.
	endedContact := beganContact copyForUpdate.
	endedContact updateWith: nil.
	batch := CFPhysicsContactUpdateBatch
		contacts: { beganContact }
		touching: { beganContact }
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
{ #category : 'tests - contact events' }
CFPhysicsContactTests >> testContinuedContactsDoNotPublishLifecycleEvents [
	<gtExample>
	| first second pair contact batch result events |
	first := self newBodyWithSequence: 1.
	second := self newBodyWithSequence: 2.
	pair := CFPhysicsPair first: first second: second.
	contact := CFPhysicsContact pair: pair manifold: (self newManifoldWithFeatureIndex: 1).
	contact := contact copyForUpdate
		updateWith: (self newManifoldWithFeatureIndex: 1);
		yourself.
	batch := CFPhysicsContactUpdateBatch
		contacts: { contact }
		touching: { contact }
		began: #()
		continued: { contact }
		ended: #().
	result := CFPhysicsContactUpdateResult pairs: { pair } contactBatch: batch.
	events := CFPhysicsContactEventBuilder new eventsFrom: result.
	self assert: events isEmpty.
	^ events
]
{ #category : 'tests - contact events' }
CFPhysicsContactTests >> testStepPipelineExposesContactEvents [
	<gtExample>
	| result |
	result := self newComposedStepResult.
	self assert: result contactEvents size equals: result beganContacts size + result endedContacts size.
	self assert: result contactBeganEvents size equals: result beganContacts size.
	self assert: result contactEndedEvents size equals: result endedContacts size.
	^ result contactEvents
]
{ #category : 'tests - post solve' }
CFPhysicsContactTests >> testPostSolveCollectorCapturesSolvedImpulses [
	<gtExample>
	| result solveResult pointResult constraint |
	result := self newComposedStepResult.
	self assert: result contactSolveResults size equals: result contactConstraints size.
	solveResult := result contactSolveResults first.
	constraint := result contactConstraints first.
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
{ #category : 'tests - post solve' }
CFPhysicsContactTests >> testHitEventsAreDerivedAfterSolving [
	<gtExample>
	| result stage |
	stage := CFPhysicsPostSolveStage new.
	stage hitEventThreshold: 0.0.
	result := self newComposedStepResult.
	stage executeOn: result.
	self assert: (result hitEvents allSatisfy: [ :event |
		event normalImpulse > 0.0 and: [ event approachSpeed > 0.0 ] ]).
	self assert: (result hitEvents allSatisfy: [ :event |
		result activeContacts includes: event contact ]).
	^ result hitEvents
]
{ #category : 'tests - post solve' }
CFPhysicsContactTests >> testHitEventThresholdSuppressesSmallApproaches [
	<gtExample>
	| result stage |
	result := self newComposedStepResult.
	stage := CFPhysicsPostSolveStage new.
	stage hitEventThreshold: 1.0e100.
	stage executeOn: result.
	self assert: result hitEvents isEmpty.
	^ result hitEvents
]
{ #category : 'tests - post solve' }
CFPhysicsContactTests >> testStepPipelineExposesPostSolveStage [
	<gtExample>
	| result execution |
	result := self newComposedStepResult.
	execution := result executionForStageType: CFPhysicsPostSolveStage.
	self assert: execution notNil.
	self assert: execution output contactResults equals: result contactSolveResults.
	self assert: execution output hitEvents equals: result hitEvents.
	^ execution
]
{ #category : 'tests - sensors' }
CFPhysicsContactTests >> testSensorContactParticipatesInLifecycleButNotSolving [
	<gtExample>
	| result |
	result := self newSensorContactStepResult.
	self assert: result activeContacts size equals: 1.
	self assert: result activeContacts first isSensor.
	self assert: result beganContacts size equals: 1.
	self assert: result solverConstraints isEmpty.
	self assert: result contactSolveResults isEmpty.
	self assert: result hitEvents isEmpty.
	self assert: result contactBeganEvents size equals: 1.
	self assert: result contactBeganEvents first isSensor.
	^ result
]
{ #category : 'tests - sensors' }
CFPhysicsContactTests >> testSensorContactDoesNotJoinDynamicBodiesIntoOneIsland [
	<gtExample>
	| first second sensor step pipeline result dynamicIslands |
	first := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self newBodyWithSequence: 2 position: 30 @ 0 extent: 20 @ 20.
	sensor := self newBodyWithSequence: 3 position: 0 @ 0 extent: 50 @ 20.
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
	self assert: result solverConstraints isEmpty.
	self assert: dynamicIslands size equals: 2.
	self assert: (dynamicIslands allSatisfy: [ :island |
		(island bodies select: [ :body | body isDynamic ]) size = 1 ]).
	^ result
]
{ #category : 'tests - sensors' }
CFPhysicsContactTests >> testSensorContactPublishesEndedEventWithoutSolveData [
	<gtExample>
	| firstResult sensor ground secondResult step pipeline |
	firstResult := self newSensorContactStepResult.
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
{ #category : 'tests - contacts' }
CFPhysicsContactTests >> testManifoldPreservesImpulsesByFeatureIdentityWhenNormalChanges [
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

	self assert: newPoint normalImpulse equals: 7.5.
	self assert: newPoint tangentImpulse equals: -1.25.
	^ newManifold
]
{ #category : 'tests - contacts' }
CFPhysicsContactTests >> testContactUpdateStageUsesCapturedTransformsForManifolds [
	<gtExample>
	| first second result stage contacts step |
	first := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self newBodyWithSequence: 2 position: 15 @ 0 extent: 20 @ 20.
	step := CFPhysicsStep
		timeStep: 0.016
		substeps: 4
		contactHertz: 30.0
		dampingRatio: 10.0.
	step speculativeDistance: 0.0.
	result := CFPhysicsStepPipelineResult new
		step: step;
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
{ #category : 'tests - contacts' }
CFPhysicsContactTests >> testContactUpdateStageUsesCapturedSensorClassification [
	<gtExample>
	| first second result stage contacts step |
	first := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self newBodyWithSequence: 2 position: 15 @ 0 extent: 20 @ 20.
	first beSensor.
	step := CFPhysicsStep
		timeStep: 0.016
		substeps: 4
		contactHertz: 30.0
		dampingRatio: 10.0.
	step speculativeDistance: 0.0.
	result := CFPhysicsStepPipelineResult new
		step: step;
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
{ #category : 'tests - sensors' }
CFPhysicsContactTests >> testRuntimeSensorChangeUnlinksAContinuedContactFromItsPersistentIsland [
	<gtExample>
	| owner first second world firstBody secondBody firstResult firstContact secondResult |
	owner := BlElement new size: 200 @ 200; yourself.
	first := BlElement new size: 20 @ 20; yourself.
	second := BlElement new size: 20 @ 20; yourself.
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
	firstContact := firstResult activeContacts first.
	self assert: (world persistentIslandGraph islandForConstraint: firstContact) notNil.
	firstBody sleep.
	secondBody sleep.
	firstBody beSensor.
	self assert: firstBody isAwake.
	self assert: secondBody isAwake.
	secondResult := world step.
	self assert: secondResult continuedContacts size equals: 1.
	self assert: secondResult continuedContacts first isSensor.
	self assert: (world persistentIslandGraph islandForConstraint: firstContact) isNil.
	self assert: (world persistentIslandGraph islandForConstraint: secondResult continuedContacts first) isNil.
	^ secondResult
]
{ #category : 'tests - sensors' }
CFPhysicsContactTests >> testRuntimeSolidChangeLinksAContinuedContactIntoThePersistentIsland [
	<gtExample>
	| owner first second world firstBody secondBody firstResult secondResult contact |
	owner := BlElement new size: 200 @ 200; yourself.
	first := BlElement new size: 20 @ 20; yourself.
	second := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { first. second }.
	world := owner physics beWorld.
	world containment disable.
	world gravity: 0 @ 0.
	world owner physics makeChildrenDynamic.
	firstBody := world bodyStateFor: first.
	secondBody := world bodyStateFor: second.
	firstBody position: 0 @ 0; beSensor.
	secondBody position: 10 @ 0.
	firstResult := world step.
	self assert: firstResult activeContacts size equals: 1.
	self assert: firstResult activeContacts first isSensor.
	self assert: (world persistentIslandGraph islandForConstraint: firstResult activeContacts first) isNil.
	firstBody sleep.
	secondBody sleep.
	firstBody beSolid.
	self assert: firstBody isAwake.
	self assert: secondBody isAwake.
	secondResult := world step.
	self assert: secondResult continuedContacts size equals: 1.
	contact := secondResult continuedContacts first.
	self assert: contact isSolid.
	self assert: (world persistentIslandGraph islandForConstraint: contact) notNil.
	^ secondResult
]
{ #category : 'tests - contact solver' }
CFPhysicsContactTests >> testContactPushSpeedDefaultsAndPropagatesIntoStep [
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
{ #category : 'tests - contact solver' }
CFPhysicsContactTests >> testWorldScaleConvertsMutableConfigurationWhenStateIsCaptured [
	<gtExample>
	| owner world state |
	owner := BlElement new size: 200 @ 200; yourself.
	world := owner physics beWorld.
	world
		lengthUnitsPerMetre: 200.0;
		gravity: 0 @ 5.0;
		restitutionThreshold: 2.0;
		hitEventThreshold: 1.5.
	world owner physics makeChildrenDynamic.
	state := world capturePreparedState.
	self assert: (world gravity closeTo: 0 @ 5.0).
	self assert: (world restitutionThreshold closeTo: 2.0).
	self assert: (world hitEventThreshold closeTo: 1.5).
	self assert: (state gravity closeTo: 0 @ 1000.0).
	self assert: (state restitutionThreshold closeTo: 400.0).
	self assert: (state step hitEventThreshold closeTo: 300.0).
	^ state
]
{ #category : 'tests - post solve' }
CFPhysicsContactTests >> testHitEventsUseConfirmedImpulseRatherThanWarmStartedImpulse [
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
{ #category : 'tests - post solve' }
CFPhysicsContactTests >> testHitEventsChooseFastestPointPerContact [
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
{ #category : 'tests - contact pipeline' }
CFPhysicsContactTests >> testBroadphasePairRetainsNonTouchingContact [
	<gtExample>
	| first second pair touchingUpdater nonTouchingUpdater touchingBatch nonTouchingBatch |
	first := self newBodyWithSequence: 1.
	second := self newBodyWithSequence: 2.
	pair := CFPhysicsPair first: first second: second.
	touchingUpdater := CFPhysicsContactUpdater manifoldGenerator: (CFPhysicsFixedManifoldGenerator manifold: (self newManifoldWithFeatureIndex: 1)).
	touchingBatch := touchingUpdater updatePairs: { pair } fromContacts: #().
	nonTouchingUpdater := CFPhysicsContactUpdater manifoldGenerator: (CFPhysicsFixedManifoldGenerator manifold: nil).
	nonTouchingBatch := nonTouchingUpdater updatePairs: { pair } fromContacts: touchingBatch contacts.
	self assert: nonTouchingBatch contacts size equals: 1.
	self assert: nonTouchingBatch activeContacts isEmpty.
	self assert: nonTouchingBatch endedContacts size equals: 1.
	self assert: nonTouchingBatch contacts first isTouching not.
	self assert: nonTouchingBatch contacts first key equals: pair key.
	^ nonTouchingBatch
]
{ #category : 'tests - contact pipeline' }
CFPhysicsContactTests >> testNonTouchingContactBeginsAgainWithoutPairRecreation [
	<gtExample>
	| first second pair touchingUpdater nonTouchingUpdater firstBatch secondBatch thirdBatch |
	first := self newBodyWithSequence: 1.
	second := self newBodyWithSequence: 2.
	pair := CFPhysicsPair first: first second: second.
	touchingUpdater := CFPhysicsContactUpdater manifoldGenerator: (CFPhysicsFixedManifoldGenerator manifold: (self newManifoldWithFeatureIndex: 1)).
	nonTouchingUpdater := CFPhysicsContactUpdater manifoldGenerator: (CFPhysicsFixedManifoldGenerator manifold: nil).
	firstBatch := touchingUpdater updatePairs: { pair } fromContacts: #().
	secondBatch := nonTouchingUpdater updatePairs: { pair } fromContacts: firstBatch contacts.
	thirdBatch := touchingUpdater updatePairs: { pair } fromContacts: secondBatch contacts.
	self assert: thirdBatch contacts size equals: 1.
	self assert: thirdBatch activeContacts size equals: 1.
	self assert: thirdBatch beganContacts size equals: 1.
	self assert: thirdBatch endedContacts isEmpty.
	self assert: thirdBatch contacts first key equals: pair key.
	^ thirdBatch
]
{ #category : 'tests - contact pipeline' }
CFPhysicsContactTests >> testRemovedBroadphasePairDoesNotRetainDestroyedContact [
	<gtExample>
	| first second pair updater firstBatch removedBatch |
	first := self newBodyWithSequence: 1.
	second := self newBodyWithSequence: 2.
	pair := CFPhysicsPair first: first second: second.
	updater := CFPhysicsContactUpdater manifoldGenerator: (CFPhysicsFixedManifoldGenerator manifold: (self newManifoldWithFeatureIndex: 1)).
	firstBatch := updater updatePairs: { pair } fromContacts: #().
	removedBatch := updater updatePairs: #() fromContacts: firstBatch contacts.
	self assert: removedBatch contacts isEmpty.
	self assert: removedBatch activeContacts isEmpty.
	self assert: removedBatch endedContacts size equals: 1.
	^ removedBatch
]
{ #category : 'tests - contact pipeline' }
CFPhysicsContactTests >> testSpeculativeDistanceFlowsThroughTheContactPipeline [
	<gtExample>
	| first second step pipeline result |
	first := self newBodyWithSequence: 1 position: 0 @ 0 extent: 30 @ 30.
	second := self newBodyWithSequence: 2 position: 31 @ 0 extent: 30 @ 30.
	first element geometry: BlCircleGeometry new.
	second element geometry: BlCircleGeometry new.
	step := CFPhysicsStep
		timeStep: 0.016
		substeps: 4
		contactHertz: 30.0
		dampingRatio: 10.0.
	step speculativeDistance: 2.0.
	pipeline := CFPhysicsStepPipeline manifoldGenerator: CFPhysicsManifoldGenerator new.
	result := pipeline
		stepBodies: { first. second }
		fromContacts: #()
		step: step
		gravity: 0 @ 0
		restitutionThreshold: 1.0.
	self assert: result activeContacts size equals: 1.
	self assert: (result activeContacts first manifold contactPoints first separation closeTo: 1.0).
	^ result
]

{ #category : 'tests - contact pipeline' }
CFPhysicsContactTests >> testNonTouchingRecomputationDoesNotDirtyContactVisualState [
	<gtExample>
	| first second pair updater batch |
	first := self newBodyWithSequence: 1.
	second := self newBodyWithSequence: 2.
	pair := CFPhysicsPair first: first second: second.
	updater := CFPhysicsContactUpdater
		manifoldGenerator: (CFPhysicsFixedManifoldGenerator manifold: nil).
	batch := updater updatePairs: { pair } fromContacts: #().
	self assert: batch contacts size equals: 1.
	self assert: batch touchingContacts isEmpty.
	self assert: batch endedContacts isEmpty.
	self assert: batch visualStateMayHaveChanged not.
	^ batch
]

