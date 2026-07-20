Class {
	#name : 'CFPhysicsRailJointConstraintBuilder',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'building' }
CFPhysicsRailJointConstraintBuilder >> constraintsFrom: joints bodyStates: bodyStates warmStartRatio: warmStartRatio [
	^ (joints select: [ :joint |
		joint class == CFPhysicsRailJoint and: [ joint isActive ] ]) collect: [ :joint |
			self constraintFrom: joint bodyStates: bodyStates warmStartRatio: warmStartRatio ]
]

{ #category : 'private - building' }
CFPhysicsRailJointConstraintBuilder >> constraintFrom: joint bodyStates: bodyStates warmStartRatio: warmStartRatio [
	| stateA stateB centreA centreB anchorA anchorB displacement axis normal crossA crossB axisCrossA axisCrossB inversePerpendicularMass inverseTranslationMass inverseAngularMass angleA angleB |
	stateA := joint firstBody ifNil: [ nil ] ifNotNil: [ :body | bodyStates at: body ].
	stateB := joint secondBody ifNil: [ nil ] ifNotNil: [ :body | bodyStates at: body ].
	centreA := self centreFor: joint firstBody state: stateA.
	centreB := self centreFor: joint secondBody state: stateB.
	anchorA := joint endpointPair worldPointA - centreA.
	anchorB := joint endpointPair worldPointB - centreB.
	displacement := (centreB + anchorB) - (centreA + anchorA).
	axis := joint axis.
	normal := joint normal.
	crossA := self cross: anchorA with: normal.
	crossB := self cross: anchorB with: normal.
	inversePerpendicularMass := (self inverseMassFor: joint firstBody cross: crossA)
		+ (self inverseMassFor: joint secondBody cross: crossB).
	axisCrossA := self cross: anchorA with: axis.
	axisCrossB := self cross: anchorB with: axis.
	inverseTranslationMass := (self inverseMassFor: joint firstBody cross: axisCrossA)
		+ (self inverseMassFor: joint secondBody cross: axisCrossB).
	inverseAngularMass := (self inverseInertiaFor: joint firstBody)
		+ (self inverseInertiaFor: joint secondBody).
	angleA := stateA ifNil: [ 0.0 ] ifNotNil: [ stateA currentTransform rotation ].
	angleB := stateB ifNil: [ 0.0 ] ifNotNil: [ stateB currentTransform rotation ].
	^ CFPhysicsPreparedRailJoint new
		joint: joint;
		bodyStateA: stateA;
		bodyStateB: stateB;
		anchorA: anchorA;
		anchorB: anchorB;
		axis: axis;
		normal: normal;
		basePerpendicularSeparation: (self dot: displacement with: normal);
		perpendicularMass: (inversePerpendicularMass = 0.0 ifTrue: [ 0.0 ] ifFalse: [ 1.0 / inversePerpendicularMass ]);
		perpendicularImpulse: joint accumulatedPerpendicularImpulse * warmStartRatio;
		baseTranslation: (self dot: displacement negated with: axis) - joint referenceTranslation;
		limitsEnabled: joint limitsEnabled;
		lowerTranslation: joint lowerTranslation;
		upperTranslation: joint upperTranslation;
		translationMass: (inverseTranslationMass = 0.0 ifTrue: [ 0.0 ] ifFalse: [ 1.0 / inverseTranslationMass ]);
		translationImpulse: 0.0;
		baseAngle: angleB - angleA - joint referenceAngle;
		angularMass: (inverseAngularMass = 0.0 ifTrue: [ 0.0 ] ifFalse: [ 1.0 / inverseAngularMass ]);
		angularImpulse: joint accumulatedAngularImpulse * warmStartRatio;
		yourself
]

{ #category : 'private - mathematics' }
CFPhysicsRailJointConstraintBuilder >> cross: first with: second [
	^ (first x * second y) - (first y * second x)
]

{ #category : 'private - mathematics' }
CFPhysicsRailJointConstraintBuilder >> dot: first with: second [
	^ (first x * second x) + (first y * second y)
]

{ #category : 'private - building' }
CFPhysicsRailJointConstraintBuilder >> centreFor: aBody state: aState [
	^ aBody
		ifNil: [ 0 @ 0 ]
		ifNotNil: [ aState currentTransform position + (aBody extent / 2.0) ]
]

{ #category : 'private - building' }
CFPhysicsRailJointConstraintBuilder >> inverseMassFor: aBody cross: aCross [
	^ aBody
		ifNil: [ 0.0 ]
		ifNotNil: [ aBody inverseMass + (aBody inverseInertia * aCross squared) ]
]

{ #category : 'private - building' }
CFPhysicsRailJointConstraintBuilder >> inverseInertiaFor: aBody [
	^ aBody ifNil: [ 0.0 ] ifNotNil: [ aBody inverseInertia ]
]
