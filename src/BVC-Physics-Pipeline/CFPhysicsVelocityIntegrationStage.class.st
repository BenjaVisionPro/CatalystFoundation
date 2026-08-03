"
I integrate forces and velocities into the step-local body states. I am the first dynamic stage of the standard step pipeline.
"

Class {
	#name : 'CFPhysicsVelocityIntegrationStage',
	#superclass : 'CFPhysicsStepStage',
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
}

{ #category : 'executing' }
CFPhysicsVelocityIntegrationStage >> executeOn: aStepResult [
	"Velocity integration is performed once per solver substep, matching Box2D Soft Step."
	^ aStepResult bodyStates
]
