"
I orchestrate a force-directed arrangement for a graph supplied by an adapter.

I reconcile edge distance joints and configure the persistent forces that repel and centre the selected graph elements.
"
Class {
	#name : 'CFPhysicsForceDirectedBehaviour',
	#superclass : 'CFPhysicsBehaviour',
	#instVars : [
		'adapter', 'springsByEdge', 'orientationForcesByElement', 'repulsionForce', 'positioningForce',
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
	orientationForcesByElement := IdentityDictionary new.
	repulsionForce := nil.
	positioningForce := nil.
	length := CFPhysicsSharedScalar value: 90.0.
	hertz := CFPhysicsSharedScalar value: 0.65.
	dampingRatio := CFPhysicsSharedScalar value: 1.0.
	repulsion := CFPhysicsSharedScalar value: 450000.0.
	repulsionSofteningDistance := CFPhysicsSharedScalar value: 60.0.
	maximumRepulsionDistance := CFPhysicsSharedScalar value: 500.0.
	centringStrength := CFPhysicsSharedScalar value: 8.0.
	velocityDamping := CFPhysicsSharedScalar value: 4.0
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
CFPhysicsForceDirectedBehaviour >> repulsionForce [ ^ repulsionForce ]

{ #category : 'accessing' }
CFPhysicsForceDirectedBehaviour >> positioningForce [ ^ positioningForce ]

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
	| currentElements currentEdges currentBodies |
	currentElements := self elements.
	currentEdges := self edges.
	self validateElements: currentElements edges: currentEdges.
	currentBodies := currentElements collect: [ :element | element physics body ].
	self ensureRepulsionForceFor: currentBodies.
	self ensurePositioningForceFor: currentBodies.
	self reconcileOrientationForcesFor: currentElements.
	self removeObsoleteSpringsExcept: currentEdges asIdentitySet.
	currentEdges do: [ :edge | self ensureSpringFor: edge ]
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
CFPhysicsForceDirectedBehaviour >> removeObsoleteSpringsExcept: desiredEdges [
	(springsByEdge associations sorted: [ :first :second |
		first value sequence < second value sequence ]) do: [ :association |
		(desiredEdges includes: association key) ifFalse: [
			association value remove.
			springsByEdge removeKey: association key ] ]
]


{ #category : 'private - reconciliation' }
CFPhysicsForceDirectedBehaviour >> reconcileOrientationForcesFor: currentElements [
	| desiredElements |
	desiredElements := currentElements asIdentitySet.
	orientationForcesByElement associations copy do: [ :association |
		(desiredElements includes: association key) ifFalse: [
			association value remove.
			orientationForcesByElement removeKey: association key ] ].
	currentElements do: [ :element |
		| force |
		force := orientationForcesByElement at: element ifAbsent: [ nil ].
		(force isNil or: [ force isActive not ]) ifTrue: [
			force := element physics restoreOrientation.
			orientationForcesByElement at: element put: force ] ]
]

{ #category : 'accessing' }
CFPhysicsForceDirectedBehaviour >> orientationForcesByElement [
	^ orientationForcesByElement copy
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
CFPhysicsForceDirectedBehaviour >> ensureRepulsionForceFor: currentBodies [
	(repulsionForce isNil or: [ repulsionForce isActive not ]) ifTrue: [
		repulsionForce := self world addForce: CFPhysicsManyBodyRepulsionForce new ].
	repulsionForce
		bodies: currentBodies;
		distanceResponse: (CFPhysicsSoftenedInverseSquareResponse new
			force: repulsion;
			softeningDistance: repulsionSofteningDistance;
			maximumDistance: maximumRepulsionDistance;
			yourself)
]

{ #category : 'private - reconciliation' }
CFPhysicsForceDirectedBehaviour >> ensurePositioningForceFor: currentBodies [
	(positioningForce isNil or: [ positioningForce isActive not ]) ifTrue: [
		positioningForce := self world addForce: CFPhysicsCentreForce new ].
	positioningForce
		bodies: currentBodies;
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
	orientationForcesByElement values copy do: #remove.
	repulsionForce ifNotNil: [ repulsionForce remove ].
	positioningForce ifNotNil: [ positioningForce remove ].
	repulsionForce := nil.
	positioningForce := nil.
	springsByEdge removeAll.
	orientationForcesByElement removeAll
]
