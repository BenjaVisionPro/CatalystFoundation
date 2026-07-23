Class {
	#name : 'CFPhysicsMondrianShowcaseExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Physics-Examples',
	#package : 'BVC-Foundation-Physics-Examples'
}

{ #category : 'showcase - mondrian' }
CFPhysicsMondrianShowcaseExamples >> defaultPhysicsGraph [
	<gtExample>
	<return: #GtMondrian>
	| mondrian world |
	mondrian := CFPhysicsMondrianExampleGraphBuilder new build.
	world := mondrian physics beWorld.
	mondrian root when: BlElementAddedToSceneGraphEvent do: [ :anEvent |
		world startStepping ].
	^ mondrian
]

{ #category : 'showcase - mondrian' }
CFPhysicsMondrianShowcaseExamples >> forceDirectedGraph [
	<gtExample>
	<return: #GtMondrian>
	| mondrian world forceDirected |
	mondrian := CFPhysicsMondrianExampleGraphBuilder new build.
	world := mondrian physics beWorld.
	world gravity: 0 @ 0.
	forceDirected := mondrian physics forceDirected.
	forceDirected
		restLength: 118.0;
		stiffness: 52.0;
		damping: 7.0;
		repulsion: 5200.0;
		maximumRepulsionDistance: 340.0.
	mondrian root when: BlElementAddedToSceneGraphEvent do: [ :anEvent |
		world startStepping ].
	^ mondrian
]

{ #category : 'showcase - mondrian' }
CFPhysicsMondrianShowcaseExamples >> livingBehaviourGraph [
	<gtExample>
	<return: #GtMondrian>
	^ self forceDirectedGraph
]
