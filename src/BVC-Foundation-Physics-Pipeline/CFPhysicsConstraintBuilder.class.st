Class {
	#name : 'CFPhysicsConstraintBuilder',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'building' }
CFPhysicsConstraintBuilder >> constraintsFrom: contacts bodyStates: bodyStates [
	^ (contacts reject: [ :contact | contact isSensor ]) collect: [ :contact |
		self
			constraintFrom: contact
			bodyStateA: (bodyStates at: contact firstBody)
			bodyStateB: (bodyStates at: contact secondBody) ]
]

{ #category : 'private - building' }
CFPhysicsConstraintBuilder >> constraintFrom: contact bodyStateA: stateA bodyStateB: stateB [
	| normal tangent constraint |
	normal := contact manifold normal.
	tangent := normal y negated @ normal x.
	constraint := CFPhysicsPreparedConstraint new
		contact: contact;
		bodyStateA: stateA;
		bodyStateB: stateB;
		normal: normal;
		tangent: tangent;
		friction: (contact firstBody friction * contact secondBody friction) sqrt;
		restitution: (contact firstBody restitution max: contact secondBody restitution);
		yourself.
	constraint points: (contact manifold contactPoints collect: [ :manifoldPoint |
		self
			pointFrom: manifoldPoint
			contact: contact
			bodyStateA: stateA
			bodyStateB: stateB
			normal: normal
			tangent: tangent ]).
	^ constraint
]

{ #category : 'private - building' }
CFPhysicsConstraintBuilder >> pointFrom: manifoldPoint contact: contact bodyStateA: stateA bodyStateB: stateB normal: normal tangent: tangent [
	| point anchorA anchorB rnA rnB rtA rtB normalDenominator tangentDenominator relativeVelocity |
	anchorA := self rotatedAnchorFor: manifoldPoint localAnchorA body: contact firstBody.
	anchorB := self rotatedAnchorFor: manifoldPoint localAnchorB body: contact secondBody.
	rnA := self cross: anchorA with: normal.
	rnB := self cross: anchorB with: normal.
	normalDenominator := contact firstBody inverseMass + contact secondBody inverseMass
		+ (contact firstBody inverseInertia * rnA squared)
		+ (contact secondBody inverseInertia * rnB squared).
	rtA := self cross: anchorA with: tangent.
	rtB := self cross: anchorB with: tangent.
	tangentDenominator := contact firstBody inverseMass + contact secondBody inverseMass
		+ (contact firstBody inverseInertia * rtA squared)
		+ (contact secondBody inverseInertia * rtB squared).
	relativeVelocity := (stateB linearVelocity + (self crossScalar: stateB angularVelocity with: anchorB))
		- (stateA linearVelocity + (self crossScalar: stateA angularVelocity with: anchorA)).
	point := CFPhysicsConstraintPoint new
		manifoldPoint: manifoldPoint;
		featureId: manifoldPoint featureId;
		anchorA: anchorA;
		anchorB: anchorB;
		baseSeparation: manifoldPoint separation;
		normalMass: (normalDenominator = 0.0 ifTrue: [ 0.0 ] ifFalse: [ 1.0 / normalDenominator ]);
		tangentMass: (tangentDenominator = 0.0 ifTrue: [ 0.0 ] ifFalse: [ 1.0 / tangentDenominator ]);
		relativeNormalVelocity: (self dot: relativeVelocity with: normal);
		normalImpulse: manifoldPoint normalImpulse;
		tangentImpulse: manifoldPoint tangentImpulse;
		yourself.
	^ point
]

{ #category : 'private - geometry' }
CFPhysicsConstraintBuilder >> rotatedAnchorFor: localAnchor body: body [
	| localCentre relative cosine sine |
	localCentre := body shapeState extent / 2.0.
	relative := localAnchor - localCentre.
	cosine := body rotation cos.
	sine := body rotation sin.
	^ ((relative x * cosine) - (relative y * sine))
		@ ((relative x * sine) + (relative y * cosine))
]

{ #category : 'private - mathematics' }
CFPhysicsConstraintBuilder >> dot: first with: second [
	^ (first x * second x) + (first y * second y)
]

{ #category : 'private - mathematics' }
CFPhysicsConstraintBuilder >> cross: first with: second [
	^ (first x * second y) - (first y * second x)
]

{ #category : 'private - mathematics' }
CFPhysicsConstraintBuilder >> crossScalar: scalar with: vector [
	^ (scalar * vector y negated) @ (scalar * vector x)
]
