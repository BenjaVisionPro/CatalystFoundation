"
I maintain force-directed springs and repulsions between ordinary Physics bodies.

My participants and connections may be fixed collections or providers, so I can be used by any Physics world whose bodies have relationships. A connection is an Association from one participating element to another; I do not know about graphs or graph adapters.

I apply velocity damping to my selected nodes on each step. This lets disconnected components settle after repulsion has separated them without changing the Physics configuration of bodies outside this behaviour.
"
Class {
	#name : 'CFPhysicsForceDirectedBehaviour',
	#superclass : 'CFPhysicsBehaviour',
	#instVars : [
		'nodes', 'connections', 'springsByConnection', 'repulsionsByPair',
		'restLength', 'stiffness', 'damping', 'maximumSpringForce',
		'repulsion', 'maximumRepulsionDistance', 'velocityDamping'
	],
	#category : 'BVC-Foundation-Physics-Core-Behaviours',
	#package : 'BVC-Foundation-Physics-Core'
}

{ #category : 'initialization' }
CFPhysicsForceDirectedBehaviour >> initialize [
	super initialize.
	springsByConnection := Dictionary new.
	repulsionsByPair := Dictionary new.
	restLength := CFPhysicsSharedScalar value: 120.0.
	stiffness := CFPhysicsSharedScalar value: 10000.0.
	damping := CFPhysicsSharedScalar value: 4000.0.
	maximumSpringForce := CFPhysicsSharedScalar value: 500000.0.
	repulsion := CFPhysicsSharedScalar value: 8000.0.
	maximumRepulsionDistance := CFPhysicsSharedScalar value: 300.0.
	velocityDamping := CFPhysicsSharedScalar value: 12.0
]

{ #category : 'configuration' }
CFPhysicsForceDirectedBehaviour >> nodes: aCollectionOrProvider [
	nodes := aCollectionOrProvider.
	^ self
]

{ #category : 'accessing' }
CFPhysicsForceDirectedBehaviour >> nodes [
	^ self resolvedParticipantsFrom: nodes default: [ world members ]
]

{ #category : 'configuration' }
CFPhysicsForceDirectedBehaviour >> connections: aCollectionOrProvider [
	connections := aCollectionOrProvider.
	^ self
]

{ #category : 'accessing' }
CFPhysicsForceDirectedBehaviour >> connections [
	^ self resolvedParticipantsFrom: connections default: [ #() ]
]

{ #category : 'accessing' }
CFPhysicsForceDirectedBehaviour >> springsByConnection [ ^ springsByConnection copy ]

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

{ #category : 'configuration' }
CFPhysicsForceDirectedBehaviour >> velocityDamping [ ^ velocityDamping value ]

{ #category : 'configuration' }
CFPhysicsForceDirectedBehaviour >> velocityDamping: aNumber [
	velocityDamping value: (aNumber asFloat max: 0.0)
]

{ #category : 'updating' }
CFPhysicsForceDirectedBehaviour >> updateForStep: aPhysicsStep [
	| currentNodes currentConnections desiredConnections desiredPairs |
	currentNodes := self nodes.
	currentConnections := self connections.
	self validateNodes: currentNodes connections: currentConnections.
	desiredConnections := currentConnections asSet.
	desiredPairs := self orderedPairsFor: currentNodes.
	self removeObsoleteSpringsExcept: desiredConnections.
	self removeObsoleteRepulsionsExcept: desiredPairs asSet.
	currentConnections do: [ :each | self ensureSpringFor: each ].
	desiredPairs do: [ :each | self ensureRepulsionFor: each ].
	self dampVelocitiesOf: currentNodes over: aPhysicsStep timeStep
]

{ #category : 'private - updating' }
CFPhysicsForceDirectedBehaviour >> dampVelocitiesOf: currentNodes over: aTimeStep [
	| factor |
	velocityDamping value isZero ifTrue: [ ^ self ].
	factor := 1.0 / (1.0 + (aTimeStep * velocityDamping value)).
	currentNodes do: [ :each |
		each physics velocity: each physics velocity * factor ]
]

{ #category : 'private - validation' }
CFPhysicsForceDirectedBehaviour >> validateNodes: currentNodes connections: currentConnections [
	| nodeSet |
	nodeSet := currentNodes asIdentitySet.
	currentNodes do: [ :node |
		(node physics behaviourWorld == world) ifFalse: [
			self error: 'Force-directed nodes must belong to the Behaviour physics world' ] ].
	currentConnections do: [ :connection |
		((nodeSet includes: connection key) and: [ nodeSet includes: connection value ]) ifFalse: [
			self error: 'Every force-directed connection endpoint must occur in the selected nodes' ] ]
]

{ #category : 'private - reconciliation' }
CFPhysicsForceDirectedBehaviour >> orderedPairsFor: currentNodes [
	| pairs |
	pairs := OrderedCollection new.
	1 to: currentNodes size do: [ :firstIndex |
		firstIndex + 1 to: currentNodes size do: [ :secondIndex |
			pairs add: (CFPhysicsNodePair
				first: (currentNodes at: firstIndex)
				second: (currentNodes at: secondIndex)) ] ].
	^ pairs
]

{ #category : 'private - reconciliation' }
CFPhysicsForceDirectedBehaviour >> removeObsoleteSpringsExcept: desiredConnections [
	(springsByConnection associations sorted: [ :first :second |
		first value sequence < second value sequence ]) do: [ :association |
		(desiredConnections includes: association key) ifFalse: [
			world removeSpringConstraint: association value.
			springsByConnection removeKey: association key ] ]
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
CFPhysicsForceDirectedBehaviour >> ensureSpringFor: aConnection [
	^ springsByConnection at: aConnection ifAbsentPut: [
		| spring sourceBody targetBody |
		sourceBody := aConnection key physics requireBodyState.
		targetBody := aConnection value physics requireBodyState.
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
	springsByConnection values copy do: [ :each | world removeSpringConstraint: each ].
	repulsionsByPair values copy do: [ :each | world removeRepulsionConstraint: each ].
	springsByConnection removeAll.
	repulsionsByPair removeAll
]
