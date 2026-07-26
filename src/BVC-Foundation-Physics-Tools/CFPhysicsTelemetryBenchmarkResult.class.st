"I retain the measured telemetry and derived stage ranking for one controlled Physics workload. My conclusions are limited to this recorded run."
Class {
	#name : 'CFPhysicsTelemetryBenchmarkResult',
	#superclass : 'Object',
	#instVars : [
		'scenarioName',
		'parameters',
		'warmupSteps',
		'measuredSteps',
		'world',
		'analysis'
	],
	#category : 'BVC-Foundation-Physics-Tools-Telemetry',
	#package : 'BVC-Foundation-Physics-Tools'
}

{ #category : 'instance creation' }
CFPhysicsTelemetryBenchmarkResult class >> scenario: aString parameters: aCollection warmupSteps: warmupCount measuredSteps: measuredCount world: aWorld [
	^ self new
		scenarioName: aString;
		parameters: aCollection;
		warmupSteps: warmupCount;
		measuredSteps: measuredCount;
		world: aWorld;
		analysis: (CFPhysicsTelemetryAnalysis world: aWorld);
		yourself
]

{ #category : 'accessing' }
CFPhysicsTelemetryBenchmarkResult >> scenarioName [ ^ scenarioName ]

{ #category : 'accessing' }
CFPhysicsTelemetryBenchmarkResult >> scenarioName: aString [ scenarioName := aString ]

{ #category : 'accessing' }
CFPhysicsTelemetryBenchmarkResult >> parameters [ ^ parameters ifNil: [ #() ] ]

{ #category : 'accessing' }
CFPhysicsTelemetryBenchmarkResult >> parameters: aCollection [ parameters := aCollection ]

{ #category : 'accessing' }
CFPhysicsTelemetryBenchmarkResult >> warmupSteps [ ^ warmupSteps ]

{ #category : 'accessing' }
CFPhysicsTelemetryBenchmarkResult >> warmupSteps: anInteger [ warmupSteps := anInteger ]

{ #category : 'accessing' }
CFPhysicsTelemetryBenchmarkResult >> measuredSteps [ ^ measuredSteps ]

{ #category : 'accessing' }
CFPhysicsTelemetryBenchmarkResult >> measuredSteps: anInteger [ measuredSteps := anInteger ]

{ #category : 'accessing' }
CFPhysicsTelemetryBenchmarkResult >> world [ ^ world ]

{ #category : 'accessing' }
CFPhysicsTelemetryBenchmarkResult >> world: aWorld [ world := aWorld ]

{ #category : 'accessing' }
CFPhysicsTelemetryBenchmarkResult >> analysis [ ^ analysis ]

{ #category : 'accessing' }
CFPhysicsTelemetryBenchmarkResult >> analysis: anAnalysis [ analysis := anAnalysis ]

{ #category : 'accessing' }
CFPhysicsTelemetryBenchmarkResult >> rootStatistics [ ^ analysis rootStatistics ]

{ #category : 'accessing' }
CFPhysicsTelemetryBenchmarkResult >> focusSpans [
	| root spans |
	root := self rootStatistics.
	root ifNil: [ ^ #() ].
	spans := OrderedCollection new.
	root children do: [ :span |
		span name asString = 'Pipeline'
			ifTrue: [ spans addAll: span children ]
			ifFalse: [ spans add: span ] ].
	^ spans sorted: [ :a :b | a averageDuration > b averageDuration ]
]

{ #category : 'accessing' }
CFPhysicsTelemetryBenchmarkResult >> topFocusSpan [
	^ self focusSpans ifEmpty: [ nil ] ifNotEmpty: [ :spans | spans first ]
]

{ #category : 'statistics' }
CFPhysicsTelemetryBenchmarkResult >> averageStepMilliseconds [
	^ self rootStatistics ifNil: [ 0 ] ifNotNil: [ :root | root averageMilliseconds ]
]

{ #category : 'statistics' }
CFPhysicsTelemetryBenchmarkResult >> p95StepMilliseconds [
	^ self rootStatistics ifNil: [ 0 ] ifNotNil: [ :root | root p95Milliseconds ]
]

{ #category : 'statistics' }
CFPhysicsTelemetryBenchmarkResult >> averageShareFor: aSpan [
	^ aSpan averageShareOf: self rootStatistics
]

{ #category : 'printing' }
CFPhysicsTelemetryBenchmarkResult >> printOn: aStream [
	aStream
		nextPutAll: self class name;
		nextPutAll: '(';
		nextPutAll: scenarioName;
		nextPutAll: ', ';
		print: measuredSteps;
		nextPutAll: ' measured steps)'
]

{ #category : 'gt - views' }
CFPhysicsTelemetryBenchmarkResult >> gtSummaryFor: aView [
	<gtView>
	| top |
	top := self topFocusSpan.
	^ aView columnedList
		title: 'Summary';
		priority: 10;
		items: [ {
			'Scenario' -> scenarioName.
			'Parameters' -> self parameters.
			'Warm-up steps' -> warmupSteps.
			'Measured steps' -> measuredSteps.
			'Recorded steps' -> analysis sampleCount.
			'Average step (ms)' -> self averageStepMilliseconds.
			'P95 step (ms)' -> self p95StepMilliseconds.
			'Highest measured focus' -> (top ifNil: [ '' ] ifNotNil: [ top readableName ]).
			'Highest measured share' -> (top ifNil: [ 0 ] ifNotNil: [ self averageShareFor: top ]) } ];
		column: 'Property' text: #key;
		column: 'Value' text: #value;
		send: #value
]

{ #category : 'gt - views' }
CFPhysicsTelemetryBenchmarkResult >> gtOptimisationFocusFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Optimisation focus';
		priority: 11;
		items: [ self focusSpans ];
		column: 'Rank' text: [ :span | (self focusSpans indexOf: span) asString ];
		column: 'Span' text: #readableName;
		column: 'Average (ms)' text: [ :span | span averageMilliseconds asFloat printShowingDecimalPlaces: 3 ];
		column: 'Median (ms)' text: [ :span | span medianMilliseconds asFloat printShowingDecimalPlaces: 3 ];
		column: 'P95 (ms)' text: [ :span | span p95Milliseconds asFloat printShowingDecimalPlaces: 3 ];
		column: 'Average share' text: [ :span | (((self averageShareFor: span) * 100) asFloat printShowingDecimalPlaces: 1), '%' ];
		column: 'Samples' text: #sampleCount;
		send: [ :span | span ]
]

{ #category : 'gt - views' }
CFPhysicsTelemetryBenchmarkResult >> gtRecordingsFor: aView [
	<gtView>
	^ aView list
		title: 'Recordings';
		priority: 12;
		items: [ analysis stepRecordings ];
		send: [ :signal | signal ]
]
