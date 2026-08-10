"
I am responsible for converting Bloc space tasks into shared Motion frames.

I sample the BlSpace clock once per active presentation frame, create one immutable CFMotionFrame and ask the CFMotionCoordinator to advance every active Motion with that same frame. I deactivate when the space has no active Motions.
"
Class {
	#name : 'CFMotionFrameDriver',
	#superclass : 'BlTask',
	#instVars : [ 'coordinator', 'space', 'time', 'previousTime', 'active' ],
	#category : 'BVC-Motion-Core',
	#package : 'BVC-Motion-Core'
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
		"BlRealTime uses the wall clock, which can be adjusted backwards. Frame
		progress is monotonic, so a regressing clock contributes no elapsed time."
		elapsed < (0 milliSeconds) ifTrue: [ elapsed := 0 milliSeconds ].
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
