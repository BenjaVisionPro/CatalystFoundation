"I prepare Box2D 3.1.1 motor joints for one solver step."
Class { #name : 'CFPhysicsMotorJointConstraintBuilder', #superclass : 'Object', #category : 'BVC-Physics-Pipeline', #package : 'BVC-Physics-Pipeline' }

{ #category : 'building' }
CFPhysicsMotorJointConstraintBuilder >> constraintsFrom: joints bodyStates: bodyStates step: step [
	^ (joints select: [ :joint | joint class == CFPhysicsMotorJoint and: [ joint isActive ] ]) collect: [ :joint |
		self constraintFrom: joint bodyStates: bodyStates step: step ]
]

{ #category : 'private - building' }
CFPhysicsMotorJointConstraintBuilder >> constraintFrom: joint bodyStates: bodyStates step: step [
	| stateA stateB anchorA anchorB inverseMassA inverseMassB inverseInertiaA inverseInertiaB kxx kxy kyy determinant massXX massXY massYY inverseAngularMass |
	stateA := bodyStates at: joint bodyA.
	stateB := bodyStates at: joint bodyB.
	"Box2D 3.1.1 motor joints use each body's origin as the local anchor. Catalyst body origins are the solver centres, so both lever arms begin at zero. Keeping them explicit preserves the complete point-constraint solve."
	anchorA := 0 @ 0.
	anchorB := 0 @ 0.
	inverseMassA := stateA inverseMass.
	inverseMassB := stateB inverseMass.
	inverseInertiaA := stateA inverseInertia.
	inverseInertiaB := stateB inverseInertia.
	kxx := inverseMassA + inverseMassB
		+ (inverseInertiaA * anchorA y squared)
		+ (inverseInertiaB * anchorB y squared).
	kxy := (inverseInertiaA * anchorA x * anchorA y) negated
		- (inverseInertiaB * anchorB x * anchorB y).
	kyy := inverseMassA + inverseMassB
		+ (inverseInertiaA * anchorA x squared)
		+ (inverseInertiaB * anchorB x squared).
	determinant := (kxx * kyy) - (kxy * kxy).
	determinant = 0.0
		ifTrue: [ massXX := 0.0. massXY := 0.0. massYY := 0.0 ]
		ifFalse: [
			massXX := kyy / determinant.
			massXY := kxy negated / determinant.
			massYY := kxx / determinant ].
	inverseAngularMass := inverseInertiaA + inverseInertiaB.
	^ CFPhysicsPreparedMotorJoint new
		joint: joint;
		bodyStateA: stateA;
		bodyStateB: stateB;
		anchorA: anchorA;
		anchorB: anchorB;
		baseLinearSeparation: stateB currentBodyOrigin - stateA currentBodyOrigin - joint linearOffset;
		baseAngularSeparation: stateB currentTransform rotation - stateA currentTransform rotation - joint angularOffset;
		effectiveMassXX: massXX;
		effectiveMassXY: massXY;
		effectiveMassYY: massYY;
		angularMass: (inverseAngularMass = 0.0 ifTrue: [ 0.0 ] ifFalse: [ 1.0 / inverseAngularMass ]);
		maximumLinearImpulse: step substepTime * joint maximumForce;
		maximumAngularImpulse: step substepTime * joint maximumTorque;
		linearImpulse: joint linearImpulse * step warmStartRatio;
		angularImpulse: joint angularImpulse * step warmStartRatio;
		yourself
]
