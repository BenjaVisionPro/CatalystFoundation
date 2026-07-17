Class {
	#name : 'CFPhysicsContact',
	#superclass : 'Object',
	#instVars : [ 'firstBody', 'secondBody', 'manifold', 'touching', 'touchingBeforeUpdate' ],
	#category : 'BVC-Foundation-Physics-Collision',
	#package : 'BVC-Foundation-Physics-Collision'
}

{ #category : 'instance creation' }
CFPhysicsContact class >> first: first second: second manifold: aManifold [
	^ self new
		firstBody: first;
		secondBody: second;
		updateWithManifold: aManifold;
		yourself
]

{ #category : 'lifecycle' }
CFPhysicsContact >> beganThisStep [
	^ touching and: [ touchingBeforeUpdate not ]
]

{ #category : 'lifecycle' }
CFPhysicsContact >> continuedThisStep [
	^ touching and: [ touchingBeforeUpdate ]
]

{ #category : 'lifecycle' }
CFPhysicsContact >> endedThisStep [
	^ touching not and: [ touchingBeforeUpdate ]
]

{ #category : 'accessing' }
CFPhysicsContact >> firstBody [
	^ firstBody
]

{ #category : 'accessing' }
CFPhysicsContact >> firstBody: aBody [
	firstBody := aBody
]

{ #category : 'initialization' }
CFPhysicsContact >> initialize [
	super initialize.
	touching := false.
	touchingBeforeUpdate := false
]

{ #category : 'testing' }
CFPhysicsContact >> involves: aBody [
	^ firstBody == aBody or: [ secondBody == aBody ]
]

{ #category : 'testing' }
CFPhysicsContact >> isTouching [
	^ touching
]

{ #category : 'accessing' }
CFPhysicsContact >> manifold [
	^ manifold
]

{ #category : 'accessing' }
CFPhysicsContact >> normal [
	^ manifold normal
]

{ #category : 'accessing' }
CFPhysicsContact >> penetration [
	^ manifold penetration
]

{ #category : 'lifecycle' }
CFPhysicsContact >> markSeparated [
	touchingBeforeUpdate := touching.
	touching := false
]

{ #category : 'resolving' }
CFPhysicsContact >> resolve [
	| inverseMassSum correction relativeVelocity normalVelocity impulse normal |
	touching ifFalse: [ ^ self ].
	normal := manifold normal.
	inverseMassSum := firstBody inverseMass + secondBody inverseMass.
	inverseMassSum = 0 ifTrue: [ ^ self ].
	correction := normal * (manifold penetration / inverseMassSum).
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

{ #category : 'updating' }
CFPhysicsContact >> updateWithManifold: aManifold [
	touchingBeforeUpdate := touching.
	manifold := aManifold.
	touching := true
]
