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
	| mondrian |
	mondrian := CFPhysicsMondrianExampleGraphBuilder new build.
	mondrian physics beWorld.
	^ mondrian
]

{ #category : 'showcase - mondrian' }
CFPhysicsMondrianShowcaseExamples >> forceDirectedGraph [
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
CFPhysicsMondrianShowcaseExamples >> livingBehaviourGraph [
	<gtExample>
	<return: #GtMondrian>
	^ self forceDirectedGraph
]
