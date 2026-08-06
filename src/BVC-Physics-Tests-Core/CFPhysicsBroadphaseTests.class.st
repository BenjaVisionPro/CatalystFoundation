Class {
	#name : 'CFPhysicsBroadphaseTests',
	#superclass : 'CFPhysicsTestCase',
	#category : 'BVC-Physics-Tests-Core',
	#package : 'BVC-Physics-Tests-Core'
}

{ #category : 'tests - pair discovery' }
CFPhysicsBroadphaseTests >> testPairFinderReturnsOverlappingPairsInSequenceOrder [
	<gtExample>
	| first second third pairs |
	first := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self newBodyWithSequence: 2 position: 15 @ 0 extent: 20 @ 20.
	third := self newBodyWithSequence: 3 position: 10 @ 10 extent: 20 @ 20.
	pairs := CFPhysicsPairFinder new pairsAmong: { third. first. second }.
	self assert: (pairs collect: [ :pair | { pair firstBody sequence. pair secondBody sequence } ])
		equals: { { 1. 2 }. { 1. 3 }. { 2. 3 } }.
	^ pairs
]
{ #category : 'tests - pair discovery' }
CFPhysicsBroadphaseTests >> testPairFinderExpiresInactiveSweepEntriesInPlace [
	<gtExample>
	| first second third pairFinder pairs |
	first := self newBodyWithSequence: 1 position: 0 @ 0 extent: 10 @ 10.
	second := self newBodyWithSequence: 2 position: 100 @ 0 extent: 10 @ 10.
	third := self newBodyWithSequence: 3 position: 105 @ 0 extent: 10 @ 10.
	pairFinder := CFPhysicsPairFinder new.
	pairs := pairFinder pairsAmong: { third. first. second }.
	self assert: pairFinder comparisonCount equals: 1.
	self assert: pairs size equals: 1.
	self assert: pairs first firstBody equals: second.
	self assert: pairs first secondBody equals: third.
	^ pairs
]
{ #category : 'tests - pair discovery' }
CFPhysicsBroadphaseTests >> testPairFinderStageUsesCapturedBodyState [
	<gtExample>
	| first second result stage pairs |
	first := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self newBodyWithSequence: 2 position: 15 @ 0 extent: 20 @ 20.
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
{ #category : 'tests - collision filtering' }
CFPhysicsBroadphaseTests >> testPairFinderStageUsesCapturedJointCollisionPolicy [
	<gtExample>
	| first second result pairs |
	first := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self newBodyWithSequence: 2 position: 15 @ 0 extent: 20 @ 20.
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
{ #category : 'tests - pair discovery' }
CFPhysicsBroadphaseTests >> testBodyStepStateCapturesBlocGeometry [
	<gtExample>
	| first second result pairs |
	first := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self newBodyWithSequence: 2 position: 15 @ 0 extent: 20 @ 20.
	result := CFPhysicsStepPipelineResult new bodies: { first. second }; yourself.
	CFPhysicsBodyStateCaptureStage new executeOn: result.
	second element size: 1 @ 1.
	pairs := CFPhysicsPairFinderStage new executeOn: result.
	self assert: pairs size equals: 1.
	self assert: (result bodyStates at: second) shapeState extent equals: 20 @ 20.
	^ pairs
]
{ #category : 'tests - pair discovery' }
CFPhysicsBroadphaseTests >> testPairFinderRejectsSeparatedBodies [
	<gtExample>
	| first second pairs |
	first := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self newBodyWithSequence: 2 position: 30 @ 0 extent: 20 @ 20.
	pairs := CFPhysicsPairFinder new pairsAmong: { first. second }.
	self assert: pairs isEmpty.
	^ pairs
]
{ #category : 'tests - pair discovery' }
CFPhysicsBroadphaseTests >> testPairFinderRejectsStaticStaticPairs [
	<gtExample>
	| first second pairs |
	first := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self newBodyWithSequence: 2 position: 10 @ 0 extent: 20 @ 20.
	first beStatic.
	second beStatic.
	pairs := CFPhysicsPairFinder new pairsAmong: { first. second }.
	self assert: pairs isEmpty.
	^ pairs
]
{ #category : 'tests - collision filtering' }
CFPhysicsBroadphaseTests >> testCollisionFiltersAllowOrdinaryOverlappingBodies [
	<gtExample>
	| first second pairs |
	first := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self newBodyWithSequence: 2 position: 10 @ 0 extent: 20 @ 20.
	pairs := CFPhysicsPairFinder new pairsAmong: { first. second }.
	self assert: pairs size equals: 1.
	self assert: first collisionCategoryBits equals: 1.
	self assert: first collisionMaskBits equals: 16rFFFFFFFF.
	self assert: first collisionGroupIndex equals: 0.
	^ pairs
]
{ #category : 'tests - collision filtering' }
CFPhysicsBroadphaseTests >> testCollisionMasksRejectBodiesBeforeManifoldConstruction [
	<gtExample>
	| first second pairs |
	first := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self newBodyWithSequence: 2 position: 10 @ 0 extent: 20 @ 20.
	first collisionCategoryBits: 2r0001.
	first collisionMaskBits: 2r0010.
	second collisionCategoryBits: 2r0100.
	second collisionMaskBits: 2r0001.
	pairs := CFPhysicsPairFinder new pairsAmong: { first. second }.
	self assert: pairs isEmpty.
	^ pairs
]
{ #category : 'tests - collision filtering' }
CFPhysicsBroadphaseTests >> testPositiveCollisionGroupOverridesMasks [
	<gtExample>
	| first second pairs |
	first := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self newBodyWithSequence: 2 position: 10 @ 0 extent: 20 @ 20.
	first collisionMaskBits: 0; collisionGroupIndex: 7.
	second collisionMaskBits: 0; collisionGroupIndex: 7.
	pairs := CFPhysicsPairFinder new pairsAmong: { first. second }.
	self assert: pairs size equals: 1.
	^ pairs
]
{ #category : 'tests - collision filtering' }
CFPhysicsBroadphaseTests >> testNegativeCollisionGroupSuppressesCollision [
	<gtExample>
	| first second pairs |
	first := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self newBodyWithSequence: 2 position: 10 @ 0 extent: 20 @ 20.
	first collisionGroupIndex: -3.
	second collisionGroupIndex: -3.
	pairs := CFPhysicsPairFinder new pairsAmong: { first. second }.
	self assert: pairs isEmpty.
	^ pairs
]
{ #category : 'tests - collision filtering' }
CFPhysicsBroadphaseTests >> testElementFacingCollisionFilteringConfiguresItsBody [
	<gtExample>
	| owner child world body |
	owner := BlElement new size: 200 @ 200; yourself.
	child := BlElement new size: 30 @ 30; yourself.
	owner addChild: child.
	world := owner physics beWorld.
	world owner physics makeChildrenDynamic.
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
{ #category : 'tests - collision filtering' }
CFPhysicsBroadphaseTests >> testRuntimeFilterChangeCreatesAContactWithoutBodyMovement [
	<gtExample>
	| owner first second world firstBody secondBody firstResult secondResult |
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
	firstBody position: 0 @ 0; collisionMaskBits: 0.
	secondBody position: 10 @ 0.
	firstResult := world step.
	self assert: firstResult activeContacts isEmpty.
	firstBody collisionMaskBits: 16rFFFFFFFF.
	secondResult := world step.
	self assert: secondResult beganContacts size equals: 1.
	self assert: secondResult activeContacts size equals: 1.
	^ secondResult
]
{ #category : 'tests - collision filtering' }
CFPhysicsBroadphaseTests >> testRuntimeFilterChangeEndsATouchingContactAndWakesBothBodies [
	<gtExample>
	| owner first second world firstBody secondBody firstResult secondResult |
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
	self assert: firstResult activeContacts size equals: 1.
	firstBody sleep.
	secondBody sleep.
	firstBody collisionMaskBits: 0.
	self assert: firstBody isAwake.
	self assert: secondBody isAwake.
	secondResult := world step.
	self assert: secondResult endedContacts size equals: 1.
	self assert: secondResult activeContacts isEmpty.
	self assert: (world persistentIslandGraph islandForConstraint: firstResult activeContacts first) isNil.
	^ secondResult
]
{ #category : 'tests - collision filtering' }
CFPhysicsBroadphaseTests >> testDistanceJointCanSuppressCollisionBetweenItsEndpoints [
	<gtExample>
	| owner first second world joint pairs |
	owner := BlElement new size: 400 @ 300; yourself.
	first := BlElement new size: 20 @ 20; yourself.
	second := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { first. second }.
	world := owner physics beWorld.
	world owner physics makeChildrenDynamic.
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
{ #category : 'tests - collision filtering' }
CFPhysicsBroadphaseTests >> testRevoluteJointCanSuppressCollisionBetweenItsEndpoints [
	<gtExample>
	| owner first second world joint pairs |
	owner := BlElement new size: 400 @ 300; yourself.
	first := BlElement new size: 20 @ 20; yourself.
	second := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { first. second }.
	world := owner physics beWorld.
	world owner physics makeChildrenDynamic.
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
{ #category : 'tests - collision filtering' }
CFPhysicsBroadphaseTests >> testWeldJointCanSuppressCollisionBetweenItsEndpoints [
	<gtExample>
	| owner first second world joint pairs |
	owner := BlElement new size: 400 @ 300; yourself.
	first := BlElement new size: 20 @ 20; yourself.
	second := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { first. second }.
	world := owner physics beWorld.
	world owner physics makeChildrenDynamic.
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
{ #category : 'tests - collision filtering' }
CFPhysicsBroadphaseTests >> testPrismaticJointCanSuppressCollisionBetweenItsEndpoints [
	<gtExample>
	| owner first second world joint pairs |
	owner := BlElement new size: 400 @ 300; yourself.
	first := BlElement new size: 20 @ 20; yourself.
	second := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { first. second }.
	world := owner physics beWorld.
	world owner physics makeChildrenDynamic.
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
{ #category : 'tests - collision filtering' }
CFPhysicsBroadphaseTests >> testFilterJointMatchesBox2DCollisionAndIslandSemantics [
	<gtExample>
	| owner first second world joint graph island suppressedResult collidingResult |
	owner := BlElement new size: 400 @ 300; yourself.
	first := BlElement new size: 20 @ 20; yourself.
	second := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { first. second }.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world owner physics makeChildrenDynamic.
	first physics position: 100 @ 100.
	second physics position: 110 @ 100.
	joint := first physics filterJointTo: second.
	self assert: joint collideConnected not.
	self assert: world filterJoints equals: { joint }.
	self assert: first physics filterJoints equals: { joint }.
	suppressedResult := world step.
	self assert: suppressedResult activeContacts isEmpty.
	self assert: suppressedResult jointConstraints isEmpty.
	graph := world persistentIslandGraph.
	graph mergeIslands.
	island := graph islandForBody: first physics body.
	self assert: (graph islandForBody: second physics body) == island.
	self assert: (graph islandForConstraint: joint) == island.
	joint collideConnected: true.
	collidingResult := world step.
	self assert: collidingResult activeContacts size equals: 1.
	self assert: collidingResult jointConstraints isEmpty.
	^ collidingResult
]
{ #category : 'tests - collision filtering' }
CFPhysicsBroadphaseTests >> testDisablingDistanceJointCollisionEndsAnActiveContact [
	<gtExample>
	| owner first second world joint firstResult secondResult |
	owner := BlElement new size: 400 @ 300; yourself.
	first := BlElement new size: 20 @ 20; yourself.
	second := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { first. second }.
	world := owner physics beWorld.
	world containment disable.
	world gravity: 0 @ 0.
	world owner physics makeChildrenDynamic.
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
{ #category : 'tests - collision filtering' }
CFPhysicsBroadphaseTests >> testChangingDistanceJointCollisionPolicyWakesItsBodies [
	<gtExample>
	| owner first second world joint |
	owner := BlElement new size: 400 @ 300; yourself.
	first := BlElement new size: 20 @ 20; yourself.
	second := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { first. second }.
	world := owner physics beWorld.
	world owner physics makeChildrenDynamic.
	joint := first physics distanceJointTo: second.
	joint collideConnected: true.
	first physics body sleep.
	second physics body sleep.
	joint collideConnected: false.
	self assert: first physics body isAwake.
	self assert: second physics body isAwake.
	^ joint
]
{ #category : 'tests - hierarchy collision diagnosis' }
CFPhysicsBroadphaseTests >> testThreeOverlappingBodiesAnchoredIndependentlyToWorldCentre [
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
	world owner physics makeChildrenDynamic.
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
{ #category : 'tests - broadphase' }
CFPhysicsBroadphaseTests >> testAabbExpansionPreservesCentreAndAddsMargin [
	<gtExample>
	| bounds expanded |
	bounds := CFPhysicsAABB position: 10 @ 20 extent: 30 @ 40.
	expanded := bounds expandedBy: 5.0.
	self assert: expanded minimum equals: 5 @ 15.
	self assert: expanded maximum equals: 45 @ 65.
	self assert: expanded centre equals: bounds centre.
	^ expanded
]
{ #category : 'tests - broadphase' }
CFPhysicsBroadphaseTests >> testWorldScalesBroadphaseDistancesIntoEachStep [
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
{ #category : 'tests - broadphase' }
CFPhysicsBroadphaseTests >> testDynamicTreeQueriesOnlyOverlappingProxies [
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
{ #category : 'tests - broadphase' }
CFPhysicsBroadphaseTests >> testDynamicTreeMovesProxyOnlyOutsideItsFatBounds [
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
{ #category : 'tests - broadphase' }
CFPhysicsBroadphaseTests >> testDynamicTreeReusesReleasedNodes [
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
{ #category : 'tests - broadphase' }
CFPhysicsBroadphaseTests >> testDynamicTreeMaintainsBox2DStructuralInvariants [
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
{ #category : 'tests - broadphase' }
CFPhysicsBroadphaseTests >> testDynamicTreeQueryCanTerminateWithoutCollectingResults [
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
{ #category : 'tests - broadphase' }
CFPhysicsBroadphaseTests >> testDynamicTreeReportsBox2DAreaRatio [
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
{ #category : 'tests - broadphase' }
CFPhysicsBroadphaseTests >> testDynamicTreeRayCastClipsAndVisitsNearestProxyFirst [
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
{ #category : 'tests - broadphase' }
CFPhysicsBroadphaseTests >> testDynamicTreeRayCastCallbackCanTerminateTraversal [
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
{ #category : 'tests - broadphase' }
CFPhysicsBroadphaseTests >> testDynamicTreeShapeCastClipsAndVisitsNearestProxyFirst [
	<gtExample>
	| tree input visited completed |
	tree := CFPhysicsDynamicTree new.
	tree createProxyFor: #near aabb: (CFPhysicsAABB position: 10 @ -2 extent: 4 @ 4).
	tree createProxyFor: #far aabb: (CFPhysicsAABB position: 30 @ -2 extent: 4 @ 4).
	tree createProxyFor: #outside aabb: (CFPhysicsAABB position: 10 @ 20 extent: 4 @ 4).
	input := CFPhysicsShapeCastInput new
		points: { 0 @ -1. 0 @ 1 };
		radius: 1.0;
		translation: 50 @ 0;
		maximumFraction: 1.0;
		yourself.
	visited := OrderedCollection new.
	completed := tree shapeCast: input do: [ :each :clippedInput |
		visited add: each.
		self assert: (clippedInput maximumFraction closeTo: 1.0).
		each = #near ifTrue: [ 0.3 ] ifFalse: [ clippedInput maximumFraction ] ].
	self assert: completed.
	self assert: visited asArray equals: #(near).
	self assert: tree queryLeafVisitCount equals: 1.
	^ tree
]
{ #category : 'tests - broadphase' }
CFPhysicsBroadphaseTests >> testDynamicTreeShapeCastCallbackCanTerminateTraversal [
	<gtExample>
	| tree input visited completed |
	tree := CFPhysicsDynamicTree new.
	tree createProxyFor: #body aabb: (CFPhysicsAABB position: 10 @ -2 extent: 4 @ 4).
	input := CFPhysicsShapeCastInput new
		points: { 0 @ 0 };
		radius: 1.0;
		translation: 50 @ 0;
		maximumFraction: 1.0;
		yourself.
	visited := 0.
	completed := tree shapeCast: input do: [ :each :clippedInput |
		visited := visited + 1.
		0.0 ].
	self assert: completed not.
	self assert: visited equals: 1.
	^ tree
]
{ #category : 'tests - broadphase' }
CFPhysicsBroadphaseTests >> testDynamicTreeFullRebuildPreservesProxiesAndInvariants [
	<gtExample>
	| tree before after rebuilt |
	tree := CFPhysicsDynamicTree new.
	1 to: 32 do: [ :index |
		tree
			createProxyFor: index
			aabb: (CFPhysicsAABB
				position: (index * 13) @ ((index \\ 7) * 17)
				extent: 9 @ 11) ].
	before := tree proxyCount.
	rebuilt := tree rebuildFully.
	after := tree proxyCount.
	self assert: rebuilt equals: before.
	self assert: after equals: before.
	self assert: tree rebuildCount equals: 1.
	self assert: tree validate.
	self assert: (tree query: (CFPhysicsAABB position: 0 @ 0 extent: 1000 @ 1000)) size equals: before.
	^ tree
]
{ #category : 'tests - broadphase' }
CFPhysicsBroadphaseTests >> testDynamicTreePartialRebuildTouchesOnlyEnlargedBranch [
	<gtExample>
	| tree proxy rebuilt |
	tree := CFPhysicsDynamicTree new.
	proxy := tree createProxyFor: #moving aabb: (CFPhysicsAABB position: 0 @ 0 extent: 10 @ 10).
	tree createProxyFor: #near aabb: (CFPhysicsAABB position: 20 @ 0 extent: 10 @ 10).
	tree createProxyFor: #far aabb: (CFPhysicsAABB position: 200 @ 0 extent: 10 @ 10).
	tree enlargeProxy: proxy to: (CFPhysicsAABB position: 0 @ 0 extent: 40 @ 10).
	rebuilt := tree rebuild.
	self assert: rebuilt > 0.
	self assert: rebuilt <= tree proxyCount.
	self assert: tree validate.
	self assert: ((tree query: (CFPhysicsAABB position: 30 @ 0 extent: 5 @ 5)) includes: #moving).
	^ tree
]
