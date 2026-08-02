"I run a Physics world through an optional warm-up period and capture a fixed number of telemetry-enabled steps for automated tests.

I deliberately separate warm-up from measurement. Warm-up steps execute without telemetry, then the world's telemetry buffer is reset before measured steps begin. After the run I retain immutable snapshots of the recordings and their Physics data so assertions do not depend on the inspector UI or on the logger remaining active."
Class {
	#name : 'CFPhysicsTelemetryTestRun',
	#superclass : 'Object',
	#instVars : [ 'world', 'warmUpStepCount', 'measuredStepCount', 'recordings', 'physicsData' ],
	#category : 'BVC-Physics-Tests-Core',
	#package : 'BVC-Physics-Tests-Core'
}

{ #category : 'instance creation' }
CFPhysicsTelemetryTestRun class >> world: aWorld warmUpSteps: warmUpSteps measuredSteps: measuredSteps [
	^ self new
		world: aWorld;
		warmUpStepCount: warmUpSteps;
		measuredStepCount: measuredSteps;
		run;
		yourself
]

{ #category : 'initialization' }
CFPhysicsTelemetryTestRun >> initialize [
	super initialize.
	warmUpStepCount := 0.
	measuredStepCount := 1.
	recordings := #().
	physicsData := #()
]

{ #category : 'accessing' }
CFPhysicsTelemetryTestRun >> world [
	^ world
]

{ #category : 'accessing' }
CFPhysicsTelemetryTestRun >> world: aWorld [
	world := aWorld
]

{ #category : 'accessing' }
CFPhysicsTelemetryTestRun >> warmUpStepCount [
	^ warmUpStepCount
]

{ #category : 'accessing' }
CFPhysicsTelemetryTestRun >> warmUpStepCount: anInteger [
	self assert: anInteger >= 0.
	warmUpStepCount := anInteger
]

{ #category : 'accessing' }
CFPhysicsTelemetryTestRun >> measuredStepCount [
	^ measuredStepCount
]

{ #category : 'accessing' }
CFPhysicsTelemetryTestRun >> measuredStepCount: anInteger [
	self assert: anInteger > 0.
	measuredStepCount := anInteger
]

{ #category : 'running' }
CFPhysicsTelemetryTestRun >> run [
	| telemetryWasEnabled previousCapacity |
	self assert: world notNil.
	telemetryWasEnabled := world telemetryEnabled.
	previousCapacity := world telemetryCapacity.
	[
		world telemetryEnabled: false.
		world step: warmUpStepCount.
		world telemetryCapacity: measuredStepCount.
		world telemetryEnabled: true.
		world resetTelemetry.
		world step: measuredStepCount.
		recordings := world telemetryRecordings copy.
		physicsData := recordings collect: [ :each | each physicsData copy ]
	] ensure: [
		world telemetryCapacity: previousCapacity.
		world telemetryEnabled: telemetryWasEnabled ].
	^ self
]

{ #category : 'accessing' }
CFPhysicsTelemetryTestRun >> recordings [
	^ recordings
]

{ #category : 'accessing' }
CFPhysicsTelemetryTestRun >> physicsData [
	^ physicsData
]

{ #category : 'accessing' }
CFPhysicsTelemetryTestRun >> sampleCount [
	^ recordings size
]

{ #category : 'accessing' }
CFPhysicsTelemetryTestRun >> latestRecording [
	^ recordings ifEmpty: [ nil ] ifNotEmpty: [ recordings last ]
]

{ #category : 'accessing' }
CFPhysicsTelemetryTestRun >> latestPhysicsData [
	^ physicsData ifEmpty: [ nil ] ifNotEmpty: [ physicsData last ]
]

{ #category : 'accessing' }
CFPhysicsTelemetryTestRun >> valuesAt: aKey [
	^ physicsData collect: [ :each | each at: aKey ]
]

{ #category : 'accessing' }
CFPhysicsTelemetryTestRun >> analysis [
	^ CFPhysicsTelemetryAnalysis
		recordings: recordings
		windowSeconds: 3600
]
