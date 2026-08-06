"
I provide executable showcases of Physics integrated with Mondrian.

My responsibility is to demonstrate world creation, force-directed Behaviour and Physics inspection on graph visualisations.
"
Class {
	#name : 'CFPhysicsMondrianExamples',
	#superclass : 'Object',
	#category : 'BVC-Physics-Examples',
	#package : 'BVC-Physics-Examples'
}

{ #category : 'showcase - mondrian' }
CFPhysicsMondrianExamples >> defaultPhysicsGraph [
	<gtExample>
	<return: #GtMondrian>
	| mondrian |
	mondrian := CFPhysicsMondrianExampleGraphBuilder new build.
	mondrian physics beWorld.
	^ mondrian
]

{ #category : 'showcase - mondrian' }
CFPhysicsMondrianExamples >> forceDirectedGraph [
	<gtExample>
	<return: #GtMondrian>
	| mondrian world |
	mondrian := CFPhysicsMondrianExampleGraphBuilder new build.
	world := mondrian physics beWorld.
	world gravity: 0 @ 0.
	mondrian physics forceDirected.
	^ mondrian
]

{ #category : 'showcase - mondrian' }
CFPhysicsMondrianExamples >> livingBehaviourGraph [
	<gtExample>
	<return: #GtMondrian>
	^ self forceDirectedGraph
]


{ #category : 'showcase - mondrian' }
CFPhysicsMondrianExamples >> physicsInspectorGraph [
	<gtExample>
	<return: #GtMondrian>
	| space mondrian world nodes overlay |
	space := BlSpace new.
	space time: BlTime simulated.
	mondrian := CFPhysicsMondrianExampleGraphBuilder new build.
	space root addChild: mondrian root.
	space pulse.
	world := mondrian physics beWorld.
	world gravity: 0 @ 0.
	mondrian physics forceDirected.
	space pulse.
	nodes := mondrian nodeElements.
	nodes first physics
		density: 2.0;
		friction: 0.8;
		restitution: 0.2.
	nodes second physics
		density: 0.5;
		friction: 0.1;
		restitution: 0.9.
	nodes third physics beStatic.
	overlay := mondrian root showPhysicsOverlay.
	nodes first fireEvent: BlClickEvent new.
	self assert: overlay selectedElement == nodes first.
	self assert: overlay objectInspector selectedPhysics == nodes first existingPhysics.
	^ mondrian
]
