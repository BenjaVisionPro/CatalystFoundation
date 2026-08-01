"
I build prepared contact constraints from active contacts and step-local body states. I also reuse constraint and point objects to reduce allocation during stepping.
"

Class {
	#name : 'CFPhysicsConstraintBuilder',
	#superclass : 'Object',
	#instVars : [ 'createdConstraintCount', 'reusedConstraintCount', 'createdPointCount', 'reusedPointCount' ],
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
}

{ #category : 'building' }
CFPhysicsConstraintBuilder >> constraintsFrom: contacts bodyStates: bodyStates [
	^ self constraintsFrom: contacts bodyStates: bodyStates warmStartRatio: 1.0
]

{ #category : 'building' }
CFPhysicsConstraintBuilder >> constraintsFrom: contacts bodyStates: bodyStates warmStartRatio: warmStartRatio [
	| constraints index |
	self resetReuseMeasurements.
	constraints := Array new: (contacts count: [ :contact |
		(self isSensorContact: contact bodyStates: bodyStates) not ]).
	index := 1.
	contacts do: [ :contact |
		(self isSensorContact: contact bodyStates: bodyStates) ifFalse: [
			constraints
				at: index
				put: (self
					constraintFrom: contact
					bodyStateA: (bodyStates at: contact firstBody)
					bodyStateB: (bodyStates at: contact secondBody)
					warmStartRatio: warmStartRatio).
			index := index + 1 ] ].
	^ constraints
]


{ #category : 'private - testing' }
CFPhysicsConstraintBuilder >> isSensorContact: contact bodyStates: bodyStates [
	^ (bodyStates at: contact firstBody) isSensor or: [
		(bodyStates at: contact secondBody) isSensor ]
]

{ #category : 'private - building' }
CFPhysicsConstraintBuilder >> constraintFrom: contact bodyStateA: stateA bodyStateB: stateB warmStartRatio: warmStartRatio [
	| normal tangent constraint previousPoints |
	normal := contact manifold normal.
	tangent := normal y @ normal x negated.
	constraint := contact preparedConstraint.
	constraint
		ifNil: [
			constraint := CFPhysicsPreparedConstraint new.
			createdConstraintCount := createdConstraintCount + 1 ]
		ifNotNil: [ reusedConstraintCount := reusedConstraintCount + 1 ].
	previousPoints := constraint points ifNil: [ #() ].
	constraint
		contact: contact;
		bodyStateA: stateA;
		bodyStateB: stateB;
		normal: normal;
		tangent: tangent;
		friction: (stateA friction * stateB friction) sqrt;
		restitution: (stateA restitution max: stateB restitution);
		tangentSpeed: stateA tangentSpeed + stateB tangentSpeed.
	constraint points: (self
		pointsFrom: contact manifold contactPoints
		previousPoints: previousPoints
		contact: contact
		bodyStateA: stateA
		bodyStateB: stateB
		normal: normal
		tangent: tangent
		warmStartRatio: warmStartRatio).
	contact preparedConstraint: constraint.
	^ constraint
]

{ #category : 'private - building' }
CFPhysicsConstraintBuilder >> pointsFrom: manifoldPoints previousPoints: previousPoints contact: contact bodyStateA: stateA bodyStateB: stateB normal: normal tangent: tangent warmStartRatio: warmStartRatio [
	| result index reusablePoint |
	result := Array new: manifoldPoints size.
	index := 1.
	manifoldPoints do: [ :manifoldPoint |
		reusablePoint := self reusablePointFor: manifoldPoint among: previousPoints contact: contact.
		reusablePoint
			ifNil: [
				reusablePoint := CFPhysicsConstraintPoint new.
				createdPointCount := createdPointCount + 1 ]
			ifNotNil: [ reusedPointCount := reusedPointCount + 1 ].
		result
			at: index
			put: (self
				updatePoint: reusablePoint
				from: manifoldPoint
				contact: contact
				bodyStateA: stateA
				bodyStateB: stateB
				normal: normal
				tangent: tangent
				warmStartRatio: warmStartRatio).
		index := index + 1 ].
	^ result
]

{ #category : 'private - building' }
CFPhysicsConstraintBuilder >> reusablePointFor: manifoldPoint among: previousPoints contact: contact [
	manifoldPoint featureId ifNil: [ ^ nil ].
	(contact previousManifold isNil or: [
		(contact manifold hasCompatibleNormalWith: contact previousManifold) not ]) ifTrue: [ ^ nil ].
	^ previousPoints
		detect: [ :point | point featureId = manifoldPoint featureId ]
		ifNone: [ nil ]
]

{ #category : 'private - building' }
CFPhysicsConstraintBuilder >> updatePoint: point from: manifoldPoint contact: contact bodyStateA: stateA bodyStateB: stateB normal: normal tangent: tangent warmStartRatio: warmStartRatio [
	| anchorA anchorB rnA rnB rtA rtB normalDenominator tangentDenominator relativeVelocity |
	anchorA := self rotatedAnchorFor: manifoldPoint localAnchorA bodyState: stateA.
	anchorB := self rotatedAnchorFor: manifoldPoint localAnchorB bodyState: stateB.
	rnA := self cross: anchorA with: normal.
	rnB := self cross: anchorB with: normal.
	normalDenominator := stateA inverseMass + stateB inverseMass
		+ (stateA inverseInertia * rnA squared)
		+ (stateB inverseInertia * rnB squared).
	rtA := self cross: anchorA with: tangent.
	rtB := self cross: anchorB with: tangent.
	tangentDenominator := stateA inverseMass + stateB inverseMass
		+ (stateA inverseInertia * rtA squared)
		+ (stateB inverseInertia * rtB squared).
	relativeVelocity := (stateB linearVelocity + (self crossScalar: stateB angularVelocity with: anchorB))
		- (stateA linearVelocity + (self crossScalar: stateA angularVelocity with: anchorA)).
	point
		manifoldPoint: manifoldPoint;
		featureId: manifoldPoint featureId;
		anchorA: anchorA;
		anchorB: anchorB;
		baseSeparation: manifoldPoint separation;
		normalMass: (normalDenominator = 0.0 ifTrue: [ 0.0 ] ifFalse: [ 1.0 / normalDenominator ]);
		tangentMass: (tangentDenominator = 0.0 ifTrue: [ 0.0 ] ifFalse: [ 1.0 / tangentDenominator ]);
		relativeNormalVelocity: (self dot: relativeVelocity with: normal);
		normalImpulse: manifoldPoint normalImpulse * warmStartRatio;
		tangentImpulse: manifoldPoint tangentImpulse * warmStartRatio;
		totalNormalImpulse: 0.0.
	^ point
]

{ #category : 'private - measurement' }
CFPhysicsConstraintBuilder >> resetReuseMeasurements [
	createdConstraintCount := 0.
	reusedConstraintCount := 0.
	createdPointCount := 0.
	reusedPointCount := 0
]

{ #category : 'accessing - measurement' }
CFPhysicsConstraintBuilder >> createdConstraintCount [ ^ createdConstraintCount ifNil: [ 0 ] ]

{ #category : 'accessing - measurement' }
CFPhysicsConstraintBuilder >> reusedConstraintCount [ ^ reusedConstraintCount ifNil: [ 0 ] ]

{ #category : 'accessing - measurement' }
CFPhysicsConstraintBuilder >> createdPointCount [ ^ createdPointCount ifNil: [ 0 ] ]

{ #category : 'accessing - measurement' }
CFPhysicsConstraintBuilder >> reusedPointCount [ ^ reusedPointCount ifNil: [ 0 ] ]

{ #category : 'private - geometry' }
CFPhysicsConstraintBuilder >> rotatedAnchorFor: localAnchor bodyState: bodyState [
	| relative rotation cosine sine |
	relative := bodyState bodyLocalPointForElementLocalPoint: localAnchor.
	rotation := bodyState currentTransform rotation.
	cosine := rotation cos.
	sine := rotation sin.
	^ ((relative x * cosine) - (relative y * sine))
		@ ((relative x * sine) + (relative y * cosine))
]

{ #category : 'private - mathematics' }
CFPhysicsConstraintBuilder >> dot: first with: second [
	^ (first x * second x) + (first y * second y)
]

{ #category : 'private - mathematics' }
CFPhysicsConstraintBuilder >> cross: first with: second [
	^ (first x * second y) - (first y * second x)
]

{ #category : 'private - mathematics' }
CFPhysicsConstraintBuilder >> crossScalar: scalar with: vector [
	^ (scalar * vector y negated) @ (scalar * vector x)
]
