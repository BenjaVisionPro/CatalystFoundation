Class {
	#name : 'CFPhysicsStepPipelineResult',
	#superclass : 'Object',
	#instVars : [ 'step', 'bodies', 'previousContacts', 'pairs', 'contactResult', 'bodyStates', 'constraints', 'islands', 'solver', 'sleepDecisions', 'contactSolveResults', 'hitEvents', 'contactEvents', 'gravity', 'restitutionThreshold', 'stageExecutions', 'continuousStepResult' ],
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'initialization' }
CFPhysicsStepPipelineResult >> initialize [
	super initialize.
	bodies := #().
	previousContacts := #().
	pairs := #().
	constraints := #().
	islands := #().
	sleepDecisions := #().
	contactSolveResults := #().
	hitEvents := #().
	contactEvents := #().
	stageExecutions := OrderedCollection new.
	continuousStepResult := nil
]

{ #category : 'accessing' }
CFPhysicsStepPipelineResult >> step [ ^ step ]
{ #category : 'accessing' }
CFPhysicsStepPipelineResult >> step: anObject [ step := anObject ]
{ #category : 'accessing' }
CFPhysicsStepPipelineResult >> bodies [ ^ bodies ]
{ #category : 'accessing' }
CFPhysicsStepPipelineResult >> bodies: aCollection [ bodies := aCollection asArray ]
{ #category : 'accessing' }
CFPhysicsStepPipelineResult >> previousContacts [ ^ previousContacts ]
{ #category : 'accessing' }
CFPhysicsStepPipelineResult >> previousContacts: aCollection [ previousContacts := aCollection asArray ]
{ #category : 'accessing' }
CFPhysicsStepPipelineResult >> pairs [ ^ pairs ]
{ #category : 'accessing' }
CFPhysicsStepPipelineResult >> pairs: aCollection [ pairs := aCollection asArray ]
{ #category : 'accessing' }
CFPhysicsStepPipelineResult >> contactResult [ ^ contactResult ]
{ #category : 'accessing' }
CFPhysicsStepPipelineResult >> contactResult: anObject [ contactResult := anObject ]
{ #category : 'accessing' }
CFPhysicsStepPipelineResult >> bodyStates [ ^ bodyStates ]
{ #category : 'accessing' }
CFPhysicsStepPipelineResult >> bodyStates: aDictionary [ bodyStates := aDictionary ]
{ #category : 'accessing' }
CFPhysicsStepPipelineResult >> constraints [ ^ constraints ]
{ #category : 'accessing' }
CFPhysicsStepPipelineResult >> constraints: aCollection [ constraints := aCollection asArray ]
{ #category : 'accessing' }
CFPhysicsStepPipelineResult >> islands [ ^ islands ]
{ #category : 'accessing' }
CFPhysicsStepPipelineResult >> islands: aCollection [ islands := aCollection asArray ]
{ #category : 'accessing' }
CFPhysicsStepPipelineResult >> solver [ ^ solver ]
{ #category : 'accessing' }
CFPhysicsStepPipelineResult >> solver: anObject [ solver := anObject ]
{ #category : 'accessing' }
CFPhysicsStepPipelineResult >> sleepDecisions [ ^ sleepDecisions ]
{ #category : 'accessing' }
CFPhysicsStepPipelineResult >> sleepDecisions: aCollection [ sleepDecisions := aCollection asArray ]

{ #category : 'accessing' }
CFPhysicsStepPipelineResult >> contactSolveResults [ ^ contactSolveResults ]
{ #category : 'accessing' }
CFPhysicsStepPipelineResult >> contactSolveResults: aCollection [ contactSolveResults := aCollection asArray ]
{ #category : 'accessing' }
CFPhysicsStepPipelineResult >> hitEvents [ ^ hitEvents ]
{ #category : 'accessing' }
CFPhysicsStepPipelineResult >> hitEvents: aCollection [ hitEvents := aCollection asArray ]

{ #category : 'accessing' }
CFPhysicsStepPipelineResult >> contactEvents [ ^ contactEvents ]
{ #category : 'accessing' }
CFPhysicsStepPipelineResult >> contactEvents: aCollection [ contactEvents := aCollection asArray ]
{ #category : 'accessing' }
CFPhysicsStepPipelineResult >> gravity [ ^ gravity ]
{ #category : 'accessing' }
CFPhysicsStepPipelineResult >> gravity: aPoint [ gravity := aPoint ]
{ #category : 'accessing' }
CFPhysicsStepPipelineResult >> restitutionThreshold [ ^ restitutionThreshold ]
{ #category : 'accessing' }
CFPhysicsStepPipelineResult >> restitutionThreshold: aNumber [ restitutionThreshold := aNumber ]

{ #category : 'stages' }
CFPhysicsStepPipelineResult >> recordStage: aStage output: anObject [
	stageExecutions add: (CFPhysicsStepStageExecution stage: aStage output: anObject)
]

{ #category : 'stages' }
CFPhysicsStepPipelineResult >> stageExecutions [ ^ stageExecutions asArray ]

{ #category : 'stages' }
CFPhysicsStepPipelineResult >> executedStages [
	^ self stageExecutions collect: #stage
]

{ #category : 'stages' }
CFPhysicsStepPipelineResult >> executionForStageType: aStageClass [
	^ self stageExecutions
		detect: [ :execution | execution stage isKindOf: aStageClass ]
		ifNone: [ nil ]
]

{ #category : 'sleeping' }
CFPhysicsStepPipelineResult >> sleptIslands [
	^ (sleepDecisions select: [ :decision | decision slept ])
		collect: [ :decision | decision island ]
]

{ #category : 'sleeping' }
CFPhysicsStepPipelineResult >> wokenBodies [
	^ sleepDecisions flatCollect: [ :decision | decision wokeBodies ]
]

{ #category : 'contacts' }
CFPhysicsStepPipelineResult >> activeContacts [ ^ contactResult activeContacts ]
{ #category : 'contacts' }
CFPhysicsStepPipelineResult >> beganContacts [ ^ contactResult beganContacts ]
{ #category : 'contacts' }
CFPhysicsStepPipelineResult >> continuedContacts [ ^ contactResult continuedContacts ]
{ #category : 'contacts' }
CFPhysicsStepPipelineResult >> endedContacts [ ^ contactResult endedContacts ]
{ #category : 'contacts' }
CFPhysicsStepPipelineResult >> contactBeganEvents [
	^ contactEvents select: [ :event | event began ]
]
{ #category : 'contacts' }
CFPhysicsStepPipelineResult >> contactEndedEvents [
	^ contactEvents select: [ :event | event ended ]
]


{ #category : 'continuous collision' }
CFPhysicsStepPipelineResult >> continuousStepResult [ ^ continuousStepResult ]

{ #category : 'continuous collision' }
CFPhysicsStepPipelineResult >> continuousStepResult: anObject [ continuousStepResult := anObject ]

{ #category : 'continuous collision' }
CFPhysicsStepPipelineResult >> hasContinuousImpact [
	^ continuousStepResult notNil and: [ continuousStepResult hasImpact ]
]
