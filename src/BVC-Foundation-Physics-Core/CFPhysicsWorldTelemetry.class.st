Class {
	#name : 'CFPhysicsWorldTelemetry',
	#superclass : 'Object',
	#instVars : [ 'capacity', 'samples' ],
	#category : 'BVC-Foundation-Physics-Core',
	#package : 'BVC-Foundation-Physics-Core'
}

{ #category : 'initialization' }
CFPhysicsWorldTelemetry >> initialize [
	super initialize.
	capacity := 300.
	samples := OrderedCollection new
]

{ #category : 'accessing' }
CFPhysicsWorldTelemetry >> capacity [ ^ capacity ]
{ #category : 'accessing' }
CFPhysicsWorldTelemetry >> capacity: anInteger [
	capacity := anInteger max: 1.
	[ samples size > capacity ] whileTrue: [ samples removeFirst ].
	^ self
]
{ #category : 'accessing' }
CFPhysicsWorldTelemetry >> samples [ ^ samples asArray ]
{ #category : 'accessing' }
CFPhysicsWorldTelemetry >> sampleCount [ ^ samples size ]
{ #category : 'accessing' }
CFPhysicsWorldTelemetry >> latest [ ^ samples ifEmpty: [ nil ] ifNotEmpty: [ samples last ] ]
{ #category : 'recording' }
CFPhysicsWorldTelemetry >> record: aFrameMetrics [
	samples add: aFrameMetrics.
	[ samples size > capacity ] whileTrue: [ samples removeFirst ].
	^ aFrameMetrics
]
{ #category : 'recording' }
CFPhysicsWorldTelemetry >> reset [ samples removeAll. ^ self ]
{ #category : 'statistics' }
CFPhysicsWorldTelemetry >> averageOf: aSelector [
	| values |
	values := samples collect: [ :each | each perform: aSelector ].
	^ values ifEmpty: [ 0.0 ] ifNotEmpty: [ values average asFloat ]
]
{ #category : 'statistics' }
CFPhysicsWorldTelemetry >> minimumOf: aSelector [
	^ samples ifEmpty: [ 0 ] ifNotEmpty: [ (samples collect: [ :each | each perform: aSelector ]) min ]
]
{ #category : 'statistics' }
CFPhysicsWorldTelemetry >> maximumOf: aSelector [
	^ samples ifEmpty: [ 0 ] ifNotEmpty: [ (samples collect: [ :each | each perform: aSelector ]) max ]
]
{ #category : 'statistics' }
CFPhysicsWorldTelemetry >> percentile: aFraction of: aSelector [
	| values index |
	values := (samples collect: [ :each | each perform: aSelector ]) sorted.
	values ifEmpty: [ ^ 0 ].
	index := ((values size * aFraction) ceiling max: 1) min: values size.
	^ values at: index
]
{ #category : 'statistics' }
CFPhysicsWorldTelemetry >> p95Of: aSelector [ ^ self percentile: 0.95 of: aSelector ]
{ #category : 'statistics' }
CFPhysicsWorldTelemetry >> averageStageDurations [
	| totals counts |
	totals := Dictionary new.
	counts := Dictionary new.
	samples do: [ :sample |
		sample stageExecutions do: [ :execution |
			| key duration |
			key := execution name asString.
			duration := execution durationMilliseconds.
			duration ifNotNil: [
				totals at: key put: (totals at: key ifAbsent: [ 0 ]) + duration.
				counts at: key put: (counts at: key ifAbsent: [ 0 ]) + 1 ] ] ].
	^ totals associations collect: [ :association |
		association key -> (association value / (counts at: association key)) asFloat ]
]

{ #category : 'statistics' }
CFPhysicsWorldTelemetry >> formattedMilliseconds: aNumber [
	^ (aNumber roundTo: 0.01) printString
]

{ #category : 'statistics' }
CFPhysicsWorldTelemetry >> timingRowNamed: aString selector: aSelector [
	| latestValue |
	latestValue := self latest
		ifNil: [ 0 ]
		ifNotNil: [ :sample | sample perform: aSelector ].
	^ aString -> {
		self formattedMilliseconds: latestValue.
		self formattedMilliseconds: (self averageOf: aSelector).
		self formattedMilliseconds: (self p95Of: aSelector).
		self formattedMilliseconds: (self maximumOf: aSelector) }
]

{ #category : 'statistics' }
CFPhysicsWorldTelemetry >> countRowNamed: aString selector: aSelector [
	| latestValue |
	latestValue := self latest
		ifNil: [ 0 ]
		ifNotNil: [ :sample | sample perform: aSelector ].
	^ aString -> {
		latestValue.
		(self averageOf: aSelector) roundTo: 0.01.
		self p95Of: aSelector.
		self maximumOf: aSelector }
]

{ #category : 'statistics' }
CFPhysicsWorldTelemetry >> performanceRows [
	^ {
		self timingRowNamed: 'Total frame (ms)' selector: #totalMilliseconds.
		self timingRowNamed: 'Membership (ms)' selector: #membershipMilliseconds.
		self timingRowNamed: 'Preparation (ms)' selector: #preparationMilliseconds.
		self timingRowNamed: 'Pipeline (ms)' selector: #pipelineMilliseconds.
		self timingRowNamed: 'Boundary (ms)' selector: #boundaryMilliseconds.
		self countRowNamed: 'Bodies' selector: #bodyCount.
		self countRowNamed: 'Active bodies' selector: #activeBodyCount.
		self countRowNamed: 'Sleeping bodies' selector: #sleepingBodyCount.
		self countRowNamed: 'Contacts' selector: #contactCount.
		self countRowNamed: 'Constraints' selector: #constraintCount.
		self countRowNamed: 'Joints' selector: #jointCount }
]

{ #category : 'statistics' }
CFPhysicsWorldTelemetry >> stageRows [
	| latest averages |
	latest := self latest.
	averages := self averageStageDurations asDictionary.
	latest ifNil: [ ^ #() ].
	^ latest stageExecutions collect: [ :execution |
		| name duration |
		name := execution name asString.
		duration := execution durationMilliseconds ifNil: [ 0 ].
		name -> {
			self formattedMilliseconds: duration.
			self formattedMilliseconds: (averages at: name ifAbsent: [ 0 ]) } ]
]
