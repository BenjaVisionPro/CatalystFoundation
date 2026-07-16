Class {
	#name : 'CFMotionExtentProperty',
	#superclass : 'CFMotionProperty',
	#classInstVars : [ 'uniqueInstance' ],
	#category : 'BVC-Foundation-Motion-Core',
	#package : 'BVC-Foundation-Motion-Core'
}

{ #category : 'instance creation' }
CFMotionExtentProperty class >> uniqueInstance [
	^ uniqueInstance ifNil: [ uniqueInstance := self new ]
]

{ #category : 'accessing' }
CFMotionExtentProperty >> apply: anExtent to: anElement [
	anElement constraintsDo: [ :c |
		c horizontal exact: anExtent x.
		c vertical exact: anExtent y ]
]

{ #category : 'accessing' }
CFMotionExtentProperty >> currentPresentationOf: anElement [
	^ anElement extent
]
