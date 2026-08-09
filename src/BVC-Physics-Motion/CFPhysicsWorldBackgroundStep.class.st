"
I represent one asynchronous Physics solve for a world.

My responsibility is to capture the configured pipeline task, execute its solve in the Physics Pipeline future group, and return the resulting solution to the owning Bloc element for commit.
"
Class {
	#name : 'CFPhysicsWorldBackgroundStep',
	#superclass : 'Object',
	#instVars : [ 'world', 'state', 'pipeline', 'telemetryEnabled', 'telemetryContext', 'task' ],
	#category : 'BVC-Physics-Motion',
	#package : 'BVC-Physics-Motion'
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
			telemetryContext
				recordSolutionFrom: [ pipeline solveWithTelemetry: state ]
				pipeline: pipeline ]
]
