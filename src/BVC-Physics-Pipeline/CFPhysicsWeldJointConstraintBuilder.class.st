"
I prepare weld joints for one solver step.

My responsibility is to derive the point and angular constraints that preserve a weld joint's relative transform.
"
Class {
	#name : 'CFPhysicsWeldJointConstraintBuilder',
	#superclass : 'Object',
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
}

{ #category : 'building' }
CFPhysicsWeldJointConstraintBuilder >> constraintsFrom: joints bodyStates: bodyStates warmStartRatio: warmStartRatio [
	^ (joints select: [ :joint |
		joint class == CFPhysicsWeldJoint and: [ joint isActive ] ]) collect: [ :joint |
			self constraintFrom: joint bodyStates: bodyStates warmStartRatio: warmStartRatio ]
]

{ #category : 'private - building' }
CFPhysicsWeldJointConstraintBuilder >> constraintFrom: joint bodyStates: bodyStates warmStartRatio: warmStartRatio [
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
	angleA := stateA ifNil: [ 0.0 ] ifNotNil: [ stateA currentTransform rotation ].
	angleB := stateB ifNil: [ 0.0 ] ifNotNil: [ stateB currentTransform rotation ].
	^ CFPhysicsPreparedWeldJoint new
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
		limitBaseAngle: 0.0;
		limitsEnabled: false;
		lowerAngle: 0.0;
		upperAngle: 0.0;
		limitMass: 0.0;
		limitImpulse: 0.0;
		motorEnabled: false;
		motorSpeed: 0.0;
		maximumMotorImpulse: 0.0;
		motorMass: 0.0;
		motorImpulse: 0.0;
		baseAngle: (angleB - angleA - joint referenceAngle);
		angularMass: (inverseAngularMass = 0.0 ifTrue: [ 0.0 ] ifFalse: [ 1.0 / inverseAngularMass ]);
		angularImpulse: joint accumulatedAngularImpulse * warmStartRatio;
		yourself
]

{ #category : 'private - building' }
CFPhysicsWeldJointConstraintBuilder >> originForState: aState [
	^ aState ifNil: [ 0 @ 0 ] ifNotNil: [ aState currentBodyOrigin ]
]

{ #category : 'private - building' }
CFPhysicsWeldJointConstraintBuilder >> inverseMassForState: aState [
	^ aState ifNil: [ 0.0 ] ifNotNil: [ aState inverseMass ]
]

{ #category : 'private - building' }
CFPhysicsWeldJointConstraintBuilder >> inverseInertiaForState: aState [
	^ aState ifNil: [ 0.0 ] ifNotNil: [ aState inverseInertia ]
]
