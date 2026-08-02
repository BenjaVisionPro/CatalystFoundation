"
I am one node in a CFPhysicsDynamicTree.

Leaf nodes carry proxy data. Internal nodes carry two children and the union of their bounds. Nodes are retained by the tree's pool and reset when released so proxy insertion and removal do not continually allocate replacement node objects.
"
Class {
	#name : 'CFPhysicsDynamicTreeNode',
	#superclass : 'Object',
	#instVars : [ 'identifier', 'aabb', 'parent', 'firstChild', 'secondChild', 'height', 'userData', 'allocated', 'enlarged' ],
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
}

{ #category : 'initialization' }
CFPhysicsDynamicTreeNode >> initialize [
	super initialize.
	self reset
]

{ #category : 'initialization' }
CFPhysicsDynamicTreeNode >> reset [
	aabb := nil.
	parent := nil.
	firstChild := nil.
	secondChild := nil.
	height := -1.
	userData := nil.
	allocated := false.
	enlarged := false
]

{ #category : 'allocation' }
CFPhysicsDynamicTreeNode >> allocate [
	allocated := true.
	enlarged := false.
	height := 0
]

{ #category : 'testing' }
CFPhysicsDynamicTreeNode >> isAllocated [ ^ allocated ]

{ #category : 'testing' }
CFPhysicsDynamicTreeNode >> isLeaf [ ^ allocated and: [ firstChild isNil ] ]

{ #category : 'accessing' }
CFPhysicsDynamicTreeNode >> identifier [ ^ identifier ]

{ #category : 'accessing' }
CFPhysicsDynamicTreeNode >> identifier: anInteger [ identifier := anInteger ]

{ #category : 'accessing' }
CFPhysicsDynamicTreeNode >> aabb [ ^ aabb ]

{ #category : 'accessing' }
CFPhysicsDynamicTreeNode >> aabb: anAABB [ aabb := anAABB ]

{ #category : 'accessing' }
CFPhysicsDynamicTreeNode >> parent [ ^ parent ]

{ #category : 'accessing' }
CFPhysicsDynamicTreeNode >> parent: aNode [ parent := aNode ]

{ #category : 'accessing' }
CFPhysicsDynamicTreeNode >> firstChild [ ^ firstChild ]

{ #category : 'accessing' }
CFPhysicsDynamicTreeNode >> firstChild: aNode [ firstChild := aNode ]

{ #category : 'accessing' }
CFPhysicsDynamicTreeNode >> secondChild [ ^ secondChild ]

{ #category : 'accessing' }
CFPhysicsDynamicTreeNode >> secondChild: aNode [ secondChild := aNode ]

{ #category : 'accessing' }
CFPhysicsDynamicTreeNode >> height [ ^ height ]

{ #category : 'accessing' }
CFPhysicsDynamicTreeNode >> height: anInteger [ height := anInteger ]

{ #category : 'accessing' }
CFPhysicsDynamicTreeNode >> userData [ ^ userData ]

{ #category : 'accessing' }
CFPhysicsDynamicTreeNode >> userData: anObject [ userData := anObject ]


{ #category : 'testing' }
CFPhysicsDynamicTreeNode >> isEnlarged [ ^ enlarged ]

{ #category : 'accessing' }
CFPhysicsDynamicTreeNode >> enlarged: aBoolean [ enlarged := aBoolean ]
