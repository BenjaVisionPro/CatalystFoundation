"
I represent the exclusive Motion property for scale transform contribution.

I provide stable property identity for ownership and retargeting while CFMotionScaleTrack performs presentation through the shared transform channel.
"
Class {
	#name : 'CFMotionScaleProperty',
	#superclass : 'CFMotionProperty',
	#classInstVars : [ 'uniqueInstance' ],
	#category : 'BVC-Motion-Core',
	#package : 'BVC-Motion-Core'
}

{ #category : 'instance creation' }
CFMotionScaleProperty class >> uniqueInstance [
	^ uniqueInstance ifNil: [ uniqueInstance := self new ]
]

{ #category : 'accessing' }
CFMotionScaleProperty >> apply: aValue to: anElement [
	self error: 'Scale motion is applied through a transform channel'
]

{ #category : 'accessing' }
CFMotionScaleProperty >> currentPresentationOf: anElement [
	self error: 'Scale motion is read through a transform channel'
]
