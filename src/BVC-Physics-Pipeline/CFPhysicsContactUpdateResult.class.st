"
I represent the result of running the contact pipeline. I contain the candidate pairs and the resulting contact update batch.
"

Class {
	#name : 'CFPhysicsContactUpdateResult',
	#superclass : 'Object',
	#instVars : [ 'pairs', 'contactBatch' ],
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
}

{ #category : 'instance creation' }
CFPhysicsContactUpdateResult class >> pairs: pairs contactBatch: aContactBatch [
	^ self new
		pairs: pairs;
		contactBatch: aContactBatch;
		yourself
]

{ #category : 'accessing' }
CFPhysicsContactUpdateResult >> pairs [ ^ pairs ]

{ #category : 'accessing' }
CFPhysicsContactUpdateResult >> pairs: aCollection [ pairs := aCollection asArray ]

{ #category : 'accessing' }
CFPhysicsContactUpdateResult >> contactBatch [ ^ contactBatch ]

{ #category : 'accessing' }
CFPhysicsContactUpdateResult >> contactBatch: aContactBatch [ contactBatch := aContactBatch ]

{ #category : 'accessing' }
CFPhysicsContactUpdateResult >> contacts [ ^ contactBatch contacts ]

{ #category : 'accessing' }
CFPhysicsContactUpdateResult >> touchingContacts [ ^ contactBatch touchingContacts ]

{ #category : 'accessing' }
CFPhysicsContactUpdateResult >> activeContacts [ ^ contactBatch touchingContacts ]

{ #category : 'accessing' }
CFPhysicsContactUpdateResult >> beganContacts [ ^ contactBatch beganContacts ]

{ #category : 'accessing' }
CFPhysicsContactUpdateResult >> continuedContacts [ ^ contactBatch continuedContacts ]

{ #category : 'accessing' }
CFPhysicsContactUpdateResult >> endedContacts [ ^ contactBatch endedContacts ]
