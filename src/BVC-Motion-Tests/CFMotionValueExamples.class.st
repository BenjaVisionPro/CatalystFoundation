Class {
	#name : 'CFMotionValueExamples',
	#superclass : 'Object',
	#category : 'BVC-Motion-Tests-Values',
	#package : 'BVC-Motion-Tests'
}

{ #category : 'examples - values' }
CFMotionValueExamples >> timelineAnimatesAMotionValue [
	<gtExample>
	| value timeline track |
	value := CFMotionValue value: 10.0.
	timeline := CFMotionTimeline new.
	track := CFMotionTimelineTrack
		on: (value interpolateFrom: 10.0 to: 20.0)
		in: timeline.
	track duration: 1 second; easing: BlEasing linear.
	timeline prepareForPlayback; advanceBy: 500 milliSeconds.
	self assert: (value value closeTo: 15.0).
	^ timeline
]

{ #category : 'examples - values' }
CFMotionValueExamples >> valueInterpolationIsCanonicalAndTransitionNamesRemainCompatible [
	<gtExample>
	| value interpolation compatibilitySelector compatibilityClass |
	value := CFMotionValue value: 0.0.
	interpolation := value interpolateFrom: 0.0 to: 10.0.
	compatibilitySelector := value transitionFrom: 0.0 to: 10.0.
	compatibilityClass := CFMotionValueTransition on: value from: 0.0 to: 10.0.
	self assert: interpolation class equals: CFMotionValueInterpolation.
	self assert: compatibilitySelector class equals: CFMotionValueInterpolation.
	self assert: compatibilityClass class equals: CFMotionValueTransition.
	self assert: (compatibilityClass isKindOf: CFMotionValueInterpolation).
	interpolation applyProgress: 0.5.
	self assert: (value value closeTo: 5.0).
	^ interpolation
]

{ #category : 'examples - values' }
CFMotionValueExamples >> repeatingTimelineComposesSequentialValueTransitions [
	<gtExample>
	| value timeline rise fall |
	value := CFMotionValue value: 0.0.
	timeline := CFMotionTimeline new.
	rise := CFMotionTimelineTrack
		on: (value interpolateFrom: 0.0 to: 10.0)
		in: timeline.
	rise duration: 1 second; easing: BlEasing linear.
	fall := CFMotionTimelineTrack
		on: (value interpolateFrom: 10.0 to: 0.0)
		in: timeline.
	fall startsAt: rise end; duration: 1 second; easing: BlEasing linear.
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
		on: (value interpolateFrom: 0.0 to: 10.0)
		in: timeline.
	track duration: 1 second; easing: BlEasing linear.
	timeline repeat; prepareForPlayback; seekTo: 250 milliSeconds.
	self assert: (value value closeTo: 2.5).
	^ timeline
]


{ #category : 'examples - values' }
CFMotionValueExamples >> motionValueSupportsCustomInterpolation [
	<gtExample>
	| value timeline track |
	value := CFMotionValue value: 'start'.
	timeline := CFMotionTimeline new.
	track := CFMotionTimelineTrack
		on: (value interpolateFrom: 'start' to: 'end' using: [ :start :end :progress | progress < 0.5 ifTrue: [ start ] ifFalse: [ end ] ])
		in: timeline.
	track duration: 1 second; easing: BlEasing linear.
	timeline prepareForPlayback; advanceBy: 750 milliSeconds.
	self assert: value value equals: 'end'.
	^ timeline
]

{ #category : 'examples - values' }
CFMotionValueExamples >> repeatingTimelineSeparatesCycleFromPlaybackSemantics [
	<gtExample>
	| value timeline track |
	value := CFMotionValue value: 0.0.
	timeline := CFMotionTimeline new.
	track := CFMotionTimelineTrack on: (value interpolateTo: 10.0) in: timeline.
	track duration: 1 second; easing: BlEasing linear.
	timeline repeat; prepareForPlayback; seekTo: 3 seconds.
	self assert: timeline duration equals: 1 second.
	self assert: timeline cycleDuration equals: 1 second.
	self assert: timeline elapsedTime equals: 3 seconds.
	self assert: timeline currentPosition equals: 0 milliSeconds.
	self assert: timeline isFinite.
	self assert: timeline isIndefinite not.
	self assert: timeline isRepeating.
	^ timeline
]

{ #category : 'examples - values' }
CFMotionValueExamples >> finiteTimelineRepeatCountsTotalCyclesAndEndsAtTheDestination [
	<gtExample>
	| value timeline track |
	value := CFMotionValue value: 0.0.
	timeline := CFMotionTimeline new.
	track := CFMotionTimelineTrack
		on: (value interpolateFrom: 0.0 to: 10.0)
		in: timeline.
	track duration: 100 milliSeconds; easing: BlEasing linear.
	timeline repeat: 2; prepareForPlayback.
	timeline advanceBy: 50 milliSeconds.
	self assert: (value value closeTo: 5.0).
	self assert: timeline cycleDuration equals: 100 milliSeconds.
	self assert: timeline playbackDuration equals: 200 milliSeconds.
	self assert: (timeline playbackProgress closeTo: 0.25).
	timeline advanceBy: 50 milliSeconds.
	self assert: value value equals: 0.0.
	self assert: timeline currentPosition equals: 0 milliSeconds.
	self assert: (timeline progress closeTo: 0.0).
	self assert: (timeline playbackProgress closeTo: 0.5).
	timeline advanceBy: 50 milliSeconds.
	self assert: (value value closeTo: 5.0).
	timeline advanceBy: 50 milliSeconds.
	self assert: value value equals: 10.0.
	self assert: timeline currentPosition equals: 100 milliSeconds.
	self assert: timeline elapsedTime equals: 200 milliSeconds.
	self assert: timeline isComplete.
	self assert: (timeline progress closeTo: 1.0).
	self assert: (timeline playbackProgress closeTo: 1.0).
	^ timeline
]

{ #category : 'examples - values' }
CFMotionValueExamples >> finiteTimelineRepeatSeeksInPlaybackTimeAndClampsAtTheFinalDestination [
	<gtExample>
	| value timeline track |
	value := CFMotionValue value: 0.0.
	timeline := CFMotionTimeline new.
	track := CFMotionTimelineTrack
		on: (value interpolateFrom: 0.0 to: 10.0)
		in: timeline.
	track duration: 100 milliSeconds; easing: BlEasing linear.
	timeline repeat: 2; prepareForPlayback; seekTo: 150 milliSeconds.
	self assert: timeline elapsedTime equals: 150 milliSeconds.
	self assert: timeline currentPosition equals: 50 milliSeconds.
	self assert: (value value closeTo: 5.0).
	timeline seekTo: 2 seconds.
	self assert: timeline elapsedTime equals: 200 milliSeconds.
	self assert: timeline currentPosition equals: 100 milliSeconds.
	self assert: value value equals: 10.0.
	self assert: timeline isComplete.
	^ timeline
]

{ #category : 'examples - values' }
CFMotionValueExamples >> finiteTimelineRepeatLeavesTrackAnchorsAndOffsetsInTheCycle [
	<gtExample>
	| firstValue secondValue timeline first second |
	firstValue := CFMotionValue value: 0.0.
	secondValue := CFMotionValue value: 0.0.
	timeline := CFMotionTimeline new.
	first := CFMotionTimelineTrack
		on: (firstValue interpolateFrom: 0.0 to: 10.0)
		in: timeline.
	first duration: 100 milliSeconds; easing: BlEasing linear.
	second := CFMotionTimelineTrack
		on: (secondValue interpolateFrom: 0.0 to: 10.0)
		in: timeline.
	second
		starts: 20 milliSeconds after: first end;
		duration: 30 milliSeconds;
		easing: BlEasing linear.
	timeline repeat: 2.
	self assert: timeline cycleDuration equals: 150 milliSeconds.
	self assert: first resolvedStart equals: 0 milliSeconds.
	self assert: first resolvedEnd equals: 100 milliSeconds.
	self assert: second resolvedStart equals: 120 milliSeconds.
	self assert: second resolvedEnd equals: 150 milliSeconds.
	self assert: timeline playbackDuration equals: 300 milliSeconds.
	^ timeline
]
