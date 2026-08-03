"
I update persistent contacts from the current broadphase pairs and classify touching transitions.
"

Class {
	#name : 'CFPhysicsContactUpdateStage',
	#superclass : 'CFPhysicsStepStage',
	#instVars : [ 'contactUpdater' ],
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
}

{ #category : 'instance creation' }
CFPhysicsContactUpdateStage class >> manifoldGenerator: aManifoldGenerator [
	^ self new
		contactUpdater: (CFPhysicsContactUpdater manifoldGenerator: aManifoldGenerator);
		yourself
]

{ #category : 'accessing' }
CFPhysicsContactUpdateStage >> contactUpdater [ ^ contactUpdater ]
{ #category : 'accessing' }
CFPhysicsContactUpdateStage >> contactUpdater: anObject [ contactUpdater := anObject ]

{ #category : 'executing' }
CFPhysicsContactUpdateStage >> executeOn: aStepResult [
	| batch contactResult |
	batch := contactUpdater
		updatePairs: aStepResult pairs
		includingImpactContacts: #()
		fromContacts: aStepResult previousContacts
		reusingContacts: aStepResult calculationContacts
		bodyStates: aStepResult bodyStates
		speculativeDistance: aStepResult step speculativeDistance.
	contactResult := CFPhysicsContactUpdateResult
		pairs: aStepResult pairs
		contactBatch: batch.
	aStepResult contactResult: contactResult.
	^ contactResult
]
