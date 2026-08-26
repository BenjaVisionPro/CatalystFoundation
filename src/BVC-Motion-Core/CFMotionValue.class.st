"
I represent a mutable value that can participate in Motion timelines without requiring a Bloc element.

I create CFMotionValueInterpolations between values, including custom interpolation strategies. I am useful for deterministic temporal composition of non-visual or application-defined values.
"
Class {
	#name : 'CFMotionValue',
	#superclass : 'Object',
	#instVars : [ 'value' ],
	#category : 'BVC-Motion-Core-Values',
	#package : 'BVC-Motion-Core'
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

{ #category : 'motion - interpolation' }
CFMotionValue >> interpolateFrom: aStartValue to: anEndValue [
	^ CFMotionValueInterpolation
		on: self
		from: aStartValue
		to: anEndValue
]

{ #category : 'motion - interpolation' }
CFMotionValue >> interpolateFrom: aStartValue to: anEndValue using: anInterpolator [
	^ CFMotionValueInterpolation
		on: self
		from: aStartValue
		to: anEndValue
		using: anInterpolator
]

{ #category : 'motion - interpolation' }
CFMotionValue >> interpolateTo: anEndValue [
	^ self interpolateFrom: value to: anEndValue
]

{ #category : 'motion - interpolation' }
CFMotionValue >> interpolateTo: anEndValue using: anInterpolator [
	^ self interpolateFrom: value to: anEndValue using: anInterpolator
]

{ #category : 'compatibility' }
CFMotionValue >> transitionFrom: aStartValue to: anEndValue [
	^ self interpolateFrom: aStartValue to: anEndValue
]

{ #category : 'compatibility' }
CFMotionValue >> transitionFrom: aStartValue to: anEndValue using: anInterpolator [
	^ self interpolateFrom: aStartValue to: anEndValue using: anInterpolator
]

{ #category : 'compatibility' }
CFMotionValue >> transitionTo: anEndValue [
	^ self interpolateTo: anEndValue
]

{ #category : 'compatibility' }
CFMotionValue >> transitionTo: anEndValue using: anInterpolator [
	^ self interpolateTo: anEndValue using: anInterpolator
]
