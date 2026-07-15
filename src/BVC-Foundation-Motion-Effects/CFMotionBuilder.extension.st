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
CFMotionBuilder >> appear: anElement [
	^ CFMotionAppearanceOperation
		appear: anElement
		in: element
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
