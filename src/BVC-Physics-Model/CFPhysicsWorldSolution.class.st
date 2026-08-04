"
I represent the solved result of one captured world state.

My responsibility is to carry pipeline output and validation identity back to the world for commit.
"
Class {
	#name : 'CFPhysicsWorldSolution',
	#superclass : 'Object',
	#instVars : [ 'pipelineResult', 'world', 'lifetimeGeneration', 'topologyRevision', 'solveTicket', 'visualState' ],
	#category : 'BVC-Physics-Model',
	#package : 'BVC-Physics-Model'
}

{ #category : 'instance creation' }
CFPhysicsWorldSolution class >> pipelineResult: aPipelineResult [
	^ self new
		pipelineResult: aPipelineResult;
		yourself
]

{ #category : 'accessing' }
CFPhysicsWorldSolution >> pipelineResult [ ^ pipelineResult ]

{ #category : 'accessing' }
CFPhysicsWorldSolution >> pipelineResult: anObject [ pipelineResult := anObject ]

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
