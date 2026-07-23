Class {
	#name : 'CFMotionValueExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Motion-Tests-Values',
	#package : 'BVC-Foundation-Motion-Tests'
}

{ #category : 'examples - values' }
CFMotionValueExamples >> timelineAnimatesAMotionValue [
	<gtExample>
	| value timeline track |
	value := CFMotionValue value: 10.0.
	timeline := CFMotionTimeline new.
	track := CFMotionTimelineTrack
		on: (value transitionFrom: 10.0 to: 20.0)
		in: timeline.
	track duration: 1 second; easing: BlEasing linear.
	timeline prepareForPlayback; advanceBy: 500 milliSeconds.
	self assert: (value value closeTo: 15.0).
	^ timeline
]

{ #category : 'examples - values' }
CFMotionValueExamples >> repeatingTimelineComposesSequentialValueTransitions [
	<gtExample>
	| value timeline inhale exhale |
	value := CFMotionValue value: 0.0.
	timeline := CFMotionTimeline new.
	inhale := CFMotionTimelineTrack
		on: (value transitionFrom: 0.0 to: 10.0)
		in: timeline.
	inhale duration: 1 second; easing: BlEasing linear.
	exhale := CFMotionTimelineTrack
		on: (value transitionFrom: 10.0 to: 0.0)
		in: timeline.
	exhale startsAt: inhale end; duration: 1 second; easing: BlEasing linear.
	timeline repeat; prepareForPlayback.
	timeline advanceBy: 500 milliSeconds.
	self assert: (value value closeTo: 5.0).
	timeline advanceBy: 2 seconds.
	self assert: (value value closeTo: 5.0).
	^ timeline
]

{ #category : 'examples - values' }
CFMotionValueExamples >> repeatingTimelineCanSeekToAPhase [
	<gtExample>
	| value timeline track |
	value := CFMotionValue value: 0.0.
	timeline := CFMotionTimeline new.
	track := CFMotionTimelineTrack
		on: (value transitionFrom: 0.0 to: 10.0)
		in: timeline.
	track duration: 1 second; easing: BlEasing linear.
	timeline repeat; prepareForPlayback; seekTo: 250 milliSeconds.
	self assert: (value value closeTo: 2.5).
	^ timeline
]
