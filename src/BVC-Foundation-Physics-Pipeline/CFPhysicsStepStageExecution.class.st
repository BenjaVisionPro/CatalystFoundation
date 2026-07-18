Class {
	#name : 'CFPhysicsStepStageExecution',
	#superclass : 'Object',
	#instVars : [ 'stage', 'output' ],
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'instance creation' }
CFPhysicsStepStageExecution class >> stage: aStage output: anObject [
	^ self new stage: aStage; output: anObject; yourself
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
