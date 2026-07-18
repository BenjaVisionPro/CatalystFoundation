Class {
	#name : 'CFPhysicsContactPipeline',
	#superclass : 'Object',
	#instVars : [ 'pairFinder', 'contactUpdater' ],
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'instance creation' }
CFPhysicsContactPipeline class >> manifoldBuilder: aBlock [
	^ self new
		pairFinder: CFPhysicsPairFinder new;
		contactUpdater: (CFPhysicsContactUpdater manifoldBuilder: aBlock);
		yourself
]

{ #category : 'accessing' }
CFPhysicsContactPipeline >> pairFinder: aPairFinder [ pairFinder := aPairFinder ]

{ #category : 'accessing' }
CFPhysicsContactPipeline >> contactUpdater: anUpdater [ contactUpdater := anUpdater ]

{ #category : 'updating' }
CFPhysicsContactPipeline >> updateBodies: bodies fromContacts: previousContacts [
	| pairs batch |
	pairs := pairFinder pairsAmong: bodies.
	batch := contactUpdater updatePairs: pairs fromContacts: previousContacts.
	^ CFPhysicsContactPipelineResult pairs: pairs contactBatch: batch
]
