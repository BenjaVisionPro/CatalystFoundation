Class {
	#name : 'CFPhysicsMondrianExampleGraphBuilder',
	#superclass : 'Object',
	#instVars : [ 'random' ],
	#category : 'BVC-Foundation-Physics-Examples',
	#package : 'BVC-Foundation-Physics-Examples'
}

{ #category : 'examples' }
CFPhysicsMondrianExampleGraphBuilder >> exampleGraph [
	<gtExample>
	<return: #GtMondrian>
	^ self build
]

{ #category : 'building' }
CFPhysicsMondrianExampleGraphBuilder >> build [
	| mondrian models |
	random := self newRandom.
	models := self nodeModels.
	mondrian := GtMondrian new.
	self configureRoot: mondrian root.
	mondrian nodes
		stencil: [ :aModel | self newNodeElementFor: aModel ];
		with: models.
	mondrian edges
		fromNearestCircle;
		toNearestCircle;
		stencil: [ :anEdge | self newEdgeElement ];
		connectAssociations: (self edgesFor: models).
	self positionNodesOf: mondrian.
	^ mondrian
]

{ #category : 'private - building' }
CFPhysicsMondrianExampleGraphBuilder >> configureRoot: aRoot [
	aRoot
		size: 920 @ 620;
		background: (Color veryVeryDarkGray alpha: 0.96)
]

{ #category : 'private - building' }
CFPhysicsMondrianExampleGraphBuilder >> edgesFor: aCollection [
	| edges |
	edges := OrderedCollection new.
	1 to: aCollection size - 1 do: [ :index |
		edges add: (aCollection at: index) -> (aCollection at: index + 1) ].
	8 timesRepeat: [ self addChordTo: edges among: aCollection ].
	^ edges
]

{ #category : 'private - building' }
CFPhysicsMondrianExampleGraphBuilder >> addChordTo: edges among: aCollection [
	| source target candidate |
	source := self randomModelFrom: aCollection.
	target := self randomModelFrom: aCollection.
	[ source = target or: [ edges includes: (source -> target) ] ] whileTrue: [
		target := self randomModelFrom: aCollection ].
	candidate := source -> target.
	edges add: candidate
]

{ #category : 'private - building' }
CFPhysicsMondrianExampleGraphBuilder >> newEdgeElement [
	^ BlLineElement new
		zIndex: -1;
		border: (BlBorder paint: (Color lightGray alpha: 0.38) width: 2);
		yourself
]

{ #category : 'private - building' }
CFPhysicsMondrianExampleGraphBuilder >> newNodeElementFor: aModel [
	| aptitude element |
	aptitude := BrGlamorousLabelAptitude new.
	aptitude foreground: Color white.
	element := BrLabel new
		aptitude: aptitude;
		text: 'Node ' , aModel asString;
		size: 62 @ 34;
		geometry: (BlRoundedRectangleGeometry cornerRadii: (BlCornerRadii radius: 10));
		background: Color blue muchDarker;
		border: (BlBorder paint: (Color white alpha: 0.28) width: 1);
		addEventHandler: BlPullHandler new;
		yourself.
	element physics excludeDescendantsFromWorld.
	^ element
]

{ #category : 'private - initialization' }
CFPhysicsMondrianExampleGraphBuilder >> newRandom [
	^ CFPhysicsRandomSource seed: 7319
]

{ #category : 'private - building' }
CFPhysicsMondrianExampleGraphBuilder >> nodeModels [
	^ 1 to: 12
]

{ #category : 'private - building' }
CFPhysicsMondrianExampleGraphBuilder >> positionNodesOf: aMondrian [
	aMondrian nodeElements withIndexDo: [ :each :index |
		| x y |
		x := 24 + ((index - 1) * 74) + ((random next * 18) - 9).
		y := 28 + (random next * 120).
		each relocate: x @ y ]
]

{ #category : 'private - building' }
CFPhysicsMondrianExampleGraphBuilder >> randomModelFrom: aCollection [
	^ aCollection at: (random next * aCollection size) floor + 1
]
