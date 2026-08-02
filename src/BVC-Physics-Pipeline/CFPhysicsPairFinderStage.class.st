"
I update the persistent Box2D-style broadphase and expose its candidate pairs as an ordered pipeline stage.
"

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
	pairFinder := CFPhysicsBroadphase new
]



{ #category : 'accessing' }
CFPhysicsPairFinderStage >> pairFinder [
	^ pairFinder
]

{ #category : 'executing' }
CFPhysicsPairFinderStage >> executeOn: aStepResult [
	| pairs |
	pairs := pairFinder
		pairsAmongSolvedStepStates: aStepResult orderedBodyStates
		collisionSuppressedBodyPairs: aStepResult collisionSuppressedBodyPairs
		step: aStepResult step.
	aStepResult pairs: pairs.
	^ pairs
]
