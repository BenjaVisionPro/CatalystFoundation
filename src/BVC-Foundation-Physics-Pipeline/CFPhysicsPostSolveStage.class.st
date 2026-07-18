Class {
	#name : 'CFPhysicsPostSolveStage',
	#superclass : 'CFPhysicsStepStage',
	#instVars : [ 'collector' ],
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'initialization' }
CFPhysicsPostSolveStage >> initialize [
	super initialize.
	collector := CFPhysicsPostSolveCollector new
]

{ #category : 'executing' }
CFPhysicsPostSolveStage >> executeOn: aStepResult [
	| batch |
	batch := collector collectFrom: aStepResult constraints.
	aStepResult
		contactSolveResults: batch contactResults;
		hitEvents: batch hitEvents.
	^ batch
]

{ #category : 'accessing' }
CFPhysicsPostSolveStage >> hitEventThreshold [ ^ collector hitEventThreshold ]
{ #category : 'accessing' }
CFPhysicsPostSolveStage >> hitEventThreshold: aNumber [ collector hitEventThreshold: aNumber ]
