Class {
	#name : 'CFPhysicsPairFinderStage',
	#superclass : 'CFPhysicsStepStage',
	#instVars : [ 'pairFinder' ],
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'initialization' }
CFPhysicsPairFinderStage >> initialize [
	super initialize.
	pairFinder := CFPhysicsPairFinder new
]

{ #category : 'accessing' }
CFPhysicsPairFinderStage >> pairFinder [ ^ pairFinder ]
{ #category : 'accessing' }
CFPhysicsPairFinderStage >> pairFinder: anObject [ pairFinder := anObject ]

{ #category : 'executing' }
CFPhysicsPairFinderStage >> executeOn: aStepResult [
	| pairs |
	pairs := pairFinder
		pairsAmongStepStates: aStepResult bodyStates values
		for: aStepResult step timeStep.
	aStepResult pairs: pairs.
	^ pairs
]
