"
I describe one presentation frame observed by Motion.

A CFMotionCoordinator creates one instance per Bloc frame and supplies that same instance to every Motion it advances. My absoluteTime is sampled from the owning BlSpace's BlTime. My elapsedTime is the duration since the previous active Motion frame and is zero for the first frame after activation or resumption. My frameId identifies the enclosing BlSpaceFrame.

I do not define simulation time steps, interpolation policy, playback position or rendering behaviour. Motions, timelines and downstream Behaviours interpret my timing information according to their own responsibilities.
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
