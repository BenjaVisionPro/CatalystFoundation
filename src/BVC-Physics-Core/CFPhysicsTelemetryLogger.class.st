"
I record telemetry signals for one Physics world.

My responsibility is to retain accepted signals in a bounded ring buffer, defer background-solve signals until commit and throttle change announcements for live tools.
"
Class {
	#name : 'CFPhysicsTelemetryLogger',
	#superclass : 'TelemetryLogger',
	#instVars : [ 'world', 'lastAnnouncementMilliseconds', 'announcementIntervalMilliseconds', 'detachedSignals', 'committedSolveTicket' ],
	#category : 'BVC-Physics-Core',
	#package : 'BVC-Physics-Core'
}

{ #category : 'configuration' }
CFPhysicsTelemetryLogger class >> defaultCapacity [
	^ 3600
]

{ #category : 'instance creation' }
CFPhysicsTelemetryLogger class >> on: aWorld [
	^ self new world: aWorld; yourself
]

{ #category : 'initialization' }
CFPhysicsTelemetryLogger >> initialize [
	super initialize.
	self telemetryClass: ProcessTelemetry.
	lastAnnouncementMilliseconds := 0.
	announcementIntervalMilliseconds := 250.
	detachedSignals := SharedQueue new.
	committedSolveTicket := nil
]

{ #category : 'accessing' }
CFPhysicsTelemetryLogger >> capacity [ ^ recordings capacity ]

{ #category : 'accessing' }
CFPhysicsTelemetryLogger >> capacity: anInteger [
	recordings capacity: anInteger
]


{ #category : 'initialization' }
CFPhysicsTelemetryLogger >> reset [
	| retainedCapacity |
	retainedCapacity := recordings
		ifNil: [ self class defaultCapacity ]
		ifNotNil: [ recordings capacity ].
	mutex critical: [
		recordings := CFPhysicsTelemetryRingBuffer capacity: retainedCapacity ]
]

{ #category : 'accessing' }
CFPhysicsTelemetryLogger >> announcementIntervalMilliseconds [ ^ announcementIntervalMilliseconds ]


{ #category : 'accessing' }
CFPhysicsTelemetryLogger >> announcementIntervalMilliseconds: anInteger [
	announcementIntervalMilliseconds := anInteger max: 1
]

{ #category : 'accessing' }
CFPhysicsTelemetryLogger >> world [
	^ world
]

{ #category : 'accessing' }
CFPhysicsTelemetryLogger >> world: aWorld [ world := aWorld ]

{ #category : 'accessing' }
CFPhysicsTelemetryLogger >> nextPut: aSignal [
	| physicsData solveTicket publishNow |
	aSignal class == TelemetrySignal ifFalse: [ ^ self ].
	physicsData := aSignal data
		at: #physicsFrame
		ifAbsent: [ aSignal data at: #physicsPresentation ifAbsent: [ nil ] ].
	(physicsData notNil and: [ (physicsData at: #physicsWorld ifAbsent: [ nil ]) == world ])
		ifFalse: [ ^ self ].
	physicsData at: #telemetryRecordedAt put: DateAndTime now.
	solveTicket := physicsData at: #solveTicket ifAbsent: [ nil ].
	solveTicket ifNil: [ ^ self publish: aSignal ].
	publishNow := false.
	mutex critical: [
		committedSolveTicket = solveTicket
			ifTrue: [
				committedSolveTicket := nil.
				publishNow := true ]
			ifFalse: [ detachedSignals nextPut: aSignal ] ].
	publishNow ifTrue: [ self publish: aSignal ]
]

{ #category : 'private - recording' }
CFPhysicsTelemetryLogger >> publish: aSignal [
	super nextPut: aSignal.
	self announceIfDue
]

{ #category : 'detached stepping' }
CFPhysicsTelemetryLogger >> commitSolveTicket: aSolveTicket [
	| signal matchingSignal |
	mutex critical: [
		[ (signal := detachedSignals nextOrNil) isNotNil ] whileTrue: [
			((signal data at: #physicsFrame) at: #solveTicket) = aSolveTicket
				ifTrue: [ matchingSignal := signal ] ].
		matchingSignal
			ifNil: [ committedSolveTicket := aSolveTicket ]
			ifNotNil: [ committedSolveTicket := nil ] ].
	matchingSignal ifNotNil: [ self publish: matchingSignal ]
]

{ #category : 'detached stepping' }
CFPhysicsTelemetryLogger >> rejectSolveTicket: aSolveTicket [
	mutex critical: [
		committedSolveTicket = aSolveTicket ifTrue: [ committedSolveTicket := nil ].
		self discardDetachedSignalsUnsafe ]
]

{ #category : 'detached stepping' }
CFPhysicsTelemetryLogger >> discardDetachedSignals [
	mutex critical: [
		committedSolveTicket := nil.
		self discardDetachedSignalsUnsafe ]
]

{ #category : 'private - detached stepping' }
CFPhysicsTelemetryLogger >> discardDetachedSignalsUnsafe [
	[ detachedSignals nextOrNil isNotNil ] whileTrue
]

{ #category : 'private - announcing' }
CFPhysicsTelemetryLogger >> announceIfDue [
	| now |
	now := Time millisecondClockValue.
	(now - lastAnnouncementMilliseconds >= announcementIntervalMilliseconds
		or: [ now < lastAnnouncementMilliseconds ]) ifFalse: [ ^ self ].
	lastAnnouncementMilliseconds := now.
	world announceTelemetryChanged
]
