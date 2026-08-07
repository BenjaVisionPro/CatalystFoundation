"I prepare Box2D 3.1.1 prismatic joints for one solver step."
Class { #name : 'CFPhysicsPrismaticJointConstraintBuilder', #superclass : 'Object', #category : 'BVC-Physics-Pipeline', #package : 'BVC-Physics-Pipeline' }

{ #category : 'building' }
CFPhysicsPrismaticJointConstraintBuilder >> constraintsFrom: joints bodyStates: bodyStates step: step [
	^ (joints select: [ :joint | joint class == CFPhysicsPrismaticJoint and: [ joint isActive ] ]) collect: [ :joint |
		self constraintFrom: joint bodyStates: bodyStates step: step ]
]

{ #category : 'private - building' }
CFPhysicsPrismaticJointConstraintBuilder >> constraintFrom: joint bodyStates: bodyStates step: step [
	| stateA stateB originA originB anchorA anchorB displacement axis normal crossA crossB axisCrossA axisCrossB inversePerpendicularMass inverseAxialMass inverseAngularMass angleA angleB omega a1 a2 a3 |
	stateA := joint bodyA ifNil: [ nil ] ifNotNil: [ :body | bodyStates at: body ].
	stateB := joint bodyB ifNil: [ nil ] ifNotNil: [ :body | bodyStates at: body ].
	originA := self originForState: stateA. originB := self originForState: stateB.
	anchorA := joint endpointPair worldPointA - originA. anchorB := joint endpointPair worldPointB - originB.
	displacement := (originB + anchorB) - (originA + anchorA).
	axis := stateA ifNil: [ joint localAxisA ] ifNotNil: [ stateA worldVectorForBodyLocalVector: joint localAxisA ].
	normal := axis y negated @ axis x.
	crossA := self cross: displacement + anchorA with: normal. crossB := self cross: anchorB with: normal.
	inversePerpendicularMass := (self inverseMassForState: stateA cross: crossA) + (self inverseMassForState: stateB cross: crossB).
	axisCrossA := self cross: displacement + anchorA with: axis. axisCrossB := self cross: anchorB with: axis.
	inverseAxialMass := (self inverseMassForState: stateA cross: axisCrossA) + (self inverseMassForState: stateB cross: axisCrossB).
	inverseAngularMass := (self inverseInertiaForState: stateA) + (self inverseInertiaForState: stateB).
	angleA := stateA ifNil: [ 0.0 ] ifNotNil: [ stateA currentTransform rotation ].
	angleB := stateB ifNil: [ 0.0 ] ifNotNil: [ stateB currentTransform rotation ].
	omega := 2.0 * Float pi * joint hertz.
	a1 := (2.0 * joint dampingRatio) + (omega * step substepTime).
	a2 := step substepTime * omega * a1.
	a3 := 1.0 / (1.0 + a2).
	^ CFPhysicsPreparedPrismaticJoint new
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
		maximumMotorImpulse: (joint forceUnitsForNewtons: joint maximumMotorForce) * step substepTime;
		motorImpulse: joint motorImpulse * step warmStartRatio;
		baseAngle: angleB - angleA - joint referenceAngle;
		angularMass: (self reciprocalOrZero: inverseAngularMass);
		angularImpulse: joint angularImpulse * step warmStartRatio;
		yourself
]

{ #category : 'private - mathematics' }
CFPhysicsPrismaticJointConstraintBuilder >> cross: first with: second [ ^ (first x * second y) - (first y * second x) ]
{ #category : 'private - mathematics' }
CFPhysicsPrismaticJointConstraintBuilder >> dot: first with: second [ ^ (first x * second x) + (first y * second y) ]
{ #category : 'private - building' }
CFPhysicsPrismaticJointConstraintBuilder >> originForState: state [ ^ state ifNil: [ 0 @ 0 ] ifNotNil: [ state currentBodyOrigin ] ]
{ #category : 'private - building' }
CFPhysicsPrismaticJointConstraintBuilder >> inverseMassForState: state cross: cross [ ^ state ifNil: [ 0.0 ] ifNotNil: [ state inverseMass + (state inverseInertia * cross squared) ] ]
{ #category : 'private - building' }
CFPhysicsPrismaticJointConstraintBuilder >> inverseInertiaForState: state [ ^ state ifNil: [ 0.0 ] ifNotNil: [ state inverseInertia ] ]
{ #category : 'private - mathematics' }
CFPhysicsPrismaticJointConstraintBuilder >> reciprocalOrZero: value [ ^ value = 0.0 ifTrue: [ 0.0 ] ifFalse: [ 1.0 / value ] ]
