Class {
	#name : 'CFPhysicsTelemetryStressTests',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Physics-Tests-Telemetry',
	#package : 'BVC-Foundation-Physics-Tests'
}

{ #category : 'private - recording' }
CFPhysicsTelemetryStressTests >> record: aWorld warmupSteps: warmupCount measuredSteps: measuredCount [
	aWorld telemetryEnabled: false.
	warmupCount timesRepeat: [ aWorld step ].
	aWorld resetTelemetry.
	aWorld telemetryEnabled: true.
	measuredCount timesRepeat: [ aWorld step ].
	aWorld telemetryEnabled: false.
	^ CFPhysicsTelemetryAnalysis world: aWorld
]

{ #category : 'private - assertions' }
CFPhysicsTelemetryStressTests >> assertAnalysis: anAnalysis measuredSteps: measuredCount [
	| root pipeline previousStart |
	self assert: anAnalysis sampleCount equals: measuredCount.
	root := anAnalysis rootStatistics.
	self assert: root notNil.
	self assert: root samples size equals: measuredCount.
	pipeline := root children detect: [ :each | each name asString = 'Pipeline' ].
	self assert: pipeline children isNotEmpty.
	previousStart := -1.
	pipeline children do: [ :stage |
		self assert: stage samples isNotEmpty.
		self assert: stage p05Start <= stage p25Start.
		self assert: stage p25Start <= stage medianStart.
		self assert: stage medianStart <= stage medianEnd.
		self assert: stage medianEnd <= stage p75End.
		self assert: stage p75End <= stage p95End.
		self assert: stage averageStart >= previousStart.
		self assert: stage averageEnd >= stage averageStart.
		self assert: stage executionsByDuration first signal notNil.
		previousStart := stage averageStart ]
]

{ #category : 'tests - lifecycle' }
CFPhysicsTelemetryStressTests >> testTelemetryRecordingLifecycleIsAutomatable [
	<gtExample>
	| world |
	world := CFPhysicsTelemetryStressScenarios sleepingBodies: 8.
	self assert: world hasTelemetryLogger not.
	world step.
	self assert: world hasTelemetryLogger not.
	world telemetryEnabled: true.
	world step.
	self assert: world telemetryRecordings size equals: 1.
	world telemetryEnabled: false.
	self assert: world telemetryRecordings size equals: 1.
	world resetTelemetry.
	self assert: world telemetryRecordings isEmpty
]

{ #category : 'tests - stress' }
CFPhysicsTelemetryStressTests >> testSleepingBodiesTelemetry [
	<gtExample>
	| world analysis |
	world := CFPhysicsTelemetryStressScenarios sleepingBodies: 40.
	self assert: (world bodyStatesInOrder allSatisfy: [ :body | body isAwake not ]).
	analysis := self record: world warmupSteps: 2 measuredSteps: 12.
	self assertAnalysis: analysis measuredSteps: 12.
	self assert: world lastStepResult bodies size equals: 40
]

{ #category : 'tests - stress' }
CFPhysicsTelemetryStressTests >> testDensePileTelemetry [
	<gtExample>
	| world analysis |
	world := CFPhysicsTelemetryStressScenarios densePileRows: 6 columns: 6.
	analysis := self record: world warmupSteps: 4 measuredSteps: 16.
	self assertAnalysis: analysis measuredSteps: 16.
	self assert: world lastStepResult bodies size equals: 36.
	self assert: world lastStepResult contactResult activeContacts isNotEmpty.
	self assert: world lastStepResult islands isNotEmpty
]

{ #category : 'tests - stress' }
CFPhysicsTelemetryStressTests >> testIndependentIslandsTelemetry [
	<gtExample>
	| world analysis |
	world := CFPhysicsTelemetryStressScenarios independentIslands: 4 bodiesPerIsland: 4.
	analysis := self record: world warmupSteps: 4 measuredSteps: 16.
	self assertAnalysis: analysis measuredSteps: 16.
	self assert: world lastStepResult bodies size equals: 16.
	self assert: world lastStepResult islands size >= 4
]

{ #category : 'tests - stress' }
CFPhysicsTelemetryStressTests >> testSinglePathologicalIslandTelemetry [
	<gtExample>
	| world analysis |
	world := CFPhysicsTelemetryStressScenarios singleIslandBodies: 20.
	analysis := self record: world warmupSteps: 4 measuredSteps: 16.
	self assertAnalysis: analysis measuredSteps: 16.
	self assert: world lastStepResult bodies size equals: 20.
	self assert: world lastStepResult islands size equals: 1
]

{ #category : 'tests - stress' }
CFPhysicsTelemetryStressTests >> testSensorOverlapTelemetry [
	<gtExample>
	| world analysis contacts |
	world := CFPhysicsTelemetryStressScenarios sensorOverlapPairs: 12.
	analysis := self record: world warmupSteps: 2 measuredSteps: 12.
	self assertAnalysis: analysis measuredSteps: 12.
	self assert: world lastStepResult bodies size equals: 24.
	contacts := world lastStepResult contactResult activeContacts.
	self assert: contacts size equals: 12.
	self assert: (contacts allSatisfy: [ :contact | contact isSensor ])
]

{ #category : 'tests - stress' }
CFPhysicsTelemetryStressTests >> testContinuousCollisionTelemetry [
	<gtExample>
	| world analysis continuousResult |
	world := CFPhysicsTelemetryStressScenarios continuousCollisionBodies: 8.
	analysis := self record: world warmupSteps: 0 measuredSteps: 1.
	self assertAnalysis: analysis measuredSteps: 1.
	self assert: world lastStepResult bodies size equals: 16.
	continuousResult := world lastStepResult continuousStepResult.
	self assert: continuousResult notNil.
	self assert: continuousResult impacts size equals: 8
]
