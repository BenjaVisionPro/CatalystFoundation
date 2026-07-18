Class {
	#name : 'CFPhysicsContactPipelineResult',
	#superclass : 'Object',
	#instVars : [ 'pairs', 'contactBatch' ],
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'instance creation' }
CFPhysicsContactPipelineResult class >> pairs: pairs contactBatch: aContactBatch [
	^ self new
		pairs: pairs;
		contactBatch: aContactBatch;
		yourself
]

{ #category : 'accessing' }
CFPhysicsContactPipelineResult >> pairs [ ^ pairs ]

{ #category : 'accessing' }
CFPhysicsContactPipelineResult >> pairs: aCollection [ pairs := aCollection asArray ]

{ #category : 'accessing' }
CFPhysicsContactPipelineResult >> contactBatch [ ^ contactBatch ]

{ #category : 'accessing' }
CFPhysicsContactPipelineResult >> contactBatch: aContactBatch [ contactBatch := aContactBatch ]

{ #category : 'accessing' }
CFPhysicsContactPipelineResult >> activeContacts [ ^ contactBatch activeContacts ]

{ #category : 'accessing' }
CFPhysicsContactPipelineResult >> beganContacts [ ^ contactBatch beganContacts ]

{ #category : 'accessing' }
CFPhysicsContactPipelineResult >> continuedContacts [ ^ contactBatch continuedContacts ]

{ #category : 'accessing' }
CFPhysicsContactPipelineResult >> endedContacts [ ^ contactBatch endedContacts ]
