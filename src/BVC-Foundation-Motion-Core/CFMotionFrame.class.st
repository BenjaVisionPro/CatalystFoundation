"
I am the immutable time sample shared by every Motion advanced in one Bloc frame.

absoluteTime is sampled once from the owning BlSpace clock, elapsedTime excludes inactive time and is zero on the first frame after driver activation, and frameId identifies the enclosing BlSpaceFrame. I contain no interpolation, simulation-step or playback policy.
"
Class {
	#name : 'CFMotionFrame',
	#superclass : 'Object',
	#instVars : [ 'absoluteTime', 'elapsedTime', 'frameId' ],
	#category : 'BVC-Foundation-Motion-Core',
	#package : 'BVC-Foundation-Motion-Core'
}

{ #category : 'instance creation' }
CFMotionFrame class >> absoluteTime: aDateAndTime elapsedTime: aDuration frameId: anInteger [
	^ self new
		initializeAbsoluteTime: aDateAndTime
		elapsedTime: aDuration
		frameId: anInteger
]

{ #category : 'accessing' }
CFMotionFrame >> absoluteTime [
	^ absoluteTime
]

{ #category : 'accessing' }
CFMotionFrame >> elapsedTime [
	^ elapsedTime
]

{ #category : 'accessing' }
CFMotionFrame >> frameId [
	^ frameId
]

{ #category : 'initialization' }
CFMotionFrame >> initializeAbsoluteTime: aDateAndTime elapsedTime: aDuration frameId: anInteger [
	absoluteTime := aDateAndTime.
	elapsedTime := aDuration.
	frameId := anInteger.
	^ self
]
