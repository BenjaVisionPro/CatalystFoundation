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
	^ self statisticsForPings: (recordings collect: #ping) rootPings: (recordings collect: #ping) depth: 0
]

{ #category : 'private - aggregation' }
CFPhysicsTelemetryAnalysis >> statisticsForPings: pings rootPings: roots depth: aDepth [
	| template node children |
	template := pings first.
	node := CFPhysicsTelemetrySpanStatistics new
		name: template name;
		depth: aDepth;
		averageStart: (self averageOf: (pings with: roots collect: [ :ping :root | ping startTime - root startTime ]));
		averageDuration: (self averageOf: (pings collect: [ :ping | ping endTime - ping startTime ]));
		p95Start: (self p95Of: (pings with: roots collect: [ :ping :root | ping startTime - root startTime ]));
		p95Duration: (self p95Of: (pings collect: [ :ping | ping endTime - ping startTime ]));
		yourself.
	children := OrderedCollection new.
	1 to: template tasks size do: [ :index |
		| matching matchingRoots |
		matching := OrderedCollection new.
		matchingRoots := OrderedCollection new.
		1 to: pings size do: [ :sampleIndex |
			| ping |
			ping := pings at: sampleIndex.
			ping tasks size >= index ifTrue: [
				matching add: (ping tasks at: index).
				matchingRoots add: (roots at: sampleIndex) ] ].
		matching ifNotEmpty: [
			children add: (self statisticsForPings: matching rootPings: matchingRoots depth: aDepth + 1) ] ].
	node children: children.
	^ node
]

{ #category : 'private - statistics' }
CFPhysicsTelemetryAnalysis >> averageOf: numbers [
	^ numbers ifEmpty: [ 0 ] ifNotEmpty: [ numbers average ]
]

{ #category : 'private - statistics' }
CFPhysicsTelemetryAnalysis >> p95Of: numbers [
	| sorted rank |
	numbers ifEmpty: [ ^ 0 ].
	sorted := numbers sorted.
	rank := ((sorted size * 0.95) ceiling max: 1) min: sorted size.
	^ sorted at: rank
]
