"
I maintain force-directed springs and repulsions for the current contents of a domain-neutral graph source.
"
Class {
	#name : 'CFPhysicsForceDirectedBehaviour',
	#superclass : 'CFPhysicsBehaviour',
	#instVars : [
		'graphSource', 'springsByEdge', 'repulsionsByPair',
		'restLength', 'stiffness', 'damping', 'maximumSpringForce',
		'repulsion', 'maximumRepulsionDistance'
	],
	#category : 'BVC-Foundation-Physics-Core-Behaviours',
	#package : 'BVC-Foundation-Physics-Core'
}

{ #category : 'initialization' }
CFPhysicsForceDirectedBehaviour >> initialize [
	super initialize.
	graphSource := CFPhysicsGraphSource new.
	springsByEdge := IdentityDictionary new.
	repulsionsByPair := Dictionary new.
	restLength := CFPhysicsSharedScalar value: 100.0.
	stiffness := CFPhysicsSharedScalar value: 40.0.
	damping := CFPhysicsSharedScalar value: 8.0.
	maximumSpringForce := CFPhysicsSharedScalar value: 100000.0.
	repulsion := CFPhysicsSharedScalar value: 1000.0.
	maximumRepulsionDistance := CFPhysicsSharedScalar value: 300.0
]

{ #category : 'accessing' }
CFPhysicsForceDirectedBehaviour >> graphSource [ ^ graphSource ]

{ #category : 'configuration' }
CFPhysicsForceDirectedBehaviour >> graphSource: aGraphSource [ graphSource := aGraphSource ]

{ #category : 'accessing' }
CFPhysicsForceDirectedBehaviour >> springsByEdge [ ^ springsByEdge copy ]

{ #category : 'accessing' }
CFPhysicsForceDirectedBehaviour >> repulsionsByPair [ ^ repulsionsByPair copy ]

{ #category : 'configuration' }
CFPhysicsForceDirectedBehaviour >> restLength [ ^ restLength value ]

{ #category : 'configuration' }
CFPhysicsForceDirectedBehaviour >> restLength: aNumber [ restLength value: aNumber ]

{ #category : 'configuration' }
CFPhysicsForceDirectedBehaviour >> stiffness [ ^ stiffness value ]

{ #category : 'configuration' }
CFPhysicsForceDirectedBehaviour >> stiffness: aNumber [ stiffness value: aNumber ]

{ #category : 'configuration' }
CFPhysicsForceDirectedBehaviour >> damping [ ^ damping value ]

{ #category : 'configuration' }
CFPhysicsForceDirectedBehaviour >> damping: aNumber [ damping value: aNumber ]

{ #category : 'configuration' }
CFPhysicsForceDirectedBehaviour >> maximumSpringForce [ ^ maximumSpringForce value ]

{ #category : 'configuration' }
CFPhysicsForceDirectedBehaviour >> maximumSpringForce: aNumber [ maximumSpringForce value: aNumber ]

{ #category : 'configuration' }
CFPhysicsForceDirectedBehaviour >> repulsion [ ^ repulsion value ]

{ #category : 'configuration' }
CFPhysicsForceDirectedBehaviour >> repulsion: aNumber [ repulsion value: aNumber ]

{ #category : 'configuration' }
CFPhysicsForceDirectedBehaviour >> maximumRepulsionDistance [ ^ maximumRepulsionDistance value ]

{ #category : 'configuration' }
CFPhysicsForceDirectedBehaviour >> maximumRepulsionDistance: aNumber [ maximumRepulsionDistance value: aNumber ]

{ #category : 'updating' }
CFPhysicsForceDirectedBehaviour >> updateForStep: aPhysicsStep [
	| nodes edges desiredEdges desiredPairs |
	nodes := graphSource nodes.
	edges := graphSource edges.
	self validateNodes: nodes edges: edges.
	desiredEdges := edges asIdentitySet.
	desiredPairs := self orderedPairsFor: nodes.
	self removeObsoleteSpringsExcept: desiredEdges.
	self removeObsoleteRepulsionsExcept: desiredPairs asSet.
	edges do: [ :edge | self ensureSpringFor: edge ].
	desiredPairs do: [ :pair | self ensureRepulsionFor: pair ]
]

{ #category : 'private - validation' }
CFPhysicsForceDirectedBehaviour >> validateNodes: nodes edges: edges [
	| nodeSet |
	nodeSet := nodes asIdentitySet.
	nodes do: [ :node |
		(node physics behaviourWorld == world) ifFalse: [
			self error: 'Force-directed nodes must belong to the Behaviour physics world' ] ].
	edges do: [ :edge |
		((nodeSet includes: (graphSource sourceForEdge: edge)) and: [
			nodeSet includes: (graphSource targetForEdge: edge) ]) ifFalse: [
			self error: 'Every force-directed edge endpoint must occur in the graph nodes' ] ]
]

{ #category : 'private - reconciliation' }
CFPhysicsForceDirectedBehaviour >> orderedPairsFor: nodes [
	| pairs |
	pairs := OrderedCollection new.
	1 to: nodes size do: [ :firstIndex |
		firstIndex + 1 to: nodes size do: [ :secondIndex |
			pairs add: (CFPhysicsNodePair
				first: (nodes at: firstIndex)
				second: (nodes at: secondIndex)) ] ].
	^ pairs
]

{ #category : 'private - reconciliation' }
CFPhysicsForceDirectedBehaviour >> removeObsoleteSpringsExcept: desiredEdges [
	(springsByEdge associations sorted: [ :first :second |
		first value sequence < second value sequence ]) do: [ :association |
		(desiredEdges includes: association key) ifFalse: [
			world removeSpringConstraint: association value.
			springsByEdge removeKey: association key ] ]
]

{ #category : 'private - reconciliation' }
CFPhysicsForceDirectedBehaviour >> removeObsoleteRepulsionsExcept: desiredPairs [
	(repulsionsByPair associations sorted: [ :first :second |
		first value sequence < second value sequence ]) do: [ :association |
		(desiredPairs includes: association key) ifFalse: [
			world removeRepulsionConstraint: association value.
			repulsionsByPair removeKey: association key ] ]
]

{ #category : 'private - reconciliation' }
CFPhysicsForceDirectedBehaviour >> ensureSpringFor: edge [
	^ springsByEdge at: edge ifAbsentPut: [
		| spring sourceBody targetBody |
		sourceBody := (graphSource sourceForEdge: edge) physics requireBodyState.
		targetBody := (graphSource targetForEdge: edge) physics requireBodyState.
		spring := CFPhysicsSpringConstraint between: sourceBody and: targetBody.
		spring
			restLength: restLength;
			stiffness: stiffness;
			damping: damping;
			maximumForce: maximumSpringForce.
		world addSpringConstraint: spring ]
]

{ #category : 'private - reconciliation' }
CFPhysicsForceDirectedBehaviour >> ensureRepulsionFor: pair [
	^ repulsionsByPair at: pair ifAbsentPut: [
		| constraint |
		constraint := CFPhysicsRepulsionConstraint
			between: pair first physics requireBodyState
			and: pair second physics requireBodyState.
		constraint
			force: repulsion;
			maximumDistance: maximumRepulsionDistance.
		world addRepulsionConstraint: constraint ]
]

{ #category : 'removing' }
CFPhysicsForceDirectedBehaviour >> removing [
	springsByEdge values copy do: [ :each | world removeSpringConstraint: each ].
	repulsionsByPair values copy do: [ :each | world removeRepulsionConstraint: each ].
	springsByEdge removeAll.
	repulsionsByPair removeAll
]
