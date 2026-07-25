"I derive aggregate Pharo Telemetry signals from the bounded recordings of one Physics world. I retain no measurements; every result is rebuilt from the source TelemetrySignal objects."
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
	signal := self signalForRoot: root sampleCount: recordings size.
	^ signal
]

{ #category : 'accessing' }
CFPhysicsTelemetryAnalysis >> comparisonSignal [
	| recordings averageRoot p95Root averageGroup p95Group root gap signal |
	recordings := self stepRecordings.
	recordings ifEmpty: [ ^ self signalForRoot: self emptyPing sampleCount: 0 ].

	statistic := #average.
	averageRoot := self aggregatePings: (recordings collect: #ping).
	averageGroup := self groupNamed: 'Average' containing: averageRoot.

	statistic := #p95.
	p95Root := self aggregatePings: (recordings collect: #ping).
	gap := ((averageGroup endTime - averageGroup startTime) * 0.03) ceiling max: 1.
	self shiftPing: p95Root by: averageGroup endTime + gap.
	p95Group := self groupNamed: 'P95' containing: p95Root.

	root := TelemetryPing new
		name: 'Physics step statistics';
		startTime: averageGroup startTime;
		endTime: p95Group endTime;
		realStartTime: averageGroup startTime;
		realEndTime: p95Group endTime;
		instVarNamed: 'gcStartTime' put: 0;
		instVarNamed: 'gcEndTime' put: 0;
		tasks: { averageGroup. p95Group };
		yourself.
	averageGroup sender: root.
	p95Group sender: root.
	signal := self signalForRoot: root sampleCount: recordings size.
	^ signal
]

{ #category : 'private - building' }
CFPhysicsTelemetryAnalysis >> signalForRoot: root sampleCount: sampleCount [
	^ TelemetrySignal new
		task: root;
		telemetry: ProcessTelemetry soleInstance;
		data: (Dictionary new
			at: #physicsTelemetryAggregate put: (Dictionary new
				at: #physicsWorld put: world;
				at: #statistic put: statistic;
				at: #sampleCount put: sampleCount;
				yourself);
			yourself);
		yourself
]

{ #category : 'private - aggregation' }
CFPhysicsTelemetryAnalysis >> aggregatePings: pings [
	^ self aggregatePings: pings templateRoot: pings first
]

{ #category : 'private - aggregation' }
CFPhysicsTelemetryAnalysis >> aggregatePings: pings templateRoot: templateRoot [
	| template aggregate children startOffset elapsed |
	template := pings first.
	startOffset := template startTime - templateRoot startTime.
	elapsed := self statisticOf: (pings collect: [ :ping | ping endTime - ping startTime ]).
	aggregate := self newPingNamed: template name start: startOffset elapsed: elapsed.
	children := OrderedCollection new.
	1 to: template tasks size do: [ :index |
		| matching child |
		matching := pings
			select: [ :ping | ping tasks size >= index ]
			thenCollect: [ :ping | ping tasks at: index ].
		matching ifNotEmpty: [
			child := self aggregatePings: matching templateRoot: templateRoot.
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
CFPhysicsTelemetryAnalysis >> newPingNamed: aName start: start elapsed: elapsed [
	^ TelemetryPing new
		name: aName;
		startTime: start;
		endTime: start + elapsed;
		realStartTime: start;
		realEndTime: start + elapsed;
		instVarNamed: 'gcStartTime' put: 0;
		instVarNamed: 'gcEndTime' put: 0;
		yourself
]

{ #category : 'private - building' }
CFPhysicsTelemetryAnalysis >> groupNamed: aName containing: aPing [
	| group |
	group := self
		newPingNamed: aName
		start: aPing startTime
		elapsed: aPing endTime - aPing startTime.
	group tasks: { aPing }.
	aPing sender: group.
	^ group
]

{ #category : 'private - building' }
CFPhysicsTelemetryAnalysis >> shiftPing: aPing by: anOffset [
	aPing
		startTime: aPing startTime + anOffset;
		endTime: aPing endTime + anOffset;
		realStartTime: aPing realStartTime + anOffset;
		realEndTime: aPing realEndTime + anOffset.
	aPing tasks do: [ :child | self shiftPing: child by: anOffset ]
]

{ #category : 'private - building' }
CFPhysicsTelemetryAnalysis >> emptyPing [
	^ self newPingNamed: 'No Physics step recordings' start: 0 elapsed: 1
]
