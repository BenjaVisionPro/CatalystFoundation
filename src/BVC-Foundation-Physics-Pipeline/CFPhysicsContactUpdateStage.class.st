Class {
	#name : 'CFPhysicsContactUpdateStage',
	#superclass : 'CFPhysicsStepStage',
	#instVars : [ 'contactUpdater' ],
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
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
	| batch contactResult impactContacts |
	impactContacts := aStepResult continuousSensorContacts asOrderedCollection.
	aStepResult hasContinuousImpact ifTrue: [
		impactContacts addAll: (aStepResult continuousStepResult impactSolveResults collect: #contact) ].
	batch := aStepResult hasContinuousImpact
		ifTrue: [
			contactUpdater
				updateImpactContacts: impactContacts
				fromContacts: aStepResult previousContacts ]
		ifFalse: [
			contactUpdater
				updatePairs: aStepResult pairs
				includingImpactContacts: impactContacts
				fromContacts: aStepResult previousContacts ].
	contactResult := CFPhysicsContactPipelineResult
		pairs: aStepResult pairs
		contactBatch: batch.
	aStepResult contactResult: contactResult.
	^ contactResult
]
