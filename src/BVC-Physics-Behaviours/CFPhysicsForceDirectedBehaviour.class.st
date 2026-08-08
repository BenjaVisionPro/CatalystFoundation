"
I orchestrate a force-directed arrangement for a graph supplied by an adapter.

I reconcile edge distance joints and configure the persistent forces that repel, centre, and gently gather disconnected graph components.
"
Class {
	#name : 'CFPhysicsForceDirectedBehaviour',
	#superclass : 'CFPhysicsBehaviour',
	#instVars : [
		'adapter', 'springsByEdge', 'orientationForcesByElement', 'repulsionForce', 'positioningForce', 'componentForces',
		'length', 'hertz', 'dampingRatio',
		'repulsionAtOneMetre', 'maximumRepulsionDistance', 'centringStiffness', 'componentCentringStiffness', 'linearDamping',
		'orientationStiffness', 'orientationDamping', 'orientationMaximumAngularAcceleration', 'orientationAngularResponseVelocityScale', 'orientationAngleTolerance', 'orientationAngularVelocityTolerance',
		'originalLinearDampingByBody'
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
	componentForces := IdentityDictionary new.
	length := CFPhysicsSharedScalar value: 90.0.
	hertz := CFPhysicsSharedScalar value: 1.5.
	dampingRatio := CFPhysicsSharedScalar value: 1.5.
	repulsionAtOneMetre := CFPhysicsSharedScalar value: 1.5.
	maximumRepulsionDistance := CFPhysicsSharedScalar value: 5.0.
	centringStiffness := CFPhysicsSharedScalar value: 2.0.
	componentCentringStiffness := CFPhysicsSharedScalar value: 1.0.
	linearDamping := CFPhysicsSharedScalar value: 2.5.
	orientationStiffness := CFPhysicsSharedScalar value: 36.0.
	orientationDamping := CFPhysicsSharedScalar value: 6.0.
	orientationMaximumAngularAcceleration := CFPhysicsSharedScalar value: 30.0.
	orientationAngularResponseVelocityScale := CFPhysicsSharedScalar value: 4.0.
	orientationAngleTolerance := CFPhysicsSharedScalar value: 0.002.
	orientationAngularVelocityTolerance := CFPhysicsSharedScalar value: 0.01.
	originalLinearDampingByBody := IdentityDictionary new
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

{ #category : 'accessing' }
CFPhysicsForceDirectedBehaviour >> componentForces [ ^ componentForces values asArray ]

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
CFPhysicsForceDirectedBehaviour >> repulsionAtOneMetre [ "Repulsive force in newtons at one metre separation." ^ repulsionAtOneMetre value ]
{ #category : 'configuration' }
CFPhysicsForceDirectedBehaviour >> repulsionAtOneMetre: aNumber [ repulsionAtOneMetre value: (aNumber asFloat max: 0.0) ]
{ #category : 'configuration' }
CFPhysicsForceDirectedBehaviour >> maximumRepulsionDistance [ "Maximum repulsion range in metres." ^ maximumRepulsionDistance value ]
{ #category : 'configuration' }
CFPhysicsForceDirectedBehaviour >> maximumRepulsionDistance: aNumber [ maximumRepulsionDistance value: aNumber ]
{ #category : 'configuration' }
CFPhysicsForceDirectedBehaviour >> centringStiffness [ "Whole-graph centring stiffness in newtons per metre." ^ centringStiffness value ]
{ #category : 'configuration' }
CFPhysicsForceDirectedBehaviour >> centringStiffness: aNumber [ centringStiffness value: (aNumber asFloat max: 0.0) ]
{ #category : 'configuration' }
CFPhysicsForceDirectedBehaviour >> componentCentringStiffness [ "Disconnected-component centring stiffness in newtons per metre." ^ componentCentringStiffness value ]
{ #category : 'configuration' }
CFPhysicsForceDirectedBehaviour >> componentCentringStiffness: aNumber [ componentCentringStiffness value: (aNumber asFloat max: 0.0) ]
{ #category : 'configuration' }
CFPhysicsForceDirectedBehaviour >> linearDamping [ ^ linearDamping value ]
{ #category : 'configuration' }
CFPhysicsForceDirectedBehaviour >> linearDamping: aNumber [ linearDamping value: (aNumber asFloat max: 0.0) ]

{ #category : 'configuration' }
CFPhysicsForceDirectedBehaviour >> orientationStiffness [ ^ orientationStiffness value ]
{ #category : 'configuration' }
CFPhysicsForceDirectedBehaviour >> orientationStiffness: aNumber [ orientationStiffness value: (aNumber asFloat max: 0.0) ]
{ #category : 'configuration' }
CFPhysicsForceDirectedBehaviour >> orientationDamping [ ^ orientationDamping value ]
{ #category : 'configuration' }
CFPhysicsForceDirectedBehaviour >> orientationDamping: aNumber [ orientationDamping value: (aNumber asFloat max: 0.0) ]
{ #category : 'configuration' }
CFPhysicsForceDirectedBehaviour >> orientationMaximumAngularAcceleration [ ^ orientationMaximumAngularAcceleration value ]
{ #category : 'configuration' }
CFPhysicsForceDirectedBehaviour >> orientationMaximumAngularAcceleration: aNumber [ orientationMaximumAngularAcceleration value: (aNumber asFloat max: 0.0) ]
{ #category : 'configuration' }
CFPhysicsForceDirectedBehaviour >> orientationAngularResponseVelocityScale [ ^ orientationAngularResponseVelocityScale value ]
{ #category : 'configuration' }
CFPhysicsForceDirectedBehaviour >> orientationAngularResponseVelocityScale: aNumber [ orientationAngularResponseVelocityScale value: (aNumber asFloat max: Float machineEpsilon) ]
{ #category : 'configuration' }
CFPhysicsForceDirectedBehaviour >> orientationAngleTolerance [ ^ orientationAngleTolerance value ]
{ #category : 'configuration' }
CFPhysicsForceDirectedBehaviour >> orientationAngleTolerance: aNumber [ orientationAngleTolerance value: (aNumber asFloat max: 0.0) ]
{ #category : 'configuration' }
CFPhysicsForceDirectedBehaviour >> orientationAngularVelocityTolerance [ ^ orientationAngularVelocityTolerance value ]
{ #category : 'configuration' }
CFPhysicsForceDirectedBehaviour >> orientationAngularVelocityTolerance: aNumber [ orientationAngularVelocityTolerance value: (aNumber asFloat max: 0.0) ]

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
	self reconcile
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
	self reconcileComponentForcesFor: currentElements edges: currentEdges.
	self reconcileBodyDampingFor: currentElements.
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
			force wakesBodies: false.
			orientationForcesByElement at: element put: force ].
		force
			stiffness: orientationStiffness value;
			damping: orientationDamping value;
			maximumAngularAcceleration: orientationMaximumAngularAcceleration value;
			angularResponseVelocityScale: orientationAngularResponseVelocityScale value;
			angleTolerance: orientationAngleTolerance value;
			angularVelocityTolerance: orientationAngularVelocityTolerance value ]
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
		repulsionForce := self world addForce: (CFPhysicsManyBodyRepulsionForce new
			wakesBodies: false;
			distanceResponse: CFPhysicsInverseSquareResponse new;
			yourself) ].
	repulsionForce
		bodies: currentBodies;
		force: repulsionAtOneMetre value;
		maximumDistance: maximumRepulsionDistance value
]

{ #category : 'private - reconciliation' }
CFPhysicsForceDirectedBehaviour >> ensurePositioningForceFor: currentBodies [
	(positioningForce isNil or: [ positioningForce isActive not ]) ifTrue: [
		positioningForce := self world addForce: (CFPhysicsCentreForce new wakesBodies: false) ].
	positioningForce
		bodies: currentBodies;
		centre: self world owner extent / 2.0;
		stiffness: centringStiffness value
]


{ #category : 'private - reconciliation' }
CFPhysicsForceDirectedBehaviour >> connectedComponentsFor: currentElements edges: currentEdges [
	| adjacency remaining components |
	adjacency := IdentityDictionary new.
	currentElements do: [ :element | adjacency at: element put: IdentitySet new ].
	currentEdges do: [ :edge |
		| source destination |
		source := adapter sourceElementFor: edge.
		destination := adapter destinationElementFor: edge.
		(adjacency at: source) add: destination.
		(adjacency at: destination) add: source ].
	remaining := currentElements asIdentitySet.
	components := OrderedCollection new.
	currentElements do: [ :start |
		(remaining includes: start) ifTrue: [
			| component pending |
			component := OrderedCollection new.
			pending := OrderedCollection with: start.
			remaining remove: start.
			[ pending isNotEmpty ] whileTrue: [
				| element |
				element := pending removeFirst.
				component add: element.
				(adjacency at: element) do: [ :neighbour |
					(remaining includes: neighbour) ifTrue: [
						remaining remove: neighbour.
						pending add: neighbour ] ] ].
			components add: component ] ].
	^ components
]

{ #category : 'private - reconciliation' }
CFPhysicsForceDirectedBehaviour >> reconcileComponentForcesFor: currentElements edges: currentEdges [
	| components desiredKeys centre |
	components := self connectedComponentsFor: currentElements edges: currentEdges.
	desiredKeys := IdentitySet new.
	centre := self world owner extent / 2.0.
	components size > 1 ifTrue: [
		components do: [ :component |
			| key force bodies |
			key := component first.
			desiredKeys add: key.
			bodies := component collect: [ :element | element physics body ].
			force := componentForces at: key ifAbsentPut: [
				self world addForce: (CFPhysicsCentreForce new wakesBodies: false) ].
			force
				bodies: bodies;
				centre: centre;
				stiffness: componentCentringStiffness value ] ].
	componentForces associations copy do: [ :association |
		(desiredKeys includes: association key) ifFalse: [
			association value remove.
			componentForces removeKey: association key ] ]
]

{ #category : 'private - reconciliation' }
CFPhysicsForceDirectedBehaviour >> reconcileBodyDampingFor: currentElements [
	| currentBodies desiredBodies |
	currentBodies := currentElements collect: [ :element | element physics body ].
	desiredBodies := currentBodies asIdentitySet.
	originalLinearDampingByBody associations copy do: [ :association |
		(desiredBodies includes: association key) ifFalse: [
			association key linearDamping: association value.
			originalLinearDampingByBody removeKey: association key ] ].
	currentBodies do: [ :body |
		originalLinearDampingByBody
			at: body
			ifAbsentPut: [ body linearDamping ].
		body linearDamping: linearDamping value ]
]

{ #category : 'private - running' }
CFPhysicsForceDirectedBehaviour >> restoreBodyDamping [
	originalLinearDampingByBody associations copy do: [ :association |
		association key linearDamping: association value ].
	originalLinearDampingByBody removeAll
]

{ #category : 'private - running' }
CFPhysicsForceDirectedBehaviour >> removeOwnedPhysics [
	self restoreBodyDamping.
	springsByEdge values copy do: #remove.
	orientationForcesByElement values copy do: #remove.
	repulsionForce ifNotNil: [ repulsionForce remove ].
	positioningForce ifNotNil: [ positioningForce remove ].
	componentForces values copy do: #remove.
	repulsionForce := nil.
	positioningForce := nil.
	springsByEdge removeAll.
	orientationForcesByElement removeAll.
	componentForces removeAll
]


{ #category : 'accessing - physics scope' }
CFPhysicsForceDirectedBehaviour >> physicsBodies [
	^ self elements collect: [ :element | element physics body ]
]

{ #category : 'accessing - physics scope' }
CFPhysicsForceDirectedBehaviour >> physicsConstraints [
	^ springsByEdge values asArray
]
