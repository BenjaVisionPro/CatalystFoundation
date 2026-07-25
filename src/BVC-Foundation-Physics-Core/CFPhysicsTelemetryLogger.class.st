"I am the bounded Pharo Telemetry logger owned by one Physics world.

I do not define a telemetry model. I only select TelemetrySignal instances whose #physicsWorld metadata identifies my world, and bound the retained Beacon recordings so a diagnostic session cannot grow without limit."
Class {
	#name : 'CFPhysicsTelemetryLogger',
	#superclass : 'TelemetryLogger',
	#instVars : [ 'world', 'capacity' ],
	#category : 'BVC-Foundation-Physics-Core',
	#package : 'BVC-Foundation-Physics-Core'
}

{ #category : 'instance creation' }
CFPhysicsTelemetryLogger class >> on: aWorld [
	^ self new world: aWorld; yourself
]

{ #category : 'initialization' }
CFPhysicsTelemetryLogger >> initialize [
	super initialize.
	capacity := 300
]

{ #category : 'accessing' }
CFPhysicsTelemetryLogger >> capacity [ ^ capacity ]

{ #category : 'accessing' }
CFPhysicsTelemetryLogger >> capacity: anInteger [
	capacity := anInteger max: 1.
	self trimRecordings
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
	super nextPut: aSignal.
	self trimRecordings
]

{ #category : 'private - accessing' }
CFPhysicsTelemetryLogger >> trimRecordings [
	[ recordings size > capacity ] whileTrue: [ recordings removeFirst ]
]
