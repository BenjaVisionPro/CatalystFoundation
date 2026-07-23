Class {
	#name : 'CFPhysicsRecordingBehaviour',
	#superclass : 'CFPhysicsBehaviour',
	#instVars : [ 'updates', 'removalCount', 'updateBlock' ],
	#category : 'BVC-Foundation-Physics-Tests-Behaviours',
	#package : 'BVC-Foundation-Physics-Tests'
}

{ #category : 'initialization' }
CFPhysicsRecordingBehaviour >> initialize [
	super initialize.
	updates := OrderedCollection new.
	removalCount := 0
]

{ #category : 'accessing' }
CFPhysicsRecordingBehaviour >> updates [
	^ updates copy
]

{ #category : 'accessing' }
CFPhysicsRecordingBehaviour >> removalCount [
	^ removalCount
]

{ #category : 'accessing' }
CFPhysicsRecordingBehaviour >> updateBlock: aBlock [
	updateBlock := aBlock
]

{ #category : 'updating' }
CFPhysicsRecordingBehaviour >> updateForStep: aPhysicsStep [
	updates add: aPhysicsStep.
	updateBlock ifNotNil: [ updateBlock value: self value: aPhysicsStep ]
]

{ #category : 'removing' }
CFPhysicsRecordingBehaviour >> removing [
	removalCount := removalCount + 1
]
