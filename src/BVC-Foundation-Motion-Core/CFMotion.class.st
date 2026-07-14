Class {
	#name : 'CFMotion',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Motion-Core',
	#package : 'BVC-Foundation-Motion-Core'
}

{ #category : 'instance creation' }
CFMotion class >> on: anElement [
	^ CFMotionBuilder on: anElement
]

{ #category : 'instance creation' }
CFMotion class >> layoutIn: aCoordinateSpace [
	^ CFMotionLayoutTransaction in: aCoordinateSpace
]
