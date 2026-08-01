"
I prepare rail joints for one solver step. I derive the axis, limits, masses and impulses required by the rail-joint solver.
"

Class {
	#name : 'CFPhysicsRailJointConstraintBuilder',
	#superclass : 'Object',
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
}

{ #category : 'building' }
CFPhysicsRailJointConstraintBuilder >> constraintsFrom: joints bodyStates: bodyStates warmStartRatio: warmStartRatio [
	^ (joints select: [ :joint |
		joint class == CFPhysicsRailJoint and: [ joint isActive ] ]) collect: [ :joint |
			self constraintFrom: joint bodyStates: bodyStates warmStartRatio: warmStartRatio ]
]

{ #category : 'private - building' }
CFPhysicsRailJointConstraintBuilder >> constraintFrom: joint bodyStates: bodyStates warmStartRatio: warmStartRatio [
	| stateA stateB originA originB anchorA anchorB displacement axis normal crossA crossB axisCrossA axisCrossB inversePerpendicularMass inverseTranslationMass inverseAngularMass angleA angleB |
	stateA := joint firstBody ifNil: [ nil ] ifNotNil: [ :body | bodyStates at: body ].
	stateB := joint secondBody ifNil: [ nil ] ifNotNil: [ :body | bodyStates at: body ].
	originA := self originForState: stateA.
	originB := self originForState: stateB.
	anchorA := joint endpointPair worldPointA - originA.
	anchorB := joint endpointPair worldPointB - originB.
	displacement := (originB + anchorB) - (originA + anchorA).
	axis := joint axis.
	normal := joint normal.
	crossA := self cross: anchorA with: normal.
	crossB := self cross: anchorB with: normal.
	inversePerpendicularMass := (self inverseMassForState: stateA cross: crossA)
		+ (self inverseMassForState: stateB cross: crossB).
	axisCrossA := self cross: anchorA with: axis.
	axisCrossB := self cross: anchorB with: axis.
	inverseTranslationMass := (self inverseMassForState: stateA cross: axisCrossA)
		+ (self inverseMassForState: stateB cross: axisCrossB).
	inverseAngularMass := (self inverseInertiaForState: stateA)
		+ (self inverseInertiaForState: stateB).
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
CFPhysicsRailJointConstraintBuilder >> originForState: aState [
	^ aState
		ifNil: [ 0 @ 0 ]
		ifNotNil: [ aState currentBodyOrigin ]
]

{ #category : 'private - building' }
CFPhysicsRailJointConstraintBuilder >> inverseMassForState: aState cross: aCross [
	^ aState
		ifNil: [ 0.0 ]
		ifNotNil: [ aState inverseMass + (aState inverseInertia * aCross squared) ]
]

{ #category : 'private - building' }
CFPhysicsRailJointConstraintBuilder >> inverseInertiaForState: aState [
	^ aState ifNil: [ 0.0 ] ifNotNil: [ aState inverseInertia ]
]
