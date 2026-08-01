"
I solve prepared contacts and joints using the soft-step formulation. I warm-start accumulated impulses, iterates constraints and writes solved impulses back to their persistent owners.
"

Class {
	#name : 'CFPhysicsSoftStepSolver',
	#superclass : 'Object',
	#instVars : [ 'step', 'bodyStates', 'constraints', 'contactConstraints', 'orderedJointConstraints', 'contactPointCount', 'warmStartedContactPointCount', 'restitutionCandidatePointCount', 'distanceJointConstraintCount', 'prismaticJointConstraintCount', 'revoluteJointConstraintCount', 'weldJointConstraintCount' ],
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
	weldJointConstraintCount := 0
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
	(constraint isKindOf: CFPhysicsPreparedDistanceJoint) ifTrue: [
		^ self applyDistanceJointImpulse: constraint direction * constraint impulse constraint: constraint ].
	(constraint isKindOf: CFPhysicsPreparedPrismaticJoint) ifTrue: [
		self applyDistanceJointImpulse: constraint normal * constraint perpendicularImpulse constraint: constraint.
		self applyWeldJointAngularImpulse: constraint angularImpulse constraint: constraint. ].
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
CFPhysicsSoftStepSolver >> solveDistanceJointConstraint: constraint biasEnabled: biasEnabled [
	| relativeVelocity separation bias massCoefficient impulseCoefficient increment |
	relativeVelocity := self dot: (self distanceJointRelativeVelocity: constraint) with: constraint direction.
	separation := constraint baseSeparation
		+ (self dot: (self distanceJointDeltaPositionFor: constraint bodyStateB)
			- (self distanceJointDeltaPositionFor: constraint bodyStateA)
			with: constraint direction).
	separation := separation
		+ (self dot: (self rotated: constraint anchorB by: (self distanceJointDeltaRotationFor: constraint bodyStateB)) - constraint anchorB with: constraint direction)
		- (self dot: (self rotated: constraint anchorA by: (self distanceJointDeltaRotationFor: constraint bodyStateA)) - constraint anchorA with: constraint direction).
	bias := biasEnabled ifTrue: [ step biasRate * separation ] ifFalse: [ 0.0 ].
	massCoefficient := biasEnabled ifTrue: [ step massCoefficient ] ifFalse: [ 1.0 ].
	impulseCoefficient := biasEnabled ifTrue: [ step impulseCoefficient ] ifFalse: [ 0.0 ].
	increment := (massCoefficient * constraint effectiveMass * (relativeVelocity + bias)) negated
		- (impulseCoefficient * constraint impulse).
	constraint impulse: constraint impulse + increment.
	self applyDistanceJointImpulse: constraint direction * increment constraint: constraint
]

{ #category : 'private - solving' }
CFPhysicsSoftStepSolver >> solvePrismaticJointConstraint: constraint biasEnabled: biasEnabled [
	| relativeVelocity separation bias massCoefficient impulseCoefficient increment angularRelativeVelocity angularSeparation angularBias angularIncrement |
	relativeVelocity := self dot: (self distanceJointRelativeVelocity: constraint) with: constraint normal.
	separation := constraint basePerpendicularSeparation
		+ (self dot: (self distanceJointDeltaPositionFor: constraint bodyStateB)
			- (self distanceJointDeltaPositionFor: constraint bodyStateA)
			with: constraint normal).
	separation := separation
		+ (self dot: (self rotated: constraint anchorB by: (self distanceJointDeltaRotationFor: constraint bodyStateB)) - constraint anchorB with: constraint normal)
		- (self dot: (self rotated: constraint anchorA by: (self distanceJointDeltaRotationFor: constraint bodyStateA)) - constraint anchorA with: constraint normal).
	bias := biasEnabled ifTrue: [ step biasRate * separation ] ifFalse: [ 0.0 ].
	massCoefficient := biasEnabled ifTrue: [ step massCoefficient ] ifFalse: [ 1.0 ].
	impulseCoefficient := biasEnabled ifTrue: [ step impulseCoefficient ] ifFalse: [ 0.0 ].
	increment := (massCoefficient * constraint perpendicularMass * (relativeVelocity + bias)) negated
		- (impulseCoefficient * constraint perpendicularImpulse).
	constraint perpendicularImpulse: constraint perpendicularImpulse + increment.
	self applyDistanceJointImpulse: constraint normal * increment constraint: constraint.
	angularRelativeVelocity := self weldJointRelativeAngularVelocity: constraint.
	angularSeparation := constraint baseAngle
		+ (self distanceJointDeltaRotationFor: constraint bodyStateB)
		- (self distanceJointDeltaRotationFor: constraint bodyStateA).
	angularBias := biasEnabled ifTrue: [ step biasRate * angularSeparation ] ifFalse: [ 0.0 ].
	angularIncrement := (massCoefficient * constraint angularMass * (angularRelativeVelocity + angularBias)) negated
		- (impulseCoefficient * constraint angularImpulse).
	constraint angularImpulse: constraint angularImpulse + angularIncrement.
	self applyWeldJointAngularImpulse: angularIncrement constraint: constraint.
	self solvePrismaticJointLimit: constraint biasEnabled: biasEnabled
]

{ #category : 'private - solving' }
CFPhysicsSoftStepSolver >> solvePrismaticJointLimit: constraint biasEnabled: biasEnabled [
	| translation relativeVelocity requiredVelocity increment oldImpulse newImpulse |
	(self isLimitedPrismaticJointConstraint: constraint) ifFalse: [ ^ self ].
	translation := constraint baseTranslation
		+ (self dot: ((self distanceJointDeltaPositionFor: constraint bodyStateB)
			- (self distanceJointDeltaPositionFor: constraint bodyStateA)) negated with: constraint axis)
		+ (self dot: ((self rotated: constraint anchorA by: (self distanceJointDeltaRotationFor: constraint bodyStateA)) - constraint anchorA) with: constraint axis)
		- (self dot: ((self rotated: constraint anchorB by: (self distanceJointDeltaRotationFor: constraint bodyStateB)) - constraint anchorB) with: constraint axis).
	relativeVelocity := self dot: (self distanceJointRelativeVelocity: constraint) negated with: constraint axis.
	translation + (relativeVelocity * step substepTime) < constraint lowerTranslation ifTrue: [
		requiredVelocity := (constraint lowerTranslation - translation) / step substepTime.
		increment := constraint translationMass * (requiredVelocity - relativeVelocity).
		oldImpulse := constraint translationImpulse max: 0.0.
		newImpulse := (oldImpulse + increment) max: 0.0.
		constraint translationImpulse: newImpulse.
		^ self applyDistanceJointImpulse: (constraint axis * (newImpulse - oldImpulse)) negated constraint: constraint ].
	translation + (relativeVelocity * step substepTime) > constraint upperTranslation ifTrue: [
		requiredVelocity := (constraint upperTranslation - translation) / step substepTime.
		increment := constraint translationMass * (requiredVelocity - relativeVelocity).
		oldImpulse := constraint translationImpulse min: 0.0.
		newImpulse := (oldImpulse + increment) min: 0.0.
		constraint translationImpulse: newImpulse.
		^ self applyDistanceJointImpulse: (constraint axis * (newImpulse - oldImpulse)) negated constraint: constraint ].
	constraint translationImpulse: 0.0
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
