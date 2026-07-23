"
I am one Motion Behaviour that interpolates a CFMotionValue between two explicit values.

Temporal placement, easing, repetition and playback all belong to CFMotionTimeline and CFMotionTimelineTrack. I only apply the progress supplied by my track. Explicit endpoints make sequential and repeating compositions deterministic: every occurrence describes the same transition and does not depend on when another track happened to prepare.
"
Class {
	#name : 'CFMotionValueTransition',
	#superclass : 'CFMotionBehaviour',
	#instVars : [ 'motionValue', 'startValue', 'targetValue' ],
	#category : 'BVC-Foundation-Motion-Core-Values',
	#package : 'BVC-Foundation-Motion-Core'
}

{ #category : 'instance creation' }
CFMotionValueTransition class >> on: aMotionValue from: aStartValue to: anEndValue [
	^ self new
		motionValue: aMotionValue;
		startValue: aStartValue;
		targetValue: anEndValue;
		yourself
]

{ #category : 'playing' }
CFMotionValueTransition >> applyDestination [
	motionValue value: targetValue
]

{ #category : 'playing' }
CFMotionValueTransition >> applyProgress: aProgress [
	motionValue value: ((targetValue - startValue) * aProgress + startValue)
]

{ #category : 'accessing' }
CFMotionValueTransition >> motionValue [
	^ motionValue
]

{ #category : 'private - initialization' }
CFMotionValueTransition >> motionValue: aMotionValue [
	(aMotionValue respondsTo: #value) ifFalse: [
		self error: 'A Motion value transition needs a target answering #value' ].
	(aMotionValue respondsTo: #value:) ifFalse: [
		self error: 'A Motion value transition needs a target answering #value:' ].
	motionValue := aMotionValue
]

{ #category : 'accessing' }
CFMotionValueTransition >> propertyKey [
	^ motionValue
]

{ #category : 'controlling' }
CFMotionValueTransition >> reversed [
	^ self class on: motionValue from: targetValue to: startValue
]

{ #category : 'accessing' }
CFMotionValueTransition >> startValue [
	^ startValue
]

{ #category : 'private - initialization' }
CFMotionValueTransition >> startValue: anObject [
	startValue := anObject
]

{ #category : 'accessing' }
CFMotionValueTransition >> targetValue [
	^ targetValue
]

{ #category : 'accessing' }
CFMotionValueTransition >> targetValue: anObject [
	targetValue := anObject
]
