Class {
	#name : 'CFPhysicsConstraintPreparationStage',
	#superclass : 'CFPhysicsStepStage',
	#instVars : [ 'constraintBuilder', 'distanceJointConstraintBuilder', 'revoluteJointConstraintBuilder' ],
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'initialization' }
CFPhysicsConstraintPreparationStage >> initialize [
	super initialize.
	constraintBuilder := CFPhysicsConstraintBuilder new.
	distanceJointConstraintBuilder := CFPhysicsDistanceJointConstraintBuilder new.
	revoluteJointConstraintBuilder := CFPhysicsRevoluteJointConstraintBuilder new
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

{ #category : 'executing' }
CFPhysicsConstraintPreparationStage >> executeOn: aStepResult [
	| constraints jointConstraints |
	constraints := aStepResult hasContinuousImpact
		ifTrue: [
			| allConstraints |
			allConstraints := OrderedCollection new.
			aStepResult continuousStepResult impactSolveResults do: [ :solveResult |
				allConstraints addAll: solveResult constraints ].
			allConstraints ]
		ifFalse: [
			constraintBuilder
				constraintsFrom: aStepResult activeContacts
				bodyStates: aStepResult bodyStates
				warmStartRatio: aStepResult step warmStartRatio ].
	jointConstraints := distanceJointConstraintBuilder
		constraintsFrom: aStepResult joints
		bodyStates: aStepResult bodyStates
		warmStartRatio: aStepResult step warmStartRatio.
	jointConstraints := jointConstraints asOrderedCollection
		addAll: (revoluteJointConstraintBuilder
			constraintsFrom: aStepResult joints
			bodyStates: aStepResult bodyStates
			warmStartRatio: aStepResult step warmStartRatio);
		yourself.
	constraints := constraints asOrderedCollection addAll: jointConstraints; yourself.
	aStepResult constraints: constraints.
	^ aStepResult constraints
]
