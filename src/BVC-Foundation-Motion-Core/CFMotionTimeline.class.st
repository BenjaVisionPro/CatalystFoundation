"
I own temporal composition and playback position for one Motion.

I resolve track anchors before playback, reset and advance one playhead, and evaluate my ordered tracks at that absolute timeline position. A finite timeline clamps at its resolved end and reports completion. A timeline containing an indefinite track has no duration, progress or automatic completion.

I never schedule frames, claim presentation properties or manage Motion lifecycle. CFMotion owns lifecycle, CFMotionCoordinator supplies the shared frame cadence, CFMotionTimelineTrack owns temporal placement, and CFMotionBehaviour owns the work performed by an evaluation.
"
Class {
	#name : 'CFMotionTimeline',
	#superclass : 'Object',
	#instVars : [ 'tracks', 'startAnchor', 'endAnchor', 'resolvedEnd', 'elapsedTime', 'indefinite', 'repeating' ],
	#category : 'BVC-Foundation-Motion-Core',
	#package : 'BVC-Foundation-Motion-Core'
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
	(indefinite or: [ repeating ]) ifFalse: [ elapsedTime := elapsedTime min: resolvedEnd ].
	self applyCurrentPosition.
	^ self
]

{ #category : 'private - playing' }
CFMotionTimeline >> applyCurrentPosition [
	tracks do: [ :each | each applyAt: self currentPosition ]
]

{ #category : 'accessing' }
CFMotionTimeline >> duration [
	self ensureResolvedTemporalLayout.
	^ indefinite ifTrue: [ nil ] ifFalse: [ resolvedEnd ]
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

{ #category : 'initialization' }
CFMotionTimeline >> initialize [
	super initialize.
	tracks := OrderedCollection new.
	startAnchor := CFMotionTemporalAnchor timelineStartIn: self.
	endAnchor := CFMotionTemporalAnchor timelineEndIn: self.
	elapsedTime := 0 milliSeconds.
	indefinite := false.
	repeating := false
]

{ #category : 'testing' }
CFMotionTimeline >> isComplete [
	self ensureResolvedTemporalLayout.
	^ indefinite not and: [ repeating not and: [ elapsedTime >= resolvedEnd ] ]
]

{ #category : 'testing' }
CFMotionTimeline >> isFinite [
	self ensureResolvedTemporalLayout.
	^ indefinite not and: [ repeating not ]
]

{ #category : 'testing' }
CFMotionTimeline >> isIndefinite [
	self ensureResolvedTemporalLayout.
	^ indefinite or: [ repeating ]
]

{ #category : 'playing' }
CFMotionTimeline >> prepareForPlayback [
	self resolveTemporalLayout.
	elapsedTime := 0 milliSeconds.
	^ self
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
	(indefinite or: [ repeating not ]) ifTrue: [ ^ elapsedTime ].
	resolvedEnd isZero ifTrue: [ ^ 0 milliSeconds ].
	^ (elapsedTime asMilliSeconds \\ resolvedEnd asMilliSeconds) milliSeconds
]

{ #category : 'configuration' }
CFMotionTimeline >> repeat [
	repeating := true.
	^ self
]

{ #category : 'testing' }
CFMotionTimeline >> isRepeating [
	^ repeating
]

{ #category : 'playing' }
CFMotionTimeline >> seekTo: aDuration [
	self ensureResolvedTemporalLayout.
	aDuration < (0 milliSeconds) ifTrue: [
		self error: 'A Motion timeline cannot seek before zero' ].
	elapsedTime := aDuration.
	(indefinite or: [ repeating ]) ifFalse: [ elapsedTime := elapsedTime min: resolvedEnd ].
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
