Class {
	#name : 'CFPhysicsMondrianExampleGraphBuilder',
	#superclass : 'Object',
	#instVars : [ 'randomState', 'nextNodeId', 'depth', 'rootCountRange', 'childrenRanges', 'parentCountRanges' ],
	#category : 'BVC-Foundation-Physics-Examples',
	#package : 'BVC-Foundation-Physics-Examples'
}

{ #category : 'examples' }
CFPhysicsMondrianExampleGraphBuilder >> exampleGraph [
	<gtExample>
	<return: #GtMondrian>
	^ self build
]

{ #category : 'initialization' }
CFPhysicsMondrianExampleGraphBuilder >> initialize [
	super initialize.
	depth := 3.
	rootCountRange := 1 @ 7.
	childrenRanges := Dictionary new
		at: 1 put: (0 @ 20);
		at: 2 put: (5 @ 10);
		yourself.
	parentCountRanges := Dictionary new
		at: 2 put: (1 @ 4);
		yourself
]

{ #category : 'building' }
CFPhysicsMondrianExampleGraphBuilder >> build [
	| mondrian graph |
	randomState := 7319.
	nextNodeId := 1.
	graph := self newGraph.
	mondrian := GtMondrian new.
	self configureRoot: mondrian root.
	mondrian nodes
		stencil: [ :aModel | self newNodeElementFor: aModel ];
		with: graph first.
	mondrian edges
		fromNearestCircle;
		toNearestCircle;
		stencil: [ :anEdge | self newEdgeElement ];
		connectAssociations: graph second.
	self positionNodesOf: mondrian.
	^ mondrian
]

{ #category : 'configuration' }
CFPhysicsMondrianExampleGraphBuilder >> childrenAtLevel: aLevel from: aMinimum to: aMaximum [
	self validateLevel: aLevel.
	self validateRangeFrom: aMinimum to: aMaximum.
	childrenRanges at: aLevel put: (aMinimum @ aMaximum).
	^ self
]

{ #category : 'configuration' }
CFPhysicsMondrianExampleGraphBuilder >> depth: aDepth [
	(aDepth isInteger and: [ aDepth positive ]) ifFalse: [
		self error: 'Depth must be a positive integer' ].
	depth := aDepth.
	^ self
]

{ #category : 'configuration' }
CFPhysicsMondrianExampleGraphBuilder >> parentsAtLevel: aLevel from: aMinimum to: aMaximum [
	self validateLevel: aLevel.
	self validateRangeFrom: aMinimum to: aMaximum.
	parentCountRanges at: aLevel put: (aMinimum @ aMaximum).
	^ self
]

{ #category : 'configuration' }
CFPhysicsMondrianExampleGraphBuilder >> rootCountFrom: aMinimum to: aMaximum [
	self validateRangeFrom: aMinimum to: aMaximum.
	rootCountRange := aMinimum @ aMaximum.
	^ self
]

{ #category : 'private - building' }
CFPhysicsMondrianExampleGraphBuilder >> configureRoot: aRoot [
	aRoot
		size: 920 @ 620;
		background: Color veryVeryLightGray
]

{ #category : 'private - building' }
CFPhysicsMondrianExampleGraphBuilder >> newGraph [
	| nodes connections parents |
	nodes := OrderedCollection new.
	connections := OrderedCollection new.
	parents := self newRootNodesIn: nodes.
	1 to: depth - 1 do: [ :level |
		parents := self
			addChildrenAtLevel: level
			below: parents
			into: nodes
			connections: connections ].
	^ { nodes. connections }
]

{ #category : 'private - building' }
CFPhysicsMondrianExampleGraphBuilder >> addChildrenAtLevel: aLevel below: parentNodes into: nodes connections: connections [
	| available children |
	available := parentNodes asOrderedCollection.
	children := OrderedCollection new.
	(self parentCountAtLevel: aLevel from: available size) timesRepeat: [
		| parent |
		parent := available removeAt: ((self nextRandom * available size) floor + 1).
		(self childCountAtLevel: aLevel) timesRepeat: [
			| child |
			child := self newNodeIn: nodes.
			connections add: parent -> child.
			children add: child ] ].
	^ children
]

{ #category : 'private - building' }
CFPhysicsMondrianExampleGraphBuilder >> newRootNodesIn: nodes [
	| roots |
	roots := OrderedCollection new.
	self rootCount timesRepeat: [
		| root |
		root := self newNodeIn: nodes.
		roots add: root ].
	^ roots
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
	aptitude foreground: Color darkGray.
	element := BrLabel new
		aptitude: aptitude;
		text: 'Node ' , aModel asString;
		size: 62 @ 34;
		geometry: (BlRoundedRectangleGeometry cornerRadii: (BlCornerRadii radius: 10));
		background: Color white;
		border: BlBorder empty;
		addEventHandler: BlPullHandler new;
		yourself.
	^ element
]

{ #category : 'private - building' }
CFPhysicsMondrianExampleGraphBuilder >> newNodeIn: nodes [
	| node |
	node := nextNodeId.
	nextNodeId := nextNodeId + 1.
	nodes add: node.
	^ node
]

{ #category : 'private - building' }
CFPhysicsMondrianExampleGraphBuilder >> positionNodesOf: aMondrian [
	aMondrian nodeElements withIndexDo: [ :each :index |
		| column row x y |
		column := (index - 1) \\ 13.
		row := (index - 1) // 13.
		x := 24 + (column * 66) + ((self nextRandom * 8) - 4).
		y := 24 + (row * 38) + ((self nextRandom * 6) - 3).
		each relocate: x @ y ]
]

{ #category : 'private - building' }
CFPhysicsMondrianExampleGraphBuilder >> rootCount [
	^ self randomIntegerFrom: rootCountRange x to: rootCountRange y
]

{ #category : 'private - building' }
CFPhysicsMondrianExampleGraphBuilder >> childCountAtLevel: aLevel [
	| range |
	range := childrenRanges at: aLevel ifAbsent: [ ^ 0 ].
	^ self randomIntegerFrom: range x to: range y
]

{ #category : 'private - building' }
CFPhysicsMondrianExampleGraphBuilder >> parentCountAtLevel: aLevel from: anAvailableCount [
	| range minimum maximum |
	anAvailableCount isZero ifTrue: [ ^ 0 ].
	range := parentCountRanges at: aLevel ifAbsent: [ ^ anAvailableCount ].
	minimum := range x min: anAvailableCount.
	maximum := range y min: anAvailableCount.
	^ self randomIntegerFrom: minimum to: maximum
]

{ #category : 'private - building' }
CFPhysicsMondrianExampleGraphBuilder >> randomIntegerFrom: aMinimum to: aMaximum [
	^ aMinimum + (self nextRandom * (aMaximum - aMinimum + 1)) floor
]

{ #category : 'private - validation' }
CFPhysicsMondrianExampleGraphBuilder >> validateLevel: aLevel [
	(aLevel isInteger and: [ aLevel positive ]) ifFalse: [
		self error: 'Level must be a positive integer' ]
]

{ #category : 'private - validation' }
CFPhysicsMondrianExampleGraphBuilder >> validateRangeFrom: aMinimum to: aMaximum [
	((aMinimum isInteger and: [ aMaximum isInteger ])
		and: [ aMinimum >= 0 and: [ aMinimum <= aMaximum ] ]) ifFalse: [
		self error: 'Ranges must contain ordered non-negative integers' ]
]

{ #category : 'private - random' }
CFPhysicsMondrianExampleGraphBuilder >> nextRandom [
	randomState := (randomState * 48271) \\ 2147483647.
	^ randomState asFloat / 2147483647.0
]
