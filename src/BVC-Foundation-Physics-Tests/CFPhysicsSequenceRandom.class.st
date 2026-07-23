Class {
	#name : 'CFPhysicsSequenceRandom',
	#superclass : 'Object',
	#instVars : [ 'values', 'index' ],
	#category : 'BVC-Foundation-Physics-Tests-Behaviours',
	#package : 'BVC-Foundation-Physics-Tests'
}

{ #category : 'instance creation' }
CFPhysicsSequenceRandom class >> values: aCollection [
	^ self new
		values: aCollection;
		yourself
]

{ #category : 'initialization' }
CFPhysicsSequenceRandom >> initialize [
	super initialize.
	index := 0
]

{ #category : 'accessing' }
CFPhysicsSequenceRandom >> values: aCollection [
	values := aCollection asArray
]

{ #category : 'accessing' }
CFPhysicsSequenceRandom >> next [
	index := index + 1.
	index > values size ifTrue: [
		self error: 'The deterministic random sequence is exhausted' ].
	^ values at: index
]
