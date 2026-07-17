Class {
	#name : 'CFPhysicsContact',
	#superclass : 'Object',
	#instVars : [ 'firstBody', 'secondBody', 'manifold', 'touching', 'touchingBeforeUpdate' ],
	#category : 'BVC-Foundation-Physics-Collision',
	#package : 'BVC-Foundation-Physics-Collision'
}

{ #category : 'instance creation' }
CFPhysicsContact class >> first: first second: second manifold: aManifold [
	^ self new firstBody: first; secondBody: second; updateWithManifold: aManifold; yourself
]

{ #category : 'private - solving' }
CFPhysicsContact >> applyImpulse: anImpulse [
	firstBody addVelocity: anImpulse * firstBody inverseMass negated.
	secondBody addVelocity: anImpulse * secondBody inverseMass
]

{ #category : 'lifecycle' }
CFPhysicsContact >> beganThisStep [ ^ touching and: [ touchingBeforeUpdate not ] ]
{ #category : 'lifecycle' }
CFPhysicsContact >> continuedThisStep [ ^ touching and: [ touchingBeforeUpdate ] ]
{ #category : 'lifecycle' }
CFPhysicsContact >> endedThisStep [ ^ touching not and: [ touchingBeforeUpdate ] ]
{ #category : 'accessing' }
CFPhysicsContact >> firstBody [ ^ firstBody ]
{ #category : 'accessing' }
CFPhysicsContact >> firstBody: aBody [ firstBody := aBody ]

{ #category : 'private - solving' }
CFPhysicsContact >> friction [
	^ (firstBody friction * secondBody friction) sqrt
]

{ #category : 'initialization' }
CFPhysicsContact >> initialize [
	super initialize.
	touching := false.
	touchingBeforeUpdate := false
]

{ #category : 'testing' }
CFPhysicsContact >> involves: aBody [ ^ firstBody == aBody or: [ secondBody == aBody ] ]
{ #category : 'testing' }
CFPhysicsContact >> isTouching [ ^ touching ]
{ #category : 'accessing' }
CFPhysicsContact >> manifold [ ^ manifold ]
{ #category : 'accessing' }
CFPhysicsContact >> normal [ ^ manifold normal ]
{ #category : 'accessing' }
CFPhysicsContact >> penetration [ ^ manifold penetration ]

{ #category : 'lifecycle' }
CFPhysicsContact >> markSeparated [
	touchingBeforeUpdate := touching.
	touching := false
]

{ #category : 'private - solving' }
CFPhysicsContact >> restitution [
	^ firstBody restitution max: secondBody restitution
]

{ #category : 'resolving' }
CFPhysicsContact >> solvePositionFraction: aFraction [
	| inverseMassSum correction normal |
	(touching and: [ self shouldSolve ]) ifFalse: [ ^ self ].
	inverseMassSum := firstBody inverseMass + secondBody inverseMass.
	inverseMassSum = 0 ifTrue: [ ^ self ].
	normal := manifold normal.
	correction := normal * ((manifold penetration * aFraction) / inverseMassSum).
	firstBody translateBy: correction * firstBody inverseMass negated.
	secondBody translateBy: correction * secondBody inverseMass
]

{ #category : 'resolving' }
CFPhysicsContact >> solveVelocity [
	| inverseMassSum normal point relativeVelocity normalVelocity impulseMagnitude oldImpulse tangent tangentVelocity tangentMagnitude oldTangent maximumFriction |
	(touching and: [ self shouldSolve ]) ifFalse: [ ^ self ].
	inverseMassSum := firstBody inverseMass + secondBody inverseMass.
	inverseMassSum = 0 ifTrue: [ ^ self ].
	manifold contactPoints ifEmpty: [ ^ self ].
	normal := manifold normal.
	point := manifold contactPoints first.
	relativeVelocity := secondBody velocity - firstBody velocity.
	normalVelocity := (relativeVelocity x * normal x) + (relativeVelocity y * normal y).
	impulseMagnitude := (normalVelocity negated * (1.0 + self restitution)) / inverseMassSum.
	oldImpulse := point normalImpulse.
	point normalImpulse: (oldImpulse + impulseMagnitude max: 0.0).
	self applyImpulse: normal * (point normalImpulse - oldImpulse).
	relativeVelocity := secondBody velocity - firstBody velocity.
	tangent := normal y negated @ normal x.
	tangentVelocity := (relativeVelocity x * tangent x) + (relativeVelocity y * tangent y).
	tangentMagnitude := tangentVelocity negated / inverseMassSum.
	oldTangent := point tangentImpulse.
	maximumFriction := self friction * point normalImpulse.
	point tangentImpulse: ((oldTangent + tangentMagnitude max: maximumFriction negated) min: maximumFriction).
	self applyImpulse: tangent * (point tangentImpulse - oldTangent)
]

{ #category : 'accessing' }
CFPhysicsContact >> secondBody [ ^ secondBody ]
{ #category : 'accessing' }
CFPhysicsContact >> secondBody: aBody [ secondBody := aBody ]

{ #category : 'updating' }
CFPhysicsContact >> updateWithManifold: aManifold [
	touchingBeforeUpdate := touching.
	aManifold preserveImpulsesFrom: manifold.
	manifold := aManifold.
	touching := true
]

{ #category : 'resolving' }
CFPhysicsContact >> warmStart [
	| point normal tangent impulse |
	(touching and: [ self shouldSolve and: [ manifold contactPoints notEmpty ] ]) ifFalse: [ ^ self ].
	point := manifold contactPoints first.
	normal := manifold normal.
	tangent := normal y negated @ normal x.
	impulse := (normal * point normalImpulse) + (tangent * point tangentImpulse).
	self applyImpulse: impulse
]


{ #category : 'private - solving' }
CFPhysicsContact >> shouldSolve [
	^ firstBody isAwake or: [ secondBody isAwake ]
]
