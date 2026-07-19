"
I am the sole Bloc task that advances Motion in one BlSpace.

While my coordinator has active Motions I sample BlSpace time once per execution, create one shared CFMotionFrame and requeue through the normal Bloc task queue. When no Motion remains active I stop requeueing and clear the elapsed-time baseline, so inactive wall-clock time is never delivered on reactivation.

I own no Motion content, playback position or presentation policy.
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
