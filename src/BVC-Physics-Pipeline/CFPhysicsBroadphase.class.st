"
I am the persistent broadphase translated from Box2D 3.1.1.

I own one dynamic AABB tree for each body type, retain proxies between steps,
buffer proxies whose fat bounds change, and query only those moved proxies for
new candidate pairs. Candidate pairs remain registered while their fat proxy bounds overlap and drive the lifetime of persistent contacts.
"
Class {
	#name : 'CFPhysicsBroadphase',
	#superclass : 'Object',
	#instVars : [ 'staticTree', 'kinematicTree', 'dynamicTree', 'proxiesByBody', 'proxyTypesByBody', 'movedBodies', 'candidatePairsByKey', 'pairFilter', 'entryCount', 'comparisonCount', 'acceptedPairCount', 'maximumActiveCount', 'queryVisitCount', 'queryLeafVisitCount', 'lastMovedProxyCount' ],
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
}

{ #category : 'initialization' }
CFPhysicsBroadphase >> initialize [
	super initialize.
	staticTree := CFPhysicsDynamicTree new.
	kinematicTree := CFPhysicsDynamicTree new.
	dynamicTree := CFPhysicsDynamicTree new.
	proxiesByBody := IdentityDictionary new.
	proxyTypesByBody := IdentityDictionary new.
	movedBodies := IdentitySet new.
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
	lastMovedProxyCount := movedBodies size.
	movedBodies removeAll.
	entryCount := proxiesByBody size.
	acceptedPairCount := candidatePairsByKey size.
	^ candidatePairsByKey values asArray sorted: [ :left :right |
		left comesBefore: right ]
]

{ #category : 'private - synchronisation' }
CFPhysicsBroadphase >> synchroniseProxiesWith: stepStates statesByBody: statesByBody step: step [
	| removedBodies |
	removedBodies := proxiesByBody keys reject: [ :body | statesByBody includesKey: body ].
	removedBodies do: [ :body | self destroyProxyFor: body ].
	stepStates do: [ :state | self synchroniseProxyFor: state step: step ]
]

{ #category : 'private - synchronisation' }
CFPhysicsBroadphase >> synchroniseProxyFor: aStepState step: aStep [
	| body type tree bounds proxy previousType |
	body := aStepState body.
	type := self typeFor: aStepState.
	tree := self treeForType: type.
	bounds := self broadphaseAABBFor: aStepState step: aStep.
	proxy := proxiesByBody at: body ifAbsent: [ nil ].
	previousType := proxyTypesByBody at: body ifAbsent: [ nil ].
	(proxy notNil and: [ previousType ~= type ]) ifTrue: [
		(self treeForType: previousType) destroyProxy: proxy.
		proxiesByBody removeKey: body.
		proxyTypesByBody removeKey: body.
		proxy := nil ].
	proxy
		ifNil: [
			proxy := tree createProxyFor: body aabb: bounds.
			proxiesByBody at: body put: proxy.
			proxyTypesByBody at: body put: type.
			movedBodies add: body ]
		ifNotNil: [
			(tree moveProxy: proxy to: bounds) ifTrue: [ movedBodies add: body ] ]
]

{ #category : 'private - synchronisation' }
CFPhysicsBroadphase >> destroyProxyFor: aBody [
	| proxy type |
	proxy := proxiesByBody removeKey: aBody ifAbsent: [ ^ self ].
	type := proxyTypesByBody removeKey: aBody.
	(self treeForType: type) destroyProxy: proxy.
	movedBodies remove: aBody ifAbsent: [ ].
	(candidatePairsByKey keys select: [ :key |
		| pair |
		pair := candidatePairsByKey at: key.
		pair firstBody == aBody or: [ pair secondBody == aBody ] ])
		do: [ :key | candidatePairsByKey removeKey: key ]
]

{ #category : 'private - pairs' }
CFPhysicsBroadphase >> findNewPairsUsing: statesByBody collisionSuppressedBodyPairs: collisionSuppressedBodyPairs [
	movedBodies do: [ :body |
		| state type proxy bounds |
		state := statesByBody at: body ifAbsent: [ nil ].
		state ifNotNil: [
			type := proxyTypesByBody at: body.
			proxy := proxiesByBody at: body.
			bounds := proxy aabb.
			type = #dynamic ifTrue: [
				self queryTree: kinematicTree bounds: bounds for: state statesByBody: statesByBody collisionSuppressedBodyPairs: collisionSuppressedBodyPairs.
				self queryTree: staticTree bounds: bounds for: state statesByBody: statesByBody collisionSuppressedBodyPairs: collisionSuppressedBodyPairs ].
			self queryTree: dynamicTree bounds: bounds for: state statesByBody: statesByBody collisionSuppressedBodyPairs: collisionSuppressedBodyPairs ] ]
]

{ #category : 'private - pairs' }
CFPhysicsBroadphase >> queryTree: aTree bounds: bounds for: queryState statesByBody: statesByBody collisionSuppressedBodyPairs: collisionSuppressedBodyPairs [
	aTree query: bounds do: [ :otherBody |
		| otherState pair |
		otherBody == queryState body ifFalse: [
			otherState := statesByBody at: otherBody ifAbsent: [ nil ].
			otherState ifNotNil: [
				comparisonCount := comparisonCount + 1.
				(self
					shouldConsider: queryState
					with: otherState
					collisionSuppressedBodyPairs: collisionSuppressedBodyPairs) ifTrue: [
					pair := CFPhysicsPair first: queryState body second: otherBody.
					candidatePairsByKey at: pair key put: pair ] ] ].
		true ].
	queryVisitCount := queryVisitCount + aTree queryVisitCount.
	queryLeafVisitCount := queryLeafVisitCount + aTree queryLeafVisitCount
]

{ #category : 'private - pairs' }
CFPhysicsBroadphase >> removeInvalidCandidatePairsUsing: statesByBody collisionSuppressedBodyPairs: collisionSuppressedBodyPairs [
	(candidatePairsByKey keys select: [ :key |
		| pair firstState secondState |
		pair := candidatePairsByKey at: key.
		firstState := statesByBody at: pair firstBody ifAbsent: [ nil ].
		secondState := statesByBody at: pair secondBody ifAbsent: [ nil ].
		firstState isNil or: [
			secondState isNil or: [
				(self
					shouldConsider: firstState
					with: secondState
					collisionSuppressedBodyPairs: collisionSuppressedBodyPairs) not ] ] ])
		do: [ :key | candidatePairsByKey removeKey: key ]
]

{ #category : 'private - filtering' }
CFPhysicsBroadphase >> shouldConsider: firstState with: secondState collisionSuppressedBodyPairs: collisionSuppressedBodyPairs [
	| firstProxy secondProxy |
	firstProxy := proxiesByBody at: firstState body.
	secondProxy := proxiesByBody at: secondState body.
	^ pairFilter
		shouldConsiderStepState: firstState
		with: secondState
		firstAABB: firstProxy aabb
		secondAABB: secondProxy aabb
		collisionSuppressedBodyPairs: collisionSuppressedBodyPairs
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
CFPhysicsBroadphase >> proxyCount [ ^ proxiesByBody size ]
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
