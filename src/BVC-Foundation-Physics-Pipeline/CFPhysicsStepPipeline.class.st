Class {
	#name : 'CFPhysicsStepPipeline',
	#superclass : 'Object',
	#instVars : [ 'contactPipeline', 'constraintBuilder' ],
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'instance creation' }
CFPhysicsStepPipeline class >> manifoldBuilder: aBlock [
	^ self new
		contactPipeline: (CFPhysicsContactPipeline manifoldBuilder: aBlock);
		constraintBuilder: CFPhysicsConstraintBuilder new;
		yourself
]

{ #category : 'accessing' }
CFPhysicsStepPipeline >> contactPipeline: aContactPipeline [
	contactPipeline := aContactPipeline
]

{ #category : 'accessing' }
CFPhysicsStepPipeline >> constraintBuilder: aConstraintBuilder [
	constraintBuilder := aConstraintBuilder
]

{ #category : 'stepping' }
CFPhysicsStepPipeline >> stepBodies: bodies fromContacts: previousContacts step: step gravity: gravityVector restitutionThreshold: restitutionThreshold [
	| orderedBodies contactResult bodyStates constraints solver |
	orderedBodies := bodies asArray sorted: [ :left :right | left sequence < right sequence ].
	contactResult := contactPipeline
		updateBodies: orderedBodies
		fromContacts: previousContacts.
	bodyStates := self captureBodyStatesFor: orderedBodies.
	constraints := constraintBuilder
		constraintsFrom: contactResult activeContacts
		bodyStates: bodyStates.
	solver := CFPhysicsSoftStepSolver
		step: step
		bodyStates: bodyStates
		constraints: constraints.
	solver
		solveWithGravity: gravityVector
		restitutionThreshold: restitutionThreshold.
	^ CFPhysicsStepPipelineResult new
		step: step;
		bodies: orderedBodies;
		contactResult: contactResult;
		bodyStates: bodyStates;
		constraints: constraints;
		solver: solver;
		gravity: gravityVector;
		restitutionThreshold: restitutionThreshold;
		yourself
]

{ #category : 'private - stepping' }
CFPhysicsStepPipeline >> captureBodyStatesFor: bodies [
	| states |
	states := IdentityDictionary new.
	bodies do: [ :body |
		states at: body put: (CFPhysicsBodyStepState on: body) ].
	^ states
]
