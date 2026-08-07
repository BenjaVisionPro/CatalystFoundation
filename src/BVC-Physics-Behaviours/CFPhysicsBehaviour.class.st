
"
I orchestrate Physics for one target.

My target determines the Physics world in which I run. The world sends me #step: before each simulation step. Subclasses may create persistent Physics resources, contribute on every step, or do both.
"
Class {
	#name : 'CFPhysicsBehaviour',
	#superclass : 'Object',
	#instVars : [ 'target', 'world' ],
	#category : 'BVC-Physics-Behaviours',
	#package : 'BVC-Physics-Behaviours'
}

{ #category : 'accessing' }
CFPhysicsBehaviour >> target [
	^ target
]

{ #category : 'accessing' }
CFPhysicsBehaviour >> target: aTarget [
	self isRunning ifTrue: [
		self error: 'Stop a Physics Behaviour before changing its target' ].
	target := aTarget.
	^ self
]

{ #category : 'accessing' }
CFPhysicsBehaviour >> world [
	^ world
]

{ #category : 'running' }
CFPhysicsBehaviour >> start [
	self isRunning ifTrue: [ ^ self ].
	target ifNil: [ self error: 'A Physics Behaviour requires a target' ].
	world := target physics world.
	world ifNil: [
		self error: 'A Physics Behaviour target must belong to a Physics world' ].
	world addBehaviour: self.
	^ self
]

{ #category : 'running' }
CFPhysicsBehaviour >> stop [
	world ifNotNil: [
		world removeBehaviour: self.
		world := nil ].
	^ self
]

{ #category : 'testing' }
CFPhysicsBehaviour >> isRunning [
	^ world notNil and: [ world includesBehaviour: self ]
]

{ #category : 'stepping' }
CFPhysicsBehaviour >> step: aPhysicsStep [
]
