"
I record telemetry signals for one Physics world.

My responsibility is to retain accepted signals in a bounded ring buffer, defer background-solve signals until commit and throttle change announcements for live tools.
"
Class {
	#name : 'CFPhysicsTelemetryLogger',
	#superclass : 'TelemetryLogger',
	#instVars : [ 'world', 'capacity', 'lastAnnouncementMilliseconds', 'announcementIntervalMilliseconds', 'detachedSignals' ],
	#category : 'BVC-Physics-Core',
	#package : 'BVC-Physics-Core'
}

{ #category : 'instance creation' }
CFPhysicsTelemetryLogger class >> on: aWorld [
	^ self new world: aWorld; yourself
]

{ #category : 'initialization' }
CFPhysicsTelemetryLogger >> initialize [
	super initialize.
	self telemetryClass: ProcessTelemetry.
	capacity := 3600.
	recordings := CFPhysicsTelemetryRingBuffer capacity: capacity.
	lastAnnouncementMilliseconds := 0.
	announcementIntervalMilliseconds := 250.
	detachedSignals := SharedQueue new
]

{ #category : 'accessing' }
CFPhysicsTelemetryLogger >> capacity [ ^ capacity ]

{ #category : 'accessing' }
CFPhysicsTelemetryLogger >> capacity: anInteger [
	capacity := anInteger max: 1.
	recordings capacity: capacity
]

{ #category : 'accessing' }
CFPhysicsTelemetryLogger >> announcementIntervalMilliseconds [ ^ announcementIntervalMilliseconds ]

{ #category : 'accessing' }
CFPhysicsTelemetryLogger >> announcementIntervalMilliseconds: anInteger [
	announcementIntervalMilliseconds := anInteger max: 1
]

{ #category : 'accessing' }
CFPhysicsTelemetryLogger >> world: aWorld [ world := aWorld ]

{ #category : 'accessing' }
CFPhysicsTelemetryLogger >> nextPut: aSignal [
	| physicsData |
	aSignal class == TelemetrySignal ifFalse: [ ^ self ].
	physicsData := aSignal data
		at: #physicsFrame
		ifAbsent: [ aSignal data at: #physicsPresentation ifAbsent: [ nil ] ].
	(physicsData notNil and: [ (physicsData at: #physicsWorld ifAbsent: [ nil ]) == world ])
		ifFalse: [ ^ self ].
	physicsData at: #telemetryRecordedAt put: DateAndTime now.
	(physicsData at: #solveTicket ifAbsent: [ nil ]) ifNotNil: [
		detachedSignals nextPut: aSignal.
		^ self ].
	self publish: aSignal
]

{ #category : 'private - recording' }
CFPhysicsTelemetryLogger >> publish: aSignal [
	super nextPut: aSignal.
	self announceIfDue
]

{ #category : 'detached stepping' }
CFPhysicsTelemetryLogger >> commitSolveTicket: aSolveTicket [
	| signal matchingSignal |
	[ (signal := detachedSignals nextOrNil) isNotNil ] whileTrue: [
		((signal data at: #physicsFrame) at: #solveTicket) = aSolveTicket
			ifTrue: [ matchingSignal := signal ] ].
	matchingSignal ifNotNil: [ self publish: matchingSignal ]
]

{ #category : 'detached stepping' }
CFPhysicsTelemetryLogger >> rejectSolveTicket: aSolveTicket [
	self discardDetachedSignals
]

{ #category : 'detached stepping' }
CFPhysicsTelemetryLogger >> discardDetachedSignals [
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
