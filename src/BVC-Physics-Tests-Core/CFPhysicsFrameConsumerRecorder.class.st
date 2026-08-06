"
I record frame-consumer callbacks for executable examples.

My responsibility is to record presentation cadence and interpolation alpha without introducing a visual consumer.
"
Class {
	#name : 'CFPhysicsFrameConsumerRecorder',
	#superclass : 'Object',
	#instVars : [ 'presentationCount', 'lastPresentationAlpha' ],
	#category : 'BVC-Physics-Tests-Core',
	#package : 'BVC-Physics-Tests-Core'
}

{ #category : 'initialization' }
CFPhysicsFrameConsumerRecorder >> initialize [
	super initialize.
	presentationCount := 0.
	lastPresentationAlpha := nil.
]

{ #category : 'consuming frames' }
CFPhysicsFrameConsumerRecorder >> frameReadyAtAlpha: aNumber [
	presentationCount := presentationCount + 1.
	lastPresentationAlpha := aNumber
]


{ #category : 'accessing' }
CFPhysicsFrameConsumerRecorder >> presentationCount [
	^ presentationCount
]

{ #category : 'accessing' }
CFPhysicsFrameConsumerRecorder >> lastPresentationAlpha [
	^ lastPresentationAlpha
]

