Class {
	#name : 'CFPhysicsWorldVisualState',
	#superclass : 'Object',
	#instVars : [ 'contactsByKey', 'contacts' ],
	#category : 'BVC-Physics-Core',
	#package : 'BVC-Physics-Core'
}

{ #category : 'initialization' }
CFPhysicsWorldVisualState >> initialize [
	super initialize.
	contactsByKey := Dictionary new.
	contacts := #()
]

{ #category : 'accessing' }
CFPhysicsWorldVisualState >> contacts [ ^ contacts ]

{ #category : 'updating' }
CFPhysicsWorldVisualState >> updateFromContacts: aCollection [
	| live ordered |
	live := Set new.
	ordered := OrderedCollection new.
	aCollection do: [ :contact |
		(contact isTouching and: [ contact manifold normal notNil ]) ifTrue: [
			| visualState |
			live add: contact key.
			visualState := contactsByKey
				at: contact key
				ifAbsentPut: [ CFPhysicsContactVisualState new ].
			visualState updateFrom: contact.
			ordered add: visualState ] ].
	(contactsByKey keys reject: [ :key | live includes: key ]) do: [ :key |
		contactsByKey removeKey: key ].
	contacts := ordered asArray.
	^ self
]

{ #category : 'updating' }
CFPhysicsWorldVisualState >> clear [
	contactsByKey removeAll.
	contacts := #().
	^ self
]
