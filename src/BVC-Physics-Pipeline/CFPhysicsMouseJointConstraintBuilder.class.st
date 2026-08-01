"
I prepare mouse joints for one solver step using Box2D 3.1.1 spring softness and force limiting.
"
Class {
	#name : 'CFPhysicsMouseJointConstraintBuilder',
	#superclass : 'Object',
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
}

{ #category : 'building' }
CFPhysicsMouseJointConstraintBuilder >> constraintsFrom: joints bodyStates: bodyStates step: step [
	^ (joints select: [ :joint | joint class == CFPhysicsMouseJoint and: [ joint isActive ] ]) collect: [ :joint |
		self constraintFrom: joint bodyStates: bodyStates step: step ]
]

{ #category : 'private - building' }
CFPhysicsMouseJointConstraintBuilder >> constraintFrom: joint bodyStates: bodyStates step: step [
	| state origin anchor inverseMass inverseInertia kxx kxy kyy determinant massXX massXY massYY omega a1 a2 a3 |
	state := bodyStates at: joint bodyB.
	origin := state currentBodyOrigin.
	anchor := (state worldPointForBodyLocalPoint: joint localAnchorB) - origin.
	inverseMass := state inverseMass.
	inverseInertia := state inverseInertia.
	kxx := inverseMass + (inverseInertia * anchor y squared).
	kxy := (inverseInertia * anchor x * anchor y) negated.
	kyy := inverseMass + (inverseInertia * anchor x squared).
	determinant := (kxx * kyy) - (kxy * kxy).
	determinant = 0.0
		ifTrue: [ massXX := 0.0. massXY := 0.0. massYY := 0.0 ]
		ifFalse: [
			massXX := kyy / determinant.
			massXY := kxy negated / determinant.
			massYY := kxx / determinant ].
	omega := 2.0 * Float pi * joint hertz.
	a1 := (2.0 * joint dampingRatio) + (omega * step substepTime).
	a2 := step substepTime * omega * a1.
	a3 := a2 = 0.0 ifTrue: [ 0.0 ] ifFalse: [ 1.0 / (1.0 + a2) ].
	^ CFPhysicsPreparedMouseJoint new
		joint: joint;
		bodyStateA: nil;
		bodyStateB: state;
		anchorB: anchor;
		baseSeparation: origin + anchor - joint target;
		effectiveMassXX: massXX;
		effectiveMassXY: massXY;
		effectiveMassYY: massYY;
		biasRate: (a1 = 0.0 ifTrue: [ 0.0 ] ifFalse: [ omega / a1 ]);
		massCoefficient: a2 * a3;
		impulseCoefficient: a3;
		maximumImpulse: step substepTime * joint maximumForce;
		impulse: joint impulse * step warmStartRatio;
		yourself
]
