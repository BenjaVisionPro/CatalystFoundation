Class {
	#name : 'CFPhysicsPipelineTestCase',
	#superclass : 'CFPhysicsTestCase',
	#category : 'BVC-Physics-Tests-Core',
	#package : 'BVC-Physics-Tests-Core'
}

{ #category : 'private - pipeline fixtures' }
CFPhysicsPipelineTestCase >> newComposedStepResult [
	| ground box step pipeline |
	ground := self newBodyWithSequence: 1 position: 0 @ 0 extent: 100 @ 20.
	ground beStatic.
	box := self newBodyWithSequence: 2 position: 20 @ 15 extent: 60 @ 20.
	step := CFPhysicsStep
		timeStep: 0.016
		substeps: 4
		contactHertz: 30.0
		dampingRatio: 10.0.
	pipeline := CFPhysicsStepPipeline manifoldGenerator: CFPhysicsManifoldGenerator new.
	^ pipeline
		stepBodies: { box. ground }
		fromContacts: #()
		step: step
		gravity: 0 @ 0
		restitutionThreshold: 1.0
]
