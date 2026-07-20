"
I record the frame-consumer protocol used by CFPhysicsWorldBehaviour in executable examples.

I am deliberately separate from CFPhysicsWorldStepRecorder so simulation stepping and frame consumption remain distinct collaborators.
"
Class {
	#name : 'CFPhysicsFrameConsumerRecorder',
	#superclass : 'Object',
	#instVars : [ 'presentationCount', 'lastPresentationAlpha', 'releaseCount' ],
	#category : 'BVC-Foundation-Physics-Examples',
	#package : 'BVC-Foundation-Physics-Examples'
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
