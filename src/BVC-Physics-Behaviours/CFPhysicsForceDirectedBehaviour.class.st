
"
I orchestrate a force-directed arrangement for a graph supplied by an adapter.

I reconcile distance joints and repulsion forces with the current graph and damp the selected elements while the arrangement settles.
"
Class {
	#name : 'CFPhysicsForceDirectedBehaviour',
	#superclass : 'CFPhysicsBehaviour',
	#instVars : [
		'adapter', 'springsByEdge', 'repulsionsByPair', 'centringForce',
		'length', 'hertz', 'dampingRatio',
		'repulsion', 'repulsionSofteningDistance', 'maximumRepulsionDistance', 'centringStrength', 'velocityDamping'
	],
	#category : 'BVC-Physics-Behaviours',
	#package : 'BVC-Physics-Behaviours'
}

{ #category : 'initialization' }
CFPhysicsForceDirectedBehaviour >> initialize [
	super initialize.
	springsByEdge := IdentityDictionary new.
	repulsionsByPair := Dictionary new.
	centringForce := nil.
	length := CFPhysicsSharedScalar value: 80.0.
	hertz := CFPhysicsSharedScalar value: 3.0.
	dampingRatio := CFPhysicsSharedScalar value: 1.0.
	repulsion := CFPhysicsSharedScalar value: 100000.0.
	repulsionSofteningDistance := CFPhysicsSharedScalar value: 50.0.
	maximumRepulsionDistance := CFPhysicsSharedScalar value: 200.0.
	centringStrength := CFPhysicsSharedScalar value: 4.0.
	velocityDamping := CFPhysicsSharedScalar value: 8.0
]

{ #category : 'configuration' }
CFPhysicsForceDirectedBehaviour >> adapter [ ^ adapter ]

{ #category : 'configuration' }
CFPhysicsForceDirectedBehaviour >> adapter: anAdapter [
	self isRunning ifTrue: [ self error: 'Stop a force-directed Behaviour before changing its adapter' ].
	adapter := anAdapter.
	^ self
]

{ #category : 'accessing' }
CFPhysicsForceDirectedBehaviour >> elements [
	adapter ifNil: [ self error: 'A force-directed Behaviour requires a graph adapter' ].
	^ adapter elementsFor: target
]

{ #category : 'accessing' }
CFPhysicsForceDirectedBehaviour >> edges [
	adapter ifNil: [ self error: 'A force-directed Behaviour requires a graph adapter' ].
	^ adapter edgesFor: target
]

{ #category : 'accessing' }
CFPhysicsForceDirectedBehaviour >> springsByEdge [ ^ springsByEdge copy ]

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
CFPhysicsForceDirectedBehaviour >> repulsionSofteningDistance: aNumber [ repulsionSofteningDistance value: (aNumber asFloat max: 0.0) ]
{ #category : 'configuration' }
CFPhysicsForceDirectedBehaviour >> maximumRepulsionDistance [ ^ maximumRepulsionDistance value ]
{ #category : 'configuration' }
CFPhysicsForceDirectedBehaviour >> maximumRepulsionDistance: aNumber [ maximumRepulsionDistance value: aNumber ]
{ #category : 'configuration' }
CFPhysicsForceDirectedBehaviour >> centringStrength [ ^ centringStrength value ]
{ #category : 'configuration' }
CFPhysicsForceDirectedBehaviour >> centringStrength: aNumber [ centringStrength value: (aNumber asFloat max: 0.0) ]
{ #category : 'configuration' }
CFPhysicsForceDirectedBehaviour >> velocityDamping [ ^ velocityDamping value ]
{ #category : 'configuration' }
CFPhysicsForceDirectedBehaviour >> velocityDamping: aNumber [ velocityDamping value: (aNumber asFloat max: 0.0) ]

{ #category : 'running' }
CFPhysicsForceDirectedBehaviour >> start [
	adapter ifNil: [ self error: 'A force-directed Behaviour requires a graph adapter' ].
	super start.
	[ self reconcile ] on: Error do: [ :error |
		super stop.
		self removeOwnedPhysics.
		error pass ].
	^ self
]

{ #category : 'running' }
CFPhysicsForceDirectedBehaviour >> stop [
	super stop.
	self removeOwnedPhysics.
	^ self
]

{ #category : 'stepping' }
CFPhysicsForceDirectedBehaviour >> step: aPhysicsStep [
	| currentElements |
	self reconcile.
	currentElements := self elements.
	self dampVelocitiesOf: currentElements over: aPhysicsStep timeStep
]

{ #category : 'private - reconciliation' }
CFPhysicsForceDirectedBehaviour >> reconcile [
	| currentElements currentEdges desiredPairs |
	currentElements := self elements.
	currentEdges := self edges.
	self validateElements: currentElements edges: currentEdges.
	self ensureCentringForceFor: currentElements.
	desiredPairs := self orderedPairsFor: currentElements.
	self removeObsoleteSpringsExcept: currentEdges asIdentitySet.
	self removeObsoleteRepulsionsExcept: desiredPairs asSet.
	currentEdges do: [ :edge | self ensureSpringFor: edge ].
	desiredPairs do: [ :pair | self ensureRepulsionFor: pair ]
]

{ #category : 'private - validation' }
CFPhysicsForceDirectedBehaviour >> validateElements: currentElements edges: currentEdges [
	| elementSet |
	elementSet := currentElements asIdentitySet.
	currentElements do: [ :element |
		(element physics world == self world) ifFalse: [
			self error: 'Force-directed elements must belong to the Behaviour target world' ] ].
	currentEdges do: [ :edge |
		((elementSet includes: (adapter sourceElementFor: edge)) and: [
			elementSet includes: (adapter destinationElementFor: edge) ]) ifFalse: [
				self error: 'Every force-directed edge endpoint must occur in the selected elements' ] ]
]

{ #category : 'private - reconciliation' }
CFPhysicsForceDirectedBehaviour >> orderedPairsFor: currentElements [
	| pairs |
	pairs := OrderedCollection new.
	1 to: currentElements size do: [ :firstIndex |
		firstIndex + 1 to: currentElements size do: [ :secondIndex |
			pairs add: (CFPhysicsNodePair
				first: (currentElements at: firstIndex)
				second: (currentElements at: secondIndex)) ] ].
	^ pairs
]

{ #category : 'private - reconciliation' }
CFPhysicsForceDirectedBehaviour >> removeObsoleteSpringsExcept: desiredEdges [
	(springsByEdge associations sorted: [ :first :second |
		first value sequence < second value sequence ]) do: [ :association |
		(desiredEdges includes: association key) ifFalse: [
			association value remove.
			springsByEdge removeKey: association key ] ]
]

{ #category : 'private - reconciliation' }
CFPhysicsForceDirectedBehaviour >> removeObsoleteRepulsionsExcept: desiredPairs [
	repulsionsByPair associations copy do: [ :association |
		(desiredPairs includes: association key) ifFalse: [
			association value remove.
			repulsionsByPair removeKey: association key ] ]
]

{ #category : 'private - reconciliation' }
CFPhysicsForceDirectedBehaviour >> ensureSpringFor: anEdge [
	| spring |
	spring := springsByEdge at: anEdge ifAbsentPut: [
		self world addJoint: (CFPhysicsDistanceJoint
			between: (adapter sourceElementFor: anEdge) physics body
			and: (adapter destinationElementFor: anEdge) physics body) ].
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
		| force |
		force := CFPhysicsRepulsionForce
			between: pair first physics body
			and: pair second physics body.
		force distanceResponse: (CFPhysicsSoftenedInverseSquareResponse new
			force: repulsion;
			softeningDistance: repulsionSofteningDistance;
			maximumDistance: maximumRepulsionDistance;
			yourself).
		self world addForce: force ]
]


{ #category : 'private - reconciliation' }
CFPhysicsForceDirectedBehaviour >> ensureCentringForceFor: currentElements [
	(centringForce isNil or: [ centringForce isActive not ]) ifTrue: [
		centringForce := self world addForce: CFPhysicsCentreForce new ].
	centringForce
		bodies: (currentElements collect: [ :element | element physics body ]);
		centre: self world owner extent / 2.0;
		strength: centringStrength value
]

{ #category : 'private - stepping' }
CFPhysicsForceDirectedBehaviour >> dampVelocitiesOf: currentElements over: aTimeStep [
	| factor |
	velocityDamping value isZero ifTrue: [ ^ self ].
	factor := 1.0 / (1.0 + (aTimeStep * velocityDamping value)).
	currentElements do: [ :element |
		element physics velocity: element physics velocity * factor ]
]

{ #category : 'private - running' }
CFPhysicsForceDirectedBehaviour >> removeOwnedPhysics [
	springsByEdge values copy do: #remove.
	repulsionsByPair values copy do: #remove.
	centringForce ifNotNil: [ centringForce remove ].
	centringForce := nil.
	springsByEdge removeAll.
	repulsionsByPair removeAll
]
