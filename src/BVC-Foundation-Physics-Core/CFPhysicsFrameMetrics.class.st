Class {
	#name : 'CFPhysicsFrameMetrics',
	#superclass : 'Object',
	#instVars : [ 'stepNumber', 'simulationTime', 'membershipMilliseconds', 'preparationMilliseconds', 'pipelineMilliseconds', 'boundaryMilliseconds', 'totalMilliseconds', 'bodyCount', 'activeBodyCount', 'contactCount', 'constraintCount', 'jointCount', 'stageExecutions' ],
	#category : 'BVC-Foundation-Physics-Core',
	#package : 'BVC-Foundation-Physics-Core'
}

{ #category : 'accessing' }
CFPhysicsFrameMetrics >> stepNumber [ ^ stepNumber ]
{ #category : 'accessing' }
CFPhysicsFrameMetrics >> stepNumber: anInteger [ stepNumber := anInteger ]
{ #category : 'accessing' }
CFPhysicsFrameMetrics >> simulationTime [ ^ simulationTime ]
{ #category : 'accessing' }
CFPhysicsFrameMetrics >> simulationTime: aNumber [ simulationTime := aNumber ]
{ #category : 'accessing' }
CFPhysicsFrameMetrics >> membershipMilliseconds [ ^ membershipMilliseconds ]
{ #category : 'accessing' }
CFPhysicsFrameMetrics >> membershipMilliseconds: aNumber [ membershipMilliseconds := aNumber ]
{ #category : 'accessing' }
CFPhysicsFrameMetrics >> preparationMilliseconds [ ^ preparationMilliseconds ]
{ #category : 'accessing' }
CFPhysicsFrameMetrics >> preparationMilliseconds: aNumber [ preparationMilliseconds := aNumber ]
{ #category : 'accessing' }
CFPhysicsFrameMetrics >> pipelineMilliseconds [ ^ pipelineMilliseconds ]
{ #category : 'accessing' }
CFPhysicsFrameMetrics >> pipelineMilliseconds: aNumber [ pipelineMilliseconds := aNumber ]
{ #category : 'accessing' }
CFPhysicsFrameMetrics >> boundaryMilliseconds [ ^ boundaryMilliseconds ]
{ #category : 'accessing' }
CFPhysicsFrameMetrics >> boundaryMilliseconds: aNumber [ boundaryMilliseconds := aNumber ]
{ #category : 'accessing' }
CFPhysicsFrameMetrics >> totalMilliseconds [ ^ totalMilliseconds ]
{ #category : 'accessing' }
CFPhysicsFrameMetrics >> totalMilliseconds: aNumber [ totalMilliseconds := aNumber ]
{ #category : 'accessing' }
CFPhysicsFrameMetrics >> bodyCount [ ^ bodyCount ]
{ #category : 'accessing' }
CFPhysicsFrameMetrics >> bodyCount: anInteger [ bodyCount := anInteger ]
{ #category : 'accessing' }
CFPhysicsFrameMetrics >> activeBodyCount [ ^ activeBodyCount ]
{ #category : 'accessing' }
CFPhysicsFrameMetrics >> activeBodyCount: anInteger [ activeBodyCount := anInteger ]
{ #category : 'accessing' }
CFPhysicsFrameMetrics >> sleepingBodyCount [ ^ bodyCount - activeBodyCount ]
{ #category : 'accessing' }
CFPhysicsFrameMetrics >> contactCount [ ^ contactCount ]
{ #category : 'accessing' }
CFPhysicsFrameMetrics >> contactCount: anInteger [ contactCount := anInteger ]
{ #category : 'accessing' }
CFPhysicsFrameMetrics >> constraintCount [ ^ constraintCount ]
{ #category : 'accessing' }
CFPhysicsFrameMetrics >> constraintCount: anInteger [ constraintCount := anInteger ]
{ #category : 'accessing' }
CFPhysicsFrameMetrics >> jointCount [ ^ jointCount ]
{ #category : 'accessing' }
CFPhysicsFrameMetrics >> jointCount: anInteger [ jointCount := anInteger ]
{ #category : 'accessing' }
CFPhysicsFrameMetrics >> stageExecutions [ ^ stageExecutions ifNil: [ #() ] ]
{ #category : 'accessing' }
CFPhysicsFrameMetrics >> stageExecutions: aCollection [ stageExecutions := aCollection asArray ]
{ #category : 'accessing' }
CFPhysicsFrameMetrics >> durationForStageNamed: aString [
	^ self stageExecutions
		detect: [ :each | each name asString = aString ]
		ifFound: [ :each | each durationMilliseconds ]
		ifNone: [ nil ]
]

{ #category : 'derived metrics' }
CFPhysicsFrameMetrics >> stageMilliseconds [
	^ self stageExecutions
		inject: 0.0
		into: [ :sum :each | sum + (each durationMilliseconds ifNil: [ 0.0 ]) ]
]

{ #category : 'derived metrics' }
CFPhysicsFrameMetrics >> unaccountedMilliseconds [
	^ (totalMilliseconds
		- membershipMilliseconds
		- preparationMilliseconds
		- pipelineMilliseconds
		- boundaryMilliseconds) max: 0.0
]
