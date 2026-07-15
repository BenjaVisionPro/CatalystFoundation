Class {
	#name : 'CFMotionScaleTrack',
	#superclass : 'CFMotionTrack',
	#instVars : [ 'element', 'sourceScale', 'targetScale', 'startScale', 'presentation' ],
	#category : 'BVC-Foundation-Motion-Core',
	#package : 'BVC-Foundation-Motion-Core'
}

{ #category : 'instance creation' }
CFMotionScaleTrack class >> on: anElement from: aSourceScale to: aTargetScale [
	^ self new
		element: anElement;
		sourceScale: aSourceScale;
		targetScale: aTargetScale;
		yourself
]

{ #category : 'accessing' }
CFMotionScaleTrack >> animationTarget [ ^ element ]

{ #category : 'playing' }
CFMotionScaleTrack >> applyDestination [
	presentation ifNil: [ ^ self ].
	presentation scale: targetScale.
	presentation release
]

{ #category : 'playing' }
CFMotionScaleTrack >> applyProgress: aProgress [
	presentation scale: ((targetScale - startScale) * aProgress + startScale)
]

{ #category : 'playing' }
CFMotionScaleTrack >> captureOrigin [
	presentation := CFMotionTransformPresentation on: element
]

{ #category : 'playing' }
CFMotionScaleTrack >> captureOriginIn: aCoordinator [
	presentation := CFMotionTransformPresentation
		on: element
		using: (aCoordinator transformChannelFor: element)
]

{ #category : 'accessing' }
CFMotionScaleTrack >> element [ ^ element ]

{ #category : 'accessing' }
CFMotionScaleTrack >> element: anElement [ element := anElement ]

{ #category : 'testing' }
CFMotionScaleTrack >> isAtDestination [ ^ startScale = targetScale ]

{ #category : 'accessing' }
CFMotionScaleTrack >> presentation [ ^ presentation ]

{ #category : 'playing' }
CFMotionScaleTrack >> prepareFromCurrentPresentation [
	startScale := presentation isActive
		ifTrue: [ presentation scale ]
		ifFalse: [ sourceScale ].
	presentation scale: startScale
]

{ #category : 'playing' }
CFMotionScaleTrack >> preserveCurrentPresentation [
	presentation ifNotNil: [ presentation adoptCurrentPresentation ]
]

{ #category : 'accessing' }
CFMotionScaleTrack >> propertyKey [
	^ CFMotionPropertyKey
		element: element
		property: CFScaleMotionProperty uniqueInstance
]

{ #category : 'playing' }
CFMotionScaleTrack >> restoreOrigin [
	presentation ifNil: [ ^ self ].
	presentation scale: 1 @ 1.
	presentation release
]

{ #category : 'accessing' }
CFMotionScaleTrack >> sourceScale [ ^ sourceScale ]

{ #category : 'accessing' }
CFMotionScaleTrack >> sourceScale: aPoint [ sourceScale := aPoint ]

{ #category : 'accessing' }
CFMotionScaleTrack >> startScale [ ^ startScale ]

{ #category : 'accessing' }
CFMotionScaleTrack >> targetScale [ ^ targetScale ]

{ #category : 'accessing' }
CFMotionScaleTrack >> targetScale: aPoint [ targetScale := aPoint ]

{ #category : 'accessing' }
CFMotionScaleTrack >> targetValue [ ^ targetScale ]

{ #category : 'accessing' }
CFMotionScaleTrack >> targetValue: aPoint [ targetScale := aPoint ]
