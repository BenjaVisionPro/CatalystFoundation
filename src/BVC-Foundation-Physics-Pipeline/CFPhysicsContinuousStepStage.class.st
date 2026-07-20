Class {
	#name : 'CFPhysicsContinuousStepStage',
	#superclass : 'CFPhysicsStepStage',
	#instVars : [ 'executor' ],
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'initialization' }
CFPhysicsContinuousStepStage >> initialize [
	super initialize.
	executor := CFPhysicsContinuousStepExecutor new
]

{ #category : 'executing' }
CFPhysicsContinuousStepStage >> executeOn: aStepResult [
	| continuousResult |
	continuousResult := executor
		executePairs: aStepResult pairs
		bodyStates: aStepResult bodyStates
		step: aStepResult step
		restitutionThreshold: aStepResult restitutionThreshold.
	aStepResult continuousStepResult: continuousResult.
	^ continuousResult
]

{ #category : 'accessing' }
CFPhysicsContinuousStepStage >> executor [ ^ executor ]

{ #category : 'accessing' }
CFPhysicsContinuousStepStage >> executor: anObject [ executor := anObject ]
