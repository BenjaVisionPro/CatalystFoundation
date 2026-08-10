"
I represent one immutable Motion presentation-time sample.

I carry the absolute BlSpace time, elapsed time since the previous active Motion frame and the Bloc frame identifier. I contain no easing, playback, interpolation or simulation policy.
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
