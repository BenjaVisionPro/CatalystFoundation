Class {
	#name : 'CFPhysicsIslandWakeStage',
	#superclass : 'CFPhysicsStepStage',
	#instVars : [ 'sleepBehaviour' ],
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'accessing' }
CFPhysicsIslandWakeStage >> sleepBehaviour [ ^ sleepBehaviour ]
{ #category : 'accessing' }
CFPhysicsIslandWakeStage >> sleepBehaviour: anObject [ sleepBehaviour := anObject ]

{ #category : 'executing' }
CFPhysicsIslandWakeStage >> executeOn: aStepResult [
	sleepBehaviour propagateWakeAcross: aStepResult islands.
	^ aStepResult islands
]
