"
I identify a shape pair independently of encounter order.

My body sequence and shape index components provide stable equality and hashing for contact lookup and reconciliation. Existing one-shape body contacts use shape index zero.
"
Class {
	#name : 'CFPhysicsContactKey',
	#superclass : 'Object',
	#instVars : [ 'firstSequence', 'firstShapeIndex', 'secondSequence', 'secondShapeIndex' ],
	#category : 'BVC-Physics-Collision',
	#package : 'BVC-Physics-Collision'
}

{ #category : 'instance creation' }
CFPhysicsContactKey class >> first: firstBody second: secondBody [
	^ self
		firstBody: firstBody
		firstShapeIndex: 0
		secondBody: secondBody
		secondShapeIndex: 0
]

{ #category : 'instance creation' }
CFPhysicsContactKey class >> firstBody: firstBody firstShapeIndex: aFirstShapeIndex secondBody: secondBody secondShapeIndex: aSecondShapeIndex [
	| firstComesFirst |
	firstComesFirst := firstBody sequence < secondBody sequence
		or: [ firstBody sequence = secondBody sequence and: [ aFirstShapeIndex <= aSecondShapeIndex ] ].
	^ firstComesFirst
		ifTrue: [ self new
			firstSequence: firstBody sequence;
			firstShapeIndex: aFirstShapeIndex;
			secondSequence: secondBody sequence;
			secondShapeIndex: aSecondShapeIndex;
			yourself ]
		ifFalse: [ self new
			firstSequence: secondBody sequence;
			firstShapeIndex: aSecondShapeIndex;
			secondSequence: firstBody sequence;
			secondShapeIndex: aFirstShapeIndex;
			yourself ]
]

{ #category : 'comparing' }
CFPhysicsContactKey >> = anotherObject [
	^ self class == anotherObject class
		and: [ firstSequence = anotherObject firstSequence
		and: [ firstShapeIndex = anotherObject firstShapeIndex
		and: [ secondSequence = anotherObject secondSequence
		and: [ secondShapeIndex = anotherObject secondShapeIndex ] ] ] ]
]

{ #category : 'accessing' }
CFPhysicsContactKey >> firstSequence [ ^ firstSequence ]
{ #category : 'accessing' }
CFPhysicsContactKey >> firstSequence: anInteger [ firstSequence := anInteger ]
{ #category : 'accessing' }
CFPhysicsContactKey >> firstShapeIndex [ ^ firstShapeIndex ]
{ #category : 'accessing' }
CFPhysicsContactKey >> firstShapeIndex: anInteger [ firstShapeIndex := anInteger ]
{ #category : 'accessing' }
CFPhysicsContactKey >> secondSequence [ ^ secondSequence ]
{ #category : 'accessing' }
CFPhysicsContactKey >> secondSequence: anInteger [ secondSequence := anInteger ]
{ #category : 'accessing' }
CFPhysicsContactKey >> secondShapeIndex [ ^ secondShapeIndex ]
{ #category : 'accessing' }
CFPhysicsContactKey >> secondShapeIndex: anInteger [ secondShapeIndex := anInteger ]

{ #category : 'comparing' }
CFPhysicsContactKey >> hash [
	^ (((firstSequence hash bitXor: firstShapeIndex hash) bitXor: secondSequence hash) bitXor: secondShapeIndex hash)
]
