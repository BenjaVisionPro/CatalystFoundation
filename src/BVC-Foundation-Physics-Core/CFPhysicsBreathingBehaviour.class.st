"
I coordinate a graph-shaped breathing motion through one force-directed Behaviour.

Intensity is the public semantic control. I derive the breath timing, amplitude and force character from it, calculate graph distance from an origin, and distribute phase-shifted Motion value sequences to the participating spring and repulsion constraints.

Motion owns interpolation and temporal composition. Shared scalars remain plain value holders. Physics constraints only consume #value.
"
Class {
	#name : 'CFPhysicsBreathingBehaviour',
	#superclass : 'CFPhysicsBehaviour',
	#instVars : [ 'forceDirected', 'origin', 'intensity', 'springMotions', 'repulsionMotions' ],
	#category : 'BVC-Foundation-Physics-Core-Behaviours',
	#package : 'BVC-Foundation-Physics-Core'
}

{ #category : 'initialization' }
CFPhysicsBreathingBehaviour >> initialize [
	super initialize.
	intensity := 0.25.
	springMotions := IdentityDictionary new.
	repulsionMotions := IdentityDictionary new
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
	self reconcileSpringMotionsUsing: distances.
	self reconcileRepulsionMotionsUsing: distances.
	springMotions valuesDo: [ :motions | motions do: [ :each | each applyAt: aPhysicsStep simulationTime seconds ] ].
	repulsionMotions valuesDo: [ :motions | motions do: [ :each | each applyAt: aPhysicsStep simulationTime seconds ] ]
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
CFPhysicsBreathingBehaviour >> reconcileSpringMotionsUsing: distances [
	| desired source |
	desired := forceDirected springsByEdge.
	source := forceDirected graphSource.
	(springMotions keys reject: [ :constraint | desired values identityIncludes: constraint ]) do: [ :constraint |
		springMotions removeKey: constraint ].
	desired keysAndValuesDo: [ :edge :spring |
		| edgeDistance |
		edgeDistance := ((distances at: (source sourceForEdge: edge) ifAbsent: [ 0 ])
			max: (distances at: (source targetForEdge: edge) ifAbsent: [ 0 ])).
		springMotions at: spring ifAbsentPut: [ self newSpringMotionsFor: spring distance: edgeDistance ] ]
]

{ #category : 'private - reconciliation' }
CFPhysicsBreathingBehaviour >> reconcileRepulsionMotionsUsing: distances [
	| desired |
	desired := forceDirected repulsionsByPair.
	(repulsionMotions keys reject: [ :constraint | desired values identityIncludes: constraint ]) do: [ :constraint |
		repulsionMotions removeKey: constraint ].
	desired keysAndValuesDo: [ :pair :constraint |
		| pairDistance |
		pairDistance := (distances at: pair first ifAbsent: [ 0 ]) min:
			(distances at: pair second ifAbsent: [ 0 ]).
		repulsionMotions at: constraint ifAbsentPut: [ self newRepulsionMotionsFor: constraint distance: pairDistance ] ]
]

{ #category : 'private - motion building' }
CFPhysicsBreathingBehaviour >> newSpringMotionsFor: aSpring distance: distance [
	| restScalar stiffnessScalar restBase stiffnessBase amplitude forceAmplitude |
	restBase := forceDirected restLength.
	stiffnessBase := forceDirected stiffness.
	amplitude := (restBase * (0.025 + (0.16 * intensity))) * (1.0 / (1.0 + (distance * 0.08))).
	forceAmplitude := stiffnessBase * (0.04 + (0.28 * intensity)).
	restScalar := CFPhysicsSharedScalar value: restBase.
	stiffnessScalar := CFPhysicsSharedScalar value: stiffnessBase.
	aSpring restLength: restScalar; stiffness: stiffnessScalar.
	^ {
		self motionOn: restScalar around: restBase amplitude: amplitude distance: distance.
		self motionOn: stiffnessScalar around: stiffnessBase amplitude: forceAmplitude distance: distance }
]

{ #category : 'private - motion building' }
CFPhysicsBreathingBehaviour >> newRepulsionMotionsFor: aConstraint distance: distance [
	| scalar base amplitude |
	base := forceDirected repulsion.
	amplitude := base * (0.03 + (0.24 * intensity)) * (1.0 / (1.0 + (distance * 0.08))).
	scalar := CFPhysicsSharedScalar value: base.
	aConstraint force: scalar.
	^ { self motionOn: scalar around: base amplitude: amplitude distance: distance }
]

{ #category : 'private - motion building' }
CFPhysicsBreathingBehaviour >> motionOn: aScalar around: base amplitude: amplitude distance: distance [
	| inhaleDuration exhaleDuration pauseDuration phaseDelay inhaleValue exhaleValue inhaleEasing exhaleEasing |
	inhaleDuration := ((0.9 - (0.45 * intensity)) seconds).
	exhaleDuration := ((1.35 - (0.70 * intensity)) seconds).
	pauseDuration := ((0.35 * (1.0 - intensity)) seconds) max: 1 milliSecond.
	phaseDelay := (distance * (0.11 - (0.05 * intensity))) seconds.
	inhaleValue := base - amplitude.
	exhaleValue := base + (amplitude * (0.65 + (0.35 * intensity))).
	inhaleEasing := BlDecelerateInterpolator factor: 1.0 + (intensity * 1.4).
	exhaleEasing := BlDecelerateInterpolator factor: 2.2 - (intensity * 1.2).
	^ (CFMotionValueMotion on: aScalar)
		from: base;
		to: inhaleValue over: inhaleDuration easing: inhaleEasing;
		to: exhaleValue over: exhaleDuration easing: exhaleEasing;
		to: base over: pauseDuration easing: exhaleEasing;
		phaseOffset: phaseDelay;
		repeat
]

{ #category : 'private - rebuilding' }
CFPhysicsBreathingBehaviour >> rebuildMotions [
	springMotions removeAll.
	repulsionMotions removeAll
]

{ #category : 'removing' }
CFPhysicsBreathingBehaviour >> removing [
	springMotions keysAndValuesDo: [ :spring :motions |
		spring restLength: forceDirected restLength; stiffness: forceDirected stiffness ].
	repulsionMotions keysAndValuesDo: [ :constraint :motions |
		constraint force: forceDirected repulsion ].
	self rebuildMotions
]
