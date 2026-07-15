Class {
	#name : 'CFMotionRotationProperty',
	#superclass : 'CFMotionProperty',
	#classInstVars : [ 'uniqueInstance' ],
	#category : 'BVC-Foundation-Motion-Core',
	#package : 'BVC-Foundation-Motion-Core'
}

{ #category : 'instance creation' }
CFMotionRotationProperty class >> uniqueInstance [
	^ uniqueInstance ifNil: [ uniqueInstance := self new ]
]

{ #category : 'accessing' }
CFMotionRotationProperty >> apply: aValue to: anElement [
	self error: 'Rotation motion is applied through a transform channel'
]

{ #category : 'accessing' }
CFMotionRotationProperty >> currentPresentationOf: anElement [
	self error: 'Rotation motion is read through a transform channel'
]
