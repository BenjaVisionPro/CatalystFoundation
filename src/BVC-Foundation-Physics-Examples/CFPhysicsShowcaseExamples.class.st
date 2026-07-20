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
			angularDamping: 12.0;
			enablePointerDragging.
		containment := each physics containWithinWorld.
		containment restitution: 0.9 ].
	host when: BlElementAddedToSceneGraphEvent do: [ :anEvent |
		world startStepping ].
	^ host
]

{ #category : 'showcase - controls' }
CFPhysicsShowcaseExamples >> newClickMeButtonUsing: aRandom [
	| aptitude |
	aptitude := BrGlamorousButtonWithLabelAptitude new.
	aptitude foreground: Color black.
	^ BrButton new
		aptitude: aptitude;
		label: 'Click Me';
		size: 104 @ 42;
		action: [ :aButton |
			aButton physics bodyState
				addVelocity: (self randomClickVelocityUsing: aRandom) ];
		yourself
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
