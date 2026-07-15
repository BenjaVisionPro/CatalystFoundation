Extension { #name : 'CFMotionBuilder' }

{ #category : '*BVC-Foundation-Motion-Effects' }
CFMotionBuilder >> fadeIn [
	^ CFMotionEffects
		fadeIn: element
		duration: duration
		easing: easing
]

{ #category : '*BVC-Foundation-Motion-Effects' }
CFMotionBuilder >> fadeOut [
	^ CFMotionEffects
		fadeOut: element
		duration: duration
		easing: easing
]

{ #category : '*BVC-Foundation-Motion-Effects' }
CFMotionBuilder >> scaleIn [
	^ CFMotionEffects
		scaleIn: element
		from: 0.8 @ 0.8
		duration: duration
		easing: easing
]

{ #category : '*BVC-Foundation-Motion-Effects' }
CFMotionBuilder >> popIn [
	^ CFMotionEffects
		popIn: element
		from: 0.8 @ 0.8
		duration: duration
		easing: easing
]

{ #category : '*BVC-Foundation-Motion-Effects' }
CFMotionBuilder >> popOut [
	^ CFMotionEffects
		popOut: element
		to: 0.8 @ 0.8
		duration: duration
		easing: easing
]

{ #category : '*BVC-Foundation-Motion-Effects' }
CFMotionBuilder >> appear: anElement [
	^ CFMotionAppearanceOperation
		appear: anElement
		in: element
		duration: duration
		easing: easing
]

{ #category : '*BVC-Foundation-Motion-Effects' }
CFMotionBuilder >> appear: anElement at: anIndex [
	^ CFMotionAppearanceOperation
		appear: anElement
		in: element
		at: anIndex
		duration: duration
		easing: easing
]

{ #category : '*BVC-Foundation-Motion-Effects' }
CFMotionBuilder >> disappear [
	^ CFMotionAppearanceOperation
		disappear: element
		duration: duration
		easing: easing
]
