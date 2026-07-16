Class {
	#name : 'CFMotionVerticalExtentTrack',
	#superclass : 'CFMotionTrack',
	#instVars : [ 'element', 'sourceExtent', 'targetExtent', 'startExtent', 'originExtent', 'completionPolicy' ],
	#category : 'BVC-Foundation-Motion-Core',
	#package : 'BVC-Foundation-Motion-Core'
}

{ #category : 'instance creation' }
CFMotionVerticalExtentTrack class >> on: anElement from: aSourceExtent to: aTargetExtent [
	^ self new
		element: anElement;
		sourceExtent: aSourceExtent;
		targetExtent: aTargetExtent;
		yourself
]

{ #category : 'accessing' }
CFMotionVerticalExtentTrack >> animationTarget [ ^ element ]

{ #category : 'playing' }
CFMotionVerticalExtentTrack >> applyDestination [
	completionPolicy = #fitContent
		ifTrue: [ element vFitContent ]
		ifFalse: [ element vExact: targetExtent ]
]

{ #category : 'playing' }
CFMotionVerticalExtentTrack >> applyProgress: aProgress [
	element vExact: ((targetExtent - startExtent) * aProgress + startExtent)
]

{ #category : 'playing' }
CFMotionVerticalExtentTrack >> captureOrigin [
	originExtent := element extent y
]

{ #category : 'accessing' }
CFMotionVerticalExtentTrack >> element [ ^ element ]

{ #category : 'accessing' }
CFMotionVerticalExtentTrack >> element: anElement [ element := anElement ]

{ #category : 'configuration' }
CFMotionVerticalExtentTrack >> fitContentAtDestination [
	completionPolicy := #fitContent.
	^ self
]

{ #category : 'initialization' }
CFMotionVerticalExtentTrack >> initialize [
	super initialize.
	completionPolicy := #exact
]

{ #category : 'testing' }
CFMotionVerticalExtentTrack >> isAtDestination [ ^ startExtent = targetExtent ]

{ #category : 'playing' }
CFMotionVerticalExtentTrack >> prepareFromCurrentPresentation [
	startExtent := element extent y.
	element
		vExact: startExtent;
		clipChildren: true
]

{ #category : 'playing' }
CFMotionVerticalExtentTrack >> preserveCurrentPresentation [
	element vExact: element extent y
]

{ #category : 'accessing' }
CFMotionVerticalExtentTrack >> propertyKey [
	^ CFMotionPropertyKey
		element: element
		property: CFVerticalExtentMotionProperty uniqueInstance
]

{ #category : 'playing' }
CFMotionVerticalExtentTrack >> restoreOrigin [
	element vExact: originExtent
]

{ #category : 'accessing' }
CFMotionVerticalExtentTrack >> sourceExtent [ ^ sourceExtent ]

{ #category : 'accessing' }
CFMotionVerticalExtentTrack >> sourceExtent: aNumber [ sourceExtent := aNumber ]

{ #category : 'accessing' }
CFMotionVerticalExtentTrack >> startExtent [ ^ startExtent ]

{ #category : 'accessing' }
CFMotionVerticalExtentTrack >> targetExtent [ ^ targetExtent ]

{ #category : 'accessing' }
CFMotionVerticalExtentTrack >> targetExtent: aNumber [ targetExtent := aNumber ]

{ #category : 'accessing' }
CFMotionVerticalExtentTrack >> targetValue [ ^ targetExtent ]

{ #category : 'accessing' }
CFMotionVerticalExtentTrack >> targetValue: aNumber [ targetExtent := aNumber ]
