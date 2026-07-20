Class {
	#name : 'CFPhysicsFixedJointConstraintBuilder',
	#superclass : 'CFPhysicsRevoluteJointConstraintBuilder',
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'building' }
CFPhysicsFixedJointConstraintBuilder >> constraintsFrom: joints bodyStates: bodyStates warmStartRatio: warmStartRatio [
	^ (joints select: [ :joint |
		(joint isKindOf: CFPhysicsFixedJoint) and: [ joint isActive ] ]) collect: [ :joint |
			self constraintFrom: joint bodyStates: bodyStates warmStartRatio: warmStartRatio ]
]

{ #category : 'private - building' }
CFPhysicsFixedJointConstraintBuilder >> constraintFrom: joint bodyStates: bodyStates warmStartRatio: warmStartRatio [
	| positional stateA stateB inverseInertia angleA angleB inverseAngularMass |
	positional := super constraintFrom: joint bodyStates: bodyStates warmStartRatio: warmStartRatio.
	stateA := positional bodyStateA.
	stateB := positional bodyStateB.
	inverseInertia := (self inverseInertiaFor: joint firstBody)
		+ (self inverseInertiaFor: joint secondBody).
	inverseAngularMass := inverseInertia = 0.0
		ifTrue: [ 0.0 ]
		ifFalse: [ 1.0 / inverseInertia ].
	angleA := stateA ifNil: [ 0.0 ] ifNotNil: [ stateA currentTransform rotation ].
	angleB := stateB ifNil: [ 0.0 ] ifNotNil: [ stateB currentTransform rotation ].
	^ CFPhysicsPreparedFixedJoint new
		joint: joint;
		bodyStateA: positional bodyStateA;
		bodyStateB: positional bodyStateB;
		anchorA: positional anchorA;
		anchorB: positional anchorB;
		baseSeparation: positional baseSeparation;
		effectiveMassXX: positional effectiveMassXX;
		effectiveMassXY: positional effectiveMassXY;
		effectiveMassYY: positional effectiveMassYY;
		impulse: positional impulse;
		baseAngle: (angleB - angleA - joint referenceAngle);
		angularMass: inverseAngularMass;
		angularImpulse: joint accumulatedAngularImpulse * warmStartRatio;
		yourself
]
