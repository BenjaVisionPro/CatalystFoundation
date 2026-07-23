"
I advance one CFPhysicsWorld as an indefinite Motion Behaviour.

My playback lifetime is explicit. I become active when Motion starts me and inactive when that playback ends by completion or cancellation. Pause and resume preserve that same lifetime. Once inactive I retain no presentation-frame remainder, so a later playback always begins from a clean fixed-step boundary.

I adapt Motion's presentation-frame cadence to Physics' deterministic fixed step. Each evaluation contributes the increase in local Motion time to an accumulator. I advance the world in whole #stepDuration increments and retain any remainder for a later frame. A zero-time initial Motion frame performs no Physics step; a long presentation frame may perform several fixed steps.

I own no frame scheduling, timeline placement, frame-consumer lifetime, Physics solver policy or visual property claim. CFMotionCoordinator supplies shared frames, CFMotionTimelineTrack places me in time, and CFPhysicsWorld owns its step configuration and simulation state. My propertyKey remains nil because a Physics world may present many elements rather than exclusively owning one Motion property.

After stepping I publish the interpolation alpha through the small #frameReadyAtAlpha: consumer protocol. I do not know whether that consumer presents, records, profiles or ignores the frame.

My animation target is the world's owner element. Normal Motion validity therefore cancels playback if that owner leaves or moves away from the coordinator's BlSpace.
"
Class {
	#name : 'CFPhysicsWorldMotionBehaviour',
	#superclass : 'CFMotionBehaviour',
	#instVars : [ 'world', 'previousLocalTime', 'accumulatedTime', 'active', 'frameConsumer' ],
	#category : 'BVC-Foundation-Physics-Motion',
	#package : 'BVC-Foundation-Physics-Motion'
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
	| elapsed stepDuration |
	active ifFalse: [ self error: 'A Physics world Behaviour cannot evaluate outside its playback lifetime' ].
	elapsed := anEvaluation localTime - previousLocalTime.
	elapsed < (0 milliSeconds) ifTrue: [
		self error: 'A Physics Motion Behaviour cannot move backwards in time' ].
	previousLocalTime := anEvaluation localTime.
	accumulatedTime := accumulatedTime + elapsed.
	stepDuration := world stepDuration.
	[ accumulatedTime >= stepDuration ] whileTrue: [
		world step.
		accumulatedTime := accumulatedTime - stepDuration ].
	frameConsumer
		frameReadyAtAlpha: (accumulatedTime asMilliSeconds / stepDuration asMilliSeconds)
]

{ #category : 'initialization' }
CFPhysicsWorldMotionBehaviour >> initialize [
	super initialize.
	previousLocalTime := 0 milliSeconds.
	accumulatedTime := 0 milliSeconds.
	active := false
]

{ #category : 'playing' }
CFPhysicsWorldMotionBehaviour >> playbackStartedIn: aCoordinator [
	previousLocalTime := 0 milliSeconds.
	accumulatedTime := 0 milliSeconds.
	active := true
]

{ #category : 'playing' }
CFPhysicsWorldMotionBehaviour >> playbackEndedWith: aMotionState [
	active := false.
	previousLocalTime := 0 milliSeconds.
	accumulatedTime := 0 milliSeconds
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
