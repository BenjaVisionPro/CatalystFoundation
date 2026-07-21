Class {
	#name : 'CFPhysicsBodyCommitStage',
	#superclass : 'CFPhysicsStepStage',
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'executing' }
CFPhysicsBodyCommitStage >> executeOn: aStepResult [
	| states |
	states := aStepResult bodyStates values sorted: [ :first :second |
		first body sequence < second body sequence ].
	states do: #commit.
	^ states
]
