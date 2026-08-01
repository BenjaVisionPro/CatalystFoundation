"
I solve prepared contacts and joints using the soft-step formulation. I warm-start accumulated impulses, iterates constraints and writes solved impulses back to their persistent owners.
"

Class {
	#name : 'CFPhysicsSoftStepSolver',
	#superclass : 'Object',
	#instVars : [ 'step', 'bodyStates', 'constraints', 'contactConstraints', 'orderedJointConstraints', 'contactPointCount', 'warmStartedContactPointCount', 'restitutionCandidatePointCount', 'distanceJointConstraintCount', 'prismaticJointConstraintCount', 'revoluteJointConstraintCount', 'weldJointConstraintCount', 'mouseJointConstraintCount', 'motorJointConstraintCount' ],
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
}

{ #category : 'instance creation' }
CFPhysicsSoftStepSolver class >> step: aStep bodyStates: anOrderedCollection constraints: aCollection [
	^ self new
		step: aStep;
		bodyStates: anOrderedCollection;
		constraints: aCollection;
		yourself
]

{ #category : 'initialization' }
CFPhysicsSoftStepSolver >> initialize [
	super initialize.
	bodyStates := #().
	constraints := #().
	contactConstraints := #().
	orderedJointConstraints := #().
	contactPointCount := 0.
	warmStartedContactPointCount := 0.
	restitutionCandidatePointCount := 0.
	distanceJointConstraintCount := 0.
	prismaticJointConstraintCount := 0.
	revoluteJointConstraintCount := 0.
	weldJointConstraintCount := 0.
	mouseJointConstraintCount := 0.
	motorJointConstraintCount := 0
]

{ #category : 'solving' }
CFPhysicsSoftStepSolver >> solveWithRestitutionThreshold: restitutionThreshold [
	self warmStart.
	step substepCount timesRepeat: [
		self solveContactsWithBias: true.
		self solveJointConstraintsWithBias: true.
		bodyStates do: [ :state | state integratePositionBy: step substepTime ].
		self solveContactsWithBias: false.
		self solveJointConstraintsWithBias: false ].
	self applyRestitutionWithThreshold: restitutionThreshold.
	contactConstraints do: [ :constraint | constraint writeImpulsesBack ]
]

{ #category : 'solving' }
CFPhysicsSoftStepSolver >> solveImpactWithRestitutionThreshold: restitutionThreshold [
	self warmStart.
	step substepCount timesRepeat: [
		self solveContactsWithBias: false.
		self solveJointConstraintsWithBias: true ].
	self applyRestitutionWithThreshold: restitutionThreshold.
	contactConstraints do: [ :constraint | constraint writeImpulsesBack ]
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
	self orderedJointConstraints do: [ :constraint |
		self warmStartJointConstraint: constraint ]
]

{ #category : 'private - solving' }
CFPhysicsSoftStepSolver >> warmStartJointConstraint: constraint [
	(constraint isKindOf: CFPhysicsPreparedMotorJoint) ifTrue: [ ^ self warmStartMotorJointConstraint: constraint ].
	(constraint isKindOf: CFPhysicsPreparedMouseJoint) ifTrue: [
		^ self warmStartMouseJointConstraint: constraint ].
	(constraint isKindOf: CFPhysicsPreparedDistanceJoint) ifTrue: [
		^ self applyDistanceJointImpulse: (self distanceJointAxisFor: constraint) * constraint impulse constraint: constraint ].
	(constraint isKindOf: CFPhysicsPreparedPrismaticJoint) ifTrue: [
		^ self warmStartPrismaticJointConstraint: constraint ].
	(constraint isKindOf: CFPhysicsPreparedRevoluteJoint) ifTrue: [
		self applyRevoluteJointImpulse: constraint impulse constraint: constraint.
		self warmStartRevoluteJointMotor: constraint.
		(constraint isKindOf: CFPhysicsPreparedWeldJoint) ifTrue: [
			self applyWeldJointAngularImpulse: constraint angularImpulse constraint: constraint ] ]
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
	self orderedJointConstraints do: [ :constraint |
		(constraint isKindOf: CFPhysicsPreparedDistanceJoint) ifTrue: [
			self solveDistanceJointConstraint: constraint biasEnabled: biasEnabled ] ]
]

{ #category : 'private - solving' }
CFPhysicsSoftStepSolver >> solveRevoluteJointsWithBias: biasEnabled [
	self orderedJointConstraints do: [ :constraint |
		(constraint isKindOf: CFPhysicsPreparedRevoluteJoint) ifTrue: [
			self solveRevoluteJointConstraint: constraint biasEnabled: biasEnabled ] ]
]

{ #category : 'private - solving' }
CFPhysicsSoftStepSolver >> solveWeldJointsWithBias: biasEnabled [
	self orderedJointConstraints do: [ :constraint |
		(constraint isKindOf: CFPhysicsPreparedWeldJoint) ifTrue: [
			self solveWeldJointConstraint: constraint biasEnabled: biasEnabled ] ]
]

{ #category : 'private - solving' }
CFPhysicsSoftStepSolver >> solveJointConstraintsWithBias: biasEnabled [
	self orderedJointConstraints do: [ :constraint |
		self solveJointConstraint: constraint biasEnabled: biasEnabled ]
]

{ #category : 'private - solving' }
CFPhysicsSoftStepSolver >> solveJointConstraint: constraint biasEnabled: biasEnabled [
	(constraint isKindOf: CFPhysicsPreparedMotorJoint) ifTrue: [ ^ self solveMotorJointConstraint: constraint biasEnabled: biasEnabled ].
	(constraint isKindOf: CFPhysicsPreparedMouseJoint) ifTrue: [
		^ self solveMouseJointConstraint: constraint biasEnabled: biasEnabled ].
	(constraint isKindOf: CFPhysicsPreparedDistanceJoint) ifTrue: [
		^ self solveDistanceJointConstraint: constraint biasEnabled: biasEnabled ].
	(constraint isKindOf: CFPhysicsPreparedPrismaticJoint) ifTrue: [
		^ self solvePrismaticJointConstraint: constraint biasEnabled: biasEnabled ].
	(constraint isKindOf: CFPhysicsPreparedRevoluteJoint) ifTrue: [
		self solveRevoluteJointConstraint: constraint biasEnabled: biasEnabled.
		(constraint isKindOf: CFPhysicsPreparedWeldJoint) ifTrue: [
			self solveWeldJointConstraint: constraint biasEnabled: biasEnabled ] ]
]


{ #category : 'private - solving' }
CFPhysicsSoftStepSolver >> solveMouseJointConstraint: constraint biasEnabled: biasEnabled [
	| state angularIncrement anchor velocity separation bias massVector increment oldImpulse newImpulse magnitude |
	state := constraint bodyStateB.
	state ifNil: [ ^ self ].
	angularIncrement := (constraint angularMassCoefficient * constraint angularMass * state angularVelocity) negated
		- (constraint angularImpulseCoefficient * constraint angularImpulse).
	constraint angularImpulse: constraint angularImpulse + angularIncrement.
	state angularVelocity: state angularVelocity + (angularIncrement * state inverseInertia).
	anchor := self rotated: constraint anchorB by: (self distanceJointDeltaRotationFor: state).
	velocity := self distanceJointVelocityFor: state anchor: anchor.
	separation := constraint baseSeparation
		+ (self distanceJointDeltaPositionFor: state)
		+ anchor - constraint anchorB.
	bias := separation * constraint biasRate.
	massVector :=
		((constraint effectiveMassXX * (velocity x + bias x))
			+ (constraint effectiveMassXY * (velocity y + bias y)))
		@ ((constraint effectiveMassXY * (velocity x + bias x))
			+ (constraint effectiveMassYY * (velocity y + bias y))).
	increment := (massVector * constraint massCoefficient) negated
		- (constraint linearImpulse * constraint impulseCoefficient).
	oldImpulse := constraint linearImpulse.
	newImpulse := oldImpulse + increment.
	magnitude := newImpulse r.
	(magnitude > constraint maximumImpulse and: [ magnitude > 0.0 ]) ifTrue: [
		newImpulse := newImpulse * (constraint maximumImpulse / magnitude) ].
	constraint linearImpulse: newImpulse.
	self applyMouseJointLinearImpulse: newImpulse - oldImpulse constraint: constraint
]

{ #category : 'private - solving' }
CFPhysicsSoftStepSolver >> warmStartMouseJointConstraint: constraint [
	| state anchor |
	state := constraint bodyStateB.
	state ifNil: [ ^ self ].
	anchor := self rotated: constraint anchorB by: (self distanceJointDeltaRotationFor: state).
	state linearVelocity:
		state linearVelocity + (constraint linearImpulse * state inverseMass).
	state angularVelocity:
		state angularVelocity
			+ (((self cross: anchor with: constraint linearImpulse) + constraint angularImpulse)
				* state inverseInertia)
]

{ #category : 'private - solving' }
CFPhysicsSoftStepSolver >> applyMouseJointLinearImpulse: impulse constraint: constraint [
	| anchor state |
	state := constraint bodyStateB.
	state ifNil: [ ^ self ].
	anchor := self rotated: constraint anchorB by: (self distanceJointDeltaRotationFor: state).
	state linearVelocity: state linearVelocity + (impulse * state inverseMass).
	state angularVelocity: state angularVelocity + ((self cross: anchor with: impulse) * state inverseInertia)
]

{ #category : 'private - solving' }
CFPhysicsSoftStepSolver >> solveDistanceJointConstraint: constraint biasEnabled: biasEnabled [
	| axis relativeVelocity separation bias massCoefficient impulseCoefficient increment |
	axis := self distanceJointAxisFor: constraint.
	relativeVelocity := self dot: (self distanceJointRelativeVelocity: constraint) with: axis.
	separation := (self distanceJointLengthFor: constraint) - constraint joint length.
	constraint springEnabled
		ifTrue: [
			bias := constraint biasRate * separation.
			massCoefficient := constraint massCoefficient.
			impulseCoefficient := constraint impulseCoefficient ]
		ifFalse: [
			bias := biasEnabled ifTrue: [ step biasRate * separation ] ifFalse: [ 0.0 ].
			massCoefficient := biasEnabled ifTrue: [ step massCoefficient ] ifFalse: [ 1.0 ].
			impulseCoefficient := biasEnabled ifTrue: [ step impulseCoefficient ] ifFalse: [ 0.0 ] ].
	increment := (massCoefficient * constraint effectiveMass * (relativeVelocity + bias)) negated
		- (impulseCoefficient * constraint impulse).
	constraint impulse: constraint impulse + increment.
	self applyDistanceJointImpulse: axis * increment constraint: constraint
]

{ #category : 'private - solving' }
CFPhysicsSoftStepSolver >> distanceJointSeparationFor: constraint [
	| anchorA anchorB |
	anchorA := self rotated: constraint anchorA by: (self distanceJointDeltaRotationFor: constraint bodyStateA).
	anchorB := self rotated: constraint anchorB by: (self distanceJointDeltaRotationFor: constraint bodyStateB).
	^ (constraint direction * constraint baseLength)
		+ (self distanceJointDeltaPositionFor: constraint bodyStateB)
		- (self distanceJointDeltaPositionFor: constraint bodyStateA)
		+ anchorB - constraint anchorB
		- anchorA + constraint anchorA
]

{ #category : 'private - solving' }
CFPhysicsSoftStepSolver >> distanceJointLengthFor: constraint [
	^ (self distanceJointSeparationFor: constraint) r
]

{ #category : 'private - solving' }
CFPhysicsSoftStepSolver >> distanceJointAxisFor: constraint [
	| separation length |
	separation := self distanceJointSeparationFor: constraint.
	length := separation r.
	^ length = 0.0 ifTrue: [ 1 @ 0 ] ifFalse: [ separation / length ]
]

{ #category : 'private - solving' }
CFPhysicsSoftStepSolver >> prismaticJointAnchorAFor: constraint [
	^ self rotated: constraint anchorA by: (self distanceJointDeltaRotationFor: constraint bodyStateA)
]

{ #category : 'private - solving' }
CFPhysicsSoftStepSolver >> prismaticJointAnchorBFor: constraint [
	^ self rotated: constraint anchorB by: (self distanceJointDeltaRotationFor: constraint bodyStateB)
]

{ #category : 'private - solving' }
CFPhysicsSoftStepSolver >> prismaticJointAxisFor: constraint [
	^ self rotated: constraint axis by: (self distanceJointDeltaRotationFor: constraint bodyStateA)
]

{ #category : 'private - solving' }
CFPhysicsSoftStepSolver >> prismaticJointSeparationFor: constraint [
	| anchorA anchorB baseSeparation |
	anchorA := self prismaticJointAnchorAFor: constraint.
	anchorB := self prismaticJointAnchorBFor: constraint.
	baseSeparation := (constraint axis * constraint baseTranslation)
		+ (constraint normal * constraint basePerpendicularSeparation).
	^ baseSeparation
		+ (self distanceJointDeltaPositionFor: constraint bodyStateB)
		- (self distanceJointDeltaPositionFor: constraint bodyStateA)
		+ anchorB - constraint anchorB
		- anchorA + constraint anchorA
]

{ #category : 'private - solving' }
CFPhysicsSoftStepSolver >> prismaticJointTranslationFor: constraint [
	^ self dot: (self prismaticJointSeparationFor: constraint) with: (self prismaticJointAxisFor: constraint)
]

{ #category : 'private - solving' }
CFPhysicsSoftStepSolver >> prismaticJointLeverAFor: constraint direction: direction [
	^ self cross:
		(self prismaticJointSeparationFor: constraint) + (self prismaticJointAnchorAFor: constraint)
		with: direction
]

{ #category : 'private - solving' }
CFPhysicsSoftStepSolver >> prismaticJointLeverBFor: constraint direction: direction [
	^ self cross: (self prismaticJointAnchorBFor: constraint) with: direction
]

{ #category : 'private - solving' }
CFPhysicsSoftStepSolver >> prismaticJointVelocityFor: constraint direction: direction leverA: leverA leverB: leverB [
	| velocityA velocityB angularA angularB |
	velocityA := constraint bodyStateA ifNil: [ 0 @ 0 ] ifNotNil: [ :state | state linearVelocity ].
	velocityB := constraint bodyStateB ifNil: [ 0 @ 0 ] ifNotNil: [ :state | state linearVelocity ].
	angularA := constraint bodyStateA ifNil: [ 0.0 ] ifNotNil: [ :state | state angularVelocity ].
	angularB := constraint bodyStateB ifNil: [ 0.0 ] ifNotNil: [ :state | state angularVelocity ].
	^ (self dot: velocityB - velocityA with: direction)
		+ (leverB * angularB) - (leverA * angularA)
]

{ #category : 'private - solving' }
CFPhysicsSoftStepSolver >> applyPrismaticJointImpulse: impulse direction: direction leverA: leverA leverB: leverB constraint: constraint [
	| vector stateA stateB |
	vector := direction * impulse.
	stateA := constraint bodyStateA.
	stateA ifNotNil: [
		stateA linearVelocity: stateA linearVelocity - (vector * stateA inverseMass).
		stateA angularVelocity: stateA angularVelocity - (impulse * leverA * stateA inverseInertia) ].
	stateB := constraint bodyStateB.
	stateB ifNotNil: [
		stateB linearVelocity: stateB linearVelocity + (vector * stateB inverseMass).
		stateB angularVelocity: stateB angularVelocity + (impulse * leverB * stateB inverseInertia) ]
]

{ #category : 'private - solving' }
CFPhysicsSoftStepSolver >> warmStartPrismaticJointConstraint: constraint [
	| axis normal axialImpulse perpendicularLeverA perpendicularLeverB axialLeverA axialLeverB |
	axis := self prismaticJointAxisFor: constraint.
	normal := axis y negated @ axis x.
	perpendicularLeverA := self prismaticJointLeverAFor: constraint direction: normal.
	perpendicularLeverB := self prismaticJointLeverBFor: constraint direction: normal.
	axialLeverA := self prismaticJointLeverAFor: constraint direction: axis.
	axialLeverB := self prismaticJointLeverBFor: constraint direction: axis.
	axialImpulse := constraint springImpulse + constraint lowerLimitImpulse
		- constraint upperLimitImpulse + constraint motorImpulse.
	self applyPrismaticJointImpulse: constraint perpendicularImpulse direction: normal
		leverA: perpendicularLeverA leverB: perpendicularLeverB constraint: constraint.
	self applyPrismaticJointImpulse: axialImpulse direction: axis
		leverA: axialLeverA leverB: axialLeverB constraint: constraint.
	self applyWeldJointAngularImpulse: constraint angularImpulse constraint: constraint
]

{ #category : 'private - solving' }
CFPhysicsSoftStepSolver >> solvePrismaticJointConstraint: constraint biasEnabled: biasEnabled [
	| axis normal leverA leverB relativeVelocity separation bias massCoefficient impulseCoefficient increment angularRelativeVelocity angularSeparation angularBias angularIncrement |
	axis := self prismaticJointAxisFor: constraint.
	normal := axis y negated @ axis x.
	leverA := self prismaticJointLeverAFor: constraint direction: normal.
	leverB := self prismaticJointLeverBFor: constraint direction: normal.
	relativeVelocity := self prismaticJointVelocityFor: constraint direction: normal leverA: leverA leverB: leverB.
	separation := self dot: (self prismaticJointSeparationFor: constraint) with: normal.
	bias := biasEnabled ifTrue: [ step biasRate * separation ] ifFalse: [ 0.0 ].
	massCoefficient := biasEnabled ifTrue: [ step massCoefficient ] ifFalse: [ 1.0 ].
	impulseCoefficient := biasEnabled ifTrue: [ step impulseCoefficient ] ifFalse: [ 0.0 ].
	increment := (massCoefficient * constraint perpendicularMass * (relativeVelocity + bias)) negated
		- (impulseCoefficient * constraint perpendicularImpulse).
	constraint perpendicularImpulse: constraint perpendicularImpulse + increment.
	self applyPrismaticJointImpulse: increment direction: normal leverA: leverA leverB: leverB constraint: constraint.
	angularRelativeVelocity := self weldJointRelativeAngularVelocity: constraint.
	angularSeparation := constraint baseAngle
		+ (self distanceJointDeltaRotationFor: constraint bodyStateB)
		- (self distanceJointDeltaRotationFor: constraint bodyStateA).
	angularBias := biasEnabled ifTrue: [ step biasRate * angularSeparation ] ifFalse: [ 0.0 ].
	angularIncrement := (massCoefficient * constraint angularMass * (angularRelativeVelocity + angularBias)) negated
		- (impulseCoefficient * constraint angularImpulse).
	constraint angularImpulse: constraint angularImpulse + angularIncrement.
	self applyWeldJointAngularImpulse: angularIncrement constraint: constraint.
	self solvePrismaticJointSpring: constraint.
	self solvePrismaticJointMotor: constraint.
	self solvePrismaticJointLimits: constraint biasEnabled: biasEnabled
]

{ #category : 'private - solving' }
CFPhysicsSoftStepSolver >> solvePrismaticJointSpring: constraint [
	| axis leverA leverB separation velocity increment |
	constraint springEnabled ifFalse: [ ^ self ].
	axis := self prismaticJointAxisFor: constraint.
	leverA := self prismaticJointLeverAFor: constraint direction: axis.
	leverB := self prismaticJointLeverBFor: constraint direction: axis.
	separation := (self prismaticJointTranslationFor: constraint) - constraint joint targetTranslation.
	velocity := self prismaticJointVelocityFor: constraint direction: axis leverA: leverA leverB: leverB.
	increment := (constraint springMassCoefficient * constraint axialMass
		* (velocity + (constraint springBiasRate * separation))) negated
		- (constraint springImpulseCoefficient * constraint springImpulse).
	constraint springImpulse: constraint springImpulse + increment.
	self applyPrismaticJointImpulse: increment direction: axis leverA: leverA leverB: leverB constraint: constraint
]

{ #category : 'private - solving' }
CFPhysicsSoftStepSolver >> solvePrismaticJointMotor: constraint [
	| axis leverA leverB velocity increment oldImpulse newImpulse |
	constraint motorEnabled ifFalse: [ ^ self ].
	axis := self prismaticJointAxisFor: constraint.
	leverA := self prismaticJointLeverAFor: constraint direction: axis.
	leverB := self prismaticJointLeverBFor: constraint direction: axis.
	velocity := self prismaticJointVelocityFor: constraint direction: axis leverA: leverA leverB: leverB.
	increment := constraint axialMass * (constraint motorSpeed - velocity).
	oldImpulse := constraint motorImpulse.
	newImpulse := ((oldImpulse + increment) max: constraint maximumMotorImpulse negated)
		min: constraint maximumMotorImpulse.
	constraint motorImpulse: newImpulse.
	self applyPrismaticJointImpulse: newImpulse - oldImpulse direction: axis leverA: leverA leverB: leverB constraint: constraint
]

{ #category : 'private - solving' }
CFPhysicsSoftStepSolver >> solvePrismaticJointLimits: constraint biasEnabled: biasEnabled [
	| translation axis leverA leverB velocity separation bias massCoefficient impulseCoefficient increment oldImpulse newImpulse |
	constraint limitsEnabled ifFalse: [ ^ self ].
	translation := self prismaticJointTranslationFor: constraint.
	axis := self prismaticJointAxisFor: constraint.
	leverA := self prismaticJointLeverAFor: constraint direction: axis.
	leverB := self prismaticJointLeverBFor: constraint direction: axis.
	velocity := self prismaticJointVelocityFor: constraint direction: axis leverA: leverA leverB: leverB.
	separation := translation - constraint lowerTranslation.
	bias := (biasEnabled and: [ separation < 0.0 ]) ifTrue: [ step biasRate * separation ] ifFalse: [ 0.0 ].
	massCoefficient := biasEnabled ifTrue: [ step massCoefficient ] ifFalse: [ 1.0 ].
	impulseCoefficient := biasEnabled ifTrue: [ step impulseCoefficient ] ifFalse: [ 0.0 ].
	increment := (massCoefficient * constraint axialMass * (velocity + bias)) negated
		- (impulseCoefficient * constraint lowerLimitImpulse).
	oldImpulse := constraint lowerLimitImpulse.
	newImpulse := (oldImpulse + increment) max: 0.0.
	constraint lowerLimitImpulse: newImpulse.
	self applyPrismaticJointImpulse: newImpulse - oldImpulse direction: axis leverA: leverA leverB: leverB constraint: constraint.
	separation := constraint upperTranslation - translation.
	bias := (biasEnabled and: [ separation < 0.0 ]) ifTrue: [ step biasRate * separation ] ifFalse: [ 0.0 ].
	increment := (massCoefficient * constraint axialMass * (velocity negated + bias)) negated
		- (impulseCoefficient * constraint upperLimitImpulse).
	oldImpulse := constraint upperLimitImpulse.
	newImpulse := (oldImpulse + increment) max: 0.0.
	constraint upperLimitImpulse: newImpulse.
	self applyPrismaticJointImpulse: newImpulse - oldImpulse direction: axis negated leverA: leverA negated leverB: leverB negated constraint: constraint
]

{ #category : 'private - solving' }
CFPhysicsSoftStepSolver >> solveRevoluteJointConstraint: constraint biasEnabled: biasEnabled [
	| relativeVelocity separation bias massCoefficient impulseCoefficient increment |
	relativeVelocity := self revoluteJointRelativeVelocity: constraint.
	separation := constraint baseSeparation
		+ (self distanceJointDeltaPositionFor: constraint bodyStateB)
		- (self distanceJointDeltaPositionFor: constraint bodyStateA)
		+ ((self rotated: constraint anchorB by: (self distanceJointDeltaRotationFor: constraint bodyStateB)) - constraint anchorB)
		- ((self rotated: constraint anchorA by: (self distanceJointDeltaRotationFor: constraint bodyStateA)) - constraint anchorA).
	bias := biasEnabled ifTrue: [ separation * step biasRate ] ifFalse: [ 0 @ 0 ].
	massCoefficient := biasEnabled ifTrue: [ step massCoefficient ] ifFalse: [ 1.0 ].
	impulseCoefficient := biasEnabled ifTrue: [ step impulseCoefficient ] ifFalse: [ 0.0 ].
	increment := (self
		revoluteJointImpulseFor: (relativeVelocity + bias) * massCoefficient
		constraint: constraint) - (constraint impulse * impulseCoefficient).
	constraint impulse: constraint impulse + increment.
	self applyRevoluteJointImpulse: increment constraint: constraint.
	self solveRevoluteJointMotor: constraint.
	self solveRevoluteJointLimit: constraint biasEnabled: biasEnabled
]

{ #category : 'private - solving' }
CFPhysicsSoftStepSolver >> warmStartRevoluteJointMotor: constraint [
	(self isMotorJointConstraint: constraint) ifTrue: [
		self applyWeldJointAngularImpulse: constraint motorImpulse constraint: constraint ]
]

{ #category : 'private - solving' }
CFPhysicsSoftStepSolver >> solveRevoluteJointMotor: constraint [
	| relativeVelocity increment oldImpulse newImpulse |
	(self isMotorJointConstraint: constraint) ifFalse: [ ^ self ].
	relativeVelocity := self weldJointRelativeAngularVelocity: constraint.
	increment := constraint motorMass * (constraint motorSpeed - relativeVelocity).
	oldImpulse := constraint motorImpulse.
	newImpulse := ((oldImpulse + increment) max: constraint maximumMotorImpulse negated)
		min: constraint maximumMotorImpulse.
	constraint motorImpulse: newImpulse.
	self applyWeldJointAngularImpulse: newImpulse - oldImpulse constraint: constraint
]

{ #category : 'private - solving' }
CFPhysicsSoftStepSolver >> solveRevoluteJointLimit: constraint biasEnabled: biasEnabled [
	| angle relativeVelocity separation bias increment oldImpulse newImpulse |
	(self isLimitedRevoluteJointConstraint: constraint) ifFalse: [ ^ self ].
	angle := constraint limitBaseAngle
		+ (self distanceJointDeltaRotationFor: constraint bodyStateB)
		- (self distanceJointDeltaRotationFor: constraint bodyStateA).
	angle < constraint lowerAngle ifTrue: [
		separation := angle - constraint lowerAngle.
		relativeVelocity := self weldJointRelativeAngularVelocity: constraint.
		bias := biasEnabled ifTrue: [ step biasRate * separation ] ifFalse: [ 0.0 ].
		increment := constraint limitMass * (relativeVelocity + bias) negated.
		oldImpulse := constraint limitImpulse max: 0.0.
		newImpulse := (oldImpulse + increment) max: 0.0.
		constraint limitImpulse: newImpulse.
		^ self applyWeldJointAngularImpulse: newImpulse - oldImpulse constraint: constraint ].
	angle > constraint upperAngle ifTrue: [
		separation := angle - constraint upperAngle.
		relativeVelocity := self weldJointRelativeAngularVelocity: constraint.
		bias := biasEnabled ifTrue: [ step biasRate * separation ] ifFalse: [ 0.0 ].
		increment := constraint limitMass * (relativeVelocity + bias) negated.
		oldImpulse := constraint limitImpulse min: 0.0.
		newImpulse := (oldImpulse + increment) min: 0.0.
		constraint limitImpulse: newImpulse.
		^ self applyWeldJointAngularImpulse: newImpulse - oldImpulse constraint: constraint ].
	constraint limitImpulse: 0.0
]

{ #category : 'private - solving' }
CFPhysicsSoftStepSolver >> solveWeldJointConstraint: constraint biasEnabled: biasEnabled [
	| relativeVelocity separation bias massCoefficient impulseCoefficient increment |
	relativeVelocity := self weldJointRelativeAngularVelocity: constraint.
	separation := constraint baseAngle
		+ (self distanceJointDeltaRotationFor: constraint bodyStateB)
		- (self distanceJointDeltaRotationFor: constraint bodyStateA).
	bias := biasEnabled ifTrue: [ step biasRate * separation ] ifFalse: [ 0.0 ].
	massCoefficient := biasEnabled ifTrue: [ step massCoefficient ] ifFalse: [ 1.0 ].
	impulseCoefficient := biasEnabled ifTrue: [ step impulseCoefficient ] ifFalse: [ 0.0 ].
	increment := (massCoefficient * constraint angularMass * (relativeVelocity + bias)) negated
		- (impulseCoefficient * constraint angularImpulse).
	constraint angularImpulse: constraint angularImpulse + increment.
	self applyWeldJointAngularImpulse: increment constraint: constraint
]

{ #category : 'private - solving' }
CFPhysicsSoftStepSolver >> solveNormalAt: point constraint: constraint biasEnabled: biasEnabled [
	| relativeVelocity normalVelocity separation bias increment oldImpulse newImpulse |
	relativeVelocity := self relativeVelocityAt: point constraint: constraint.
	normalVelocity := self dot: relativeVelocity with: constraint normal.
	separation := self contactSeparationAt: point constraint: constraint.
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
	restitutionCandidatePointCount := 0.
	self contactConstraints do: [ :constraint |
		constraint points do: [ :point |
			point relativeNormalVelocity < threshold negated ifTrue: [
				| normalVelocity increment oldImpulse newImpulse |
				restitutionCandidatePointCount := restitutionCandidatePointCount + 1.
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
			state linearVelocity - (impulse * state inverseMass).
		state angularVelocity:
			state angularVelocity - ((self cross: anchorA with: impulse) * state inverseInertia) ].
	constraint bodyStateB ifNotNil: [ :state |
		state linearVelocity:
			state linearVelocity + (impulse * state inverseMass).
		state angularVelocity:
			state angularVelocity + ((self cross: anchorB with: impulse) * state inverseInertia) ]
]

{ #category : 'private - solving' }
CFPhysicsSoftStepSolver >> applyRevoluteJointImpulse: impulse constraint: constraint [
	| anchorA anchorB |
	anchorA := self rotated: constraint anchorA by: (self distanceJointDeltaRotationFor: constraint bodyStateA).
	anchorB := self rotated: constraint anchorB by: (self distanceJointDeltaRotationFor: constraint bodyStateB).
	constraint bodyStateA ifNotNil: [ :state |
		state linearVelocity:
			state linearVelocity - (impulse * state inverseMass).
		state angularVelocity:
			state angularVelocity - ((self cross: anchorA with: impulse) * state inverseInertia) ].
	constraint bodyStateB ifNotNil: [ :state |
		state linearVelocity:
			state linearVelocity + (impulse * state inverseMass).
		state angularVelocity:
			state angularVelocity + ((self cross: anchorB with: impulse) * state inverseInertia) ]
]

{ #category : 'private - solving' }
CFPhysicsSoftStepSolver >> applyWeldJointAngularImpulse: impulse constraint: constraint [
	constraint bodyStateA ifNotNil: [ :state |
		state angularVelocity:
			state angularVelocity - (impulse * state inverseInertia) ].
	constraint bodyStateB ifNotNil: [ :state |
		state angularVelocity:
			state angularVelocity + (impulse * state inverseInertia) ]
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
CFPhysicsSoftStepSolver >> weldJointRelativeAngularVelocity: constraint [
	^ (constraint bodyStateB ifNil: [ 0.0 ] ifNotNil: [ :state | state angularVelocity ])
		- (constraint bodyStateA ifNil: [ 0.0 ] ifNotNil: [ :state | state angularVelocity ])
]

{ #category : 'private - testing' }
CFPhysicsSoftStepSolver >> isMotorJointConstraint: constraint [
	^ constraint joint class == CFPhysicsRevoluteJoint
		and: [ constraint motorEnabled and: [ constraint maximumMotorImpulse > 0.0 ] ]
]

{ #category : 'private - testing' }
CFPhysicsSoftStepSolver >> isLimitedRevoluteJointConstraint: constraint [
	^ constraint joint class == CFPhysicsRevoluteJoint
		and: [ constraint limitsEnabled and: [ constraint limitMass > 0.0 ] ]
]

{ #category : 'private - testing' }
CFPhysicsSoftStepSolver >> isLimitedPrismaticJointConstraint: constraint [
	^ constraint joint class == CFPhysicsPrismaticJoint
		and: [ constraint limitsEnabled and: [ constraint translationMass > 0.0 ] ]
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
	^ contactConstraints
]

{ #category : 'private - accessing' }
CFPhysicsSoftStepSolver >> distanceJointConstraints [
	^ constraints select: [ :constraint | constraint isKindOf: CFPhysicsPreparedDistanceJoint ]
]

{ #category : 'private - accessing' }
CFPhysicsSoftStepSolver >> prismaticJointConstraints [
	^ constraints select: [ :constraint | constraint isKindOf: CFPhysicsPreparedPrismaticJoint ]
]

{ #category : 'private - accessing' }
CFPhysicsSoftStepSolver >> revoluteJointConstraints [
	^ constraints select: [ :constraint | constraint isKindOf: CFPhysicsPreparedRevoluteJoint ]
]

{ #category : 'private - accessing' }
CFPhysicsSoftStepSolver >> weldJointConstraints [
	^ constraints select: [ :constraint | constraint isKindOf: CFPhysicsPreparedWeldJoint ]
]

{ #category : 'private - accessing' }
CFPhysicsSoftStepSolver >> orderedJointConstraints [
	^ orderedJointConstraints
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
CFPhysicsSoftStepSolver >> contactSeparationAt: point constraint: constraint [
	^ point baseSeparation
		+ (self dot: constraint bodyStateB deltaPosition - constraint bodyStateA deltaPosition with: constraint normal)
		+ (self dot: (self rotated: point anchorB by: constraint bodyStateB deltaRotation) - point anchorB with: constraint normal)
		- (self dot: (self rotated: point anchorA by: constraint bodyStateA deltaRotation) - point anchorA with: constraint normal)
]

{ #category : 'private - solving' }
CFPhysicsSoftStepSolver >> applyImpulse: impulse at: point constraint: constraint [
	| anchorA anchorB |
	anchorA := self rotated: point anchorA by: constraint bodyStateA deltaRotation.
	anchorB := self rotated: point anchorB by: constraint bodyStateB deltaRotation.
	constraint bodyStateA linearVelocity:
		constraint bodyStateA linearVelocity - (impulse * constraint bodyStateA inverseMass).
	constraint bodyStateA angularVelocity:
		constraint bodyStateA angularVelocity
			- ((self cross: anchorA with: impulse) * constraint bodyStateA inverseInertia).
	constraint bodyStateB linearVelocity:
		constraint bodyStateB linearVelocity + (impulse * constraint bodyStateB inverseMass).
	constraint bodyStateB angularVelocity:
		constraint bodyStateB angularVelocity
			+ ((self cross: anchorB with: impulse) * constraint bodyStateB inverseInertia)
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
CFPhysicsSoftStepSolver >> bodyStates: anOrderedCollection [ bodyStates := anOrderedCollection ]
{ #category : 'accessing' }
CFPhysicsSoftStepSolver >> constraints: aCollection [
	constraints := aCollection asArray.
	contactConstraints := constraints select: [ :constraint |
		constraint isKindOf: CFPhysicsPreparedConstraint ].
	orderedJointConstraints := ((constraints select: [ :constraint |
		constraint isKindOf: CFPhysicsPreparedMotorJoint ]),
		(constraints select: [ :constraint |
			constraint isKindOf: CFPhysicsPreparedMouseJoint ]),
		(constraints select: [ :constraint |
			constraint isKindOf: CFPhysicsPreparedDistanceJoint ]),
		(constraints select: [ :constraint |
			constraint isKindOf: CFPhysicsPreparedRevoluteJoint ]),
		(constraints select: [ :constraint |
			constraint isKindOf: CFPhysicsPreparedPrismaticJoint ]))
		asArray sorted: [ :first :second |
			first joint orderingKey = second joint orderingKey
				ifTrue: [ first joint class name asString < second joint class name asString ]
				ifFalse: [ first joint orderingKey < second joint orderingKey ] ].
	self measurePreparedWork
]

{ #category : 'private - telemetry' }
CFPhysicsSoftStepSolver >> measurePreparedWork [
	contactPointCount := contactConstraints
		inject: 0
		into: [ :total :constraint | total + constraint points size ].
	warmStartedContactPointCount := contactConstraints
		inject: 0
		into: [ :total :constraint |
			total + (constraint points count: [ :point |
				point normalImpulse ~= 0.0 or: [ point tangentImpulse ~= 0.0 ] ]) ].
	motorJointConstraintCount := orderedJointConstraints count: [ :constraint |
		constraint isKindOf: CFPhysicsPreparedMotorJoint ].
	mouseJointConstraintCount := orderedJointConstraints count: [ :constraint |
		constraint isKindOf: CFPhysicsPreparedMouseJoint ].
	distanceJointConstraintCount := orderedJointConstraints count: [ :constraint |
		constraint isKindOf: CFPhysicsPreparedDistanceJoint ].
	prismaticJointConstraintCount := orderedJointConstraints count: [ :constraint |
		constraint isKindOf: CFPhysicsPreparedPrismaticJoint ].
	weldJointConstraintCount := orderedJointConstraints count: [ :constraint |
		constraint isKindOf: CFPhysicsPreparedWeldJoint ].
	revoluteJointConstraintCount := orderedJointConstraints count: [ :constraint |
		(constraint isKindOf: CFPhysicsPreparedRevoluteJoint)
			and: [ (constraint isKindOf: CFPhysicsPreparedWeldJoint) not ] ]
]


{ #category : 'accessing - telemetry' }
CFPhysicsSoftStepSolver >> contactConstraintCount [ ^ contactConstraints size ]
{ #category : 'accessing - telemetry' }
CFPhysicsSoftStepSolver >> contactPointCount [ ^ contactPointCount ]
{ #category : 'accessing - telemetry' }
CFPhysicsSoftStepSolver >> warmStartedContactPointCount [ ^ warmStartedContactPointCount ]
{ #category : 'accessing - telemetry' }
CFPhysicsSoftStepSolver >> restitutionCandidatePointCount [ ^ restitutionCandidatePointCount ]
{ #category : 'accessing - telemetry' }
CFPhysicsSoftStepSolver >> jointConstraintCount [ ^ orderedJointConstraints size ]
{ #category : 'accessing - telemetry' }
CFPhysicsSoftStepSolver >> distanceJointConstraintCount [ ^ distanceJointConstraintCount ]
{ #category : 'accessing - telemetry' }
CFPhysicsSoftStepSolver >> prismaticJointConstraintCount [ ^ prismaticJointConstraintCount ]
{ #category : 'accessing - telemetry' }
CFPhysicsSoftStepSolver >> revoluteJointConstraintCount [ ^ revoluteJointConstraintCount ]
{ #category : 'accessing - telemetry' }
CFPhysicsSoftStepSolver >> weldJointConstraintCount [ ^ weldJointConstraintCount ]

{ #category : 'accessing - telemetry' }
CFPhysicsSoftStepSolver >> mouseJointConstraintCount [ ^ mouseJointConstraintCount ]

{ #category : 'accessing - telemetry' }
CFPhysicsSoftStepSolver >> motorJointConstraintCount [ ^ motorJointConstraintCount ]


{ #category : 'private - solving' }
CFPhysicsSoftStepSolver >> warmStartMotorJointConstraint: constraint [
	| stateA stateB anchorA anchorB linearImpulse angularImpulse |
	stateA := constraint bodyStateA.
	stateB := constraint bodyStateB.
	anchorA := self rotate: constraint anchorA by: stateA deltaRotation.
	anchorB := self rotate: constraint anchorB by: stateB deltaRotation.
	linearImpulse := constraint linearImpulse.
	angularImpulse := constraint angularImpulse.
	stateA linearVelocity: stateA linearVelocity - (linearImpulse * stateA inverseMass).
	stateA angularVelocity: stateA angularVelocity
		- (((self cross: anchorA with: linearImpulse) + angularImpulse) * stateA inverseInertia).
	stateB linearVelocity: stateB linearVelocity + (linearImpulse * stateB inverseMass).
	stateB angularVelocity: stateB angularVelocity
		+ (((self cross: anchorB with: linearImpulse) + angularImpulse) * stateB inverseInertia)
]

{ #category : 'private - solving' }
CFPhysicsSoftStepSolver >> solveMotorJointConstraint: constraint biasEnabled: biasEnabled [
	| stateA stateB angularSeparation angularBias increment oldImpulse newImpulse anchorA anchorB displacement linearSeparation linearBias velocityA velocityB relativeVelocity massResult vectorIncrement oldVector newVector magnitude |
	stateA := constraint bodyStateA.
	stateB := constraint bodyStateB.
	angularSeparation := constraint baseAngularSeparation + stateB deltaRotation - stateA deltaRotation.
	angularBias := (1.0 / step substepTime) * constraint joint correctionFactor * angularSeparation.
	increment := (constraint angularMass
		* ((stateB angularVelocity - stateA angularVelocity) + angularBias)) negated.
	oldImpulse := constraint angularImpulse.
	newImpulse := (oldImpulse + increment max: constraint maximumAngularImpulse negated)
		min: constraint maximumAngularImpulse.
	constraint angularImpulse: newImpulse.
	increment := newImpulse - oldImpulse.
	stateA angularVelocity: stateA angularVelocity - (increment * stateA inverseInertia).
	stateB angularVelocity: stateB angularVelocity + (increment * stateB inverseInertia).

	anchorA := self rotate: constraint anchorA by: stateA deltaRotation.
	anchorB := self rotate: constraint anchorB by: stateB deltaRotation.
	displacement := stateB deltaPosition - stateA deltaPosition + anchorB - anchorA.
	linearSeparation := constraint baseLinearSeparation + displacement.
	linearBias := linearSeparation * ((1.0 / step substepTime) * constraint joint correctionFactor).
	velocityA := stateA linearVelocity + (self crossScalar: stateA angularVelocity withVector: anchorA).
	velocityB := stateB linearVelocity + (self crossScalar: stateB angularVelocity withVector: anchorB).
	relativeVelocity := velocityB - velocityA.
	massResult := self
		multiplyXX: constraint effectiveMassXX
		xy: constraint effectiveMassXY
		yy: constraint effectiveMassYY
		by: relativeVelocity + linearBias.
	vectorIncrement := massResult negated.
	oldVector := constraint linearImpulse.
	newVector := oldVector + vectorIncrement.
	magnitude := newVector r.
	(magnitude > constraint maximumLinearImpulse and: [ magnitude > 0.0 ]) ifTrue: [
		newVector := newVector * (constraint maximumLinearImpulse / magnitude) ].
	constraint linearImpulse: newVector.
	vectorIncrement := newVector - oldVector.
	stateA linearVelocity: stateA linearVelocity - (vectorIncrement * stateA inverseMass).
	stateA angularVelocity: stateA angularVelocity
		- ((self cross: anchorA with: vectorIncrement) * stateA inverseInertia).
	stateB linearVelocity: stateB linearVelocity + (vectorIncrement * stateB inverseMass).
	stateB angularVelocity: stateB angularVelocity
		+ ((self cross: anchorB with: vectorIncrement) * stateB inverseInertia)
]



{ #category : 'private - geometry' }
CFPhysicsSoftStepSolver >> rotate: aPoint by: anAngle [
	| cosine sine |
	cosine := anAngle cos.
	sine := anAngle sin.
	^ ((aPoint x * cosine) - (aPoint y * sine))
		@ ((aPoint x * sine) + (aPoint y * cosine))
]

{ #category : 'private - geometry' }
CFPhysicsSoftStepSolver >> crossScalar: aScalar withVector: aPoint [
	^ (aScalar * aPoint y negated) @ (aScalar * aPoint x)
]

{ #category : 'private - geometry' }
CFPhysicsSoftStepSolver >> multiplyXX: xx xy: xy yy: yy by: aPoint [
	^ ((xx * aPoint x) + (xy * aPoint y))
		@ ((xy * aPoint x) + (yy * aPoint y))
]
