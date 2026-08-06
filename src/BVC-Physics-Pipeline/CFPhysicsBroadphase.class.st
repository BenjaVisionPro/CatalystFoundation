"
I am the persistent broadphase translated from Box2D 3.1.1.

I own one dynamic AABB tree for each body type, retain proxies between steps,
buffer proxies whose fat bounds change, and query only those moved proxies for
new candidate pairs. Candidate pairs remain registered while their fat proxy bounds overlap and drive the lifetime of persistent contacts.
"
Class {
	#name : 'CFPhysicsBroadphase',
	#superclass : 'Object',
	#instVars : [ 'staticTree', 'kinematicTree', 'dynamicTree', 'proxiesByShape', 'proxyTypesByShape', 'entriesByShape', 'movedShapes', 'candidatePairsByKey', 'pairFilter', 'entryCount', 'comparisonCount', 'acceptedPairCount', 'maximumActiveCount', 'queryVisitCount', 'queryLeafVisitCount', 'lastMovedProxyCount' ],
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
}

{ #category : 'initialization' }
CFPhysicsBroadphase >> initialize [
	super initialize.
	staticTree := CFPhysicsDynamicTree new.
	kinematicTree := CFPhysicsDynamicTree new.
	dynamicTree := CFPhysicsDynamicTree new.
	proxiesByShape := IdentityDictionary new.
	proxyTypesByShape := IdentityDictionary new.
	entriesByShape := IdentityDictionary new.
	movedShapes := IdentitySet new.
	candidatePairsByKey := Dictionary new.
	pairFilter := CFPhysicsPairFinder new.
	lastMovedProxyCount := 0.
	self resetMeasurements
]

{ #category : 'finding' }
CFPhysicsBroadphase >> pairsAmongSolvedStepStates: stepStates collisionSuppressedBodyPairs: collisionSuppressedBodyPairs step: step [
	| statesByBody |
	self resetMeasurements.
	statesByBody := IdentityDictionary new.
	stepStates do: [ :state | statesByBody at: state body put: state ].
	self synchroniseProxiesWith: stepStates statesByBody: statesByBody step: step.
	self
		removeInvalidCandidatePairsUsing: statesByBody
		collisionSuppressedBodyPairs: collisionSuppressedBodyPairs.
	self
		findNewPairsUsing: statesByBody
		collisionSuppressedBodyPairs: collisionSuppressedBodyPairs.
	lastMovedProxyCount := movedShapes size.
	movedShapes removeAll.
	entryCount := proxiesByShape size.
	acceptedPairCount := candidatePairsByKey size.
	^ candidatePairsByKey values asArray sorted: [ :left :right |
		left comesBefore: right ]
]

{ #category : 'private - synchronisation' }
CFPhysicsBroadphase >> synchroniseProxiesWith: stepStates statesByBody: statesByBody step: step [
	| currentShapes removedShapes |
	currentShapes := IdentitySet new.
	stepStates do: [ :state |
		state body shapes withIndexDo: [ :shape :index |
			currentShapes add: shape.
			self
				synchroniseProxyForShape: shape
				shapeIndex: index - 1
				stepState: state
				step: step ] ].
	removedShapes := proxiesByShape keys reject: [ :shape | currentShapes includes: shape ].
	removedShapes do: [ :shape | self destroyProxyForShape: shape ]
]

{ #category : 'private - synchronisation' }
CFPhysicsBroadphase >> synchroniseProxyForShape: aShape shapeIndex: aShapeIndex stepState: aStepState step: aStep [
	| type tree bounds proxy previousType entry |
	type := self typeFor: aStepState.
	tree := self treeForType: type.
	bounds := self
		broadphaseAABBForShape: aShape
		shapeIndex: aShapeIndex
		stepState: aStepState
		step: aStep.
	proxy := proxiesByShape at: aShape ifAbsent: [ nil ].
	previousType := proxyTypesByShape at: aShape ifAbsent: [ nil ].
	(proxy notNil and: [ previousType ~= type ]) ifTrue: [
		(self treeForType: previousType) destroyProxy: proxy.
		proxiesByShape removeKey: aShape.
		proxyTypesByShape removeKey: aShape.
		entriesByShape removeKey: aShape.
		proxy := nil ].
	proxy
		ifNil: [
			entry := CFPhysicsBroadphaseEntry
				body: aStepState body
				shape: aShape
				shapeIndex: aShapeIndex.
			proxy := tree createProxyFor: entry aabb: bounds.
			proxiesByShape at: aShape put: proxy.
			proxyTypesByShape at: aShape put: type.
			entriesByShape at: aShape put: entry.
			movedShapes add: aShape ]
		ifNotNil: [
			(tree moveProxy: proxy to: bounds) ifTrue: [ movedShapes add: aShape ] ]
]

{ #category : 'private - synchronisation' }
CFPhysicsBroadphase >> destroyProxyForShape: aShape [
	| proxy type entry |
	proxy := proxiesByShape removeKey: aShape ifAbsent: [ ^ self ].
	type := proxyTypesByShape removeKey: aShape.
	entry := entriesByShape removeKey: aShape.
	(self treeForType: type) destroyProxy: proxy.
	movedShapes remove: aShape ifAbsent: [ ].
	(candidatePairsByKey keys select: [ :key |
		| pair |
		pair := candidatePairsByKey at: key.
		pair firstShape == entry shape or: [ pair secondShape == entry shape ] ])
		do: [ :key | candidatePairsByKey removeKey: key ]
]

{ #category : 'pair buffering' }
CFPhysicsBroadphase >> touchProxyForBody: aBody [
	"Buffer an existing proxy for pair creation without changing its bounds.
	Box2D uses this path when a joint begins allowing its connected bodies to
	collide, because neither body need move for the broadphase to reconsider
	the pair."
	aBody shapes do: [ :shape |
		(proxiesByShape includesKey: shape) ifTrue: [ movedShapes add: shape ] ].
	^ self
]

{ #category : 'private - pairs' }
CFPhysicsBroadphase >> findNewPairsUsing: statesByBody collisionSuppressedBodyPairs: collisionSuppressedBodyPairs [
	movedShapes do: [ :shape |
		| entry state type proxy bounds |
		entry := entriesByShape at: shape ifAbsent: [ nil ].
		entry ifNotNil: [
			state := statesByBody at: entry body ifAbsent: [ nil ].
			state ifNotNil: [
				type := proxyTypesByShape at: shape.
				proxy := proxiesByShape at: shape.
				bounds := proxy aabb.
				type = #dynamic ifTrue: [
					self queryTree: kinematicTree bounds: bounds for: entry state: state statesByBody: statesByBody collisionSuppressedBodyPairs: collisionSuppressedBodyPairs.
					self queryTree: staticTree bounds: bounds for: entry state: state statesByBody: statesByBody collisionSuppressedBodyPairs: collisionSuppressedBodyPairs ].
				self queryTree: dynamicTree bounds: bounds for: entry state: state statesByBody: statesByBody collisionSuppressedBodyPairs: collisionSuppressedBodyPairs ] ] ]
]

{ #category : 'private - pairs' }
CFPhysicsBroadphase >> queryTree: aTree bounds: bounds for: queryEntry state: queryState statesByBody: statesByBody collisionSuppressedBodyPairs: collisionSuppressedBodyPairs [
	aTree query: bounds do: [ :otherEntry |
		| otherState pair |
		otherEntry body == queryEntry body ifFalse: [
			otherState := statesByBody at: otherEntry body ifAbsent: [ nil ].
			otherState ifNotNil: [
				comparisonCount := comparisonCount + 1.
				(self
					shouldConsider: queryState
					with: otherState
					firstAABB: bounds
					secondAABB: (proxiesByShape at: otherEntry shape) aabb
					collisionSuppressedBodyPairs: collisionSuppressedBodyPairs) ifTrue: [
					pair := CFPhysicsPair
						firstBody: queryEntry body
						shape: queryEntry shape
						shapeIndex: queryEntry shapeIndex
						secondBody: otherEntry body
						shape: otherEntry shape
						shapeIndex: otherEntry shapeIndex.
					candidatePairsByKey at: pair key put: pair ] ] ].
		true ].
	queryVisitCount := queryVisitCount + aTree queryVisitCount.
	queryLeafVisitCount := queryLeafVisitCount + aTree queryLeafVisitCount
]

{ #category : 'private - pairs' }
CFPhysicsBroadphase >> removeInvalidCandidatePairsUsing: statesByBody collisionSuppressedBodyPairs: collisionSuppressedBodyPairs [
	(candidatePairsByKey keys select: [ :key |
		| pair firstState secondState firstProxy secondProxy |
		pair := candidatePairsByKey at: key.
		firstState := statesByBody at: pair firstBody ifAbsent: [ nil ].
		secondState := statesByBody at: pair secondBody ifAbsent: [ nil ].
		firstProxy := proxiesByShape at: pair firstShape ifAbsent: [ nil ].
		secondProxy := proxiesByShape at: pair secondShape ifAbsent: [ nil ].
		firstState isNil or: [
			secondState isNil or: [
				firstProxy isNil or: [
					secondProxy isNil or: [
						(self
							shouldConsider: firstState
							with: secondState
							firstAABB: firstProxy aabb
							secondAABB: secondProxy aabb
							collisionSuppressedBodyPairs: collisionSuppressedBodyPairs) not ] ] ] ] ])
		do: [ :key | candidatePairsByKey removeKey: key ]
]

{ #category : 'private - filtering' }
CFPhysicsBroadphase >> shouldConsider: firstState with: secondState firstAABB: firstAABB secondAABB: secondAABB collisionSuppressedBodyPairs: collisionSuppressedBodyPairs [
	^ pairFilter
		shouldConsiderStepState: firstState
		with: secondState
		firstAABB: firstAABB
		secondAABB: secondAABB
		collisionSuppressedBodyPairs: collisionSuppressedBodyPairs
]

{ #category : 'private - bounds' }
CFPhysicsBroadphase >> broadphaseAABBForShape: aShape shapeIndex: aShapeIndex stepState: aStepState step: aStep [
	| transform bounds speculativeDistance proxyMargin |
	aShapeIndex = 0 ifTrue: [ ^ self broadphaseAABBFor: aStepState step: aStep ].
	aShape isChainSegment ifFalse: [
		self error: 'Unsupported additional Physics shape: ', aShape class name ].
	transform := aStepState solvedTransform.
	bounds := aShape
		aabbAtBodyOrigin: transform bodyOrigin
		rotation: transform rotation.
	aStep ifNil: [ ^ bounds ].
	speculativeDistance := aStep speculativeDistance.
	proxyMargin := aStepState body isStatic
		ifTrue: [ speculativeDistance ]
		ifFalse: [ aStep broadphaseAABBMargin ].
	^ (bounds expandedBy: speculativeDistance)
		expandedBy: proxyMargin
]

{ #category : 'private - bounds' }
CFPhysicsBroadphase >> broadphaseAABBFor: aStepState step: aStep [
	| speculativeDistance proxyMargin |
	aStep ifNil: [ ^ aStepState solvedSweptAABB ].
	speculativeDistance := aStep speculativeDistance.
	proxyMargin := aStepState body isStatic
		ifTrue: [ speculativeDistance ]
		ifFalse: [ aStep broadphaseAABBMargin ].
	^ (aStepState solvedSweptAABB expandedBy: speculativeDistance)
		expandedBy: proxyMargin
]

{ #category : 'private - types' }
CFPhysicsBroadphase >> typeFor: aStepState [
	aStepState bodyType isStatic ifTrue: [ ^ #static ].
	aStepState bodyType isDynamic ifTrue: [ ^ #dynamic ].
	^ #kinematic
]

{ #category : 'private - types' }
CFPhysicsBroadphase >> treeForType: aSymbol [
	aSymbol = #static ifTrue: [ ^ staticTree ].
	aSymbol = #kinematic ifTrue: [ ^ kinematicTree ].
	self assert: aSymbol = #dynamic.
	^ dynamicTree
]

{ #category : 'private - measurements' }
CFPhysicsBroadphase >> resetMeasurements [
	entryCount := 0.
	comparisonCount := 0.
	acceptedPairCount := 0.
	maximumActiveCount := 0.
	queryVisitCount := 0.
	queryLeafVisitCount := 0
]

{ #category : 'measurements' }
CFPhysicsBroadphase >> entryCount [ ^ entryCount ]
{ #category : 'measurements' }
CFPhysicsBroadphase >> comparisonCount [ ^ comparisonCount ]
{ #category : 'measurements' }
CFPhysicsBroadphase >> acceptedPairCount [ ^ acceptedPairCount ]
{ #category : 'measurements' }
CFPhysicsBroadphase >> maximumActiveCount [ ^ maximumActiveCount ]
{ #category : 'measurements' }
CFPhysicsBroadphase >> queryVisitCount [ ^ queryVisitCount ]
{ #category : 'measurements' }
CFPhysicsBroadphase >> queryLeafVisitCount [ ^ queryLeafVisitCount ]
{ #category : 'measurements' }
CFPhysicsBroadphase >> movedProxyCount [ ^ lastMovedProxyCount ]
{ #category : 'measurements' }
CFPhysicsBroadphase >> proxyCount [ ^ proxiesByShape size ]
{ #category : 'accessing' }
CFPhysicsBroadphase >> staticTree [ ^ staticTree ]
{ #category : 'accessing' }
CFPhysicsBroadphase >> kinematicTree [ ^ kinematicTree ]
{ #category : 'accessing' }
CFPhysicsBroadphase >> dynamicTree [ ^ dynamicTree ]

{ #category : 'measurements' }
CFPhysicsBroadphase >> dynamicTreeAreaRatio [ ^ dynamicTree areaRatio ]

{ #category : 'measurements' }
CFPhysicsBroadphase >> kinematicTreeAreaRatio [ ^ kinematicTree areaRatio ]

{ #category : 'measurements' }
CFPhysicsBroadphase >> staticTreeAreaRatio [ ^ staticTree areaRatio ]


{ #category : 'maintenance' }
CFPhysicsBroadphase >> rebuildTrees [
	"Partially rebuild the dynamic and kinematic trees, matching
	b2BroadPhase_RebuildTrees in Box2D 3.1.1. Static proxies are not rebuilt."
	^ dynamicTree rebuild + kinematicTree rebuild
]

{ #category : 'maintenance' }
CFPhysicsBroadphase >> rebuildTreesFully [
	"Fully rebuild the dynamic and kinematic trees for explicit maintenance or diagnostics."
	^ dynamicTree rebuildFully + kinematicTree rebuildFully
]


{ #category : 'private - synchronisation' }
CFPhysicsBroadphase >> resetProxiesForBody: aBody [
	aBody shapes do: [ :shape | self destroyProxyForShape: shape ].
	^ self
]
