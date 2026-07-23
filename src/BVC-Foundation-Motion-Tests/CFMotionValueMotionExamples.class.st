Class {
	#name : 'CFMotionValueMotionExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Motion-Tests-Values',
	#package : 'BVC-Foundation-Motion-Tests'
}

{ #category : 'examples - value motion' }
CFMotionValueMotionExamples >> valueMotionAnimatesAnOrdinaryValueTarget [
	<gtExample>
	| target motion |
	target := CFMotionValueRecorder new value: 10.0; yourself.
	motion := (CFMotionValueMotion on: target)
		from: 10.0;
		to: 20.0 over: 1 second easing: BlEasing linear.
	motion applyAt: 500 milliSeconds.
	self assert: (target value closeTo: 15.0).
	^ motion
]

{ #category : 'examples - value motion' }
CFMotionValueMotionExamples >> repeatingValueMotionSupportsPhaseOffset [
	<gtExample>
	| target motion |
	target := CFMotionValueRecorder new.
	motion := (CFMotionValueMotion on: target)
		from: 0.0;
		to: 10.0 over: 1 second easing: BlEasing linear;
		to: 0.0 over: 1 second easing: BlEasing linear;
		phaseOffset: 500 milliSeconds;
		repeat.
	motion applyAt: 1 second.
	self assert: (target value closeTo: 5.0).
	motion applyAt: 2500 milliSeconds.
	self assert: (target value closeTo: 5.0).
	^ motion
]
