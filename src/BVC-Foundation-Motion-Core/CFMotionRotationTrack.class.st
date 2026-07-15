Class {
	#name : 'CFMotionRotationTrack',
	#superclass : 'CFMotionTrack',
	#instVars : [ 'element', 'sourceRotation', 'targetRotation', 'startRotation', 'presentation', 'completionPolicy' ],
	#category : 'BVC-Foundation-Motion-Core',
	#package : 'BVC-Foundation-Motion-Core'
}

{ #category : 'instance creation' }
CFMotionRotationTrack class >> on: anElement from: aSourceRotation to: aTargetRotation [
	^ self new
		element: anElement;
		sourceRotation: aSourceRotation;
		targetRotation: aTargetRotation;
		yourself
]

{ #category : 'configuration' }
CFMotionRotationTrack >> adoptAtDestination [
	completionPolicy := #adopt.
	^ self
]

{ #category : 'accessing' }
CFMotionRotationTrack >> animationTarget [ ^ element ]

{ #category : 'playing' }
CFMotionRotationTrack >> applyDestination [
	presentation ifNil: [ ^ self ].
	presentation rotation: targetRotation.
	completionPolicy = #adopt
		ifTrue: [ presentation adoptCurrentPresentation ]
		ifFalse: [ presentation release ]
]

{ #category : 'playing' }
CFMotionRotationTrack >> applyProgress: aProgress [
	presentation rotation: ((targetRotation - startRotation) * aProgress + startRotation)
]

{ #category : 'playing' }
CFMotionRotationTrack >> captureOrigin [
	presentation := CFMotionTransformPresentation on: element
]

{ #category : 'playing' }
CFMotionRotationTrack >> captureOriginIn: aCoordinator [
	presentation := CFMotionTransformPresentation
		on: element
		using: (aCoordinator transformChannelFor: element)
]

{ #category : 'accessing' }
CFMotionRotationTrack >> element [ ^ element ]

{ #category : 'accessing' }
CFMotionRotationTrack >> element: anElement [ element := anElement ]

{ #category : 'testing' }
CFMotionRotationTrack >> isAtDestination [ ^ startRotation = targetRotation ]

{ #category : 'initialization' }
CFMotionRotationTrack >> initialize [
	super initialize.
	completionPolicy := #release
]

{ #category : 'accessing' }
CFMotionRotationTrack >> presentation [ ^ presentation ]

{ #category : 'playing' }
CFMotionRotationTrack >> prepareFromCurrentPresentation [
	startRotation := presentation isActive
		ifTrue: [ presentation rotation ]
		ifFalse: [ sourceRotation ].
	presentation rotation: startRotation
]

{ #category : 'playing' }
CFMotionRotationTrack >> preserveCurrentPresentation [
	presentation ifNotNil: [ presentation adoptCurrentPresentation ]
]

{ #category : 'accessing' }
CFMotionRotationTrack >> propertyKey [
	^ CFMotionPropertyKey
		element: element
		property: CFMotionRotationProperty uniqueInstance
]

{ #category : 'playing' }
CFMotionRotationTrack >> restoreOrigin [
	presentation ifNil: [ ^ self ].
	presentation rotation: 0.
	presentation release
]

{ #category : 'accessing' }
CFMotionRotationTrack >> sourceRotation [ ^ sourceRotation ]

{ #category : 'accessing' }
CFMotionRotationTrack >> sourceRotation: aNumber [ sourceRotation := aNumber ]

{ #category : 'accessing' }
CFMotionRotationTrack >> startRotation [ ^ startRotation ]

{ #category : 'accessing' }
CFMotionRotationTrack >> targetRotation [ ^ targetRotation ]

{ #category : 'accessing' }
CFMotionRotationTrack >> targetRotation: aNumber [ targetRotation := aNumber ]

{ #category : 'accessing' }
CFMotionRotationTrack >> targetValue [ ^ targetRotation ]

{ #category : 'accessing' }
CFMotionRotationTrack >> targetValue: aNumber [ targetRotation := aNumber ]
