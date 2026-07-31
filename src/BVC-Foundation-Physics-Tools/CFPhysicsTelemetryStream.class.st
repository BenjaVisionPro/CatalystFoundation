"A TAsyncStream source for one Physics world telemetry announcer.

The single pending slot is the producer-side equivalent of BlEventsStream>>keepOnlyLast:
it prevents announcements from accumulating before the sink polls. AsyncPeekSink then owns
the latest received value on the element side."
Class {
	#name : 'CFPhysicsTelemetryStream',
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
CFPhysicsTelemetryStream class >> on: aWorld [
	^ self new
		registerOn: aWorld;
		yourself
]

{ #category : 'initialization' }
CFPhysicsTelemetryStream >> initialize [
	super initialize.
	updates := AsyncMutex for: LinkedList new.
	waker := AsyncFutureExecutionAtomicWaker new
]

{ #category : 'initialization' }
CFPhysicsTelemetryStream >> registerOn: aWorld [
	world := aWorld.
	world telemetryAnnouncer weak
		when: Announcement
		send: #onTelemetryChanged:
		to: self.
	self class finalizationRegistry add: self
]

{ #category : 'private - announcements' }
CFPhysicsTelemetryStream >> onTelemetryChanged: anAnnouncement [
	updates lock: [ :pendingUpdates |
		pendingUpdates removeAll.
		pendingUpdates addLast: anAnnouncement.
		waker wakeUp ]
]

{ #category : 'api - stream' }
CFPhysicsTelemetryStream >> pollNext: anAsynchronousContext [
	<return: #AsyncPoll>
	Processor activeProcess name: 'Physics Telemetry'.
	^ updates lock: [ :pendingUpdates |
		pendingUpdates
			ifEmpty: [
				waker register: anAsynchronousContext waker.
				AsyncPoll indefinitelyPending ]
			ifNotEmpty: [
				AsyncPoll ready: (AsyncOptionalValue some: pendingUpdates removeFirst) ] ]
]

{ #category : 'finalization' }
CFPhysicsTelemetryStream >> finalize [
	super finalize.
	world ifNotNil: [ world telemetryAnnouncer unsubscribe: self ]
]

{ #category : 'api - stream copy' }
CFPhysicsTelemetryStream >> postSimilarCopy [
	updates := AsyncMutex for: LinkedList new.
	waker := AsyncFutureExecutionAtomicWaker new.
	self registerOn: world
]
