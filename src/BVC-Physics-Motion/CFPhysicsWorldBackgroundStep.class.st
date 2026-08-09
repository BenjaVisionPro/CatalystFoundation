"
I represent one asynchronous Physics solve for a world.

My responsibility is to capture the configured pipeline task, execute its solve in the Physics Pipeline future group, and return the resulting solution to the owning Bloc element for commit.
"
Class {
	#name : 'CFPhysicsWorldBackgroundStep',
	#superclass : 'Object',
	#instVars : [ 'world', 'state', 'pipeline', 'telemetryEnabled', 'telemetryContext', 'promise' ],
	#category : 'BVC-Physics-Motion',
	#package : 'BVC-Physics-Motion'
}

{ #category : 'instance creation' }
CFPhysicsWorldBackgroundStep class >> on: aPhysicsWorld [
	^ self new
		world: aPhysicsWorld;
		yourself
]


{ #category : 'accessing' }
CFPhysicsWorldBackgroundStep >> pipeline [
	^ pipeline
]

{ #category : 'accessing' }
CFPhysicsWorldBackgroundStep >> state [
	^ state
]


{ #category : 'accessing' }
CFPhysicsWorldBackgroundStep >> telemetryEnabled [
	^ telemetryEnabled
]

{ #category : 'accessing' }
CFPhysicsWorldBackgroundStep >> promise [
	^ promise
]

{ #category : 'starting' }
CFPhysicsWorldBackgroundStep >> start [
	| owner |
	owner := world owner.
	(owner notNil and: [ owner isAttachedToSceneGraph ]) ifFalse: [ ^ false ].
	pipeline := world stepPipeline.
	telemetryEnabled := world telemetryEnabled.
	state := world captureStateIfIdle.
	state ifNil: [ ^ false ].
	(world claimBackgroundExecution: self) ifFalse: [
		world abandonSolveTicket: state solveTicket.
		^ false ].
	telemetryEnabled ifTrue: [
		telemetryContext := world telemetryContextForState: state ].
	promise := [ self solveCapturedState ]
		asAsyncPromiseWithPriority: AsyncFutureExecutionHighPriority uniqueInstance
		inCustomGroup: #'Physics Pipeline'.
	promise
		then: [ :solution |
			world backgroundExecutionFinished: self.
			owner enqueueTask: (BlTaskAction new action: [
				world commit: solution ]) ]
		otherwise: [ :anError |
			world backgroundExecutionFinished: self.
			owner enqueueTask: (BlTaskAction new action: [
				world abandonSolveTicket: state solveTicket.
				anError class = AsyncFutureCancelled ifFalse: [
					NonInteractiveTranscript stdout
						nextPutAll: anError printString;
						cr ] ]) ].
	^ true
]

{ #category : 'private - initialization' }
CFPhysicsWorldBackgroundStep >> world: aPhysicsWorld [
	world := aPhysicsWorld
]


{ #category : 'private - solving' }
CFPhysicsWorldBackgroundStep >> solveCapturedState [
	Processor activeProcess name: 'Physics Pipeline'.
	telemetryEnabled ifFalse: [ ^ pipeline solve: state ].
	^ ProcessTelemetry
		rootTimeSync: [ 'Physics step' ]
		during: [
			telemetryContext
				recordSolutionFrom: [ pipeline solveWithTelemetry: state ]
				pipeline: pipeline ]
]
