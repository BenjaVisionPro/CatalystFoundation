Class {
	#name : 'CFPhysicsSoftStepSolver',
	#superclass : 'Object',
	#instVars : [ 'step', 'bodyStates', 'constraints' ],
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'instance creation' }
CFPhysicsSoftStepSolver class >> step: aStep bodyStates: aDictionary constraints: aCollection [
	^ self new
		step: aStep;
		bodyStates: aDictionary;
		constraints: aCollection;
		yourself
]

{ #category : 'solving' }
CFPhysicsSoftStepSolver >> solveWithRestitutionThreshold: restitutionThreshold [
	self warmStart.
	step substepCount timesRepeat: [
		self solveContactsWithBias: true.
		self solveDistanceJointsWithBias: true.
		self solveRevoluteJointsWithBias: true.
		bodyStates valuesDo: [ :state | state integratePositionBy: step substepTime ].
		self solveContactsWithBias: false ].
	self applyRestitutionWithThreshold: restitutionThreshold.
	constraints do: [ :constraint | constraint writeImpulsesBack ].
	bodyStates valuesDo: [ :state | state commit ]
]

{ #category : 'solving' }
CFPhysicsSoftStepSolver >> solveImpactWithRestitutionThreshold: restitutionThreshold [
	self warmStart.
	step substepCount timesRepeat: [
		self solveContactsWithBias: false.
		self solveDistanceJointsWithBias: true.
		self solveRevoluteJointsWithBias: true ].
	self applyRestitutionWithThreshold: restitutionThreshold.
	constraints do: [ :constraint | constraint writeImpulsesBack ]
]

{ #category : 'private - solving' }
CFPhysicsSoftStepSolver >> warmStart [
	self contactConstraints do: [ :constraint |
		constraint points do: [ :point |
			self
				applyImpulse: (constraint normal * point normalImpulse)
					+ (constraint tangent * point tangentImpulse)
				at: point
				constraint: constraint ] ].
	self distanceJointConstraints do: [ :constraint |
		self applyDistanceJointImpulse: constraint direction * constraint impulse constraint: constraint ].
	self revoluteJointConstraints do: [ :constraint |
		self applyRevoluteJointImpulse: constraint impulse constraint: constraint ]
]

{ #category : 'private - solving' }
CFPhysicsSoftStepSolver >> solveContactsWithBias: biasEnabled [
	self contactConstraints do: [ :constraint |
		constraint points do: [ :point |
			self solveNormalAt: point constraint: constraint biasEnabled: biasEnabled ].
		constraint points do: [ :point |
			self solveTangentAt: point constraint: constraint ] ]
]

{ #category : 'private - solving' }
CFPhysicsSoftStepSolver >> solveDistanceJointsWithBias: biasEnabled [
	self distanceJointConstraints do: [ :constraint |
		| relativeVelocity separation bias increment |
		relativeVelocity := self dot: (self distanceJointRelativeVelocity: constraint) with: constraint direction.
		separation := constraint baseSeparation
			+ (self dot: (self distanceJointDeltaPositionFor: constraint bodyStateB)
				- (self distanceJointDeltaPositionFor: constraint bodyStateA)
				with: constraint direction).
		separation := separation
			+ (self dot: (self rotated: constraint anchorB by: (self distanceJointDeltaRotationFor: constraint bodyStateB)) - constraint anchorB with: constraint direction)
			- (self dot: (self rotated: constraint anchorA by: (self distanceJointDeltaRotationFor: constraint bodyStateA)) - constraint anchorA with: constraint direction).
		bias := biasEnabled ifTrue: [ step biasRate * separation ] ifFalse: [ 0.0 ].
		increment := constraint effectiveMass * (relativeVelocity + bias) negated.
		constraint impulse: constraint impulse + increment.
		self applyDistanceJointImpulse: constraint direction * increment constraint: constraint ]
]

{ #category : 'private - solving' }
CFPhysicsSoftStepSolver >> solveRevoluteJointsWithBias: biasEnabled [
	self revoluteJointConstraints do: [ :constraint |
		| relativeVelocity separation bias increment |
		relativeVelocity := self revoluteJointRelativeVelocity: constraint.
		separation := constraint baseSeparation
			+ (self distanceJointDeltaPositionFor: constraint bodyStateB)
			- (self distanceJointDeltaPositionFor: constraint bodyStateA)
			+ ((self rotated: constraint anchorB by: (self distanceJointDeltaRotationFor: constraint bodyStateB)) - constraint anchorB)
			- ((self rotated: constraint anchorA by: (self distanceJointDeltaRotationFor: constraint bodyStateA)) - constraint anchorA).
		bias := biasEnabled ifTrue: [ separation * step biasRate ] ifFalse: [ 0 @ 0 ].
		increment := self revoluteJointImpulseFor: relativeVelocity + bias constraint: constraint.
		constraint impulse: constraint impulse + increment.
		self applyRevoluteJointImpulse: increment constraint: constraint ]
]

{ #category : 'private - solving' }
CFPhysicsSoftStepSolver >> solveNormalAt: point constraint: constraint biasEnabled: biasEnabled [
	| relativeVelocity normalVelocity separation bias increment oldImpulse newImpulse |
	relativeVelocity := self relativeVelocityAt: point constraint: constraint.
	normalVelocity := self dot: relativeVelocity with: constraint normal.
	separation := point baseSeparation
		+ (self dot: constraint bodyStateB deltaPosition - constraint bodyStateA deltaPosition with: constraint normal)
		+ (self dot: (self rotated: point anchorB by: constraint bodyStateB deltaRotation) - point anchorB with: constraint normal)
		- (self dot: (self rotated: point anchorA by: constraint bodyStateA deltaRotation) - point anchorA with: constraint normal).
	bias := biasEnabled
		ifTrue: [ step biasRate * (separation min: 0.0) ]
		ifFalse: [ 0.0 ].
	increment := (step massCoefficient * point normalMass * (normalVelocity + bias)) negated
		- (step impulseCoefficient * point normalImpulse).
	oldImpulse := point normalImpulse.
	newImpulse := (oldImpulse + increment) max: 0.0.
	point normalImpulse: newImpulse.
	self applyImpulse: constraint normal * (newImpulse - oldImpulse) at: point constraint: constraint
]

{ #category : 'private - solving' }
CFPhysicsSoftStepSolver >> solveTangentAt: point constraint: constraint [
	| relativeVelocity tangentVelocity increment oldImpulse maximum newImpulse |
	relativeVelocity := self relativeVelocityAt: point constraint: constraint.
	tangentVelocity := self dot: relativeVelocity with: constraint tangent.
	increment := point tangentMass * tangentVelocity negated.
	oldImpulse := point tangentImpulse.
	maximum := constraint friction * point normalImpulse.
	newImpulse := (((oldImpulse + increment) max: maximum negated) min: maximum).
	point tangentImpulse: newImpulse.
	self applyImpulse: constraint tangent * (newImpulse - oldImpulse) at: point constraint: constraint
]

{ #category : 'private - solving' }
CFPhysicsSoftStepSolver >> applyRestitutionWithThreshold: threshold [
	self contactConstraints do: [ :constraint |
		constraint points do: [ :point |
			point relativeNormalVelocity < threshold negated ifTrue: [
				| normalVelocity increment oldImpulse newImpulse |
				normalVelocity := self dot: (self relativeVelocityAt: point constraint: constraint) with: constraint normal.
				increment := point normalMass
					* (normalVelocity + (constraint restitution * point relativeNormalVelocity)) negated.
				oldImpulse := point normalImpulse.
				newImpulse := (oldImpulse + increment) max: 0.0.
				point normalImpulse: newImpulse.
				self applyImpulse: constraint normal * (newImpulse - oldImpulse) at: point constraint: constraint ] ] ]
]

{ #category : 'private - solving' }
CFPhysicsSoftStepSolver >> applyDistanceJointImpulse: impulse constraint: constraint [
	| anchorA anchorB |
	anchorA := self rotated: constraint anchorA by: (self distanceJointDeltaRotationFor: constraint bodyStateA).
	anchorB := self rotated: constraint anchorB by: (self distanceJointDeltaRotationFor: constraint bodyStateB).
	constraint bodyStateA ifNotNil: [ :state |
		state linearVelocity:
			state linearVelocity - (impulse * constraint firstBody inverseMass).
		state angularVelocity:
			state angularVelocity - ((self cross: anchorA with: impulse) * constraint firstBody inverseInertia) ].
	constraint bodyStateB ifNotNil: [ :state |
		state linearVelocity:
			state linearVelocity + (impulse * constraint secondBody inverseMass).
		state angularVelocity:
			state angularVelocity + ((self cross: anchorB with: impulse) * constraint secondBody inverseInertia) ]
]

{ #category : 'private - solving' }
CFPhysicsSoftStepSolver >> applyRevoluteJointImpulse: impulse constraint: constraint [
	| anchorA anchorB |
	anchorA := self rotated: constraint anchorA by: (self distanceJointDeltaRotationFor: constraint bodyStateA).
	anchorB := self rotated: constraint anchorB by: (self distanceJointDeltaRotationFor: constraint bodyStateB).
	constraint bodyStateA ifNotNil: [ :state |
		state linearVelocity:
			state linearVelocity - (impulse * constraint firstBody inverseMass).
		state angularVelocity:
			state angularVelocity - ((self cross: anchorA with: impulse) * constraint firstBody inverseInertia) ].
	constraint bodyStateB ifNotNil: [ :state |
		state linearVelocity:
			state linearVelocity + (impulse * constraint secondBody inverseMass).
		state angularVelocity:
			state angularVelocity + ((self cross: anchorB with: impulse) * constraint secondBody inverseInertia) ]
]

{ #category : 'private - solving' }
CFPhysicsSoftStepSolver >> distanceJointRelativeVelocity: constraint [
	| anchorA anchorB |
	anchorA := self rotated: constraint anchorA by: (self distanceJointDeltaRotationFor: constraint bodyStateA).
	anchorB := self rotated: constraint anchorB by: (self distanceJointDeltaRotationFor: constraint bodyStateB).
	^ (self distanceJointVelocityFor: constraint bodyStateB anchor: anchorB)
		- (self distanceJointVelocityFor: constraint bodyStateA anchor: anchorA)
]

{ #category : 'private - solving' }
CFPhysicsSoftStepSolver >> revoluteJointRelativeVelocity: constraint [
	| anchorA anchorB |
	anchorA := self rotated: constraint anchorA by: (self distanceJointDeltaRotationFor: constraint bodyStateA).
	anchorB := self rotated: constraint anchorB by: (self distanceJointDeltaRotationFor: constraint bodyStateB).
	^ (self distanceJointVelocityFor: constraint bodyStateB anchor: anchorB)
		- (self distanceJointVelocityFor: constraint bodyStateA anchor: anchorA)
]

{ #category : 'private - solving' }
CFPhysicsSoftStepSolver >> revoluteJointImpulseFor: vector constraint: constraint [
	^ ((constraint effectiveMassXX * vector x) + (constraint effectiveMassXY * vector y)) negated
		@ ((constraint effectiveMassXY * vector x) + (constraint effectiveMassYY * vector y)) negated
]

{ #category : 'private - solving' }
CFPhysicsSoftStepSolver >> distanceJointVelocityFor: aState anchor: anAnchor [
	^ aState
		ifNil: [ 0 @ 0 ]
		ifNotNil: [ aState linearVelocity + (self crossScalar: aState angularVelocity with: anAnchor) ]
]

{ #category : 'private - solving' }
CFPhysicsSoftStepSolver >> distanceJointDeltaPositionFor: aState [
	^ aState ifNil: [ 0 @ 0 ] ifNotNil: [ aState deltaPosition ]
]

{ #category : 'private - solving' }
CFPhysicsSoftStepSolver >> distanceJointDeltaRotationFor: aState [
	^ aState ifNil: [ 0.0 ] ifNotNil: [ aState deltaRotation ]
]

{ #category : 'private - accessing' }
CFPhysicsSoftStepSolver >> contactConstraints [
	^ constraints select: [ :constraint | constraint isKindOf: CFPhysicsPreparedConstraint ]
]

{ #category : 'private - accessing' }
CFPhysicsSoftStepSolver >> distanceJointConstraints [
	^ constraints select: [ :constraint | constraint isKindOf: CFPhysicsPreparedDistanceJoint ]
]

{ #category : 'private - accessing' }
CFPhysicsSoftStepSolver >> revoluteJointConstraints [
	^ constraints select: [ :constraint | constraint isKindOf: CFPhysicsPreparedRevoluteJoint ]
]

{ #category : 'private - solving' }
CFPhysicsSoftStepSolver >> relativeVelocityAt: point constraint: constraint [
	| anchorA anchorB |
	anchorA := self rotated: point anchorA by: constraint bodyStateA deltaRotation.
	anchorB := self rotated: point anchorB by: constraint bodyStateB deltaRotation.
	^ (constraint bodyStateB linearVelocity
		+ (self crossScalar: constraint bodyStateB angularVelocity with: anchorB))
		- (constraint bodyStateA linearVelocity
			+ (self crossScalar: constraint bodyStateA angularVelocity with: anchorA))
]

{ #category : 'private - solving' }
CFPhysicsSoftStepSolver >> applyImpulse: impulse at: point constraint: constraint [
	| anchorA anchorB |
	anchorA := self rotated: point anchorA by: constraint bodyStateA deltaRotation.
	anchorB := self rotated: point anchorB by: constraint bodyStateB deltaRotation.
	constraint bodyStateA linearVelocity:
		constraint bodyStateA linearVelocity - (impulse * constraint firstBody inverseMass).
	constraint bodyStateA angularVelocity:
		constraint bodyStateA angularVelocity
			- ((self cross: anchorA with: impulse) * constraint firstBody inverseInertia).
	constraint bodyStateB linearVelocity:
		constraint bodyStateB linearVelocity + (impulse * constraint secondBody inverseMass).
	constraint bodyStateB angularVelocity:
		constraint bodyStateB angularVelocity
			+ ((self cross: anchorB with: impulse) * constraint secondBody inverseInertia)
]

{ #category : 'private - mathematics' }
CFPhysicsSoftStepSolver >> rotated: vector by: angle [
	| cosine sine |
	cosine := angle cos.
	sine := angle sin.
	^ ((vector x * cosine) - (vector y * sine))
		@ ((vector x * sine) + (vector y * cosine))
]

{ #category : 'private - mathematics' }
CFPhysicsSoftStepSolver >> dot: first with: second [ ^ (first x * second x) + (first y * second y) ]
{ #category : 'private - mathematics' }
CFPhysicsSoftStepSolver >> cross: first with: second [ ^ (first x * second y) - (first y * second x) ]
{ #category : 'private - mathematics' }
CFPhysicsSoftStepSolver >> crossScalar: scalar with: vector [ ^ (scalar * vector y negated) @ (scalar * vector x) ]

{ #category : 'accessing' }
CFPhysicsSoftStepSolver >> step: anObject [ step := anObject ]
{ #category : 'accessing' }
CFPhysicsSoftStepSolver >> bodyStates: aDictionary [ bodyStates := aDictionary ]
{ #category : 'accessing' }
CFPhysicsSoftStepSolver >> constraints: aCollection [ constraints := aCollection ]
