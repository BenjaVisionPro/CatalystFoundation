"
I am a complete temporal composition played by a CFMotionCoordinator.

I own my tracks, optional source timeline, playback position, easing, lifecycle and completion. I prepare and claim my presentation tracks when started, then advance only from the shared CFMotionFrames supplied by my coordinator. I do not create Bloc animations, schedule pulses or read a clock.

The coordinator owns frame scheduling and cross-Motion presentation coordination. Tracks own presentation interpolation. CFMotionTimeline currently supplies temporal layout and will become the richer runtime timeline in the next cutover slice.
"
Class {
	#name : 'CFMotion',
	#superclass : 'Object',
	#instVars : [ 'coordinator', 'timeline', 'tracks', 'duration', 'easing', 'elapsedTime', 'state', 'trace', 'terminalHandlers', 'holdAtDestination', 'componentMotions' ],
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
		duration: aTimeline duration;
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
	trace := CFMotionTrace new.
	terminalHandlers := OrderedCollection new.
	holdAtDestination := false.
	componentMotions := OrderedCollection new
]

{ #category : 'controlling' }
CFMotion >> cancel [ ^ self cancelPreservingCurrentPresentation ]

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
	trace record: #cancelled for: self.
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
	trace record: #cancelled for: self.
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
		trace record: #completed for: self.
		self notifyTerminalHandlers.
		^ self ].
	holdAtDestination ifTrue: [
		state := CFMotionState settled.
		trace record: #settled for: self.
		^ self ].
	tracks do: [ :each | each applyDestination ].
	state := CFMotionState completed.
	trace record: #completed for: self.
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
	tracks do: [ :each | coordinator claim: each propertyKey for: self ].
	trace record: #claimed for: self
]

{ #category : 'private - ownership' }
CFMotion >> releaseClaims [
	coordinator releaseAllFor: self.
	trace record: #cleanedUp for: self
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
		trace record: #retargeted for: self track: ownedTrack ].
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
	self startFromCurrentPresentation.
	^ self
]

{ #category : 'private - playing' }
CFMotion >> startComponentMotions [
	state isTerminal ifTrue: [ self error: 'A completed Motion cannot start again' ].
	(state == CFMotionState running) ifTrue: [ self error: 'A Motion cannot start while it is already running' ].
	state := CFMotionState running.
	trace record: #started for: self.
	componentMotions do: [ :each |
		each onTerminalDo: [ :anOperation | self finishComponentMotionsIfTerminal ].
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
			trace record: #cancelled for: self.
			self notifyTerminalHandlers ]
		ifFalse: [ self complete ]
]

{ #category : 'private - playing' }
CFMotion >> startFromCurrentPresentation [
	coordinator removeActiveMotion: self.
	tracks do: [ :each | each prepareFromCurrentPresentation ].
	elapsedTime := 0 milliSeconds.
	state := CFMotionState running.
	trace record: #started for: self.
	(tracks allSatisfy: [ :each | each isAtDestination ]) ifTrue: [
		^ self complete ].
	coordinator play: self
]

{ #category : 'playing' }
CFMotion >> advanceWith: aFrame [
	| progress |
	state == CFMotionState running ifFalse: [ ^ self ].
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
	trace record: #paused for: self.
	^ self
]

{ #category : 'controlling' }
CFMotion >> resume [
	state == CFMotionState paused ifFalse: [ ^ self ].
	state := CFMotionState running.
	trace record: #resumed for: self.
	coordinator play: self.
	^ self
]

{ #category : 'testing' }
CFMotion >> isPaused [
	^ state == CFMotionState paused
]

{ #category : 'accessing' }
CFMotion >> elapsedTime [
	^ elapsedTime
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
CFMotion >> trace [ ^ trace ]

{ #category : 'accessing' }
CFMotion >> tracks [ ^ tracks asArray ]

{ #category : 'accessing' }
CFMotion >> tracks: aCollection [ tracks := aCollection asOrderedCollection ]
