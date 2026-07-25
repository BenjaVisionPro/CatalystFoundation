"I derive an aggregate Pharo Telemetry signal from the bounded recordings of one Physics world. I retain no measurements; every result is rebuilt from the source TelemetrySignal objects."
Class {
	#name : 'CFPhysicsTelemetryAnalysis',
	#superclass : 'Object',
	#instVars : [ 'world', 'statistic' ],
	#category : 'BVC-Foundation-Physics-Tools',
	#package : 'BVC-Foundation-Physics-Tools'
}

{ #category : 'instance creation' }
CFPhysicsTelemetryAnalysis class >> world: aWorld statistic: aSymbol [
	^ self new world: aWorld; statistic: aSymbol; yourself
]

{ #category : 'accessing' }
CFPhysicsTelemetryAnalysis >> world: aWorld [ world := aWorld ]

{ #category : 'accessing' }
CFPhysicsTelemetryAnalysis >> statistic: aSymbol [ statistic := aSymbol ]

{ #category : 'accessing' }
CFPhysicsTelemetryAnalysis >> stepRecordings [
	^ world telemetryRecordings select: [ :signal |
		| data |
		data := signal physicsData.
		data notNil and: [ (data at: #kind ifAbsent: [ nil ]) = #step ] ]
]

{ #category : 'accessing' }
CFPhysicsTelemetryAnalysis >> aggregateSignal [
	| recordings root signal |
	recordings := self stepRecordings.
	root := recordings
		ifEmpty: [ self emptyPing ]
		ifNotEmpty: [ self aggregatePings: (recordings collect: #ping) ].
	signal := TelemetrySignal new.
	signal task: root.
	signal telemetry: ProcessTelemetry.
	signal data: (Dictionary new
		at: #physicsTelemetryAggregate put: (Dictionary new
			at: #physicsWorld put: world;
			at: #statistic put: statistic;
			at: #sampleCount put: recordings size;
			yourself);
		yourself).
	^ signal
]

{ #category : 'private - aggregation' }
CFPhysicsTelemetryAnalysis >> aggregatePings: pings [
	| template aggregate children |
	template := pings first.
	aggregate := self newPingNamed: template name duration: (self statisticOf: (pings collect: #durationInMicroseconds)).
	children := OrderedCollection new.
	1 to: template tasks size do: [ :index |
		| matching child |
		matching := pings
			select: [ :ping | ping tasks size >= index ]
			thenCollect: [ :ping | ping tasks at: index ].
		matching ifNotEmpty: [
			child := self aggregatePings: matching.
			child sender: aggregate.
			children add: child ] ].
	aggregate tasks: children.
	^ aggregate
]

{ #category : 'private - aggregation' }
CFPhysicsTelemetryAnalysis >> statisticOf: numbers [
	statistic = #average ifTrue: [ ^ numbers average ].
	statistic = #p95 ifTrue: [
		| sorted rank |
		sorted := numbers sorted.
		rank := ((sorted size * 0.95) ceiling max: 1) min: sorted size.
		^ sorted at: rank ].
	self error: 'Unsupported telemetry statistic'
]

{ #category : 'private - building' }
CFPhysicsTelemetryAnalysis >> newPingNamed: aName duration: microseconds [
	^ TelemetryPing new
		name: aName;
		startTime: 0;
		endTime: microseconds;
		realStartTime: 0;
		realEndTime: microseconds;
		instVarNamed: 'gcStartTime' put: 0;
		instVarNamed: 'gcEndTime' put: 0;
		yourself
]

{ #category : 'private - building' }
CFPhysicsTelemetryAnalysis >> emptyPing [
	^ self newPingNamed: 'No Physics step recordings' duration: 1
]
