"
I carry the mutable working state of one pipeline execution. I connect stage outputs, step-local bodies, contacts, constraints, islands and observable results.
"

Class {
	#name : 'CFPhysicsStepPipelineResult',
	#superclass : 'Object',
	#instVars : [ 'step', 'bodies', 'previousContacts', 'calculationContacts', 'pairs', 'contactResult', 'bodyStates', 'constraints', 'contactConstraints', 'solverConstraints', 'joints', 'islands', 'solver', 'sleepDecisions', 'contactSolveResults', 'hitEvents', 'contactEvents', 'orderedBodyStates', 'gravity', 'restitutionThreshold', 'stageExecutions', 'continuousStepResult', 'continuousSensorContacts', 'jointConstraints', 'collisionSuppressedBodyPairs', 'islandBodyGroups' ],
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
}

{ #category : 'initialization' }
CFPhysicsStepPipelineResult >> initialize [
	super initialize.
	bodies := #().
	previousContacts := #().
	calculationContacts := #().
	pairs := #().
	constraints := #().
	contactConstraints := #().
	solverConstraints := #().
	joints := #().
	islands := #().
	sleepDecisions := #().
	contactSolveResults := #().
	hitEvents := #().
	contactEvents := #().
	stageExecutions := OrderedCollection new.
	orderedBodyStates := #().
	continuousStepResult := nil.
	continuousSensorContacts := #().
	jointConstraints := #().
	collisionSuppressedBodyPairs := #().
	islandBodyGroups := #()
]


{ #category : 'accessing' }
CFPhysicsStepPipelineResult >> collisionSuppressedBodyPairs [ ^ collisionSuppressedBodyPairs ]

{ #category : 'accessing' }
CFPhysicsStepPipelineResult >> collisionSuppressedBodyPairs: aCollection [
	collisionSuppressedBodyPairs := aCollection asArray
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
CFPhysicsStepPipelineResult >> calculationContacts [ ^ calculationContacts ]
{ #category : 'accessing' }
CFPhysicsStepPipelineResult >> calculationContacts: aCollection [ calculationContacts := aCollection asArray ]
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
CFPhysicsStepPipelineResult >> orderedBodyStates [ ^ orderedBodyStates ]
{ #category : 'accessing' }
CFPhysicsStepPipelineResult >> orderedBodyStates: aCollection [ orderedBodyStates := aCollection asArray ]
{ #category : 'accessing' }
CFPhysicsStepPipelineResult >> constraints [
	"Compatibility name for prepared joint constraints. Contacts remain separate, matching Box2D's solver model."
	^ constraints
]
{ #category : 'accessing' }
CFPhysicsStepPipelineResult >> constraints: aCollection [ constraints := aCollection asArray ]

{ #category : 'accessing' }
CFPhysicsStepPipelineResult >> contactConstraints [
	^ contactConstraints
]
{ #category : 'accessing' }
CFPhysicsStepPipelineResult >> contactConstraints: aCollection [ contactConstraints := aCollection asArray ]

{ #category : 'accessing' }
CFPhysicsStepPipelineResult >> solverConstraints [
	"Private combined sequence consumed by island construction and solving."
	^ solverConstraints
]
{ #category : 'accessing' }
CFPhysicsStepPipelineResult >> solverConstraints: aCollection [ solverConstraints := aCollection asArray ]

{ #category : 'accessing' }
CFPhysicsStepPipelineResult >> jointConstraints [ ^ jointConstraints ]
{ #category : 'accessing' }
CFPhysicsStepPipelineResult >> jointConstraints: aCollection [ jointConstraints := aCollection asArray ]

{ #category : 'committing' }
CFPhysicsStepPipelineResult >> commitBodyStates [
	orderedBodyStates do: #commit
]

{ #category : 'committing' }
CFPhysicsStepPipelineResult >> commitJointConstraints [
	jointConstraints do: #writeImpulsesBack
]

{ #category : 'accessing' }
CFPhysicsStepPipelineResult >> joints [ ^ joints ]
{ #category : 'accessing' }
CFPhysicsStepPipelineResult >> joints: aCollection [ joints := aCollection asArray ]
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
CFPhysicsStepPipelineResult >> contacts [ ^ contactResult contacts ]
{ #category : 'contacts' }
CFPhysicsStepPipelineResult >> touchingContacts [ ^ contactResult touchingContacts ]
{ #category : 'contacts' }
CFPhysicsStepPipelineResult >> activeContacts [ ^ contactResult touchingContacts ]
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

{ #category : 'continuous collision' }
CFPhysicsStepPipelineResult >> continuousSensorContacts [ ^ continuousSensorContacts ]

{ #category : 'continuous collision' }
CFPhysicsStepPipelineResult >> continuousSensorContacts: aCollection [ continuousSensorContacts := aCollection asArray ]

{ #category : 'accessing - islands' }
CFPhysicsStepPipelineResult >> islandBodyGroups [
	^ islandBodyGroups
]

{ #category : 'accessing - islands' }
CFPhysicsStepPipelineResult >> islandBodyGroups: aCollection [
	islandBodyGroups := aCollection collect: [ :group | group asArray ]
]

