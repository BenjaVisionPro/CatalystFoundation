Class {
	#name : 'CFMotionEffects',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Motion-Effects',
	#package : 'BVC-Foundation-Motion-Effects'
}

{ #category : 'fading' }
CFMotionEffects class >> crossFadeFrom: anOutgoingElement to: anIncomingElement [
	^ self
		crossFadeFrom: anOutgoingElement
		to: anIncomingElement
		duration: 180 milliSeconds
		easing: (BlDecelerateInterpolator factor: 1.4)
]

{ #category : 'fading' }
CFMotionEffects class >> crossFadeFrom: anOutgoingElement to: anIncomingElement duration: aDuration easing: anInterpolator [
	| operation opacity |
	anOutgoingElement == anIncomingElement ifTrue: [
		self error: 'A cross fade needs distinct outgoing and incoming elements' ].
	anOutgoingElement isAttachedToSceneGraph ifFalse: [
		self error: 'A cross fade outgoing element must be attached to a BlSpace' ].
	anIncomingElement isAttachedToSceneGraph ifFalse: [
		self error: 'A cross fade incoming element must be attached to a BlSpace' ].
	anOutgoingElement space == anIncomingElement space ifFalse: [
		self error: 'Cross fade elements must share a BlSpace' ].
	opacity := CFOpacityMotionProperty uniqueInstance.
	operation := CFMotionOperation
		coordinator: anOutgoingElement space cfMotionCoordinator
		tracks: {
			CFMotionPropertyTrack on: anOutgoingElement property: opacity target: 0.0.
			CFMotionPropertyTrack on: anIncomingElement property: opacity target: 1.0 }.
	operation
		duration: aDuration;
		easing: anInterpolator;
		start.
	^ operation
]

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
