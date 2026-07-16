Class {
	#name : 'CFMotionBuilder',
	#superclass : 'Object',
	#instVars : [ 'element', 'duration', 'easing', 'opacity', 'scale', 'rotation', 'translation', 'sourceExtent', 'targetExtent', 'configuration', 'holdAtDestination' ],
	#category : 'BVC-Foundation-Motion-Core',
	#package : 'BVC-Foundation-Motion-Core'
}

{ #category : 'instance creation' }
CFMotionBuilder class >> configure: aBlock [
	^ self new
		configure: aBlock;
		yourself
]

{ #category : 'instance creation' }
CFMotionBuilder class >> on: anElement [
	^ self new element: anElement; yourself
]

{ #category : 'standard motions' }
CFMotionBuilder class >> compress [
	^ self new
		holdAtDestination;
		configure: [ :anElement |
			{ CFMotionScaleTrack on: anElement from: 1 @ 1 to: 0.96 @ 0.96 } ];
		yourself
]

{ #category : 'standard motions' }
CFMotionBuilder class >> fadeIn [
	^ self configure: [ :anElement |
		{ CFMotionPropertyTrack
			on: anElement
			property: CFMotionOpacityProperty uniqueInstance
			target: 1.0 } ]
]

{ #category : 'standard motions' }
CFMotionBuilder class >> fadeOut [
	^ self configure: [ :anElement |
		{ CFMotionPropertyTrack
			on: anElement
			property: CFMotionOpacityProperty uniqueInstance
			target: 0.0 } ]
]

{ #category : 'standard motions' }
CFMotionBuilder class >> fallAndFadeOut [
	^ self configure: [ :anElement |
		{ CFMotionPropertyTrack
			on: anElement
			property: CFMotionOpacityProperty uniqueInstance
			target: 0.0.
		CFMotionTranslationTrack on: anElement from: 0 @ 0 to: 0 @ 12 } ]
]

{ #category : 'standard motions' }
CFMotionBuilder class >> riseAndFadeIn [
	^ self configure: [ :anElement |
		{ CFMotionPropertyTrack
			on: anElement
			property: CFMotionOpacityProperty uniqueInstance
			target: 1.0.
		CFMotionTranslationTrack on: anElement from: 0 @ 12 to: 0 @ 0 } ]
]

{ #category : 'standard motions' }
CFMotionBuilder class >> scaleAndFadeIn [
	^ self configure: [ :anElement |
		{ CFMotionPropertyTrack
			on: anElement
			property: CFMotionOpacityProperty uniqueInstance
			target: 1.0.
		CFMotionScaleTrack on: anElement from: 0.8 @ 0.8 to: 1 @ 1 } ]
]

{ #category : 'standard motions' }
CFMotionBuilder class >> scaleAndFadeOut [
	^ self configure: [ :anElement |
		{ CFMotionPropertyTrack
			on: anElement
			property: CFMotionOpacityProperty uniqueInstance
			target: 0.0.
		CFMotionScaleTrack on: anElement from: 1 @ 1 to: 0.8 @ 0.8 } ]
]

{ #category : 'standard motions' }
CFMotionBuilder class >> scaleIn [
	^ self configure: [ :anElement |
		{ CFMotionScaleTrack on: anElement from: 0.8 @ 0.8 to: 1 @ 1 } ]
]

{ #category : 'standard motions' }
CFMotionBuilder class >> scaleOut [
	^ self configure: [ :anElement |
		{ CFMotionScaleTrack on: anElement from: 1 @ 1 to: 0.8 @ 0.8 } ]
]

{ #category : 'initialization' }
CFMotionBuilder >> initialize [
	super initialize.
	duration := 180 milliSeconds.
	easing := BlDecelerateInterpolator factor: 1.4.
	holdAtDestination := false
]

{ #category : 'building' }
CFMotionBuilder >> build [
	| motion |
	element ifNil: [ self error: 'A Motion builder needs an element before it can build a Motion' ].
	element isAttachedToSceneGraph ifFalse: [
		self error: 'A Motion subject must be attached to a BlSpace' ].
	motion := (CFMotion
		coordinator: element space cfMotionCoordinator
		tracks: self buildTracks)
		duration: duration;
		easing: easing;
		yourself.
	holdAtDestination ifTrue: [ motion holdAtDestination ].
	^ motion
]

{ #category : 'private - building' }
CFMotionBuilder >> buildTracks [
	| tracks track |
	tracks := OrderedCollection new.
	opacity ifNotNil: [
		tracks add: (CFMotionPropertyTrack
			on: element
			property: CFMotionOpacityProperty uniqueInstance
			target: opacity) ].
	scale ifNotNil: [
		track := CFMotionScaleTrack on: element from: 1 @ 1 to: scale.
		track adoptAtDestination.
		tracks add: track ].
	rotation ifNotNil: [
		track := CFMotionRotationTrack on: element from: 0 to: rotation.
		track adoptAtDestination.
		tracks add: track ].
	translation ifNotNil: [
		track := CFMotionTranslationTrack on: element from: 0 @ 0 to: translation.
		track adoptAtDestination.
		tracks add: track ].
	targetExtent ifNotNil: [
		tracks add: (CFMotionExtentTrack
			on: element
			from: sourceExtent
			to: targetExtent) ].
	configuration ifNotNil: [ tracks addAll: (configuration value: element) ].
	tracks isEmpty ifTrue: [ self error: 'A Motion builder needs at least one track' ].
	^ tracks
]

{ #category : 'configuration' }
CFMotionBuilder >> configure: aBlock [
	configuration := aBlock.
	^ self
]

{ #category : 'configuration' }
CFMotionBuilder >> duration: aDuration [
	duration := aDuration.
	^ self
]

{ #category : 'configuration' }
CFMotionBuilder >> easing: anInterpolator [
	easing := anInterpolator.
	^ self
]

{ #category : 'accessing' }
CFMotionBuilder >> element [ ^ element ]

{ #category : 'configuration' }
CFMotionBuilder >> element: anElement [
	element := anElement.
	^ self
]

{ #category : 'playing' }
CFMotionBuilder >> geometry: aRectangle [
	^ self mutateLayout: [
		element
			relocate: aRectangle origin;
			size: aRectangle extent ]
]

{ #category : 'configuration' }
CFMotionBuilder >> holdAtDestination [
	holdAtDestination := true.
	^ self
]

{ #category : 'configuration' }
CFMotionBuilder >> horizontalExtent: aNumber [
	| currentExtent |
	currentExtent := element extent.
	^ self
		extentFrom: currentExtent
		to: aNumber @ currentExtent y
]

{ #category : 'building' }
CFMotionBuilder >> layout [
	element isAttachedToSceneGraph
		ifFalse: [ self error: 'A layout motion subject must be attached to a BlSpace' ].
	^ (CFMotionLayoutTransaction on: element)
		duration: duration;
		easing: easing;
		yourself
]

{ #category : 'private - playing' }
CFMotionBuilder >> mutateLayout: aBlock [
	element hasParent ifFalse: [
		self error: 'A simple layout motion subject must belong to a container' ].
	^ (CFMotionLayoutTransaction on: element parent)
		duration: duration;
		easing: easing;
		affecting: { element };
		mutate: aBlock;
		play
]

{ #category : 'configuration' }
CFMotionBuilder >> opacity: aNumber [
	opacity := aNumber.
	^ self
]

{ #category : 'playing' }
CFMotionBuilder >> relocate: aPoint [
	^ self mutateLayout: [ element relocate: aPoint ]
]

{ #category : 'configuration' }
CFMotionBuilder >> rotation: aNumber [
	rotation := aNumber.
	^ self
]

{ #category : 'configuration' }
CFMotionBuilder >> scale: aPoint [
	scale := aPoint.
	^ self
]

{ #category : 'playing' }
CFMotionBuilder >> resize: anExtent [
	^ self mutateLayout: [ element size: anExtent ]
]

{ #category : 'configuration' }
CFMotionBuilder >> translation: aPoint [
	translation := aPoint.
	^ self
]

{ #category : 'configuration' }
CFMotionBuilder >> extentFrom: aSourceExtent to: aTargetExtent [
	sourceExtent := aSourceExtent.
	targetExtent := aTargetExtent.
	^ self
]

{ #category : 'configuration' }
CFMotionBuilder >> verticalExtent: aNumber [
	| currentExtent |
	currentExtent := element extent.
	^ self
		extentFrom: currentExtent
		to: currentExtent x @ aNumber
]
