Class {
	#name : 'CFPhysicsIslandBuilderStage',
	#superclass : 'CFPhysicsStepStage',
	#instVars : [ 'islandBuilder' ],
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'initialization' }
CFPhysicsIslandBuilderStage >> initialize [
	super initialize.
	islandBuilder := CFPhysicsIslandBuilder new
]

{ #category : 'accessing' }
CFPhysicsIslandBuilderStage >> islandBuilder [ ^ islandBuilder ]
{ #category : 'accessing' }
CFPhysicsIslandBuilderStage >> islandBuilder: anObject [ islandBuilder := anObject ]

{ #category : 'executing' }
CFPhysicsIslandBuilderStage >> executeOn: aStepResult [
	| islands |
	islands := islandBuilder
		islandsFromBodies: aStepResult bodies
		constraints: aStepResult constraints.
	aStepResult islands: islands.
	^ islands
]
