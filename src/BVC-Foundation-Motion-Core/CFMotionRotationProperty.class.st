"
I represent the exclusive Motion property for rotational transform contribution.

I provide stable property identity for ownership and retargeting while CFMotionRotationTrack performs presentation through the shared transform channel.
"
Class {
	#name : 'CFMotionRotationProperty',
	#superclass : 'CFMotionProperty',
	#classInstVars : [ 'uniqueInstance' ],
	#category : 'BVC-Foundation-Motion-Core',
	#package : 'BVC-Foundation-Motion-Core'
}

{ #category : 'instance creation' }
CFMotionRotationProperty class >> uniqueInstance [
	^ uniqueInstance ifNil: [ uniqueInstance := self new ]
]

{ #category : 'accessing' }
CFMotionRotationProperty >> apply: aValue to: anElement [
	self error: 'Rotation motion is applied through a transform channel'
]

{ #category : 'accessing' }
CFMotionRotationProperty >> currentPresentationOf: anElement [
	self error: 'Rotation motion is read through a transform channel'
]
