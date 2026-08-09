"
I provide executable regression examples for the Physics and Motion integration boundary.

My responsibility is to verify fixed-step playback, background solve coordination, presentation cadence, shared frame-driver behaviour and lifecycle cleanup using focused test doubles.
"
Class {
	#name : 'CFPhysicsMotionTests',
	#superclass : 'TestCase',
	#category : 'BVC-Physics-Tests-Core',
	#package : 'BVC-Physics-Tests-Core'
}

{ #category : 'examples - motion integration' }
CFPhysicsMotionTests >> testPhysicsWorldBehaviourAdvancesDeterministicFixedSteps [
	<gtExample>
	| space owner world presentation behaviour timeline track motion |
	space := BlSpace new.
	space time: BlTime simulated.
	owner := BlElement new size: 320 @ 200.
	space root addChild: owner.
	space pulse.
	world := CFPhysicsWorldStepRecorder new
		owner: owner;
		stepDuration: 16 milliSeconds;
		yourself.
	presentation := CFPhysicsFrameConsumerRecorder new.
	behaviour := CFPhysicsWorldMotionBehaviour on: world frameConsumer: presentation.
	timeline := CFMotionTimeline new.
	track := (CFMotionTimelineTrack on: behaviour in: timeline) indefinite.
	motion := (CFMotion timeline: timeline coordinator: space cfMotionCoordinator) start.
	space pulse.
	self assert: presentation presentationCount equals: 1.
	self assert: world stepCount equals: 0.
	space time wait: 10 milliSeconds.
	space pulse.
	self assert: world stepCount equals: 0.
	self assert: presentation presentationCount equals: 2.
	self assert: (presentation lastPresentationAlpha closeTo: 0.625).
	space time wait: 10 milliSeconds.
	space pulse.
	self assert: world stepCount equals: 1.
	self assert: presentation presentationCount equals: 3.
	self assert: (presentation lastPresentationAlpha closeTo: 0.25).
	space time wait: 30 milliSeconds.
	space pulse.
	self assert: world stepCount equals: 3.
	self assert: presentation presentationCount equals: 4.
	self assert: (presentation lastPresentationAlpha closeTo: 0.125).
	self assert: motion isRunning.
	motion cancel.
	self assert: behaviour isActive not.
	self assert: space cfMotionCoordinator hasActiveMotions not.
	^ track
]

{ #category : 'examples - motion integration' }
CFPhysicsMotionTests >> testBackgroundPhysicsPlaybackRetainsFixedStepDebt [
	<gtExample>
	| space owner world presentation behaviour timeline motion |
	space := BlSpace new.
	space time: BlTime simulated.
	owner := BlElement new size: 320 @ 200.
	space root addChild: owner.
	space pulse.
	world := CFPhysicsWorldStepRecorder new
		owner: owner;
		stepDuration: 10 milliSeconds;
		backgroundStepping: true;
		yourself.
	presentation := CFPhysicsFrameConsumerRecorder new.
	behaviour := CFPhysicsWorldMotionBehaviour on: world frameConsumer: presentation.
	timeline := CFMotionTimeline new.
	(CFMotionTimelineTrack on: behaviour in: timeline) indefinite.
	motion := (CFMotion timeline: timeline coordinator: space cfMotionCoordinator) start.
	space pulse.
	space time wait: 100 milliSeconds.
	space pulse.
	self assert: world backgroundStepCount equals: 1.
	self assert: world stepCount equals: 0.
	self assert: world hasSolveInFlight.
	self assert: behaviour accumulatedTime equals: 90 milliSeconds.
	self assert: presentation lastPresentationAlpha equals: 1.0.
	space time wait: 100 milliSeconds.
	space pulse.
	self assert: world backgroundStepCount equals: 1.
	self assert: behaviour accumulatedTime equals: 190 milliSeconds.
	self assert: presentation lastPresentationAlpha equals: 1.0.
	world completeBackgroundStep.
	space time wait: 1 milliSecond.
	space pulse.
	self assert: world backgroundStepCount equals: 2.
	self assert: behaviour accumulatedTime equals: 181 milliSeconds.
	motion cancel.
	self assert: world hasSolveInFlight not.
	^ behaviour
]

{ #category : 'examples - motion integration' }
CFPhysicsMotionTests >> testIndependentPhysicsWorldBehavioursShareOneFrameDriver [
	<gtExample>
	| space firstOwner secondOwner firstWorld secondWorld firstBehaviour secondBehaviour firstTimeline secondTimeline firstMotion secondMotion coordinator |
	space := BlSpace new.
	space time: BlTime simulated.
	firstOwner := BlElement new size: 160 @ 120.
	secondOwner := BlElement new size: 160 @ 120.
	space root addChild: firstOwner.
	space root addChild: secondOwner.
	space pulse.
	firstWorld := CFPhysicsWorldStepRecorder new
		owner: firstOwner;
		stepDuration: 10 milliSeconds;
		yourself.
	secondWorld := CFPhysicsWorldStepRecorder new
		owner: secondOwner;
		stepDuration: 15 milliSeconds;
		yourself.
	firstBehaviour := CFPhysicsWorldMotionBehaviour on: firstWorld frameConsumer: CFPhysicsFrameConsumerRecorder new.
	secondBehaviour := CFPhysicsWorldMotionBehaviour on: secondWorld frameConsumer: CFPhysicsFrameConsumerRecorder new.
	firstTimeline := CFMotionTimeline new.
	(CFMotionTimelineTrack on: firstBehaviour in: firstTimeline) indefinite.
	secondTimeline := CFMotionTimeline new.
	(CFMotionTimelineTrack on: secondBehaviour in: secondTimeline) indefinite.
	coordinator := space cfMotionCoordinator.
	firstMotion := (CFMotion timeline: firstTimeline coordinator: coordinator) start.
	secondMotion := (CFMotion timeline: secondTimeline coordinator: coordinator) start.
	space pulse.
	self assert: coordinator activeMotions size equals: 2.
	self assert: coordinator frameDriver isActive.
	space time wait: 30 milliSeconds.
	space pulse.
	self assert: firstWorld stepCount equals: 3.
	self assert: secondWorld stepCount equals: 2.
	firstMotion cancel.
	self assert: firstBehaviour isActive not.
	self assert: secondBehaviour isActive.
	self assert: coordinator activeMotions size equals: 1.
	space time wait: 15 milliSeconds.
	space pulse.
	self assert: firstWorld stepCount equals: 3.
	self assert: secondWorld stepCount equals: 3.
	secondMotion cancel.
	self assert: coordinator hasActiveMotions not.
	self assert: coordinator frameDriver isActive not.
	^ coordinator
]

{ #category : 'examples - motion integration' }
CFPhysicsMotionTests >> testDetachedPhysicsWorldOwnerEndsPlaybackCleanly [
	<gtExample>
	| space owner world behaviour timeline motion stepCountBeforeDetachment |
	space := BlSpace new.
	space time: BlTime simulated.
	owner := BlElement new size: 320 @ 200.
	space root addChild: owner.
	space pulse.
	world := CFPhysicsWorldStepRecorder new
		owner: owner;
		stepDuration: 10 milliSeconds;
		yourself.
	behaviour := CFPhysicsWorldMotionBehaviour on: world frameConsumer: CFPhysicsFrameConsumerRecorder new.
	timeline := CFMotionTimeline new.
	(CFMotionTimelineTrack on: behaviour in: timeline) indefinite.
	motion := (CFMotion timeline: timeline coordinator: space cfMotionCoordinator) start.
	space pulse.
	space time wait: 20 milliSeconds.
	space pulse.
	self assert: world stepCount equals: 2.
	stepCountBeforeDetachment := world stepCount.
	owner removeFromParent.
	space pulse.
	self assert: motion isCancelled.
	self assert: behaviour isActive not.
	self assert: world stepCount equals: stepCountBeforeDetachment.
	self assert: space cfMotionCoordinator hasActiveMotions not.
	^ behaviour
]

{ #category : 'examples - motion integration' }
CFPhysicsMotionTests >> testRestartingPhysicsSteppingBeginsAtCleanStepBoundary [
	<gtExample>
	| space owner world firstBehaviour firstTimeline firstMotion secondBehaviour secondTimeline secondMotion |
	space := BlSpace new.
	space time: BlTime simulated.
	owner := BlElement new size: 320 @ 200.
	space root addChild: owner.
	space pulse.
	world := CFPhysicsWorldStepRecorder new
		owner: owner;
		stepDuration: 10 milliSeconds;
		yourself.
	firstBehaviour := CFPhysicsWorldMotionBehaviour on: world frameConsumer: CFPhysicsFrameConsumerRecorder new.
	firstTimeline := CFMotionTimeline new.
	(CFMotionTimelineTrack on: firstBehaviour in: firstTimeline) indefinite.
	firstMotion := (CFMotion timeline: firstTimeline coordinator: space cfMotionCoordinator) start.
	space pulse.
	space time wait: 15 milliSeconds.
	space pulse.
	self assert: world stepCount equals: 1.
	firstMotion cancel.
	self assert: firstBehaviour isActive not.
	secondBehaviour := CFPhysicsWorldMotionBehaviour on: world frameConsumer: CFPhysicsFrameConsumerRecorder new.
	secondTimeline := CFMotionTimeline new.
	(CFMotionTimelineTrack on: secondBehaviour in: secondTimeline) indefinite.
	secondMotion := (CFMotion timeline: secondTimeline coordinator: space cfMotionCoordinator) start.
	space pulse.
	self assert: world stepCount equals: 1.
	self assert: secondBehaviour accumulatedTime equals: 0 milliSeconds.
	secondMotion cancel.
	^ secondBehaviour
]

{ #category : 'examples - motion integration' }
CFPhysicsMotionTests >> testBackgroundToForegroundRebasesAccumulatedTimeAtOneStep [
	<gtExample>
	| space owner world presentation behaviour timeline motion |
	space := BlSpace new.
	space time: BlTime simulated.
	owner := BlElement new size: 320 @ 200.
	space root addChild: owner.
	space pulse.
	world := CFPhysicsWorldStepRecorder new
		owner: owner;
		stepDuration: 10 milliSeconds;
		backgroundStepping: true;
		yourself.
	presentation := CFPhysicsFrameConsumerRecorder new.
	behaviour := CFPhysicsWorldMotionBehaviour on: world frameConsumer: presentation.
	timeline := CFMotionTimeline new.
	(CFMotionTimelineTrack on: behaviour in: timeline) indefinite.
	motion := (CFMotion timeline: timeline coordinator: space cfMotionCoordinator) start.
	space pulse.
	space time wait: 100 milliSeconds.
	space pulse.
	self assert: world backgroundStepCount equals: 1.
	self assert: world hasSolveInFlight.
	self assert: behaviour accumulatedTime equals: 90 milliSeconds.
	world backgroundStepping: false.
	self assert: world hasSolveInFlight not.
	space time wait: 5 milliSeconds.
	space pulse.
	self assert: world stepCount equals: 1.
	self assert: behaviour accumulatedTime equals: 0 milliSeconds.
	self assert: presentation lastPresentationAlpha equals: 0.0.
	space time wait: 5 milliSeconds.
	space pulse.
	self assert: world stepCount equals: 1.
	self assert: behaviour accumulatedTime equals: 5 milliSeconds.
	self assert: (presentation lastPresentationAlpha closeTo: 0.5).
	motion cancel.
	^ behaviour
]

{ #category : 'examples - motion integration' }
CFPhysicsMotionTests >> testBackgroundPlaybackContinuesPresentingWhileSolveIsInFlight [
	<gtExample>
	| space owner world presentation behaviour timeline motion initialPresentationCount |
	space := BlSpace new.
	space time: BlTime simulated.
	owner := BlElement new size: 320 @ 200.
	space root addChild: owner.
	space pulse.
	world := CFPhysicsWorldStepRecorder new
		owner: owner;
		stepDuration: 10 milliSeconds;
		backgroundStepping: true;
		yourself.
	presentation := CFPhysicsFrameConsumerRecorder new.
	behaviour := CFPhysicsWorldMotionBehaviour on: world frameConsumer: presentation.
	timeline := CFMotionTimeline new.
	(CFMotionTimelineTrack on: behaviour in: timeline) indefinite.
	motion := (CFMotion timeline: timeline coordinator: space cfMotionCoordinator) start.
	space pulse.
	space time wait: 10 milliSeconds.
	space pulse.
	self assert: world backgroundStepCount equals: 1.
	self assert: world hasSolveInFlight.
	initialPresentationCount := presentation presentationCount.
	3 timesRepeat: [
		space time wait: 5 milliSeconds.
		space pulse ].
	self assert: presentation presentationCount equals: initialPresentationCount + 3.
	self assert: world backgroundStepCount equals: 1.
	self assert: world hasSolveInFlight.
	self assert: presentation lastPresentationAlpha equals: 1.0.
	motion cancel.
	^ behaviour
]
