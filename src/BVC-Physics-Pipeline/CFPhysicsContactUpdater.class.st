"
I reconcile persistent broadphase pairs with the previous contact set. A contact remains alive while its pair exists, independently of whether it is currently touching.
"

Class {
	#name : 'CFPhysicsContactUpdater',
	#superclass : 'Object',
	#instVars : [ 'manifoldGenerator', 'visitedPairCount', 'previousContactMatchCount', 'reusedContactCount', 'createdContactCount', 'copiedContactCount', 'impactContactCount', 'manifoldGenerationCount', 'cachedSimplexCount', 'bothSleepingPairCount', 'touchingContactCount', 'sleepingRetainedContactCount', 'awakeManifoldGenerationCount', 'sleepingImpactManifoldGenerationCount', 'sleepingNewManifoldGenerationCount', 'sleepingNonTouchingManifoldGenerationCount', 'sleepingNonSolidManifoldGenerationCount', 'sleepingOtherManifoldGenerationCount' ],
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
}

{ #category : 'instance creation' }
CFPhysicsContactUpdater class >> manifoldGenerator: aManifoldGenerator [
	^ self new manifoldGenerator: aManifoldGenerator; yourself
]

{ #category : 'accessing' }
CFPhysicsContactUpdater >> manifoldGenerator: aManifoldGenerator [ manifoldGenerator := aManifoldGenerator ]

{ #category : 'telemetry' }
CFPhysicsContactUpdater >> visitedPairCount [ ^ visitedPairCount ifNil: [ 0 ] ]
{ #category : 'telemetry' }
CFPhysicsContactUpdater >> previousContactMatchCount [ ^ previousContactMatchCount ifNil: [ 0 ] ]
{ #category : 'telemetry' }
CFPhysicsContactUpdater >> reusedContactCount [ ^ reusedContactCount ifNil: [ 0 ] ]
{ #category : 'telemetry' }
CFPhysicsContactUpdater >> createdContactCount [ ^ createdContactCount ifNil: [ 0 ] ]
{ #category : 'telemetry' }
CFPhysicsContactUpdater >> copiedContactCount [ ^ copiedContactCount ifNil: [ 0 ] ]
{ #category : 'telemetry' }
CFPhysicsContactUpdater >> impactContactCount [ ^ impactContactCount ifNil: [ 0 ] ]
{ #category : 'telemetry' }
CFPhysicsContactUpdater >> manifoldGenerationCount [ ^ manifoldGenerationCount ifNil: [ 0 ] ]
{ #category : 'telemetry' }
CFPhysicsContactUpdater >> cachedSimplexCount [ ^ cachedSimplexCount ifNil: [ 0 ] ]
{ #category : 'telemetry' }
CFPhysicsContactUpdater >> bothSleepingPairCount [ ^ bothSleepingPairCount ifNil: [ 0 ] ]
{ #category : 'telemetry' }
CFPhysicsContactUpdater >> touchingContactCount [ ^ touchingContactCount ifNil: [ 0 ] ]

{ #category : 'telemetry' }
CFPhysicsContactUpdater >> sleepingRetainedContactCount [ ^ sleepingRetainedContactCount ifNil: [ 0 ] ]
{ #category : 'telemetry' }
CFPhysicsContactUpdater >> awakeManifoldGenerationCount [ ^ awakeManifoldGenerationCount ifNil: [ 0 ] ]
{ #category : 'telemetry' }
CFPhysicsContactUpdater >> sleepingImpactManifoldGenerationCount [ ^ sleepingImpactManifoldGenerationCount ifNil: [ 0 ] ]
{ #category : 'telemetry' }
CFPhysicsContactUpdater >> sleepingNewManifoldGenerationCount [ ^ sleepingNewManifoldGenerationCount ifNil: [ 0 ] ]
{ #category : 'telemetry' }
CFPhysicsContactUpdater >> sleepingNonTouchingManifoldGenerationCount [ ^ sleepingNonTouchingManifoldGenerationCount ifNil: [ 0 ] ]
{ #category : 'telemetry' }
CFPhysicsContactUpdater >> sleepingNonSolidManifoldGenerationCount [ ^ sleepingNonSolidManifoldGenerationCount ifNil: [ 0 ] ]
{ #category : 'telemetry' }
CFPhysicsContactUpdater >> sleepingOtherManifoldGenerationCount [ ^ sleepingOtherManifoldGenerationCount ifNil: [ 0 ] ]

{ #category : 'private - telemetry' }
CFPhysicsContactUpdater >> resetMeasurements [
	visitedPairCount := 0.
	previousContactMatchCount := 0.
	reusedContactCount := 0.
	createdContactCount := 0.
	copiedContactCount := 0.
	impactContactCount := 0.
	manifoldGenerationCount := 0.
	cachedSimplexCount := 0.
	bothSleepingPairCount := 0.
	touchingContactCount := 0.
	sleepingRetainedContactCount := 0.
	awakeManifoldGenerationCount := 0.
	sleepingImpactManifoldGenerationCount := 0.
	sleepingNewManifoldGenerationCount := 0.
	sleepingNonTouchingManifoldGenerationCount := 0.
	sleepingNonSolidManifoldGenerationCount := 0.
	sleepingOtherManifoldGenerationCount := 0
]

{ #category : 'private - collision' }
CFPhysicsContactUpdater >> manifoldForPair: pair bodyStates: bodyStates speculativeDistance: speculativeDistance [
	^ self
		manifoldForPair: pair
		bodyStates: bodyStates
		speculativeDistance: speculativeDistance
		simplexCache: CFPhysicsSimplexCache empty
]

{ #category : 'private - collision' }
CFPhysicsContactUpdater >> manifoldForPair: pair bodyStates: bodyStates speculativeDistance: speculativeDistance simplexCache: simplexCache [
	^ bodyStates
		ifNil: [ manifoldGenerator manifoldBetweenBody: pair firstBody andBody: pair secondBody ]
		ifNotNil: [ manifoldGenerator
			manifoldForPair: pair
			bodyStates: bodyStates
			speculativeDistance: speculativeDistance
			simplexCache: simplexCache ]
]

{ #category : 'updating' }
CFPhysicsContactUpdater >> updatePairs: pairs fromContacts: previousContacts [
	^ self
		updatePairs: pairs
		includingImpactContacts: #()
		fromContacts: previousContacts
		reusingContacts: #()
		bodyStates: nil
]

{ #category : 'updating' }
CFPhysicsContactUpdater >> updateImpactContact: impactContact fromContacts: previousContacts [
	^ self
		updateImpactContacts: (impactContact ifNil: [ #() ] ifNotNil: [ { impactContact } ])
		fromContacts: previousContacts
]

{ #category : 'updating' }
CFPhysicsContactUpdater >> updateImpactContacts: impactContacts fromContacts: previousContacts [
	| pairs |
	pairs := OrderedCollection new.
	impactContacts do: [ :contact |
		contact ifNotNil: [ pairs add: contact pair ] ].
	^ self
		updatePairs: pairs
		includingImpactContacts: impactContacts
		fromContacts: previousContacts
		reusingContacts: #()
		bodyStates: nil
]

{ #category : 'updating' }
CFPhysicsContactUpdater >> updatePairs: pairs includingImpactContacts: impactContacts fromContacts: previousContacts [
	^ self
		updatePairs: pairs
		includingImpactContacts: impactContacts
		fromContacts: previousContacts
		bodyStates: nil
]

{ #category : 'updating' }
CFPhysicsContactUpdater >> updatePairs: pairs includingImpactContacts: impactContacts fromContacts: previousContacts bodyStates: bodyStates [
	^ self
		updatePairs: pairs
		includingImpactContacts: impactContacts
		fromContacts: previousContacts
		reusingContacts: #()
		bodyStates: bodyStates
]

{ #category : 'updating' }
CFPhysicsContactUpdater >> updatePairs: pairs includingImpactContacts: impactContacts fromContacts: previousContacts reusingContacts: reusableContacts bodyStates: bodyStates [
	^ self
		updatePairs: pairs
		includingImpactContacts: impactContacts
		fromContacts: previousContacts
		reusingContacts: reusableContacts
		bodyStates: bodyStates
		speculativeDistance: 0.0
]

{ #category : 'updating' }
CFPhysicsContactUpdater >> updatePairs: pairs includingImpactContacts: impactContacts fromContacts: previousContacts reusingContacts: reusableContacts bodyStates: bodyStates speculativeDistance: speculativeDistance [
	| previousByKey reusableByKey impactByKey contacts touching began continued ended orderedPairs visualStateMayHaveChanged |
	self resetMeasurements.
	visualStateMayHaveChanged := false.
	previousByKey := Dictionary new.
	previousContacts do: [ :contact | previousByKey at: contact key put: contact ].
	reusableByKey := Dictionary new.
	reusableContacts do: [ :contact | reusableByKey at: contact key put: contact ].
	impactByKey := Dictionary new.
	impactContacts do: [ :contact |
		contact ifNotNil: [ impactByKey at: contact key put: contact ] ].
	contacts := OrderedCollection new.
	touching := OrderedCollection new.
	began := OrderedCollection new.
	continued := OrderedCollection new.
	ended := OrderedCollection new.
	orderedPairs := pairs asArray sorted: [ :left :right | left comesBefore: right ].
	visitedPairCount := orderedPairs size.
	orderedPairs do: [ :pair |
		| manifold impactContact contact previous bothSleeping retainSleepingContact |
		impactContact := impactByKey at: pair key ifAbsent: [ nil ].
		previous := previousByKey removeKey: pair key ifAbsent: [ nil ].
		previous ifNotNil: [ previousContactMatchCount := previousContactMatchCount + 1 ].
		(reusableByKey includesKey: pair key) ifTrue: [ reusedContactCount := reusedContactCount + 1 ].
		impactContact ifNotNil: [ impactContactCount := impactContactCount + 1 ].
		contact := reusableByKey
			removeKey: pair key
			ifAbsent: [
				impactContact
					ifNil: [
						previous
							ifNil: [ createdContactCount := createdContactCount + 1. CFPhysicsContact pair: pair manifold: nil ]
							ifNotNil: [ copiedContactCount := copiedContactCount + 1. previous copyForUpdate ] ]
					ifNotNil: [ impactContact ] ].
		contact pair: pair.
		contact simplexCache count > 0 ifTrue: [ cachedSimplexCount := cachedSimplexCount + 1 ].
		bothSleeping := bodyStates notNil and: [
			((bodyStates at: pair firstBody) isAwake not) and: [
				(bodyStates at: pair secondBody) isAwake not ] ].
		bothSleeping ifTrue: [ bothSleepingPairCount := bothSleepingPairCount + 1 ].
		retainSleepingContact := bothSleeping
			and: [ previous notNil
			and: [ previous isTouching
			and: [ previous isSolid
			and: [ impactContact isNil ] ] ] ].
		retainSleepingContact
			ifTrue: [
				sleepingRetainedContactCount := sleepingRetainedContactCount + 1.
				contact
					shapeStatesFromBodyStates: bodyStates;
					simplexCache: previous simplexCache;
					updateFromPreviousContact: previous with: previous manifold.
				contacts add: contact.
				touching add: contact.
				continued add: contact ]
			ifFalse: [
				manifoldGenerationCount := manifoldGenerationCount + 1.
				bothSleeping
					ifFalse: [ awakeManifoldGenerationCount := awakeManifoldGenerationCount + 1 ]
					ifTrue: [
						impactContact notNil
							ifTrue: [ sleepingImpactManifoldGenerationCount := sleepingImpactManifoldGenerationCount + 1 ]
							ifFalse: [
								previous isNil
									ifTrue: [ sleepingNewManifoldGenerationCount := sleepingNewManifoldGenerationCount + 1 ]
									ifFalse: [
										previous isTouching not
											ifTrue: [ sleepingNonTouchingManifoldGenerationCount := sleepingNonTouchingManifoldGenerationCount + 1 ]
											ifFalse: [
												previous isSolid not
													ifTrue: [ sleepingNonSolidManifoldGenerationCount := sleepingNonSolidManifoldGenerationCount + 1 ]
													ifFalse: [ sleepingOtherManifoldGenerationCount := sleepingOtherManifoldGenerationCount + 1 ] ] ] ] ].
				manifold := self
					manifoldForPair: pair
					bodyStates: bodyStates
					speculativeDistance: speculativeDistance
					simplexCache: contact simplexCache.
				(manifold isNil and: [ impactContact notNil ]) ifTrue: [
					manifold := impactContact manifold ].
				bodyStates
					ifNil: [ contact shapeStatesFromPair ]
					ifNotNil: [ contact shapeStatesFromBodyStates: bodyStates ].
				contact updateFromPreviousContact: previous with: manifold.
				contacts add: contact.
				contact isTouching ifTrue: [
					visualStateMayHaveChanged := true.
					touching add: contact ].
				contact began ifTrue: [ began add: contact ].
				contact continued ifTrue: [ continued add: contact ].
				contact ended ifTrue: [
					visualStateMayHaveChanged := true.
					ended add: contact ] ] ].
	"Pairs absent from the broadphase are destroyed. A touching contact contributes one final end transition, but the destroyed contact is not retained in the batch."
	previousByKey valuesDo: [ :previous |
		previous isTouching ifTrue: [
			| endedContact |
			visualStateMayHaveChanged := true.
			endedContact := reusableByKey
				removeKey: previous key
				ifAbsent: [ CFPhysicsContact pair: previous pair manifold: nil ].
			endedContact pair: previous pair.
			endedContact updateFromPreviousContact: previous with: nil.
			ended add: endedContact ] ].
	touchingContactCount := touching size.
	ended := ended asArray sorted: [ :left :right |
		left pair comesBefore: right pair ].
	^ (CFPhysicsContactUpdateBatch
		contacts: contacts
		touching: touching
		began: began
		continued: continued
		ended: ended)
		visualStateMayHaveChanged: visualStateMayHaveChanged;
		yourself
]
