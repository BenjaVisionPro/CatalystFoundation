Class {
	#name : 'CFMotionBuilder',
	#superclass : 'Object',
	#instVars : [ 'element', 'duration', 'easing' ],
	#category : 'BVC-Foundation-Motion-Core',
	#package : 'BVC-Foundation-Motion-Core'
}

{ #category : 'instance creation' }
CFMotionBuilder class >> on: anElement [
	^ self new element: anElement; yourself
]

{ #category : 'initialization' }
CFMotionBuilder >> initialize [
	super initialize.
	duration := 180 milliSeconds.
	easing := BlDecelerateInterpolator factor: 1.4
]

{ #category : 'accessing' }
CFMotionBuilder >> element: anElement [ element := anElement ]

{ #category : 'configuration' }
CFMotionBuilder >> duration: aDuration [ duration := aDuration ]

{ #category : 'configuration' }
CFMotionBuilder >> easing: anInterpolator [ easing := anInterpolator ]

{ #category : 'building' }
CFMotionBuilder >> layout [
	element isAttachedToSceneGraph
		ifFalse: [ self error: 'A layout motion subject must be attached to a BlSpace' ].
	^ (CFMotionLayoutTransaction on: element)
		duration: duration;
		easing: easing;
		yourself
]

{ #category : 'playing' }
CFMotionBuilder >> opacity: aNumber [
	element isAttachedToSceneGraph
		ifFalse: [ self error: 'A motion subject must be attached to a BlSpace' ].
	^ element space cfMotionCoordinator
		retarget: (CFMotionPropertyTrack
			on: element
			property: CFOpacityMotionProperty uniqueInstance
			target: aNumber)
		duration: duration
		easing: easing
]

{ #category : 'playing' }
CFMotionBuilder >> scale: aPoint [
	element isAttachedToSceneGraph
		ifFalse: [ self error: 'A motion subject must be attached to a BlSpace' ].
	^ element space cfMotionCoordinator
		retarget: ((CFMotionScaleTrack on: element from: 1 @ 1 to: aPoint)
			adoptAtDestination)
		duration: duration
		easing: easing
]

{ #category : 'playing' }
CFMotionBuilder >> rotation: aNumber [
	element isAttachedToSceneGraph
		ifFalse: [ self error: 'A motion subject must be attached to a BlSpace' ].
	^ element space cfMotionCoordinator
		retarget: ((CFMotionRotationTrack on: element from: 0 to: aNumber)
			adoptAtDestination)
		duration: duration
		easing: easing
]

{ #category : 'playing' }
CFMotionBuilder >> translation: aPoint [
	element isAttachedToSceneGraph
		ifFalse: [ self error: 'A motion subject must be attached to a BlSpace' ].
	^ element space cfMotionCoordinator
		retarget: ((CFMotionTranslationTrack on: element from: 0 @ 0 to: aPoint)
			adoptAtDestination)
		duration: duration
		easing: easing
]

{ #category : 'playing' }
CFMotionBuilder >> verticalExtent: aNumber [
	element isAttachedToSceneGraph
		ifFalse: [ self error: 'A motion subject must be attached to a BlSpace' ].
	^ element space cfMotionCoordinator
		retarget: (CFMotionVerticalExtentTrack
			on: element
			from: element extent y
			to: aNumber)
		duration: duration
		easing: easing
]
