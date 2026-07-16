Class {
	#name : 'CFMotionGeometryProperty',
	#superclass : 'CFMotionProperty',
	#classInstVars : [ 'uniqueInstance' ],
	#category : 'BVC-Foundation-Motion-Core',
	#package : 'BVC-Foundation-Motion-Core'
}

{ #category : 'instance creation' }
CFMotionGeometryProperty class >> uniqueInstance [
	^ uniqueInstance ifNil: [ uniqueInstance := self new ]
]

{ #category : 'accessing' }
CFMotionGeometryProperty >> currentPresentationOf: anElement [
	^ anElement transformation
]

{ #category : 'accessing' }
CFMotionGeometryProperty >> apply: aTransformation to: anElement [
	anElement transformation: aTransformation
]
