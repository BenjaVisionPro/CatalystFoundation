Class {
	#name : 'CFPhysicsShowcaseExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Physics-Examples',
	#package : 'BVC-Foundation-Physics-Examples'
}

{ #category : 'showcase - controls' }
CFPhysicsShowcaseExamples >> clickMe [
	<gtExample>
	| host world random buttons |
	host := BlElement new
		size: 740 @ 400;
		background: Color veryVeryLightGray;
		constraintsDo: [ :constraints | constraints minHeight: 250 ];
		yourself.
	world := host physics beWorld.
	world
		gravity: 0 @ 8;
		contactHertz: 120.0;
		contactDampingRatio: 1.0.
	random := Random new.
	buttons := (1 to: 14) collect: [ :each |
		self newClickMeButtonUsing: random ].
	host addChildren: buttons.
	world synchroniseMembership.
	buttons do: [ :each |
		| containment |
		each physics
			position: (self randomPositionFor: each in: host using: random);
			velocity: (self randomInitialVelocityUsing: random);
			restitution: 0.82;
			friction: 0.15;
			angularDamping: 12.0.
		containment := each physics containWithinWorld.
		containment restitution: 0.9 ].
	host when: BlElementAddedToSceneGraphEvent do: [ :anEvent |
		world startStepping ].
	^ host
]

{ #category : 'showcase - controls' }
CFPhysicsShowcaseExamples >> newClickMeButtonUsing: aRandom [
	| aptitude button |
	aptitude := BrGlamorousButtonWithLabelAptitude new.
	aptitude foreground: Color black.
	button := BrButton new
		aptitude: aptitude;
		label: 'Click Me';
		size: 104 @ 42;
		addEventHandler: BlPullHandler new;
		action: [ :aButton |
			aButton physics bodyState
				addVelocity: (self randomClickVelocityUsing: aRandom) ];
		yourself.
	button physics excludeDescendantsFromWorld.
	^ button
]

{ #category : 'showcase - controls' }
CFPhysicsShowcaseExamples >> randomClickVelocityUsing: aRandom [
	^ ((aRandom next * 540.0) - 270.0)
		@ ((aRandom next * 420.0) - 270.0)
]

{ #category : 'showcase - controls' }
CFPhysicsShowcaseExamples >> randomInitialVelocityUsing: aRandom [
	^ ((aRandom next * 180.0) - 90.0)
		@ ((aRandom next * 100.0) - 50.0)
]

{ #category : 'showcase - controls' }
CFPhysicsShowcaseExamples >> randomPositionFor: aButton in: aHost using: aRandom [
	| horizontalRange verticalRange |
	horizontalRange := aHost width - aButton width - 24.
	verticalRange := aHost height - aButton height - 24.
	^ 12 + (aRandom next * horizontalRange)
		@ (12 + (aRandom next * verticalRange))
]

{ #category : 'showcase - joints' }
CFPhysicsShowcaseExamples >> joints [
	<gtExample>
	<return: #BlElement>
	| host world crank slider hammer pendulum payload crankJoint connectingJoint railJoint pendulumJoint payloadJoint |
	host := BlElement new
		size: 900 @ 500;
		background: Color veryVeryLightGray;
		constraintsDo: [ :constraints | constraints minHeight: 380 ];
		yourself.
	world := host physics beWorld.
	world
		gravity: 0 @ 180;
		contactHertz: 120.0;
		contactDampingRatio: 1.0.

	"A motorised crank drives a slider through a distance joint."
	crank := self
		jointShowcaseBodyWithExtent: 110 @ 18
		color: Color orange muchLighter.
	slider := self
		jointShowcaseBodyWithExtent: 70 @ 34
		color: Color green muchLighter.

	"The fixed partner extends the slider into a hammer without merging bodies."
	hammer := self
		jointShowcaseBodyWithExtent: 70 @ 34
		color: Color purple muchLighter.

	"The hammer strikes a limited pendulum, which transfers motion onwards."
	pendulum := self
		jointShowcaseBodyWithExtent: 120 @ 20
		color: Color blue muchLighter.
	payload := self
		jointShowcaseBodyWithExtent: 50 @ 30
		color: Color yellow muchLighter.

	host addChildren: {
		crank.
		slider.
		hammer.
		pendulum.
		payload }.
	world synchroniseMembership.

	crank physics
		position: 100 @ 111;
		friction: 0.25;
		restitution: 0.15.
	slider physics
		position: 320 @ 203;
		friction: 0.35;
		restitution: 0.1.
	hammer physics
		position: 390 @ 203;
		friction: 0.25;
		restitution: 0.55.
	pendulum physics
		position: 560 @ 110;
		friction: 0.2;
		restitution: 0.45.
	payload physics
		position: 690 @ 220;
		friction: 0.25;
		restitution: 0.35.

	crankJoint := (crank physics localAnchorAt: 10 @ 9)
		revoluteJointTo: (world anchorAt: 110 @ 120).
	crankJoint
		motorEnabled: true;
		motorSpeed: 1.8;
		maximumMotorImpulse: 1800.0.

	connectingJoint := (crank physics localAnchorAt: 100 @ 9)
		distanceJointTo: (slider physics localAnchorAt: 0 @ 17).
	connectingJoint restLength: 156.0.

	railJoint := (slider physics localAnchorAt: 35 @ 17)
		railJointTo: (world anchorAt: 355 @ 220)
		along: 1 @ 0.
	railJoint
		limitsEnabled: true;
		limitTranslationFrom: -80 to: 120.

	(slider physics localAnchorAt: 70 @ 17)
		fixedJointTo: (hammer physics localAnchorAt: 0 @ 17).

	pendulumJoint := (pendulum physics localAnchorAt: 10 @ 10)
		revoluteJointTo: (world anchorAt: 570 @ 120).
	pendulumJoint
		limitsEnabled: true;
		limitAnglesFrom: Float pi negated / 2.0 to: Float pi / 2.0.

	payloadJoint := (payload physics localAnchorAt: 25 @ 0)
		distanceJointTo: (world anchorAt: 715 @ 90).
	payloadJoint restLength: 145.0.

	{ crank. slider. hammer. pendulum. payload } do: [ :each |
		| containment |
		containment := each physics containWithinWorld.
		containment restitution: 0.4 ].

	host when: BlElementAddedToSceneGraphEvent do: [ :anEvent |
		host showPhysicsOverlay.
		world startStepping ].
	^ host
]

{ #category : 'showcase - joints' }
CFPhysicsShowcaseExamples >> jointShowcaseBodyWithExtent: anExtent color: aColor [
	^ BlElement new
		size: anExtent;
		background: aColor;
		border: (BlBorder paint: Color gray width: 1);
		addEventHandler: BlPullHandler new;
		yourself
]
