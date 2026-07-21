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
	| batch contactResult impactContacts pairs |
	impactContacts := aStepResult continuousSensorContacts asOrderedCollection.
	aStepResult hasContinuousImpact ifTrue: [
		impactContacts addAll: (aStepResult continuousStepResult impactSolveResults collect: #contact) ].
	pairs := aStepResult pairs asOrderedCollection.
	impactContacts do: [ :each |
		(pairs includes: each pair) ifFalse: [ pairs add: each pair ] ].
	aStepResult pairs: pairs.
	batch := contactUpdater
		updatePairs: pairs
		includingImpactContacts: impactContacts
		fromContacts: aStepResult previousContacts.
	contactResult := CFPhysicsContactPipelineResult
		pairs: pairs
		contactBatch: batch.
	aStepResult contactResult: contactResult.
	^ contactResult
]
