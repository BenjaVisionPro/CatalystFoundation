Class {
	#name : 'CFMotionGeometryTrack',
	#superclass : 'CFMotionTrack',
	#instVars : [ 'element', 'sourceSnapshot', 'destinationSnapshot', 'presentation', 'startScale', 'startTranslation' ],
	#category : 'BVC-Foundation-Motion-Core',
	#package : 'BVC-Foundation-Motion-Core'
}

{ #category : 'instance creation' }
CFMotionGeometryTrack class >> from: aSourceSnapshot to: aDestinationSnapshot [
	aSourceSnapshot element == aDestinationSnapshot element ifFalse: [
		self error: 'Geometry snapshots must describe the same element' ].
	aSourceSnapshot coordinateSpace == aDestinationSnapshot coordinateSpace ifFalse: [
		self error: 'Geometry snapshots must use the same coordinate space' ].
	^ self new
		element: aSourceSnapshot element;
		sourceSnapshot: aSourceSnapshot;
		destinationSnapshot: aDestinationSnapshot;
		yourself
]

{ #category : 'accessing' }
CFMotionGeometryTrack >> animationTarget [ ^ element ]

{ #category : 'playing' }
CFMotionGeometryTrack >> applyDestination [
	presentation ifNil: [ ^ self ].
	presentation
		scale: 1 @ 1;
		translation: 0 @ 0;
		release
]

{ #category : 'playing' }
CFMotionGeometryTrack >> applyProgress: aProgress [
	| remaining scale translation |
	remaining := 1.0 - aProgress.
	scale := ((startScale x * remaining) + aProgress)
		@ ((startScale y * remaining) + aProgress).
	translation := (startTranslation x * remaining)
		@ (startTranslation y * remaining).
	presentation
		scale: scale;
		translation: translation
]

{ #category : 'playing' }
CFMotionGeometryTrack >> captureOrigin [
	presentation := CFMotionTransformPresentation on: element
]

{ #category : 'accessing' }
CFMotionGeometryTrack >> destinationSnapshot [ ^ destinationSnapshot ]

{ #category : 'accessing' }
CFMotionGeometryTrack >> destinationSnapshot: aSnapshot [ destinationSnapshot := aSnapshot ]

{ #category : 'accessing' }
CFMotionGeometryTrack >> element [ ^ element ]

{ #category : 'accessing' }
CFMotionGeometryTrack >> element: anElement [ element := anElement ]

{ #category : 'testing' }
CFMotionGeometryTrack >> isAtDestination [
	^ startScale = (1 @ 1) and: [ startTranslation isZero ]
]

{ #category : 'playing' }
CFMotionGeometryTrack >> prepareFromCurrentPresentation [
	startScale := (sourceSnapshot boundsInParent extent x / destinationSnapshot boundsInParent extent x)
		@ (sourceSnapshot boundsInParent extent y / destinationSnapshot boundsInParent extent y).
	startTranslation := sourceSnapshot boundsInParent origin - destinationSnapshot boundsInParent origin.
	self applyProgress: 0.0
]

{ #category : 'accessing' }
CFMotionGeometryTrack >> presentation [ ^ presentation ]

{ #category : 'playing' }
CFMotionGeometryTrack >> preserveCurrentPresentation [
	presentation ifNotNil: [ presentation adoptCurrentPresentation ]
]

{ #category : 'accessing' }
CFMotionGeometryTrack >> propertyKey [
	^ CFMotionPropertyKey
		element: element
		property: CFGeometryMotionProperty uniqueInstance
]

{ #category : 'playing' }
CFMotionGeometryTrack >> restoreOrigin [
	"The layout mutation is already authoritative; cancellation restores that state."
	self applyDestination
]

{ #category : 'accessing' }
CFMotionGeometryTrack >> sourceSnapshot [ ^ sourceSnapshot ]

{ #category : 'accessing' }
CFMotionGeometryTrack >> sourceSnapshot: aSnapshot [ sourceSnapshot := aSnapshot ]
