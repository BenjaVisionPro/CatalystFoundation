"
I am responsible for temporal composition and playback position for one Motion.

I own ordered tracks, symbolic anchors, resolved cycle duration, playback position and whole-timeline repetition. I resolve temporal layout before playback and evaluate all tracks from one shared playhead. repeat: counts total traversals of that resolved cycle; cycle anchors remain within the authored cycle while playbackDuration describes the finite whole playback.

I do not schedule frames, claim presentation properties or manage Motion lifecycle.
"
Class {
	#name : 'CFMotionTimeline',
	#superclass : 'Object',
	#instVars : [ 'tracks', 'startAnchor', 'endAnchor', 'resolvedEnd', 'elapsedTime', 'indefinite', 'repeating', 'repeatCount', 'appliedCycleIndex' ],
	#category : 'BVC-Motion-Core',
	#package : 'BVC-Motion-Core'
}

{ #category : 'private - tracks' }
CFMotionTimeline >> addTrack: aTrack [
	tracks add: aTrack.
	resolvedEnd := nil
]

{ #category : 'playing' }
CFMotionTimeline >> advanceBy: aDuration [
	self ensureResolvedTemporalLayout.
	elapsedTime := elapsedTime + aDuration.
	self hasFinitePlayback ifTrue: [ elapsedTime := elapsedTime min: self playbackDuration ].
	self applyCurrentPosition.
	^ self
]

{ #category : 'private - playing' }
CFMotionTimeline >> applyCurrentPosition [
	| cycleIndex |
	cycleIndex := self currentCycleIndex.
	cycleIndex ~= appliedCycleIndex ifTrue: [
		tracks do: [ :each | each prepareForTimelineCycle: cycleIndex ].
		appliedCycleIndex := cycleIndex ].
	tracks do: [ :each | each applyAt: self currentPosition ]
]

{ #category : 'accessing' }
CFMotionTimeline >> duration [
	self ensureResolvedTemporalLayout.
	^ indefinite ifTrue: [ nil ] ifFalse: [ resolvedEnd ]
]

{ #category : 'accessing' }
CFMotionTimeline >> cycleDuration [
	^ self duration
]

{ #category : 'private - playing' }
CFMotionTimeline >> currentCycleIndex [
	self ensureResolvedTemporalLayout.
	self isRepeating ifFalse: [ ^ 0 ].
	repeating ifTrue: [
		^ elapsedTime asMilliSeconds // resolvedEnd asMilliSeconds ].
	elapsedTime >= self playbackDuration ifTrue: [ ^ repeatCount - 1 ].
	^ elapsedTime asMilliSeconds // resolvedEnd asMilliSeconds
]

{ #category : 'accessing' }
CFMotionTimeline >> elapsedTime [
	^ elapsedTime
]

{ #category : 'accessing' }
CFMotionTimeline >> end [
	^ endAnchor
]

{ #category : 'private - resolving' }
CFMotionTimeline >> ensureResolvedTemporalLayout [
	resolvedEnd ifNil: [ self resolveTemporalLayout ]
]

{ #category : 'private - resolving' }
CFMotionTimeline >> invalidateTemporalLayout [
	resolvedEnd := nil
]

{ #category : 'initialization' }
CFMotionTimeline >> initialize [
	super initialize.
	tracks := OrderedCollection new.
	startAnchor := CFMotionTemporalAnchor timelineStartIn: self.
	endAnchor := CFMotionTemporalAnchor timelineEndIn: self.
	elapsedTime := 0 milliSeconds.
	indefinite := false.
	repeating := false.
	repeatCount := nil.
	appliedCycleIndex := nil
]

{ #category : 'testing' }
CFMotionTimeline >> isComplete [
	self ensureResolvedTemporalLayout.
	^ self hasFinitePlayback and: [ elapsedTime >= self playbackDuration ]
]

{ #category : 'testing' }
CFMotionTimeline >> isFinite [
	self ensureResolvedTemporalLayout.
	^ indefinite not
]

{ #category : 'testing' }
CFMotionTimeline >> isIndefinite [
	self ensureResolvedTemporalLayout.
	^ indefinite
]

{ #category : 'private - testing' }
CFMotionTimeline >> hasFinitePlayback [
	^ indefinite not and: [ repeating not ]
]

{ #category : 'playing' }
CFMotionTimeline >> prepareForPlayback [
	self resolveTemporalLayout.
	elapsedTime := 0 milliSeconds.
	appliedCycleIndex := nil.
	^ self
]

{ #category : 'accessing' }
CFMotionTimeline >> playbackDuration [
	self ensureResolvedTemporalLayout.
	(indefinite or: [ repeating ]) ifTrue: [ ^ nil ].
	^ repeatCount
		ifNil: [ resolvedEnd ]
		ifNotNil: [ resolvedEnd * repeatCount ]
]

{ #category : 'accessing' }
CFMotionTimeline >> playbackProgress [
	| totalDuration |
	totalDuration := self playbackDuration.
	totalDuration ifNil: [ ^ nil ].
	totalDuration isZero ifTrue: [ ^ 1.0 ].
	^ (elapsedTime / totalDuration) min: 1.0
]

{ #category : 'accessing' }
CFMotionTimeline >> progress [
	self ensureResolvedTemporalLayout.
	indefinite ifTrue: [ ^ nil ].
	resolvedEnd isZero ifTrue: [ ^ 1.0 ].
	^ (self currentPosition / resolvedEnd) min: 1.0
]

{ #category : 'accessing' }
CFMotionTimeline >> currentPosition [
	self ensureResolvedTemporalLayout.
	(indefinite or: [ self isRepeating not ]) ifTrue: [ ^ elapsedTime ].
	resolvedEnd isZero ifTrue: [ ^ 0 milliSeconds ].
	(repeating not and: [ elapsedTime >= self playbackDuration ]) ifTrue: [ ^ resolvedEnd ].
	^ (elapsedTime asMilliSeconds \\ resolvedEnd asMilliSeconds) milliSeconds
]

{ #category : 'configuration' }
CFMotionTimeline >> repeat [
	repeating := true.
	repeatCount := nil.
	^ self
]

{ #category : 'configuration' }
CFMotionTimeline >> repeat: aCount [
	(aCount isInteger and: [ aCount > 0 ]) ifFalse: [
		self error: 'A Motion timeline repeat count must be a positive integer' ].
	repeating := false.
	repeatCount := aCount.
	^ self
]

{ #category : 'testing' }
CFMotionTimeline >> isRepeating [
	^ repeating or: [ repeatCount notNil ]
]

{ #category : 'playing' }
CFMotionTimeline >> seekTo: aDuration [
	self ensureResolvedTemporalLayout.
	aDuration < (0 milliSeconds) ifTrue: [
		self error: 'A Motion timeline cannot seek before zero' ].
	elapsedTime := aDuration.
	self hasFinitePlayback ifTrue: [ elapsedTime := elapsedTime min: self playbackDuration ].
	self applyCurrentPosition.
	^ self
]

{ #category : 'private - resolving' }
CFMotionTimeline >> resolveTemporalLayout [
	resolvedEnd := nil.
	indefinite := tracks anySatisfy: #isIndefinite.
	tracks do: [ :each | each clearResolvedTimes ].
	self resolveTracksThatDoNotReferenceTimelineEnd.
	self deriveTimelineEnd.
	self resolveTracksWithTimelineEnd.
	self validateResolvedTemporalLayout
]

{ #category : 'private - resolving' }
CFMotionTimeline >> deriveTimelineEnd [
	| endDefiningEnds |
	endDefiningEnds := tracks
		select: [ :each | each establishesTimelineEnd and: [ each resolvedEnd notNil ] ].
	endDefiningEnds isNotEmpty ifTrue: [
		resolvedEnd := endDefiningEnds
			inject: endDefiningEnds first resolvedEnd
			into: [ :latest :each | latest max: each resolvedEnd ] ]
]

{ #category : 'private - resolving' }
CFMotionTimeline >> resolveTracksThatDoNotReferenceTimelineEnd [
	| changed |
	changed := true.
	[ changed ] whileTrue: [
		changed := false.
		tracks do: [ :each |
			(each referencesTimelineEndWith: IdentitySet new) ifFalse: [
				changed := (each resolveUsing: self) or: [ changed ] ] ] ]
]

{ #category : 'private - resolving' }
CFMotionTimeline >> resolveTracksWithTimelineEnd [
	| changed |
	changed := true.
	[ changed ] whileTrue: [
		changed := false.
		tracks do: [ :each | changed := (each resolveUsing: self) or: [ changed ] ] ]
]

{ #category : 'private - resolving' }
CFMotionTimeline >> resolvedTimeOf: anAnchor [
	anAnchor kind = #timelineStart ifTrue: [ ^ 0 milliSeconds ].
	anAnchor kind = #timelineEnd ifTrue: [ ^ indefinite ifTrue: [ nil ] ifFalse: [ resolvedEnd ] ].
	anAnchor kind = #trackStart ifTrue: [ ^ anAnchor track resolvedStart ].
	anAnchor kind = #trackEnd ifTrue: [ ^ anAnchor track resolvedEnd ].
	self error: 'An unknown Motion temporal anchor cannot be resolved'
]

{ #category : 'accessing' }
CFMotionTimeline >> start [
	^ startAnchor
]

{ #category : 'accessing' }
CFMotionTimeline >> tracks [
	^ tracks asArray
]

{ #category : 'private - resolving' }
CFMotionTimeline >> validateResolvedTemporalLayout [
	(indefinite and: [ repeatCount notNil ]) ifTrue: [
		self error: 'An indefinite Motion timeline cannot have a finite repeat count' ].
	indefinite ifTrue: [
		(tracks anySatisfy: [ :each |
			each referencesTimelineEndWith: IdentitySet new ]) ifTrue: [
			self error: 'An indefinite Motion timeline has no timeline end anchor' ] ].
	tracks do: [ :each |
		each isFinite ifTrue: [
			(each resolvedStart isNil or: [ each resolvedEnd isNil ]) ifTrue: [
				self error: 'A finite Motion track must have a resolvable temporal layout' ] ].
		each isIndefinite ifTrue: [
			each resolvedStart ifNil: [
				self error: 'An indefinite Motion track must have a resolvable start' ] ] ].
	indefinite ifFalse: [
		resolvedEnd ifNil: [
			self error: 'A finite Motion timeline needs a duration before it can play' ] ]
]
