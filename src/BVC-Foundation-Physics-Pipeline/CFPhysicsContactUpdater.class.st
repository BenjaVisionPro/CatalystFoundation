Class {
	#name : 'CFPhysicsContactUpdater',
	#superclass : 'Object',
	#instVars : [ 'manifoldBuilder' ],
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'instance creation' }
CFPhysicsContactUpdater class >> manifoldBuilder: aBlock [
	^ self new manifoldBuilder: aBlock; yourself
]

{ #category : 'accessing' }
CFPhysicsContactUpdater >> manifoldBuilder: aBlock [ manifoldBuilder := aBlock ]

{ #category : 'updating' }
CFPhysicsContactUpdater >> updatePairs: pairs fromContacts: previousContacts [
	| previousByKey active began continued ended orderedPairs |
	previousByKey := Dictionary new.
	previousContacts do: [ :contact | previousByKey at: contact key put: contact ].
	active := OrderedCollection new.
	began := OrderedCollection new.
	continued := OrderedCollection new.
	ended := OrderedCollection new.
	orderedPairs := pairs asArray sorted: [ :left :right | left comesBefore: right ].
	orderedPairs do: [ :pair |
		| manifold contact previous |
		manifold := manifoldBuilder value: pair.
		previous := previousByKey removeKey: pair key ifAbsent: [ nil ].
		(manifold isNil and: [ previous notNil ]) ifTrue: [
			manifold := previous manifold ].
		manifold ifNotNil: [
			contact := previous
				ifNil: [ CFPhysicsContact pair: pair manifold: manifold ]
				ifNotNil: [ previous copyForUpdate updateWith: manifold; yourself ].
			active add: contact.
			contact began ifTrue: [ began add: contact ].
			contact continued ifTrue: [ continued add: contact ] ] ].
	previousByKey valuesDo: [ :previous |
		| endedContact |
		endedContact := previous copyForUpdate.
		endedContact updateWith: nil.
		ended add: endedContact ].
	ended := ended asArray sorted: [ :left :right | left pair comesBefore: right pair ].
	^ CFPhysicsContactUpdateBatch
		active: active
		began: began
		continued: continued
		ended: ended
]


{ #category : 'updating' }
CFPhysicsContactUpdater >> updateImpactContact: impactContact fromContacts: previousContacts [
	| previousByKey active began continued ended contact previous |
	previousByKey := Dictionary new.
	previousContacts do: [ :each | previousByKey at: each key put: each ].
	active := OrderedCollection new.
	began := OrderedCollection new.
	continued := OrderedCollection new.
	ended := OrderedCollection new.
	contact := impactContact.
	contact ifNotNil: [
		previous := previousByKey removeKey: contact key ifAbsent: [ nil ].
		contact := previous
			ifNil: [ contact ]
			ifNotNil: [ previous copyForUpdate updateWith: contact manifold; yourself ].
		active add: contact.
		contact began ifTrue: [ began add: contact ].
		contact continued ifTrue: [ continued add: contact ] ].
	previousByKey valuesDo: [ :each |
		| endedContact |
		endedContact := each copyForUpdate.
		endedContact updateWith: nil.
		ended add: endedContact ].
	ended := ended asArray sorted: [ :left :right |
		left pair comesBefore: right pair ].
	^ CFPhysicsContactUpdateBatch
		active: active
		began: began
		continued: continued
		ended: ended
]

{ #category : 'updating' }
CFPhysicsContactUpdater >> updateImpactContacts: impactContacts fromContacts: previousContacts [
	| previousByKey active began continued ended contactsByKey orderedContacts |
	previousByKey := Dictionary new.
	previousContacts do: [ :each | previousByKey at: each key put: each ].
	contactsByKey := Dictionary new.
	impactContacts do: [ :each |
		each ifNotNil: [ contactsByKey at: each key put: each ] ].
	orderedContacts := contactsByKey values asArray sorted: [ :left :right |
		left pair comesBefore: right pair ].
	active := OrderedCollection new.
	began := OrderedCollection new.
	continued := OrderedCollection new.
	ended := OrderedCollection new.
	orderedContacts do: [ :impactContact |
		| contact previous |
		previous := previousByKey removeKey: impactContact key ifAbsent: [ nil ].
		contact := previous
			ifNil: [ impactContact ]
			ifNotNil: [ previous copyForUpdate updateWith: impactContact manifold; yourself ].
		active add: contact.
		contact began ifTrue: [ began add: contact ].
		contact continued ifTrue: [ continued add: contact ] ].
	previousByKey valuesDo: [ :each |
		| endedContact |
		endedContact := each copyForUpdate.
		endedContact updateWith: nil.
		ended add: endedContact ].
	ended := ended asArray sorted: [ :left :right |
		left pair comesBefore: right pair ].
	^ CFPhysicsContactUpdateBatch
		active: active
		began: began
		continued: continued
		ended: ended
]


{ #category : 'updating' }
CFPhysicsContactUpdater >> updatePairs: pairs includingImpactContacts: impactContacts fromContacts: previousContacts [
	| previousByKey active began continued ended impactByKey orderedPairs |
	previousByKey := Dictionary new.
	previousContacts do: [ :contact | previousByKey at: contact key put: contact ].
	impactByKey := Dictionary new.
	impactContacts do: [ :contact |
		contact ifNotNil: [ impactByKey at: contact key put: contact ] ].
	active := OrderedCollection new.
	began := OrderedCollection new.
	continued := OrderedCollection new.
	ended := OrderedCollection new.
	orderedPairs := pairs asArray sorted: [ :left :right | left comesBefore: right ].
	orderedPairs do: [ :pair |
		| manifold impactContact contact previous |
		manifold := manifoldBuilder value: pair.
		impactContact := impactByKey at: pair key ifAbsent: [ nil ].
		(manifold isNil and: [ impactContact notNil ]) ifTrue: [
			manifold := impactContact manifold ].
		previous := previousByKey removeKey: pair key ifAbsent: [ nil ].
		manifold ifNotNil: [
			contact := previous
				ifNil: [
					impactContact
						ifNil: [ CFPhysicsContact pair: pair manifold: manifold ]
						ifNotNil: [ impactContact ] ]
				ifNotNil: [ previous copyForUpdate updateWith: manifold; yourself ].
			active add: contact.
			contact began ifTrue: [ began add: contact ].
			contact continued ifTrue: [ continued add: contact ] ] ].
	previousByKey valuesDo: [ :previous |
		| endedContact |
		endedContact := previous copyForUpdate.
		endedContact updateWith: nil.
		ended add: endedContact ].
	ended := ended asArray sorted: [ :left :right |
		left pair comesBefore: right pair ].
	^ CFPhysicsContactUpdateBatch
		active: active
		began: began
		continued: continued
		ended: ended
]
