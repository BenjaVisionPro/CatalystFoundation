Class {
	#name : 'CFPhysicsPair',
	#superclass : 'Object',
	#instVars : [ 'firstBody', 'secondBody', 'key' ],
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'instance creation' }
CFPhysicsPair class >> first: first second: second [
	^ self new initializeFirst: first second: second
]

{ #category : 'initialization' }
CFPhysicsPair >> initializeFirst: first second: second [
	first sequence <= second sequence
		ifTrue: [ firstBody := first. secondBody := second ]
		ifFalse: [ firstBody := second. secondBody := first ].
	key := CFPhysicsContactKey first: firstBody second: secondBody
]

{ #category : 'accessing' }
CFPhysicsPair >> firstBody [ ^ firstBody ]

{ #category : 'accessing' }
CFPhysicsPair >> secondBody [ ^ secondBody ]

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
	key firstSequence = anotherPair key firstSequence
		ifTrue: [ ^ key secondSequence < anotherPair key secondSequence ].
	^ key firstSequence < anotherPair key firstSequence
]
