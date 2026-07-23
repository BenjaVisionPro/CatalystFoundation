Class {
	#name : 'CFPhysicsBreathingBehaviourTests',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Physics-Tests-Behaviours',
	#package : 'BVC-Foundation-Physics-Tests'
}

{ #category : 'tests - behaviours' }
CFPhysicsBreathingBehaviourTests >> testBreathingUsesMotionValuesWithoutChangingPhysicsCore [
	| root first second world connection forceDirected breathing spring originalRestLength |
	root := BlElement new.
	first := BlElement new extent: 20 @ 20.
	second := BlElement new extent: 20 @ 20.
	root addChildren: { first. second }.
	world := root physics beWorld.
	connection := first -> second.
	forceDirected := root physics forceDirected.
	forceDirected
		nodes: [ { first. second } ];
		connections: [ { connection } ].
	world step.
	spring := forceDirected springsByConnection at: connection.
	originalRestLength := spring restLength value.
	breathing := root physics breathingUsing: forceDirected.
	breathing origin: first; intensity: 0.5.
	world step.
	self assert: spring restLength class equals: CFMotionValue.
	self deny: spring restLength value equals: originalRestLength
]
