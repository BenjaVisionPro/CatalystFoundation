"
I am an immutable evaluation supplied by a CFMotionTimelineTrack to a CFMotionBehaviour.

I describe one Behaviour evaluation in both timeline and local terms. timelineTime is the absolute playhead position. localTime is measured from the track's resolved start. progress is the track's eased normalised progress.

I contain no scheduling, lifecycle or presentation policy. A timeline track creates me; a Behaviour interprets me.
"
Class {
	#name : 'CFMotionEvaluation',
	#superclass : 'Object',
	#instVars : [ 'timelineTime', 'localTime', 'progress' ],
	#category : 'BVC-Foundation-Motion-Core',
	#package : 'BVC-Foundation-Motion-Core'
}

{ #category : 'instance creation' }
CFMotionEvaluation class >> timelineTime: aTimelineTime localTime: aLocalTime progress: aProgress [
	^ self new
		timelineTime: aTimelineTime;
		localTime: aLocalTime;
		progress: aProgress;
		yourself
]

{ #category : 'accessing' }
CFMotionEvaluation >> localTime [ ^ localTime ]

{ #category : 'private - initialization' }
CFMotionEvaluation >> localTime: aDuration [ localTime := aDuration ]

{ #category : 'accessing' }
CFMotionEvaluation >> progress [ ^ progress ]

{ #category : 'private - initialization' }
CFMotionEvaluation >> progress: aNumber [ progress := aNumber ]

{ #category : 'accessing' }
CFMotionEvaluation >> timelineTime [ ^ timelineTime ]

{ #category : 'private - initialization' }
CFMotionEvaluation >> timelineTime: aDuration [ timelineTime := aDuration ]
