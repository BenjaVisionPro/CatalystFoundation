"I prepare Box2D 3.1.1 wheel joints for one solver step."
Class { #name : 'CFPhysicsWheelJointConstraintBuilder', #superclass : 'Object', #category : 'BVC-Physics-Pipeline', #package : 'BVC-Physics-Pipeline' }

{ #category : 'building' }
CFPhysicsWheelJointConstraintBuilder >> constraintsFrom: joints bodyStates: bodyStates step: step [
	^ (joints select: [ :joint | joint class == CFPhysicsWheelJoint and: [ joint isActive ] ]) collect: [ :joint |
		self constraintFrom: joint bodyStates: bodyStates step: step ]
]

{ #category : 'private - building' }
CFPhysicsWheelJointConstraintBuilder >> constraintFrom: joint bodyStates: bodyStates step: step [
	| stateA stateB originA originB anchorA anchorB displacement axis normal perpendicularLeverA perpendicularLeverB axialLeverA axialLeverB inversePerpendicularMass inverseAxialMass inverseMotorMass omega a1 a2 a3 |
	stateA := joint bodyA ifNil: [ nil ] ifNotNil: [ :body | bodyStates at: body ].
	stateB := joint bodyB ifNil: [ nil ] ifNotNil: [ :body | bodyStates at: body ].
	originA := self originForState: stateA.
	originB := self originForState: stateB.
	anchorA := joint endpointPair worldPointA - originA.
	anchorB := joint endpointPair worldPointB - originB.
	displacement := (originB + anchorB) - (originA + anchorA).
	axis := stateA ifNil: [ joint localAxisA ] ifNotNil: [ stateA worldVectorForBodyLocalVector: joint localAxisA ].
	normal := axis y negated @ axis x.
	perpendicularLeverA := self cross: displacement + anchorA with: normal.
	perpendicularLeverB := self cross: anchorB with: normal.
	inversePerpendicularMass := (self inverseMassForState: stateA cross: perpendicularLeverA)
		+ (self inverseMassForState: stateB cross: perpendicularLeverB).
	axialLeverA := self cross: displacement + anchorA with: axis.
	axialLeverB := self cross: anchorB with: axis.
	inverseAxialMass := (self inverseMassForState: stateA cross: axialLeverA)
		+ (self inverseMassForState: stateB cross: axialLeverB).
	inverseMotorMass := (self inverseInertiaForState: stateA) + (self inverseInertiaForState: stateB).
	omega := 2.0 * Float pi * joint hertz.
	a1 := (2.0 * joint dampingRatio) + (omega * step substepTime).
	a2 := step substepTime * omega * a1.
	a3 := 1.0 / (1.0 + a2).
	^ CFPhysicsPreparedWheelJoint new
		joint: joint; bodyStateA: stateA; bodyStateB: stateB;
		anchorA: anchorA; anchorB: anchorB; axis: axis; normal: normal;
		basePerpendicularSeparation: (self dot: displacement with: normal);
		perpendicularMass: (self reciprocalOrZero: inversePerpendicularMass);
		perpendicularImpulse: joint perpendicularImpulse * step warmStartRatio;
		baseTranslation: (self dot: displacement with: axis);
		axialMass: (self reciprocalOrZero: inverseAxialMass);
		springEnabled: joint springEnabled;
		springBiasRate: (a1 = 0.0 ifTrue: [ 0.0 ] ifFalse: [ omega / a1 ]);
		springMassCoefficient: a2 * a3; springImpulseCoefficient: a3;
		springImpulse: joint springImpulse * step warmStartRatio;
		limitsEnabled: joint limitsEnabled; lowerTranslation: joint lowerTranslation; upperTranslation: joint upperTranslation;
		lowerLimitImpulse: joint lowerLimitImpulse * step warmStartRatio;
		upperLimitImpulse: joint upperLimitImpulse * step warmStartRatio;
		motorEnabled: joint motorEnabled; motorSpeed: joint motorSpeed;
		motorMass: (self reciprocalOrZero: inverseMotorMass);
		maximumMotorImpulse: joint maximumMotorTorque * step substepTime;
		motorImpulse: joint motorImpulse * step warmStartRatio;
		yourself
]

{ #category : 'private - mathematics' }
CFPhysicsWheelJointConstraintBuilder >> cross: first with: second [ ^ (first x * second y) - (first y * second x) ]
{ #category : 'private - mathematics' }
CFPhysicsWheelJointConstraintBuilder >> dot: first with: second [ ^ (first x * second x) + (first y * second y) ]
{ #category : 'private - building' }
CFPhysicsWheelJointConstraintBuilder >> originForState: state [ ^ state ifNil: [ 0 @ 0 ] ifNotNil: [ state currentBodyOrigin ] ]
{ #category : 'private - building' }
CFPhysicsWheelJointConstraintBuilder >> inverseMassForState: state cross: cross [ ^ state ifNil: [ 0.0 ] ifNotNil: [ state inverseMass + (state inverseInertia * cross squared) ] ]
{ #category : 'private - building' }
CFPhysicsWheelJointConstraintBuilder >> inverseInertiaForState: state [ ^ state ifNil: [ 0.0 ] ifNotNil: [ state inverseInertia ] ]
{ #category : 'private - mathematics' }
CFPhysicsWheelJointConstraintBuilder >> reciprocalOrZero: value [ ^ value = 0.0 ifTrue: [ 0.0 ] ifFalse: [ 1.0 / value ] ]
