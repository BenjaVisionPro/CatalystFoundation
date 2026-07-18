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
	^ first aabb overlaps: second aabb
]
