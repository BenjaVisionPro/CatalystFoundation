"
I am presentation or dynamic logic evaluated by a Motion track.

I own what happens when Motion is evaluated. I may interpolate a property, calculate a procedural value, advance a spring, run a state machine or eventually advance a Physics world. I receive a CFMotionEvaluation and apply work from that evaluation.

I do not own temporal placement, a playhead or frame scheduling. CFMotionTimelineTrack owns when I run. CFMotionTimeline owns the playhead. CFMotionCoordinator owns frame cadence.

CFMotion sends playbackStartedIn: once when a playback begins and playbackEndedWith: once when that playback becomes terminal. Pause and resume do not repeat either callback. Subclasses use these callbacks for resources whose lifetime spans the whole playback; ordinary interpolated Behaviours may ignore them.
"
Class {
	#name : 'CFMotionBehaviour',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Motion-Core',
	#package : 'BVC-Foundation-Motion-Core'
}

{ #category : 'accessing' }
CFMotionBehaviour >> animationTarget [ ^ nil ]

{ #category : 'playing' }
CFMotionBehaviour >> applyDestination [ ]

{ #category : 'evaluating' }
CFMotionBehaviour >> evaluate: anEvaluation [
	self applyProgress: anEvaluation progress
]

{ #category : 'playing' }
CFMotionBehaviour >> applyProgress: aProgress [ self subclassResponsibility ]

{ #category : 'playing' }
CFMotionBehaviour >> captureOrigin [ ]

{ #category : 'playing' }
CFMotionBehaviour >> captureOriginIn: aCoordinator [ self captureOrigin ]

{ #category : 'playing' }
CFMotionBehaviour >> playbackStartedIn: aCoordinator [ ]

{ #category : 'playing' }
CFMotionBehaviour >> playbackEndedWith: aMotionState [ ]

{ #category : 'accessing' }
CFMotionBehaviour >> propertyKey [ ^ nil ]

{ #category : 'playing' }
CFMotionBehaviour >> preserveCurrentPresentation [ ]

{ #category : 'playing' }
CFMotionBehaviour >> prepareFromCurrentPresentation [ ]

{ #category : 'playing' }
CFMotionBehaviour >> restoreOrigin [ ]

{ #category : 'controlling' }
CFMotionBehaviour >> reversed [ self subclassResponsibility ]

{ #category : 'private - validation' }
CFMotionBehaviour >> validateForExecution [ ]
