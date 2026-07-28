Class {
	#name : 'CFPhysicsPairFinder',
	#superclass : 'Object',
	#instVars : [ 'entryCount', 'comparisonCount', 'acceptedPairCount', 'maximumActiveCount' ],
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'finding' }
CFPhysicsPairFinder >> pairsAmong: bodies [
	| entries active pairs |
	self resetMeasurements.
	entries := (bodies collect: [ :body | { body. body sweptAABB. body sequence } ]) asArray.
	entries := self entriesSortedByMinimumX: entries.
	entryCount := entries size.
	active := OrderedCollection new: entries size.
	pairs := OrderedCollection new: entries size.
	entries do: [ :entry |
		self expireEntriesBefore: entry second minimum x from: active.
		active do: [ :other |
			comparisonCount := comparisonCount + 1.
			(self
				shouldConsider: other first
				with: entry first
				firstAABB: other second
				secondAABB: entry second) ifTrue: [
					pairs add: (CFPhysicsPair first: other first second: entry first).
					acceptedPairCount := acceptedPairCount + 1 ] ].
		active add: entry.
		maximumActiveCount := maximumActiveCount max: active size ].
	^ pairs asArray sorted: [ :left :right | left comesBefore: right ]
]


{ #category : 'initialization' }
CFPhysicsPairFinder >> initialize [
	super initialize.
	self resetMeasurements
]

{ #category : 'private - measurements' }
CFPhysicsPairFinder >> resetMeasurements [
	entryCount := 0.
	comparisonCount := 0.
	acceptedPairCount := 0.
	maximumActiveCount := 0
]

{ #category : 'measurements' }
CFPhysicsPairFinder >> entryCount [ ^ entryCount ]

{ #category : 'measurements' }
CFPhysicsPairFinder >> comparisonCount [ ^ comparisonCount ]

{ #category : 'measurements' }
CFPhysicsPairFinder >> acceptedPairCount [ ^ acceptedPairCount ]

{ #category : 'measurements' }
CFPhysicsPairFinder >> maximumActiveCount [ ^ maximumActiveCount ]


{ #category : 'finding' }
CFPhysicsPairFinder >> pairsAmongSolvedStepStates: stepStates [
	^ self pairsAmongSolvedStepStates: stepStates collisionSuppressedBodyPairs: #()
]

{ #category : 'finding' }
CFPhysicsPairFinder >> pairsAmongSolvedStepStates: stepStates collisionSuppressedBodyPairs: collisionSuppressedBodyPairs [
	| entries active pairs |
	self resetMeasurements.
	entries := (stepStates collect: [ :state |
		{ state. state solvedSweptAABB. state body sequence } ]) asArray.
	entries := self entriesSortedByMinimumX: entries.
	entryCount := entries size.
	active := OrderedCollection new: entries size.
	pairs := OrderedCollection new: entries size.
	entries do: [ :entry |
		self expireEntriesBefore: entry second minimum x from: active.
		active do: [ :other |
			comparisonCount := comparisonCount + 1.
			(self
				shouldConsiderStepState: other first
				with: entry first
				firstAABB: other second
				secondAABB: entry second
				collisionSuppressedBodyPairs: collisionSuppressedBodyPairs) ifTrue: [
				pairs add: (CFPhysicsPair first: other first body second: entry first body).
				acceptedPairCount := acceptedPairCount + 1 ] ].
		active add: entry.
		maximumActiveCount := maximumActiveCount max: active size ].
	^ pairs asArray sorted: [ :left :right | left comesBefore: right ]
]

{ #category : 'testing' }
CFPhysicsPairFinder >> shouldConsider: first with: second [
	^ self
		shouldConsider: first
		with: second
		firstAABB: first sweptAABB
		secondAABB: second sweptAABB
]

{ #category : 'testing' }
CFPhysicsPairFinder >> shouldConsider: first with: second firstAABB: firstAABB secondAABB: secondAABB [
	(first formsCollisionPairWith: second) ifFalse: [ ^ false ].
	(first allowsCollisionWith: second) ifFalse: [ ^ false ].
	(self jointPreventsCollisionBetween: first and: second) ifTrue: [ ^ false ].
	^ firstAABB overlaps: secondAABB
]

{ #category : 'finding' }
CFPhysicsPairFinder >> pairsAmongStepStates: stepStates for: seconds [
	| bodyPairs |
	bodyPairs := stepStates collect: [ :state | state body ].
	^ self
		pairsAmongStepStates: stepStates
		for: seconds
		collisionSuppressedBodyPairs: (self collisionSuppressedBodyPairsAmong: bodyPairs)
]

{ #category : 'finding' }
CFPhysicsPairFinder >> pairsAmongStepStates: stepStates for: seconds collisionSuppressedBodyPairs: collisionSuppressedBodyPairs [
	| entries active pairs |
	entries := (stepStates collect: [ :state |
		{ state. state predictedSweptAABBFor: seconds. state body sequence } ]) asArray.
	entries := self entriesSortedByMinimumX: entries.
	active := OrderedCollection new: entries size.
	pairs := OrderedCollection new: entries size.
	entries do: [ :entry |
		self expireEntriesBefore: entry second minimum x from: active.
		active do: [ :other |
			(self
				shouldConsiderStepState: other first
				with: entry first
				firstAABB: other second
				secondAABB: entry second
				collisionSuppressedBodyPairs: collisionSuppressedBodyPairs) ifTrue: [
					pairs add: (CFPhysicsPair first: other first body second: entry first body) ] ].
		active add: entry ].
	^ pairs asArray sorted: [ :left :right | left comesBefore: right ]
]

{ #category : 'testing' }
CFPhysicsPairFinder >> shouldConsiderStepState: first with: second for: seconds [
	^ self
		shouldConsiderStepState: first
		with: second
		firstAABB: (first predictedSweptAABBFor: seconds)
		secondAABB: (second predictedSweptAABBFor: seconds)
]

{ #category : 'testing' }
CFPhysicsPairFinder >> shouldConsiderStepState: first with: second firstAABB: firstAABB secondAABB: secondAABB [
	(first formsCollisionPairWith: second) ifFalse: [ ^ false ].
	(first allowsCollisionWith: second) ifFalse: [ ^ false ].
	(self jointPreventsCollisionBetween: first body and: second body) ifTrue: [ ^ false ].
	^ firstAABB overlaps: secondAABB
]

{ #category : 'testing' }
CFPhysicsPairFinder >> shouldConsiderStepState: first with: second firstAABB: firstAABB secondAABB: secondAABB collisionSuppressedBodyPairs: collisionSuppressedBodyPairs [
	(first formsCollisionPairWith: second) ifFalse: [ ^ false ].
	(first allowsCollisionWith: second) ifFalse: [ ^ false ].
	(self
		collisionSuppressedBetween: first body
		and: second body
		in: collisionSuppressedBodyPairs) ifTrue: [ ^ false ].
	^ firstAABB overlaps: secondAABB
]

{ #category : 'private - filtering' }
CFPhysicsPairFinder >> collisionSuppressedBetween: firstBody and: secondBody in: bodyPairs [
	^ bodyPairs anySatisfy: [ :bodyPair |
		(bodyPair first == firstBody and: [ bodyPair second == secondBody ]) or: [
			bodyPair first == secondBody and: [ bodyPair second == firstBody ] ] ]
]


{ #category : 'private - sweep' }
CFPhysicsPairFinder >> expireEntriesBefore: minimumX from: activeEntries [
	activeEntries size to: 1 by: -1 do: [ :index |
		((activeEntries at: index) second maximum x < minimumX) ifTrue: [
			activeEntries removeAt: index ] ]
]


{ #category : 'private - filtering' }
CFPhysicsPairFinder >> collisionSuppressedBodyPairsAmong: bodies [
	bodies ifEmpty: [ ^ #() ].
	^ bodies first world
		ifNil: [ #() ]
		ifNotNil: [ :world | world collisionSuppressedBodyPairs ]
]

{ #category : 'private - filtering' }
CFPhysicsPairFinder >> jointPreventsCollisionBetween: firstBody and: secondBody [
	| world |
	world := firstBody world.
	(world isNil or: [ world ~~ secondBody world ]) ifTrue: [ ^ false ].
	^ world jointPreventsCollisionBetween: firstBody and: secondBody
]

{ #category : 'private - ordering' }
CFPhysicsPairFinder >> entriesSortedByMinimumX: entries [
	^ entries sorted: [ :left :right |
		left second minimum x = right second minimum x
			ifTrue: [ left third < right third ]
			ifFalse: [ left second minimum x < right second minimum x ] ]
]
