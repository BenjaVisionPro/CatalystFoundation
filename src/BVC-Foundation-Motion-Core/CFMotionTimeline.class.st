"
I am the temporal runtime owned by a CFMotion.

I own an ordered collection of timeline tracks, their resolved temporal layout, and the current playback position. Before playback I resolve the track anchors and reset my playhead. For each coordinator frame I advance that playhead once, clamp it to my finite duration, and ask every track to present itself at the resulting absolute timeline time.

I do not schedule frames, own presentation claims, or manage Motion lifecycle. CFMotion owns lifecycle and delegates temporal advancement to me. CFMotionCoordinator supplies the shared frame cadence. CFMotionTimelineTrack owns temporal placement and translates my absolute playback position into presentation progress for its visual track.
"
Class {
	#name : 'CFMotionTimeline',
	#superclass : 'Object',
	#instVars : [ 'tracks', 'startAnchor', 'endAnchor', 'resolvedEnd', 'elapsedTime' ],
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
	elapsedTime := (elapsedTime + aDuration) min: resolvedEnd.
	self applyCurrentPosition.
	^ self
]

{ #category : 'private - playing' }
CFMotionTimeline >> applyCurrentPosition [
	tracks do: [ :each | each applyAt: elapsedTime ]
]

{ #category : 'accessing' }
CFMotionTimeline >> duration [
	self ensureResolvedTemporalLayout.
	^ resolvedEnd
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
	elapsedTime := 0 milliSeconds
]

{ #category : 'testing' }
CFMotionTimeline >> isComplete [
	self ensureResolvedTemporalLayout.
	^ elapsedTime >= resolvedEnd
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
	resolvedEnd isZero ifTrue: [ ^ 1.0 ].
	^ (elapsedTime / resolvedEnd) min: 1.0
]

{ #category : 'private - resolving' }
CFMotionTimeline >> resolveTemporalLayout [
	resolvedEnd := nil.
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
	anAnchor kind = #timelineEnd ifTrue: [ ^ resolvedEnd ].
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
	(tracks anySatisfy: [ :each |
		each referencesTimelineEndWith: IdentitySet new ]) ifTrue: [
		resolvedEnd ifNil: [
			self error: 'A Motion timeline needs a finite track to establish its end' ] ].
	tracks do: [ :each |
		each isFinite ifTrue: [
			(each resolvedStart isNil or: [ each resolvedEnd isNil ]) ifTrue: [
				self error: 'A finite Motion track must have a resolvable temporal layout' ] ] ].
	resolvedEnd ifNil: [
		self error: 'A Motion timeline needs a finite duration before it can play' ]
]
