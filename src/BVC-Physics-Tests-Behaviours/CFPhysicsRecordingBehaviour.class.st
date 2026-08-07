Class {
	#name : 'CFPhysicsRecordingBehaviour',
	#superclass : 'CFPhysicsBehaviour',
	#instVars : [ 'updates', 'stopCount', 'updateBlock' ],
	#category : 'BVC-Physics-Tests-Behaviours',
	#package : 'BVC-Physics-Tests-Behaviours'
}

{ #category : 'initialization' }
CFPhysicsRecordingBehaviour >> initialize [
	super initialize.
	updates := OrderedCollection new.
	stopCount := 0
]

{ #category : 'accessing' }
CFPhysicsRecordingBehaviour >> updates [
	^ updates copy
]

{ #category : 'accessing' }
CFPhysicsRecordingBehaviour >> stopCount [
	^ stopCount
]

{ #category : 'accessing' }
CFPhysicsRecordingBehaviour >> updateBlock: aBlock [
	updateBlock := aBlock
]

{ #category : 'updating' }
CFPhysicsRecordingBehaviour >> step: aPhysicsStep [
	updates add: aPhysicsStep.
	updateBlock ifNotNil: [ updateBlock value: self value: aPhysicsStep ]
]

{ #category : 'running' }
CFPhysicsRecordingBehaviour >> stop [
	self isRunning ifTrue: [ stopCount := stopCount + 1 ].
	^ super stop
]
