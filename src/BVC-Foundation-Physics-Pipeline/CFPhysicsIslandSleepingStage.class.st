Class {
	#name : 'CFPhysicsIslandSleepingStage',
	#superclass : 'CFPhysicsStepStage',
	#instVars : [ 'sleepBehaviour' ],
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'accessing' }
CFPhysicsIslandSleepingStage >> sleepBehaviour [ ^ sleepBehaviour ]
{ #category : 'accessing' }
CFPhysicsIslandSleepingStage >> sleepBehaviour: anObject [ sleepBehaviour := anObject ]
{ #category : 'accessing' }
CFPhysicsIslandSleepingStage >> configuration [ ^ sleepBehaviour configuration ]
{ #category : 'accessing' }
CFPhysicsIslandSleepingStage >> configuration: anObject [ sleepBehaviour configuration: anObject ]

{ #category : 'executing' }
CFPhysicsIslandSleepingStage >> executeOn: aStepResult [
	| decisions |
	decisions := sleepBehaviour
		updateIslands: aStepResult islands
		bodyStates: aStepResult bodyStates
		elapsed: aStepResult step timeStep.
	aStepResult sleepDecisions: decisions.
	^ decisions
]
