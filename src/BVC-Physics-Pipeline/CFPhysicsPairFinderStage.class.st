Class {
	#name : 'CFPhysicsPairFinderStage',
	#superclass : 'CFPhysicsStepStage',
	#instVars : [ 'pairFinder' ],
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
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
		pairsAmongSolvedStepStates: aStepResult orderedBodyStates
		collisionSuppressedBodyPairs: aStepResult collisionSuppressedBodyPairs.
	aStepResult pairs: pairs.
	^ pairs
]
