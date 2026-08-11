Class {
	#name : 'CFPhysicsProfileHealthElementTests',
	#superclass : 'TestCase',
	#category : 'BVC-Physics-Tests-Tools',
	#package : 'BVC-Physics-Tests-Tools'
}

{ #category : 'private - fixtures' }
CFPhysicsProfileHealthElementTests >> worldWithOneJoint [
	| host first second world |
	host := BlElement new.
	first := BlElement new size: 20 @ 20.
	second := BlElement new size: 20 @ 20.
	host
		addChild: first;
		addChild: second.
	world := host physics beWorld.
	host physics makeChildrenDynamic.
	world addJoint: (CFPhysicsDistanceJoint
		between: (world bodyStateFor: first)
		and: (world bodyStateFor: second)).
	^ world
]

{ #category : 'tests - retention' }
CFPhysicsProfileHealthElementTests >> testJointRetentionRowClassifiesLiveCapturedAndRetainedSolveOwners [
	| world live captured state backgroundStep solution result promise health row |
	world := self worldWithOneJoint.
	live := world joints first.
	captured := live capturedForStep.
	state := CFPhysicsWorldState new
		world: world;
		joints: { captured };
		yourself.
	backgroundStep := CFPhysicsWorldBackgroundStep on: world.
	backgroundStep instVarNamed: 'state' put: state.
	result := CFPhysicsStepPipelineResult new
		joints: { captured };
		yourself.
	solution := CFPhysicsWorldSolution new
		world: world;
		pipelineResult: result;
		yourself.
	promise := AsyncFuturePromise new.
	promise fulfillWithValue: solution.
	world instVarNamed: 'lastStepResult' put: result.
	health := CFPhysicsProfileHealthElement new world: world.
	row := health
		jointRetentionRowFrom: { live. captured }
		worldStates: { state }
		backgroundSteps: { backgroundStep }
		solutions: { solution }
		pipelineResults: { result }
		futurePromises: { promise }.
	self assert: (row at: #owned) equals: 2.
	self assert: (row at: #live) equals: 1.
	self assert: (row at: #captured) equals: 1.
	self assert: (row at: #unexplained) equals: 0.
	self assert: (row at: #worldStateCount) equals: 1.
	self assert: (row at: #backgroundStepCount) equals: 1.
	self assert: (row at: #solutionCount) equals: 1.
	self assert: (row at: #futureHeldSolutionCount) equals: 1.
	self assert: (row at: #pipelineResultCount) equals: 1.
	self assert: (row at: #worldLastPipelineResultCount) equals: 1.
	self assert: (row at: #solutionPipelineResultCount) equals: 1.
	self assert: (row at: #otherPipelineResultCount) equals: 0
]

{ #category : 'tests - retention' }
CFPhysicsProfileHealthElementTests >> testJointRetentionRowReportsRelatedJointOutsideLiveAndCapturedAsUnexplained [
	| world live unexplained health row |
	world := self worldWithOneJoint.
	live := world joints first.
	unexplained := live capturedForStep.
	unexplained sourceJoint: CFPhysicsDistanceJoint new.
	health := CFPhysicsProfileHealthElement new world: world.
	row := health
		jointRetentionRowFrom: { live. unexplained }
		worldStates: #()
		backgroundSteps: #()
		solutions: #()
		pipelineResults: #()
		futurePromises: #().
	self assert: (row at: #owned) equals: 2.
	self assert: (row at: #live) equals: 1.
	self assert: (row at: #captured) equals: 0.
	self assert: (row at: #unexplained) equals: 1.
	self assert: (row at: #difference) equals: 1
]

{ #category : 'tests - formatting' }
CFPhysicsProfileHealthElementTests >> testJointInstanceSummaryUsesNamedCounts [
	| health row |
	health := CFPhysicsProfileHealthElement new.
	row := {
		#total -> 368.
		#owned -> 116.
		#live -> 29.
		#captured -> 87.
		#unexplained -> 0 } asDictionary.
	self assert: (health jointInstanceSummaryFor: row)
		equals: 'image 368 · related 116 · live 29 · captured 87 · unexplained 0'
]

{ #category : 'tests - formatting' }
CFPhysicsProfileHealthElementTests >> testJointHolderSummaryUsesNamedCounts [
	| health row |
	health := CFPhysicsProfileHealthElement new.
	row := {
		#worldStateCount -> 2.
		#backgroundStepCount -> 2.
		#solutionCount -> 1.
		#futureHeldSolutionCount -> 1.
		#pipelineResultCount -> 3.
		#worldLastPipelineResultCount -> 1.
		#solutionPipelineResultCount -> 1.
		#otherPipelineResultCount -> 1 } asDictionary.
	self assert: (health jointHolderSummaryFor: row)
		equals: 'states 2 · background steps 2 · solutions 1 · held by future promises 1'.
	self assert: (health jointPipelineSummaryFor: row)
		equals: 'results 3 · world last 1 · solution-owned 1 · other 1'
]

{ #category : 'tests - formatting' }
CFPhysicsProfileHealthElementTests >> testInstanceStatisticsRowUsesSeparateNameAndValuesColumns [
	| health row |
	health := CFPhysicsProfileHealthElement new.
	row := health
		instanceStatisticsRowNamed: 'PhysicsJoint'
		lines: { 'Current' -> 'image 100 · related 50 · live 10 · captured 40 · unexplained 0' }.
	self assert: row children size equals: 2.
	self assert: row children first children first text asString equals: 'PhysicsJoint'.
	self assert: row children second children size equals: 1
]

{ #category : 'tests - formatting' }
CFPhysicsProfileHealthElementTests >> testInstanceStatisticsLineSeparatesLabelFromValue [
	| health line |
	health := CFPhysicsProfileHealthElement new.
	line := health
		instanceStatisticsLineNamed: 'Retained'
		value: 'image 455 · related 116 · live 29 · captured 87 · unexplained 0'.
	self assert: line children size equals: 2.
	self assert: line children first text asString equals: 'Retained'.
	self assert: line children second text asString
		equals: 'image 455 · related 116 · live 29 · captured 87 · unexplained 0'
]

{ #category : 'tests - retention' }
CFPhysicsProfileHealthElementTests >> testPipelineResultBelongsToWorldWithoutCapturedJoints [
	| world result health |
	world := self worldWithOneJoint.
	result := CFPhysicsStepPipelineResult new
		bodies: world bodyStatesInOrder;
		yourself.
	health := CFPhysicsProfileHealthElement new world: world.
	self assert: (health pipelineResult: result belongsTo: world)
]

{ #category : 'tests - formatting' }
CFPhysicsProfileHealthElementTests >> testBodyInstanceSummaryUsesLifecycleRoles [
	| health row |
	health := CFPhysicsProfileHealthElement new.
	row := {
		#total -> 33.
		#owned -> 33.
		#memberCount -> 31.
		#containmentCount -> 1.
		#stateOwnedCount -> 32.
		#resultOwnedCount -> 32.
		#otherCount -> 0 } asDictionary.
	self assert: (health bodyInstanceSummaryFor: row)
		equals: 'image 33 · related 33 · members 31 · containment 1 · state-owned 32 · result-owned 32 · other 0'
]

{ #category : 'tests - formatting' }
CFPhysicsProfileHealthElementTests >> testContactInstanceSummaryUsesLifecycleRoles [
	| health row |
	health := CFPhysicsProfileHealthElement new.
	row := {
		#total -> 10.
		#owned -> 10.
		#committedCount -> 2.
		#calculationCount -> 2.
		#stateOwnedCount -> 4.
		#previousResultOwnedCount -> 6.
		#currentResultOwnedCount -> 6.
		#otherCount -> 0 } asDictionary.
	self assert: (health contactInstanceSummaryFor: row)
		equals: 'image 10 · related 10 · committed 2 · calculation 2 · state-owned 4 · previous-result 6 · current-result 6 · other 0'
]

{ #category : 'tests - formatting' }
CFPhysicsProfileHealthElementTests >> testSolutionInstanceSummaryUsesLifecycleRoles [
	| health row |
	health := CFPhysicsProfileHealthElement new.
	row := {
		#total -> 3.
		#owned -> 3.
		#backgroundStepOwnedCount -> 0.
		#futureOwnedCount -> 0.
		#otherCount -> 3 } asDictionary.
	self assert: (health solutionInstanceSummaryFor: row)
		equals: 'image 3 · world 3 · background-step 0 · future 0 · other 3'
]
