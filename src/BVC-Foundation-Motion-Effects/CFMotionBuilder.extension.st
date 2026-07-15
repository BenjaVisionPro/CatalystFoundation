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
CFMotionBuilder >> riseAndFadeIn [
	^ CFMotionEffects
		riseAndFadeIn: element
		distance: 12
		duration: duration
		easing: easing
]

{ #category : '*BVC-Foundation-Motion-Effects' }
CFMotionBuilder >> fallAndFadeOut [
	^ CFMotionEffects
		fallAndFadeOut: element
		distance: 12
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
CFMotionBuilder >> scaleAndFadeIn [
	^ CFMotionEffects
		scaleAndFadeIn: element
		from: 0.8 @ 0.8
		duration: duration
		easing: easing
]

{ #category : '*BVC-Foundation-Motion-Effects' }
CFMotionBuilder >> scaleAndFadeOut [
	^ CFMotionEffects
		scaleAndFadeOut: element
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
CFMotionBuilder >> appear: anElement using: anEffect [
	^ CFMotionAppearanceOperation
		appear: anElement
		in: element
		using: anEffect
		duration: duration
		easing: easing
]

{ #category : '*BVC-Foundation-Motion-Effects' }
CFMotionBuilder >> adopt: aPreview as: aCommittedElement [
	^ CFMotionAdoptionOperation
		adopt: aPreview
		as: aCommittedElement
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

{ #category : '*BVC-Foundation-Motion-Effects' }
CFMotionBuilder >> disappearUsing: anEffect [
	^ CFMotionAppearanceOperation
		disappear: element
		using: anEffect
		duration: duration
		easing: easing
]
