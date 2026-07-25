Class {
	#name : 'CFPhysicsWorldTelemetry',
	#superclass : 'Object',
	#instVars : [ 'capacity', 'samples', 'metrics', 'metricsBySelector', 'stageMetricsByClass' ],
	#category : 'BVC-Foundation-Physics-Core',
	#package : 'BVC-Foundation-Physics-Core'
}

{ #category : 'initialization' }
CFPhysicsWorldTelemetry >> initialize [
	super initialize.
	capacity := 300.
	samples := OrderedCollection new.
	metrics := OrderedCollection new.
	metricsBySelector := Dictionary new.
	stageMetricsByClass := IdentityDictionary new.
	self initializeMetrics
]

{ #category : 'initialization' }
CFPhysicsWorldTelemetry >> initializeMetrics [
	self
		addMetricNamed: 'Total frame' unit: 'ms' selector: #totalMilliseconds;
		addMetricNamed: 'Membership' unit: 'ms' selector: #membershipMilliseconds;
		addMetricNamed: 'Preparation' unit: 'ms' selector: #preparationMilliseconds;
		addMetricNamed: 'Pipeline' unit: 'ms' selector: #pipelineMilliseconds;
		addMetricNamed: 'Boundary' unit: 'ms' selector: #boundaryMilliseconds;
		addMetricNamed: 'Unaccounted' unit: 'ms' selector: #unaccountedMilliseconds;
		addMetricNamed: 'Bodies' unit: 'count' selector: #bodyCount;
		addMetricNamed: 'Active bodies' unit: 'count' selector: #activeBodyCount;
		addMetricNamed: 'Sleeping bodies' unit: 'count' selector: #sleepingBodyCount;
		addMetricNamed: 'Contacts' unit: 'count' selector: #contactCount;
		addMetricNamed: 'Constraints' unit: 'count' selector: #constraintCount;
		addMetricNamed: 'Joints' unit: 'count' selector: #jointCount
]

{ #category : 'initialization' }
CFPhysicsWorldTelemetry >> addMetricNamed: aString unit: aUnitString selector: aSelector [
	| metric |
	metric := CFPhysicsMetric
		named: aString
		unit: aUnitString
		selector: aSelector
		capacity: capacity.
	metrics add: metric.
	metricsBySelector at: aSelector put: metric.
	^ metric
]

{ #category : 'accessing' }
CFPhysicsWorldTelemetry >> capacity [ ^ capacity ]

{ #category : 'accessing' }
CFPhysicsWorldTelemetry >> capacity: anInteger [
	capacity := anInteger max: 1.
	[ samples size > capacity ] whileTrue: [ samples removeFirst ].
	metrics do: [ :each | each capacity: capacity ].
	stageMetricsByClass valuesDo: [ :each | each capacity: capacity ].
	^ self
]

{ #category : 'accessing' }
CFPhysicsWorldTelemetry >> samples [ ^ samples asArray ]

{ #category : 'accessing' }
CFPhysicsWorldTelemetry >> sampleCount [ ^ samples size ]

{ #category : 'accessing' }
CFPhysicsWorldTelemetry >> latest [
	^ samples ifEmpty: [ nil ] ifNotEmpty: [ samples last ]
]

{ #category : 'accessing' }
CFPhysicsWorldTelemetry >> metrics [ ^ metrics asArray ]

{ #category : 'accessing' }
CFPhysicsWorldTelemetry >> metricAt: aSelector [
	^ metricsBySelector at: aSelector
]

{ #category : 'accessing' }
CFPhysicsWorldTelemetry >> stageMetricForClass: aStageClass [
	^ stageMetricsByClass
		at: aStageClass
		ifAbsentPut: [ CFPhysicsStageMetric forStageClass: aStageClass capacity: capacity ]
]

{ #category : 'accessing' }
CFPhysicsWorldTelemetry >> stageMetrics [
	| latestFrame ordered |
	latestFrame := self latest.
	latestFrame ifNil: [ ^ #() ].
	ordered := OrderedCollection new.
	latestFrame stageExecutions do: [ :execution |
		| metric |
		metric := stageMetricsByClass at: execution stage class ifAbsent: [ nil ].
		metric ifNotNil: [ ordered add: metric ] ].
	^ ordered asArray
]

{ #category : 'accessing' }
CFPhysicsWorldTelemetry >> hotspots [
	^ self stageMetrics sorted: [ :left :right | left average > right average ]
]

{ #category : 'recording' }
CFPhysicsWorldTelemetry >> record: aFrameMetrics [
	aFrameMetrics ifNil: [ self error: 'A telemetry frame cannot be nil' ].
	metrics do: [ :each | each recordFrame: aFrameMetrics ].
	aFrameMetrics stageExecutions do: [ :execution |
		(self stageMetricForClass: execution stage class)
			recordExecution: execution ].
	samples add: aFrameMetrics.
	[ samples size > capacity ] whileTrue: [ samples removeFirst ].
	^ aFrameMetrics
]

{ #category : 'recording' }
CFPhysicsWorldTelemetry >> reset [
	samples removeAll.
	metrics do: #reset.
	stageMetricsByClass valuesDo: #reset.
	^ self
]

{ #category : 'statistics' }
CFPhysicsWorldTelemetry >> latestFrameShareOf: aMetric [
	| total |
	aMetric unit = 'ms' ifFalse: [ ^ nil ].
	total := (self metricAt: #totalMilliseconds) latest.
	^ total = 0.0 ifTrue: [ 0.0 ] ifFalse: [ aMetric latest / total ]
]

{ #category : 'statistics' }
CFPhysicsWorldTelemetry >> latestPipelineShareOf: aStageMetric [
	| pipeline |
	pipeline := (self metricAt: #pipelineMilliseconds) latest.
	^ pipeline = 0.0 ifTrue: [ 0.0 ] ifFalse: [ aStageMetric latest / pipeline ]
]

{ #category : 'formatting' }
CFPhysicsWorldTelemetry >> formattedValueOf: aMetric value: aNumber [
	aMetric unit = 'ms' ifTrue: [ ^ self formattedMilliseconds: aNumber ].
	^ (aNumber isInteger
		ifTrue: [ aNumber printString ]
		ifFalse: [ (aNumber roundTo: 0.01) printString ])
]

{ #category : 'formatting' }
CFPhysicsWorldTelemetry >> formattedMilliseconds: aNumber [
	^ (aNumber roundTo: 0.001) printString
]

{ #category : 'formatting' }
CFPhysicsWorldTelemetry >> formattedPercent: aNumber [
	^ ((aNumber * 100.0) roundTo: 0.1) printString , '%'
]
