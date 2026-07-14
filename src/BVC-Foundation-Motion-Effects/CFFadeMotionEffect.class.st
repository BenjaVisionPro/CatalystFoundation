Class {
	#name : 'CFFadeMotionEffect',
	#superclass : 'Object',
	#instVars : [ 'targetOpacity', 'duration', 'easing' ],
	#category : 'BVC-Foundation-Motion-Effects',
	#package : 'BVC-Foundation-Motion-Effects'
}

{ #category : 'instance creation' }
CFFadeMotionEffect class >> to: aNumber [
	^ self new targetOpacity: aNumber; yourself
]

{ #category : 'initialization' }
CFFadeMotionEffect >> initialize [
	super initialize.
	duration := 180 milliSeconds.
	easing := BlDecelerateInterpolator factor: 1.4
]

{ #category : 'accessing' }
CFFadeMotionEffect >> targetOpacity: aNumber [ targetOpacity := aNumber ]

{ #category : 'configuration' }
CFFadeMotionEffect >> duration: aDuration [ duration := aDuration ]

{ #category : 'configuration' }
CFFadeMotionEffect >> easing: anInterpolator [ easing := anInterpolator ]

{ #category : 'playing' }
CFFadeMotionEffect >> playOn: anElement [
	^ (CFMotion on: anElement)
		duration: duration;
		easing: easing;
		opacityTo: targetOpacity
]
