Extension { #name : 'CFMotionBuilder' }

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
CFMotionBuilder >> appear: anElement using: aMotionBuilder [
	^ CFMotionAppearanceOperation
		appear: anElement
		in: element
		using: aMotionBuilder
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
CFMotionBuilder >> adopt: aPreview as: aCommittedElement from: aSourceContainer [
	^ CFMotionAdoptionOperation adopt: aPreview as: aCommittedElement from: aSourceContainer to: element duration: duration easing: easing
]

{ #category : '*BVC-Foundation-Motion-Effects' }
CFMotionBuilder >> disappear [
	^ CFMotionAppearanceOperation
		disappear: element
		duration: duration
		easing: easing
]

{ #category : '*BVC-Foundation-Motion-Effects' }
CFMotionBuilder >> disappearUsing: aMotionBuilder [
	^ CFMotionAppearanceOperation
		disappear: element
		using: aMotionBuilder
		duration: duration
		easing: easing
]
