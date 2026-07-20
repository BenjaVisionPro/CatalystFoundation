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
	| stateA stateB centreA centreB anchorA anchorB baseSeparation inverseMassA inverseMassB inverseInertiaA inverseInertiaB kxx kxy kyy determinant massXX massXY massYY |
	stateA := joint firstBody ifNil: [ nil ] ifNotNil: [ :body | bodyStates at: body ].
	stateB := joint secondBody ifNil: [ nil ] ifNotNil: [ :body | bodyStates at: body ].
	centreA := self centreFor: joint firstBody state: stateA.
	centreB := self centreFor: joint secondBody state: stateB.
	anchorA := joint endpointPair worldPointA - centreA.
	anchorB := joint endpointPair worldPointB - centreB.
	baseSeparation := (centreB + anchorB) - (centreA + anchorA).
	inverseMassA := self inverseMassFor: joint firstBody.
	inverseMassB := self inverseMassFor: joint secondBody.
	inverseInertiaA := self inverseInertiaFor: joint firstBody.
	inverseInertiaB := self inverseInertiaFor: joint secondBody.
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
		yourself
]

{ #category : 'private - building' }
CFPhysicsRevoluteJointConstraintBuilder >> centreFor: aBody state: aState [
	^ aBody
		ifNil: [ 0 @ 0 ]
		ifNotNil: [ aState currentTransform position + (aBody extent / 2.0) ]
]

{ #category : 'private - building' }
CFPhysicsRevoluteJointConstraintBuilder >> inverseMassFor: aBody [
	^ aBody ifNil: [ 0.0 ] ifNotNil: [ aBody inverseMass ]
]

{ #category : 'private - building' }
CFPhysicsRevoluteJointConstraintBuilder >> inverseInertiaFor: aBody [
	^ aBody ifNil: [ 0.0 ] ifNotNil: [ aBody inverseInertia ]
]
