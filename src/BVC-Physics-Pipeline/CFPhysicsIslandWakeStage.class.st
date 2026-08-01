"
I propagate wake state across islands before solving. I share the same sleeping policy used by the final sleeping stage.
"

Class {
	#name : 'CFPhysicsIslandWakeStage',
	#superclass : 'CFPhysicsStepStage',
	#instVars : [ 'sleepBehaviour' ],
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
}

{ #category : 'accessing' }
CFPhysicsIslandWakeStage >> sleepBehaviour [ ^ sleepBehaviour ]
{ #category : 'accessing' }
CFPhysicsIslandWakeStage >> sleepBehaviour: anObject [ sleepBehaviour := anObject ]

{ #category : 'executing' }
CFPhysicsIslandWakeStage >> executeOn: aStepResult [
	sleepBehaviour
		propagateWakeAcross: aStepResult islands
		bodyStates: aStepResult bodyStates.
	^ aStepResult islands
]
