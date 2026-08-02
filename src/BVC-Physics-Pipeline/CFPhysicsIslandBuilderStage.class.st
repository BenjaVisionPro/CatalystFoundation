"
I build islands for the current pipeline result. I expose the island builder as one ordered step stage.
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
{ #category : 'accessing' }
CFPhysicsIslandBuilderStage >> islandBuilder: anObject [ islandBuilder := anObject ]

{ #category : 'executing' }
CFPhysicsIslandBuilderStage >> executeOn: aStepResult [
	| islands |
	islands := aStepResult islandBodyGroups isEmpty
		ifTrue: [
			"Focused stage examples may construct a pipeline result without a captured world state."
			islandBuilder
				islandsFromBodies: aStepResult bodies
				constraints: aStepResult constraints ]
		ifFalse: [
			islandBuilder
				islandsFromPersistentBodyGroups: aStepResult islandBodyGroups
				bodies: aStepResult bodies
				constraints: aStepResult constraints ].
	aStepResult islands: islands.
	^ islands
]
