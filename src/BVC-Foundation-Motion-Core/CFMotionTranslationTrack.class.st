Class {
	#name : 'CFMotionTranslationTrack',
	#superclass : 'CFMotionTrack',
	#instVars : [ 'element', 'sourceTranslation', 'targetTranslation', 'startTranslation', 'presentation', 'completionPolicy' ],
	#category : 'BVC-Foundation-Motion-Core',
	#package : 'BVC-Foundation-Motion-Core'
}

{ #category : 'instance creation' }
CFMotionTranslationTrack class >> on: anElement from: aSourceTranslation to: aTargetTranslation [
	^ self new
		element: anElement;
		sourceTranslation: aSourceTranslation;
		targetTranslation: aTargetTranslation;
		yourself
]

{ #category : 'configuration' }
CFMotionTranslationTrack >> adoptAtDestination [
	completionPolicy := #adopt.
	^ self
]

{ #category : 'accessing' }
CFMotionTranslationTrack >> animationTarget [ ^ element ]

{ #category : 'playing' }
CFMotionTranslationTrack >> applyDestination [
	presentation ifNil: [ ^ self ].
	presentation translation: targetTranslation.
	completionPolicy = #adopt
		ifTrue: [ presentation adoptCurrentPresentation ]
		ifFalse: [ presentation release ]
]

{ #category : 'playing' }
CFMotionTranslationTrack >> applyProgress: aProgress [
	presentation translation: ((targetTranslation - startTranslation) * aProgress + startTranslation)
]

{ #category : 'playing' }
CFMotionTranslationTrack >> captureOrigin [
	presentation := CFMotionTransformPresentation on: element
]

{ #category : 'playing' }
CFMotionTranslationTrack >> captureOriginIn: aCoordinator [
	presentation := CFMotionTransformPresentation
		on: element
		using: (aCoordinator transformChannelFor: element)
]

{ #category : 'accessing' }
CFMotionTranslationTrack >> element [ ^ element ]

{ #category : 'accessing' }
CFMotionTranslationTrack >> element: anElement [ element := anElement ]

{ #category : 'testing' }
CFMotionTranslationTrack >> isAtDestination [ ^ startTranslation = targetTranslation ]

{ #category : 'initialization' }
CFMotionTranslationTrack >> initialize [
	super initialize.
	completionPolicy := #release
]

{ #category : 'accessing' }
CFMotionTranslationTrack >> presentation [ ^ presentation ]

{ #category : 'playing' }
CFMotionTranslationTrack >> prepareFromCurrentPresentation [
	startTranslation := presentation isActive
		ifTrue: [ presentation translation ]
		ifFalse: [ sourceTranslation ].
	presentation translation: startTranslation
]

{ #category : 'playing' }
CFMotionTranslationTrack >> preserveCurrentPresentation [
	presentation ifNotNil: [ presentation adoptCurrentPresentation ]
]

{ #category : 'accessing' }
CFMotionTranslationTrack >> propertyKey [
	^ CFMotionPropertyKey
		element: element
		property: CFMotionTranslationProperty uniqueInstance
]

{ #category : 'playing' }
CFMotionTranslationTrack >> restoreOrigin [
	presentation ifNil: [ ^ self ].
	presentation translation: 0 @ 0.
	presentation release
]

{ #category : 'accessing' }
CFMotionTranslationTrack >> sourceTranslation [ ^ sourceTranslation ]

{ #category : 'accessing' }
CFMotionTranslationTrack >> sourceTranslation: aPoint [ sourceTranslation := aPoint ]

{ #category : 'accessing' }
CFMotionTranslationTrack >> startTranslation [ ^ startTranslation ]

{ #category : 'accessing' }
CFMotionTranslationTrack >> targetTranslation [ ^ targetTranslation ]

{ #category : 'accessing' }
CFMotionTranslationTrack >> targetTranslation: aPoint [ targetTranslation := aPoint ]

{ #category : 'accessing' }
CFMotionTranslationTrack >> targetValue [ ^ targetTranslation ]

{ #category : 'accessing' }
CFMotionTranslationTrack >> targetValue: aPoint [ targetTranslation := aPoint ]
