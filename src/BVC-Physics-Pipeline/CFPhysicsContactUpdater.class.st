"
I reconcile persistent broadphase pairs with the previous contact set. A contact remains alive while its pair exists, independently of whether it is currently touching.
"

Class {
	#name : 'CFPhysicsContactUpdater',
	#superclass : 'Object',
	#instVars : [ 'manifoldGenerator' ],
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
}

{ #category : 'instance creation' }
CFPhysicsContactUpdater class >> manifoldGenerator: aManifoldGenerator [
	^ self new manifoldGenerator: aManifoldGenerator; yourself
]

{ #category : 'accessing' }
CFPhysicsContactUpdater >> manifoldGenerator: aManifoldGenerator [ manifoldGenerator := aManifoldGenerator ]

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
	| previousByKey reusableByKey impactByKey contacts touching began continued ended orderedPairs |
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
	orderedPairs do: [ :pair |
		| manifold impactContact contact previous |
		impactContact := impactByKey at: pair key ifAbsent: [ nil ].
		previous := previousByKey removeKey: pair key ifAbsent: [ nil ].
		contact := reusableByKey
			removeKey: pair key
			ifAbsent: [
				impactContact
					ifNil: [
						previous
							ifNil: [ CFPhysicsContact pair: pair manifold: nil ]
							ifNotNil: [ previous copyForUpdate ] ]
					ifNotNil: [ impactContact ] ].
		contact pair: pair.
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
		contact isTouching ifTrue: [ touching add: contact ].
		contact began ifTrue: [ began add: contact ].
		contact continued ifTrue: [ continued add: contact ].
		contact ended ifTrue: [ ended add: contact ] ].
	"Pairs absent from the broadphase are destroyed. A touching contact contributes one final end transition, but the destroyed contact is not retained in the batch."
	previousByKey valuesDo: [ :previous |
		previous isTouching ifTrue: [
			| endedContact |
			endedContact := reusableByKey
				removeKey: previous key
				ifAbsent: [ CFPhysicsContact pair: previous pair manifold: nil ].
			endedContact pair: previous pair.
			endedContact updateFromPreviousContact: previous with: nil.
			ended add: endedContact ] ].
	ended := ended asArray sorted: [ :left :right |
		left pair comesBefore: right pair ].
	^ CFPhysicsContactUpdateBatch
		contacts: contacts
		touching: touching
		began: began
		continued: continued
		ended: ended
]
