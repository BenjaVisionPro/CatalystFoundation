"
I am an ordinary value whose current value may be animated by Motion.

I deliberately expose only the familiar #value and #value: protocol. Domains may distribute me wherever a live value is needed, while Motion composes transitions that write me over time. I own no clock, timeline, easing or repetition policy.
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
