Class {
	#name : 'CFPhysicsIslandSolverStage',
	#superclass : 'CFPhysicsStepStage',
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
}

{ #category : 'executing' }
CFPhysicsIslandSolverStage >> executeOn: aStepResult [
	| solver |
	solver := CFPhysicsIslandSolver
		step: aStepResult step
		bodyStates: aStepResult bodyStates
		islands: aStepResult islands.
	solver solveWithRestitutionThreshold: aStepResult restitutionThreshold.
	aStepResult solver: solver.
	^ solver
]
