Class {
	#name : 'CFGeometryMotionProperty',
	#superclass : 'CFMotionProperty',
	#classInstVars : [ 'uniqueInstance' ],
	#category : 'BVC-Foundation-Motion-Core',
	#package : 'BVC-Foundation-Motion-Core'
}

{ #category : 'instance creation' }
CFGeometryMotionProperty class >> uniqueInstance [
	^ uniqueInstance ifNil: [ uniqueInstance := self new ]
]

{ #category : 'accessing' }
CFGeometryMotionProperty >> currentPresentationOf: anElement [
	^ anElement transformation
]

{ #category : 'accessing' }
CFGeometryMotionProperty >> apply: aTransformation to: anElement [
	anElement transformation: aTransformation
]
