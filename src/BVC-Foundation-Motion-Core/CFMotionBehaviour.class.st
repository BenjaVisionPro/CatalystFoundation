"
I own the work performed by one Motion evaluation.

A CFMotionTimelineTrack sends me immutable CFMotionEvaluations. I may interpolate presentation, calculate procedural values, advance a dynamic system or coordinate another runtime. I may claim one presentation property through propertyKey, or return nil when my work has no exclusive presentation owner.

I do not own temporal placement, playback position, scheduling or Motion lifecycle. playbackStartedIn: and playbackEndedWith: delimit one whole playback and are each delivered exactly once; pause and resume occur inside that lifetime. Target-backed Behaviours must remain attached to the coordinator's BlSpace, while targetless Behaviours are valid until explicitly stopped.
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


{ #category : 'testing' }
CFMotionBehaviour >> isPlaybackValidIn: aCoordinator [
	| target |
	target := self animationTarget.
	target ifNil: [ ^ true ].
	^ target isAttachedToSceneGraph
		and: [ target space == aCoordinator space ]
]

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
