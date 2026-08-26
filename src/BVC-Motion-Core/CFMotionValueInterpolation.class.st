"
I represent a finite Motion Behaviour that interpolates one CFMotionValue between explicit endpoints.

I am a tween inside one placed timeline clip. I consume progress supplied by my timeline track and apply the corresponding value. Temporal placement, easing, repetition, playback and transitions between clips remain responsibilities of the surrounding composition.
"
Class {
	#name : 'CFMotionValueInterpolation',
	#superclass : 'CFMotionBehaviour',
	#instVars : [ 'motionValue', 'startValue', 'targetValue', 'interpolator' ],
	#category : 'BVC-Motion-Core-Values',
	#package : 'BVC-Motion-Core'
}

{ #category : 'instance creation' }
CFMotionValueInterpolation class >> on: aMotionValue from: aStartValue to: anEndValue [
	^ self new
		motionValue: aMotionValue;
		startValue: aStartValue;
		targetValue: anEndValue;
		interpolator: [ :start :end :progress | (end - start) * progress + start ];
		yourself
]

{ #category : 'instance creation' }
CFMotionValueInterpolation class >> on: aMotionValue from: aStartValue to: anEndValue using: anInterpolator [
	^ self new
		motionValue: aMotionValue;
		startValue: aStartValue;
		targetValue: anEndValue;
		interpolator: anInterpolator;
		yourself
]

{ #category : 'playing' }
CFMotionValueInterpolation >> applyDestination [
	motionValue value: targetValue
]

{ #category : 'playing' }
CFMotionValueInterpolation >> applyProgress: aProgress [
	motionValue value: (interpolator value: startValue value: targetValue value: aProgress)
]

{ #category : 'accessing' }
CFMotionValueInterpolation >> interpolator [
	^ interpolator
]

{ #category : 'private - initialization' }
CFMotionValueInterpolation >> interpolator: aThreeArgumentBlock [
	interpolator := aThreeArgumentBlock
]

{ #category : 'accessing' }
CFMotionValueInterpolation >> motionValue [
	^ motionValue
]

{ #category : 'private - initialization' }
CFMotionValueInterpolation >> motionValue: aMotionValue [
	(aMotionValue respondsTo: #value) ifFalse: [
		self error: 'A Motion value interpolation needs a target answering #value' ].
	(aMotionValue respondsTo: #value:) ifFalse: [
		self error: 'A Motion value interpolation needs a target answering #value:' ].
	motionValue := aMotionValue
]

{ #category : 'accessing' }
CFMotionValueInterpolation >> propertyKey [
	^ motionValue
]

{ #category : 'playing' }
CFMotionValueInterpolation >> prepareForTimelineCycle: aCycleIndex [
	aCycleIndex isZero ifFalse: [ motionValue value: startValue ]
]

{ #category : 'playing' }
CFMotionValueInterpolation >> restoreOrigin [
	motionValue value: startValue
]

{ #category : 'controlling' }
CFMotionValueInterpolation >> reversed [
	^ self class on: motionValue from: targetValue to: startValue using: interpolator
]

{ #category : 'accessing' }
CFMotionValueInterpolation >> startValue [
	^ startValue
]

{ #category : 'private - initialization' }
CFMotionValueInterpolation >> startValue: anObject [
	startValue := anObject
]

{ #category : 'accessing' }
CFMotionValueInterpolation >> targetValue [
	^ targetValue
]

{ #category : 'accessing' }
CFMotionValueInterpolation >> targetValue: anObject [
	targetValue := anObject
]
