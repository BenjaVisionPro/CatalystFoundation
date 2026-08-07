"I prepare Box2D 3.1.1 distance joints for one solver step."
Class { #name : 'CFPhysicsDistanceJointConstraintBuilder', #superclass : 'Object', #category : 'BVC-Physics-Pipeline', #package : 'BVC-Physics-Pipeline' }

{ #category : 'building' }
CFPhysicsDistanceJointConstraintBuilder >> constraintsFrom: joints bodyStates: bodyStates step: step [
	^ (joints select: [ :joint | (joint isKindOf: CFPhysicsDistanceJoint) and: [ joint isActive ] ]) collect: [ :joint |
		self constraintFrom: joint bodyStates: bodyStates step: step ]
]

{ #category : 'private - building' }
CFPhysicsDistanceJointConstraintBuilder >> constraintFrom: joint bodyStates: bodyStates step: step [
	| stateA stateB originA originB anchorA anchorB displacement distance direction rnA rnB inverseMass omega a1 a2 a3 |
	stateA := joint bodyA ifNil: [ nil ] ifNotNil: [ :body | bodyStates at: body ].
	stateB := joint bodyB ifNil: [ nil ] ifNotNil: [ :body | bodyStates at: body ].
	originA := self originForState: stateA.
	originB := self originForState: stateB.
	anchorA := joint endpointPair worldPointA - originA.
	anchorB := joint endpointPair worldPointB - originB.
	displacement := (originB + anchorB) - (originA + anchorA).
	distance := displacement r.
	direction := distance = 0.0 ifTrue: [ 1 @ 0 ] ifFalse: [ displacement / distance ].
	rnA := self cross: anchorA with: direction.
	rnB := self cross: anchorB with: direction.
	inverseMass := (self inverseMassForState: stateA cross: rnA) + (self inverseMassForState: stateB cross: rnB).
	omega := 2.0 * Float pi * joint hertz.
	a1 := (2.0 * joint dampingRatio) + (omega * step substepTime).
	a2 := step substepTime * omega * a1.
	a3 := 1.0 / (1.0 + a2).
	^ CFPhysicsPreparedDistanceJoint new
		joint: joint; bodyStateA: stateA; bodyStateB: stateB;
		anchorA: anchorA; anchorB: anchorB; direction: direction;
		baseLength: distance;
		effectiveMass: (inverseMass = 0.0 ifTrue: [ 0.0 ] ifFalse: [ 1.0 / inverseMass ]);
		springEnabled: joint springEnabled;
		biasRate: (a1 = 0.0 ifTrue: [ 0.0 ] ifFalse: [ omega / a1 ]);
		massCoefficient: a2 * a3; impulseCoefficient: a3;
		impulse: joint impulse * step warmStartRatio;
		limitsEnabled: joint limitsEnabled;
		minimumLength: joint minimumLength;
		maximumLength: joint maximumLength;
		lowerLimitImpulse: joint lowerLimitImpulse * step warmStartRatio;
		upperLimitImpulse: joint upperLimitImpulse * step warmStartRatio;
		motorEnabled: joint motorEnabled;
		motorSpeed: joint motorSpeed;
		maximumMotorImpulse: (joint forceUnitsForNewtons: joint maximumMotorForce) * step substepTime;
		motorImpulse: joint motorImpulse * step warmStartRatio;
		yourself
]

{ #category : 'private - mathematics' }
CFPhysicsDistanceJointConstraintBuilder >> cross: first with: second [ ^ (first x * second y) - (first y * second x) ]
{ #category : 'private - building' }
CFPhysicsDistanceJointConstraintBuilder >> originForState: state [ ^ state ifNil: [ 0 @ 0 ] ifNotNil: [ state currentBodyOrigin ] ]
{ #category : 'private - building' }
CFPhysicsDistanceJointConstraintBuilder >> inverseMassForState: state cross: cross [ ^ state ifNil: [ 0.0 ] ifNotNil: [ state inverseMass + (state inverseInertia * cross squared) ] ]
