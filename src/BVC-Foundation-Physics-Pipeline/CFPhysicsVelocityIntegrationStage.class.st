Class {
	#name : 'CFPhysicsVelocityIntegrationStage',
	#superclass : 'CFPhysicsStepStage',
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'executing' }
CFPhysicsVelocityIntegrationStage >> executeOn: aStepResult [
	aStepResult bodies do: [ :body |
		(aStepResult bodyStates at: body)
			integrateVelocityBy: aStepResult step timeStep
			gravity: aStepResult gravity ].
	^ aStepResult bodyStates
]
