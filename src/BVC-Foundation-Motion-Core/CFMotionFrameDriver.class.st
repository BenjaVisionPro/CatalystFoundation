"
I am Motion's sole bridge to Bloc frame scheduling within one BlSpace.

I am a BlTask owned by a CFMotionCoordinator. While that coordinator has active Motions I requeue through the normal BlSpace task queue, causing Bloc to request another pulse. On each execution I sample the space's BlTime once, construct one CFMotionFrame and ask the coordinator to advance all active Motions with it.

I own no Motion content, timeline state, playback policy or presentation contribution. Bloc decides when a frame occurs; I translate that occurrence into a shared Motion frame. When inactive I do not requeue, allowing the space to become idle. Reactivation resets my elapsed-time baseline so inactive or paused wall-clock time is not delivered to Motion.
"
Class {
	#name : 'CFMotionFrameDriver',
	#superclass : 'BlTask',
	#instVars : [ 'coordinator', 'space', 'time', 'previousTime', 'active' ],
	#category : 'BVC-Foundation-Motion-Core',
	#package : 'BVC-Foundation-Motion-Core'
}

{ #category : 'instance creation' }
CFMotionFrameDriver class >> coordinator: aCoordinator [
	^ self new
		coordinator: aCoordinator;
		yourself
]

{ #category : 'controlling' }
CFMotionFrameDriver >> activate [
	active ifTrue: [ ^ self ].
	active := true.
	previousTime := nil.
	self isComplete ifTrue: [ self setNew ].
	self isNew ifTrue: [
		space enqueueTask: self.
		^ self ].
	(self isQueued or: [ self isPendingExecution or: [ self isExecuting ] ])
		ifFalse: [ self error: 'A Motion frame driver is in an invalid task state' ].
	^ self
]

{ #category : 'accessing' }
CFMotionFrameDriver >> coordinator [
	^ coordinator
]

{ #category : 'accessing' }
CFMotionFrameDriver >> coordinator: aCoordinator [
	coordinator := aCoordinator.
	space := aCoordinator space
]

{ #category : 'initialization' }
CFMotionFrameDriver >> initialize [
	super initialize.
	active := false.
	time := BlTime real
]

{ #category : 'testing' }
CFMotionFrameDriver >> isActive [
	^ active
]

{ #category : 'api - testing' }
CFMotionFrameDriver >> isIndefiniteTermTask [
	^ true
]

{ #category : 'hooks' }
CFMotionFrameDriver >> onEnqueued: aBlSpace [
	super onEnqueued: aBlSpace.
	space := aBlSpace.
	time := aBlSpace time
]

{ #category : 'private - running' }
CFMotionFrameDriver >> requeueTaskAfterExecution [
	^ active and: [ coordinator hasActiveMotions ]
]

{ #category : 'api - running' }
CFMotionFrameDriver >> run [
	active ifFalse: [ ^ self ].
	coordinator hasActiveMotions ifFalse: [ ^ self deactivate ].
	time synchronized: [
		| now elapsed frame |
		now := time now.
		elapsed := previousTime
			ifNil: [ 0 milliSeconds ]
			ifNotNil: [ now - previousTime ].
		previousTime := now.
		frame := CFMotionFrame
			absoluteTime: now
			elapsedTime: elapsed
			frameId: space frame id.
		coordinator advanceWith: frame ]
]

{ #category : 'controlling' }
CFMotionFrameDriver >> deactivate [
	active := false.
	previousTime := nil.
	^ self
]
