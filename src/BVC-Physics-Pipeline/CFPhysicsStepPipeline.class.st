"
I coordinate the ordered stages that solve a captured world state. I produce a validated world solution without presenting or committing it to the live world.
"

Class {
	#name : 'CFPhysicsStepPipeline',
	#superclass : 'Object',
	#instVars : [ 'stages' ],
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
}

{ #category : 'instance creation' }
CFPhysicsStepPipeline class >> manifoldGenerator: aManifoldGenerator [
	| sleepBehaviour |
	sleepBehaviour := CFPhysicsIslandSleepStage new.
	^ self new
		stages: {
			CFPhysicsVelocityIntegrationStage new.
			CFPhysicsPairFinderStage new.
			CFPhysicsContactUpdateStage manifoldGenerator: aManifoldGenerator.
			CFPhysicsConstraintPreparationStage new.
			CFPhysicsIslandBuilderStage new.
			CFPhysicsIslandWakeStage new sleepBehaviour: sleepBehaviour; yourself.
			CFPhysicsIslandSolverStage new.
			CFPhysicsPostSolveStage new.
			CFPhysicsContinuousStepStage new
				manifoldGenerator: aManifoldGenerator;
				yourself.
			CFPhysicsIslandSleepingStage new sleepBehaviour: sleepBehaviour; yourself.
			CFPhysicsContactEventStage new };
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

{ #category : 'broadphase' }
CFPhysicsStepPipeline >> touchBroadphaseProxyFor: aBody [
	(self stageOfType: CFPhysicsPairFinderStage) pairFinder touchProxyForBody: aBody.
	^ self
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
	^ self
		stepBodies: bodies
		fromContacts: previousContacts
		joints: joints
		collisionSuppressedBodyPairs: collisionSuppressedBodyPairs
		step: step
		gravity: gravityVector
		restitutionThreshold: restitutionThreshold
		telemetry: false
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
	^ self
		stepBodies: bodies
		fromContacts: previousContacts
		joints: joints
		collisionSuppressedBodyPairs: collisionSuppressedBodyPairs
		step: step
		gravity: gravityVector
		restitutionThreshold: restitutionThreshold
		telemetry: true
]

{ #category : 'private - stepping' }
CFPhysicsStepPipeline >> stepBodies: bodies fromContacts: previousContacts joints: joints collisionSuppressedBodyPairs: collisionSuppressedBodyPairs step: step gravity: gravityVector restitutionThreshold: restitutionThreshold telemetry: telemetryEnabled [
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
	self executeStagesOn: result telemetry: telemetryEnabled.
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
		collect: [ :joint | { joint bodyA. joint bodyB } ]
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
		islandBodyGroups: aWorldState islandBodyGroups;
		yourself
]

{ #category : 'solving' }
CFPhysicsStepPipeline >> solve: aWorldState [
	^ self solve: aWorldState telemetry: false
]

{ #category : 'solving' }
CFPhysicsStepPipeline >> solveWithTelemetry: aWorldState [
	^ ProcessTelemetry
		time: [ 'Pipeline' ]
		during: [ self solve: aWorldState telemetry: true ]
]

{ #category : 'private - solving' }
CFPhysicsStepPipeline >> solve: aWorldState telemetry: telemetryEnabled [
	| pipelineResult |
	pipelineResult := self newResultForWorldState: aWorldState.
	self executeStagesOn: pipelineResult telemetry: telemetryEnabled.
	^ self solutionFor: pipelineResult worldState: aWorldState
]

{ #category : 'private - solving' }
CFPhysicsStepPipeline >> solutionFor: pipelineResult worldState: aWorldState [
	^ (CFPhysicsWorldSolution pipelineResult: pipelineResult)
		world: aWorldState world;
		lifetimeGeneration: aWorldState lifetimeGeneration;
		topologyRevision: aWorldState topologyRevision;
		solveTicket: aWorldState solveTicket;
		visualState: (self visualStateFor: pipelineResult worldState: aWorldState);
		yourself
]

{ #category : 'private - solving' }
CFPhysicsStepPipeline >> executeStagesOn: pipelineResult telemetry: telemetryEnabled [
	stages do: [ :stage |
		| output |
		output := telemetryEnabled
			ifTrue: [
				ProcessTelemetry
					time: [ stage class name asString ]
					during: [ stage executeOnWithTelemetry: pipelineResult ] ]
			ifFalse: [ stage executeOn: pipelineResult ].
		pipelineResult recordStage: stage output: output ]
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


{ #category : 'broadphase' }
CFPhysicsStepPipeline >> resetBroadphaseProxiesFor: aBody [
	(self stageOfType: CFPhysicsPairFinderStage) pairFinder
		resetProxiesForBody: aBody.
	^ self
]

{ #category : 'private - solving' }
CFPhysicsStepPipeline >> visualStateFor: aPipelineResult worldState: aWorldState [
	| visualState |
	visualState := aWorldState calculationVisualState.
	visualState ifNil: [ ^ nil ].
	aPipelineResult contactResult visualStateMayHaveChanged ifFalse: [ ^ nil ].
	visualState updateFromContacts: aPipelineResult activeContacts.
	^ visualState
]

