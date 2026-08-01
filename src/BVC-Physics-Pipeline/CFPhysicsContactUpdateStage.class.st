"
I update the world's contacts from the current collision pairs. I also wake bodies when ending contacts require the sleeping state to be reconsidered.
"

Class {
	#name : 'CFPhysicsContactUpdateStage',
	#superclass : 'CFPhysicsStepStage',
	#instVars : [ 'contactUpdater' ],
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
}

{ #category : 'instance creation' }
CFPhysicsContactUpdateStage class >> manifoldBuilder: aBlock [
	^ self new
		contactUpdater: (CFPhysicsContactUpdater manifoldBuilder: aBlock);
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
		bodyStates: aStepResult bodyStates.
	self
		wakeBodiesForEndedContacts: batch endedContacts
		bodyStates: aStepResult bodyStates.
	contactResult := CFPhysicsContactPipelineResult
		pairs: aStepResult pairs
		contactBatch: batch.
	aStepResult contactResult: contactResult.
	^ contactResult
]

{ #category : 'private - waking' }
CFPhysicsContactUpdateStage >> wakeBodiesForEndedContacts: contacts bodyStates: bodyStates [
	contacts do: [ :contact |
		(bodyStates at: contact firstBody) wake.
		(bodyStates at: contact secondBody) wake ]
]
