Class {
	#name : 'CFPhysicsForceDirectedBehaviourTests',
	#superclass : 'TestCase',
	#category : 'BVC-Physics-Tests-Behaviours',
	#package : 'BVC-Physics-Tests-Behaviours'
}

{ #category : 'private' }
CFPhysicsForceDirectedBehaviourTests >> adapterForElements: elements edges: edges [
	^ CFPhysicsGraphAdapter new
		elementsBlock: [ :target | elements ];
		edgesBlock: [ :target | edges ];
		sourceElementBlock: [ :edge | edge key ];
		destinationElementBlock: [ :edge | edge value ];
		yourself
]

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
CFPhysicsForceDirectedBehaviourTests >> testForceDirectedCreatesSpringsAndRepulsions [
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
	behaviour := CFPhysicsForceDirectedBehaviour new
		target: root;
		adapter: (self adapterForElements: { first. second. third } edges: { edge });
		start.
	self assert: behaviour springsByEdge size equals: 1.
	self assert: behaviour repulsionsByPair size equals: 3.
	self assert: world springs size equals: 1.
	self assert: world repulsions size equals: 3
]

{ #category : 'tests - behaviours' }
CFPhysicsForceDirectedBehaviourTests >> testForceDirectedRetainsExistingConstraintsWhileReconcilingChanges [
	<gtExample>
	| root first second third world elements edges firstEdge secondEdge behaviour retainedSpring retainedRepulsion |
	root := BlElement new.
	first := BlElement new extent: 20 @ 20.
	second := BlElement new extent: 20 @ 20.
	third := BlElement new extent: 20 @ 20.
	root addChildren: { first. second. third }.
	world := root physics beWorld.
	world gravity: 0 @ 0.
	elements := OrderedCollection with: first with: second.
	firstEdge := first -> second.
	secondEdge := second -> third.
	edges := OrderedCollection with: firstEdge.
	behaviour := CFPhysicsForceDirectedBehaviour new
		target: root;
		adapter: (self adapterForElements: elements edges: edges);
		start.
	retainedSpring := behaviour springsByEdge at: firstEdge.
	retainedRepulsion := behaviour repulsionsByPair values anyOne.
	elements add: third.
	edges add: secondEdge.
	world step.
	self assert: (behaviour springsByEdge at: firstEdge) identicalTo: retainedSpring.
	self assert: (behaviour repulsionsByPair values includes: retainedRepulsion).
	self assert: behaviour springsByEdge size equals: 2.
	self assert: behaviour repulsionsByPair size equals: 3.
	edges remove: firstEdge.
	elements remove: first.
	world step.
	self deny: (behaviour springsByEdge includesKey: firstEdge).
	self assert: behaviour springsByEdge size equals: 1.
	self assert: behaviour repulsionsByPair size equals: 1.
	self deny: retainedSpring isActive
]

{ #category : 'tests - behaviours' }
CFPhysicsForceDirectedBehaviourTests >> testForceDirectedConfigurationUpdatesOwnedPhysics [
	<gtExample>
	| root first second world edge behaviour spring repulsion |
	root := BlElement new.
	first := BlElement new extent: 20 @ 20.
	second := BlElement new extent: 20 @ 20.
	root addChildren: { first. second }.
	world := root physics beWorld.
	edge := first -> second.
	behaviour := CFPhysicsForceDirectedBehaviour new
		target: root;
		adapter: (self adapterForElements: { first. second } edges: { edge });
		start.
	spring := behaviour springsByEdge at: edge.
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
	self assert: repulsion distanceResponse softeningDistance value equals: 35.0.
	self assert: repulsion maximumDistance value equals: 250.0
]

{ #category : 'tests - behaviours' }
CFPhysicsForceDirectedBehaviourTests >> testStoppingForceDirectedRemovesOnlyItsOwnedPhysics [
	<gtExample>
	| root first second world edge firstBehaviour secondBehaviour firstSpring secondSpring |
	root := BlElement new.
	first := BlElement new extent: 20 @ 20.
	second := BlElement new extent: 20 @ 20.
	root addChildren: { first. second }.
	world := root physics beWorld.
	edge := first -> second.
	firstBehaviour := CFPhysicsForceDirectedBehaviour new
		target: root;
		adapter: (self adapterForElements: { first. second } edges: { edge });
		start.
	secondBehaviour := CFPhysicsForceDirectedBehaviour new
		target: root;
		adapter: (self adapterForElements: { first. second } edges: { edge });
		start.
	firstSpring := firstBehaviour springsByEdge at: edge.
	secondSpring := secondBehaviour springsByEdge at: edge.
	firstBehaviour stop.
	self deny: firstSpring isActive.
	self assert: secondSpring isActive.
	self assert: world springs equals: { secondSpring }.
	self assert: world repulsions size equals: 1
]

{ #category : 'tests - behaviours' }
CFPhysicsForceDirectedBehaviourTests >> testForceDirectedRejectsEndpointsOutsideItsElementSelection [
	<gtExample>
	| root first second edge behaviour |
	root := BlElement new.
	first := BlElement new extent: 20 @ 20.
	second := BlElement new extent: 20 @ 20.
	root addChildren: { first. second }.
	root physics beWorld.
	edge := first -> second.
	behaviour := CFPhysicsForceDirectedBehaviour new
		target: root;
		adapter: (self adapterForElements: { first } edges: { edge }).
	self
		should: [ behaviour start ]
		raise: Error
		withExceptionDo: [ :error |
			self assert: error messageText equals:
				'Every force-directed edge endpoint must occur in the selected elements' ]
]
