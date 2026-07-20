Class {
	#name : 'CFPhysicsContinuousStepExecutor',
	#superclass : 'Object',
	#instVars : [ 'impactFinder', 'impactAdvancer', 'impactSolver', 'remainingTimeIntegrator' ],
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'initialization' }
CFPhysicsContinuousStepExecutor >> initialize [
	super initialize.
	impactFinder := CFPhysicsEarliestImpactFinder new.
	impactAdvancer := CFPhysicsImpactAdvancer new.
	impactSolver := CFPhysicsImpactSolver new.
	remainingTimeIntegrator := CFPhysicsRemainingTimeIntegrator new
]

{ #category : 'executing' }
CFPhysicsContinuousStepExecutor >> executePairs: pairs bodyStates: bodyStates step: step restitutionThreshold: restitutionThreshold [
	| impact advancement impactStep solveResult |
	impact := impactFinder
		earliestAmong: pairs
		bodyStates: bodyStates
		for: step timeStep.
	impact ifNil: [ ^ nil ].
	advancement := impactAdvancer
		advanceBodyStates: bodyStates
		to: impact
		for: step timeStep.
	impactStep := CFPhysicsStep
		timeStep: advancement remainingTime
		substeps: step substepCount
		contactHertz: step contactHertz
		dampingRatio: step contactDampingRatio.
	impactStep warmStartRatio: 0.0.
	solveResult := impactSolver
		solveAdvancement: advancement
		bodyStates: bodyStates
		step: impactStep
		restitutionThreshold: restitutionThreshold.
	remainingTimeIntegrator
		integrateBodyStates: bodyStates
		after: solveResult.
	self commitBodyStatesInOrder: bodyStates.
	^ CFPhysicsContinuousStepResult
		impact: impact
		impactSolveResult: solveResult
		bodyStates: bodyStates
]

{ #category : 'private - committing' }
CFPhysicsContinuousStepExecutor >> commitBodyStatesInOrder: bodyStates [
	(bodyStates values sorted: [ :first :second |
		first body sequence < second body sequence ]) do: #commit
]

{ #category : 'accessing' }
CFPhysicsContinuousStepExecutor >> impactFinder [ ^ impactFinder ]

{ #category : 'accessing' }
CFPhysicsContinuousStepExecutor >> impactFinder: anObject [ impactFinder := anObject ]

{ #category : 'accessing' }
CFPhysicsContinuousStepExecutor >> impactAdvancer [ ^ impactAdvancer ]

{ #category : 'accessing' }
CFPhysicsContinuousStepExecutor >> impactAdvancer: anObject [ impactAdvancer := anObject ]

{ #category : 'accessing' }
CFPhysicsContinuousStepExecutor >> impactSolver [ ^ impactSolver ]

{ #category : 'accessing' }
CFPhysicsContinuousStepExecutor >> impactSolver: anObject [ impactSolver := anObject ]

{ #category : 'accessing' }
CFPhysicsContinuousStepExecutor >> remainingTimeIntegrator [ ^ remainingTimeIntegrator ]

{ #category : 'accessing' }
CFPhysicsContinuousStepExecutor >> remainingTimeIntegrator: anObject [ remainingTimeIntegrator := anObject ]
