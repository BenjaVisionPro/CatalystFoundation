"
I prepare contact and joint constraints for the solver. I translate persistent contacts and joints into step-local constraint objects.
"

Class {
	#name : 'CFPhysicsConstraintPreparationStage',
	#superclass : 'CFPhysicsStepStage',
	#instVars : [ 'constraintBuilder', 'distanceJointConstraintBuilder', 'revoluteJointConstraintBuilder', 'weldJointConstraintBuilder', 'prismaticJointConstraintBuilder', 'wheelJointConstraintBuilder', 'mouseJointConstraintBuilder', 'motorJointConstraintBuilder', 'preparedContactConstraintCount', 'preparedContactPointCount', 'continuedContactConstraintCount', 'beganContactConstraintCount', 'reusableContactPointCount', 'newContactPointCount', 'stableManifoldCount', 'changedManifoldCount', 'featureIdChangedManifoldCount', 'normalChangedManifoldCount', 'pointCountChangedManifoldCount', 'pointOrderChangedManifoldCount', 'separationChangedManifoldCount', 'preparedJointConstraintCount' ],
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
}

{ #category : 'initialization' }
CFPhysicsConstraintPreparationStage >> initialize [
	super initialize.
	constraintBuilder := CFPhysicsConstraintBuilder new.
	distanceJointConstraintBuilder := CFPhysicsDistanceJointConstraintBuilder new.
	revoluteJointConstraintBuilder := CFPhysicsRevoluteJointConstraintBuilder new.
	weldJointConstraintBuilder := CFPhysicsWeldJointConstraintBuilder new.
	prismaticJointConstraintBuilder := CFPhysicsPrismaticJointConstraintBuilder new.
	wheelJointConstraintBuilder := CFPhysicsWheelJointConstraintBuilder new.
	mouseJointConstraintBuilder := CFPhysicsMouseJointConstraintBuilder new.
	motorJointConstraintBuilder := CFPhysicsMotorJointConstraintBuilder new
]





{ #category : 'executing' }
CFPhysicsConstraintPreparationStage >> executeOn: aStepResult [
	| contactConstraints jointConstraints |
	contactConstraints := constraintBuilder
		constraintsFrom: aStepResult activeSimulationContacts
		bodyStates: aStepResult bodyStates
		warmStartRatio: aStepResult step warmStartRatio.
	jointConstraints := self jointConstraintsFor: aStepResult.
	preparedJointConstraintCount := jointConstraints size.
	aStepResult
		contactConstraints: contactConstraints;
		jointConstraints: jointConstraints;
		constraints: jointConstraints;
		solverConstraints: (self
			contactConstraints: contactConstraints
			followedBy: jointConstraints).
	^ aStepResult solverConstraints
]

{ #category : 'private - building' }
CFPhysicsConstraintPreparationStage >> jointConstraintsFor: aStepResult [
	| constraints |
	constraints := OrderedCollection new: aStepResult activeSimulationJoints size.
	constraints addAll: (motorJointConstraintBuilder
		constraintsFrom: aStepResult activeSimulationJoints
		bodyStates: aStepResult bodyStates
		step: aStepResult step).
	constraints addAll: (mouseJointConstraintBuilder
		constraintsFrom: aStepResult activeSimulationJoints
		bodyStates: aStepResult bodyStates
		step: aStepResult step).
	constraints addAll: (distanceJointConstraintBuilder
		constraintsFrom: aStepResult activeSimulationJoints
		bodyStates: aStepResult bodyStates
		step: aStepResult step).
	constraints addAll: (revoluteJointConstraintBuilder
		constraintsFrom: aStepResult activeSimulationJoints
		bodyStates: aStepResult bodyStates
		step: aStepResult step).
	constraints addAll: (weldJointConstraintBuilder
		constraintsFrom: aStepResult activeSimulationJoints
		bodyStates: aStepResult bodyStates
		step: aStepResult step).
	constraints addAll: (prismaticJointConstraintBuilder
		constraintsFrom: aStepResult activeSimulationJoints
		bodyStates: aStepResult bodyStates
		step: aStepResult step).
	constraints addAll: (wheelJointConstraintBuilder
		constraintsFrom: aStepResult activeSimulationJoints
		bodyStates: aStepResult bodyStates
		step: aStepResult step).
	^ self orderedJointConstraints: constraints
]

{ #category : 'private - building' }
CFPhysicsConstraintPreparationStage >> contactConstraints: contactConstraints followedBy: jointConstraints [
	| result index |
	result := Array new: contactConstraints size + jointConstraints size.
	index := 1.
	contactConstraints do: [ :constraint |
		result at: index put: constraint.
		index := index + 1 ].
	jointConstraints do: [ :constraint |
		result at: index put: constraint.
		index := index + 1 ].
	^ result
]

{ #category : 'executing' }
CFPhysicsConstraintPreparationStage >> executeOnWithTelemetry: aStepResult [
	self measureContacts: aStepResult activeSimulationContacts.
	^ self executeOn: aStepResult
]

{ #category : 'private - ordering' }
CFPhysicsConstraintPreparationStage >> orderedJointConstraints: jointConstraints [
	^ jointConstraints asArray sorted: [ :first :second |
		first joint orderingKey = second joint orderingKey
			ifTrue: [ first joint class name asString < second joint class name asString ]
			ifFalse: [ first joint orderingKey < second joint orderingKey ] ]
]


{ #category : 'private - measurement' }
CFPhysicsConstraintPreparationStage >> measureContacts: contacts [
	| solidContacts |
	preparedContactConstraintCount := 0.
	preparedContactPointCount := 0.
	continuedContactConstraintCount := 0.
	beganContactConstraintCount := 0.
	reusableContactPointCount := 0.
	newContactPointCount := 0.
	stableManifoldCount := 0.
	changedManifoldCount := 0.
	featureIdChangedManifoldCount := 0.
	normalChangedManifoldCount := 0.
	pointCountChangedManifoldCount := 0.
	pointOrderChangedManifoldCount := 0.
	separationChangedManifoldCount := 0.
	preparedJointConstraintCount := 0.
	solidContacts := contacts reject: #isSensor.
	solidContacts do: [ :contact | self measureContact: contact ].
]

{ #category : 'private - measurement' }
CFPhysicsConstraintPreparationStage >> measureContact: contact [
	| pointCount reusableCount stable |
	preparedContactConstraintCount := preparedContactConstraintCount + 1.
	pointCount := contact manifold contactPoints size.
	preparedContactPointCount := preparedContactPointCount + pointCount.
	contact began ifTrue: [ beganContactConstraintCount := beganContactConstraintCount + 1 ].
	contact continued ifFalse: [
		newContactPointCount := newContactPointCount + pointCount.
		^ self ].
	continuedContactConstraintCount := continuedContactConstraintCount + 1.
	reusableCount := self reusablePointCountFor: contact.
	reusableContactPointCount := reusableContactPointCount + reusableCount.
	newContactPointCount := newContactPointCount + pointCount - reusableCount.
	stable := reusableCount = pointCount
		and: [ contact previousManifold contactPoints size = pointCount ].
	stable
		ifTrue: [ stableManifoldCount := stableManifoldCount + 1 ]
		ifFalse: [
			changedManifoldCount := changedManifoldCount + 1.
			self measureChangesFrom: contact previousManifold to: contact manifold ]
]

{ #category : 'private - measurement' }
CFPhysicsConstraintPreparationStage >> reusablePointCountFor: contact [
	| previous current |
	previous := contact previousManifold.
	current := contact manifold.
	previous ifNil: [ ^ 0 ].
	^ current contactPoints count: [ :point |
		point featureId notNil and: [
			previous contactPoints anySatisfy: [ :oldPoint |
				oldPoint featureId = point featureId ] ] ]
]


{ #category : 'private - measurement' }
CFPhysicsConstraintPreparationStage >> measureChangesFrom: previous to: current [
	(self featureIdsChangedFrom: previous to: current)
		ifTrue: [ featureIdChangedManifoldCount := featureIdChangedManifoldCount + 1 ].
	(self normalChangedFrom: previous to: current)
		ifTrue: [ normalChangedManifoldCount := normalChangedManifoldCount + 1 ].
	previous contactPoints size ~= current contactPoints size
		ifTrue: [ pointCountChangedManifoldCount := pointCountChangedManifoldCount + 1 ].
	(self pointOrderChangedFrom: previous to: current)
		ifTrue: [ pointOrderChangedManifoldCount := pointOrderChangedManifoldCount + 1 ].
	(self separationChangedFrom: previous to: current)
		ifTrue: [ separationChangedManifoldCount := separationChangedManifoldCount + 1 ]
]

{ #category : 'private - measurement' }
CFPhysicsConstraintPreparationStage >> featureIdsChangedFrom: previous to: current [
	| previousIds currentIds |
	previousIds := previous contactPoints collect: #featureId.
	currentIds := current contactPoints collect: #featureId.
	previousIds size = currentIds size ifFalse: [ ^ true ].
	^ previousIds anySatisfy: [ :featureId |
		(previousIds occurrencesOf: featureId) ~= (currentIds occurrencesOf: featureId) ]
]

{ #category : 'private - measurement' }
CFPhysicsConstraintPreparationStage >> normalChangedFrom: previous to: current [
	(previous normal isNil or: [ current normal isNil ])
		ifTrue: [ ^ previous normal ~~ current normal ].
	^ (previous normal closeTo: current normal) not
]

{ #category : 'private - measurement' }
CFPhysicsConstraintPreparationStage >> pointOrderChangedFrom: previous to: current [
	| previousIds currentIds |
	previousIds := previous contactPoints collect: #featureId.
	currentIds := current contactPoints collect: #featureId.
	(self featureIdsChangedFrom: previous to: current) ifTrue: [ ^ false ].
	^ previousIds ~= currentIds
]

{ #category : 'private - measurement' }
CFPhysicsConstraintPreparationStage >> separationChangedFrom: previous to: current [
	^ current contactPoints anySatisfy: [ :point |
		previous contactPoints
			detect: [ :oldPoint | oldPoint featureId = point featureId ]
			ifFound: [ :oldPoint | (oldPoint separation closeTo: point separation) not ]
			ifNone: [ false ] ]
]

{ #category : 'accessing - measurement' }
CFPhysicsConstraintPreparationStage >> preparedContactConstraintCount [ ^ preparedContactConstraintCount ifNil: [ 0 ] ]
{ #category : 'accessing - measurement' }
CFPhysicsConstraintPreparationStage >> preparedContactPointCount [ ^ preparedContactPointCount ifNil: [ 0 ] ]
{ #category : 'accessing - measurement' }
CFPhysicsConstraintPreparationStage >> continuedContactConstraintCount [ ^ continuedContactConstraintCount ifNil: [ 0 ] ]
{ #category : 'accessing - measurement' }
CFPhysicsConstraintPreparationStage >> beganContactConstraintCount [ ^ beganContactConstraintCount ifNil: [ 0 ] ]
{ #category : 'accessing - measurement' }
CFPhysicsConstraintPreparationStage >> reusableContactPointCount [ ^ reusableContactPointCount ifNil: [ 0 ] ]
{ #category : 'accessing - measurement' }
CFPhysicsConstraintPreparationStage >> newContactPointCount [ ^ newContactPointCount ifNil: [ 0 ] ]
{ #category : 'accessing - measurement' }
CFPhysicsConstraintPreparationStage >> stableManifoldCount [ ^ stableManifoldCount ifNil: [ 0 ] ]
{ #category : 'accessing - measurement' }
CFPhysicsConstraintPreparationStage >> changedManifoldCount [ ^ changedManifoldCount ifNil: [ 0 ] ]

{ #category : 'accessing - measurement' }
CFPhysicsConstraintPreparationStage >> featureIdChangedManifoldCount [ ^ featureIdChangedManifoldCount ifNil: [ 0 ] ]
{ #category : 'accessing - measurement' }
CFPhysicsConstraintPreparationStage >> normalChangedManifoldCount [ ^ normalChangedManifoldCount ifNil: [ 0 ] ]
{ #category : 'accessing - measurement' }
CFPhysicsConstraintPreparationStage >> pointCountChangedManifoldCount [ ^ pointCountChangedManifoldCount ifNil: [ 0 ] ]
{ #category : 'accessing - measurement' }
CFPhysicsConstraintPreparationStage >> pointOrderChangedManifoldCount [ ^ pointOrderChangedManifoldCount ifNil: [ 0 ] ]
{ #category : 'accessing - measurement' }
CFPhysicsConstraintPreparationStage >> separationChangedManifoldCount [ ^ separationChangedManifoldCount ifNil: [ 0 ] ]
{ #category : 'accessing - measurement' }
CFPhysicsConstraintPreparationStage >> preparedJointConstraintCount [ ^ preparedJointConstraintCount ifNil: [ 0 ] ]
{ #category : 'accessing - measurement' }
CFPhysicsConstraintPreparationStage >> preparedObjectCount [
	^ constraintBuilder createdConstraintCount
		+ constraintBuilder createdPointCount
		+ self preparedJointConstraintCount
]

