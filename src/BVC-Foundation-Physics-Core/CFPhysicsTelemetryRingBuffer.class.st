"I am the fixed-capacity chronological storage used by Physics telemetry.

Appending when full overwrites the oldest recording without shifting the retained collection. #asArray always answers the retained recordings from oldest to newest."
Class {
	#name : 'CFPhysicsTelemetryRingBuffer',
	#superclass : 'Object',
	#instVars : [ 'storage', 'capacity', 'size', 'nextIndex' ],
	#category : 'BVC-Foundation-Physics-Core',
	#package : 'BVC-Foundation-Physics-Core'
}

{ #category : 'instance creation' }
CFPhysicsTelemetryRingBuffer class >> capacity: anInteger [
	^ self new capacity: anInteger; yourself
]

{ #category : 'initialization' }
CFPhysicsTelemetryRingBuffer >> initialize [
	super initialize.
	capacity := 1.
	storage := Array new: capacity.
	size := 0.
	nextIndex := 1
]

{ #category : 'accessing' }
CFPhysicsTelemetryRingBuffer >> capacity [ ^ capacity ]

{ #category : 'accessing' }
CFPhysicsTelemetryRingBuffer >> capacity: anInteger [
	| retained newCapacity |
	newCapacity := anInteger max: 1.
	newCapacity = capacity ifTrue: [ ^ self ].
	retained := self asArray.
	retained size > newCapacity ifTrue: [
		retained := retained copyFrom: retained size - newCapacity + 1 to: retained size ].
	capacity := newCapacity.
	storage := Array new: capacity.
	size := 0.
	nextIndex := 1.
	retained do: [ :each | self add: each ]
]

{ #category : 'adding' }
CFPhysicsTelemetryRingBuffer >> add: anObject [
	storage at: nextIndex put: anObject.
	nextIndex := nextIndex = capacity ifTrue: [ 1 ] ifFalse: [ nextIndex + 1 ].
	size := (size + 1) min: capacity.
	^ anObject
]

{ #category : 'accessing' }
CFPhysicsTelemetryRingBuffer >> size [ ^ size ]

{ #category : 'testing' }
CFPhysicsTelemetryRingBuffer >> isEmpty [ ^ size = 0 ]

{ #category : 'testing' }
CFPhysicsTelemetryRingBuffer >> isNotEmpty [ ^ size > 0 ]

{ #category : 'enumerating' }
CFPhysicsTelemetryRingBuffer >> do: aBlock [
	self asArray do: aBlock
]

{ #category : 'converting' }
CFPhysicsTelemetryRingBuffer >> asArray [
	| answer firstIndex sourceIndex |
	answer := Array new: size.
	size = 0 ifTrue: [ ^ answer ].
	firstIndex := size = capacity ifTrue: [ nextIndex ] ifFalse: [ 1 ].
	1 to: size do: [ :targetIndex |
		sourceIndex := firstIndex + targetIndex - 1.
		sourceIndex > capacity ifTrue: [ sourceIndex := sourceIndex - capacity ].
		answer at: targetIndex put: (storage at: sourceIndex) ].
	^ answer
]

{ #category : 'removing' }
CFPhysicsTelemetryRingBuffer >> removeAll [
	storage := Array new: capacity.
	size := 0.
	nextIndex := 1
]
