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
