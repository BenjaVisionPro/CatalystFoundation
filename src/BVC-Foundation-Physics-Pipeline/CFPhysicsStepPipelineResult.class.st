Class {
	#name : 'CFPhysicsStepPipelineResult',
	#superclass : 'Object',
	#instVars : [ 'step', 'bodies', 'contactResult', 'bodyStates', 'constraints', 'solver', 'gravity', 'restitutionThreshold' ],
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'accessing' }
CFPhysicsStepPipelineResult >> step [ ^ step ]
{ #category : 'accessing' }
CFPhysicsStepPipelineResult >> step: anObject [ step := anObject ]
{ #category : 'accessing' }
CFPhysicsStepPipelineResult >> bodies [ ^ bodies ]
{ #category : 'accessing' }
CFPhysicsStepPipelineResult >> bodies: aCollection [ bodies := aCollection asArray ]
{ #category : 'accessing' }
CFPhysicsStepPipelineResult >> contactResult [ ^ contactResult ]
{ #category : 'accessing' }
CFPhysicsStepPipelineResult >> contactResult: anObject [ contactResult := anObject ]
{ #category : 'accessing' }
CFPhysicsStepPipelineResult >> bodyStates [ ^ bodyStates ]
{ #category : 'accessing' }
CFPhysicsStepPipelineResult >> bodyStates: aDictionary [ bodyStates := aDictionary ]
{ #category : 'accessing' }
CFPhysicsStepPipelineResult >> constraints [ ^ constraints ]
{ #category : 'accessing' }
CFPhysicsStepPipelineResult >> constraints: aCollection [ constraints := aCollection asArray ]
{ #category : 'accessing' }
CFPhysicsStepPipelineResult >> solver [ ^ solver ]
{ #category : 'accessing' }
CFPhysicsStepPipelineResult >> solver: anObject [ solver := anObject ]
{ #category : 'accessing' }
CFPhysicsStepPipelineResult >> gravity [ ^ gravity ]
{ #category : 'accessing' }
CFPhysicsStepPipelineResult >> gravity: aPoint [ gravity := aPoint ]
{ #category : 'accessing' }
CFPhysicsStepPipelineResult >> restitutionThreshold [ ^ restitutionThreshold ]
{ #category : 'accessing' }
CFPhysicsStepPipelineResult >> restitutionThreshold: aNumber [ restitutionThreshold := aNumber ]

{ #category : 'contacts' }
CFPhysicsStepPipelineResult >> pairs [ ^ contactResult pairs ]
{ #category : 'contacts' }
CFPhysicsStepPipelineResult >> activeContacts [ ^ contactResult activeContacts ]
{ #category : 'contacts' }
CFPhysicsStepPipelineResult >> beganContacts [ ^ contactResult beganContacts ]
{ #category : 'contacts' }
CFPhysicsStepPipelineResult >> continuedContacts [ ^ contactResult continuedContacts ]
{ #category : 'contacts' }
CFPhysicsStepPipelineResult >> endedContacts [ ^ contactResult endedContacts ]
