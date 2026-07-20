Class {
	#name : 'CFPhysicsPairFinder',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'finding' }
CFPhysicsPairFinder >> pairsAmong: bodies [
	| ordered pairs |
	ordered := bodies asArray sorted: [ :left :right | left sequence < right sequence ].
	pairs := OrderedCollection new.
	1 to: ordered size do: [ :firstIndex |
		firstIndex + 1 to: ordered size do: [ :secondIndex |
			| first second |
			first := ordered at: firstIndex.
			second := ordered at: secondIndex.
			(self shouldConsider: first with: second) ifTrue: [
				pairs add: (CFPhysicsPair first: first second: second) ] ] ].
	^ pairs asArray
]

{ #category : 'testing' }
CFPhysicsPairFinder >> shouldConsider: first with: second [
	(first isStatic and: [ second isStatic ]) ifTrue: [ ^ false ].
	(first allowsCollisionWith: second) ifFalse: [ ^ false ].
	^ first sweptAABB overlaps: second sweptAABB
]

{ #category : 'finding' }
CFPhysicsPairFinder >> pairsAmongStepStates: stepStates for: seconds [
	| ordered pairs |
	ordered := stepStates asArray sorted: [ :left :right |
		left body sequence < right body sequence ].
	pairs := OrderedCollection new.
	1 to: ordered size do: [ :firstIndex |
		firstIndex + 1 to: ordered size do: [ :secondIndex |
			| first second |
			first := ordered at: firstIndex.
			second := ordered at: secondIndex.
			(self shouldConsiderStepState: first with: second for: seconds) ifTrue: [
				pairs add: (CFPhysicsPair first: first body second: second body) ] ] ].
	^ pairs asArray
]

{ #category : 'testing' }
CFPhysicsPairFinder >> shouldConsiderStepState: first with: second for: seconds [
	| firstBody secondBody |
	firstBody := first body.
	secondBody := second body.
	(firstBody isStatic and: [ secondBody isStatic ]) ifTrue: [ ^ false ].
	(firstBody allowsCollisionWith: secondBody) ifFalse: [ ^ false ].
	^ (first predictedSweptAABBFor: seconds) overlaps:
		(second predictedSweptAABBFor: seconds)
]
