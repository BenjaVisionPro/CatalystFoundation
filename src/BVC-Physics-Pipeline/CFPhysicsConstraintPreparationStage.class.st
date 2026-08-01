"
I prepare contact and joint constraints for the solver. I translate persistent contacts and joints into step-local constraint objects.
"

Class {
	#name : 'CFPhysicsConstraintPreparationStage',
	#superclass : 'CFPhysicsStepStage',
	#instVars : [ 'constraintBuilder', 'distanceJointConstraintBuilder', 'revoluteJointConstraintBuilder', 'weldJointConstraintBuilder', 'prismaticJointConstraintBuilder', 'mouseJointConstraintBuilder', 'motorJointConstraintBuilder', 'preparedContactConstraintCount', 'preparedContactPointCount', 'continuedContactConstraintCount', 'beganContactConstraintCount', 'reusableContactPointCount', 'newContactPointCount', 'stableManifoldCount', 'changedManifoldCount', 'preparedJointConstraintCount' ],
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
	mouseJointConstraintBuilder := CFPhysicsMouseJointConstraintBuilder new.
	motorJointConstraintBuilder := CFPhysicsMotorJointConstraintBuilder new
]

{ #category : 'accessing' }
CFPhysicsConstraintPreparationStage >> constraintBuilder [ ^ constraintBuilder ]
{ #category : 'accessing' }
CFPhysicsConstraintPreparationStage >> constraintBuilder: anObject [ constraintBuilder := anObject ]
{ #category : 'accessing' }
CFPhysicsConstraintPreparationStage >> distanceJointConstraintBuilder [ ^ distanceJointConstraintBuilder ]
{ #category : 'accessing' }
CFPhysicsConstraintPreparationStage >> distanceJointConstraintBuilder: anObject [ distanceJointConstraintBuilder := anObject ]
{ #category : 'accessing' }
CFPhysicsConstraintPreparationStage >> revoluteJointConstraintBuilder [ ^ revoluteJointConstraintBuilder ]
{ #category : 'accessing' }
CFPhysicsConstraintPreparationStage >> revoluteJointConstraintBuilder: anObject [ revoluteJointConstraintBuilder := anObject ]
{ #category : 'accessing' }
CFPhysicsConstraintPreparationStage >> weldJointConstraintBuilder [ ^ weldJointConstraintBuilder ]
{ #category : 'accessing' }
CFPhysicsConstraintPreparationStage >> weldJointConstraintBuilder: anObject [ weldJointConstraintBuilder := anObject ]
{ #category : 'accessing' }
CFPhysicsConstraintPreparationStage >> prismaticJointConstraintBuilder [ ^ prismaticJointConstraintBuilder ]
{ #category : 'accessing' }
CFPhysicsConstraintPreparationStage >> prismaticJointConstraintBuilder: anObject [ prismaticJointConstraintBuilder := anObject ]
{ #category : 'accessing' }
CFPhysicsConstraintPreparationStage >> mouseJointConstraintBuilder [ ^ mouseJointConstraintBuilder ]
{ #category : 'accessing' }
CFPhysicsConstraintPreparationStage >> mouseJointConstraintBuilder: anObject [ mouseJointConstraintBuilder := anObject ]
{ #category : 'accessing' }
CFPhysicsConstraintPreparationStage >> motorJointConstraintBuilder [ ^ motorJointConstraintBuilder ]
{ #category : 'accessing' }
CFPhysicsConstraintPreparationStage >> motorJointConstraintBuilder: anObject [ motorJointConstraintBuilder := anObject ]

{ #category : 'executing' }
CFPhysicsConstraintPreparationStage >> executeOn: aStepResult [
	| contactConstraints jointConstraints |
	contactConstraints := constraintBuilder
		constraintsFrom: aStepResult activeContacts
		bodyStates: aStepResult bodyStates
		step: aStepResult step.
	jointConstraints := self jointConstraintsFor: aStepResult.
	preparedJointConstraintCount := jointConstraints size.
	aStepResult jointConstraints: jointConstraints.
	aStepResult constraints: (self
		contactConstraints: contactConstraints
		followedBy: jointConstraints).
	^ aStepResult constraints
]

{ #category : 'private - building' }
CFPhysicsConstraintPreparationStage >> jointConstraintsFor: aStepResult [
	| constraints |
	constraints := OrderedCollection new: aStepResult joints size.
	constraints addAll: (motorJointConstraintBuilder
		constraintsFrom: aStepResult joints
		bodyStates: aStepResult bodyStates
		step: aStepResult step).
	constraints addAll: (mouseJointConstraintBuilder
		constraintsFrom: aStepResult joints
		bodyStates: aStepResult bodyStates
		step: aStepResult step).
	constraints addAll: (distanceJointConstraintBuilder
		constraintsFrom: aStepResult joints
		bodyStates: aStepResult bodyStates
		step: aStepResult step).
	constraints addAll: (revoluteJointConstraintBuilder
		constraintsFrom: aStepResult joints
		bodyStates: aStepResult bodyStates
		step: aStepResult step).
	constraints addAll: (weldJointConstraintBuilder
		constraintsFrom: aStepResult joints
		bodyStates: aStepResult bodyStates
		step: aStepResult step).
	constraints addAll: (prismaticJointConstraintBuilder
		constraintsFrom: aStepResult joints
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
	self measureContacts: aStepResult activeContacts.
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
		ifFalse: [ changedManifoldCount := changedManifoldCount + 1 ]
]

{ #category : 'private - measurement' }
CFPhysicsConstraintPreparationStage >> reusablePointCountFor: contact [
	| previous current |
	previous := contact previousManifold.
	current := contact manifold.
	(previous isNil or: [ (current hasCompatibleNormalWith: previous) not ]) ifTrue: [ ^ 0 ].
	^ current contactPoints count: [ :point |
		point featureId notNil and: [
			previous contactPoints anySatisfy: [ :oldPoint |
				oldPoint featureId = point featureId ] ] ]
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
CFPhysicsConstraintPreparationStage >> preparedJointConstraintCount [ ^ preparedJointConstraintCount ifNil: [ 0 ] ]
{ #category : 'accessing - measurement' }
CFPhysicsConstraintPreparationStage >> preparedObjectCount [
	^ constraintBuilder createdConstraintCount
		+ constraintBuilder createdPointCount
		+ self preparedJointConstraintCount
]

{ #category : 'accessing - measurement' }
CFPhysicsConstraintPreparationStage >> reusedPreparedObjectCount [
	^ constraintBuilder reusedConstraintCount + constraintBuilder reusedPointCount
]
