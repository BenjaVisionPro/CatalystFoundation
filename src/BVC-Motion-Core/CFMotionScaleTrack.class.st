"
I represent a Motion Behaviour that contributes scale through Motion's shared transform channel.

I interpolate from a source scale to a target scale, preserve composition with independent transform Motions and application transforms, and support retargeting, reversal and an explicit destination-adoption policy.
"
Class {
	#name : 'CFMotionScaleTrack',
	#superclass : 'CFMotionBehaviour',
	#instVars : [ 'element', 'sourceScale', 'targetScale', 'startScale', 'entryScale', 'presentation', 'completionPolicy' ],
	#category : 'BVC-Motion-Core',
	#package : 'BVC-Motion-Core'
}

{ #category : 'instance creation' }
CFMotionScaleTrack class >> on: anElement from: aSourceScale to: aTargetScale [
	^ self new
		element: anElement;
		sourceScale: aSourceScale;
		targetScale: aTargetScale;
		yourself
]

{ #category : 'configuration' }
CFMotionScaleTrack >> adoptAtDestination [
	completionPolicy := #adopt.
	^ self
]

{ #category : 'accessing' }
CFMotionScaleTrack >> animationTarget [ ^ element ]

{ #category : 'playing' }
CFMotionScaleTrack >> applyDestination [
	presentation ifNil: [ ^ self ].
	presentation scale: targetScale.
	completionPolicy = #adopt
		ifTrue: [ ^ presentation adoptCurrentPresentation ].
	completionPolicy = #release
		ifTrue: [ presentation release ]
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

{ #category : 'initialization' }
CFMotionScaleTrack >> initialize [
	super initialize.
	completionPolicy := #release
]

{ #category : 'accessing' }
CFMotionScaleTrack >> presentation [ ^ presentation ]

{ #category : 'playing' }
CFMotionScaleTrack >> prepareFromCurrentPresentation [
	entryScale := startScale := presentation isActive
		ifTrue: [ presentation scale ]
		ifFalse: [ sourceScale ].
	presentation scale: startScale
]

{ #category : 'playing' }
CFMotionScaleTrack >> prepareForTimelineCycle: aCycleIndex [
	startScale := aCycleIndex isZero
		ifTrue: [ entryScale ]
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
		property: CFMotionScaleProperty uniqueInstance
]

{ #category : 'playing' }
CFMotionScaleTrack >> restoreOrigin [
	presentation ifNil: [ ^ self ].
	presentation scale: 1 @ 1.
	presentation release
]

{ #category : 'controlling' }
CFMotionScaleTrack >> reversed [
	| currentScale |
	presentation ifNil: [
		self error: 'A scale track must start before it can be reversed' ].
	currentScale := presentation scale.
	(currentScale x isZero or: [ currentScale y isZero ]) ifTrue: [
		self error: 'A scale track at zero cannot be reversed' ].
	^ (self class
		on: element
		from: 1 @ 1
		to: currentScale reciprocal)
		adoptAtDestination
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
