Class {
	#name : 'CFPhysicsForceDirectedBehaviourTests',
	#superclass : 'TestCase',
	#category : 'BVC-Physics-Tests-Behaviours',
	#package : 'BVC-Physics-Tests-Behaviours'
}

{ #category : 'tests - behaviours' }
CFPhysicsForceDirectedBehaviourTests >> testForceDirectedDefaultsFavourQuickSettling [
	<gtExample>
	| behaviour |
	behaviour := CFPhysicsForceDirectedBehaviour new.
	self assert: behaviour length equals: 80.0.
	self assert: behaviour hertz equals: 3.0.
	self assert: behaviour dampingRatio equals: 1.0.
	self assert: behaviour repulsion equals: 100000.0.
	self assert: behaviour repulsionSofteningDistance equals: 50.0.
	self assert: behaviour maximumRepulsionDistance equals: 200.0.
	self assert: behaviour velocityDamping equals: 8.0
]

{ #category : 'tests - behaviours' }
CFPhysicsForceDirectedBehaviourTests >> testForceDirectedCreatesSpringsAndRepulsionsInConnectionOrder [
	<gtExample>
	| root first second third world edge behaviour |
	root := BlElement new.
	first := BlElement new extent: 20 @ 20.
	second := BlElement new extent: 20 @ 20.
	third := BlElement new extent: 20 @ 20.
	root addChildren: { first. second. third }.
	world := root physics beWorld.
	world gravity: 0 @ 0.
	edge := first -> second.
	behaviour := root physics forceDirected.
	behaviour
		nodes: [ { first. second. third } ];
		connections: [ { edge } ].
	world step.
	self assert: behaviour springsByConnection size equals: 1.
	self assert: behaviour repulsionsByPair size equals: 3.
	self assert: world springs size equals: 1.
	self assert: world repulsions size equals: 3
]

{ #category : 'tests - behaviours' }
CFPhysicsForceDirectedBehaviourTests >> testForceDirectedRetainsExistingConstraintsWhileReconcilingChanges [
	<gtExample>
	| root first second third world nodes connections firstConnection secondConnection behaviour retainedSpring retainedRepulsion |
	root := BlElement new.
	first := BlElement new extent: 20 @ 20.
	second := BlElement new extent: 20 @ 20.
	third := BlElement new extent: 20 @ 20.
	root addChildren: { first. second. third }.
	world := root physics beWorld.
	world gravity: 0 @ 0.
	nodes := OrderedCollection with: first with: second.
	firstConnection := first -> second.
	secondConnection := second -> third.
	connections := OrderedCollection with: firstConnection.
	behaviour := root physics forceDirected.
	behaviour
		nodes: [ nodes ];
		connections: [ connections ].
	world step.
	retainedSpring := behaviour springsByConnection at: firstConnection.
	retainedRepulsion := behaviour repulsionsByPair values anyOne.
	nodes add: third.
	connections add: secondConnection.
	world step.
	self assert: (behaviour springsByConnection at: firstConnection) identicalTo: retainedSpring.
	self assert: (behaviour repulsionsByPair values includes: retainedRepulsion).
	self assert: behaviour springsByConnection size equals: 2.
	self assert: behaviour repulsionsByPair size equals: 3.
	connections remove: firstConnection.
	nodes remove: first.
	world step.
	self deny: (behaviour springsByConnection includesKey: firstConnection).
	self assert: behaviour springsByConnection size equals: 1.
	self assert: behaviour repulsionsByPair size equals: 1.
	self deny: retainedSpring isActive
]

{ #category : 'tests - behaviours' }
CFPhysicsForceDirectedBehaviourTests >> testForceDirectedConfigurationUpdatesSharedPrimitiveValues [
	<gtExample>
	| root first second world connection behaviour spring repulsion |
	root := BlElement new.
	first := BlElement new extent: 20 @ 20.
	second := BlElement new extent: 20 @ 20.
	root addChildren: { first. second }.
	world := root physics beWorld.
	connection := first -> second.
	behaviour := root physics forceDirected.
	behaviour
		nodes: [ { first. second } ];
		connections: [ { connection } ].
	world step.
	spring := behaviour springsByConnection at: connection.
	repulsion := behaviour repulsionsByPair values anyOne.
	behaviour
		length: 175;
		hertz: 25;
		dampingRatio: 4;
		repulsion: 700;
		repulsionSofteningDistance: 35;
		maximumRepulsionDistance: 250;
		velocityDamping: 12.
	world step.
	self assert: spring length equals: 175.0.
	self assert: spring hertz equals: 25.0.
	self assert: spring dampingRatio equals: 4.0.
	self assert: repulsion force value equals: 700.0.
	self assert: repulsion distanceResponse class equals: CFPhysicsSoftenedInverseSquareResponse.
	self assert: repulsion distanceResponse softeningDistance value equals: 35.0.
	self assert: repulsion maximumDistance value equals: 250.0.
	self assert: behaviour velocityDamping equals: 12.0
]

{ #category : 'tests - behaviours' }
CFPhysicsForceDirectedBehaviourTests >> testRemovingForceDirectedRemovesOnlyItsOwnedConstraints [
	<gtExample>
	| root first second world connection firstBehaviour secondBehaviour firstSpring secondSpring |
	root := BlElement new.
	first := BlElement new extent: 20 @ 20.
	second := BlElement new extent: 20 @ 20.
	root addChildren: { first. second }.
	world := root physics beWorld.
	connection := first -> second.
	firstBehaviour := root physics forceDirected.
	firstBehaviour
		nodes: [ { first. second } ];
		connections: [ { connection } ].
	secondBehaviour := root physics forceDirected.
	secondBehaviour
		nodes: [ { first. second } ];
		connections: [ { connection } ].
	world step.
	firstSpring := firstBehaviour springsByConnection at: connection.
	secondSpring := secondBehaviour springsByConnection at: connection.
	firstBehaviour remove.
	self deny: firstSpring isActive.
	self assert: secondSpring isActive.
	self assert: world springs equals: { secondSpring }.
	self assert: world repulsions size equals: 1
]

{ #category : 'tests - behaviours' }
CFPhysicsForceDirectedBehaviourTests >> testForceDirectedRejectsEndpointsOutsideItsNodeSelection [
	<gtExample>
	| root first second world connection behaviour |
	root := BlElement new.
	first := BlElement new extent: 20 @ 20.
	second := BlElement new extent: 20 @ 20.
	root addChildren: { first. second }.
	world := root physics beWorld.
	connection := first -> second.
	behaviour := root physics forceDirected.
	behaviour
		nodes: [ { first } ];
		connections: [ { connection } ].
	self
		should: [ world step ]
		raise: Error
		withExceptionDo: [ :error |
			self assert: error messageText equals:
				'Every force-directed connection endpoint must occur in the selected nodes' ]
]
