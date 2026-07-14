Class {
	#name : 'CFOpacityMotionProperty',
	#superclass : 'CFMotionProperty',
	#classInstVars : [ 'uniqueInstance' ],
	#category : 'BVC-Foundation-Motion-Core',
	#package : 'BVC-Foundation-Motion-Core'
}

{ #category : 'instance creation' }
CFOpacityMotionProperty class >> uniqueInstance [
	^ uniqueInstance ifNil: [ uniqueInstance := self new ]
]

{ #category : 'accessing' }
CFOpacityMotionProperty >> valueOf: anElement [ ^ anElement opacity ]

{ #category : 'accessing' }
CFOpacityMotionProperty >> value: aNumber of: anElement [ anElement opacity: aNumber ]
