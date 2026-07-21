Class {
	#name : 'CFPhysicsIslandSolverStage',
	#superclass : 'CFPhysicsStepStage',
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'executing' }
CFPhysicsIslandSolverStage >> executeOn: aStepResult [
	| solver islands |
	islands := self ordinaryIslandsOn: aStepResult.
	solver := CFPhysicsIslandSolver
		step: aStepResult step
		bodyStates: aStepResult bodyStates
		islands: islands.
	solver solveWithRestitutionThreshold: aStepResult restitutionThreshold.
	aStepResult solver: solver.
	^ solver
]

{ #category : 'private - islands' }
CFPhysicsIslandSolverStage >> ordinaryIslandsOn: aStepResult [
	| completedBodies |
	aStepResult hasContinuousImpact ifFalse: [ ^ aStepResult islands ].
	completedBodies := IdentitySet new.
	completedBodies addAll: aStepResult continuousStepResult completedBodies.
	^ aStepResult islands reject: [ :island |
		| completedDynamicBodies ordinaryDynamicBodies |
		completedDynamicBodies := island dynamicBodies select: [ :body |
			completedBodies includes: body ].
		ordinaryDynamicBodies := island dynamicBodies reject: [ :body |
			completedBodies includes: body ].
		(completedDynamicBodies notEmpty and: [ ordinaryDynamicBodies notEmpty ]) ifTrue: [
			self error: 'A physics island cannot be partly completed by continuous collision' ].
		completedDynamicBodies notEmpty ]
]
