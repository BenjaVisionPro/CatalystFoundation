"
I am a reusable Motion composition over an ordinary value/value: target.

I own an ordered sequence of timed interpolation segments and can be sampled at an explicit time. I do not own scheduling or a clock. A coordinator, simulation, test or other runtime may call #applyAt: with its own authoritative time.
"
Class {
	#name : 'CFMotionValueMotion',
	#superclass : 'Object',
	#instVars : [ 'target', 'segments', 'nextFromValue', 'phaseOffset', 'repeating' ],
	#category : 'BVC-Foundation-Motion-Core-Values',
	#package : 'BVC-Foundation-Motion-Core'
}

{ #category : 'instance creation' }
CFMotionValueMotion class >> on: aValueTarget [
	^ self new
		target: aValueTarget;
		yourself
]

{ #category : 'initialization' }
CFMotionValueMotion >> initialize [
	super initialize.
	segments := OrderedCollection new.
	phaseOffset := 0 milliSeconds.
	repeating := false
]

{ #category : 'building' }
CFMotionValueMotion >> from: aValue [
	nextFromValue := aValue asFloat.
	^ self
]

{ #category : 'building' }
CFMotionValueMotion >> to: aValue over: aDuration easing: anInterpolator [
	nextFromValue ifNil: [ self error: 'A Motion value sequence needs an initial value' ].
	segments add: (CFMotionValueSegment
		from: nextFromValue
		to: aValue
		over: aDuration
		easing: anInterpolator).
	nextFromValue := aValue asFloat.
	^ self
]

{ #category : 'building' }
CFMotionValueMotion >> repeat [
	repeating := true.
	^ self
]

{ #category : 'building' }
CFMotionValueMotion >> phaseOffset: aDuration [
	phaseOffset := aDuration.
	^ self
]

{ #category : 'accessing' }
CFMotionValueMotion >> duration [
	^ segments inject: 0 milliSeconds into: [ :total :each | total + each duration ]
]

{ #category : 'evaluating' }
CFMotionValueMotion >> valueAt: anElapsedDuration [
	| total localTime cursor |
	segments ifEmpty: [ self error: 'A Motion value sequence needs at least one segment' ].
	total := self duration.
	localTime := anElapsedDuration - phaseOffset.
	repeating
		ifTrue: [
			[ localTime < (0 milliSeconds) ] whileTrue: [ localTime := localTime + total ].
			localTime := (localTime asMilliSeconds \\ total asMilliSeconds) milliSeconds ]
		ifFalse: [ localTime := (localTime min: total) max: 0 milliSeconds ].
	cursor := 0 milliSeconds.
	segments do: [ :segment |
		localTime <= (cursor + segment duration) ifTrue: [
			^ segment valueAtElapsedTime: localTime - cursor ].
		cursor := cursor + segment duration ].
	^ nextFromValue
]

{ #category : 'evaluating' }
CFMotionValueMotion >> applyAt: anElapsedDuration [
	target value: (self valueAt: anElapsedDuration).
	^ target value
]

{ #category : 'accessing' }
CFMotionValueMotion >> target [ ^ target ]

{ #category : 'private - initialization' }
CFMotionValueMotion >> target: aValueTarget [
	(aValueTarget respondsTo: #value) ifFalse: [ self error: 'A Motion value target must answer #value' ].
	(aValueTarget respondsTo: #value:) ifFalse: [ self error: 'A Motion value target must answer #value:' ].
	target := aValueTarget
]
