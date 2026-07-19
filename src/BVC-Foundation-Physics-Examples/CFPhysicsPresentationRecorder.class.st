"
I record the presentation protocol used by CFPhysicsWorldBehaviour in executable examples.

I am deliberately separate from CFPhysicsWorldStepRecorder so simulation and presentation remain distinct collaborators.
"
Class {
	#name : 'CFPhysicsPresentationRecorder',
	#superclass : 'Object',
	#instVars : [ 'presentationCount', 'lastPresentationAlpha', 'releaseCount' ],
	#category : 'BVC-Foundation-Physics-Examples',
	#package : 'BVC-Foundation-Physics-Examples'
}

{ #category : 'initialization' }
CFPhysicsPresentationRecorder >> initialize [
	super initialize.
	presentationCount := 0.
	lastPresentationAlpha := nil.
	releaseCount := 0
]

{ #category : 'presenting' }
CFPhysicsPresentationRecorder >> presentAtAlpha: aNumber [
	presentationCount := presentationCount + 1.
	lastPresentationAlpha := aNumber
]

{ #category : 'controlling' }
CFPhysicsPresentationRecorder >> release [
	releaseCount := releaseCount + 1
]

{ #category : 'accessing' }
CFPhysicsPresentationRecorder >> presentationCount [
	^ presentationCount
]

{ #category : 'accessing' }
CFPhysicsPresentationRecorder >> lastPresentationAlpha [
	^ lastPresentationAlpha
]

{ #category : 'accessing' }
CFPhysicsPresentationRecorder >> releaseCount [
	^ releaseCount
]
