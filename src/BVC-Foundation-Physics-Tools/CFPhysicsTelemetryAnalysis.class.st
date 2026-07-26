"I analyse the bounded Pharo Telemetry recordings of one Physics world. I retain no measurements and do not manufacture TelemetrySignal or TelemetryPing instances."
Class {
	#name : 'CFPhysicsTelemetryAnalysis',
	#superclass : 'Object',
	#instVars : [ 'world' ],
	#category : 'BVC-Foundation-Physics-Tools',
	#package : 'BVC-Foundation-Physics-Tools'
}

{ #category : 'instance creation' }
CFPhysicsTelemetryAnalysis class >> world: aWorld [
	^ self new world: aWorld; yourself
]

{ #category : 'accessing' }
CFPhysicsTelemetryAnalysis >> world: aWorld [ world := aWorld ]

{ #category : 'accessing' }
CFPhysicsTelemetryAnalysis >> stepRecordings [
	^ world telemetryRecordings select: [ :signal |
		| data |
		data := signal physicsData.
		data notNil and: [ (data at: #kind ifAbsent: [ nil ]) = #step ] ]
]

{ #category : 'accessing' }
CFPhysicsTelemetryAnalysis >> sampleCount [ ^ self stepRecordings size ]

{ #category : 'accessing' }
CFPhysicsTelemetryAnalysis >> rootStatistics [
	| recordings samples |
	recordings := self stepRecordings.
	recordings ifEmpty: [ ^ nil ].
	samples := OrderedCollection new.
	recordings withIndexDo: [ :signal :index |
		samples add: (CFPhysicsTelemetrySpanSample
			signal: signal
			ping: signal ping
			parent: signal ping
			sequence: index) ].
	^ self statisticsForSamples: samples depth: 0
]

{ #category : 'private - aggregation' }
CFPhysicsTelemetryAnalysis >> statisticsForSamples: samples depth: aDepth [
	| template node starts ends durations children averageStart averageEnd |
	template := samples first ping.
	starts := samples collect: #start.
	ends := samples collect: #end.
	durations := samples collect: #duration.
	averageStart := self averageOf: starts.
	averageEnd := self averageOf: ends.
	node := CFPhysicsTelemetrySpanStatistics new
		name: template name;
		depth: aDepth;
		averageStart: averageStart;
		averageEnd: averageEnd;
		averageDuration: (self averageOf: durations);
		p05Start: (self percentile: 0.05 of: starts);
		p25Start: (self percentile: 0.25 of: starts);
		medianStart: (self percentile: 0.50 of: starts);
		medianEnd: (self percentile: 0.50 of: ends);
		p75End: (self percentile: 0.75 of: ends);
		p95Start: (self percentile: 0.95 of: starts);
		p95End: (self percentile: 0.95 of: ends);
		p95Duration: (self percentile: 0.95 of: durations);
		samples: samples asArray;
		yourself.
	children := OrderedCollection new.
	template tasks do: [ :templateChild |
		| matching |
		matching := OrderedCollection new.
		samples do: [ :sample |
			| matchedChild |
			matchedChild := sample ping tasks
				detect: [ :candidate | candidate name = templateChild name ]
				ifNone: [ nil ].
			matchedChild ifNotNil: [
				matching add: (CFPhysicsTelemetrySpanSample
					signal: sample signal
					ping: matchedChild
					parent: sample ping
					sequence: sample sequence) ] ].
		matching ifNotEmpty: [
			children add: (self statisticsForSamples: matching depth: aDepth + 1) ] ].
	node children: children.
	^ node
]

{ #category : 'private - statistics' }
CFPhysicsTelemetryAnalysis >> averageOf: numbers [
	^ numbers ifEmpty: [ 0 ] ifNotEmpty: [ numbers average ]
]

{ #category : 'private - statistics' }
CFPhysicsTelemetryAnalysis >> percentile: aFraction of: numbers [
	| sorted rank |
	numbers ifEmpty: [ ^ 0 ].
	sorted := numbers sorted.
	rank := ((sorted size * aFraction) ceiling max: 1) min: sorted size.
	^ sorted at: rank
]
