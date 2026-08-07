"
I orchestrate a force-directed arrangement of participating bodies.

My responsibility is to reconcile springs and repulsions from the current connections and damp the participating bodies as the arrangement settles.
"
Class {
	#name : 'CFPhysicsForceDirectedBehaviour',
	#superclass : 'CFPhysicsBehaviour',
	#instVars : [
		'nodes', 'connections', 'springsByConnection', 'repulsionsByPair',
		'length', 'hertz', 'dampingRatio',
		'repulsion', 'repulsionSofteningDistance', 'maximumRepulsionDistance', 'velocityDamping'
	],
	#category : 'BVC-Physics-Behaviours',
	#package : 'BVC-Physics-Behaviours'
}

{ #category : 'initialization' }
CFPhysicsForceDirectedBehaviour >> initialize [
	super initialize.
	springsByConnection := Dictionary new.
	repulsionsByPair := Dictionary new.
	length := CFPhysicsSharedScalar value: 80.0.
	hertz := CFPhysicsSharedScalar value: 3.0.
	dampingRatio := CFPhysicsSharedScalar value: 1.0.
	repulsion := CFPhysicsSharedScalar value: 100000.0.
	repulsionSofteningDistance := CFPhysicsSharedScalar value: 50.0.
	maximumRepulsionDistance := CFPhysicsSharedScalar value: 200.0.
	velocityDamping := CFPhysicsSharedScalar value: 8.0
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
CFPhysicsForceDirectedBehaviour >> length [ ^ length value ]

{ #category : 'configuration' }
CFPhysicsForceDirectedBehaviour >> length: aNumber [ length value: aNumber ]

{ #category : 'configuration' }
CFPhysicsForceDirectedBehaviour >> hertz [ ^ hertz value ]

{ #category : 'configuration' }
CFPhysicsForceDirectedBehaviour >> hertz: aNumber [ hertz value: (aNumber asFloat max: 0.0) ]

{ #category : 'configuration' }
CFPhysicsForceDirectedBehaviour >> dampingRatio [ ^ dampingRatio value ]

{ #category : 'configuration' }
CFPhysicsForceDirectedBehaviour >> dampingRatio: aNumber [ dampingRatio value: (aNumber asFloat max: 0.0) ]


{ #category : 'configuration' }
CFPhysicsForceDirectedBehaviour >> repulsion [ ^ repulsion value ]

{ #category : 'configuration' }
CFPhysicsForceDirectedBehaviour >> repulsion: aNumber [ repulsion value: aNumber ]

{ #category : 'configuration' }
CFPhysicsForceDirectedBehaviour >> repulsionSofteningDistance [ ^ repulsionSofteningDistance value ]

{ #category : 'configuration' }
CFPhysicsForceDirectedBehaviour >> repulsionSofteningDistance: aNumber [
	repulsionSofteningDistance value: (aNumber asFloat max: 0.0)
]

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
		(node physics world == world) ifFalse: [
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
			association value remove.
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
	| spring |
	spring := springsByConnection at: aConnection ifAbsentPut: [
		world addJoint: (CFPhysicsDistanceJoint
			between: aConnection key physics body
			and: aConnection value physics body) ].
	spring
		length: length value;
		springEnabled: true;
		hertz: hertz value;
		dampingRatio: dampingRatio value.
	^ spring
]

{ #category : 'private - reconciliation' }
CFPhysicsForceDirectedBehaviour >> ensureRepulsionFor: pair [
	^ repulsionsByPair at: pair ifAbsentPut: [
		| constraint |
		constraint := CFPhysicsRepulsionConstraint
			between: pair first physics body
			and: pair second physics body.
		constraint distanceResponse: (CFPhysicsSoftenedInverseSquareResponse new
			force: repulsion;
			softeningDistance: repulsionSofteningDistance;
			maximumDistance: maximumRepulsionDistance;
			yourself).
		world addRepulsionConstraint: constraint ]
]

{ #category : 'removing' }
CFPhysicsForceDirectedBehaviour >> removing [
	springsByConnection values copy do: [ :each | each remove ].
	repulsionsByPair values copy do: [ :each | world removeRepulsionConstraint: each ].
	springsByConnection removeAll.
	repulsionsByPair removeAll
]
