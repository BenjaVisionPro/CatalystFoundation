"
I am presentation logic evaluated by a Motion track.

I own what happens when Motion is evaluated. I may interpolate a property, calculate a procedural value, advance a spring, run a state machine or eventually advance a Physics world. I receive a CFMotionEvaluation and apply presentation from that evaluation.

I do not own temporal placement, a playhead, frame scheduling or Motion lifecycle. CFMotionTimelineTrack owns when I run. CFMotionTimeline owns the playhead. CFMotionCoordinator owns frame cadence.
"
Class {
	#name : 'CFMotionBehaviour',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Motion-Core',
	#package : 'BVC-Foundation-Motion-Core'
}

{ #category : 'accessing' }
CFMotionBehaviour >> animationTarget [ self subclassResponsibility ]

{ #category : 'playing' }
CFMotionBehaviour >> applyDestination [ self subclassResponsibility ]

{ #category : 'evaluating' }
CFMotionBehaviour >> evaluate: anEvaluation [
	self applyProgress: anEvaluation progress
]

{ #category : 'playing' }
CFMotionBehaviour >> applyProgress: aProgress [ self subclassResponsibility ]

{ #category : 'playing' }
CFMotionBehaviour >> captureOrigin [ self subclassResponsibility ]

{ #category : 'playing' }
CFMotionBehaviour >> captureOriginIn: aCoordinator [ self captureOrigin ]

{ #category : 'accessing' }
CFMotionBehaviour >> propertyKey [ self subclassResponsibility ]

{ #category : 'playing' }
CFMotionBehaviour >> preserveCurrentPresentation [ ]

{ #category : 'playing' }
CFMotionBehaviour >> prepareFromCurrentPresentation [ self subclassResponsibility ]

{ #category : 'playing' }
CFMotionBehaviour >> restoreOrigin [ self subclassResponsibility ]

{ #category : 'controlling' }
CFMotionBehaviour >> reversed [ self subclassResponsibility ]

{ #category : 'private - validation' }
CFMotionBehaviour >> validateForExecution [ ]
