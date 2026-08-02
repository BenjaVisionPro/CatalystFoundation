"
I am a persistent dynamic AABB tree translated from the Box2D 3.1.1 broad-phase structure.

I retain leaf proxies between simulation steps. Moving a proxy only removes and reinserts its leaf when the existing fat AABB no longer contains the supplied bounds. Queries visit only tree nodes whose AABBs overlap the query bounds.

My node pool reuses released node objects. Query result ordering is made deterministic by proxy identifier rather than depending on tree shape.
"
Class {
	#name : 'CFPhysicsDynamicTree',
	#superclass : 'Object',
	#instVars : [ 'root', 'nodes', 'freeNodes', 'nextNodeIdentifier', 'proxyCount', 'queryVisitCount', 'queryLeafVisitCount', 'rotationCount' ],
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
}

{ #category : 'initialization' }
CFPhysicsDynamicTree >> initialize [
	super initialize.
	root := nil.
	nodes := OrderedCollection new.
	freeNodes := OrderedCollection new.
	nextNodeIdentifier := 1.
	proxyCount := 0.
	queryVisitCount := 0.
	queryLeafVisitCount := 0.
	rotationCount := 0
]

{ #category : 'proxies' }
CFPhysicsDynamicTree >> createProxyFor: anObject aabb: anAABB [
	| leaf |
	leaf := self allocateNode.
	leaf
		aabb: anAABB;
		userData: anObject;
		height: 0.
	self insertLeaf: leaf shouldRotate: true.
	proxyCount := proxyCount + 1.
	^ leaf
]

{ #category : 'proxies' }
CFPhysicsDynamicTree >> destroyProxy: aLeaf [
	self assert: aLeaf isAllocated.
	self assert: aLeaf isLeaf.
	self removeLeaf: aLeaf.
	self releaseNode: aLeaf.
	proxyCount := proxyCount - 1
]

{ #category : 'proxies' }
CFPhysicsDynamicTree >> moveProxy: aLeaf to: anAABB [
	"Answer true only when the proxy was removed and reinserted."
	(aLeaf aabb contains: anAABB) ifTrue: [ ^ false ].
	self removeLeaf: aLeaf.
	aLeaf aabb: anAABB.
	self insertLeaf: aLeaf shouldRotate: false.
	^ true
]

{ #category : 'querying' }
CFPhysicsDynamicTree >> query: anAABB [
	| stack leaves node first second |
	queryVisitCount := 0.
	root ifNil: [ ^ #() ].
	stack := OrderedCollection with: root.
	leaves := OrderedCollection new.
	[ stack isEmpty ] whileFalse: [
		node := stack removeLast.
		queryVisitCount := queryVisitCount + 1.
		(node aabb overlaps: anAABB) ifTrue: [
			node isLeaf
				ifTrue: [ leaves add: node ]
				ifFalse: [
					first := node firstChild.
					second := node secondChild.
					first identifier < second identifier
						ifTrue: [ stack add: second; add: first ]
						ifFalse: [ stack add: first; add: second ] ] ] ].
	^ (leaves sorted: [ :left :right | left identifier < right identifier ])
		collect: [ :leaf | leaf userData ]
]



{ #category : 'querying' }
CFPhysicsDynamicTree >> query: anAABB do: aBlock [
	"Visit overlapping proxy data using the Box2D 3.1.1 tree-query traversal.
	Answer false when aBlock terminates the query by answering false."
	| stack node |
	queryVisitCount := 0.
	queryLeafVisitCount := 0.
	root ifNil: [ ^ true ].
	stack := OrderedCollection with: root.
	[ stack isEmpty ] whileFalse: [
		node := stack removeLast.
		queryVisitCount := queryVisitCount + 1.
		(node aabb overlaps: anAABB) ifTrue: [
			node isLeaf
				ifTrue: [
					queryLeafVisitCount := queryLeafVisitCount + 1.
					(aBlock value: node userData) ifFalse: [ ^ false ] ]
				ifFalse: [
					stack
						add: node firstChild;
						add: node secondChild ] ] ].
	^ true
]

{ #category : 'private - allocation' }
CFPhysicsDynamicTree >> allocateNode [
	| node |
	freeNodes
		ifEmpty: [
			node := CFPhysicsDynamicTreeNode new.
			node identifier: nextNodeIdentifier.
			nextNodeIdentifier := nextNodeIdentifier + 1.
			nodes add: node ]
		ifNotEmpty: [ node := freeNodes removeLast ].
	node allocate.
	^ node
]

{ #category : 'private - allocation' }
CFPhysicsDynamicTree >> releaseNode: aNode [
	aNode reset.
	freeNodes add: aNode
]

{ #category : 'private - insertion' }
CFPhysicsDynamicTree >> insertLeaf: leaf shouldRotate: shouldRotate [
	| sibling oldParent newParent ancestor |
	root ifNil: [
		root := leaf.
		leaf parent: nil.
		^ self ].
	sibling := self bestSiblingFor: leaf aabb.
	oldParent := sibling parent.
	newParent := self allocateNode.
	newParent
		parent: oldParent;
		aabb: (leaf aabb mergedWith: sibling aabb);
		height: sibling height + 1;
		firstChild: sibling;
		secondChild: leaf.
	sibling parent: newParent.
	leaf parent: newParent.
	oldParent
		ifNil: [ root := newParent ]
		ifNotNil: [
			oldParent firstChild == sibling
				ifTrue: [ oldParent firstChild: newParent ]
				ifFalse: [ oldParent secondChild: newParent ] ].
	ancestor := newParent parent.
	[ ancestor notNil ] whileTrue: [
		self refit: ancestor.
		shouldRotate ifTrue: [ self balance: ancestor ].
		ancestor := ancestor parent ]
]

{ #category : 'private - insertion' }
CFPhysicsDynamicTree >> bestSiblingFor: anAABB [
	| node centre area leafArea directCost inheritedCost bestSibling bestCost first second cost firstLeaf secondLeaf firstBox secondBox firstDirectCost secondDirectCost firstArea secondArea firstLowerCost secondLowerCost firstDistance secondDistance |
	node := root.
	centre := anAABB centre.
	leafArea := anAABB perimeter.
	area := node aabb perimeter.
	directCost := (node aabb mergedWith: anAABB) perimeter.
	inheritedCost := 0.0.
	bestSibling := node.
	bestCost := directCost.
	[ node height > 0 ] whileTrue: [
		first := node firstChild.
		second := node secondChild.
		cost := directCost + inheritedCost.
		cost < bestCost ifTrue: [
			bestSibling := node.
			bestCost := cost ].
		inheritedCost := inheritedCost + directCost - area.
		firstLeaf := first isLeaf.
		secondLeaf := second isLeaf.
		firstBox := first aabb.
		secondBox := second aabb.
		firstDirectCost := (firstBox mergedWith: anAABB) perimeter.
		secondDirectCost := (secondBox mergedWith: anAABB) perimeter.
		firstArea := firstLeaf ifTrue: [ 0.0 ] ifFalse: [ firstBox perimeter ].
		secondArea := secondLeaf ifTrue: [ 0.0 ] ifFalse: [ secondBox perimeter ].
		firstLowerCost := Float infinity.
		secondLowerCost := Float infinity.
		firstLeaf
			ifTrue: [
				cost := firstDirectCost + inheritedCost.
				cost < bestCost ifTrue: [
					bestSibling := first.
					bestCost := cost ] ]
			ifFalse: [
				firstLowerCost := inheritedCost + firstDirectCost + ((leafArea - firstArea) min: 0.0) ].
		secondLeaf
			ifTrue: [
				cost := secondDirectCost + inheritedCost.
				cost < bestCost ifTrue: [
					bestSibling := second.
					bestCost := cost ] ]
			ifFalse: [
				secondLowerCost := inheritedCost + secondDirectCost + ((leafArea - secondArea) min: 0.0) ].
		(firstLeaf and: [ secondLeaf ]) ifTrue: [ ^ bestSibling ].
		(bestCost <= firstLowerCost and: [ bestCost <= secondLowerCost ]) ifTrue: [ ^ bestSibling ].
		(firstLowerCost = secondLowerCost and: [ firstLeaf not ]) ifTrue: [
			firstDistance := (firstBox centre - centre) dotProduct: (firstBox centre - centre).
			secondDistance := (secondBox centre - centre) dotProduct: (secondBox centre - centre).
			firstLowerCost := firstDistance.
			secondLowerCost := secondDistance ].
		(firstLowerCost < secondLowerCost and: [ firstLeaf not ])
			ifTrue: [
				node := first.
				area := firstArea.
				directCost := firstDirectCost ]
			ifFalse: [
				node := second.
				area := secondArea.
				directCost := secondDirectCost ] ].
	^ bestSibling
]

{ #category : 'private - removal' }
CFPhysicsDynamicTree >> removeLeaf: leaf [
	| parent grandParent sibling ancestor |
	leaf == root ifTrue: [
		root := nil.
		leaf parent: nil.
		^ self ].
	parent := leaf parent.
	grandParent := parent parent.
	sibling := parent firstChild == leaf
		ifTrue: [ parent secondChild ]
		ifFalse: [ parent firstChild ].
	grandParent
		ifNil: [
			root := sibling.
			sibling parent: nil ]
		ifNotNil: [
			grandParent firstChild == parent
				ifTrue: [ grandParent firstChild: sibling ]
				ifFalse: [ grandParent secondChild: sibling ].
			sibling parent: grandParent ].
	self releaseNode: parent.
	leaf parent: nil.
	ancestor := grandParent.
	[ ancestor notNil ] whileTrue: [
		self refit: ancestor.
		ancestor := ancestor parent ]
]

{ #category : 'private - balancing' }
CFPhysicsDynamicTree >> balance: nodeA [
	"Translate Box2D 3.1.1 b2RotateNodes:. Rotations are selected by AABB perimeter cost, not by height imbalance."
	| nodeB nodeC nodeD nodeE nodeF nodeG baseCost firstCost secondCost thirdCost fourthCost bestCost bestRotation merged |
	nodeA height < 2 ifTrue: [ ^ nodeA ].
	nodeB := nodeA firstChild.
	nodeC := nodeA secondChild.
	nodeB isLeaf ifTrue: [
		nodeF := nodeC firstChild.
		nodeG := nodeC secondChild.
		baseCost := nodeC aabb perimeter.
		firstCost := (nodeB aabb mergedWith: nodeG aabb) perimeter.
		secondCost := (nodeB aabb mergedWith: nodeF aabb) perimeter.
		(baseCost < firstCost and: [ baseCost < secondCost ]) ifTrue: [ ^ nodeA ].
		firstCost < secondCost
			ifTrue: [
				nodeA firstChild: nodeF.
				nodeC firstChild: nodeB.
				nodeB parent: nodeC.
				nodeF parent: nodeA ]
			ifFalse: [
				nodeA firstChild: nodeG.
				nodeC secondChild: nodeB.
				nodeB parent: nodeC.
				nodeG parent: nodeA ].
		self refit: nodeC.
		self refit: nodeA.
		rotationCount := rotationCount + 1.
		^ nodeA ].
	nodeC isLeaf ifTrue: [
		nodeD := nodeB firstChild.
		nodeE := nodeB secondChild.
		baseCost := nodeB aabb perimeter.
		firstCost := (nodeC aabb mergedWith: nodeE aabb) perimeter.
		secondCost := (nodeC aabb mergedWith: nodeD aabb) perimeter.
		(baseCost < firstCost and: [ baseCost < secondCost ]) ifTrue: [ ^ nodeA ].
		firstCost < secondCost
			ifTrue: [
				nodeA secondChild: nodeD.
				nodeB firstChild: nodeC.
				nodeC parent: nodeB.
				nodeD parent: nodeA ]
			ifFalse: [
				nodeA secondChild: nodeE.
				nodeB secondChild: nodeC.
				nodeC parent: nodeB.
				nodeE parent: nodeA ].
		self refit: nodeB.
		self refit: nodeA.
		rotationCount := rotationCount + 1.
		^ nodeA ].
	nodeD := nodeB firstChild.
	nodeE := nodeB secondChild.
	nodeF := nodeC firstChild.
	nodeG := nodeC secondChild.
	baseCost := nodeB aabb perimeter + nodeC aabb perimeter.
	firstCost := nodeB aabb perimeter + (nodeB aabb mergedWith: nodeG aabb) perimeter.
	secondCost := nodeB aabb perimeter + (nodeB aabb mergedWith: nodeF aabb) perimeter.
	thirdCost := nodeC aabb perimeter + (nodeC aabb mergedWith: nodeE aabb) perimeter.
	fourthCost := nodeC aabb perimeter + (nodeC aabb mergedWith: nodeD aabb) perimeter.
	bestCost := baseCost.
	bestRotation := #none.
	firstCost < bestCost ifTrue: [ bestCost := firstCost. bestRotation := #swapBWithF ].
	secondCost < bestCost ifTrue: [ bestCost := secondCost. bestRotation := #swapBWithG ].
	thirdCost < bestCost ifTrue: [ bestCost := thirdCost. bestRotation := #swapCWithD ].
	fourthCost < bestCost ifTrue: [ bestRotation := #swapCWithE ].
	bestRotation = #none ifTrue: [ ^ nodeA ].
	bestRotation = #swapBWithF ifTrue: [
		nodeA firstChild: nodeF.
		nodeC firstChild: nodeB.
		nodeB parent: nodeC.
		nodeF parent: nodeA ].
	bestRotation = #swapBWithG ifTrue: [
		nodeA firstChild: nodeG.
		nodeC secondChild: nodeB.
		nodeB parent: nodeC.
		nodeG parent: nodeA ].
	bestRotation = #swapCWithD ifTrue: [
		nodeA secondChild: nodeD.
		nodeB firstChild: nodeC.
		nodeC parent: nodeB.
		nodeD parent: nodeA ].
	bestRotation = #swapCWithE ifTrue: [
		nodeA secondChild: nodeE.
		nodeB secondChild: nodeC.
		nodeC parent: nodeB.
		nodeE parent: nodeA ].
	self refit: nodeB.
	self refit: nodeC.
	self refit: nodeA.
	rotationCount := rotationCount + 1.
	^ nodeA
]

{ #category : 'private - maintenance' }
CFPhysicsDynamicTree >> refit: aNode [
	aNode isLeaf ifTrue: [ ^ self ].
	aNode
		aabb: (aNode firstChild aabb mergedWith: aNode secondChild aabb);
		height: 1 + (aNode firstChild height max: aNode secondChild height)
]

{ #category : 'accessing' }
CFPhysicsDynamicTree >> root [ ^ root ]

{ #category : 'measurements' }
CFPhysicsDynamicTree >> proxyCount [ ^ proxyCount ]

{ #category : 'measurements' }
CFPhysicsDynamicTree >> allocatedNodeCount [
	^ nodes count: [ :node | node isAllocated ]
]

{ #category : 'measurements' }
CFPhysicsDynamicTree >> pooledNodeCount [ ^ freeNodes size ]

{ #category : 'measurements' }
CFPhysicsDynamicTree >> height [ ^ root ifNil: [ 0 ] ifNotNil: [ root height ] ]

{ #category : 'measurements' }
CFPhysicsDynamicTree >> queryVisitCount [ ^ queryVisitCount ]


{ #category : 'validation' }
CFPhysicsDynamicTree >> validate [
	root ifNil: [
		self assert: proxyCount = 0.
		^ true ].
	self assert: root parent isNil.
	self assert: (self validateNode: root) = root height.
	self assert: (self leafCountBelow: root) = proxyCount.
	^ true
]

{ #category : 'private - validation' }
CFPhysicsDynamicTree >> validateNode: aNode [
	| firstHeight secondHeight merged |
	aNode isLeaf ifTrue: [
		self assert: aNode height = 0.
		self assert: aNode firstChild isNil.
		self assert: aNode secondChild isNil.
		^ 0 ].
	self assert: aNode firstChild notNil.
	self assert: aNode secondChild notNil.
	self assert: aNode firstChild parent == aNode.
	self assert: aNode secondChild parent == aNode.
	firstHeight := self validateNode: aNode firstChild.
	secondHeight := self validateNode: aNode secondChild.
	self assert: aNode height = (1 + (firstHeight max: secondHeight)).
	merged := aNode firstChild aabb mergedWith: aNode secondChild aabb.
	self assert: aNode aabb minimum equals: merged minimum.
	self assert: aNode aabb maximum equals: merged maximum.
	^ aNode height
]

{ #category : 'private - validation' }
CFPhysicsDynamicTree >> leafCountBelow: aNode [
	aNode isLeaf ifTrue: [ ^ 1 ].
	^ (self leafCountBelow: aNode firstChild) + (self leafCountBelow: aNode secondChild)
]

{ #category : 'measurements' }
CFPhysicsDynamicTree >> queryLeafVisitCount [ ^ queryLeafVisitCount ]

{ #category : 'measurements' }
CFPhysicsDynamicTree >> areaRatio [
	"Answer the sum of internal-node perimeters divided by the root perimeter,
	matching b2DynamicTree_GetAreaRatio in Box2D 3.1.1."
	| rootPerimeter totalPerimeter |
	root ifNil: [ ^ 0.0 ].
	rootPerimeter := root aabb perimeter.
	rootPerimeter = 0.0 ifTrue: [ ^ 0.0 ].
	totalPerimeter := nodes inject: 0.0 into: [ :sum :node |
		(node isAllocated and: [ node isLeaf not and: [ node ~~ root ] ])
			ifTrue: [ sum + node aabb perimeter ]
			ifFalse: [ sum ] ].
	^ totalPerimeter / rootPerimeter
]

{ #category : 'measurements' }
CFPhysicsDynamicTree >> rotationCount [ ^ rotationCount ]
