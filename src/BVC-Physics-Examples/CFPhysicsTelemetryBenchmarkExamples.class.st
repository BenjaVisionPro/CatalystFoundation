"
I run controlled Physics telemetry benchmarks.

My responsibility is to execute repeatable workloads and answer inspectable measurements without asserting optimisation conclusions.
"
Class {
	#name : 'CFPhysicsTelemetryBenchmarkExamples',
	#superclass : 'Object',
	#category : 'BVC-Physics-Examples',
	#package : 'BVC-Physics-Examples'
}

{ #category : 'private - running' }
CFPhysicsTelemetryBenchmarkExamples >> benchmark: aWorld named: aString parameters: parameters warmupSteps: warmupCount measuredSteps: measuredCount [
	aWorld telemetryEnabled: false.
	warmupCount timesRepeat: [ aWorld step ].
	aWorld resetTelemetry.
	aWorld telemetryEnabled: true.
	measuredCount timesRepeat: [ aWorld step ].
	aWorld telemetryEnabled: false.
	^ CFPhysicsTelemetryBenchmarkResult
		scenario: aString
		parameters: parameters
		warmupSteps: warmupCount
		measuredSteps: measuredCount
		world: aWorld
]

{ #category : 'benchmarks' }
CFPhysicsTelemetryBenchmarkExamples >> sleepingBodiesBenchmark [
	<gtExample>
	^ self
		benchmark: (CFPhysicsTelemetryBenchmarkScenarios sleepingBodies: 100)
		named: 'Sleeping bodies'
		parameters: { #bodyCount -> 100 }
		warmupSteps: 20
		measuredSteps: 120
]

{ #category : 'benchmarks' }
CFPhysicsTelemetryBenchmarkExamples >> densePileBenchmark [
	<gtExample>
	^ self
		benchmark: (CFPhysicsTelemetryBenchmarkScenarios densePileRows: 10 columns: 10)
		named: 'Dense pile'
		parameters: { #rows -> 10. #columns -> 10. #bodyCount -> 100 }
		warmupSteps: 20
		measuredSteps: 120
]

{ #category : 'benchmarks' }
CFPhysicsTelemetryBenchmarkExamples >> independentIslandsBenchmark [
	<gtExample>
	^ self
		benchmark: (CFPhysicsTelemetryBenchmarkScenarios independentIslands: 10 bodiesPerIsland: 10)
		named: 'Independent islands'
		parameters: { #islandGroups -> 10. #bodiesPerGroup -> 10. #bodyCount -> 100 }
		warmupSteps: 20
		measuredSteps: 120
]

{ #category : 'benchmarks' }
CFPhysicsTelemetryBenchmarkExamples >> singleIslandBenchmark [
	<gtExample>
	^ self
		benchmark: (CFPhysicsTelemetryBenchmarkScenarios singleIslandBodies: 100)
		named: 'Single island'
		parameters: { #bodyCount -> 100 }
		warmupSteps: 20
		measuredSteps: 120
]

{ #category : 'benchmarks' }
CFPhysicsTelemetryBenchmarkExamples >> sensorOverlapBenchmark [
	<gtExample>
	^ self
		benchmark: (CFPhysicsTelemetryBenchmarkScenarios sensorOverlapPairs: 50)
		named: 'Sensor overlap'
		parameters: { #sensorPairs -> 50. #bodyCount -> 100 }
		warmupSteps: 20
		measuredSteps: 120
]

{ #category : 'benchmarks' }
CFPhysicsTelemetryBenchmarkExamples >> optimisationBenchmarkSuite [
	<gtExample>
	^ CFPhysicsTelemetryBenchmarkSuite results: {
		self sleepingBodiesBenchmark.
		self densePileBenchmark.
		self independentIslandsBenchmark.
		self singleIslandBenchmark.
		self sensorOverlapBenchmark }
]
