Class {
	#name : 'CFPhysicsStepStage',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'executing' }
CFPhysicsStepStage >> executeOn: aStepResult [
	self subclassResponsibility
]

{ #category : 'accessing' }
CFPhysicsStepStage >> name [
	^ self class name
]


{ #category : 'executing' }
CFPhysicsStepStage >> executeOnWithTelemetry: aStepResult [
	^ self executeOn: aStepResult
]
