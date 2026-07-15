Class {
	#name : 'CFScaleMotionProperty',
	#superclass : 'CFMotionProperty',
	#classInstVars : [ 'uniqueInstance' ],
	#category : 'BVC-Foundation-Motion-Core',
	#package : 'BVC-Foundation-Motion-Core'
}

{ #category : 'instance creation' }
CFScaleMotionProperty class >> uniqueInstance [
	^ uniqueInstance ifNil: [ uniqueInstance := self new ]
]

{ #category : 'accessing' }
CFScaleMotionProperty >> apply: aValue to: anElement [
	self error: 'Scale motion is applied through a transform channel'
]

{ #category : 'accessing' }
CFScaleMotionProperty >> currentPresentationOf: anElement [
	self error: 'Scale motion is read through a transform channel'
]
