Class {
	#name : 'CFPhysicsIslandTests',
	#superclass : 'CFPhysicsIslandTestCase',
	#category : 'BVC-Physics-Tests-Core',
	#package : 'BVC-Physics-Tests-Core'
}

{ #category : 'tests - islands' }
CFPhysicsIslandTests >> testIslandBuilderSeparatesDisconnectedDynamicGroups [
	<gtExample>
	| first second third fourth constraints islands |
	first := self newBodyWithSequence: 1.
	second := self newBodyWithSequence: 2.
	third := self newBodyWithSequence: 3.
	fourth := self newBodyWithSequence: 4.
	constraints := {
		self newConstraintBetween: first and: second.
		self newConstraintBetween: third and: fourth }.
	islands := CFPhysicsIslandBuilder new
		islandsFromPersistentBodyGroups: { { first }. { second }. { third }. { fourth } }
		bodies: { fourth. second. third. first }
		constraints: constraints.
	self assert: islands size equals: 2.
	self assert: (islands first dynamicBodies collect: #sequence) equals: #(1 2).
	self assert: (islands second dynamicBodies collect: #sequence) equals: #(3 4).
	self assert: islands first constraints size equals: 1.
	self assert: islands second constraints size equals: 1.
	^ islands
]
{ #category : 'tests - islands' }
CFPhysicsIslandTests >> testStaticBodyDoesNotBridgeDynamicIslands [
	<gtExample>
	| first ground second constraints islands |
	first := self newBodyWithSequence: 1.
	ground := self newBodyWithSequence: 2.
	ground beStatic.
	second := self newBodyWithSequence: 3.
	constraints := {
		self newConstraintBetween: first and: ground.
		self newConstraintBetween: ground and: second }.
	islands := CFPhysicsIslandBuilder new
		islandsFromPersistentBodyGroups: { { first }. { second } }
		bodies: { second. ground. first }
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
{ #category : 'tests - islands' }
CFPhysicsIslandTests >> testStepPipelineSolvesExplicitIslands [
	<gtExample>
	| result |
	result := self newComposedStepResult.
	self assert: result islands size equals: 1.
	self assert: result islands first constraints equals: result solverConstraints.
	self assert: result solver islands equals: result islands.
	self assert: result solver softStepSolvers size equals: result islands size.
	^ result
]
{ #category : 'tests - island sleeping' }
CFPhysicsIslandTests >> testAwakeKinematicBodyDoesNotWakeConnectedSleepingDynamicBody [
	<gtExample>
	| kinematic dynamic island stage bodyStates decision |
	kinematic := self newBodyWithSequence: 1.
	kinematic beKinematic.
	dynamic := self newBodyWithSequence: 2.
	dynamic sleep.
	island := CFPhysicsIsland new
		addBody: kinematic;
		addBody: dynamic;
		yourself.
	bodyStates := IdentityDictionary new
		at: kinematic put: (CFPhysicsBodyStepState on: kinematic);
		at: dynamic put: (CFPhysicsBodyStepState on: dynamic);
		yourself.
	stage := CFPhysicsIslandSleepStage new.
	stage propagateWakeAcross: { island } bodyStates: bodyStates.
	decision := (stage
		updateIslands: { island }
		bodyStates: bodyStates
		elapsed: 0.0) first.
	self assert: (bodyStates at: dynamic) isAwake not.
	self assert: decision wokeBodies isEmpty.
	^ decision
]
{ #category : 'tests - island sleeping' }
CFPhysicsIslandTests >> testIslandWakePropagatesAcrossConnectedDynamicBodies [
	<gtExample>
	| first second island stage decisions |
	first := self newBodyWithSequence: 1.
	second := self newBodyWithSequence: 2.
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
{ #category : 'tests - island sleeping' }
CFPhysicsIslandTests >> testIslandSleepsAsOneDecision [
	<gtExample>
	| first second island stage configuration bodyStates firstDecision secondDecision |
	first := self newBodyWithSequence: 1.
	second := self newBodyWithSequence: 2.
	island := CFPhysicsIsland new
		addBody: first;
		addBody: second;
		yourself.
	configuration := CFPhysicsSleepConfiguration standard
		timeToSleep: 0.02;
		yourself.
	stage := CFPhysicsIslandSleepStage new configuration: configuration; yourself.
	bodyStates := IdentityDictionary new
		at: first put: (CFPhysicsBodyStepState on: first);
		at: second put: (CFPhysicsBodyStepState on: second);
		yourself.
	stage propagateWakeAcross: { island }.
	firstDecision := (stage updateIslands: { island } bodyStates: bodyStates elapsed: 0.01) first.
	self assert: firstDecision eligible not.
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
{ #category : 'tests - island sleeping' }
CFPhysicsIslandTests >> testMovingMemberKeepsTheWholeIslandAwakeWithoutResettingSleepyMembers [
	<gtExample>
	| first second island stage bodyStates decision |
	first := self newBodyWithSequence: 1.
	second := self newBodyWithSequence: 2.
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
	self assert: ((bodyStates at: first) sleepTime closeTo: 0.266).
	self assert: (bodyStates at: second) sleepTime equals: 0.0.
	self assert: first sleepTime equals: 0.25.
	self assert: second sleepTime equals: 0.0.
	(bodyStates at: first) commit.
	(bodyStates at: second) commit.
	self assert: (first sleepTime closeTo: 0.266).
	self assert: second sleepTime equals: 0.0.
	^ decision
]
{ #category : 'tests - island sleeping' }
CFPhysicsIslandTests >> testPositionCorrectionKeepsAnIslandAwake [
	<gtExample>
	| body island stage configuration state decision |
	body := self newBodyWithSequence: 1.
	island := CFPhysicsIsland new addBody: body; yourself.
	configuration := CFPhysicsSleepConfiguration standard
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
{ #category : 'tests - island sleeping' }
CFPhysicsIslandTests >> testSmallPositionCorrectionMayAccumulateSleepTime [
	<gtExample>
	| body island stage configuration state decision |
	body := self newBodyWithSequence: 1.
	island := CFPhysicsIsland new addBody: body; yourself.
	configuration := CFPhysicsSleepConfiguration standard
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
	self assert: decision eligible not.
	self assert: decision slept not.
	self assert: (state sleepTime closeTo: 0.02).
	self assert: body sleepTime equals: 0.0.
	state commit.
	self assert: (body sleepTime closeTo: 0.02).
	^ decision
]
{ #category : 'tests - island sleeping' }
CFPhysicsIslandTests >> testSleepVelocityIncludesBodyExtent [
	<gtExample>
	| smallBody largeBody smallState largeState smallExtentVelocity largeExtentVelocity |
	smallBody := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	largeBody := self newBodyWithSequence: 2 position: 0 @ 0 extent: 200 @ 200.
	smallState := CFPhysicsBodyStepState on: smallBody.
	largeState := CFPhysicsBodyStepState on: largeBody.
	smallState angularVelocity: 1.0.
	largeState angularVelocity: 1.0.
	smallExtentVelocity := smallState
		sleepVelocityForElapsed: 0.02
		positionCorrectionFactor: 0.5.
	largeExtentVelocity := largeState
		sleepVelocityForElapsed: 0.02
		positionCorrectionFactor: 0.5.
	self assert: largeExtentVelocity > smallExtentVelocity.
	^ largeExtentVelocity
]
{ #category : 'tests - island sleeping' }
CFPhysicsIslandTests >> testSleepVelocityUsesBox2DPositionCorrectionFormula [
	<gtExample>
	| body state expected actual |
	body := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	state := CFPhysicsBodyStepState on: body.
	state translateBy: 0.02 @ 0.
	expected := 0.5 * 0.02 / 0.02.
	actual := state
		sleepVelocityForElapsed: 0.02
		positionCorrectionFactor: 0.5.
	self assert: (actual closeTo: expected).
	^ actual
]
{ #category : 'tests - island sleeping' }
CFPhysicsIslandTests >> testBodySleepThresholdUsesWorldScale [
	<gtExample>
	| world body state |
	world := self newWorldAfterOneStep.
	world lengthUnitsPerMetre: 200.0.
	body := self newBodyWithSequence: 1.
	body world: world.
	body sleepThreshold: 0.05.
	state := CFPhysicsBodyStepState on: body.
	self assert: (state sleepThreshold closeTo: 10.0).
	^ state
]
{ #category : 'tests - island sleeping' }
CFPhysicsIslandTests >> testEndingAContactDoesNotWakeBodies [
	<gtExample>
	| first second pair manifold previousContact batch bodyStates result |
	first := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self newBodyWithSequence: 2 position: 10 @ 0 extent: 20 @ 20.
	pair := CFPhysicsPair first: first second: second.
	manifold := self newManifoldWithFeatureIndex: 1.
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
	result := batch endedContacts first.
	self assert: result ended.
	self assert: (bodyStates at: first) isAwake not.
	self assert: (bodyStates at: second) isAwake not.
	^ result
]
{ #category : 'tests - island sleeping' }
CFPhysicsIslandTests >> testBodyMayOptOutOfSleeping [
	<gtExample>
	| body |
	body := self newBodyWithSequence: 1.
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
{ #category : 'tests - island sleeping' }
CFPhysicsIslandTests >> testImpulseWakesSleepingBody [
	<gtExample>
	| body |
	body := self newBodyWithSequence: 1.
	body sleep.
	body applyImpulse: 10 @ 0 atWorldPoint: body worldBodyOrigin.
	self assert: body isAwake.
	self assert: body velocity equals: 10 @ 0 * body inverseMass.
	^ body
]
{ #category : 'tests - island sleeping' }
CFPhysicsIslandTests >> testBodyThatPreventsSleepingKeepsItsIslandAwake [
	<gtExample>
	| first second island stage configuration bodyStates decision |
	first := self newBodyWithSequence: 1.
	second := self newBodyWithSequence: 2.
	second preventSleeping.
	island := CFPhysicsIsland new
		addBody: first;
		addBody: second;
		yourself.
	configuration := CFPhysicsSleepConfiguration standard
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
{ #category : 'tests - island sleeping' }
CFPhysicsIslandTests >> testStepPipelineExposesIslandSleepDecisions [
	<gtExample>
	| result |
	result := self newComposedStepResult.
	self assert: result sleepDecisions size equals: result islands size.
	self assert: result sleepDecisions first island == result islands first.
	^ result sleepDecisions
]
{ #category : 'tests - constraint graph' }
CFPhysicsIslandTests >> testMixedJointConstraintsKeepTheWorldOrdering [
	<gtExample>
	| owner element world bodyAnchor revoluteAnchor distanceAnchor revolute distance result |
	owner := BlElement new size: 400 @ 300; yourself.
	element := BlElement new size: 20 @ 20; yourself.
	owner addChild: element.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world owner physics makeChildrenDynamic.
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
{ #category : 'tests - constraint graph' }
CFPhysicsIslandTests >> testConstraintColorerSeparatesSharedDynamicBodies [
	<gtExample>
	| static first second staticState firstState secondState firstConstraint secondConstraint thirdConstraint colors |
	static := self newBodyWithSequence: 1.
	static beStatic.
	first := self newBodyWithSequence: 2.
	second := self newBodyWithSequence: 3.
	staticState := CFPhysicsBodyStepState on: static.
	firstState := CFPhysicsBodyStepState on: first.
	secondState := CFPhysicsBodyStepState on: second.
	firstConstraint := CFPhysicsPreparedConstraint new
		bodyStateA: staticState;
		bodyStateB: firstState;
		yourself.
	secondConstraint := CFPhysicsPreparedConstraint new
		bodyStateA: staticState;
		bodyStateB: firstState;
		yourself.
	thirdConstraint := CFPhysicsPreparedConstraint new
		bodyStateA: firstState;
		bodyStateB: secondState;
		yourself.
	colors := CFPhysicsConstraintColorer
		colorsFor: { firstConstraint. secondConstraint. thirdConstraint }.
	self assert: colors size equals: 12.
	self assert: (colors at: 1) equals: { thirdConstraint }.
	self assert: (colors at: 2) equals: { firstConstraint }.
	self assert: (colors at: 3) equals: { secondConstraint }.
	^ colors
]
{ #category : 'tests - constraint graph' }
CFPhysicsIslandTests >> testRetiringABodyRetiresAllOfItsJointTypes [
	<gtExample>
	| owner first second third fourth world revolute fixed motor filter unrelated |
	owner := BlElement new size: 400 @ 300; yourself.
	first := BlElement new size: 20 @ 20; yourself.
	second := BlElement new size: 20 @ 20; yourself.
	third := BlElement new size: 20 @ 20; yourself.
	fourth := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { first. second. third. fourth }.
	world := owner physics beWorld.
	world owner physics makeChildrenDynamic.
	revolute := first physics revoluteJointTo: second.
	fixed := first physics weldJointTo: third.
	motor := first physics motorJointTo: fourth.
	filter := first physics filterJointTo: second.
	unrelated := second physics distanceJointTo: fourth.
	owner removeChild: first.
	self assert: world revoluteJoints isEmpty.
	self assert: world weldJoints isEmpty.
	self assert: world motorJoints isEmpty.
	self assert: world filterJoints isEmpty.
	self assert: world distanceJoints equals: { unrelated }.
	self assert: revolute isActive not.
	self assert: fixed isActive not.
	self assert: motor isActive not.
	self assert: filter isActive not.
	self assert: unrelated isActive.
	^ world
]
{ #category : 'tests - constraint graph' }
CFPhysicsIslandTests >> testRetiringAContactingBodyUnlinksItsContactFromThePersistentIslandGraph [
	<gtExample>
	| owner first second world result contact graph island retiredBody |
	owner := BlElement new size: 400 @ 300; yourself.
	first := BlElement new size: 20 @ 20; yourself.
	second := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { first. second }.
	world := owner physics beWorld.
	world containment disable.
	world gravity: 0 @ 0.
	world owner physics makeChildrenDynamic.
	first physics position: 100 @ 100.
	second physics position: 110 @ 100.
	result := world step.
	self assert: result activeContacts size equals: 1.
	contact := result activeContacts first.
	graph := world persistentIslandGraph.
	island := graph islandForConstraint: contact.
	self assert: island notNil.
	self assert: (island constraints includes: contact).
	retiredBody := second physics body.
	owner removeChild: second.
	self assert: (graph islandForConstraint: contact) isNil.
	self assert: (graph islandForBody: retiredBody) isNil.
	self assert: (island constraints includes: contact) not.
	^ world
]
{ #category : 'tests - island sleeping' }
CFPhysicsIslandTests >> testIslandWakeUpdatesCapturedBodyState [
	<gtExample>
	| first second island stage bodyStates |
	first := self newBodyWithSequence: 1.
	second := self newBodyWithSequence: 2.
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
{ #category : 'tests - islands' }
CFPhysicsIslandTests >> testPersistentIslandGraphLinksAndMergesLikeBox2D [
	<gtExample>
	| first second third firstConstraint secondConstraint graph islands |
	first := self newBodyWithSequence: 1.
	second := self newBodyWithSequence: 2.
	third := self newBodyWithSequence: 3.
	firstConstraint := CFPhysicsDistanceJoint between: first and: second.
	secondConstraint := CFPhysicsDistanceJoint between: second and: third.
	graph := CFPhysicsPersistentIslandGraph new.
	graph
		linkConstraint: firstConstraint;
		linkConstraint: secondConstraint.
	self assert: graph islands size equals: 3.
	islands := graph mergeIslands.
	self assert: islands size equals: 1.
	self assert: islands first bodies size equals: 3.
	self assert: islands first constraints size equals: 2.
	self assert: (graph islandForBody: first) == islands first.
	self assert: (graph islandForBody: third) == islands first.
	^ graph
]
{ #category : 'tests - islands' }
CFPhysicsIslandTests >> testPersistentIslandGraphDefersSplitAfterConstraintRemoval [
	<gtExample>
	| first second constraint graph island |
	first := self newBodyWithSequence: 1.
	second := self newBodyWithSequence: 2.
	constraint := CFPhysicsDistanceJoint between: first and: second.
	graph := CFPhysicsPersistentIslandGraph new.
	graph linkConstraint: constraint.
	graph mergeIslands.
	island := graph islandForBody: first.
	graph unlinkConstraint: constraint.
	self assert: island constraintRemoveCount equals: 1.
	self assert: island constraints isEmpty.
	self assert: graph islands size equals: 1.
	^ graph
]
{ #category : 'tests - islands' }
CFPhysicsIslandTests >> testWorldPersistentIslandGraphTracksRuntimeJointLifecycle [
	<gtExample>
	| owner firstElement secondElement world first second joint graph island |
	owner := BlElement new size: 200 @ 200; yourself.
	firstElement := BlElement new size: 20 @ 20; yourself.
	secondElement := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { firstElement. secondElement }.
	world := owner physics beWorld.
	world owner physics makeChildrenDynamic.
	first := firstElement physics body.
	second := secondElement physics body.
	graph := world persistentIslandGraph.
	self assert: graph islands size equals: 2.
	joint := CFPhysicsDistanceJoint between: first and: second.
	world addJoint: joint.
	graph mergeIslands.
	island := graph islandForBody: first.
	self assert: (graph islandForBody: second) == island.
	self assert: (graph islandForConstraint: joint) == island.
	joint remove.
	self assert: island constraintRemoveCount equals: 1.
	self assert: (graph islandForConstraint: joint) isNil.
	^ world
]
{ #category : 'tests - persistent islands' }
CFPhysicsIslandTests >> testPersistentIslandGroupsDriveSolverIslandEnumeration [
	<gtExample>
	| first second third constraint result islands |
	first := CFPhysicsBody new sequence: 1; beDynamic; yourself.
	second := CFPhysicsBody new sequence: 2; beDynamic; yourself.
	third := CFPhysicsBody new sequence: 3; beDynamic; yourself.
	constraint := CFPhysicsTestConstraint new
		bodyA: second;
		bodyB: third;
		yourself.
	result := CFPhysicsStepPipelineResult new
		bodies: { first. second. third };
		constraints: { constraint };
		islandBodyGroups: { { first }. { second }. { third } };
		yourself.
	islands := CFPhysicsIslandBuilderStage new executeOn: result.
	self assert: islands size = 2.
	self assert: ((islands collect: [ :island | island bodies size ]) sorted = #(1 2)).
	^ result
]
{ #category : 'tests - persistent islands' }
CFPhysicsIslandTests >> testPersistentIslandGraphSplitsOnlyRemovedConnection [
	<gtExample>
	| first second third firstConstraint secondConstraint graph base islands |
	first := self newBodyWithSequence: 1.
	second := self newBodyWithSequence: 2.
	third := self newBodyWithSequence: 3.
	firstConstraint := CFPhysicsTestConstraint new bodyA: first; bodyB: second; yourself.
	secondConstraint := CFPhysicsTestConstraint new bodyA: second; bodyB: third; yourself.
	graph := CFPhysicsPersistentIslandGraph new.
	graph linkConstraint: firstConstraint.
	graph linkConstraint: secondConstraint.
	graph mergeIslands.
	base := graph islandForBody: first.
	graph unlinkConstraint: secondConstraint.
	islands := graph splitIsland: base.
	self assert: islands size = 2.
	self assert: ((islands collect: [ :island | island bodies size ]) sorted = #(1 2)).
	self assert: (graph islandForBody: first) == (graph islandForBody: second).
	self assert: (graph islandForBody: third) ~~ (graph islandForBody: second).
	self assert: (graph islandForConstraint: firstConstraint) == (graph islandForBody: first).
	self assert: (graph islandForConstraint: secondConstraint) isNil.
	^ graph
]
{ #category : 'tests - persistent islands' }
CFPhysicsIslandTests >> testPersistentIslandGraphSplitsOnlyOneSleepiestDirtyIslandPerStep [
	<gtExample>
	| first second third fourth firstConstraint secondConstraint graph firstIsland secondIsland splitIslands |
	first := self newBodyWithSequence: 1.
	second := self newBodyWithSequence: 2.
	third := self newBodyWithSequence: 3.
	fourth := self newBodyWithSequence: 4.
	firstConstraint := CFPhysicsTestConstraint new bodyA: first; bodyB: second; yourself.
	secondConstraint := CFPhysicsTestConstraint new bodyA: third; bodyB: fourth; yourself.
	graph := CFPhysicsPersistentIslandGraph new.
	graph linkConstraint: firstConstraint.
	graph linkConstraint: secondConstraint.
	graph mergeIslands.
	firstIsland := graph islandForBody: first.
	secondIsland := graph islandForBody: third.
	graph unlinkConstraint: firstConstraint.
	graph unlinkConstraint: secondConstraint.
	first commitAwake: true sleepTime: 0.6.
	second commitAwake: true sleepTime: 0.6.
	third commitAwake: true sleepTime: 0.8.
	fourth commitAwake: true sleepTime: 0.8.
	splitIslands := graph splitSleepiestIslandEligibleAt: 0.5.
	self assert: splitIslands size = 2.
	self assert: (graph islands includes: firstIsland).
	self assert: (graph islands includes: secondIsland) not.
	self assert: (graph islandForBody: first) == (graph islandForBody: second).
	self assert: (graph islandForBody: third) ~~ (graph islandForBody: fourth).
	^ graph
]
{ #category : 'tests - persistent islands' }
CFPhysicsIslandTests >> testPersistentIslandGraphDoesNotSplitASleepingDirtyIsland [
	<gtExample>
	| first second constraint graph island splitIslands |
	first := self newBodyWithSequence: 1.
	second := self newBodyWithSequence: 2.
	constraint := CFPhysicsTestConstraint new bodyA: first; bodyB: second; yourself.
	graph := CFPhysicsPersistentIslandGraph new.
	graph linkConstraint: constraint.
	graph mergeIslands.
	island := graph islandForBody: first.
	graph unlinkConstraint: constraint.
	first commitAwake: false sleepTime: 0.8.
	second commitAwake: false sleepTime: 0.8.
	splitIslands := graph splitSleepiestIslandEligibleAt: 0.5.
	self assert: splitIslands isEmpty.
	self assert: (graph islands includes: island).
	self assert: (graph islandForBody: first) == island.
	self assert: (graph islandForBody: second) == island.
	^ graph
]
{ #category : 'tests - persistent islands' }
CFPhysicsIslandTests >> testPersistentIslandGraphBreaksEqualSleepTimeTiesByLargestIdentifier [
	<gtExample>
	| first second third fourth firstConstraint secondConstraint graph firstIsland secondIsland splitIslands |
	first := self newBodyWithSequence: 1.
	second := self newBodyWithSequence: 2.
	third := self newBodyWithSequence: 3.
	fourth := self newBodyWithSequence: 4.
	firstConstraint := CFPhysicsTestConstraint new bodyA: first; bodyB: second; yourself.
	secondConstraint := CFPhysicsTestConstraint new bodyA: third; bodyB: fourth; yourself.
	graph := CFPhysicsPersistentIslandGraph new.
	graph linkConstraint: firstConstraint.
	graph linkConstraint: secondConstraint.
	graph mergeIslands.
	firstIsland := graph islandForBody: first.
	secondIsland := graph islandForBody: third.
	self assert: secondIsland identifier > firstIsland identifier.
	graph unlinkConstraint: firstConstraint.
	graph unlinkConstraint: secondConstraint.
	first commitAwake: true sleepTime: 0.8.
	second commitAwake: true sleepTime: 0.8.
	third commitAwake: true sleepTime: 0.8.
	fourth commitAwake: true sleepTime: 0.8.
	splitIslands := graph splitSleepiestIslandEligibleAt: 0.5.
	self assert: splitIslands size = 2.
	self assert: (graph islands includes: firstIsland).
	self assert: (graph islands includes: secondIsland) not.
	self assert: (graph islandForBody: first) == (graph islandForBody: second).
	self assert: (graph islandForBody: third) ~~ (graph islandForBody: fourth).
	^ graph
]
{ #category : 'tests - island sleeping' }
CFPhysicsIslandTests >> testManualWakeWakesTheEntirePersistentIsland [
	<gtExample>
	| world graph first second constraint |
	world := CFPhysicsWorld new.
	graph := world persistentIslandGraph.
	first := self newBodyWithSequence: 1.
	second := self newBodyWithSequence: 2.
	first world: world.
	second world: world.
	constraint := self newConstraintBetween: first and: second.
	graph linkConstraint: constraint.
	graph mergeIslands.
	first sleepLocally.
	second sleepLocally.
	first wake.
	self assert: first isAwake.
	self assert: second isAwake.
	^ graph islandForBody: first
]
{ #category : 'tests - island sleeping' }
CFPhysicsIslandTests >> testManualSleepSleepsTheEntirePersistentIsland [
	<gtExample>
	| world graph first second constraint |
	world := CFPhysicsWorld new.
	graph := world persistentIslandGraph.
	first := self newBodyWithSequence: 1.
	second := self newBodyWithSequence: 2.
	first world: world.
	second world: world.
	constraint := self newConstraintBetween: first and: second.
	graph linkConstraint: constraint.
	graph mergeIslands.
	first sleep.
	self assert: first isSleeping.
	self assert: second isSleeping.
	^ graph islandForBody: first
]
{ #category : 'tests - island sleeping' }
CFPhysicsIslandTests >> testManualSleepSplitsDirtyConnectivityBeforeSleeping [
	<gtExample>
	| world graph first second third firstConstraint removedConstraint |
	world := CFPhysicsWorld new.
	graph := world persistentIslandGraph.
	first := self newBodyWithSequence: 1.
	second := self newBodyWithSequence: 2.
	third := self newBodyWithSequence: 3.
	{ first. second. third } do: [ :body | body world: world ].
	firstConstraint := self newConstraintBetween: first and: second.
	removedConstraint := self newConstraintBetween: second and: third.
	graph linkConstraint: firstConstraint.
	graph linkConstraint: removedConstraint.
	graph mergeIslands.
	graph unlinkConstraint: removedConstraint.
	first sleep.
	self assert: first isSleeping.
	self assert: second isSleeping.
	self assert: third isAwake.
	self assert: (graph islandForBody: first) == (graph islandForBody: second).
	self assert: (graph islandForBody: third) ~~ (graph islandForBody: first).
	^ graph islands
]
{ #category : 'tests - island sleeping' }
CFPhysicsIslandTests >> testManualWakeDoesNotCrossAStaticSharedEndpoint [
	<gtExample>
	| world graph first second ground |
	world := CFPhysicsWorld new.
	graph := world persistentIslandGraph.
	first := self newBodyWithSequence: 1.
	ground := self newBodyWithSequence: 2.
	second := self newBodyWithSequence: 3.
	ground beStatic.
	{ first. ground. second } do: [ :body | body world: world ].
	graph linkConstraint: (self newConstraintBetween: first and: ground).
	graph linkConstraint: (self newConstraintBetween: second and: ground).
	graph mergeIslands.
	first sleepLocally.
	second sleepLocally.
	first wake.
	self assert: first isAwake.
	self assert: second isSleeping.
	self assert: (graph islandForBody: first) ~~ (graph islandForBody: second).
	^ graph islands
]
{ #category : 'tests - island sleeping' }
CFPhysicsIslandTests >> testForceWakesTheEntirePersistentIsland [
	<gtExample>
	| world graph first second constraint |
	world := CFPhysicsWorld new.
	graph := world persistentIslandGraph.
	first := self newBodyWithSequence: 1.
	second := self newBodyWithSequence: 2.
	first world: world.
	second world: world.
	constraint := self newConstraintBetween: first and: second.
	graph linkConstraint: constraint.
	graph mergeIslands.
	first sleepLocally.
	second sleepLocally.
	first applyForce: 10 @ 0.
	self assert: first isAwake.
	self assert: second isAwake.
	^ first
]
{ #category : 'tests - island sleeping' }
CFPhysicsIslandTests >> testStandaloneBodyWakeAndSleepRemainLocal [
	<gtExample>
	| body |
	body := self newBodyWithSequence: 1.
	body sleep.
	self assert: body isSleeping.
	body wake.
	self assert: body isAwake.
	^ body
]
{ #category : 'tests - simulation participation' }
CFPhysicsIslandTests >> testSleepingIslandContactIsRetainedWithoutSolverPreparation [
	<gtExample>
	| firstResult ground box step pipeline secondResult |
	firstResult := self newComposedStepResult.
	firstResult commitBodyStates.
	ground := firstResult bodies first.
	box := firstResult bodies second.
	box sleep.
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
	self assert: secondResult activeContacts size equals: 1.
	self assert: secondResult contactConstraints isEmpty.
	self assert: secondResult islands isEmpty.
	^ secondResult
]
{ #category : 'tests - simulation participation' }
CFPhysicsIslandTests >> testSleepingIslandJointIsRetainedWithoutSolverPreparation [
	<gtExample>
	| first second joint step pipeline result |
	first := self newBodyWithSequence: 1.
	second := self newBodyWithSequence: 2.
	first sleepLocally.
	second sleepLocally.
	joint := CFPhysicsDistanceJoint between: first and: second.
	step := CFPhysicsStep
		timeStep: 0.016
		substeps: 4
		contactHertz: 30.0
		dampingRatio: 10.0.
	pipeline := CFPhysicsStepPipeline manifoldGenerator: CFPhysicsManifoldGenerator new.
	result := pipeline
		stepBodies: { first. second }
		fromContacts: #()
		joints: { joint }
		step: step
		gravity: 0 @ 0
		restitutionThreshold: 1.0.
	self assert: result joints size equals: 1.
	self assert: result jointConstraints isEmpty.
	self assert: result islands isEmpty.
	^ result
]
{ #category : 'tests - simulation participation' }
CFPhysicsIslandTests >> testWakingAnIslandRestoresContactAndJointSolverParticipation [
	<gtExample>
	| ground first second contactResult joint step pipeline result |
	ground := self newBodyWithSequence: 1 position: 0 @ 0 extent: 100 @ 20.
	ground beStatic.
	first := self newBodyWithSequence: 2 position: 20 @ 15 extent: 60 @ 20.
	second := self newBodyWithSequence: 3 position: 90 @ 15 extent: 60 @ 20.
	joint := CFPhysicsDistanceJoint between: first and: second.
	step := CFPhysicsStep
		timeStep: 0.016
		substeps: 4
		contactHertz: 30.0
		dampingRatio: 10.0.
	pipeline := CFPhysicsStepPipeline manifoldGenerator: CFPhysicsManifoldGenerator new.
	contactResult := pipeline
		stepBodies: { ground. first. second }
		fromContacts: #()
		joints: { joint }
		step: step
		gravity: 0 @ 0
		restitutionThreshold: 1.0.
	contactResult commitBodyStates.
	first sleepLocally.
	second sleepLocally.
	first wakeLocally.
	result := pipeline
		stepBodies: { ground. first. second }
		fromContacts: contactResult activeContacts
		joints: { joint }
		step: step
		gravity: 0 @ 0
		restitutionThreshold: 1.0.
	self assert: result contactConstraints isEmpty not.
	self assert: result jointConstraints size equals: 1.
	self assert: result islands isEmpty not.
	^ result
]
