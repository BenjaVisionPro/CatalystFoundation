Class {
	#name : 'CFMotionScaleProperty',
	#superclass : 'CFMotionProperty',
	#classInstVars : [ 'uniqueInstance' ],
	#category : 'BVC-Foundation-Motion-Core',
	#package : 'BVC-Foundation-Motion-Core'
}

{ #category : 'instance creation' }
CFMotionScaleProperty class >> uniqueInstance [
	^ uniqueInstance ifNil: [ uniqueInstance := self new ]
]

{ #category : 'accessing' }
CFMotionScaleProperty >> apply: aValue to: anElement [
	self error: 'Scale motion is applied through a transform channel'
]

{ #category : 'accessing' }
CFMotionScaleProperty >> currentPresentationOf: anElement [
	self error: 'Scale motion is read through a transform channel'
]
