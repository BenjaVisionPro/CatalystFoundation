"
I represent a finite Motion Behaviour that interpolates one CFMotionValue between explicit endpoints.

I consume the progress supplied by my timeline track and apply the corresponding value. Temporal placement, easing, repetition and playback remain responsibilities of the surrounding timeline and track.
"
Class {
	#name : 'CFMotionValueTransition',
	#superclass : 'CFMotionBehaviour',
	#instVars : [ 'motionValue', 'startValue', 'targetValue', 'interpolator' ],
	#category : 'BVC-Foundation-Motion-Core-Values',
	#package : 'BVC-Foundation-Motion-Core'
}

{ #category : 'instance creation' }
CFMotionValueTransition class >> on: aMotionValue from: aStartValue to: anEndValue [
	^ self new
		motionValue: aMotionValue;
		startValue: aStartValue;
		targetValue: anEndValue;
		interpolator: [ :start :end :progress | (end - start) * progress + start ];
		yourself
]



{ #category : 'instance creation' }
CFMotionValueTransition class >> on: aMotionValue from: aStartValue to: anEndValue using: anInterpolator [
	^ self new
		motionValue: aMotionValue;
		startValue: aStartValue;
		targetValue: anEndValue;
		interpolator: anInterpolator;
		yourself
]

{ #category : 'playing' }
CFMotionValueTransition >> applyDestination [
	motionValue value: targetValue
]

{ #category : 'playing' }
CFMotionValueTransition >> applyProgress: aProgress [
	motionValue value: (interpolator value: startValue value: targetValue value: aProgress)
]

{ #category : 'accessing' }
CFMotionValueTransition >> interpolator [
	^ interpolator
]

{ #category : 'private - initialization' }
CFMotionValueTransition >> interpolator: aThreeArgumentBlock [
	interpolator := aThreeArgumentBlock
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
	^ self class on: motionValue from: targetValue to: startValue using: interpolator
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
