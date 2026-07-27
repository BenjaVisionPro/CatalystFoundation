Class {
	#name : 'CFPhysicsBodyCommitStage',
	#superclass : 'CFPhysicsStepStage',
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'executing' }
CFPhysicsBodyCommitStage >> executeOn: aStepResult [
	aStepResult orderedBodyStates do: #commit.
	^ aStepResult orderedBodyStates
]
