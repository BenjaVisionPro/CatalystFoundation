Class {
	#name : 'CFPhysicsConstraintPreparationStage',
	#superclass : 'CFPhysicsStepStage',
	#instVars : [ 'constraintBuilder' ],
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'initialization' }
CFPhysicsConstraintPreparationStage >> initialize [
	super initialize.
	constraintBuilder := CFPhysicsConstraintBuilder new
]

{ #category : 'accessing' }
CFPhysicsConstraintPreparationStage >> constraintBuilder [ ^ constraintBuilder ]
{ #category : 'accessing' }
CFPhysicsConstraintPreparationStage >> constraintBuilder: anObject [ constraintBuilder := anObject ]

{ #category : 'executing' }
CFPhysicsConstraintPreparationStage >> executeOn: aStepResult [
	| constraints |
	constraints := constraintBuilder
		constraintsFrom: aStepResult activeContacts
		bodyStates: aStepResult bodyStates.
	aStepResult constraints: constraints.
	^ constraints
]
