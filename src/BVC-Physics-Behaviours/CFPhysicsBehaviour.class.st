"
I represent a reusable orchestration of Physics across one or more bodies.

My responsibility is to participate in a world step and manage my ownership and removal lifecycle. Subclasses define the physical mechanism I apply.
"
Class {
	#name : 'CFPhysicsBehaviour',
	#superclass : 'Object',
	#instVars : [ 'physics', 'world', 'removed' ],
	#category : 'BVC-Physics-Behaviours',
	#package : 'BVC-Physics-Behaviours'
}

{ #category : 'instance creation' }
CFPhysicsBehaviour class >> physics: aPhysics [
	^ self new
		physics: aPhysics;
		yourself
]

{ #category : 'initialization' }
CFPhysicsBehaviour >> initialize [
	super initialize.
	removed := false
]

{ #category : 'accessing' }
CFPhysicsBehaviour >> physics [
	^ physics
]

{ #category : 'private - installation' }
CFPhysicsBehaviour >> physics: aPhysics [
	physics := aPhysics
]

{ #category : 'accessing' }
CFPhysicsBehaviour >> world [
	^ world
]

{ #category : 'private - installation' }
CFPhysicsBehaviour >> world: aWorld [
	world := aWorld
]

{ #category : 'accessing' }
CFPhysicsBehaviour >> element [
	^ physics element
]

{ #category : 'testing' }
CFPhysicsBehaviour >> isRemoved [
	^ removed
]

{ #category : 'testing' }
CFPhysicsBehaviour >> stillBelongsToWorld [
	^ physics notNil and: [ physics behaviourWorld == world ]
]

{ #category : 'updating' }
CFPhysicsBehaviour >> updateForStep: aPhysicsStep [
	self subclassResponsibility
]

{ #category : 'removing' }
CFPhysicsBehaviour >> remove [
	removed ifTrue: [ ^ self ].
	removed := true.
	[ self removing ] ensure: [
		world ifNotNil: [ world removeBehaviour: self ].
		physics ifNotNil: [ physics removeBehaviour: self ] ].
	^ self
]

{ #category : 'removing' }
CFPhysicsBehaviour >> removing [
]


{ #category : 'protected - participants' }
CFPhysicsBehaviour >> resolvedParticipantsFrom: aCollectionOrProvider default: aBlock [
	aCollectionOrProvider ifNil: [ ^ aBlock value asArray ].
	^ aCollectionOrProvider value asArray
]

{ #category : 'protected - random' }
CFPhysicsBehaviour >> randomValueBetween: minimum and: maximum using: aRandomSource [
	^ minimum + (aRandomSource next * (maximum - minimum))
]
