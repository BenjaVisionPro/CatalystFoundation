Class {
	#name : 'CFPhysicsDistanceJointConstraintBuilder',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'building' }
CFPhysicsDistanceJointConstraintBuilder >> constraintsFrom: joints bodyStates: bodyStates warmStartRatio: warmStartRatio [
	^ (joints select: [ :joint | joint isActive ]) collect: [ :joint |
		self constraintFrom: joint bodyStates: bodyStates warmStartRatio: warmStartRatio ]
]

{ #category : 'private - building' }
CFPhysicsDistanceJointConstraintBuilder >> constraintFrom: joint bodyStates: bodyStates warmStartRatio: warmStartRatio [
	| stateA stateB centreA centreB anchorA anchorB displacement distance direction rnA rnB inverseMass |
	stateA := joint firstBody ifNil: [ nil ] ifNotNil: [ :body | bodyStates at: body ].
	stateB := joint secondBody ifNil: [ nil ] ifNotNil: [ :body | bodyStates at: body ].
	centreA := self centreFor: joint firstBody state: stateA.
	centreB := self centreFor: joint secondBody state: stateB.
	anchorA := joint endpointPair worldPointA - centreA.
	anchorB := joint endpointPair worldPointB - centreB.
	displacement := (centreB + anchorB) - (centreA + anchorA).
	distance := displacement r.
	direction := distance = 0.0 ifTrue: [ 1 @ 0 ] ifFalse: [ displacement / distance ].
	rnA := self cross: anchorA with: direction.
	rnB := self cross: anchorB with: direction.
	inverseMass := (self inverseMassFor: joint firstBody cross: rnA)
		+ (self inverseMassFor: joint secondBody cross: rnB).
	^ CFPhysicsPreparedDistanceJoint new
		joint: joint;
		bodyStateA: stateA;
		bodyStateB: stateB;
		anchorA: anchorA;
		anchorB: anchorB;
		direction: direction;
		baseSeparation: distance - joint restLength;
		effectiveMass: (inverseMass = 0.0 ifTrue: [ 0.0 ] ifFalse: [ 1.0 / inverseMass ]);
		impulse: joint accumulatedImpulse * warmStartRatio;
		yourself
]

{ #category : 'private - mathematics' }
CFPhysicsDistanceJointConstraintBuilder >> cross: first with: second [
	^ (first x * second y) - (first y * second x)
]

{ #category : 'private - building' }
CFPhysicsDistanceJointConstraintBuilder >> centreFor: aBody state: aState [
	^ aBody
		ifNil: [ 0 @ 0 ]
		ifNotNil: [ aState currentTransform position + (aBody extent / 2.0) ]
]

{ #category : 'private - building' }
CFPhysicsDistanceJointConstraintBuilder >> inverseMassFor: aBody cross: aCross [
	^ aBody
		ifNil: [ 0.0 ]
		ifNotNil: [ aBody inverseMass + (aBody inverseInertia * aCross squared) ]
]
