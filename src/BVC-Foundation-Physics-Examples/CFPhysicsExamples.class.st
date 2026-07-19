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
	self assert: world stepCount equals: 0.
	space time wait: 10 milliSeconds.
	space pulse.
	self assert: world stepCount equals: 0.
	space time wait: 10 milliSeconds.
	space pulse.
	self assert: world stepCount equals: 1.
	space time wait: 30 milliSeconds.
	space pulse.
	self assert: world stepCount equals: 3.
	self assert: motion isRunning.
	motion cancel.
	self assert: space cfMotionCoordinator hasActiveMotions not.
	^ track
]

{ #category : 'examples - motion integration' }
CFPhysicsExamples >> physicsWorldBehaviourRunsTheExistingWorld [
	<gtExample>
	| space host body world initialPosition behaviour timeline motion |
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
	behaviour := CFPhysicsWorldBehaviour on: world.
	timeline := CFMotionTimeline new.
	(CFMotionTimelineTrack on: behaviour in: timeline) indefinite.
	motion := (CFMotion timeline: timeline coordinator: space cfMotionCoordinator) start.
	space pulse.
	space time wait: 20 milliSeconds.
	space pulse.
	self assert: (world bodyStateFor: body) position x > initialPosition x.
	motion cancel.
	^ host
]
