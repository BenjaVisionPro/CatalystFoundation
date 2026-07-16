Class {
	#name : 'CFMotionTranslationProperty',
	#superclass : 'CFMotionProperty',
	#classInstVars : [ 'uniqueInstance' ],
	#category : 'BVC-Foundation-Motion-Core',
	#package : 'BVC-Foundation-Motion-Core'
}

{ #category : 'instance creation' }
CFMotionTranslationProperty class >> uniqueInstance [
	^ uniqueInstance ifNil: [ uniqueInstance := self new ]
]

{ #category : 'accessing' }
CFMotionTranslationProperty >> apply: aValue to: anElement [
	self error: 'Translation motion is applied through a transform channel'
]

{ #category : 'accessing' }
CFMotionTranslationProperty >> currentPresentationOf: anElement [
	self error: 'Translation motion is read through a transform channel'
]
