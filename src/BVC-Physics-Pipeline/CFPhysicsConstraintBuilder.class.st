"
I build step-local prepared contact constraints from active contacts and captured body states.
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
	^ contact isSensor
]

{ #category : 'private - building' }
CFPhysicsConstraintBuilder >> constraintFrom: contact bodyStateA: stateA bodyStateB: stateB warmStartRatio: warmStartRatio [
	| normal tangent constraint rollingDenominator maximumRadius |
	normal := contact manifold normal.
	tangent := normal y @ normal x negated.
	constraint := CFPhysicsPreparedConstraint new.
	createdConstraintCount := createdConstraintCount + 1.
	rollingDenominator := stateA inverseInertia + stateB inverseInertia.
	maximumRadius := stateA shapeState rollingResistanceRadius max: stateB shapeState rollingResistanceRadius.
	constraint
		contact: contact;
		bodyStateA: stateA;
		bodyStateB: stateB;
		normal: normal;
		tangent: tangent;
		friction: (stateA friction * stateB friction) sqrt;
		restitution: (stateA restitution max: stateB restitution);
		rollingResistance: (stateA rollingResistance max: stateB rollingResistance) * maximumRadius;
		rollingMass: (rollingDenominator = 0.0 ifTrue: [ 0.0 ] ifFalse: [ 1.0 / rollingDenominator ]);
		rollingImpulse: contact manifold rollingImpulse * warmStartRatio;
		tangentSpeed: stateA tangentSpeed + stateB tangentSpeed.
	constraint points: (self
		pointsFrom: contact manifold contactPoints
		contact: contact
		bodyStateA: stateA
		bodyStateB: stateB
		normal: normal
		tangent: tangent
		warmStartRatio: warmStartRatio).
	^ constraint
]

{ #category : 'private - building' }
CFPhysicsConstraintBuilder >> pointsFrom: manifoldPoints contact: contact bodyStateA: stateA bodyStateB: stateB normal: normal tangent: tangent warmStartRatio: warmStartRatio [
	| result index point |
	result := Array new: manifoldPoints size.
	index := 1.
	manifoldPoints do: [ :manifoldPoint |
		point := CFPhysicsConstraintPoint new.
		createdPointCount := createdPointCount + 1.
		result
			at: index
			put: (self
				updatePoint: point
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
		baseSeparation: manifoldPoint separation - (self dot: anchorB - anchorA with: normal);
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
