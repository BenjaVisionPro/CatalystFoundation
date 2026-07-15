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
