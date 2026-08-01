"
I commit solved body step states back to their bodies. I am a pipeline stage for applying a completed step result.
"

Class {
	#name : 'CFPhysicsBodyCommitStage',
	#superclass : 'CFPhysicsStepStage',
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
}

{ #category : 'executing' }
CFPhysicsBodyCommitStage >> executeOn: aStepResult [
	aStepResult orderedBodyStates do: #commit.
	^ aStepResult orderedBodyStates
]
