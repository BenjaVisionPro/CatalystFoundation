"I prepare Box2D 3.1.1 motor joints for one solver step."
Class { #name : 'CFPhysicsMotorJointConstraintBuilder', #superclass : 'Object', #category : 'BVC-Physics-Pipeline', #package : 'BVC-Physics-Pipeline' }
{ #category : 'building' }
CFPhysicsMotorJointConstraintBuilder >> constraintsFrom: joints bodyStates: bodyStates step: step [
	^ (joints select: [ :joint | joint class == CFPhysicsMotorJoint and: [ joint isActive ] ]) collect: [ :joint |
		self constraintFrom: joint bodyStates: bodyStates step: step ]
]
{ #category : 'private - building' }
CFPhysicsMotorJointConstraintBuilder >> constraintFrom: joint bodyStates: bodyStates step: step [
	| stateA stateB inverseLinearMass inverseAngularMass worldOffset |
	stateA := bodyStates at: joint bodyA.
	stateB := bodyStates at: joint bodyB.
	inverseLinearMass := stateA inverseMass + stateB inverseMass.
	inverseAngularMass := stateA inverseInertia + stateB inverseInertia.
	worldOffset := joint bodyA worldVectorForBodyLocalVector: joint linearOffset.
	^ CFPhysicsPreparedMotorJoint new
		joint: joint; bodyStateA: stateA; bodyStateB: stateB;
		baseLinearSeparation: stateB currentBodyOrigin - stateA currentBodyOrigin - worldOffset;
		baseAngularSeparation: stateB currentTransform rotation - stateA currentTransform rotation - joint angularOffset;
		linearMass: (inverseLinearMass = 0.0 ifTrue: [ 0.0 ] ifFalse: [ 1.0 / inverseLinearMass ]);
		angularMass: (inverseAngularMass = 0.0 ifTrue: [ 0.0 ] ifFalse: [ 1.0 / inverseAngularMass ]);
		maximumLinearImpulse: step substepTime * joint maximumForce;
		maximumAngularImpulse: step substepTime * joint maximumTorque;
		linearImpulse: joint linearImpulse * step warmStartRatio;
		angularImpulse: joint angularImpulse * step warmStartRatio; yourself
]
