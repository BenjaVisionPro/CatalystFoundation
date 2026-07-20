Class {
	#name : 'CFPhysicsIslandBuilder',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'building' }
CFPhysicsIslandBuilder >> islandsFromBodies: bodies constraints: constraints [
	| orderedBodies constraintsByBody visited islands |
	orderedBodies := bodies asArray sorted: [ :left :right | left sequence < right sequence ].
	constraintsByBody := self constraintsByBodyFrom: constraints.
	visited := IdentitySet new.
	islands := OrderedCollection new.
	orderedBodies do: [ :body |
		(body isDynamic and: [ (visited includes: body) not ]) ifTrue: [
			islands add: (self
				islandFrom: body
				constraintsByBody: constraintsByBody
				visitedDynamicBodies: visited) ] ].
	^ islands asArray
]

{ #category : 'private - building' }
CFPhysicsIslandBuilder >> constraintsByBodyFrom: constraints [
	| result |
	result := IdentityDictionary new.
	constraints do: [ :constraint |
		self add: constraint for: constraint firstBody to: result.
		self add: constraint for: constraint secondBody to: result ].
	^ result
]

{ #category : 'private - building' }
CFPhysicsIslandBuilder >> add: constraint for: body to: constraintsByBody [
	(constraintsByBody at: body ifAbsentPut: [ OrderedCollection new ]) add: constraint
]

{ #category : 'private - building' }
CFPhysicsIslandBuilder >> islandFrom: seed constraintsByBody: constraintsByBody visitedDynamicBodies: visited [
	| island pending visitedConstraints |
	island := CFPhysicsIsland new.
	pending := OrderedCollection with: seed.
	visitedConstraints := IdentitySet new.
	[ pending isEmpty ] whileFalse: [
		| body |
		body := pending removeFirst.
		(visited includes: body) ifFalse: [
			visited add: body.
			island addBody: body.
			(constraintsByBody at: body ifAbsent: [ #() ]) do: [ :constraint |
				(visitedConstraints includes: constraint) ifFalse: [
					| first second |
					visitedConstraints add: constraint.
					island addConstraint: constraint.
					first := constraint firstBody.
					second := constraint secondBody.
					island addBody: first.
					island addBody: second.
					(first isDynamic and: [ (visited includes: first) not ]) ifTrue: [ pending add: first ].
					(second isDynamic and: [ (visited includes: second) not ]) ifTrue: [ pending add: second ] ] ] ] ].
	^ island
]
