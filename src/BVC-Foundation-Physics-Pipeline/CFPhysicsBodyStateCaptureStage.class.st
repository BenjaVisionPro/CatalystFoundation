Class {
	#name : 'CFPhysicsBodyStateCaptureStage',
	#superclass : 'CFPhysicsStepStage',
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'executing' }
CFPhysicsBodyStateCaptureStage >> executeOn: aStepResult [
	| states |
	states := IdentityDictionary new.
	aStepResult bodies do: [ :body |
		states at: body put: (CFPhysicsBodyStepState on: body) ].
	aStepResult bodyStates: states.
	^ states
]
