Class {
	#name : 'CFPhysicsWorldSolution',
	#superclass : 'Object',
	#instVars : [ 'pipelineResult', 'explicitlyContainedBodies' ],
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
