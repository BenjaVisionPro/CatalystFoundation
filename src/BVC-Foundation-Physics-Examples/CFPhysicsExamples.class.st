Class {
	#name : 'CFPhysicsExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Physics-Examples',
	#package : 'BVC-Foundation-Physics-Examples'
}

{ #category : 'examples - bodies' }
CFPhysicsExamples >> bodies [
	<gtExample>
	| host circle rectangle world |
	host := BlElement new
		size: 500 @ 320;
		background: Color veryVeryLightGray;
		yourself.
	circle := BlElement new
		geometry: BlCircleGeometry new;
		size: 54 @ 54;
		background: Color lightBlue;
		yourself.
	rectangle := BlElement new
		geometry: (BlRoundedRectangleGeometry cornerRadii: (BlCornerRadii radius: 8));
		size: 100 @ 58;
		background: Color lightGreen;
		yourself.
	host addChild: circle.
	host addChild: rectangle.
	world := host physics beWorld.
	world synchroniseMembership.
	(world bodyStateFor: circle)
		position: 75 @ 65;
		velocity: 45 @ 20.
	(world bodyStateFor: rectangle)
		position: 265 @ 150;
		rotation: Float pi / 10.0.
	^ host
]

{ #category : 'examples - bodies' }
CFPhysicsExamples >> bodiesAfterStepping [
	<gtExample>
	| host world |
	host := self bodies.
	world := host physics existingWorld.
	world step: 30.
	world present.
	^ host
]

{ #category : 'examples - motion integration' }
CFPhysicsExamples >> physicsWorldBehaviourAdvancesDeterministicFixedSteps [
	<gtExample>
	| space owner world behaviour timeline track motion |
	space := BlSpace new.
	space time: BlTime simulated.
	owner := BlElement new size: 320 @ 200.
	space root addChild: owner.
	space pulse.
	world := CFPhysicsWorldStepRecorder new
		owner: owner;
		stepDuration: 16 milliSeconds;
		yourself.
	behaviour := CFPhysicsWorldBehaviour on: world.
	timeline := CFMotionTimeline new.
	track := (CFMotionTimelineTrack on: behaviour in: timeline) indefinite.
	motion := (CFMotion timeline: timeline coordinator: space cfMotionCoordinator) start.
	space pulse.
	self assert: world synchronisationCount equals: 1.
	self assert: world presentationCount equals: 2.
	self assert: world stepCount equals: 0.
	self assert: world presentationCount equals: 3.
	space time wait: 10 milliSeconds.
	space pulse.
	self assert: world stepCount equals: 0.
	space time wait: 10 milliSeconds.
	space pulse.
	self assert: world stepCount equals: 1.
	self assert: world presentationCount equals: 4.
	space time wait: 30 milliSeconds.
	space pulse.
	self assert: world stepCount equals: 3.
	self assert: world presentationCount equals: 5.
	self assert: motion isRunning.
	motion cancel.
	self assert: space cfMotionCoordinator hasActiveMotions not.
	^ track
]

{ #category : 'examples - motion integration' }
CFPhysicsExamples >> physicsWorldOwnsContinuousMotionStepping [
	<gtExample>
	| space host body world initialPosition motion |
	space := BlSpace new.
	space time: BlTime simulated.
	host := BlElement new size: 500 @ 320.
	body := BlElement new
		geometry: BlCircleGeometry new;
		size: 40 @ 40;
		yourself.
	host addChild: body.
	space root addChild: host.
	space pulse.
	world := host physics beWorld.
	world gravity: 0 @ 0.
	world stepDuration: 10 milliSeconds.
	world synchroniseMembership.
	(world bodyStateFor: body)
		position: 40 @ 40;
		velocity: 100 @ 0.
	initialPosition := (world bodyStateFor: body) position.
	motion := world startStepping.
	self assert: world isStepping.
	self assert: world steppingMotion == motion.
	space pulse.
	space time wait: 20 milliSeconds.
	space pulse.
	self assert: (world bodyStateFor: body) position x > initialPosition x.
	world stopStepping.
	self assert: world isStepping not.
	self assert: world steppingMotion isNil.
	^ host
]


{ #category : 'examples - motion integration' }
CFPhysicsExamples >> independentPhysicsWorldBehavioursShareOneFrameDriver [
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
	firstBehaviour := CFPhysicsWorldBehaviour on: firstWorld.
	secondBehaviour := CFPhysicsWorldBehaviour on: secondWorld.
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
CFPhysicsExamples >> physicsWorldControlsItsSteppingLifecycle [
	<gtExample>
	| space owner body world firstMotion positionBeforePause positionWhilePaused |
	space := BlSpace new.
	space time: BlTime simulated.
	owner := BlElement new size: 320 @ 200.
	body := BlElement new size: 20 @ 20.
	owner addChild: body.
	space root addChild: owner.
	space pulse.
	world := owner physics beWorld.
	world
		gravity: 0 @ 0;
		stepDuration: 10 milliSeconds;
		synchroniseMembership.
	(world bodyStateFor: body)
		position: 20 @ 20;
		velocity: 100 @ 0.
	firstMotion := world startStepping.
	self assert: world startStepping == firstMotion.
	space pulse.
	space time wait: 20 milliSeconds.
	space pulse.
	positionBeforePause := (world bodyStateFor: body) position.
	world pauseStepping.
	self assert: firstMotion isPaused.
	space time wait: 40 milliSeconds.
	space pulse.
	positionWhilePaused := (world bodyStateFor: body) position.
	self assert: positionWhilePaused equals: positionBeforePause.
	world resumeStepping.
	self assert: firstMotion isRunning.
	space pulse.
	space time wait: 10 milliSeconds.
	space pulse.
	self assert: (world bodyStateFor: body) position x > positionWhilePaused x.
	world stopStepping.
	self assert: firstMotion isCancelled.
	self assert: world steppingMotion isNil.
	^ world
]


{ #category : 'examples - motion integration' }
CFPhysicsExamples >> detachedPhysicsWorldOwnerEndsPlaybackCleanly [
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
	behaviour := CFPhysicsWorldBehaviour on: world.
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
CFPhysicsExamples >> startSteppingResumesTheExistingPausedMotion [
	<gtExample>
	| space owner world motion |
	space := BlSpace new.
	space time: BlTime simulated.
	owner := BlElement new size: 320 @ 200.
	space root addChild: owner.
	space pulse.
	world := owner physics beWorld.
	motion := world startStepping.
	space pulse.
	world pauseStepping.
	self assert: motion isPaused.
	self assert: world startStepping == motion.
	self assert: motion isRunning.
	world stopStepping.
	^ world
]

{ #category : 'examples - motion integration' }
CFPhysicsExamples >> physicsWorldRestartsAfterOwnerDetachment [
	<gtExample>
	| space owner world firstMotion secondMotion |
	space := BlSpace new.
	space time: BlTime simulated.
	owner := BlElement new size: 320 @ 200.
	space root addChild: owner.
	space pulse.
	world := owner physics beWorld.
	world stepDuration: 10 milliSeconds.
	firstMotion := world startStepping.
	space pulse.
	owner removeFromParent.
	space pulse.
	self assert: firstMotion isCancelled.
	self assert: world steppingMotion isNil.
	space root addChild: owner.
	space pulse.
	secondMotion := world startStepping.
	self assert: secondMotion ~~ firstMotion.
	self assert: secondMotion isRunning.
	self assert: world steppingMotion == secondMotion.
	world stopStepping.
	^ world
]

{ #category : 'examples - motion integration' }
CFPhysicsExamples >> replacingPhysicsWorldOwnerStopsExistingPlayback [
	<gtExample>
	| space firstOwner secondOwner world motion |
	space := BlSpace new.
	space time: BlTime simulated.
	firstOwner := BlElement new size: 320 @ 200.
	secondOwner := BlElement new size: 320 @ 200.
	space root addChild: firstOwner.
	space root addChild: secondOwner.
	space pulse.
	world := firstOwner physics beWorld.
	motion := world startStepping.
	space pulse.
	world owner: secondOwner.
	self assert: motion isCancelled.
	self assert: world steppingMotion isNil.
	self assert: world owner == secondOwner.
	^ world
]

