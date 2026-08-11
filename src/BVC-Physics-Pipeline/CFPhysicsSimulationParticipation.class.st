"
I define the shared Physics policy for deciding which bodies and constraints participate in active solver work.

My responsibility is to keep capture and pipeline preparation aligned on the same awake/non-static participation semantics.
"
Class {
	#name : 'CFPhysicsSimulationParticipation',
	#superclass : 'Object',
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
}

{ #category : 'testing' }
CFPhysicsSimulationParticipation class >> bodyParticipatesInActiveSimulation: aBody [
	^ aBody isStatic not and: [ aBody isAwake ]
]

{ #category : 'testing' }
CFPhysicsSimulationParticipation class >> constraintParticipatesInActiveSimulation: aConstraint [
	| bodyA bodyB |
	bodyA := aConstraint bodyA.
	bodyB := aConstraint bodyB.
	^ (bodyA notNil and: [ self bodyParticipatesInActiveSimulation: bodyA ]) or: [
		bodyB notNil and: [ self bodyParticipatesInActiveSimulation: bodyB ] ]
]
