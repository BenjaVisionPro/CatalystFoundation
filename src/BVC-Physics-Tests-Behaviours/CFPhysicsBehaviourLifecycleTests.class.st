Class {
	#name : 'CFPhysicsBehaviourLifecycleTests',
	#superclass : 'TestCase',
	#category : 'BVC-Physics-Tests-Behaviours',
	#package : 'BVC-Physics-Tests-Behaviours'
}

{ #category : 'tests - behaviours' }
CFPhysicsBehaviourLifecycleTests >> testDetachedTargetCannotStartPhysicsBehaviour [
	<gtExample>
	| behaviour |
	behaviour := CFPhysicsRecordingBehaviour new target: BlElement new.
	self should: [ behaviour start ] raise: Error
]

{ #category : 'tests - behaviours' }
CFPhysicsBehaviourLifecycleTests >> testWorldStepsBehavioursInStartOrder [
	<gtExample>
	| root element world order first second |
	root := BlElement new.
	element := BlElement new.
	root addChild: element.
	world := root physics beWorld.
	world gravity: 0 @ 0.
	order := OrderedCollection new.
	first := CFPhysicsRecordingBehaviour new target: element.
	first updateBlock: [ :behaviour :step | order add: #first ].
	second := CFPhysicsRecordingBehaviour new target: element.
	second updateBlock: [ :behaviour :step | order add: #second ].
	first start.
	second start.
	world step.
	self assert: order asArray equals: #(first second).
	self assert: first updates first stepNumber equals: 1.
	self assert: second updates first simulationTime equals: 0.0
]

{ #category : 'tests - behaviours' }
CFPhysicsBehaviourLifecycleTests >> testStopIsIdempotent [
	<gtExample>
	| root element world behaviour |
	root := BlElement new.
	element := BlElement new.
	root addChild: element.
	world := root physics beWorld.
	behaviour := CFPhysicsRecordingBehaviour new target: element.
	behaviour start; stop; stop.
	self deny: behaviour isRunning.
	self assert: behaviour stopCount equals: 1.
	self assert: world behaviours isEmpty
]

{ #category : 'tests - behaviours' }
CFPhysicsBehaviourLifecycleTests >> testBehaviourCanStopItselfDuringWorldStep [
	<gtExample>
	| root element world behaviour |
	root := BlElement new.
	element := BlElement new.
	root addChild: element.
	world := root physics beWorld.
	world gravity: 0 @ 0.
	behaviour := CFPhysicsRecordingBehaviour new target: element.
	behaviour updateBlock: [ :each :step | each stop ].
	behaviour start.
	world step; step.
	self assert: behaviour updates size equals: 1.
	self assert: behaviour stopCount equals: 1.
	self assert: world behaviours isEmpty
]

{ #category : 'tests - behaviours' }
CFPhysicsBehaviourLifecycleTests >> testBehaviourStartedDuringStepBeginsNextStep [
	<gtExample>
	| root element world first second |
	root := BlElement new.
	element := BlElement new.
	root addChild: element.
	world := root physics beWorld.
	world gravity: 0 @ 0.
	second := CFPhysicsRecordingBehaviour new target: element.
	first := CFPhysicsRecordingBehaviour new target: element.
	first updateBlock: [ :behaviour :step | second start ].
	first start.
	world step.
	self assert: first updates size equals: 1.
	self assert: second updates isEmpty.
	world step.
	self assert: second updates size equals: 1
]

{ #category : 'tests - behaviours' }
CFPhysicsBehaviourLifecycleTests >> testBehaviourStopsWhenTargetLeavesItsWorld [
	<gtExample>
	| root element world behaviour |
	root := BlElement new.
	element := BlElement new.
	root addChild: element.
	world := root physics beWorld.
	world gravity: 0 @ 0.
	behaviour := CFPhysicsRecordingBehaviour new target: element.
	behaviour start.
	root removeChild: element.
	world step.
	self deny: behaviour isRunning.
	self assert: behaviour stopCount equals: 1.
	self assert: world behaviours isEmpty
]
