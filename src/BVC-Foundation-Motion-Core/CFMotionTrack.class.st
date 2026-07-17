Class {
	#name : 'CFMotionTrack',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Motion-Core',
	#package : 'BVC-Foundation-Motion-Core'
}

{ #category : 'accessing' }
CFMotionTrack >> animationTarget [ self subclassResponsibility ]

{ #category : 'playing' }
CFMotionTrack >> applyDestination [ self subclassResponsibility ]

{ #category : 'playing' }
CFMotionTrack >> applyProgress: aProgress [ self subclassResponsibility ]

{ #category : 'playing' }
CFMotionTrack >> captureOrigin [ self subclassResponsibility ]

{ #category : 'playing' }
CFMotionTrack >> captureOriginIn: aCoordinator [ self captureOrigin ]

{ #category : 'accessing' }
CFMotionTrack >> propertyKey [ self subclassResponsibility ]

{ #category : 'playing' }
CFMotionTrack >> preserveCurrentPresentation [ ]

{ #category : 'playing' }
CFMotionTrack >> prepareFromCurrentPresentation [ self subclassResponsibility ]

{ #category : 'playing' }
CFMotionTrack >> restoreOrigin [ self subclassResponsibility ]

{ #category : 'controlling' }
CFMotionTrack >> reversed [ self subclassResponsibility ]

{ #category : 'private - validation' }
CFMotionTrack >> validateForExecution [ ]
