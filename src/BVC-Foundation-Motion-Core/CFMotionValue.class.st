"
I represent a mutable value that can participate in Motion timelines without requiring a Bloc element.

I create CFMotionValueTransitions to interpolate between values, including custom interpolation strategies. I am useful for deterministic temporal composition of non-visual or application-defined values.
"
Class {
	#name : 'CFMotionValue',
	#superclass : 'Object',
	#instVars : [ 'value' ],
	#category : 'BVC-Foundation-Motion-Core-Values',
	#package : 'BVC-Foundation-Motion-Core'
}

{ #category : 'instance creation' }
CFMotionValue class >> value: anObject [
	^ self new
		value: anObject;
		yourself
]

{ #category : 'accessing' }
CFMotionValue >> value [
	^ value
]

{ #category : 'accessing' }
CFMotionValue >> value: anObject [
	value := anObject.
	^ self
]

{ #category : 'motion' }
CFMotionValue >> transitionFrom: aStartValue to: anEndValue [
	^ CFMotionValueTransition
		on: self
		from: aStartValue
		to: anEndValue
]

{ #category : 'motion' }
CFMotionValue >> transitionTo: anEndValue [
	^ self transitionFrom: value to: anEndValue
]


{ #category : 'motion' }
CFMotionValue >> transitionFrom: aStartValue to: anEndValue using: anInterpolator [
	^ CFMotionValueTransition
		on: self
		from: aStartValue
		to: anEndValue
		using: anInterpolator
]

{ #category : 'motion' }
CFMotionValue >> transitionTo: anEndValue using: anInterpolator [
	^ self transitionFrom: value to: anEndValue using: anInterpolator
]
