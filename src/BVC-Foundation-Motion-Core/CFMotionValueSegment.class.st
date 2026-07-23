Class {
	#name : 'CFMotionValueSegment',
	#superclass : 'Object',
	#instVars : [ 'fromValue', 'toValue', 'duration', 'easing' ],
	#category : 'BVC-Foundation-Motion-Core-Values',
	#package : 'BVC-Foundation-Motion-Core'
}

{ #category : 'instance creation' }
CFMotionValueSegment class >> from: aStartValue to: anEndValue over: aDuration easing: anInterpolator [
	^ self new
		fromValue: aStartValue;
		toValue: anEndValue;
		duration: aDuration;
		easing: anInterpolator;
		yourself
]

{ #category : 'accessing' }
CFMotionValueSegment >> duration [ ^ duration ]

{ #category : 'evaluating' }
CFMotionValueSegment >> valueAtElapsedTime: anElapsedDuration [
	| progress eased |
	progress := ((anElapsedDuration / duration) asFloat min: 1.0) max: 0.0.
	eased := easing interpolate: progress.
	^ fromValue + ((toValue - fromValue) * eased)
]

{ #category : 'private - initialization' }
CFMotionValueSegment >> fromValue: aValue [ fromValue := aValue asFloat ]

{ #category : 'private - initialization' }
CFMotionValueSegment >> toValue: aValue [ toValue := aValue asFloat ]

{ #category : 'private - initialization' }
CFMotionValueSegment >> duration: aDuration [
	aDuration <= (0 milliSeconds) ifTrue: [ self error: 'A Motion value segment duration must be positive' ].
	duration := aDuration
]

{ #category : 'private - initialization' }
CFMotionValueSegment >> easing: anInterpolator [ easing := anInterpolator ]
