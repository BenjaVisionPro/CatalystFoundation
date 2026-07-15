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

{ #category : 'appearance' }
CFMotionEffects class >> scaleAndFadeIn: anElement [
	^ self
		scaleAndFadeIn: anElement
		from: 0.8 @ 0.8
		duration: 180 milliSeconds
		easing: (BlDecelerateInterpolator factor: 1.4)
]

{ #category : 'appearance' }
CFMotionEffects class >> scaleAndFadeIn: anElement from: aScale duration: aDuration easing: anInterpolator [
	| operation opacity |
	anElement isAttachedToSceneGraph ifFalse: [
		self error: 'A scale-and-fade-in effect subject must be attached to a BlSpace' ].
	opacity := CFOpacityMotionProperty uniqueInstance.
	operation := CFMotionOperation
		coordinator: anElement space cfMotionCoordinator
		tracks: {
			CFMotionPropertyTrack on: anElement property: opacity target: 1.0.
			CFMotionScaleTrack on: anElement from: aScale to: 1 @ 1 }.
	operation
		duration: aDuration;
		easing: anInterpolator;
		start.
	^ operation
]

{ #category : 'appearance' }
CFMotionEffects class >> scaleAndFadeOut: anElement [
	^ self
		scaleAndFadeOut: anElement
		to: 0.8 @ 0.8
		duration: 180 milliSeconds
		easing: (BlDecelerateInterpolator factor: 1.4)
]

{ #category : 'appearance' }
CFMotionEffects class >> scaleAndFadeOut: anElement to: aScale duration: aDuration easing: anInterpolator [
	| operation opacity |
	anElement isAttachedToSceneGraph ifFalse: [
		self error: 'A scale-and-fade-out effect subject must be attached to a BlSpace' ].
	opacity := CFOpacityMotionProperty uniqueInstance.
	operation := CFMotionOperation
		coordinator: anElement space cfMotionCoordinator
		tracks: {
			CFMotionPropertyTrack on: anElement property: opacity target: 0.0.
			CFMotionScaleTrack on: anElement from: 1 @ 1 to: aScale }.
	operation
		duration: aDuration;
		easing: anInterpolator;
		start.
	^ operation
]

{ #category : 'scaling' }
CFMotionEffects class >> scaleIn: anElement [
	^ self
		scaleIn: anElement
		from: 0.8 @ 0.8
		duration: 180 milliSeconds
		easing: (BlDecelerateInterpolator factor: 1.4)
]

{ #category : 'scaling' }
CFMotionEffects class >> scaleIn: anElement from: aScale duration: aDuration easing: anInterpolator [
	| operation |
	anElement isAttachedToSceneGraph ifFalse: [
		self error: 'A scale effect subject must be attached to a BlSpace' ].
	operation := CFMotionOperation
		coordinator: anElement space cfMotionCoordinator
		tracks: { CFMotionScaleTrack on: anElement from: aScale to: 1 @ 1 }.
	operation
		duration: aDuration;
		easing: anInterpolator;
		start.
	^ operation
]
