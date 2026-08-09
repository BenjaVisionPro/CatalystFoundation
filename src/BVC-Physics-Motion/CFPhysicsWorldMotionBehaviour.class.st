"
I adapt Motion playback frames to the fixed-step progression of one Physics world.

My responsibility is to accumulate elapsed Motion time, request synchronous or background simulation steps, and publish the presentation fraction for each frame.
"
Class {
	#name : 'CFPhysicsWorldMotionBehaviour',
	#superclass : 'CFMotionBehaviour',
	#instVars : [ 'world', 'previousLocalTime', 'accumulatedTime', 'active', 'frameConsumer', 'previousBackgroundStepping' ],
	#category : 'BVC-Physics-Motion',
	#package : 'BVC-Physics-Motion'
}

{ #category : 'instance creation' }
CFPhysicsWorldMotionBehaviour class >> on: aPhysicsWorld frameConsumer: aFrameConsumer [
	^ self new
		world: aPhysicsWorld;
		frameConsumer: aFrameConsumer;
		yourself
]

{ #category : 'accessing' }
CFPhysicsWorldMotionBehaviour >> animationTarget [
	^ world owner
]

{ #category : 'evaluating' }
CFPhysicsWorldMotionBehaviour >> evaluate: anEvaluation [
	| elapsed stepDuration alpha backgroundStepping |
	active ifFalse: [ self error: 'A Physics world Behaviour cannot evaluate outside its playback lifetime' ].
	elapsed := anEvaluation localTime - previousLocalTime.
	elapsed < (0 milliSeconds) ifTrue: [
		self error: 'A Physics Motion Behaviour cannot move backwards in time' ].
	previousLocalTime := anEvaluation localTime.
	stepDuration := world stepDuration.
	backgroundStepping := world backgroundStepping.
	(backgroundStepping not and: [ world hasBackgroundExecutionInFlight ]) ifTrue: [
		accumulatedTime := stepDuration.
		frameConsumer frameReadyAtAlpha: 1.0.
		^ self ].
	(previousBackgroundStepping and: [ backgroundStepping not ])
		ifTrue: [ accumulatedTime := stepDuration ]
		ifFalse: [ accumulatedTime := accumulatedTime + elapsed ].
	backgroundStepping
		ifTrue: [ self startBackgroundStepFor: stepDuration ]
		ifFalse: [ self performSynchronousStepsFor: stepDuration ].
	previousBackgroundStepping := backgroundStepping.
	alpha := accumulatedTime asMilliSeconds / stepDuration asMilliSeconds.
	frameConsumer frameReadyAtAlpha: (alpha min: 1.0)
]

{ #category : 'private - evaluating' }
CFPhysicsWorldMotionBehaviour >> performSynchronousStepsFor: aStepDuration [
	[ accumulatedTime >= aStepDuration ] whileTrue: [
		world step ifNil: [ ^ self ].
		accumulatedTime := accumulatedTime - aStepDuration ]
]

{ #category : 'private - evaluating' }
CFPhysicsWorldMotionBehaviour >> startBackgroundStepFor: aStepDuration [
	accumulatedTime >= aStepDuration ifFalse: [ ^ self ].
	world startBackgroundStep ifTrue: [
		accumulatedTime := accumulatedTime - aStepDuration ]
]

{ #category : 'initialization' }
CFPhysicsWorldMotionBehaviour >> initialize [
	super initialize.
	previousLocalTime := 0 milliSeconds.
	accumulatedTime := 0 milliSeconds.
	active := false.
	previousBackgroundStepping := false
]

{ #category : 'playing' }
CFPhysicsWorldMotionBehaviour >> playbackStartedIn: aCoordinator [
	previousLocalTime := 0 milliSeconds.
	accumulatedTime := 0 milliSeconds.
	previousBackgroundStepping := world backgroundStepping.
	active := true
]

{ #category : 'playing' }
CFPhysicsWorldMotionBehaviour >> playbackEndedWith: aMotionState [
	world abandonActiveSolve.
	active := false.
	previousLocalTime := 0 milliSeconds.
	accumulatedTime := 0 milliSeconds.
	previousBackgroundStepping := false
]

{ #category : 'testing' }
CFPhysicsWorldMotionBehaviour >> isActive [
	^ active
]

{ #category : 'accessing' }
CFPhysicsWorldMotionBehaviour >> accumulatedTime [
	^ accumulatedTime
]

{ #category : 'controlling' }
CFPhysicsWorldMotionBehaviour >> reversed [
	self error: 'A Physics world Behaviour cannot be reversed'
]

{ #category : 'private - validation' }
CFPhysicsWorldMotionBehaviour >> validateForExecution [
	world ifNil: [ self error: 'A Physics world Behaviour needs a world' ].
	frameConsumer ifNil: [ self error: 'A Physics world Behaviour needs a frame consumer' ].
	world owner ifNil: [ self error: 'A Physics world Behaviour needs an owner element' ].
	world stepDuration <= (0 milliSeconds) ifTrue: [
		self error: 'A Physics world step duration must be positive' ]
]

{ #category : 'accessing' }
CFPhysicsWorldMotionBehaviour >> world [
	^ world
]

{ #category : 'private - initialization' }
CFPhysicsWorldMotionBehaviour >> world: aPhysicsWorld [
	world := aPhysicsWorld
]

{ #category : 'private - initialization' }
CFPhysicsWorldMotionBehaviour >> frameConsumer: aFrameConsumer [
	frameConsumer := aFrameConsumer
]
