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
	world gravity: 0 @ 8.
	random := Random new.
	buttons := (1 to: 14) collect: [ :each |
		self newClickMeButtonUsing: random ].
	host addChildren: buttons.
	buttons do: [ :each |
		each physics
			position: (self randomPositionFor: each in: host using: random);
			velocity: (self randomInitialVelocityUsing: random) ].
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
