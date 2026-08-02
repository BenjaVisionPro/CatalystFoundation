"
I add contact lifecycle events to a completed pipeline result. I am the pipeline stage wrapper around contact-event construction.
"

Class {
	#name : 'CFPhysicsContactEventStage',
	#superclass : 'CFPhysicsStepStage',
	#instVars : [ 'eventBuilder' ],
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
}

{ #category : 'initialization' }
CFPhysicsContactEventStage >> initialize [
	super initialize.
	eventBuilder := CFPhysicsContactEventBuilder new
]



{ #category : 'executing' }
CFPhysicsContactEventStage >> executeOn: aStepResult [
	| events |
	events := eventBuilder eventsFrom: aStepResult contactResult.
	aStepResult contactEvents: events.
	^ events
]
