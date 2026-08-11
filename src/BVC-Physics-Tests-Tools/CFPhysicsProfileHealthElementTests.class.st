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
CFPhysicsProfileHealthElementTests >> testJointRetentionRowClassifiesLiveAndCapturedJointsFromTheirOwnState [
	| world live captured state backgroundStep solution result health row |
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
	health := CFPhysicsProfileHealthElement new world: world.
	row := health
		jointRetentionRowFrom: { live. captured }
		worldStates: { state }
		backgroundSteps: { backgroundStep }
		solutions: { solution }
		pipelineResults: { result }.
	self assert: (row at: #owned) equals: 2.
	self assert: (row at: #live) equals: 1.
	self assert: (row at: #captured) equals: 1.
	self assert: (row at: #unexplained) equals: 0.
	self assert: (row at: #worldStateCount) equals: 1.
	self assert: (row at: #backgroundStepCount) equals: 1.
	self assert: (row at: #solutionCount) equals: 1.
	self assert: (row at: #pipelineResultCount) equals: 1
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
		pipelineResults: #().
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
		#pipelineResultCount -> 3 } asDictionary.
	self assert: (health jointHolderSummaryFor: row)
		equals: 'states 2 · background steps 2 · solutions 1 · pipeline results 3'
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
