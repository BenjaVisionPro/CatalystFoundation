Class {
	#name : 'CFPhysicsJumpingBeanBehaviourTests',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Physics-Tests-Behaviours',
	#package : 'BVC-Foundation-Physics-Tests'
}

{ #category : 'tests - behaviours' }
CFPhysicsJumpingBeanBehaviourTests >> testJumpingBeanIsImmediatelyOwnedAndParticipating [
	| root element world behaviour |
	root := BlElement new.
	element := BlElement new.
	root addChild: element.
	world := root physics beWorld.
	behaviour := element physics jumpingBean.
	self assert: element physics behaviours equals: { behaviour }.
	self assert: world behaviours equals: { behaviour }.
	self assert: behaviour physics identicalTo: element physics.
	self assert: behaviour world identicalTo: world
]

{ #category : 'tests - behaviours' }
CFPhysicsJumpingBeanBehaviourTests >> testJumpingBeanSchedulesThenAppliesLinearAndAngularImpulse [
	| root element world behaviour body initialAngularVelocity |
	root := BlElement new.
	element := BlElement new.
	element extent: 20 @ 20.
	root addChild: element.
	world := root physics beWorld.
	world gravity: 0 @ 0.
	behaviour := element physics jumpingBean.
	behaviour
		random: (CFPhysicsSequenceRandom values: #(0.0 0.0 0.0 0.0 0.0));
		minimumDelay: world stepDuration;
		maximumDelay: world stepDuration;
		minimumImpulse: 10.0;
		maximumImpulse: 10.0;
		minimumAngularImpulse: 2.0;
		maximumAngularImpulse: 2.0.
	world step.
	body := element physics requireBodyState.
	initialAngularVelocity := body angularVelocity.
	self assert: body velocity equals: 0 @ 0.
	self assert: behaviour nextJoltTime equals: world stepDuration.
	world step.
	self assert: body velocity x > 0.0.
	self assert: (body velocity y closeTo: 0.0).
	self assert: body angularVelocity > initialAngularVelocity
]

{ #category : 'tests - behaviours' }
CFPhysicsJumpingBeanBehaviourTests >> testRemovingJumpingBeanPreventsFutureJolts [
	| root element world behaviour body |
	root := BlElement new.
	element := BlElement new.
	element extent: 20 @ 20.
	root addChild: element.
	world := root physics beWorld.
	world gravity: 0 @ 0.
	behaviour := element physics jumpingBean.
	behaviour
		random: (CFPhysicsSequenceRandom values: #(0.0));
		minimumDelay: world stepDuration;
		maximumDelay: world stepDuration.
	world step.
	body := element physics requireBodyState.
	behaviour remove.
	world step.
	self assert: body velocity equals: 0 @ 0.
	self assert: body angularVelocity equals: 0.0
]

{ #category : 'tests - behaviours' }
CFPhysicsJumpingBeanBehaviourTests >> testMultipleJumpingBeansKeepIndependentSchedules [
	| root element world first second |
	root := BlElement new.
	element := BlElement new.
	element extent: 20 @ 20.
	root addChild: element.
	world := root physics beWorld.
	world gravity: 0 @ 0.
	first := element physics jumpingBean.
	second := element physics jumpingBean.
	first
		random: (CFPhysicsSequenceRandom values: #(0.0));
		minimumDelay: world stepDuration;
		maximumDelay: world stepDuration.
	second
		random: (CFPhysicsSequenceRandom values: #(0.0));
		minimumDelay: world stepDuration * 2;
		maximumDelay: world stepDuration * 2.
	world step.
	self assert: first nextJoltTime equals: world stepDuration.
	self assert: second nextJoltTime equals: world stepDuration * 2
]

{ #category : 'tests - behaviours' }
CFPhysicsJumpingBeanBehaviourTests >> testJumpingBeanIntensityChangesItsDomainProfile [
	| root element behaviour lowMinimumDelay lowMinimumImpulse |
	root := BlElement new.
	element := BlElement new extent: 20 @ 20.
	root addChild: element.
	root physics beWorld.
	behaviour := element physics jumpingBean.
	behaviour intensity: 0.0.
	lowMinimumDelay := behaviour minimumDelay.
	lowMinimumImpulse := behaviour minimumImpulse.
	behaviour intensity: 1.0.
	self assert: behaviour minimumDelay < lowMinimumDelay.
	self assert: behaviour minimumImpulse > lowMinimumImpulse
]

{ #category : 'tests - behaviours' }
CFPhysicsJumpingBeanBehaviourTests >> testJumpingBeanCanCoordinateSelectedParticipantsWithIndependentSchedules [
	| root first second third world behaviour |
	root := BlElement new.
	first := BlElement new extent: 20 @ 20.
	second := BlElement new extent: 20 @ 20.
	third := BlElement new extent: 20 @ 20.
	root addChildren: { first. second. third }.
	world := root physics beWorld.
	world gravity: 0 @ 0.
	behaviour := root physics jumpingBeanAffecting: { first. second }.
	behaviour
		random: (CFPhysicsSequenceRandom values: #(0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0));
		minimumDelay: world stepDuration;
		maximumDelay: world stepDuration;
		minimumImpulse: 10.0;
		maximumImpulse: 10.0;
		minimumAngularImpulse: 0.0;
		maximumAngularImpulse: 0.0.
	world step.
	self assert: (behaviour nextJoltTimeFor: first) equals: world stepDuration.
	self assert: (behaviour nextJoltTimeFor: second) equals: world stepDuration.
	world step.
	self assert: first physics requireBodyState velocity x > 0.0.
	self assert: second physics requireBodyState velocity x > 0.0.
	self assert: third physics requireBodyState velocity equals: 0 @ 0
]

{ #category : 'tests - behaviours' }
CFPhysicsJumpingBeanBehaviourTests >> testJumpingBeanParticipantProviderCanChangeBetweenSteps [
	| root first second world selected behaviour |
	root := BlElement new.
	first := BlElement new extent: 20 @ 20.
	second := BlElement new extent: 20 @ 20.
	root addChildren: { first. second }.
	world := root physics beWorld.
	world gravity: 0 @ 0.
	selected := { first }.
	behaviour := root physics jumpingBeanAffecting: [ selected ].
	behaviour
		random: (CFPhysicsSequenceRandom values: #(0.0 0.0 0.0 0.0 0.0 0.0));
		minimumDelay: world stepDuration;
		maximumDelay: world stepDuration;
		minimumImpulse: 10.0;
		maximumImpulse: 10.0;
		minimumAngularImpulse: 0.0;
		maximumAngularImpulse: 0.0.
	world step.
	self assert: (behaviour nextJoltTimeFor: first) equals: world stepDuration.
	selected := { second }.
	world step.
	self assert: (behaviour nextJoltTimeFor: first) isNil.
	self assert: (behaviour nextJoltTimeFor: second) equals: world stepDuration * 2.
	self assert: first physics requireBodyState velocity equals: 0 @ 0
]

{ #category : 'tests - behaviours' }
CFPhysicsJumpingBeanBehaviourTests >> testJumpingBeanIntensityIsAProfileAndExplicitSettersOverrideIt [
	| root element behaviour |
	root := BlElement new.
	element := BlElement new extent: 20 @ 20.
	root addChild: element.
	root physics beWorld.
	behaviour := element physics jumpingBean.
	behaviour intensity: 0.8; minimumImpulse: 7.0.
	self assert: behaviour minimumImpulse equals: 7.0.
	behaviour intensity: 0.8.
	self deny: behaviour minimumImpulse equals: 7.0
]

{ #category : 'tests - determinism' }
CFPhysicsJumpingBeanBehaviourTests >> testPhysicsRandomSourceRepeatsForTheSameSeed [
	| first second |
	first := CFPhysicsRandomSource seed: 42.
	second := CFPhysicsRandomSource seed: 42.
	5 timesRepeat: [ self assert: first next equals: second next ]
]
