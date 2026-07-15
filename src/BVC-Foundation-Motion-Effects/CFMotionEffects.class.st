Class {
	#name : 'CFMotionEffects',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Motion-Effects',
	#package : 'BVC-Foundation-Motion-Effects'
}

{ #category : 'recipes' }
CFMotionEffects class >> riseAndFadeIn [
	^ (CFMotionEffectRecipe named: #riseAndFadeIn start: [ :element :duration :easing :recipe |
		self riseAndFadeIn: element distance: recipe distance duration: duration easing: easing ])
		distance: 12;
		yourself
]

{ #category : 'recipes' }
CFMotionEffects class >> fallAndFadeOut [
	^ (CFMotionEffectRecipe named: #fallAndFadeOut start: [ :element :duration :easing :recipe |
		self fallAndFadeOut: element distance: recipe distance duration: duration easing: easing ])
		distance: 12;
		yourself
]

{ #category : 'recipes' }
CFMotionEffects class >> scaleAndFadeIn [
	^ (CFMotionEffectRecipe named: #scaleAndFadeIn start: [ :element :duration :easing :recipe |
		self scaleAndFadeIn: element from: recipe scale duration: duration easing: easing ])
		scale: 0.8 @ 0.8;
		yourself
]

{ #category : 'recipes' }
CFMotionEffects class >> scaleAndFadeOut [
	^ (CFMotionEffectRecipe named: #scaleAndFadeOut start: [ :element :duration :easing :recipe |
		self scaleAndFadeOut: element to: recipe scale duration: duration easing: easing ])
		scale: 0.8 @ 0.8;
		yourself
]

{ #category : 'recipes' }
CFMotionEffects class >> compress [
	^ CFMotionEffectRecipe named: #compress start: [ :element :duration :easing :recipe |
		(element motion duration: duration; easing: easing; scale: 0.96 @ 0.96) ]
]

{ #category : 'recipes' }
CFMotionEffects class >> springBack [
	^ CFMotionEffectRecipe named: #springBack start: [ :element :duration :easing :recipe |
		(element motion duration: duration; easing: easing; scale: 1 @ 1) ]
]

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

{ #category : 'translation' }
CFMotionEffects class >> riseAndFadeIn: anElement [
	^ self
		riseAndFadeIn: anElement
		distance: 12
		duration: 180 milliSeconds
		easing: (BlDecelerateInterpolator factor: 1.4)
]

{ #category : 'translation' }
CFMotionEffects class >> riseAndFadeIn: anElement distance: aNumber duration: aDuration easing: anInterpolator [
	| operation opacity |
	anElement isAttachedToSceneGraph ifFalse: [
		self error: 'A rise-and-fade-in effect subject must be attached to a BlSpace' ].
	opacity := CFOpacityMotionProperty uniqueInstance.
	operation := CFMotionOperation
		coordinator: anElement space cfMotionCoordinator
		tracks: {
			CFMotionPropertyTrack on: anElement property: opacity target: 1.0.
			CFMotionTranslationTrack on: anElement from: 0 @ aNumber to: 0 @ 0 }.
	operation
		duration: aDuration;
		easing: anInterpolator;
		start.
	^ operation
]

{ #category : 'translation' }
CFMotionEffects class >> fallAndFadeOut: anElement [
	^ self
		fallAndFadeOut: anElement
		distance: 12
		duration: 180 milliSeconds
		easing: (BlDecelerateInterpolator factor: 1.4)
]

{ #category : 'translation' }
CFMotionEffects class >> fallAndFadeOut: anElement distance: aNumber duration: aDuration easing: anInterpolator [
	| operation opacity |
	anElement isAttachedToSceneGraph ifFalse: [
		self error: 'A fall-and-fade-out effect subject must be attached to a BlSpace' ].
	opacity := CFOpacityMotionProperty uniqueInstance.
	operation := CFMotionOperation
		coordinator: anElement space cfMotionCoordinator
		tracks: {
			CFMotionPropertyTrack on: anElement property: opacity target: 0.0.
			CFMotionTranslationTrack on: anElement from: 0 @ 0 to: 0 @ aNumber }.
	operation
		duration: aDuration;
		easing: anInterpolator;
		start.
	^ operation
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
