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
