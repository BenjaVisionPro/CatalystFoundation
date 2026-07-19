"
I own the lifecycle of one playable temporal composition.

I start, pause, resume and stop playback; coordinate presentation ownership; and deliver Behaviour lifecycle callbacks exactly once. When I own a CFMotionTimeline, the timeline is the sole owner of playback position and track evaluation. Direct track compositions built without a timeline use Motion-owned normalised playback, while timeline compositions delegate playback position entirely to their timeline. Neither path owns scheduling.

I advance only from immutable CFMotionFrames supplied by my CFMotionCoordinator. I never read a clock, enqueue a Bloc task or create a Bloc animation. The coordinator owns scheduling and cross-Motion ownership, the timeline owns temporal composition, timeline tracks own placement, and Behaviours own presentation or dynamic work.

Stopping preserves the current presentation. Explicit cancellation variants may instead restore the origin or settle at the destination. A terminal Motion cannot restart; creating a new playback creates a new Motion.
"
Class {
	#name : 'CFMotion',
	#superclass : 'Object',
	#instVars : [ 'coordinator', 'timeline', 'tracks', 'duration', 'easing', 'elapsedTime', 'state', 'terminalHandlers', 'holdAtDestination', 'componentMotions' ],
	#category : 'BVC-Foundation-Motion-Core',
	#package : 'BVC-Foundation-Motion-Core'
}

{ #category : 'instance creation' }
CFMotion class >> coordinator: aCoordinator tracks: aCollection [
	^ self new
		coordinator: aCoordinator;
		tracks: aCollection;
		yourself
]

{ #category : 'instance creation' }
CFMotion class >> composedOf: aCollection [
	| aMotion |
	aMotion := self new.
	aMotion componentMotions: aCollection.
	^ aMotion
]

{ #category : 'instance creation' }
CFMotion class >> timeline: aTimeline coordinator: aCoordinator [
	aTimeline resolveTemporalLayout.
	^ (self coordinator: aCoordinator tracks: aTimeline tracks)
		timeline: aTimeline;
		easing: BlEasing linear;
		yourself
]

{ #category : 'initialization' }
CFMotion >> initialize [
	super initialize.
	duration := 180 milliSeconds.
	easing := BlDecelerateInterpolator factor: 1.4.
	elapsedTime := 0 milliSeconds.
	state := CFMotionState idle.
	terminalHandlers := OrderedCollection new.
	holdAtDestination := false.
	componentMotions := OrderedCollection new
]

{ #category : 'controlling' }
CFMotion >> cancel [ ^ self cancelPreservingCurrentPresentation ]

{ #category : 'controlling' }
CFMotion >> stop [
	^ self cancelPreservingCurrentPresentation
]

{ #category : 'controlling' }
CFMotion >> cancelAndRestore [
	(self hasComponentMotions) ifTrue: [ ^ self cancelComponentMotionsWith: #cancelAndRestore ].
	^ self cancelApplying: [ :each | each restoreOrigin ]
]

{ #category : 'controlling' }
CFMotion >> cancelPreservingCurrentPresentation [
	(self hasComponentMotions) ifTrue: [ ^ self cancelComponentMotionsWith: #cancel ].
	^ self cancelApplying: [ :each | each preserveCurrentPresentation ]
]

{ #category : 'controlling' }
CFMotion >> cancelSettlingAtEnd [
	(self hasComponentMotions) ifTrue: [ ^ self cancelComponentMotionsWith: #cancelSettlingAtEnd ].
	^ self cancelApplying: [ :each | each applyDestination ]
]

{ #category : 'private - controlling' }
CFMotion >> cancelComponentMotionsWith: aSelector [
	state isTerminal ifTrue: [ ^ self ].
	state := CFMotionState cancelled.
	componentMotions do: [ :each | each perform: aSelector ].
	self notifyTerminalHandlers.
	^ self
]

{ #category : 'private - controlling' }
CFMotion >> cancelApplying: aBlock [
	state isTerminal ifTrue: [ ^ self ].
	coordinator removeActiveMotion: self.
	tracks do: aBlock.
	state := CFMotionState cancelled.
	tracks do: [ :each | each playbackEndedWith: state ].
	self releaseClaims.
	self notifyTerminalHandlers.
	^ self
]

{ #category : 'private - controlling' }
CFMotion >> complete [
	state isTerminal ifTrue: [ ^ self ].
	coordinator ifNotNil: [ coordinator removeActiveMotion: self ].
	(self hasComponentMotions) ifTrue: [
		state := CFMotionState completed.
		self notifyTerminalHandlers.
		^ self ].
	holdAtDestination ifTrue: [
		state := CFMotionState settled.
		tracks do: [ :each | each playbackEndedWith: state ].
		^ self ].
	tracks do: [ :each | each applyDestination ].
	state := CFMotionState completed.
	tracks do: [ :each | each playbackEndedWith: state ].
	self releaseClaims.
	self notifyTerminalHandlers
]

{ #category : 'accessing' }
CFMotion >> coordinator [ ^ coordinator ]

{ #category : 'accessing' }
CFMotion >> coordinator: aCoordinator [ coordinator := aCoordinator ]

{ #category : 'accessing' }
CFMotion >> componentMotions [ ^ componentMotions asArray ]

{ #category : 'private - initialization' }
CFMotion >> componentMotions: aCollection [
	componentMotions := aCollection asOrderedCollection.
	^ self
]


{ #category : 'accessing' }
CFMotion >> duration: aDuration [ duration := aDuration ]

{ #category : 'accessing' }
CFMotion >> easing: anInterpolator [ easing := anInterpolator ]


{ #category : 'testing' }
CFMotion >> isCancelled [ ^ state == CFMotionState cancelled ]

{ #category : 'testing' }
CFMotion >> isCompleted [ ^ state == CFMotionState completed ]

{ #category : 'private - testing' }
CFMotion >> hasComponentMotions [ ^ componentMotions isNotEmpty ]

{ #category : 'testing' }
CFMotion >> isRunning [ ^ state == CFMotionState running ]

{ #category : 'configuration' }
CFMotion >> holdAtDestination [
	holdAtDestination := true.
	^ self
]

{ #category : 'configuration' }
CFMotion >> holdAtDestination: aBoolean [
	holdAtDestination := aBoolean.
	^ self
]

{ #category : 'private - notifying' }
CFMotion >> notifyTerminalHandlers [
	terminalHandlers do: [ :each | each cull: self ].
	terminalHandlers removeAll
]

{ #category : 'action handling' }
CFMotion >> onTerminalDo: aBlock [
	state isTerminal
		ifTrue: [ aBlock cull: self ]
		ifFalse: [ terminalHandlers add: aBlock ].
	^ self
]

{ #category : 'private - ownership' }
CFMotion >> claimTracks [
	tracks do: [ :each |
		each propertyKey ifNotNil: [ :aKey | coordinator claim: aKey for: self ] ].
]

{ #category : 'private - ownership' }
CFMotion >> releaseClaims [
	coordinator releaseAllFor: self.
]

{ #category : 'playing' }
CFMotion >> retarget: aTrackOrTracks duration: aDuration easing: anInterpolator [
	| requestedTracks ownedTracks |
	(self hasComponentMotions) ifTrue: [
		self error: 'A composed Motion must retarget one of its component Motions' ].
	requestedTracks := aTrackOrTracks isCollection
		ifTrue: [ aTrackOrTracks asArray ]
		ifFalse: [ { aTrackOrTracks } ].
	ownedTracks := requestedTracks collect: [ :each |
		tracks
			detect: [ :ownedTrack | ownedTrack propertyKey = each propertyKey ]
			ifNone: [ self error: 'A Motion can only retarget a property it owns' ] ].
	duration := aDuration.
	easing := anInterpolator.
	requestedTracks with: ownedTracks do: [ :each :ownedTrack |
		ownedTrack targetValue: each targetValue.
	self startFromCurrentPresentation.
	^ self
]

{ #category : 'controlling' }
CFMotion >> reversed [
	(self hasComponentMotions) ifTrue: [
		^ CFMotion composedOf: (componentMotions collect: #reversed) ].
	^ (CFMotion
		coordinator: coordinator
		tracks: (tracks reverse collect: #reversed))
		duration: duration;
		easing: easing;
		yourself
]

{ #category : 'playing' }
CFMotion >> start [
	(self hasComponentMotions) ifTrue: [ ^ self startComponentMotions ].
	tracks do: [ :each | each validateForExecution ].
	self claimTracks.
	tracks do: [ :each | each captureOriginIn: coordinator ].
	tracks do: [ :each | each playbackStartedIn: coordinator ].
	self startFromCurrentPresentation.
	^ self
]

{ #category : 'private - playing' }
CFMotion >> startComponentMotions [
	state isTerminal ifTrue: [ self error: 'A completed Motion cannot start again' ].
	(state == CFMotionState running) ifTrue: [ self error: 'A Motion cannot start while it is already running' ].
	state := CFMotionState running.
	componentMotions do: [ :each |
		each onTerminalDo: [ :anMotion | self finishComponentMotionsIfTerminal ].
		each start ].
	self finishComponentMotionsIfTerminal.
	^ self
]

{ #category : 'private - playing' }
CFMotion >> finishComponentMotionsIfTerminal [
	(state == CFMotionState running) ifFalse: [ ^ self ].
	(componentMotions allSatisfy: [ :each | each state isTerminal ]) ifFalse: [ ^ self ].
	(componentMotions anySatisfy: #isCancelled)
		ifTrue: [
			state := CFMotionState cancelled.
			self notifyTerminalHandlers ]
		ifFalse: [ self complete ]
]

{ #category : 'private - playing' }
CFMotion >> startFromCurrentPresentation [
	coordinator removeActiveMotion: self.
	tracks do: [ :each | each prepareFromCurrentPresentation ].
	timeline
		ifNil: [ elapsedTime := 0 milliSeconds ]
		ifNotNil: [ timeline prepareForPlayback ].
	state := CFMotionState running.
	(timeline isNil and: [ tracks allSatisfy: [ :each | each isAtDestination ] ]) ifTrue: [
		^ self complete ].
	coordinator play: self
]

{ #category : 'playing' }
CFMotion >> advanceWith: aFrame [
	| progress |
	state == CFMotionState running ifFalse: [ ^ self ].
	(tracks allSatisfy: [ :each | each isPlaybackValidIn: coordinator ]) ifFalse: [
		^ self cancelPreservingCurrentPresentation ].
	timeline ifNotNil: [
		timeline advanceBy: aFrame elapsedTime.
		timeline isComplete ifTrue: [ self complete ].
		^ self ].
	elapsedTime := elapsedTime + aFrame elapsedTime.
	progress := duration isZero
		ifTrue: [ 1.0 ]
		ifFalse: [ (elapsedTime / duration) min: 1.0 ].
	progress := easing interpolate: progress.
	tracks do: [ :each | each applyProgress: progress ].
	elapsedTime >= duration ifTrue: [ self complete ]
]

{ #category : 'controlling' }
CFMotion >> pause [
	state == CFMotionState running ifFalse: [ ^ self ].
	coordinator removeActiveMotion: self.
	state := CFMotionState paused.
	^ self
]

{ #category : 'controlling' }
CFMotion >> resume [
	state == CFMotionState paused ifFalse: [ ^ self ].
	state := CFMotionState running.
	coordinator play: self.
	^ self
]

{ #category : 'testing' }
CFMotion >> isPaused [
	^ state == CFMotionState paused
]

{ #category : 'accessing' }
CFMotion >> elapsedTime [
	^ timeline
		ifNil: [ elapsedTime ]
		ifNotNil: [ timeline elapsedTime ]
]

{ #category : 'accessing' }
CFMotion >> timeline [
	^ timeline
]

{ #category : 'accessing' }
CFMotion >> timeline: aTimeline [
	timeline := aTimeline
]

{ #category : 'accessing' }
CFMotion >> state [ ^ state ]

{ #category : 'accessing' }
CFMotion >> tracks [ ^ tracks asArray ]

{ #category : 'accessing' }
CFMotion >> tracks: aCollection [ tracks := aCollection asOrderedCollection ]
