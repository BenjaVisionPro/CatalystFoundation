"
I provide the user-facing Physics examples.

My showcase examples demonstrate complete, reusable Bloc and Physics configurations through supported application APIs. I also exercise supported world lifecycle and telemetry APIs so those examples remain executable documentation.

Private Motion presentation integration is covered separately by CFPhysicsMotionIntegrationExamples.
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
	world := host physics beWorld.
	circle physics
		beDynamic;
		position: 75 @ 65;
		velocity: 45 @ 20.
	rectangle physics
		beDynamic;
		position: 265 @ 150;
		rotation: Float pi / 10.0.
	^ host
]

{ #category : 'examples - bodies' }
CFPhysicsExamples >> bodiesAfterStepping [
	<gtExample>
	| host world |
	host := self bodies.
	world := host physics world.
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
	world := host physics beWorld.
	world
		backgroundStepping: false;
		gravity: 0 @ 0;
		stepDuration: 10 milliSeconds.
	body physics
		beDynamic;
		position: 40 @ 40;
		velocity: 100 @ 0.
	initialPosition := body physics position.
	motion := world startStepping.
	self assert: world isStepping.
	space pulse.
	space time wait: 20 milliSeconds.
	space pulse.
	self assert: body physics position x > initialPosition x.
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
	world := owner physics beWorld.
	world
		backgroundStepping: false;
		gravity: 0 @ 0;
		stepDuration: 10 milliSeconds.
	body physics
		beDynamic;
		position: 20 @ 20;
		velocity: 100 @ 0.
	firstMotion := world startStepping.
	self assert: world startStepping == firstMotion.
	space pulse.
	space time wait: 20 milliSeconds.
	space pulse.
	positionBeforePause := body physics position.
	world pauseStepping.
	self assert: firstMotion isPaused.
	space time wait: 40 milliSeconds.
	space pulse.
	positionWhilePaused := body physics position.
	self assert: positionWhilePaused equals: positionBeforePause.
	world resumeStepping.
	self assert: firstMotion isRunning.
	space pulse.
	space time wait: 10 milliSeconds.
	space pulse.
	self assert: body physics position x > positionWhilePaused x.
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
	world := firstOwner physics beWorld.
	motion := world startStepping.
	space pulse.
	world owner: secondOwner.
	self assert: motion isCancelled.
	self assert: world owner == secondOwner.
	^ world
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
	world := owner physics beWorld.
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
	world := host physics beWorld.
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
	world := host physics beWorld.
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
CFPhysicsExamples >> physicsWorldDefaultsToForegroundStepping [
	<gtExample>
	| owner world |
	owner := BlElement new size: 320 @ 200.
	world := owner physics beWorld.
	self assert: world backgroundStepping not.
	^ world
]

{ #category : 'showcase - controls' }
CFPhysicsExamples >> clickMe [
	<gtExample>
	| host world random buttons |
	host := BlElement new
		size: 740 @ 400;
		background: Color veryVeryLightGray;
		constraintsDo: [ :constraints | constraints minHeight: 250 ];
		yourself.
	world := host physics beWorld.
	world
		gravity: 0 @ 9.81;
		contactHertz: 120.0;
		contactDampingRatio: 1.0.
	world containment restitution: 0.9.
	random := Random new.
	buttons := (1 to: 50) collect: [ :each |
		self newClickMeButtonUsing: random ].
	host addChildren: buttons.
	world owner physics makeChildrenDynamic.
	buttons do: [ :each |
		each physics
			position: (self randomPositionFor: each in: host using: random);
			velocity: (self randomInitialVelocityUsing: random);
			restitution: 0.82;
			friction: 0.15;
			angularDamping: 12.0 ].
	host when: BlElementAddedToSceneGraphEvent do: [ :anEvent |
		world startStepping ].
	^ host
]

{ #category : 'showcase - controls' }
CFPhysicsExamples >> newClickMeButtonUsing: aRandom [
	| aptitude button |
	aptitude := BrGlamorousButtonWithLabelAptitude new.
	aptitude foreground: Color black.
	button := BrButton new
		aptitude: aptitude;
		label: 'Click Me';
		size: 104 @ 42;
		addEventHandler: BlPullHandler new;
		action: [ :aButton |
			aButton physics
				addVelocity: (self randomClickVelocityUsing: aRandom) ];
		yourself.
	^ button
]

{ #category : 'showcase - controls' }
CFPhysicsExamples >> randomClickVelocityUsing: aRandom [
	^ ((aRandom next * 540.0) - 270.0)
		@ ((aRandom next * 420.0) - 270.0)
]

{ #category : 'showcase - controls' }
CFPhysicsExamples >> randomInitialVelocityUsing: aRandom [
	^ ((aRandom next * 180.0) - 90.0)
		@ ((aRandom next * 100.0) - 50.0)
]

{ #category : 'showcase - controls' }
CFPhysicsExamples >> randomPositionFor: aButton in: aHost using: aRandom [
	| horizontalRange verticalRange |
	horizontalRange := aHost width - aButton width - 24.
	verticalRange := aHost height - aButton height - 24.
	^ 12 + (aRandom next * horizontalRange)
		@ (12 + (aRandom next * verticalRange))
]

{ #category : 'showcase - joints' }
CFPhysicsExamples >> joints [
	<gtExample>
	<return: #BlElement>
	| host world distanceBody revoluteBody railBody fixedBody fixedPartner distanceJoint revoluteJoint prismaticJoint |
	host := BlElement new
		size: 760 @ 420;
		background: Color veryVeryLightGray;
		constraintsDo: [ :constraints | constraints minHeight: 320 ];
		yourself.
	world := host physics beWorld.
	world
		gravity: 0 @ 2.4;
		contactHertz: 120.0;
		contactDampingRatio: 1.0.

	distanceBody := self jointShowcaseBodyWithExtent: 64 @ 34 color: Color blue muchLighter.
	revoluteBody := self jointShowcaseBodyWithExtent: 82 @ 24 color: Color orange muchLighter.
	railBody := self jointShowcaseBodyWithExtent: 62 @ 34 color: Color green muchLighter.
	fixedBody := self jointShowcaseBodyWithExtent: 54 @ 34 color: Color purple muchLighter.
	fixedPartner := self jointShowcaseBodyWithExtent: 54 @ 34 color: Color purple muchLighter.
	host addChildren: {
		distanceBody.
		revoluteBody.
		railBody.
		fixedBody.
		fixedPartner }.
	world owner physics makeChildrenDynamic.

	distanceBody physics position: 72 @ 118.
	revoluteBody physics position: 225 @ 112.
	railBody physics position: 390 @ 170.
	fixedBody physics position: 555 @ 115.
	fixedPartner physics position: 625 @ 160.

	distanceJoint := (distanceBody physics localAnchorAt: 32 @ 0)
		distanceJointTo: (world anchorAt: 104 @ 54).
	distanceJoint length: 82.

	revoluteJoint := (revoluteBody physics localAnchorAt: 12 @ 12)
		revoluteJointTo: (world anchorAt: 237 @ 124).
	revoluteJoint
		limitsEnabled: true;
		limitAnglesFrom: Float pi negated / 2.0 to: Float pi / 2.0.
	revoluteBody physics angularVelocity: 1.5.

	prismaticJoint := (railBody physics localAnchorAt: 31 @ 17)
		prismaticJointTo: (world anchorAt: 421 @ 187)
		along: 1 @ 0.
	prismaticJoint
		limitsEnabled: true;
		limitTranslationFrom: -90 to: 90.
	railBody physics velocity: 90 @ 0.

	(fixedBody physics localAnchorAt: 54 @ 17)
		weldJointTo: (fixedPartner physics localAnchorAt: 0 @ 17).
	fixedBody physics angularVelocity: 0.8.

	host when: BlElementAddedToSceneGraphEvent do: [ :anEvent |
		host showPhysicsOverlay.
		world startStepping ].
	^ host
]

{ #category : 'showcase - joints' }
CFPhysicsExamples >> jointShowcaseBodyWithExtent: anExtent color: aColor [
	^ BlElement new
		size: anExtent;
		background: aColor;
		border: (BlBorder paint: Color gray width: 1);
		addEventHandler: BlPullHandler new;
		yourself
]
