"
I am a live physical performer owned by one CFPhysics facade and updated by one CFPhysicsWorld.

Concrete subclasses retain only the state and physical structures required by their mechanism. I provide the common ownership, update and idempotent removal lifecycle.
"
Class {
	#name : 'CFPhysicsBehaviour',
	#superclass : 'Object',
	#instVars : [ 'physics', 'world', 'removed' ],
	#category : 'BVC-Foundation-Physics-Core-Behaviours',
	#package : 'BVC-Foundation-Physics-Core'
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
