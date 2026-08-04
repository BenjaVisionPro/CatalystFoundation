"
I provide interactive Physics showcases.

My responsibility is to demonstrate supported controls, collisions and joints through complete Bloc scenes.
"
Class {
	#name : 'CFPhysicsShowcaseExamples',
	#superclass : 'Object',
	#category : 'BVC-Physics-Examples',
	#package : 'BVC-Physics-Examples'
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
		gravity: 0 @ 9.81;
		contactHertz: 120.0;
		contactDampingRatio: 1.0.
	world containment restitution: 0.9.
	random := Random new.
	buttons := (1 to: 50) collect: [ :each |
		self newClickMeButtonUsing: random ].
	host addChildren: buttons.
	world synchroniseMembership.
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
			aButton physics body
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
	world synchroniseMembership.

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
CFPhysicsShowcaseExamples >> jointShowcaseBodyWithExtent: anExtent color: aColor [
	^ BlElement new
		size: anExtent;
		background: aColor;
		border: (BlBorder paint: Color gray width: 1);
		addEventHandler: BlPullHandler new;
		yourself
]
