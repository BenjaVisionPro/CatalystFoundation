Class {
	#name : 'CFMotionExtentTrack',
	#superclass : 'CFMotionBehaviour',
	#instVars : [ 'element', 'sourceExtent', 'targetExtent', 'startExtent', 'originExtent', 'completionPolicy', 'hasStarted' ],
	#category : 'BVC-Foundation-Motion-Core',
	#package : 'BVC-Foundation-Motion-Core'
}

{ #category : 'instance creation' }
CFMotionExtentTrack class >> on: anElement from: aSourceExtent to: aTargetExtent [
	^ self new
		element: anElement;
		sourceExtent: aSourceExtent;
		targetExtent: aTargetExtent;
		yourself
]

{ #category : 'accessing' }
CFMotionExtentTrack >> animationTarget [ ^ element ]

{ #category : 'playing' }
CFMotionExtentTrack >> applyDestination [
	completionPolicy = #fitContent
		ifTrue: [ element constraintsDo: [ :c |
			self controlsHorizontal ifTrue: [ c horizontal fitContent ].
			self controlsVertical ifTrue: [ c vertical fitContent ] ] ]
		ifFalse: [ self applyExtent: targetExtent ]
]

{ #category : 'playing' }
CFMotionExtentTrack >> applyProgress: aProgress [
	self applyExtent: ((targetExtent - startExtent) * aProgress + startExtent)
]

{ #category : 'private - playing' }
CFMotionExtentTrack >> applyExtent: anExtent [
	element constraintsDo: [ :c |
		self controlsHorizontal ifTrue: [ c horizontal exact: anExtent x ].
		self controlsVertical ifTrue: [ c vertical exact: anExtent y ] ]
]

{ #category : 'playing' }
CFMotionExtentTrack >> captureOrigin [
	originExtent := element extent
]

{ #category : 'accessing' }
CFMotionExtentTrack >> controlsHorizontal [
	^ sourceExtent x ~= targetExtent x
]

{ #category : 'testing' }
CFMotionExtentTrack >> controlsVertical [
	^ sourceExtent y ~= targetExtent y
]

{ #category : 'accessing' }
CFMotionExtentTrack >> element [ ^ element ]

{ #category : 'accessing' }
CFMotionExtentTrack >> element: anElement [ element := anElement ]

{ #category : 'configuration' }
CFMotionExtentTrack >> fitContentAtDestination [
	completionPolicy := #fitContent.
	^ self
]

{ #category : 'initialization' }
CFMotionExtentTrack >> initialize [
	super initialize.
	completionPolicy := #exact.
	hasStarted := false
]

{ #category : 'testing' }
CFMotionExtentTrack >> isAtDestination [
	^ (self controlsHorizontal not or: [ startExtent x = targetExtent x ])
		and: [ self controlsVertical not or: [ startExtent y = targetExtent y ] ]
]

{ #category : 'playing' }
CFMotionExtentTrack >> prepareFromCurrentPresentation [
	startExtent := hasStarted
		ifTrue: [ element extent ]
		ifFalse: [ sourceExtent ].
	hasStarted := true.
	self applyExtent: startExtent.
	(self controlsHorizontal or: [ self controlsVertical ]) ifTrue: [ element clipChildren: true ]
]

{ #category : 'playing' }
CFMotionExtentTrack >> preserveCurrentPresentation [
	self applyExtent: element extent
]

{ #category : 'accessing' }
CFMotionExtentTrack >> propertyKey [
	^ CFMotionPropertyKey
		element: element
		property: CFMotionExtentProperty uniqueInstance
]

{ #category : 'playing' }
CFMotionExtentTrack >> restoreOrigin [
	self applyExtent: originExtent
]

{ #category : 'accessing' }
CFMotionExtentTrack >> sourceExtent [ ^ sourceExtent ]

{ #category : 'accessing' }
CFMotionExtentTrack >> sourceExtent: aPoint [ sourceExtent := aPoint ]

{ #category : 'accessing' }
CFMotionExtentTrack >> startExtent [ ^ startExtent ]

{ #category : 'accessing' }
CFMotionExtentTrack >> targetExtent [ ^ targetExtent ]

{ #category : 'accessing' }
CFMotionExtentTrack >> targetExtent: aPoint [ targetExtent := aPoint ]

{ #category : 'accessing' }
CFMotionExtentTrack >> targetValue [ ^ targetExtent ]

{ #category : 'accessing' }
CFMotionExtentTrack >> targetValue: aPoint [ targetExtent := aPoint ]
