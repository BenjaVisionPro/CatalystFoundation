"I adapt one Physics world's telemetry announcer to GT's asynchronous stream protocol.

I retain at most the latest pending update. This prevents a live Physics world from
building a backlog when telemetry is produced faster than Bloc can redraw the
statistics element. The element sink owns consumption; finalization removes the
announcer subscription."
Class {
	#name : 'CFPhysicsTelemetryUpdatesStream',
	#superclass : 'Object',
	#traits : 'TAsyncStream',
	#classTraits : 'TAsyncStream classTrait',
	#instVars : [
		'world',
		'waker',
		'updates'
	],
	#category : 'BVC-Foundation-Physics-Tools',
	#package : 'BVC-Foundation-Physics-Tools'
}

{ #category : 'instance creation' }
CFPhysicsTelemetryUpdatesStream class >> on: aWorld [
	^ self new
		registerOn: aWorld;
		yourself
]

{ #category : 'initialization' }
CFPhysicsTelemetryUpdatesStream >> initialize [
	super initialize.
	updates := AsyncMutex for: LinkedList new.
	waker := AsyncFutureExecutionAtomicWaker new
]

{ #category : 'initialization' }
CFPhysicsTelemetryUpdatesStream >> registerOn: aWorld [
	world := aWorld.
	world telemetryAnnouncer weak
		when: Announcement
		send: #onTelemetryChanged:
		to: self.
	self class finalizationRegistry add: self
]

{ #category : 'private - announcements' }
CFPhysicsTelemetryUpdatesStream >> onTelemetryChanged: anAnnouncement [
	updates lock: [ :pendingUpdates |
		pendingUpdates removeAll.
		pendingUpdates addLast: anAnnouncement.
		waker wakeUp ]
]

{ #category : 'api - stream' }
CFPhysicsTelemetryUpdatesStream >> pollNext: anAsynchronousContext [
	<return: #AsyncPoll>
	^ updates lock: [ :pendingUpdates |
		pendingUpdates
			ifEmpty: [
				waker register: anAsynchronousContext waker.
				AsyncPoll indefinitelyPending ]
			ifNotEmpty: [
				AsyncPoll ready: (AsyncOptionalValue some: pendingUpdates removeFirst) ] ]
]

{ #category : 'finalization' }
CFPhysicsTelemetryUpdatesStream >> finalize [
	super finalize.
	world ifNotNil: [ world telemetryAnnouncer unsubscribe: self ]
]

{ #category : 'api - stream copy' }
CFPhysicsTelemetryUpdatesStream >> postSimilarCopy [
	updates := AsyncMutex for: LinkedList new.
	waker := AsyncFutureExecutionAtomicWaker new.
	self registerOn: world
]
