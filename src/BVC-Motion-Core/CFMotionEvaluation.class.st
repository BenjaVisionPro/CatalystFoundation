"
I represent one immutable Behaviour evaluation produced from a timeline position.

I carry absolute timeline time, local track time and, for finite tracks, eased normalised progress. I contain no scheduling or lifecycle policy.
"
Class {
	#name : 'CFMotionEvaluation',
	#superclass : 'Object',
	#instVars : [ 'timelineTime', 'localTime', 'progress' ],
	#category : 'BVC-Motion-Core',
	#package : 'BVC-Motion-Core'
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
