"
I represent an ordered pair of collision shapes and their owning bodies. I provide a stable key and deterministic ordering for broad-phase and contact processing.

Existing one-shape body callers continue to use first:second:, which selects each body's primary shape at shape index zero.
"
Class {
	#name : 'CFPhysicsPair',
	#superclass : 'Object',
	#instVars : [ 'firstBody', 'firstShape', 'firstShapeIndex', 'secondBody', 'secondShape', 'secondShapeIndex', 'key' ],
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
}

{ #category : 'instance creation' }
CFPhysicsPair class >> first: first second: second [
	^ self
		firstBody: first
		shape: first shapeState
		shapeIndex: 0
		secondBody: second
		shape: second shapeState
		shapeIndex: 0
]

{ #category : 'instance creation' }
CFPhysicsPair class >> firstBody: firstBody shape: firstShape shapeIndex: aFirstShapeIndex secondBody: secondBody shape: secondShape shapeIndex: aSecondShapeIndex [
	^ self new
		initializeFirstBody: firstBody
		shape: firstShape
		shapeIndex: aFirstShapeIndex
		secondBody: secondBody
		shape: secondShape
		shapeIndex: aSecondShapeIndex
]

{ #category : 'initialization' }
CFPhysicsPair >> initializeFirstBody: aFirstBody shape: aFirstShape shapeIndex: aFirstShapeIndex secondBody: aSecondBody shape: aSecondShape shapeIndex: aSecondShapeIndex [
	| firstComesFirst |
	firstComesFirst := aFirstBody sequence < aSecondBody sequence
		or: [ aFirstBody sequence = aSecondBody sequence and: [ aFirstShapeIndex <= aSecondShapeIndex ] ].
	firstComesFirst
		ifTrue: [
			firstBody := aFirstBody.
			firstShape := aFirstShape.
			firstShapeIndex := aFirstShapeIndex.
			secondBody := aSecondBody.
			secondShape := aSecondShape.
			secondShapeIndex := aSecondShapeIndex ]
		ifFalse: [
			firstBody := aSecondBody.
			firstShape := aSecondShape.
			firstShapeIndex := aSecondShapeIndex.
			secondBody := aFirstBody.
			secondShape := aFirstShape.
			secondShapeIndex := aFirstShapeIndex ].
	key := CFPhysicsContactKey
		firstBody: firstBody
		firstShapeIndex: firstShapeIndex
		firstShapeRevision: firstShape geometryRevision
		secondBody: secondBody
		secondShapeIndex: secondShapeIndex
		secondShapeRevision: secondShape geometryRevision
]

{ #category : 'accessing' }
CFPhysicsPair >> firstBody [ ^ firstBody ]
{ #category : 'accessing' }
CFPhysicsPair >> firstShape [ ^ firstShape ]
{ #category : 'accessing' }
CFPhysicsPair >> firstShapeIndex [ ^ firstShapeIndex ]
{ #category : 'accessing' }
CFPhysicsPair >> secondBody [ ^ secondBody ]
{ #category : 'accessing' }
CFPhysicsPair >> secondShape [ ^ secondShape ]
{ #category : 'accessing' }
CFPhysicsPair >> secondShapeIndex [ ^ secondShapeIndex ]
{ #category : 'accessing' }
CFPhysicsPair >> key [ ^ key ]

{ #category : 'comparing' }
CFPhysicsPair >> = anotherObject [
	^ self class == anotherObject class and: [ key = anotherObject key ]
]

{ #category : 'comparing' }
CFPhysicsPair >> hash [ ^ key hash ]

{ #category : 'ordering' }
CFPhysicsPair >> comesBefore: anotherPair [
	key firstSequence = anotherPair key firstSequence ifFalse: [
		^ key firstSequence < anotherPair key firstSequence ].
	key firstShapeIndex = anotherPair key firstShapeIndex ifFalse: [
		^ key firstShapeIndex < anotherPair key firstShapeIndex ].
	key firstShapeRevision = anotherPair key firstShapeRevision ifFalse: [
		^ key firstShapeRevision < anotherPair key firstShapeRevision ].
	key secondSequence = anotherPair key secondSequence ifFalse: [
		^ key secondSequence < anotherPair key secondSequence ].
	key secondShapeIndex = anotherPair key secondShapeIndex ifFalse: [
		^ key secondShapeIndex < anotherPair key secondShapeIndex ].
	^ key secondShapeRevision < anotherPair key secondShapeRevision
]
