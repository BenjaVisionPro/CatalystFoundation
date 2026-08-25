"
I represent the work performed by one Motion evaluation.

I may interpolate presentation, calculate procedural values, advance a dynamic system or adapt Motion time to another runtime. I may identify one exclusively owned presentation property with propertyKey, or answer nil when exclusive presentation ownership does not apply.

I do not own temporal placement, playback position, scheduling or Motion lifecycle. playbackStartedIn: and playbackEndedWith: delimit one whole playback lifetime; pause, resume and settlement remain inside that lifetime. A surrounding Timeline may ask me to prepare an already-selected repeat cycle; I retain only the presentation state needed to evaluate that cycle.
"
Class {
	#name : 'CFMotionBehaviour',
	#superclass : 'Object',
	#category : 'BVC-Motion-Core',
	#package : 'BVC-Motion-Core'
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
CFMotionBehaviour >> prepareForTimelineCycle: aCycleIndex [
	aCycleIndex isZero ifFalse: [ self restoreOrigin ]
]

{ #category : 'playing' }
CFMotionBehaviour >> restoreOrigin [ ]

{ #category : 'controlling' }
CFMotionBehaviour >> reversed [ self subclassResponsibility ]

{ #category : 'private - validation' }
CFMotionBehaviour >> validateForExecution [ ]
