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
			CFPhysicsVelocityIntegrationStage new.
			CFPhysicsPairFinderStage new.
			CFPhysicsContactUpdateStage manifoldBuilder: aBlock.
			CFPhysicsConstraintPreparationStage new.
			CFPhysicsIslandBuilderStage new.
			CFPhysicsIslandWakeStage new sleepBehaviour: sleepBehaviour; yourself.
			CFPhysicsIslandSolverStage new.
			CFPhysicsPostSolveStage new.
			CFPhysicsContinuousStepStage new.
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
	^ self
		stepBodies: bodies
		fromContacts: previousContacts
		joints: #()
		step: step
		gravity: gravityVector
		restitutionThreshold: restitutionThreshold
]

{ #category : 'stepping' }
CFPhysicsStepPipeline >> stepBodies: bodies fromContacts: previousContacts joints: joints step: step gravity: gravityVector restitutionThreshold: restitutionThreshold [
	^ self
		stepBodies: bodies
		fromContacts: previousContacts
		joints: joints
		collisionSuppressedBodyPairs: (self collisionSuppressedBodyPairsFrom: joints)
		step: step
		gravity: gravityVector
		restitutionThreshold: restitutionThreshold
]

{ #category : 'stepping' }
CFPhysicsStepPipeline >> stepBodies: bodies fromContacts: previousContacts joints: joints collisionSuppressedBodyPairs: collisionSuppressedBodyPairs step: step gravity: gravityVector restitutionThreshold: restitutionThreshold [
	| result |
	result := self
		newResultForBodies: bodies
		fromContacts: previousContacts
		joints: joints
		collisionSuppressedBodyPairs: collisionSuppressedBodyPairs
		step: step
		gravity: gravityVector
		restitutionThreshold: restitutionThreshold.
	CFPhysicsBodyStateCaptureStage new executeOn: result.
	stages do: [ :stage |
		result recordStage: stage output: (stage executeOn: result) ].
	^ result
]

{ #category : 'stepping' }
CFPhysicsStepPipeline >> stepBodiesWithTelemetry: bodies fromContacts: previousContacts joints: joints step: step gravity: gravityVector restitutionThreshold: restitutionThreshold [
	^ self
		stepBodiesWithTelemetry: bodies
		fromContacts: previousContacts
		joints: joints
		collisionSuppressedBodyPairs: (self collisionSuppressedBodyPairsFrom: joints)
		step: step
		gravity: gravityVector
		restitutionThreshold: restitutionThreshold
]

{ #category : 'stepping' }
CFPhysicsStepPipeline >> stepBodiesWithTelemetry: bodies fromContacts: previousContacts joints: joints collisionSuppressedBodyPairs: collisionSuppressedBodyPairs step: step gravity: gravityVector restitutionThreshold: restitutionThreshold [
	| result |
	result := self
		newResultForBodies: bodies
		fromContacts: previousContacts
		joints: joints
		collisionSuppressedBodyPairs: collisionSuppressedBodyPairs
		step: step
		gravity: gravityVector
		restitutionThreshold: restitutionThreshold.
	CFPhysicsBodyStateCaptureStage new executeOn: result.
	stages do: [ :stage |
		| output |
		output := ProcessTelemetry
			time: [ stage class name asString ]
			during: [ stage executeOnWithTelemetry: result ].
		result recordStage: stage output: output ].
	^ result
]

{ #category : 'private - stepping' }
CFPhysicsStepPipeline >> newResultForBodies: bodies fromContacts: previousContacts joints: joints step: step gravity: gravityVector restitutionThreshold: restitutionThreshold [
	^ self
		newResultForBodies: bodies
		fromContacts: previousContacts
		joints: joints
		collisionSuppressedBodyPairs: (self collisionSuppressedBodyPairsFrom: joints)
		step: step
		gravity: gravityVector
		restitutionThreshold: restitutionThreshold
]

{ #category : 'private - stepping' }
CFPhysicsStepPipeline >> newResultForBodies: bodies fromContacts: previousContacts joints: joints collisionSuppressedBodyPairs: collisionSuppressedBodyPairs step: step gravity: gravityVector restitutionThreshold: restitutionThreshold [
	^ CFPhysicsStepPipelineResult new
		step: step;
		bodies: (bodies asArray sorted: [ :left :right | left sequence < right sequence ]);
		previousContacts: previousContacts;
		collisionSuppressedBodyPairs: collisionSuppressedBodyPairs;
		joints: (joints asArray sorted: [ :left :right |
			left orderingKey = right orderingKey
				ifTrue: [ left class name asString < right class name asString ]
				ifFalse: [ left orderingKey < right orderingKey ] ]);
		gravity: gravityVector;
		restitutionThreshold: restitutionThreshold;
		yourself
]


{ #category : 'private - collision filtering' }
CFPhysicsStepPipeline >> collisionSuppressedBodyPairsFrom: joints [
	^ (joints select: [ :joint |
		joint isActive and: [ joint collideConnected not ] ])
		collect: [ :joint | { joint firstBody. joint secondBody } ]
]

{ #category : 'private - stepping' }
CFPhysicsStepPipeline >> newResultForWorldState: aWorldState [
	^ (self
		newResultForBodies: aWorldState bodies
		fromContacts: aWorldState contacts
		joints: aWorldState joints
		collisionSuppressedBodyPairs: aWorldState collisionSuppressedBodyPairs
		step: aWorldState step
		gravity: aWorldState gravity
		restitutionThreshold: aWorldState restitutionThreshold)
		bodyStates: aWorldState bodyStates;
		calculationContacts: aWorldState calculationContacts;
		orderedBodyStates: aWorldState orderedBodyStates;
		yourself
]

{ #category : 'solving' }
CFPhysicsStepPipeline >> solve: aWorldState [
	| pipelineResult |
	pipelineResult := self newResultForWorldState: aWorldState.
	stages do: [ :stage |
		pipelineResult recordStage: stage output: (stage executeOn: pipelineResult) ].
	aWorldState calculationVisualState ifNotNil: [ :visualState |
		visualState updateFromContacts: pipelineResult activeContacts ].
	^ (CFPhysicsWorldSolution
		pipelineResult: pipelineResult
		explicitlyContainedBodies: aWorldState explicitlyContainedBodies)
		world: aWorldState world;
		lifetimeGeneration: aWorldState lifetimeGeneration;
		topologyRevision: aWorldState topologyRevision;
		solveTicket: aWorldState solveTicket;
		visualState: aWorldState calculationVisualState;
		yourself
]

{ #category : 'solving' }
CFPhysicsStepPipeline >> solveWithTelemetry: aWorldState [
	| pipelineResult |
	pipelineResult := self newResultForWorldState: aWorldState.
	stages do: [ :stage |
		| output |
		output := ProcessTelemetry
			time: [ stage class name asString ]
			during: [ stage executeOnWithTelemetry: pipelineResult ].
		pipelineResult recordStage: stage output: output ].
	aWorldState calculationVisualState ifNotNil: [ :visualState |
		visualState updateFromContacts: pipelineResult activeContacts ].
	^ (CFPhysicsWorldSolution
		pipelineResult: pipelineResult
		explicitlyContainedBodies: aWorldState explicitlyContainedBodies)
		world: aWorldState world;
		lifetimeGeneration: aWorldState lifetimeGeneration;
		topologyRevision: aWorldState topologyRevision;
		solveTicket: aWorldState solveTicket;
		visualState: aWorldState calculationVisualState;
		yourself
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
