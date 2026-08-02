"
I materialise solver islands from the detached persistent island groups captured from the world.

The legacy whole-world connectivity rebuild has been removed. The persistent island graph is the only runtime source of solver groups.
"

Class {
	#name : 'CFPhysicsIslandBuilderStage',
	#superclass : 'CFPhysicsStepStage',
	#instVars : [ 'islandBuilder' ],
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
}

{ #category : 'initialization' }
CFPhysicsIslandBuilderStage >> initialize [
	super initialize.
	islandBuilder := CFPhysicsIslandBuilder new
]

{ #category : 'accessing' }
CFPhysicsIslandBuilderStage >> islandBuilder [ ^ islandBuilder ]

{ #category : 'executing' }
CFPhysicsIslandBuilderStage >> executeOn: aStepResult [
	| islands |
	islands := islandBuilder
		islandsFromPersistentBodyGroups: aStepResult islandBodyGroups
		bodies: aStepResult bodies
		constraints: aStepResult constraints.
	aStepResult islands: islands.
	^ islands
]
