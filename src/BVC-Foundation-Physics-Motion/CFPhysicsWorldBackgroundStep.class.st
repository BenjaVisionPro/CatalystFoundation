"
I dispatch one captured Physics solve through GT's asynchronous future execution and return its publication to the owning Bloc element.

Capture and commit remain on the Bloc process. Only #solve: executes in the future group. I never wait for the worker and I never queue more than one solve because CFPhysicsWorld>>#captureStateIfIdle owns that gate.
"
Class {
	#name : 'CFPhysicsWorldBackgroundStep',
	#superclass : 'Object',
	#instVars : [ 'world', 'state', 'pipeline', 'telemetryEnabled', 'telemetryContext', 'task' ],
	#category : 'BVC-Foundation-Physics-Motion',
	#package : 'BVC-Foundation-Physics-Motion'
}

{ #category : 'instance creation' }
CFPhysicsWorldBackgroundStep class >> on: aPhysicsWorld [
	^ self new
		world: aPhysicsWorld;
		yourself
]

{ #category : 'private - configuration' }
CFPhysicsWorldBackgroundStep >> futureConfiguration [
	^ AsyncFutureExecutionConfiguration new
		customGroup: #'Physics Pipeline'
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
CFPhysicsWorldBackgroundStep >> task [
	^ task
]

{ #category : 'starting' }
CFPhysicsWorldBackgroundStep >> start [
	| owner |
	owner := world owner.
	(owner notNil and: [ owner isAttachedToSceneGraph ]) ifFalse: [ ^ false ].
	world discardDetachedTelemetrySignals.
	pipeline := world stepPipeline.
	telemetryEnabled := world telemetryEnabled.
	state := world captureStateIfIdle.
	state ifNil: [ ^ false ].
	telemetryEnabled ifTrue: [
		telemetryContext := world telemetryContextForState: state ].
	task := BlEnqueuedFutureAction new
		name: 'Physics Pipeline';
		action: [ self solveCapturedState ];
		futureConfiguration: self futureConfiguration;
		onSuccessEnqueueAction: [ :solution |
			world commit: solution ];
		onFailureEnqueueAction: [ :anError |
			world abandonSolveTicket: state solveTicket.
			anError class = AsyncFutureCancelled ifFalse: [
				NonInteractiveTranscript stdout
					nextPutAll: anError printString;
					cr ] ];
		yourself.
	owner enqueueTask: task.
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
			ProcessTelemetry
				profile: [ pipeline solveWithTelemetry: state ]
				executing: [ :run |
					| solution |
					solution := run value.
					telemetryContext
						dataForSolution: solution
						pipeline: pipeline ]
				as: #physicsFrame ]
]
