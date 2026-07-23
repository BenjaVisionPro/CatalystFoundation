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
	| mondrian world |
	mondrian := CFPhysicsMondrianExampleGraphBuilder new build.
	world := mondrian physics beWorld.
	world gravity: 0 @ 0.
	mondrian physics forceDirected.
	self debugEdgeCoordinatesOf: mondrian in: world.
	mondrian root when: BlElementAddedToSceneGraphEvent do: [ :anEvent |
		world startStepping ].
	^ mondrian
]

{ #category : 'private - debugging' }
CFPhysicsMondrianShowcaseExamples >> debugEdgeCoordinatesOf: aMondrian in: aWorld [
	| reportedSteps |
	reportedSteps := Set new.
	aMondrian nodeElements do: [ :eachNode |
		eachNode when: BlElementTransformationChangedEvent do: [ :anEvent |
			(aWorld stepNumber <= 1 and: [ (reportedSteps includes: aWorld stepNumber) not ]) ifTrue: [
				| edge source target |
				reportedSteps add: aWorld stepNumber.
				edge := aMondrian edgeElements first.
				source := edge graph model fromElement.
				target := edge graph model toElement.
				Transcript
					crShow: 'Force-directed edge probe, step ' , aWorld stepNumber printString;
					crShow: '  root scale/translation: ' , aMondrian root childrenScaleFactor printString , ' / ' , aMondrian root childrenTranslationFactor printString;
					crShow: '  edge/root parent: ' , (edge parent == aMondrian root) printString;
					crShow: '  source physics/layout/bounds: ' , source physics position printString , ' / ' , source position printString , ' / ' , (source bounds inParent: aMondrian root) printString;
					crShow: '  target physics/layout/bounds: ' , target physics position printString , ' / ' , target position printString , ' / ' , (target bounds inParent: aMondrian root) printString;
					crShow: '  edge anchors: ' , edge fromPosition printString , ' -> ' , edge toPosition printString.
				edge commonAnchorParentDo: [ :aParent |
					Transcript crShow: '  anchor/root common parent: ' , (aParent == aMondrian root) printString ] ] ]
]

{ #category : 'showcase - mondrian' }
CFPhysicsMondrianShowcaseExamples >> livingBehaviourGraph [
	<gtExample>
	<return: #GtMondrian>
	^ self forceDirectedGraph
]
