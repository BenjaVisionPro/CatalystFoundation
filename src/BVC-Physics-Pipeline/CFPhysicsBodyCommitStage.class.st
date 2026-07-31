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
