Class {
	#name : 'CFPhysicsRevoluteJointConstraintBuilder',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'building' }
CFPhysicsRevoluteJointConstraintBuilder >> constraintsFrom: joints bodyStates: bodyStates warmStartRatio: warmStartRatio [
	^ (joints select: [ :joint |
		joint class == CFPhysicsRevoluteJoint and: [ joint isActive ] ]) collect: [ :joint |
			self constraintFrom: joint bodyStates: bodyStates warmStartRatio: warmStartRatio ]
]

{ #category : 'private - building' }
CFPhysicsRevoluteJointConstraintBuilder >> constraintFrom: joint bodyStates: bodyStates warmStartRatio: warmStartRatio [
	| stateA stateB centreA centreB anchorA anchorB baseSeparation inverseMassA inverseMassB inverseInertiaA inverseInertiaB kxx kxy kyy determinant massXX massXY massYY inverseAngularMass angleA angleB |
	stateA := joint firstBody ifNil: [ nil ] ifNotNil: [ :body | bodyStates at: body ].
	stateB := joint secondBody ifNil: [ nil ] ifNotNil: [ :body | bodyStates at: body ].
	centreA := self centreForState: stateA.
	centreB := self centreForState: stateB.
	anchorA := joint endpointPair worldPointA - centreA.
	anchorB := joint endpointPair worldPointB - centreB.
	baseSeparation := (centreB + anchorB) - (centreA + anchorA).
	inverseMassA := self inverseMassForState: stateA.
	inverseMassB := self inverseMassForState: stateB.
	inverseInertiaA := self inverseInertiaForState: stateA.
	inverseInertiaB := self inverseInertiaForState: stateB.
	angleA := stateA ifNil: [ 0.0 ] ifNotNil: [ stateA currentTransform rotation ].
	angleB := stateB ifNil: [ 0.0 ] ifNotNil: [ stateB currentTransform rotation ].
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
	^ CFPhysicsPreparedRevoluteJoint new
		joint: joint;
		bodyStateA: stateA;
		bodyStateB: stateB;
		anchorA: anchorA;
		anchorB: anchorB;
		baseSeparation: baseSeparation;
		effectiveMassXX: massXX;
		effectiveMassXY: massXY;
		effectiveMassYY: massYY;
		impulse: joint accumulatedImpulse * warmStartRatio;
		limitBaseAngle: angleB - angleA - joint referenceAngle;
		limitsEnabled: joint limitsEnabled;
		lowerAngle: joint lowerAngle;
		upperAngle: joint upperAngle;
		limitMass: (inverseAngularMass = 0.0 ifTrue: [ 0.0 ] ifFalse: [ 1.0 / inverseAngularMass ]);
		limitImpulse: 0.0;
		motorEnabled: joint motorEnabled;
		motorSpeed: joint motorSpeed;
		maximumMotorImpulse: joint maximumMotorImpulse;
		motorMass: (inverseAngularMass = 0.0 ifTrue: [ 0.0 ] ifFalse: [ 1.0 / inverseAngularMass ]);
		motorImpulse: joint motorImpulse * warmStartRatio;
		yourself
]

{ #category : 'private - building' }
CFPhysicsRevoluteJointConstraintBuilder >> centreForState: aState [
	^ aState
		ifNil: [ 0 @ 0 ]
		ifNotNil: [ aState currentTransform position + aState localCentre ]
]

{ #category : 'private - building' }
CFPhysicsRevoluteJointConstraintBuilder >> inverseMassForState: aState [
	^ aState ifNil: [ 0.0 ] ifNotNil: [ aState inverseMass ]
]

{ #category : 'private - building' }
CFPhysicsRevoluteJointConstraintBuilder >> inverseInertiaForState: aState [
	^ aState ifNil: [ 0.0 ] ifNotNil: [ aState inverseInertia ]
]
