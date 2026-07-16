Class {
	#name : 'CFMotionVerticalExtentProperty',
	#superclass : 'CFMotionProperty',
	#classInstVars : [ 'uniqueInstance' ],
	#category : 'BVC-Foundation-Motion-Core',
	#package : 'BVC-Foundation-Motion-Core'
}

{ #category : 'instance creation' }
CFMotionVerticalExtentProperty class >> uniqueInstance [
	^ uniqueInstance ifNil: [ uniqueInstance := self new ]
]

{ #category : 'accessing' }
CFMotionVerticalExtentProperty >> apply: aNumber to: anElement [
	anElement constraintsDo: [ :c | c vertical exact: aNumber ]
]

{ #category : 'accessing' }
CFMotionVerticalExtentProperty >> currentPresentationOf: anElement [
	^ anElement extent y
]
