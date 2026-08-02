"
I maintain persistent solver islands using the union-find and deferred-merge model used by Box2D 3.1.1.

Non-static bodies own an island. Linking a touching contact or joint joins the roots using parentIsland links. mergeIslands performs path compression, merges child islands into their roots, and updates every body's island mapping. Removing a constraint marks its island for a later split rather than rebuilding all islands immediately.
"

Class {
	#name : 'CFPhysicsPersistentIslandGraph',
	#superclass : 'Object',
	#instVars : [ 'islands', 'islandByBody', 'islandByConstraint', 'nextIdentifier' ],
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
}

{ #category : 'initialization' }
CFPhysicsPersistentIslandGraph >> initialize [
	super initialize.
	islands := OrderedCollection new.
	islandByBody := IdentityDictionary new.
	islandByConstraint := IdentityDictionary new.
	nextIdentifier := 1
]

{ #category : 'accessing' }
CFPhysicsPersistentIslandGraph >> islands [
	^ islands asArray
]

{ #category : 'accessing' }
CFPhysicsPersistentIslandGraph >> islandForBody: aBody [
	^ islandByBody at: aBody ifAbsent: [ nil ]
]

{ #category : 'accessing' }
CFPhysicsPersistentIslandGraph >> islandForConstraint: aConstraint [
	^ islandByConstraint at: aConstraint ifAbsent: [ nil ]
]

{ #category : 'body lifecycle' }
CFPhysicsPersistentIslandGraph >> addBody: aBody [
	| island |
	aBody isStatic ifTrue: [ ^ nil ].
	(islandByBody includesKey: aBody) ifTrue: [ ^ islandByBody at: aBody ].
	island := CFPhysicsIsland new
		identifier: nextIdentifier;
		addBody: aBody;
		yourself.
	nextIdentifier := nextIdentifier + 1.
	islands add: island.
	islandByBody at: aBody put: island.
	^ island
]

{ #category : 'linking' }
CFPhysicsPersistentIslandGraph >> linkConstraint: aConstraint [
	| bodyA bodyB islandA islandB rootA rootB target |
	(islandByConstraint includesKey: aConstraint) ifTrue: [ ^ self islandForConstraint: aConstraint ].
	bodyA := aConstraint bodyA.
	bodyB := aConstraint bodyB.
	islandA := bodyA ifNil: [ nil ] ifNotNil: [ self addBody: bodyA ].
	islandB := bodyB ifNil: [ nil ] ifNotNil: [ self addBody: bodyB ].
	rootA := islandA ifNil: [ nil ] ifNotNil: [ self rootOf: islandA ].
	rootB := islandB ifNil: [ nil ] ifNotNil: [ self rootOf: islandB ].
	target := rootA ifNil: [ rootB ].
	target ifNil: [ ^ nil ].
	(rootA notNil and: [ rootB notNil and: [ rootA ~~ rootB ] ]) ifTrue: [
		"Box2D links the second root to the first root and merges awake islands later."
		rootB parentIsland: rootA ].
	target addConstraint: aConstraint.
	islandByConstraint at: aConstraint put: target.
	^ target
]

{ #category : 'merging' }
CFPhysicsPersistentIslandGraph >> mergeIslands [
	| children |
	"First compress every parent chain so each child points directly at its root."
	islands do: [ :island |
		| root |
		root := self rootOf: island.
		root == island ifFalse: [ island parentIsland: root ] ].
	children := islands select: [ :island | island parentIsland notNil ].
	children reverseDo: [ :child |
		| root |
		root := child parentIsland.
		root mergeFrom: child.
		child bodies do: [ :body | islandByBody at: body put: root ].
		child constraints do: [ :constraint | islandByConstraint at: constraint put: root ].
		islands remove: child ifAbsent: [ ].
		child parentIsland: nil ].
	^ self islands
]

{ #category : 'private' }
CFPhysicsPersistentIslandGraph >> rootOf: anIsland [
	| island parent |
	island := anIsland.
	[ island parentIsland notNil ] whileTrue: [
		parent := island parentIsland.
		parent parentIsland ifNotNil: [ island parentIsland: parent parentIsland ].
		island := parent ].
	^ island
]

{ #category : 'unlinking' }
CFPhysicsPersistentIslandGraph >> unlinkConstraint: aConstraint [
	| island |
	island := islandByConstraint removeKey: aConstraint ifAbsent: [ ^ self ].
	island := self rootOf: island.
	island removeConstraint: aConstraint
]
