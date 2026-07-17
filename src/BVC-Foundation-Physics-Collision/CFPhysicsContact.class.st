Class {
	#name : 'CFPhysicsContact',
	#superclass : 'Object',
	#instVars : [ 'firstBody', 'secondBody', 'normal', 'penetration' ],
	#category : 'BVC-Foundation-Physics-Collision',
	#package : 'BVC-Foundation-Physics-Collision'
}

{ #category : 'instance creation' }
CFPhysicsContact class >> first: first second: second normal: aNormal penetration: aNumber [
	^ self new
		firstBody: first;
		secondBody: second;
		normal: aNormal;
		penetration: aNumber;
		yourself
]

{ #category : 'accessing' }
CFPhysicsContact >> firstBody [
	^ firstBody
]

{ #category : 'accessing' }
CFPhysicsContact >> firstBody: aBody [
	firstBody := aBody
]

{ #category : 'accessing' }
CFPhysicsContact >> normal [
	^ normal
]

{ #category : 'accessing' }
CFPhysicsContact >> normal: aPoint [
	normal := aPoint
]

{ #category : 'accessing' }
CFPhysicsContact >> penetration [
	^ penetration
]

{ #category : 'accessing' }
CFPhysicsContact >> penetration: aNumber [
	penetration := aNumber
]

{ #category : 'resolving' }
CFPhysicsContact >> resolve [
	| inverseMassSum correction relativeVelocity normalVelocity impulse |
	inverseMassSum := firstBody inverseMass + secondBody inverseMass.
	inverseMassSum = 0 ifTrue: [ ^ self ].
	correction := normal * (penetration / inverseMassSum).
	firstBody translateBy: correction * firstBody inverseMass negated.
	secondBody translateBy: correction * secondBody inverseMass.
	relativeVelocity := secondBody velocity - firstBody velocity.
	normalVelocity := (relativeVelocity x * normal x)
		+ (relativeVelocity y * normal y).
	normalVelocity >= 0 ifTrue: [ ^ self ].
	impulse := normal * (normalVelocity negated / inverseMassSum).
	firstBody addVelocity: impulse * firstBody inverseMass negated.
	secondBody addVelocity: impulse * secondBody inverseMass
]

{ #category : 'accessing' }
CFPhysicsContact >> secondBody [
	^ secondBody
]

{ #category : 'accessing' }
CFPhysicsContact >> secondBody: aBody [
	secondBody := aBody
]
