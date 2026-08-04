"
I collect post-solve contact results for the current pipeline result. I am the pipeline stage that applies the configured hit threshold.
"

Class {
	#name : 'CFPhysicsPostSolveStage',
	#superclass : 'CFPhysicsStepStage',
	#instVars : [ 'collector' ],
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
}

{ #category : 'initialization' }
CFPhysicsPostSolveStage >> initialize [
	super initialize.
	collector := CFPhysicsPostSolveCollector new
]

{ #category : 'executing' }
CFPhysicsPostSolveStage >> executeOn: aStepResult [
	| batch |
	collector hitEventThreshold: aStepResult step hitEventThreshold.
	batch := collector collectFrom: aStepResult contactConstraints.
	aStepResult
		contactSolveResults: batch contactResults;
		hitEvents: batch hitEvents.
	^ batch
]

{ #category : 'accessing' }
CFPhysicsPostSolveStage >> hitEventThreshold [ ^ collector hitEventThreshold ]
{ #category : 'accessing' }
CFPhysicsPostSolveStage >> hitEventThreshold: aNumber [ collector hitEventThreshold: aNumber ]
