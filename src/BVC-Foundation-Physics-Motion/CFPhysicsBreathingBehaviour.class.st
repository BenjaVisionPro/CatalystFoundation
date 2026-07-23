"
I coordinate a graph-shaped breathing motion through one force-directed Behaviour.

Intensity is the public semantic control. I derive the breath timing, amplitude and force character from it, calculate graph distance from an origin, and compose one repeating Motion timeline for each graph-distance cohort.

Each cohort owns ordinary CFMotionValues for spring rest length, spring stiffness and repulsion. All participating constraints at that graph distance share those values. Motion owns interpolation, easing, sequencing, repetition and phase. Physics constraints only consume #value.
"
Class {
	#name : 'CFPhysicsBreathingBehaviour',
	#superclass : 'CFPhysicsBehaviour',
	#instVars : [ 'forceDirected', 'origin', 'intensity', 'cohorts', 'springDistances', 'repulsionDistances' ],
	#category : 'BVC-Foundation-Physics-Motion-Behaviours',
	#package : 'BVC-Foundation-Physics-Motion'
}

{ #category : 'initialization' }
CFPhysicsBreathingBehaviour >> initialize [
	super initialize.
	intensity := 0.25.
	cohorts := Dictionary new.
	springDistances := IdentityDictionary new.
	repulsionDistances := IdentityDictionary new
]

{ #category : 'configuration' }
CFPhysicsBreathingBehaviour >> forceDirected [ ^ forceDirected ]

{ #category : 'configuration' }
CFPhysicsBreathingBehaviour >> forceDirected: aBehaviour [ forceDirected := aBehaviour ]

{ #category : 'configuration' }
CFPhysicsBreathingBehaviour >> origin [ ^ origin ]

{ #category : 'configuration' }
CFPhysicsBreathingBehaviour >> origin: anElement [
	origin := anElement.
	self rebuildMotions
]

{ #category : 'configuration' }
CFPhysicsBreathingBehaviour >> intensity [ ^ intensity ]

{ #category : 'configuration' }
CFPhysicsBreathingBehaviour >> intensity: aNumber [
	intensity := (aNumber asFloat min: 1.0) max: 0.0.
	self rebuildMotions
]

{ #category : 'updating' }
CFPhysicsBreathingBehaviour >> updateForStep: aPhysicsStep [
	| distances |
	self validateConfiguration.
	distances := self graphDistances.
	self reconcileSpringsUsing: distances.
	self reconcileRepulsionsUsing: distances.
	self removeUnusedCohorts.
	cohorts valuesDo: [ :each | each first advanceBy: world stepDuration ]
]

{ #category : 'private - validation' }
CFPhysicsBreathingBehaviour >> validateConfiguration [
	forceDirected ifNil: [ self error: 'Breathing needs a force-directed Behaviour' ].
	forceDirected world == world ifFalse: [ self error: 'Breathing and force-directed Behaviours must belong to the same Physics world' ].
	origin ifNil: [
		| nodes |
		nodes := forceDirected graphSource nodes.
		nodes ifNotEmpty: [ origin := nodes first ] ].
	origin ifNil: [ self error: 'Breathing needs an origin node' ]
]

{ #category : 'private - topology' }
CFPhysicsBreathingBehaviour >> graphDistances [
	| source nodes edges distances frontier nextFrontier distance |
	source := forceDirected graphSource.
	nodes := source nodes.
	edges := source edges.
	(nodes identityIncludes: origin) ifFalse: [ self error: 'The breathing origin must be one of the graph nodes' ].
	distances := IdentityDictionary new.
	distances at: origin put: 0.
	frontier := { origin }.
	distance := 0.
	[ frontier isNotEmpty ] whileTrue: [
		nextFrontier := OrderedCollection new.
		frontier do: [ :node |
			edges do: [ :edge |
				| neighbour sourceNode targetNode |
				sourceNode := source sourceForEdge: edge.
				targetNode := source targetForEdge: edge.
				neighbour := sourceNode == node
					ifTrue: [ targetNode ]
					ifFalse: [ targetNode == node ifTrue: [ sourceNode ] ifFalse: [ nil ] ].
				(neighbour notNil and: [ (distances includesKey: neighbour) not ]) ifTrue: [
					distances at: neighbour put: distance + 1.
					nextFrontier add: neighbour ] ] ].
		distance := distance + 1.
		frontier := nextFrontier ].
	^ distances
]

{ #category : 'private - reconciliation' }
CFPhysicsBreathingBehaviour >> reconcileSpringsUsing: distances [
	| desired source |
	desired := forceDirected springsByEdge.
	source := forceDirected graphSource.
	(springDistances keys reject: [ :constraint | desired values identityIncludes: constraint ]) do: [ :constraint |
		springDistances removeKey: constraint ].
	desired keysAndValuesDo: [ :edge :spring |
		| edgeDistance cohort |
		edgeDistance := ((distances at: (source sourceForEdge: edge) ifAbsent: [ 0 ])
			max: (distances at: (source targetForEdge: edge) ifAbsent: [ 0 ])).
		cohort := self cohortAtDistance: edgeDistance.
		spring
			restLength: cohort second;
			stiffness: cohort third.
		springDistances at: spring put: edgeDistance ]
]

{ #category : 'private - reconciliation' }
CFPhysicsBreathingBehaviour >> reconcileRepulsionsUsing: distances [
	| desired |
	desired := forceDirected repulsionsByPair.
	(repulsionDistances keys reject: [ :constraint | desired values identityIncludes: constraint ]) do: [ :constraint |
		repulsionDistances removeKey: constraint ].
	desired keysAndValuesDo: [ :pair :constraint |
		| pairDistance cohort |
		pairDistance := (distances at: pair first ifAbsent: [ 0 ]) min:
			(distances at: pair second ifAbsent: [ 0 ]).
		cohort := self cohortAtDistance: pairDistance.
		constraint force: cohort fourth.
		repulsionDistances at: constraint put: pairDistance ]
]

{ #category : 'private - cohorts' }
CFPhysicsBreathingBehaviour >> cohortAtDistance: distance [
	^ cohorts at: distance ifAbsentPut: [ self newCohortAtDistance: distance ]
]

{ #category : 'private - cohorts' }
CFPhysicsBreathingBehaviour >> newCohortAtDistance: distance [
	| timeline restValue stiffnessValue repulsionValue restBase stiffnessBase repulsionBase falloff phaseOffset |
	restBase := forceDirected restLength.
	stiffnessBase := forceDirected stiffness.
	repulsionBase := forceDirected repulsion.
	falloff := 1.0 / (1.0 + (distance * 0.08)).
	restValue := CFMotionValue value: restBase.
	stiffnessValue := CFMotionValue value: stiffnessBase.
	repulsionValue := CFMotionValue value: repulsionBase.
	timeline := CFMotionTimeline new.
	self
		addBreathOf: restValue
		around: restBase
		amplitude: restBase * (0.025 + (0.16 * intensity)) * falloff
		to: timeline.
	self
		addBreathOf: stiffnessValue
		around: stiffnessBase
		amplitude: stiffnessBase * (0.04 + (0.28 * intensity)) * falloff
		to: timeline.
	self
		addBreathOf: repulsionValue
		around: repulsionBase
		amplitude: repulsionBase * (0.03 + (0.24 * intensity)) * falloff
		to: timeline.
	timeline repeat; prepareForPlayback.
	phaseOffset := (distance * (0.11 - (0.05 * intensity))) seconds.
	phaseOffset isZero ifFalse: [
		| cycle phase |
		cycle := timeline duration.
		phase := phaseOffset asMilliSeconds \\ cycle asMilliSeconds.
		timeline seekTo: ((cycle asMilliSeconds - phase) \\ cycle asMilliSeconds) milliSeconds ].
	^ { timeline. restValue. stiffnessValue. repulsionValue }
]

{ #category : 'private - motion building' }
CFPhysicsBreathingBehaviour >> addBreathOf: aMotionValue around: base amplitude: amplitude to: aTimeline [
	| inhaleDuration exhaleDuration recoveryDuration inhaleValue exhaleValue inhaleEasing exhaleEasing inhale exhale recovery |
	inhaleDuration := (0.9 - (0.45 * intensity)) seconds.
	exhaleDuration := (1.35 - (0.70 * intensity)) seconds.
	recoveryDuration := ((0.35 * (1.0 - intensity)) seconds) max: 1 milliSecond.
	inhaleValue := base - amplitude.
	exhaleValue := base + (amplitude * (0.65 + (0.35 * intensity))).
	inhaleEasing := BlDecelerateInterpolator factor: 1.0 + (intensity * 1.4).
	exhaleEasing := BlDecelerateInterpolator factor: 2.2 - (intensity * 1.2).
	inhale := CFMotionTimelineTrack
		on: (aMotionValue transitionFrom: base to: inhaleValue)
		in: aTimeline.
	inhale duration: inhaleDuration; easing: inhaleEasing.
	exhale := CFMotionTimelineTrack
		on: (aMotionValue transitionFrom: inhaleValue to: exhaleValue)
		in: aTimeline.
	exhale startsAt: inhale end; duration: exhaleDuration; easing: exhaleEasing.
	recovery := CFMotionTimelineTrack
		on: (aMotionValue transitionFrom: exhaleValue to: base)
		in: aTimeline.
	recovery startsAt: exhale end; duration: recoveryDuration; easing: exhaleEasing
]

{ #category : 'private - cohorts' }
CFPhysicsBreathingBehaviour >> removeUnusedCohorts [
	| usedDistances |
	usedDistances := Set new.
	usedDistances addAll: springDistances values.
	usedDistances addAll: repulsionDistances values.
	(cohorts keys reject: [ :distance | usedDistances includes: distance ]) do: [ :distance |
		cohorts removeKey: distance ]
]

{ #category : 'private - rebuilding' }
CFPhysicsBreathingBehaviour >> rebuildMotions [
	cohorts removeAll.
	springDistances removeAll.
	repulsionDistances removeAll
]

{ #category : 'removing' }
CFPhysicsBreathingBehaviour >> removing [
	springDistances keysDo: [ :spring |
		spring restLength: forceDirected restLength; stiffness: forceDirected stiffness ].
	repulsionDistances keysDo: [ :constraint |
		constraint force: forceDirected repulsion ].
	self rebuildMotions
]
