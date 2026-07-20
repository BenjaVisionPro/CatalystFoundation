Class {
	#name : 'CFPhysicsStepPipeline',
	#superclass : 'Object',
	#instVars : [ 'stages' ],
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'instance creation' }
CFPhysicsStepPipeline class >> manifoldBuilder: aBlock [
	| sleepBehaviour |
	sleepBehaviour := CFPhysicsIslandSleepStage new.
	^ self new
		stages: {
			CFPhysicsBodyStateCaptureStage new.
			CFPhysicsVelocityIntegrationStage new.
			CFPhysicsPairFinderStage new.
			CFPhysicsContactUpdateStage manifoldBuilder: aBlock.
			CFPhysicsConstraintPreparationStage new.
			CFPhysicsIslandBuilderStage new.
			CFPhysicsIslandWakeStage new sleepBehaviour: sleepBehaviour; yourself.
			CFPhysicsIslandSolverStage new.
			CFPhysicsPostSolveStage new.
			CFPhysicsIslandSleepingStage new sleepBehaviour: sleepBehaviour; yourself.
			CFPhysicsContactEventsStage new };
		yourself
]

{ #category : 'initialization' }
CFPhysicsStepPipeline >> initialize [
	super initialize.
	stages := #()
]

{ #category : 'accessing' }
CFPhysicsStepPipeline >> stages [ ^ stages ]

{ #category : 'accessing' }
CFPhysicsStepPipeline >> stages: aCollection [
	stages := aCollection asArray
]

{ #category : 'accessing' }
CFPhysicsStepPipeline >> stageOfType: aStageClass [
	^ stages
		detect: [ :stage | stage isKindOf: aStageClass ]
		ifNone: [ self error: 'The step pipeline does not contain ', aStageClass name asString ]
]

{ #category : 'accessing' }
CFPhysicsStepPipeline >> sleepStage [
	^ self stageOfType: CFPhysicsIslandSleepingStage
]

{ #category : 'accessing' }
CFPhysicsStepPipeline >> sleepConfiguration [
	^ self sleepStage configuration
]

{ #category : 'accessing' }
CFPhysicsStepPipeline >> sleepConfiguration: aConfiguration [
	self sleepStage configuration: aConfiguration
]

{ #category : 'stepping' }
CFPhysicsStepPipeline >> stepBodies: bodies fromContacts: previousContacts step: step gravity: gravityVector restitutionThreshold: restitutionThreshold [
	| result |
	result := CFPhysicsStepPipelineResult new
		step: step;
		bodies: (bodies asArray sorted: [ :left :right | left sequence < right sequence ]);
		previousContacts: previousContacts;
		gravity: gravityVector;
		restitutionThreshold: restitutionThreshold;
		yourself.
	stages do: [ :stage |
		| output |
		output := stage executeOn: result.
		result recordStage: stage output: output ].
	^ result
]

{ #category : 'accessing' }
CFPhysicsStepPipeline >> postSolveStage [
	^ self stageOfType: CFPhysicsPostSolveStage
]

{ #category : 'accessing' }
CFPhysicsStepPipeline >> hitEventThreshold [
	^ self postSolveStage hitEventThreshold
]

{ #category : 'accessing' }
CFPhysicsStepPipeline >> hitEventThreshold: aNumber [
	self postSolveStage hitEventThreshold: aNumber
]
