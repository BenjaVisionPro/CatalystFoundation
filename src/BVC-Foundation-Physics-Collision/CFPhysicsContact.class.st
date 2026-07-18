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
CFPhysicsContact >> applyImpulse: anImpulse at: aPoint [
	firstBody applyImpulse: anImpulse negated atWorldPoint: aPoint.
	secondBody applyImpulse: anImpulse atWorldPoint: aPoint
]

{ #category : 'private - solving' }
CFPhysicsContact >> crossOf: aPoint with: aVector [
	^ (aPoint x * aVector y) - (aPoint y * aVector x)
]

{ #category : 'private - solving' }
CFPhysicsContact >> effectiveMassAlong: anAxis at: aPoint [
	| firstRadius secondRadius firstCross secondCross |
	firstRadius := aPoint - firstBody centre.
	secondRadius := aPoint - secondBody centre.
	firstCross := self crossOf: firstRadius with: anAxis.
	secondCross := self crossOf: secondRadius with: anAxis.
	^ firstBody inverseMass + secondBody inverseMass
		+ (firstBody inverseInertia * firstCross squared)
		+ (secondBody inverseInertia * secondCross squared)
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
CFPhysicsContact >> solvePosition [
	| currentManifold inverseMassSum correction normal effectivePenetration contactPoint firstRadius secondRadius firstAngular secondAngular |
	(touching and: [ self shouldSolve ]) ifFalse: [ ^ self ].
	currentManifold := CFPhysicsCollision manifoldBetween: firstBody and: secondBody.
	currentManifold ifNil: [ ^ self ].
	currentManifold preserveImpulsesFrom: manifold.
	manifold := currentManifold.
	inverseMassSum := self effectiveMassAlong: currentManifold normal at: currentManifold contactPoints first position.
	inverseMassSum = 0 ifTrue: [ ^ self ].
	effectivePenetration := (manifold penetration - self positionSlop) max: 0.0.
	effectivePenetration = 0 ifTrue: [ ^ self ].
	normal := manifold normal.
	correction := normal * (effectivePenetration / inverseMassSum).
	contactPoint := manifold contactPoints first position.
	firstRadius := contactPoint - firstBody centre.
	secondRadius := contactPoint - secondBody centre.
	firstAngular := (self crossOf: firstRadius with: correction) * firstBody inverseInertia negated.
	secondAngular := (self crossOf: secondRadius with: correction) * secondBody inverseInertia.
	firstBody translateBy: correction * firstBody inverseMass negated.
	secondBody translateBy: correction * secondBody inverseMass.
	firstBody rotateBy: firstAngular.
	secondBody rotateBy: secondAngular
]

{ #category : 'resolving' }
CFPhysicsContact >> solveVelocity [
	| normal point contactPosition relativeVelocity normalVelocity effectiveMass impulseMagnitude oldImpulse tangent tangentVelocity tangentMass tangentMagnitude oldTangent maximumFriction |
	(touching and: [ self shouldSolve ]) ifFalse: [ ^ self ].
	manifold contactPoints ifEmpty: [ ^ self ].
	normal := manifold normal.
	point := manifold contactPoints first.
	contactPosition := point position.
	relativeVelocity := (secondBody velocityAtWorldPoint: contactPosition) - (firstBody velocityAtWorldPoint: contactPosition).
	normalVelocity := (relativeVelocity x * normal x) + (relativeVelocity y * normal y).
	effectiveMass := self effectiveMassAlong: normal at: contactPosition.
	effectiveMass = 0 ifTrue: [ ^ self ].
	impulseMagnitude := (point velocityBias - normalVelocity) / effectiveMass.
	oldImpulse := point normalImpulse.
	point normalImpulse: (oldImpulse + impulseMagnitude max: 0.0).
	self applyImpulse: normal * (point normalImpulse - oldImpulse) at: contactPosition.
	relativeVelocity := (secondBody velocityAtWorldPoint: contactPosition) - (firstBody velocityAtWorldPoint: contactPosition).
	tangent := normal y negated @ normal x.
	tangentVelocity := (relativeVelocity x * tangent x) + (relativeVelocity y * tangent y).
	tangentMass := self effectiveMassAlong: tangent at: contactPosition.
	tangentMass = 0 ifTrue: [ ^ self ].
	tangentMagnitude := tangentVelocity negated / tangentMass.
	oldTangent := point tangentImpulse.
	maximumFriction := self friction * point normalImpulse.
	point tangentImpulse: ((oldTangent + tangentMagnitude max: maximumFriction negated) min: maximumFriction).
	self applyImpulse: tangent * (point tangentImpulse - oldTangent) at: contactPosition
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
	self applyImpulse: impulse at: point position
]


{ #category : 'private - solving' }
CFPhysicsContact >> shouldSolve [
	^ firstBody isAwake or: [ secondBody isAwake ]
]


{ #category : 'private - solving' }
CFPhysicsContact >> prepareVelocityConstraintWithRestitutionThreshold: aThreshold [
	| point normal relativeVelocity normalVelocity |
	(touching and: [ self shouldSolve and: [ manifold contactPoints notEmpty ] ]) ifFalse: [ ^ self ].
	point := manifold contactPoints first.
	normal := manifold normal.
	relativeVelocity := (secondBody velocityAtWorldPoint: point position) - (firstBody velocityAtWorldPoint: point position).
	normalVelocity := (relativeVelocity x * normal x) + (relativeVelocity y * normal y).
	point velocityBias: (normalVelocity < aThreshold negated
		ifTrue: [ normalVelocity negated * self restitution ]
		ifFalse: [ 0.0 ])
]

{ #category : 'private - solving' }
CFPhysicsContact >> propagateAwakeState [
	firstBody isAwake ifTrue: [ secondBody isSleeping ifTrue: [ secondBody wake ] ].
	secondBody isAwake ifTrue: [ firstBody isSleeping ifTrue: [ firstBody wake ] ]
]

{ #category : 'private - solving' }
CFPhysicsContact >> positionSlop [
	^ 0.000001
]
