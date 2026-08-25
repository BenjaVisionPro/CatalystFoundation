"
I represent a finite Motion Behaviour that interpolates one CFMotionProperty on one element.

I capture the original presentation, interpolate from the current presentation to a target value, support retargeting and reversal, and participate in the coordinator's exclusive property ownership.
"
Class {
	#name : 'CFMotionPropertyTrack',
	#superclass : 'CFMotionBehaviour',
	#instVars : [ 'element', 'property', 'targetValue', 'originValue', 'startValue', 'entryValue' ],
	#category : 'BVC-Motion-Core',
	#package : 'BVC-Motion-Core'
}

{ #category : 'instance creation' }
CFMotionPropertyTrack class >> on: anElement property: aProperty target: aValue [
	^ self new
		element: anElement;
		property: aProperty;
		targetValue: aValue;
		yourself
]

{ #category : 'accessing' }
CFMotionPropertyTrack >> animationTarget [ ^ element ]

{ #category : 'playing' }
CFMotionPropertyTrack >> applyDestination [
	property apply: targetValue to: element
]

{ #category : 'playing' }
CFMotionPropertyTrack >> applyProgress: aProgress [
	property
		apply: ((targetValue - startValue) * aProgress + startValue)
		to: element
]

{ #category : 'playing' }
CFMotionPropertyTrack >> captureOrigin [
	originValue ifNil: [ originValue := property currentPresentationOf: element ]
]

{ #category : 'accessing' }
CFMotionPropertyTrack >> element [ ^ element ]

{ #category : 'accessing' }
CFMotionPropertyTrack >> element: anElement [ element := anElement ]

{ #category : 'testing' }
CFMotionPropertyTrack >> isAtDestination [ ^ startValue = targetValue ]

{ #category : 'accessing' }
CFMotionPropertyTrack >> originValue [ ^ originValue ]

{ #category : 'playing' }
CFMotionPropertyTrack >> prepareFromCurrentPresentation [
	entryValue := startValue := property currentPresentationOf: element
]

{ #category : 'playing' }
CFMotionPropertyTrack >> prepareForTimelineCycle: aCycleIndex [
	aCycleIndex isZero
		ifTrue: [ startValue := entryValue ]
		ifFalse: [
			startValue := originValue.
			self restoreOrigin ]
]

{ #category : 'accessing' }
CFMotionPropertyTrack >> property [ ^ property ]

{ #category : 'accessing' }
CFMotionPropertyTrack >> property: aProperty [ property := aProperty ]

{ #category : 'accessing' }
CFMotionPropertyTrack >> propertyKey [
	^ CFMotionPropertyKey element: element property: property
]

{ #category : 'playing' }
CFMotionPropertyTrack >> restoreOrigin [
	property apply: originValue to: element
]

{ #category : 'controlling' }
CFMotionPropertyTrack >> reversed [
	originValue ifNil: [
		self error: 'A property track must start before it can be reversed' ].
	^ self class on: element property: property target: originValue
]

{ #category : 'accessing' }
CFMotionPropertyTrack >> startValue [ ^ startValue ]

{ #category : 'accessing' }
CFMotionPropertyTrack >> targetValue [ ^ targetValue ]

{ #category : 'accessing' }
CFMotionPropertyTrack >> targetValue: aValue [ targetValue := aValue ]
