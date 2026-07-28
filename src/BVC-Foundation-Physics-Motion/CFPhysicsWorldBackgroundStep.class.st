"
I dispatch one captured Physics solve through GT's asynchronous future execution and return its publication to the owning Bloc element.

Capture and commit remain on the Bloc process. Only #solve: executes in the future group. I never wait for the worker and I never queue more than one solve because CFPhysicsWorld>>#captureStateIfIdle owns that gate.
"
Class {
	#name : 'CFPhysicsWorldBackgroundStep',
	#superclass : 'Object',
	#instVars : [ 'world', 'state', 'task' ],
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
		customGroup: #Physics
]

{ #category : 'accessing' }
CFPhysicsWorldBackgroundStep >> state [
	^ state
]

{ #category : 'accessing' }
CFPhysicsWorldBackgroundStep >> task [
	^ task
]

{ #category : 'starting' }
CFPhysicsWorldBackgroundStep >> start [
	| owner |
	owner := world owner.
	owner ifNil: [ ^ false ].
	state := world captureStateIfIdle.
	state ifNil: [ ^ false ].
	task := BlEnqueuedFutureAction new
		name: 'Physics solve';
		action: [ world stepPipeline solve: state ];
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
