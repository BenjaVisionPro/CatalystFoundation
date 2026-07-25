Class {
	#name : 'CFPhysicsStepStageExecution',
	#superclass : 'Object',
	#instVars : [ 'stage', 'output', 'durationMilliseconds' ],
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'instance creation' }
CFPhysicsStepStageExecution class >> stage: aStage output: anObject [
	^ self new stage: aStage; output: anObject; durationMilliseconds: nil; yourself
]

{ #category : 'instance creation' }
CFPhysicsStepStageExecution class >> stage: aStage output: anObject durationMilliseconds: aNumber [
	^ self new stage: aStage; output: anObject; durationMilliseconds: aNumber; yourself
]

{ #category : 'accessing' }
CFPhysicsStepStageExecution >> stage [ ^ stage ]
{ #category : 'accessing' }
CFPhysicsStepStageExecution >> stage: anObject [ stage := anObject ]
{ #category : 'accessing' }
CFPhysicsStepStageExecution >> output [ ^ output ]
{ #category : 'accessing' }
CFPhysicsStepStageExecution >> output: anObject [ output := anObject ]
{ #category : 'accessing' }
CFPhysicsStepStageExecution >> name [ ^ stage name ]

{ #category : 'accessing' }
CFPhysicsStepStageExecution >> durationMilliseconds [ ^ durationMilliseconds ]

{ #category : 'accessing' }
CFPhysicsStepStageExecution >> durationMilliseconds: aNumber [ durationMilliseconds := aNumber ]
