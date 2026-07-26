"I collect benchmark results so optimisation focus can be compared across controlled workloads without claiming a universal hotspot."
Class {
	#name : 'CFPhysicsTelemetryBenchmarkSuite',
	#superclass : 'Object',
	#instVars : [ 'results' ],
	#category : 'BVC-Foundation-Physics-Tools-Telemetry',
	#package : 'BVC-Foundation-Physics-Tools'
}

{ #category : 'instance creation' }
CFPhysicsTelemetryBenchmarkSuite class >> results: aCollection [
	^ self new results: aCollection; yourself
]

{ #category : 'accessing' }
CFPhysicsTelemetryBenchmarkSuite >> results [ ^ results ifNil: [ #() ] ]

{ #category : 'accessing' }
CFPhysicsTelemetryBenchmarkSuite >> results: aCollection [ results := aCollection ]

{ #category : 'printing' }
CFPhysicsTelemetryBenchmarkSuite >> printOn: aStream [
	aStream
		nextPutAll: self class name;
		nextPutAll: '(';
		print: self results size;
		nextPutAll: ' workloads)'
]

{ #category : 'gt - views' }
CFPhysicsTelemetryBenchmarkSuite >> gtScenarioFocusFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Scenario focus';
		priority: 10;
		items: [ self results ];
		column: 'Scenario' text: #scenarioName;
		column: 'Top measured span' text: [ :result |
			result topFocusSpan ifNil: [ '' ] ifNotNil: [ :span | span readableName ] ];
		column: 'Share' text: [ :result |
			result topFocusSpan
				ifNil: [ '' ]
				ifNotNil: [ :span | ((result averageShareFor: span) * 100) printShowingDecimalPlaces: 1 , '%' ] ];
		column: 'Average step (ms)' text: [ :result | result averageStepMilliseconds printShowingDecimalPlaces: 3 ];
		column: 'P95 step (ms)' text: [ :result | result p95StepMilliseconds printShowingDecimalPlaces: 3 ];
		column: 'Samples' text: [ :result | result analysis sampleCount ];
		send: [ :result | result ]
]

{ #category : 'gt - views' }
CFPhysicsTelemetryBenchmarkSuite >> gtAllMeasuredSpansFor: aView [
	<gtView>
	| rows |
	rows := OrderedCollection new.
	self results do: [ :result |
		result focusSpans do: [ :span | rows add: { result. span } ] ].
	^ aView columnedList
		title: 'All measured spans';
		priority: 11;
		items: [ rows ];
		column: 'Scenario' text: [ :row | row first scenarioName ];
		column: 'Span' text: [ :row | row second readableName ];
		column: 'Average (ms)' text: [ :row | row second averageMilliseconds printShowingDecimalPlaces: 3 ];
		column: 'P95 (ms)' text: [ :row | row second p95Milliseconds printShowingDecimalPlaces: 3 ];
		column: 'Share' text: [ :row | ((row first averageShareFor: row second) * 100) printShowingDecimalPlaces: 1 , '%' ];
		send: [ :row | row second ]
]
