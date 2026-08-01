"
I represent one ordered operation in the Physics step pipeline. Subclasses transform or enrich a pipeline result while preserving deterministic stage order.
"

Class {
	#name : 'CFPhysicsStepStage',
	#superclass : 'Object',
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
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
