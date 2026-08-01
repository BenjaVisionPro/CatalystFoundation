"
I provide executable examples of the core Physics and Motion integration.

My responsibility is to demonstrate supported world, body, stepping and playback behaviour while also serving as focused regression checks.
"
Class {
	#name : 'CFPhysicsExamples',
	#superclass : 'Object',
	#category : 'BVC-Physics-Examples',
	#package : 'BVC-Physics-Examples'
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
	world := host physics world.
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
	world := host physics worldOrNil.
	world step: 30.
	world present.
	^ host
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
	world := host physics world.
	world gravity: 0 @ 0.
	world stepDuration: 10 milliSeconds.
	world synchroniseMembership.
	(world bodyStateFor: body)
		position: 40 @ 40;
		velocity: 100 @ 0.
	initialPosition := (world bodyStateFor: body) position.
	motion := world startStepping.
	self assert: world isStepping.
	space pulse.
	space time wait: 20 milliSeconds.
	space pulse.
	self assert: (world bodyStateFor: body) position x > initialPosition x.
	world stopStepping.
	self assert: world isStepping not.
	^ host
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
	world := owner physics world.
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
	^ world
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
	world := owner physics world.
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
	world := owner physics world.
	world stepDuration: 10 milliSeconds.
	firstMotion := world startStepping.
	space pulse.
	owner removeFromParent.
	space pulse.
	self assert: firstMotion isCancelled.
	space root addChild: owner.
	space pulse.
	secondMotion := world startStepping.
	self assert: secondMotion ~~ firstMotion.
	self assert: secondMotion isRunning.
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
	world := firstOwner physics world.
	motion := world startStepping.
	space pulse.
	world owner: secondOwner.
	self assert: motion isCancelled.
	self assert: world owner == secondOwner.
	^ world
]

{ #category : 'examples - motion integration' }
CFPhysicsExamples >> physicsPresentationComposesWithOtherMotionTransforms [
	<gtExample>
	| space host body world state physicsPresentation channel scalePresentation |
	space := BlSpace new.
	host := BlElement new size: 320 @ 200.
	body := BlElement new size: 20 @ 20.
	host addChild: body.
	space root addChild: host.
	space pulse.
	world := host physics world.
	world synchroniseMembership.
	state := world bodyStateFor: body.
	state position: 40 @ 20.
	world present.
	physicsPresentation := (CFPhysicsWorldMotionIntegration for: world) manualPresentation presentationFor: state.
	channel := physicsPresentation channel.
	scalePresentation := CFMotionTransformPresentation on: body using: channel.
	scalePresentation scale: 0.5 @ 0.75.
	self assert: physicsPresentation ownsCurrentTransformation.
	self assert: scalePresentation ownsCurrentTransformation.
	state position: 60 @ 30.
	world present.
	self assert: physicsPresentation ownsCurrentTransformation.
	self assert: scalePresentation ownsCurrentTransformation.
	scalePresentation release.
	self assert: physicsPresentation ownsCurrentTransformation.
	((CFPhysicsWorldMotionIntegration for: world) manualPresentation presentationFor: state) release.
	^ channel
]

{ #category : 'examples - motion integration' }
CFPhysicsExamples >> releasingPhysicsPresentationPreservesOtherMotionTransforms [
	<gtExample>
	| space host body applicationTransformation world state physicsPresentation channel scalePresentation |
	space := BlSpace new.
	host := BlElement new size: 320 @ 200.
	body := BlElement new size: 20 @ 20.
	host addChild: body.
	space root addChild: host.
	space pulse.
	body transformDo: [ :builder | builder translateBy: 8 @ 0 ].
	applicationTransformation := body transformation.
	world := host physics world.
	world synchroniseMembership.
	state := world bodyStateFor: body.
	state position: 40 @ 20.
	world present.
	physicsPresentation := (CFPhysicsWorldMotionIntegration for: world) manualPresentation presentationFor: state.
	channel := physicsPresentation channel.
	scalePresentation := CFMotionTransformPresentation on: body using: channel.
	scalePresentation scale: 0.8 @ 0.8.
	((CFPhysicsWorldMotionIntegration for: world) manualPresentation presentationFor: state) release.
	self assert: physicsPresentation isActive not.
	self assert: scalePresentation ownsCurrentTransformation.
	scalePresentation release.
	self assert: body transformation == applicationTransformation.
	^ channel
]

{ #category : 'examples - motion integration' }
CFPhysicsExamples >> bodyMutationDoesNotPresentOutsideMotion [
	<gtExample>
	| space host body world state |
	space := BlSpace new.
	host := BlElement new size: 320 @ 200.
	body := BlElement new size: 20 @ 20.
	host addChild: body.
	space root addChild: host.
	space pulse.
	world := host physics world.
	world synchroniseMembership.
	state := world bodyStateFor: body.
	self assert: ((CFPhysicsWorldMotionIntegration for: world) manualPresentation isPresenting: state) not.
	state position: 40 @ 20.
	state rotation: Float pi / 4.0.
	state translation: 60 @ 30 rotation: Float pi / 2.0.
	self assert: state position equals: 60 @ 30.
	self assert: state rotation equals: Float pi / 2.0.
	self assert: ((CFPhysicsWorldMotionIntegration for: world) manualPresentation isPresenting: state) not.
	world present.
	self assert: ((CFPhysicsWorldMotionIntegration for: world) manualPresentation isPresenting: state).
	((CFPhysicsWorldMotionIntegration for: world) manualPresentation presentationFor: state) release.
	^ state
]

{ #category : 'examples - motion integration' }
CFPhysicsExamples >> physicsPresentationConvertsPhysicsRotationToMotionDegrees [
	<gtExample>
	| space host body world state presentation |
	space := BlSpace new.
	host := BlElement new size: 320 @ 200.
	body := BlElement new size: 20 @ 20.
	host addChild: body.
	space root addChild: host.
	space pulse.
	world := host physics world.
	world synchroniseMembership.
	state := world bodyStateFor: body.
	state rotation: Float pi / 2.0.
	world present.
	presentation := (CFPhysicsWorldMotionIntegration for: world) manualPresentation presentationFor: state.
	self assert: presentation rotation equals: 90.0.
	presentation release.
	^ presentation
]

{ #category : 'examples - motion integration' }
CFPhysicsExamples >> manualPhysicsSteppingDoesNotPresent [
	<gtExample>
	| space host body world state initialPosition |
	space := BlSpace new.
	host := BlElement new size: 320 @ 200.
	body := BlElement new size: 20 @ 20.
	host addChild: body.
	space root addChild: host.
	space pulse.
	world := host physics world.
	world
		gravity: 0 @ 0;
		stepDuration: 10 milliSeconds;
		synchroniseMembership.
	state := world bodyStateFor: body.
	state
		position: 20 @ 20;
		velocity: 100 @ 0.
	initialPosition := state position.
	world step: 2.
	self assert: state position x > initialPosition x.
	self assert: ((CFPhysicsWorldMotionIntegration for: world) manualPresentation isPresenting: state) not.
	world present.
	self assert: ((CFPhysicsWorldMotionIntegration for: world) manualPresentation isPresenting: state).
	((CFPhysicsWorldMotionIntegration for: world) manualPresentation presentationFor: state) release.
	^ world
]

{ #category : 'examples - motion integration' }
CFPhysicsExamples >> stepAndPresentRemainsExplicit [
	<gtExample>
	| space host body world state initialPosition result |
	space := BlSpace new.
	host := BlElement new size: 320 @ 200.
	body := BlElement new size: 20 @ 20.
	host addChild: body.
	space root addChild: host.
	space pulse.
	world := host physics world.
	world
		gravity: 0 @ 0;
		stepDuration: 10 milliSeconds;
		synchroniseMembership.
	state := world bodyStateFor: body.
	state
		position: 20 @ 20;
		velocity: 100 @ 0.
	initialPosition := state position.
	result := world stepAndPresent.
	self assert: result == world lastStepResult.
	self assert: state position x > initialPosition x.
	self assert: ((CFPhysicsWorldMotionIntegration for: world) manualPresentation isPresenting: state).
	((CFPhysicsWorldMotionIntegration for: world) manualPresentation presentationFor: state) release.
	^ result
]

{ #category : 'examples - motion integration' }
CFPhysicsExamples >> manualPresentationCannotCompeteWithContinuousPlayback [
	<gtExample>
	| space owner world motion stepResultBeforeAttempt presentError stepAndPresentError |
	space := BlSpace new.
	space time: BlTime simulated.
	owner := BlElement new size: 320 @ 200.
	space root addChild: owner.
	space pulse.
	world := owner physics world.
	motion := world startStepping.
	space pulse.
	stepResultBeforeAttempt := world lastStepResult.
	presentError := [
		world present.
		nil ]
		on: Error
		do: [ :anError | anError ].
	self assert: presentError notNil.
	self assert: world lastStepResult == stepResultBeforeAttempt.
	world pauseStepping.
	stepAndPresentError := [
		world stepAndPresent.
		nil ]
		on: Error
		do: [ :anError | anError ].
	self assert: stepAndPresentError notNil.
	self assert: world lastStepResult == stepResultBeforeAttempt.
	world stopStepping.
	world present.
	self assert: motion isCancelled.
	^ world
]




{ #category : 'examples - telemetry' }
CFPhysicsExamples >> physicsWorldDoesNoTelemetryWorkWhenDisabled [
	<gtExample>
	| host world announcer |
	host := BlElement new size: 320 @ 200; yourself.
	host addChild: (BlElement new size: 20 @ 20; yourself).
	world := host physics world.
	self assert: world hasTelemetryLogger not.
	announcer := world telemetryAnnouncer.
	self assert: announcer notNil.
	self assert: world hasTelemetryLogger not.
	world step.
	self assert: world hasTelemetryLogger not.
	self assert: world telemetryRecordings isEmpty.
	^ world
]
{ #category : 'examples - telemetry' }
CFPhysicsExamples >> physicsWorldRecordsPharoTelemetry [
	<gtExample>
	| host world |
	host := BlElement new size: 320 @ 200; yourself.
	host addChild: (BlElement new size: 20 @ 20; yourself).
	world := host physics world.
	world telemetryEnabled: true.
	world step.
	self assert: world telemetryRecordings isNotEmpty.
	self assert: (world latestTelemetryRecording data includesKey: #physicsFrame).
	self assert: world latestTelemetryRecording ping tasks isNotEmpty.
	world telemetryEnabled: false.
	self assert: world telemetryRecordings isNotEmpty.
	^ world
]

{ #category : 'examples - telemetry' }
CFPhysicsExamples >> physicsWorldTelemetryCanBeReset [
	<gtExample>
	| world |
	world := self physicsWorldRecordsPharoTelemetry.
	world telemetryEnabled: true.
	world resetTelemetry.
	self assert: world telemetryRecordings isEmpty.
	world telemetryEnabled: false.
	^ world
]


{ #category : 'examples - telemetry' }
CFPhysicsExamples >> physicsWorldTelemetryStatistics [
	<gtExample>
	| world analysis root pipeline previousStart element |
	world := self physicsWorldRecordsPharoTelemetry.
	analysis := CFPhysicsTelemetryAnalysis world: world.
	root := analysis rootStatistics.
	self assert: root notNil.
	self assert: root children isNotEmpty.
	self assert: root averageMilliseconds > 0.
	self assert: root p95Milliseconds > 0.
	self assert: root averageEnd >= root averageStart.
	self assert: root p95End >= root p05Start.
	pipeline := root children detect: [ :each | each name asString = 'Pipeline' ].
	self assert: pipeline samples size = analysis sampleCount.
	self assert: pipeline children first samples isNotEmpty.
	self assert: pipeline children first executionsByDuration first signal notNil.
	self assert: (pipeline children first durationHistogramWithBins: 12) isNotEmpty.
	self assert: pipeline children first samples first bodyCount notNil.
	self assert: pipeline children first samples first contactCount notNil.
	previousStart := -1.
	pipeline children do: [ :span |
		self assert: span averageStart >= previousStart.
		self assert: span averageEnd >= span averageStart.
		self assert: span p05Start <= span p25Start.
		self assert: span p25Start <= span medianStart.
		self assert: span medianStart <= span p95Start.
		self assert: span medianStart <= span medianEnd.
		self assert: span medianEnd <= span p75End.
		self assert: span p75End <= span p95End.
		previousStart := span averageStart ].
	element := CFPhysicsTelemetryPipelineElement world: world.
	self assert: element children isNotEmpty.
	world telemetryEnabled: false.
	^ root
]


{ #category : 'examples - telemetry' }
CFPhysicsExamples >> physicsTelemetryRingBufferOverwritesOldest [
	<gtExample>
	| buffer |
	buffer := CFPhysicsTelemetryRingBuffer capacity: 3.
	buffer add: 1; add: 2; add: 3; add: 4.
	self assert: buffer size = 3.
	self assert: buffer asArray = #(2 3 4).
	buffer capacity: 2.
	self assert: buffer asArray = #(3 4).
	^ buffer
]

{ #category : 'examples - telemetry' }
CFPhysicsExamples >> physicsTelemetryAnalysisWindowCanChangeLive [
	<gtExample>
	| world |
	world := self physicsWorldRecordsPharoTelemetry.
	self assert: world telemetryAnalysisWindowSeconds = 5.
	world telemetryAnalysisWindowSeconds: 1.
	self assert: world telemetryAnalysisWindowSeconds = 1.
	self assert: (CFPhysicsTelemetryAnalysis world: world) sampleCount > 0.
	^ world
]


{ #category : 'examples - telemetry' }
CFPhysicsExamples >> physicsTelemetryStepStatisticsScaleDoesNotContract [
	<gtExample>
	| world firstMaximum secondMaximum |
	world := CFPhysicsWorld new.
	firstMaximum := world telemetryStepStatisticsMaximumMicrosecondsFor: 4200.
	secondMaximum := world telemetryStepStatisticsMaximumMicrosecondsFor: 1800.
	self assert: firstMaximum = secondMaximum.
	world telemetryAnalysisWindowSeconds: 1.
	self assert: (world telemetryStepStatisticsMaximumMicrosecondsFor: 1800) < firstMaximum.
	^ world
]

{ #category : 'examples - telemetry' }
CFPhysicsExamples >> physicsTelemetryAnalysisCanRunInBackground [
	<gtExample>
	| world |
	world := CFPhysicsWorld new.
	self assert: world telemetryAnalysisInBackground not.
	world telemetryAnalysisInBackground: true.
	self assert: world telemetryAnalysisInBackground.
	^ world
]

{ #category : 'examples - motion integration' }
CFPhysicsExamples >> physicsWorldDefaultsToSynchronousStepping [
	<gtExample>
	| owner world |
	owner := BlElement new size: 320 @ 200.
	world := owner physics world.
	self assert: world backgroundStepping not.
	^ world
]
