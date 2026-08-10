"
I represent one symbolic temporal anchor belonging to a CFMotionTimeline or one of its tracks.

I identify timeline start/end or track start/end so temporal placement can be expressed before concrete times are resolved. I do not resolve time myself.
"
Class {
	#name : 'CFMotionTemporalAnchor',
	#superclass : 'Object',
	#instVars : [ 'kind', 'timeline', 'track' ],
	#category : 'BVC-Motion-Core',
	#package : 'BVC-Motion-Core'
}

{ #category : 'instance creation' }
CFMotionTemporalAnchor class >> timelineEndIn: aTimeline [
	^ self new
		kind: #timelineEnd;
		timeline: aTimeline;
		yourself
]

{ #category : 'instance creation' }
CFMotionTemporalAnchor class >> timelineStartIn: aTimeline [
	^ self new
		kind: #timelineStart;
		timeline: aTimeline;
		yourself
]

{ #category : 'instance creation' }
CFMotionTemporalAnchor class >> trackEnd: aTrack [
	^ self new
		kind: #trackEnd;
		timeline: aTrack timeline;
		track: aTrack;
		yourself
]

{ #category : 'instance creation' }
CFMotionTemporalAnchor class >> trackStart: aTrack [
	^ self new
		kind: #trackStart;
		timeline: aTrack timeline;
		track: aTrack;
		yourself
]

{ #category : 'testing' }
CFMotionTemporalAnchor >> isIn: aTimeline [
	^ timeline == aTimeline
]

{ #category : 'testing' }
CFMotionTemporalAnchor >> isTimelineEnd [
	^ kind = #timelineEnd
]

{ #category : 'accessing' }
CFMotionTemporalAnchor >> kind [
	^ kind
]

{ #category : 'private - initialization' }
CFMotionTemporalAnchor >> kind: aSymbol [
	kind := aSymbol
]

{ #category : 'testing' }
CFMotionTemporalAnchor >> referencesTimelineEndWith: aCollection [
	self isTimelineEnd ifTrue: [ ^ true ].
	track ifNil: [ ^ false ].
	^ track referencesTimelineEndWith: aCollection
]

{ #category : 'accessing' }
CFMotionTemporalAnchor >> track [
	^ track
]

{ #category : 'private - initialization' }
CFMotionTemporalAnchor >> track: aTrack [
	track := aTrack
]

{ #category : 'accessing' }
CFMotionTemporalAnchor >> timeline [
	^ timeline
]

{ #category : 'private - initialization' }
CFMotionTemporalAnchor >> timeline: aTimeline [
	timeline := aTimeline
]
