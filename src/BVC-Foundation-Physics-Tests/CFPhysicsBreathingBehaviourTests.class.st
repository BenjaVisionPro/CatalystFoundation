Class {
	#name : 'CFPhysicsBreathingBehaviourTests',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Physics-Tests-Behaviours',
	#package : 'BVC-Foundation-Physics-Tests'
}

{ #category : 'tests - behaviours' }
CFPhysicsBreathingBehaviourTests >> testBreathingUsesMotionValuesWithoutChangingPhysicsCore [
	| root first second world edge source forceDirected breathing spring originalRestLength |
	root := BlElement new.
	first := BlElement new extent: 20 @ 20.
	second := BlElement new extent: 20 @ 20.
	root addChildren: { first. second }.
	world := root physics beWorld.
	edge := first -> second.
	source := CFPhysicsGraphSource
		nodes: [ { first. second } ]
		edges: [ { edge } ]
		source: [ :each | each key ]
		target: [ :each | each value ].
	forceDirected := root physics forceDirectedUsing: source.
	world step.
	spring := forceDirected springsByEdge at: edge.
	originalRestLength := spring restLength value.
	breathing := root physics breathingUsing: forceDirected.
	breathing origin: first; intensity: 0.5.
	world step.
	self assert: spring restLength class equals: CFMotionValue.
	self deny: spring restLength value equals: originalRestLength
]
