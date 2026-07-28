Class {
	#name : 'CFPhysicsWorldSolution',
	#superclass : 'Object',
	#instVars : [ 'pipelineResult', 'explicitlyContainedBodies', 'world', 'lifetimeGeneration', 'topologyRevision', 'solveTicket', 'visualState' ],
	#category : 'BVC-Foundation-Physics-Core',
	#package : 'BVC-Foundation-Physics-Core'
}

{ #category : 'instance creation' }
CFPhysicsWorldSolution class >> pipelineResult: aPipelineResult explicitlyContainedBodies: aCollection [
	^ self new
		pipelineResult: aPipelineResult;
		explicitlyContainedBodies: aCollection;
		yourself
]

{ #category : 'initialization' }
CFPhysicsWorldSolution >> initialize [
	super initialize.
	explicitlyContainedBodies := #()
]

{ #category : 'accessing' }
CFPhysicsWorldSolution >> pipelineResult [ ^ pipelineResult ]

{ #category : 'accessing' }
CFPhysicsWorldSolution >> pipelineResult: anObject [ pipelineResult := anObject ]

{ #category : 'accessing' }
CFPhysicsWorldSolution >> explicitlyContainedBodies [ ^ explicitlyContainedBodies ]

{ #category : 'accessing' }
CFPhysicsWorldSolution >> explicitlyContainedBodies: aCollection [
	explicitlyContainedBodies := aCollection asArray
]


{ #category : 'accessing - solution identity' }
CFPhysicsWorldSolution >> world [ ^ world ]

{ #category : 'accessing - solution identity' }
CFPhysicsWorldSolution >> world: aWorld [ world := aWorld ]

{ #category : 'accessing - solution identity' }
CFPhysicsWorldSolution >> lifetimeGeneration [ ^ lifetimeGeneration ]

{ #category : 'accessing - solution identity' }
CFPhysicsWorldSolution >> lifetimeGeneration: anInteger [ lifetimeGeneration := anInteger ]

{ #category : 'accessing - solution identity' }
CFPhysicsWorldSolution >> topologyRevision [ ^ topologyRevision ]

{ #category : 'accessing - solution identity' }
CFPhysicsWorldSolution >> topologyRevision: anInteger [ topologyRevision := anInteger ]

{ #category : 'accessing - solution identity' }
CFPhysicsWorldSolution >> solveTicket [ ^ solveTicket ]

{ #category : 'accessing - solution identity' }
CFPhysicsWorldSolution >> solveTicket: anInteger [ solveTicket := anInteger ]


{ #category : 'accessing - visual state' }
CFPhysicsWorldSolution >> visualState [
	^ visualState
]

{ #category : 'accessing - visual state' }
CFPhysicsWorldSolution >> visualState: aVisualState [
	visualState := aVisualState
]
