Class {
	#name : 'CFPhysicsIslandSolverStage',
	#superclass : 'CFPhysicsStepStage',
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'executing' }
CFPhysicsIslandSolverStage >> executeOn: aStepResult [
	| solver |
	solver := CFPhysicsIslandSolver
		step: aStepResult step
		bodyStates: aStepResult bodyStates
		islands: aStepResult islands.
	solver
		solveWithGravity: aStepResult gravity
		restitutionThreshold: aStepResult restitutionThreshold.
	aStepResult solver: solver.
	^ solver
]
