Class {
	#name : 'CFPhysicsIslandSolverStage',
	#superclass : 'CFPhysicsStepStage',
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'executing' }
CFPhysicsIslandSolverStage >> executeOn: aStepResult [
	| solver step |
	step := aStepResult hasContinuousImpact
		ifTrue: [ self recoveryStepFor: aStepResult step ]
		ifFalse: [ aStepResult step ].
	solver := CFPhysicsIslandSolver
		step: step
		bodyStates: aStepResult bodyStates
		islands: aStepResult islands.
	solver solveWithRestitutionThreshold: aStepResult restitutionThreshold.
	aStepResult solver: solver.
	^ solver
]

{ #category : 'private - stepping' }
CFPhysicsIslandSolverStage >> recoveryStepFor: aStep [
	^ (CFPhysicsStep
		timeStep: 0.0
		substeps: aStep substepCount
		contactHertz: aStep contactHertz
		dampingRatio: aStep contactDampingRatio)
		warmStartRatio: 0.0;
		yourself
]
