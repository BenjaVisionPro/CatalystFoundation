Class {
	#name : 'CFPhysicsContactConstraint',
	#superclass : 'Object',
	#instVars : [ 'contact', 'bodyStateA', 'bodyStateB', 'normal', 'friction', 'restitution', 'points' ],
	#category : 'BVC-Foundation-Physics-Dynamics',
	#package : 'BVC-Foundation-Physics-Dynamics'
}

{ #category : 'instance creation' }
CFPhysicsContactConstraint class >> contact: aContact bodyStateA: stateA bodyStateB: stateB [
	^ self new
		contact: aContact;
		bodyStateA: stateA;
		bodyStateB: stateB;
		prepare;
		yourself
]

{ #category : 'preparing' }
CFPhysicsContactConstraint >> prepare [
	normal := contact manifold normal.
	friction := (contact firstBody friction * contact secondBody friction) sqrt.
	restitution := contact firstBody restitution max: contact secondBody restitution.
	points := contact manifold contactPoints collect: [ :each |
		self preparePoint: each ]
]

{ #category : 'preparing' }
CFPhysicsContactConstraint >> preparePoint: aManifoldPoint [
	| point worldPoint rA rB rnA rnB kNormal tangent rtA rtB kTangent relativeVelocity |
	point := CFPhysicsContactConstraintPoint from: aManifoldPoint.
	worldPoint := aManifoldPoint position.
	rA := worldPoint - contact firstBody centre.
	rB := worldPoint - contact secondBody centre.
	point anchorA: rA; anchorB: rB; baseSeparation: aManifoldPoint separation.
	rnA := self cross: rA with: normal.
	rnB := self cross: rB with: normal.
	kNormal := contact firstBody inverseMass + contact secondBody inverseMass
		+ (contact firstBody inverseInertia * rnA squared)
		+ (contact secondBody inverseInertia * rnB squared).
	point normalMass: (kNormal = 0.0 ifTrue: [ 0.0 ] ifFalse: [ 1.0 / kNormal ]).
	tangent := normal y negated @ normal x.
	rtA := self cross: rA with: tangent.
	rtB := self cross: rB with: tangent.
	kTangent := contact firstBody inverseMass + contact secondBody inverseMass
		+ (contact firstBody inverseInertia * rtA squared)
		+ (contact secondBody inverseInertia * rtB squared).
	point tangentMass: (kTangent = 0.0 ifTrue: [ 0.0 ] ifFalse: [ 1.0 / kTangent ]).
	relativeVelocity := (bodyStateB linearVelocity + (self crossScalar: bodyStateB angularVelocity with: rB))
		- (bodyStateA linearVelocity + (self crossScalar: bodyStateA angularVelocity with: rA)).
	point relativeNormalVelocity: (self dot: relativeVelocity with: normal).
	^ point
]

{ #category : 'solving' }
CFPhysicsContactConstraint >> warmStart [
	| tangent |
	tangent := normal y negated @ normal x.
	points do: [ :point |
		| impulse |
		impulse := (normal * point manifoldPoint normalImpulse)
			+ (tangent * point manifoldPoint tangentImpulse).
		self applyImpulse: impulse at: point ]
]

{ #category : 'solving' }
CFPhysicsContactConstraint >> solveWith: aStep biasEnabled: biasEnabled [
	points do: [ :point | self solveNormalAt: point with: aStep biasEnabled: biasEnabled ].
	points do: [ :point | self solveTangentAt: point ]
]

{ #category : 'private - solving' }
CFPhysicsContactConstraint >> solveNormalAt: point with: aStep biasEnabled: biasEnabled [
	| relativeVelocity normalVelocity separation bias incremental oldImpulse newImpulse |
	relativeVelocity := self relativeVelocityAt: point.
	normalVelocity := self dot: relativeVelocity with: normal.
	separation := point baseSeparation
		+ (self dot: bodyStateB deltaPosition - bodyStateA deltaPosition with: normal).
	bias := biasEnabled ifTrue: [ aStep biasRate * (separation min: 0.0) ] ifFalse: [ 0.0 ].
	incremental := (aStep massCoefficient * point normalMass * (normalVelocity + bias)) negated
		- (aStep impulseCoefficient * point manifoldPoint normalImpulse).
	oldImpulse := point manifoldPoint normalImpulse.
	newImpulse := (oldImpulse + incremental) max: 0.0.
	point manifoldPoint normalImpulse: newImpulse.
	self applyImpulse: normal * (newImpulse - oldImpulse) at: point
]

{ #category : 'private - solving' }
CFPhysicsContactConstraint >> solveTangentAt: point [
	| tangent relativeVelocity tangentVelocity incremental oldImpulse maximum newImpulse |
	tangent := normal y negated @ normal x.
	relativeVelocity := self relativeVelocityAt: point.
	tangentVelocity := self dot: relativeVelocity with: tangent.
	incremental := point tangentMass * tangentVelocity negated.
	oldImpulse := point manifoldPoint tangentImpulse.
	maximum := friction * point manifoldPoint normalImpulse.
	newImpulse := ((oldImpulse + incremental max: maximum negated) min: maximum).
	point manifoldPoint tangentImpulse: newImpulse.
	self applyImpulse: tangent * (newImpulse - oldImpulse) at: point
]

{ #category : 'solving' }
CFPhysicsContactConstraint >> applyRestitutionWithThreshold: threshold [
	points do: [ :point |
		point relativeNormalVelocity < threshold negated ifTrue: [
			| relativeVelocity normalVelocity incremental oldImpulse newImpulse |
			relativeVelocity := self relativeVelocityAt: point.
			normalVelocity := self dot: relativeVelocity with: normal.
			incremental := point normalMass * (normalVelocity + (restitution * point relativeNormalVelocity)) negated.
			oldImpulse := point manifoldPoint normalImpulse.
			newImpulse := (oldImpulse + incremental) max: 0.0.
			point manifoldPoint normalImpulse: newImpulse.
			self applyImpulse: normal * (newImpulse - oldImpulse) at: point ] ]
]

{ #category : 'private - solving' }
CFPhysicsContactConstraint >> relativeVelocityAt: point [
	^ (bodyStateB linearVelocity + (self crossScalar: bodyStateB angularVelocity with: point anchorB))
		- (bodyStateA linearVelocity + (self crossScalar: bodyStateA angularVelocity with: point anchorA))
]

{ #category : 'private - solving' }
CFPhysicsContactConstraint >> applyImpulse: impulse at: point [
	bodyStateA linearVelocity: bodyStateA linearVelocity - (impulse * contact firstBody inverseMass).
	bodyStateA angularVelocity: bodyStateA angularVelocity - ((self cross: point anchorA with: impulse) * contact firstBody inverseInertia).
	bodyStateB linearVelocity: bodyStateB linearVelocity + (impulse * contact secondBody inverseMass).
	bodyStateB angularVelocity: bodyStateB angularVelocity + ((self cross: point anchorB with: impulse) * contact secondBody inverseInertia)
]

{ #category : 'private - mathematics' }
CFPhysicsContactConstraint >> dot: first with: second [ ^ (first x * second x) + (first y * second y) ]
{ #category : 'private - mathematics' }
CFPhysicsContactConstraint >> cross: first with: second [ ^ (first x * second y) - (first y * second x) ]
{ #category : 'private - mathematics' }
CFPhysicsContactConstraint >> crossScalar: scalar with: vector [ ^ (scalar * vector y negated) @ (scalar * vector x) ]

{ #category : 'accessing' }
CFPhysicsContactConstraint >> contact: aContact [ contact := aContact ]
{ #category : 'accessing' }
CFPhysicsContactConstraint >> bodyStateA: aState [ bodyStateA := aState ]
{ #category : 'accessing' }
CFPhysicsContactConstraint >> bodyStateB: aState [ bodyStateB := aState ]
{ #category : 'accessing' }
CFPhysicsContactConstraint >> points [ ^ points ]
