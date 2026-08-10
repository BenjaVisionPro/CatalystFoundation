"
I represent the exclusive Motion property used to identify element-extent ownership.

I provide the property identity used by extent tracks and ownership keys. CFMotionExtentTrack performs the actual extent presentation work.
"
Class {
	#name : 'CFMotionExtentProperty',
	#superclass : 'CFMotionProperty',
	#classInstVars : [ 'uniqueInstance' ],
	#category : 'BVC-Motion-Core',
	#package : 'BVC-Motion-Core'
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
