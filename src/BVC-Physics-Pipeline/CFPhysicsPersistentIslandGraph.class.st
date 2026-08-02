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
	islandByConstraint := Dictionary new.
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
	^ islandByConstraint at: (self keyForConstraint: aConstraint) ifAbsent: [ nil ]
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
	(islandByConstraint includesKey: (self keyForConstraint: aConstraint)) ifTrue: [ ^ self islandForConstraint: aConstraint ].
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
	islandByConstraint at: (self keyForConstraint: aConstraint) put: target.
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
		child constraints do: [ :constraint | islandByConstraint at: (self keyForConstraint: constraint) put: root ].
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
	| key island storedConstraint |
	key := self keyForConstraint: aConstraint.
	island := islandByConstraint removeKey: key ifAbsent: [ ^ self ].
	island := self rootOf: island.
	storedConstraint := island constraints
		detect: [ :each | (self keyForConstraint: each) = key ]
		ifNone: [ nil ].
	storedConstraint ifNotNil: [ island removeConstraint: storedConstraint ]
]


{ #category : 'private' }
CFPhysicsPersistentIslandGraph >> keyForConstraint: aConstraint [
	"Contacts are recreated or reused across step buffers, so their stable pair key identifies the persistent edge. Runtime joints retain identity."
	^ (aConstraint isKindOf: CFPhysicsContact)
		ifTrue: [ { #contact. aConstraint key } ]
		ifFalse: [ aConstraint ]
]

{ #category : 'body lifecycle' }
CFPhysicsPersistentIslandGraph >> removeBody: aBody [
	| island |
	island := islandByBody removeKey: aBody ifAbsent: [ ^ self ].
	island := self rootOf: island.
	island removeBody: aBody.
	island bodies isEmpty ifTrue: [ islands remove: island ifAbsent: [ ] ]
]

{ #category : 'solver snapshots' }
CFPhysicsPersistentIslandGraph >> solverBodyGroups [
	"Answer a detached, deterministic snapshot of the non-static body membership of each persistent island. The pipeline may consume this snapshot on a background process without reading or mutating the world-owned graph."
	self mergeIslands.
	^ (islands asArray sorted: [ :left :right | left identifier < right identifier ])
		collect: [ :island |
			island bodies asArray sorted: [ :left :right | left sequence < right sequence ] ]
]



{ #category : 'splitting' }
CFPhysicsPersistentIslandGraph >> splitIsland: anIsland [
	"Split one persistent island by traversing only its remaining runtime constraints. This is the direct Catalyst equivalent of b2SplitIsland in Box2D 3.1.1. Static bodies remain constraint endpoints but never become persistent island members."
	| baseIsland orderedBodies activeConstraints constraintsByBody visitedBodies visitedConstraints newIslands |
	baseIsland := self rootOf: anIsland.
	baseIsland constraintRemoveCount = 0 ifTrue: [ ^ { baseIsland } ].
	orderedBodies := baseIsland bodies asArray sorted: [ :left :right | left sequence < right sequence ].
	activeConstraints := baseIsland constraints select: [ :constraint |
		| mappedIsland |
		mappedIsland := islandByConstraint at: (self keyForConstraint: constraint) ifAbsent: [ nil ].
		mappedIsland notNil and: [ (self rootOf: mappedIsland) == baseIsland ] ].
	constraintsByBody := IdentityDictionary new.
	activeConstraints do: [ :constraint |
		constraint bodyA ifNotNil: [ :body |
			body isStatic ifFalse: [ self addConstraint: constraint forBody: body to: constraintsByBody ] ].
		constraint bodyB ifNotNil: [ :body |
			body isStatic ifFalse: [ self addConstraint: constraint forBody: body to: constraintsByBody ] ] ].
	islands remove: baseIsland ifAbsent: [ ].
	visitedBodies := IdentitySet new.
	visitedConstraints := Set new.
	newIslands := OrderedCollection new.
	orderedBodies do: [ :seed |
		(visitedBodies includes: seed) ifFalse: [
			| island pending |
			island := CFPhysicsIsland new
				identifier: nextIdentifier;
				yourself.
			nextIdentifier := nextIdentifier + 1.
			pending := OrderedCollection with: seed.
			visitedBodies add: seed.
			[ pending isEmpty ] whileFalse: [
				| body |
				body := pending removeLast.
				island addBody: body.
				islandByBody at: body put: island.
				(constraintsByBody at: body ifAbsent: [ #() ]) do: [ :constraint |
					| key other |
					key := self keyForConstraint: constraint.
					(visitedConstraints includes: key) ifFalse: [
						visitedConstraints add: key.
						island addConstraint: constraint.
						islandByConstraint at: key put: island ].
					other := constraint bodyA == body
						ifTrue: [ constraint bodyB ]
						ifFalse: [ constraint bodyA ].
					(other notNil and: [ other isStatic not and: [ (visitedBodies includes: other) not ] ]) ifTrue: [
						visitedBodies add: other.
						pending add: other ] ] ].
			islands add: island.
			newIslands add: island ] ].
	^ newIslands asArray
]

{ #category : 'private - splitting' }
CFPhysicsPersistentIslandGraph >> addConstraint: aConstraint forBody: aBody to: constraintsByBody [
	(constraintsByBody at: aBody ifAbsentPut: [ OrderedCollection new ]) add: aConstraint
]


{ #category : 'splitting' }
CFPhysicsPersistentIslandGraph >> splitSleepiestIslandEligibleAt: minimumSleepTime [
	"Split at most one dirty island, matching Box2D 3.1.1 finalisation scheduling. A body whose sleep time has reached the threshold may nominate its dirty island; the island containing the sleepiest eligible body wins."
	| candidate candidateSleepTime |
	self mergeIslands.
	candidate := nil.
	candidateSleepTime := 0.0.
	islands do: [ :island |
		island constraintRemoveCount > 0 ifTrue: [
			island bodies do: [ :body |
				| sleepTime |
				sleepTime := body sleepTime.
				(sleepTime >= minimumSleepTime and: [ sleepTime > candidateSleepTime ]) ifTrue: [
					candidate := island.
					candidateSleepTime := sleepTime ] ] ] ].
	candidate ifNil: [ ^ #() ].
	^ self splitIsland: candidate
]
