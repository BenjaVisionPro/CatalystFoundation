Class {
	#name : 'CFMotionEffects',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Motion-Effects',
	#package : 'BVC-Foundation-Motion-Effects'
}

{ #category : 'fading' }
CFMotionEffects class >> fadeIn: anElement [
	^ anElement motion opacity: 1.0
]

{ #category : 'fading' }
CFMotionEffects class >> fadeIn: anElement duration: aDuration easing: anInterpolator [
	^ (CFMotionBuilder on: anElement)
		duration: aDuration;
		easing: anInterpolator;
		opacity: 1.0
]

{ #category : 'fading' }
CFMotionEffects class >> fadeOut: anElement [
	^ anElement motion opacity: 0.0
]

{ #category : 'fading' }
CFMotionEffects class >> fadeOut: anElement duration: aDuration easing: anInterpolator [
	^ (CFMotionBuilder on: anElement)
		duration: aDuration;
		easing: anInterpolator;
		opacity: 0.0
]
