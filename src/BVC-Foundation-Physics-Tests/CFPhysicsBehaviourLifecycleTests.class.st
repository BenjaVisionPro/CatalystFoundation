Class {
	#name : 'CFPhysicsBehaviourLifecycleTests',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Physics-Tests-Behaviours',
	#package : 'BVC-Foundation-Physics-Tests'
}

{ #category : 'tests - behaviours' }
CFPhysicsBehaviourLifecycleTests >> testPhysicsOwnsAddedBehaviourAndWorldParticipates [
	| root element world behaviour |
	root := BlElement new.
	element := BlElement new.
	root addChild: element.
	world := root physics beWorld.
	behaviour := CFPhysicsRecordingBehaviour physics: element physics.
	element physics addBehaviour: behaviour.
	self assert: element physics behaviours equals: { behaviour }.
	self assert: world behaviours equals: { behaviour }.
	self assert: behaviour physics identicalTo: element physics.
	self assert: behaviour world identicalTo: world.
	self assert: behaviour element identicalTo: element
]

{ #category : 'tests - behaviours' }
CFPhysicsBehaviourLifecycleTests >> testDetachedElementCannotAddPhysicsBehaviour [
	| element behaviour |
	element := BlElement new.
	behaviour := CFPhysicsRecordingBehaviour physics: element physics.
	self
		should: [ element physics addBehaviour: behaviour ]
		raise: Error
]

{ #category : 'tests - behaviours' }
CFPhysicsBehaviourLifecycleTests >> testWorldUpdatesBehavioursInInsertionOrder [
	| root element world order first second |
	root := BlElement new.
	element := BlElement new.
	root addChild: element.
	world := root physics beWorld.
	world gravity: 0 @ 0.
	order := OrderedCollection new.
	first := CFPhysicsRecordingBehaviour physics: element physics.
	first updateBlock: [ :behaviour :step | order add: #first ].
	second := CFPhysicsRecordingBehaviour physics: element physics.
	second updateBlock: [ :behaviour :step | order add: #second ].
	element physics
		addBehaviour: first;
		addBehaviour: second.
	world step.
	self assert: order asArray equals: #(first second).
	self assert: first updates first stepNumber equals: 1.
	self assert: second updates first simulationTime equals: 0.0
]

{ #category : 'tests - behaviours' }
CFPhysicsBehaviourLifecycleTests >> testBehaviourRemovalIsIdempotentAndClearsBothOwners [
	| root element world behaviour |
	root := BlElement new.
	element := BlElement new.
	root addChild: element.
	world := root physics beWorld.
	behaviour := CFPhysicsRecordingBehaviour physics: element physics.
	element physics addBehaviour: behaviour.
	behaviour remove; remove.
	self assert: behaviour isRemoved.
	self assert: behaviour removalCount equals: 1.
	self assert: element physics behaviours isEmpty.
	self assert: world behaviours isEmpty
]

{ #category : 'tests - behaviours' }
CFPhysicsBehaviourLifecycleTests >> testBehaviourCanRemoveItselfDuringWorldUpdate [
	| root element world behaviour |
	root := BlElement new.
	element := BlElement new.
	root addChild: element.
	world := root physics beWorld.
	world gravity: 0 @ 0.
	behaviour := CFPhysicsRecordingBehaviour physics: element physics.
	behaviour updateBlock: [ :each :step | each remove ].
	element physics addBehaviour: behaviour.
	world step; step.
	self assert: behaviour updates size equals: 1.
	self assert: behaviour removalCount equals: 1.
	self assert: world behaviours isEmpty
]

{ #category : 'tests - behaviours' }
CFPhysicsBehaviourLifecycleTests >> testBehaviourAddedDuringUpdateBeginsOnNextStep [
	| root element world first second |
	root := BlElement new.
	element := BlElement new.
	root addChild: element.
	world := root physics beWorld.
	world gravity: 0 @ 0.
	second := CFPhysicsRecordingBehaviour physics: element physics.
	first := CFPhysicsRecordingBehaviour physics: element physics.
	first updateBlock: [ :behaviour :step |
		element physics addBehaviour: second ].
	element physics addBehaviour: first.
	world step.
	self assert: first updates size equals: 1.
	self assert: second updates isEmpty.
	world step.
	self assert: second updates size equals: 1
]

{ #category : 'tests - behaviours' }
CFPhysicsBehaviourLifecycleTests >> testBehaviourIsRemovedWhenElementLeavesItsWorld [
	| root element world behaviour |
	root := BlElement new.
	element := BlElement new.
	root addChild: element.
	world := root physics beWorld.
	world gravity: 0 @ 0.
	behaviour := CFPhysicsRecordingBehaviour physics: element physics.
	element physics addBehaviour: behaviour.
	root removeChild: element.
	world step.
	self assert: behaviour isRemoved.
	self assert: behaviour removalCount equals: 1.
	self assert: element physics behaviours isEmpty.
	self assert: world behaviours isEmpty
]

{ #category : 'tests - behaviours' }
CFPhysicsBehaviourLifecycleTests >> testWorldOwningElementCanOwnBehaviour [
	| root world behaviour |
	root := BlElement new.
	world := root physics beWorld.
	world gravity: 0 @ 0.
	behaviour := CFPhysicsRecordingBehaviour physics: root physics.
	root physics addBehaviour: behaviour.
	world step.
	self assert: behaviour updates size equals: 1.
	self assert: behaviour stillBelongsToWorld
]
