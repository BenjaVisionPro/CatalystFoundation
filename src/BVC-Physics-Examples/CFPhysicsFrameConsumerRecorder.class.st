"
I record frame-consumer callbacks for executable examples.

My responsibility is to verify presentation and release behaviour without introducing a real visual consumer.
"
Class {
	#name : 'CFPhysicsFrameConsumerRecorder',
	#superclass : 'Object',
	#instVars : [ 'presentationCount', 'lastPresentationAlpha', 'releaseCount' ],
	#category : 'BVC-Physics-Examples',
	#package : 'BVC-Physics-Examples'
}

{ #category : 'initialization' }
CFPhysicsFrameConsumerRecorder >> initialize [
	super initialize.
	presentationCount := 0.
	lastPresentationAlpha := nil.
	releaseCount := 0
]

{ #category : 'consuming frames' }
CFPhysicsFrameConsumerRecorder >> frameReadyAtAlpha: aNumber [
	presentationCount := presentationCount + 1.
	lastPresentationAlpha := aNumber
]

{ #category : 'controlling' }
CFPhysicsFrameConsumerRecorder >> release [
	releaseCount := releaseCount + 1
]

{ #category : 'accessing' }
CFPhysicsFrameConsumerRecorder >> presentationCount [
	^ presentationCount
]

{ #category : 'accessing' }
CFPhysicsFrameConsumerRecorder >> lastPresentationAlpha [
	^ lastPresentationAlpha
]

{ #category : 'accessing' }
CFPhysicsFrameConsumerRecorder >> releaseCount [
	^ releaseCount
]
