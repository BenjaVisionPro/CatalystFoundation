"
I stream the latest telemetry change from one Physics world. I keep at most one pending update so inspector consumers cannot accumulate stale announcements.
"
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
	#category : 'BVC-Physics-Tools',
	#package : 'BVC-Physics-Tools'
}

{ #category : 'instance creation' }
CFPhysicsTelemetryStream class >> on: aWorld [
	^ self new
		registerOn: aWorld;
		yourself
]

{ #category : 'finalization' }
CFPhysicsTelemetryStream >> finalize [
	super finalize.
	world ifNotNil: [ world telemetryAnnouncer unsubscribe: self ]
]

{ #category : 'initialization' }
CFPhysicsTelemetryStream >> initialize [
	super initialize.
	updates := AsyncMutex for: LinkedList new.
	waker := AsyncFutureExecutionAtomicWaker new
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

{ #category : 'api - stream copy' }
CFPhysicsTelemetryStream >> postSimilarCopy [
	updates := AsyncMutex for: LinkedList new.
	waker := AsyncFutureExecutionAtomicWaker new.
	self registerOn: world
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
