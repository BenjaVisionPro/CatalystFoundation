Class {
	#name : 'CFPhysicsContactKey',
	#superclass : 'Object',
	#instVars : [ 'firstSequence', 'secondSequence' ],
	#category : 'BVC-Foundation-Physics-Collision',
	#package : 'BVC-Foundation-Physics-Collision'
}

{ #category : 'instance creation' }
CFPhysicsContactKey class >> first: firstBody second: secondBody [
	| firstSequence secondSequence |
	firstSequence := firstBody sequence.
	secondSequence := secondBody sequence.
	^ firstSequence < secondSequence
		ifTrue: [ self new firstSequence: firstSequence; secondSequence: secondSequence; yourself ]
		ifFalse: [ self new firstSequence: secondSequence; secondSequence: firstSequence; yourself ]
]

{ #category : 'comparing' }
CFPhysicsContactKey >> = anotherObject [
	^ self class == anotherObject class
		and: [ firstSequence = anotherObject firstSequence
		and: [ secondSequence = anotherObject secondSequence ] ]
]

{ #category : 'accessing' }
CFPhysicsContactKey >> firstSequence [
	^ firstSequence
]

{ #category : 'accessing' }
CFPhysicsContactKey >> firstSequence: anInteger [
	firstSequence := anInteger
]

{ #category : 'comparing' }
CFPhysicsContactKey >> hash [
	^ firstSequence hash bitXor: secondSequence hash
]

{ #category : 'accessing' }
CFPhysicsContactKey >> secondSequence [
	^ secondSequence
]

{ #category : 'accessing' }
CFPhysicsContactKey >> secondSequence: anInteger [
	secondSequence := anInteger
]
