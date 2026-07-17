Class {
	#name : 'CFMotionTimeline',
	#superclass : 'Object',
	#instVars : [ 'tracks', 'startAnchor', 'endAnchor', 'resolvedEnd' ],
	#category : 'BVC-Foundation-Motion-Core',
	#package : 'BVC-Foundation-Motion-Core'
}

{ #category : 'private - tracks' }
CFMotionTimeline >> addTrack: aTrack [
	tracks add: aTrack
]

{ #category : 'accessing' }
CFMotionTimeline >> duration [
	self resolveTemporalLayout.
	^ resolvedEnd
]

{ #category : 'accessing' }
CFMotionTimeline >> end [
	^ endAnchor
]

{ #category : 'initialization' }
CFMotionTimeline >> initialize [
	super initialize.
	tracks := OrderedCollection new.
	startAnchor := CFMotionTemporalAnchor timelineStartIn: self.
	endAnchor := CFMotionTemporalAnchor timelineEndIn: self
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
		tracks do: [ :each | changed := (each resolveUsing: self) or: [ changed ] ] ] ]
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
				self error: 'A finite Motion track must have a resolvable temporal layout' ] ] ]
]
