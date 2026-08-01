"I represent a collection of Physics benchmark results. My responsibility is to compare scenarios and expose their measured spans for inspection."
Class {
	#name : 'CFPhysicsTelemetryBenchmarkSuite',
	#superclass : 'Object',
	#instVars : [ 'results' ],
	#category : 'BVC-Physics-Examples',
	#package : 'BVC-Physics-Examples'
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
				ifNotNil: [ :span | (((result averageShareFor: span) * 100) asFloat printShowingDecimalPlaces: 1), '%' ] ];
		column: 'Average step (ms)' text: [ :result | result averageStepMilliseconds asFloat printShowingDecimalPlaces: 3 ];
		column: 'P95 step (ms)' text: [ :result | result p95StepMilliseconds asFloat printShowingDecimalPlaces: 3 ];
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
		column: 'Average (ms)' text: [ :row | row second averageMilliseconds asFloat printShowingDecimalPlaces: 3 ];
		column: 'P95 (ms)' text: [ :row | row second p95Milliseconds asFloat printShowingDecimalPlaces: 3 ];
		column: 'Share' text: [ :row | (((row first averageShareFor: row second) * 100) asFloat printShowingDecimalPlaces: 1), '%' ];
		send: [ :row | row second ]
]
