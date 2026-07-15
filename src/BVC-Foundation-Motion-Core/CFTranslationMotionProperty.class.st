Class {
	#name : 'CFTranslationMotionProperty',
	#superclass : 'CFMotionProperty',
	#classInstVars : [ 'uniqueInstance' ],
	#category : 'BVC-Foundation-Motion-Core',
	#package : 'BVC-Foundation-Motion-Core'
}

{ #category : 'instance creation' }
CFTranslationMotionProperty class >> uniqueInstance [
	^ uniqueInstance ifNil: [ uniqueInstance := self new ]
]

{ #category : 'accessing' }
CFTranslationMotionProperty >> apply: aValue to: anElement [
	self error: 'Translation motion is applied through a transform channel'
]

{ #category : 'accessing' }
CFTranslationMotionProperty >> currentPresentationOf: anElement [
	self error: 'Translation motion is read through a transform channel'
]
