Class {
	#name : 'CFVerticalExtentMotionProperty',
	#superclass : 'CFMotionProperty',
	#classInstVars : [ 'uniqueInstance' ],
	#category : 'BVC-Foundation-Motion-Core',
	#package : 'BVC-Foundation-Motion-Core'
}

{ #category : 'instance creation' }
CFVerticalExtentMotionProperty class >> uniqueInstance [
	^ uniqueInstance ifNil: [ uniqueInstance := self new ]
]

{ #category : 'accessing' }
CFVerticalExtentMotionProperty >> apply: aNumber to: anElement [
	anElement vExact: aNumber
]

{ #category : 'accessing' }
CFVerticalExtentMotionProperty >> currentPresentationOf: anElement [
	^ anElement extent y
]
