"
I am a persistent dynamic AABB tree translated from the Box2D 3.1.1 broad-phase structure.

I retain leaf proxies between simulation steps. Moving a proxy only removes and reinserts its leaf when the existing fat AABB no longer contains the supplied bounds. Queries visit only tree nodes whose AABBs overlap the query bounds.

My node pool reuses released node objects. Query result ordering is made deterministic by proxy identifier rather than depending on tree shape.
"
Class {
	#name : 'CFPhysicsDynamicTree',
	#superclass : 'Object',
	#instVars : [ 'root', 'nodes', 'freeNodes', 'nextNodeIdentifier', 'proxyCount', 'queryVisitCount' ],
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
	queryVisitCount := 0
]

{ #category : 'proxies' }
CFPhysicsDynamicTree >> createProxyFor: anObject aabb: anAABB [
	| leaf |
	leaf := self allocateNode.
	leaf
		aabb: anAABB;
		userData: anObject;
		height: 0.
	self insertLeaf: leaf.
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
	self insertLeaf: aLeaf.
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
CFPhysicsDynamicTree >> insertLeaf: leaf [
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
		ancestor := self balance: ancestor.
		self refit: ancestor.
		ancestor := ancestor parent ]
]

{ #category : 'private - insertion' }
CFPhysicsDynamicTree >> bestSiblingFor: anAABB [
	| node first second firstCost secondCost |
	node := root.
	[ node isLeaf ] whileFalse: [
		first := node firstChild.
		second := node secondChild.
		firstCost := self insertionCostOf: anAABB beneath: first.
		secondCost := self insertionCostOf: anAABB beneath: second.
		firstCost = secondCost
			ifTrue: [ node := first identifier < second identifier ifTrue: [ first ] ifFalse: [ second ] ]
			ifFalse: [ node := firstCost < secondCost ifTrue: [ first ] ifFalse: [ second ] ] ].
	^ node
]

{ #category : 'private - insertion' }
CFPhysicsDynamicTree >> insertionCostOf: anAABB beneath: aNode [
	| mergedCost existingCost |
	mergedCost := (aNode aabb mergedWith: anAABB) perimeter.
	aNode isLeaf ifTrue: [ ^ mergedCost ].
	existingCost := aNode aabb perimeter.
	^ mergedCost - existingCost
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
		ancestor := self balance: ancestor.
		self refit: ancestor.
		ancestor := ancestor parent ]
]

{ #category : 'private - balancing' }
CFPhysicsDynamicTree >> balance: nodeA [
	| nodeB nodeC difference nodeF nodeG oldParent |
	(nodeA isLeaf or: [ nodeA height < 2 ]) ifTrue: [ ^ nodeA ].
	nodeB := nodeA firstChild.
	nodeC := nodeA secondChild.
	difference := nodeC height - nodeB height.
	difference > 1 ifTrue: [
		nodeF := nodeC firstChild.
		nodeG := nodeC secondChild.
		oldParent := nodeA parent.
		nodeC parent: oldParent.
		oldParent
			ifNil: [ root := nodeC ]
			ifNotNil: [ oldParent firstChild == nodeA
				ifTrue: [ oldParent firstChild: nodeC ]
				ifFalse: [ oldParent secondChild: nodeC ] ].
		nodeC firstChild: nodeA.
		nodeA parent: nodeC.
		nodeF height > nodeG height
			ifTrue: [
				nodeC secondChild: nodeF.
				nodeA secondChild: nodeG.
				nodeG parent: nodeA ]
			ifFalse: [
				nodeC secondChild: nodeG.
				nodeA secondChild: nodeF.
				nodeF parent: nodeA ].
		self refit: nodeA.
		self refit: nodeC.
		^ nodeC ].
	difference < -1 ifTrue: [
		nodeF := nodeB firstChild.
		nodeG := nodeB secondChild.
		oldParent := nodeA parent.
		nodeB parent: oldParent.
		oldParent
			ifNil: [ root := nodeB ]
			ifNotNil: [ oldParent firstChild == nodeA
				ifTrue: [ oldParent firstChild: nodeB ]
				ifFalse: [ oldParent secondChild: nodeB ] ].
		nodeB firstChild: nodeA.
		nodeA parent: nodeB.
		nodeF height > nodeG height
			ifTrue: [
				nodeB secondChild: nodeF.
				nodeA firstChild: nodeG.
				nodeG parent: nodeA ]
			ifFalse: [
				nodeB secondChild: nodeG.
				nodeA firstChild: nodeF.
				nodeF parent: nodeA ].
		self refit: nodeA.
		self refit: nodeB.
		^ nodeB ].
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
