Class {
	#name : 'CFPhysicsContactTestCase',
	#superclass : 'CFPhysicsPipelineTestCase',
	#category : 'BVC-Physics-Tests-Core',
	#package : 'BVC-Physics-Tests-Core'
}

{ #category : 'private - contact pipeline' }
CFPhysicsContactTestCase >> newManifoldWithFeatureIndex: anInteger [
	| point manifold |
	point := CFPhysicsManifoldPoint at: 5 @ 5.
	point
		featureId: (CFPhysicsContactFeatureId featureA: #face index: 0 featureB: #vertex index: anInteger);
		localAnchorA: 5 @ 5;
		localAnchorB: 5 @ 0;
		separation: -1.0.
	manifold := CFPhysicsManifold normal: 0 @ 1 penetration: 1.0.
	manifold contactPoints: { point }.
	^ manifold
]


{ #category : 'private - contact fixtures' }
CFPhysicsContactTestCase >> newPreparedConstraint [
	| first second pair manifold contact bodyStates |
	first := self newBodyWithSequence: 1.
	first beStatic.
	second := self newBodyWithSequence: 2.
	pair := CFPhysicsPair first: first second: second.
	manifold := self newManifoldWithFeatureIndex: 1.
	contact := CFPhysicsContact pair: pair manifold: manifold.
	bodyStates := IdentityDictionary new
		at: first put: (CFPhysicsBodyStepState on: first);
		at: second put: (CFPhysicsBodyStepState on: second);
		yourself.
	^ (CFPhysicsConstraintBuilder new
		constraintsFrom: { contact }
		bodyStates: bodyStates) first
]

{ #category : 'private - contact fixtures' }
CFPhysicsContactTestCase >> newSensorContactStepResult [
	| ground sensor step pipeline |
	ground := self newBodyWithSequence: 1 position: 0 @ 0 extent: 100 @ 20.
	ground beStatic.
	sensor := self newBodyWithSequence: 2 position: 20 @ 15 extent: 60 @ 20.
	sensor beSensor.
	step := CFPhysicsStep
		timeStep: 0.016
		substeps: 4
		contactHertz: 30.0
		dampingRatio: 10.0.
	pipeline := CFPhysicsStepPipeline manifoldGenerator: CFPhysicsManifoldGenerator new.
	^ pipeline
		stepBodies: { sensor. ground }
		fromContacts: #()
		step: step
		gravity: 0 @ 0
		restitutionThreshold: 1.0
]
