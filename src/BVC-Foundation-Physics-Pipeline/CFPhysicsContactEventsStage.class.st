Class {
	#name : 'CFPhysicsContactEventsStage',
	#superclass : 'CFPhysicsStepStage',
	#instVars : [ 'eventBuilder' ],
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'initialization' }
CFPhysicsContactEventsStage >> initialize [
	super initialize.
	eventBuilder := CFPhysicsContactEventStage new
]

{ #category : 'accessing' }
CFPhysicsContactEventsStage >> eventBuilder [ ^ eventBuilder ]
{ #category : 'accessing' }
CFPhysicsContactEventsStage >> eventBuilder: anObject [ eventBuilder := anObject ]

{ #category : 'executing' }
CFPhysicsContactEventsStage >> executeOn: aStepResult [
	| events |
	events := eventBuilder eventsFrom: aStepResult contactResult.
	aStepResult contactEvents: events.
	^ events
]
