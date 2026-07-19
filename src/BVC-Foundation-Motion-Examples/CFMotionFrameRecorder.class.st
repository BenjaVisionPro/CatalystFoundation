"
I am a minimal Motion participant used by executable examples to record the shared frames supplied by a CFMotionCoordinator. I contain no scheduling or timing logic.
"
Class {
	#name : 'CFMotionFrameRecorder',
	#superclass : 'Object',
	#instVars : [ 'frames' ],
	#category : 'BVC-Foundation-Motion-Examples',
	#package : 'BVC-Foundation-Motion-Examples'
}

{ #category : 'playing' }
CFMotionFrameRecorder >> advanceWith: aFrame [
	frames add: aFrame
]

{ #category : 'accessing' }
CFMotionFrameRecorder >> frames [
	^ frames asArray
]

{ #category : 'initialization' }
CFMotionFrameRecorder >> initialize [
	super initialize.
	frames := OrderedCollection new
]
