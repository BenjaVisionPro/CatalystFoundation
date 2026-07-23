Class {
	#name : 'CFPhysicsSparksBehaviourTests',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Physics-Tests-Behaviours',
	#package : 'BVC-Foundation-Physics-Tests'
}

{ #category : 'tests - behaviours' }
CFPhysicsSparksBehaviourTests >> testSparksIsImmediatelyOwnedAndParticipating [
	| root source world behaviour |
	root := BlElement new.
	source := BlElement new extent: 20 @ 20.
	root addChild: source.
	world := root physics beWorld.
	behaviour := source physics sparks.
	self assert: source physics behaviours equals: { behaviour }.
	self assert: world behaviours equals: { behaviour }.
	self assert: behaviour physics identicalTo: source physics.
	self assert: behaviour world identicalTo: world
]

{ #category : 'tests - behaviours' }
CFPhysicsSparksBehaviourTests >> testSparksSchedulesThenEmitsAnOrdinaryPhysicsBody [
	| root source world behaviour spark sparkBody |
	root := BlElement new.
	source := BlElement new extent: 20 @ 20.
	root addChild: source.
	world := root physics beWorld.
	world gravity: 0 @ 0.
	behaviour := source physics sparks.
	behaviour
		random: (CFPhysicsSequenceRandom values: #(0.0 0.5 0.0 0.5));
		direction: 1 @ 0;
		spread: 0.0;
		minimumEmissionDelay: world stepDuration;
		maximumEmissionDelay: world stepDuration;
		minimumLaunchImpulse: 10.0;
		maximumLaunchImpulse: 10.0;
		minimumAngularImpulse: 0.0;
		maximumAngularImpulse: 0.0;
		lifetime: 1.0.
	world step.
	self assert: behaviour nextEmissionTime equals: world stepDuration.
	self assert: behaviour numberOfLiveSparks equals: 0.
	world step.
	self assert: behaviour numberOfLiveSparks equals: 1.
	spark := behaviour liveSparks anyOne.
	self assert: (world includes: spark).
	sparkBody := spark physics requireBodyState.
	self assert: sparkBody velocity x > 0.0.
	self assert: (sparkBody velocity y closeTo: 0.0)
]

{ #category : 'tests - behaviours' }
CFPhysicsSparksBehaviourTests >> testSparksExpireAndLeaveThePhysicsWorld [
	| root source world behaviour spark |
	root := BlElement new.
	source := BlElement new extent: 20 @ 20.
	root addChild: source.
	world := root physics beWorld.
	world gravity: 0 @ 0.
	behaviour := source physics sparks.
	behaviour
		random: (CFPhysicsSequenceRandom values: #(0.0 0.5 0.0 0.5 0.0));
		minimumEmissionDelay: world stepDuration;
		maximumEmissionDelay: world stepDuration;
		minimumLaunchImpulse: 0.0;
		maximumLaunchImpulse: 0.0;
		minimumAngularImpulse: 0.0;
		maximumAngularImpulse: 0.0;
		lifetime: world stepDuration.
	world step; step.
	spark := behaviour liveSparks anyOne.
	self assert: spark hasParent.
	world step.
	self assert: behaviour numberOfLiveSparks equals: 0.
	self deny: spark hasParent.
	world synchroniseMembership.
	self deny: (world includes: spark)
]

{ #category : 'tests - behaviours' }
CFPhysicsSparksBehaviourTests >> testRemovingSparksRemovesOnlyItsOwnedSparks [
	| root source unrelated world behaviour spark |
	root := BlElement new.
	source := BlElement new extent: 20 @ 20.
	unrelated := BlElement new extent: 20 @ 20.
	root addChildren: { source. unrelated }.
	world := root physics beWorld.
	world gravity: 0 @ 0.
	behaviour := source physics sparks.
	behaviour
		random: (CFPhysicsSequenceRandom values: #(0.0 0.5 0.0 0.5));
		minimumEmissionDelay: world stepDuration;
		maximumEmissionDelay: world stepDuration;
		minimumLaunchImpulse: 0.0;
		maximumLaunchImpulse: 0.0;
		lifetime: 1.0.
	world step; step.
	spark := behaviour liveSparks anyOne.
	behaviour remove.
	self deny: spark hasParent.
	self assert: unrelated parent identicalTo: root.
	self assert: behaviour numberOfLiveSparks equals: 0
]

{ #category : 'tests - behaviours' }
CFPhysicsSparksBehaviourTests >> testSparksIntensityChangesItsDomainProfile [
	| root source behaviour lowDelay lowImpulse lowLifetime |
	root := BlElement new.
	source := BlElement new extent: 20 @ 20.
	root addChild: source.
	root physics beWorld.
	behaviour := source physics sparks.
	behaviour intensity: 0.0.
	lowDelay := behaviour minimumEmissionDelay.
	lowImpulse := behaviour minimumLaunchImpulse.
	lowLifetime := behaviour lifetime.
	behaviour intensity: 1.0.
	self assert: behaviour minimumEmissionDelay < lowDelay.
	self assert: behaviour minimumLaunchImpulse > lowImpulse.
	self assert: behaviour lifetime > lowLifetime
]

{ #category : 'tests - behaviours' }
CFPhysicsSparksBehaviourTests >> testSparksUsesItsConfiguredFactory [
	| root source world behaviour spark |
	root := BlElement new.
	source := BlElement new extent: 20 @ 20.
	root addChild: source.
	world := root physics beWorld.
	world gravity: 0 @ 0.
	behaviour := source physics sparks.
	behaviour
		sparkFactory: [ BlElement new extent: 9 @ 7; yourself ];
		random: (CFPhysicsSequenceRandom values: #(0.0 0.5 0.0 0.5));
		minimumEmissionDelay: world stepDuration;
		maximumEmissionDelay: world stepDuration;
		minimumLaunchImpulse: 0.0;
		maximumLaunchImpulse: 0.0;
		lifetime: 1.0.
	world step; step.
	spark := behaviour liveSparks anyOne.
	self assert: spark extent equals: 9 @ 7
]

{ #category : 'tests - behaviours' }
CFPhysicsSparksBehaviourTests >> testSparksForgetsAnExternallyRemovedSpark [
	| root source world behaviour spark |
	root := BlElement new.
	source := BlElement new extent: 20 @ 20.
	root addChild: source.
	world := root physics beWorld.
	world gravity: 0 @ 0.
	behaviour := source physics sparks.
	behaviour
		random: (CFPhysicsSequenceRandom values: #(0.0 0.5 0.0 0.5 0.0));
		minimumEmissionDelay: world stepDuration;
		maximumEmissionDelay: world stepDuration;
		minimumLaunchImpulse: 0.0;
		maximumLaunchImpulse: 0.0;
		lifetime: 1.0.
	world step; step.
	spark := behaviour liveSparks anyOne.
	spark removeFromParent.
	world step.
	self assert: behaviour numberOfLiveSparks equals: 0
]

{ #category : 'tests - behaviours' }
CFPhysicsSparksBehaviourTests >> testSparksRejectsAReusedFactoryElement [
	| root source world behaviour shared |
	root := BlElement new.
	source := BlElement new extent: 20 @ 20.
	root addChild: source.
	world := root physics beWorld.
	shared := BlElement new.
	behaviour := source physics sparks.
	behaviour
		sparkFactory: [ shared ];
		random: (CFPhysicsSequenceRandom values: #(0.0 0.5 0.0 0.5 0.0));
		minimumEmissionDelay: world stepDuration;
		maximumEmissionDelay: world stepDuration;
		lifetime: 1.0.
	world step; step.
	self should: [ world step ] raise: Error
]
