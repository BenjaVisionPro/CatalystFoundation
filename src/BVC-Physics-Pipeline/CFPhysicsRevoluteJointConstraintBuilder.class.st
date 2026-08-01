"
I prepare revolute joints for one solver step. I derive pivot, limit and motor data from the current body states.
"

Class {
	#name : 'CFPhysicsRevoluteJointConstraintBuilder',
	#superclass : 'Object',
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
}

{ #category : 'building' }
CFPhysicsRevoluteJointConstraintBuilder >> constraintsFrom: joints bodyStates: bodyStates warmStartRatio: warmStartRatio [
	^ (joints select: [ :joint |
		joint class == CFPhysicsRevoluteJoint and: [ joint isActive ] ]) collect: [ :joint |
			self constraintFrom: joint bodyStates: bodyStates warmStartRatio: warmStartRatio ]
]

{ #category : 'private - building' }
CFPhysicsRevoluteJointConstraintBuilder >> constraintFrom: joint bodyStates: bodyStates warmStartRatio: warmStartRatio [
	| stateA stateB originA originB anchorA anchorB baseSeparation inverseMassA inverseMassB inverseInertiaA inverseInertiaB kxx kxy kyy determinant massXX massXY massYY inverseAngularMass angleA angleB |
	stateA := joint bodyA ifNil: [ nil ] ifNotNil: [ :body | bodyStates at: body ].
	stateB := joint bodyB ifNil: [ nil ] ifNotNil: [ :body | bodyStates at: body ].
	originA := self originForState: stateA.
	originB := self originForState: stateB.
	anchorA := joint endpointPair worldPointA - originA.
	anchorB := joint endpointPair worldPointB - originB.
	baseSeparation := (originB + anchorB) - (originA + anchorA).
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
		lowerLimitImpulse: joint lowerLimitImpulse * warmStartRatio;
		upperLimitImpulse: joint upperLimitImpulse * warmStartRatio;
		motorEnabled: joint motorEnabled;
		motorSpeed: joint motorSpeed;
		maximumMotorImpulse: joint maximumMotorImpulse;
		motorMass: (inverseAngularMass = 0.0 ifTrue: [ 0.0 ] ifFalse: [ 1.0 / inverseAngularMass ]);
		motorImpulse: joint motorImpulse * warmStartRatio;
		yourself
]

{ #category : 'private - building' }
CFPhysicsRevoluteJointConstraintBuilder >> originForState: aState [
	^ aState
		ifNil: [ 0 @ 0 ]
		ifNotNil: [ aState currentBodyOrigin ]
]

{ #category : 'private - building' }
CFPhysicsRevoluteJointConstraintBuilder >> inverseMassForState: aState [
	^ aState ifNil: [ 0.0 ] ifNotNil: [ aState inverseMass ]
]

{ #category : 'private - building' }
CFPhysicsRevoluteJointConstraintBuilder >> inverseInertiaForState: aState [
	^ aState ifNil: [ 0.0 ] ifNotNil: [ aState inverseInertia ]
]
