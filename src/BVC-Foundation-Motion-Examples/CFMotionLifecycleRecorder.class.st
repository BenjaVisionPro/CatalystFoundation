"
I am an example Behaviour that records whole-playback lifecycle callbacks and frame evaluations. I demonstrate that Behaviour resources begin once, survive pause and resume, and end once with the terminal CFMotionState.
"
Class {
	#name : 'CFMotionLifecycleRecorder',
	#superclass : 'CFMotionEvaluationRecorder',
	#instVars : [ 'coordinators', 'terminalStates' ],
	#category : 'BVC-Foundation-Motion-Examples',
	#package : 'BVC-Foundation-Motion-Examples'
}

{ #category : 'initialization' }
CFMotionLifecycleRecorder >> initialize [
	super initialize.
	coordinators := OrderedCollection new.
	terminalStates := OrderedCollection new
]

{ #category : 'playing' }
CFMotionLifecycleRecorder >> playbackStartedIn: aCoordinator [
	coordinators add: aCoordinator
]

{ #category : 'playing' }
CFMotionLifecycleRecorder >> playbackEndedWith: aMotionState [
	terminalStates add: aMotionState
]

{ #category : 'accessing' }
CFMotionLifecycleRecorder >> coordinators [
	^ coordinators asArray
]

{ #category : 'accessing' }
CFMotionLifecycleRecorder >> terminalStates [
	^ terminalStates asArray
]
