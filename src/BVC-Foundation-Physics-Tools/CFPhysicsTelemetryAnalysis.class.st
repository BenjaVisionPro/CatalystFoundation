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
	| recordings |
	recordings := self stepRecordings.
	recordings ifEmpty: [ ^ nil ].
	^ self
		statisticsForPings: (recordings collect: #ping)
		rootPings: (recordings collect: #ping)
		depth: 0
]

{ #category : 'private - aggregation' }
CFPhysicsTelemetryAnalysis >> statisticsForPings: pings rootPings: roots depth: aDepth [
	| template node starts ends durations children |
	template := pings first.
	starts := pings with: roots collect: [ :ping :root | ping startTime - root startTime ].
	ends := pings with: roots collect: [ :ping :root | ping endTime - root startTime ].
	durations := pings collect: [ :ping | ping endTime - ping startTime ].
	node := CFPhysicsTelemetrySpanStatistics new
		name: template name;
		depth: aDepth;
		averageStart: (self averageOf: starts);
		averageEnd: (self averageOf: ends);
		averageDuration: (self averageOf: durations);
		p05Start: (self percentile: 0.05 of: starts);
		p25Start: (self percentile: 0.25 of: starts);
		p75End: (self percentile: 0.75 of: ends);
		p95Start: (self percentile: 0.95 of: starts);
		p95End: (self percentile: 0.95 of: ends);
		p95Duration: (self percentile: 0.95 of: durations);
		yourself.
	children := OrderedCollection new.
	template tasks do: [ :templateChild |
		| matching matchingRoots |
		matching := OrderedCollection new.
		matchingRoots := OrderedCollection new.
		1 to: pings size do: [ :sampleIndex |
			| ping matchedChild |
			ping := pings at: sampleIndex.
			matchedChild := ping tasks
				detect: [ :candidate | candidate name = templateChild name ]
				ifNone: [ nil ].
			matchedChild ifNotNil: [
				matching add: matchedChild.
				matchingRoots add: (roots at: sampleIndex) ] ].
		matching ifNotEmpty: [
			children add: (self
				statisticsForPings: matching
				rootPings: matchingRoots
				depth: aDepth + 1) ] ].
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

{ #category : 'private - statistics' }
CFPhysicsTelemetryAnalysis >> p95Of: numbers [
	^ self percentile: 0.95 of: numbers
]
