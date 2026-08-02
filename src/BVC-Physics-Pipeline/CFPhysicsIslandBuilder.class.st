"
I materialise deterministic solver islands from detached persistent body groups and the prepared constraints for the current step.

Persistent connectivity belongs to CFPhysicsPersistentIslandGraph. I do not rebuild the world contact graph.
"

Class {
	#name : 'CFPhysicsIslandBuilder',
	#superclass : 'Object',
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
}

{ #category : 'building - persistent islands' }
CFPhysicsIslandBuilder >> islandsFromPersistentBodyGroups: bodyGroups bodies: bodies constraints: constraints [
	"Build the current solver islands from the detached persistent body groups. Current prepared constraints may join groups that were created during this solve and have not yet been committed to the world-owned graph. Removed constraints deliberately do not split a persistent group here; Box2D defers that work."
	| groupByBody parent constraintsByRoot islandsByRoot orderedGroups |
	groupByBody := IdentityDictionary new.
	parent := IdentityDictionary new.
	orderedGroups := bodyGroups asArray.
	orderedGroups doWithIndex: [ :group :index |
		parent at: index put: index.
		group do: [ :body | groupByBody at: body put: index ] ].

	"Bodies captured before their persistent registration still receive a deterministic singleton group."
	(bodies asArray sorted: [ :left :right | left sequence < right sequence ]) do: [ :body |
		(body isStatic not and: [ (groupByBody includesKey: body) not ]) ifTrue: [
			| index |
			index := parent size + 1.
			parent at: index put: index.
			groupByBody at: body put: index.
			orderedGroups := orderedGroups copyWith: { body } ] ].

	constraints do: [ :constraint |
		| groupA groupB |
		groupA := constraint bodyA ifNil: [ nil ] ifNotNil: [ :body | groupByBody at: body ifAbsent: [ nil ] ].
		groupB := constraint bodyB ifNil: [ nil ] ifNotNil: [ :body | groupByBody at: body ifAbsent: [ nil ] ].
		(groupA notNil and: [ groupB notNil ]) ifTrue: [
			self union: groupA with: groupB parents: parent ] ].

	islandsByRoot := Dictionary new.
	orderedGroups doWithIndex: [ :group :index |
		| root island |
		root := self rootOfIndex: index parents: parent.
		island := islandsByRoot at: root ifAbsentPut: [ CFPhysicsIsland new ].
		group do: [ :body | island addBody: body ] ].

	constraints do: [ :constraint |
		| body root island |
		body := constraint bodyA.
		(body isNil or: [ body isStatic ]) ifTrue: [ body := constraint bodyB ].
		body ifNotNil: [
			root := groupByBody at: body ifAbsent: [ nil ].
			root ifNotNil: [
				root := self rootOfIndex: root parents: parent.
				island := islandsByRoot at: root.
				island addConstraint: constraint.
				constraint bodyA ifNotNil: [ :endpoint | island addBody: endpoint ].
				constraint bodyB ifNotNil: [ :endpoint | island addBody: endpoint ] ] ] ].

	^ (islandsByRoot associations sorted: [ :left :right | left key < right key ])
		collect: [ :association | association value ]
]

{ #category : 'private - persistent islands' }
CFPhysicsIslandBuilder >> rootOfIndex: anIndex parents: parents [
	| index parentIndex |
	index := anIndex.
	[ (parentIndex := parents at: index) = index ] whileFalse: [
		(parents at: parentIndex) = parentIndex ifFalse: [
			parents at: index put: (parents at: parentIndex) ].
		index := parentIndex ].
	^ index
]

{ #category : 'private - persistent islands' }
CFPhysicsIslandBuilder >> union: firstIndex with: secondIndex parents: parents [
	| firstRoot secondRoot |
	firstRoot := self rootOfIndex: firstIndex parents: parents.
	secondRoot := self rootOfIndex: secondIndex parents: parents.
	firstRoot = secondRoot ifTrue: [ ^ self ].
	"Use the lower captured island index as the root so solver ordering is deterministic."
	firstRoot < secondRoot
		ifTrue: [ parents at: secondRoot put: firstRoot ]
		ifFalse: [ parents at: firstRoot put: secondRoot ]
]

