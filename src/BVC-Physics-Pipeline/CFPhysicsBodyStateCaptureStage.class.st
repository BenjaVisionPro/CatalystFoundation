Class {
	#name : 'CFPhysicsBodyStateCaptureStage',
	#superclass : 'CFPhysicsStepStage',
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
}

{ #category : 'executing' }
CFPhysicsBodyStateCaptureStage >> executeOn: aStepResult [
	| states orderedStates index |
	states := IdentityDictionary new.
	orderedStates := Array new: aStepResult bodies size.
	index := 0.
	aStepResult bodies do: [ :body |
		| state |
		state := CFPhysicsBodyStepState on: body.
		states at: body put: state.
		orderedStates at: (index := index + 1) put: state ].
	aStepResult
		bodyStates: states;
		orderedBodyStates: orderedStates.
	^ states
]
