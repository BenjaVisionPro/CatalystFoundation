Class {
	#name : 'CFMotionEffects',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Motion-Effects',
	#package : 'BVC-Foundation-Motion-Effects'
}

{ #category : 'effects' }
CFMotionEffects class >> fadeIn [
	^ CFFadeMotionEffect to: 1.0
]

{ #category : 'effects' }
CFMotionEffects class >> fadeOut [
	^ CFFadeMotionEffect to: 0.0
]
