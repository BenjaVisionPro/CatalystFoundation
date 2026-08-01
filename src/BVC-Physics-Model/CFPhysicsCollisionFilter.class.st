"
I represent the collision membership and mask of a body.

My responsibility is to decide whether two bodies are eligible to collide.
"
Class {
	#name : 'CFPhysicsCollisionFilter',
	#superclass : 'Object',
	#instVars : [ 'categoryBits', 'maskBits', 'groupIndex' ],
	#category : 'BVC-Physics-Model',
	#package : 'BVC-Physics-Model'
}

{ #category : 'initialization' }
CFPhysicsCollisionFilter >> initialize [
	super initialize.
	categoryBits := 1.
	maskBits := 16rFFFFFFFF.
	groupIndex := 0
]

{ #category : 'accessing' }
CFPhysicsCollisionFilter >> categoryBits [
	^ categoryBits
]

{ #category : 'accessing' }
CFPhysicsCollisionFilter >> categoryBits: anInteger [
	(anInteger isInteger and: [ anInteger >= 0 ])
		ifFalse: [ self error: 'Collision category bits must be a non-negative integer' ].
	categoryBits := anInteger
]

{ #category : 'accessing' }
CFPhysicsCollisionFilter >> maskBits [
	^ maskBits
]

{ #category : 'accessing' }
CFPhysicsCollisionFilter >> maskBits: anInteger [
	(anInteger isInteger and: [ anInteger >= 0 ])
		ifFalse: [ self error: 'Collision mask bits must be a non-negative integer' ].
	maskBits := anInteger
]

{ #category : 'accessing' }
CFPhysicsCollisionFilter >> groupIndex [
	^ groupIndex
]

{ #category : 'accessing' }
CFPhysicsCollisionFilter >> groupIndex: anInteger [
	anInteger isInteger
		ifFalse: [ self error: 'Collision group index must be an integer' ].
	groupIndex := anInteger
]

{ #category : 'testing' }
CFPhysicsCollisionFilter >> allowsCollisionWith: anotherFilter [
	(groupIndex ~= 0 and: [ groupIndex = anotherFilter groupIndex ])
		ifTrue: [ ^ groupIndex > 0 ].
	^ ((maskBits bitAnd: anotherFilter categoryBits) ~= 0)
		and: [ (anotherFilter maskBits bitAnd: categoryBits) ~= 0 ]
]
