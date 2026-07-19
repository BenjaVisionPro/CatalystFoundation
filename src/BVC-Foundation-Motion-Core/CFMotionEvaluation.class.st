"
I am the immutable value passed from a timeline track to its Behaviour.

timelineTime is the timeline playhead, localTime is measured from the track's resolved start, and progress is eased normalised progress for a finite track or nil for an indefinite track. I contain no scheduling, lifecycle or presentation policy.
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

{ #category : 'testing' }
CFMotionEvaluation >> hasProgress [
	^ progress notNil
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
