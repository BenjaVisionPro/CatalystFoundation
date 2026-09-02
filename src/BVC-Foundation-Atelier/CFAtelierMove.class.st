"I coordinate one semantic move of an existing object between two Magritte to-many relation editing contexts.

Assessment reads current staged values from the supplied mementos, derives complete replacement collections and validates both descriptions without mutation. apply reassesses immediately before staging the two ordinary memento writes.

I intentionally do not own drag/drop, presentation geometry, child-memento transfer or a general transaction system."
Class {
	#name : 'CFAtelierMove',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'object',
		'sourceMemento',
		'sourceDescription',
		'destinationMemento',
		'destinationDescription',
		'destinationIndex'
	],
	#category : 'BVC-Foundation-Atelier-Move',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'Move'
}

{ #category : 'instance creation' }
CFAtelierMove class >> object: anObject sourceMemento: aSourceMemento sourceDescription: aSourceDescription destinationMemento: aDestinationMemento destinationDescription: aDestinationDescription destinationIndex: anIndex [
	^ self new
		object: anObject;
		sourceMemento: aSourceMemento;
		sourceDescription: aSourceDescription;
		destinationMemento: aDestinationMemento;
		destinationDescription: aDestinationDescription;
		destinationIndex: anIndex;
		yourself
]

{ #category : 'assessing' }
CFAtelierMove >> assess [
	| sourceItems destinationItems proposedSourceItems proposedDestinationItems identityCount |
	sourceItems := sourceMemento readUsing: sourceDescription.
	destinationItems := destinationMemento readUsing: destinationDescription.

	(sourceMemento == destinationMemento and: [ sourceDescription == destinationDescription ])
		ifTrue: [ ^ self rejectedWithSource: sourceItems destination: destinationItems because: 'A move between identical relation contexts is a reorder and belongs to the relation editor.' ].

	sourceDescription isReadOnly
		ifTrue: [ ^ self rejectedWithSource: sourceItems destination: destinationItems because: 'The source relation is read-only.' ].
	destinationDescription isReadOnly
		ifTrue: [ ^ self rejectedWithSource: sourceItems destination: destinationItems because: 'The destination relation is read-only.' ].

	(sourceDescription autoAccept or: [ destinationDescription autoAccept ])
		ifTrue: [ ^ self rejectedWithSource: sourceItems destination: destinationItems because: 'This compound move requires staged relation descriptions; an affected relation is auto-accepting.' ].

	sourceItems ifNil: [ ^ self rejectedWithSource: sourceItems destination: destinationItems because: 'The source relation has no collection value.' ].
	destinationItems ifNil: [ ^ self rejectedWithSource: sourceItems destination: destinationItems because: 'The destination relation has no collection value.' ].

	(sourceDescription isMultiple and: [ destinationDescription isMultiple ])
		ifFalse: [ ^ self rejectedWithSource: sourceItems destination: destinationItems because: 'A cross-relation move requires to-many relation descriptions.' ].

	identityCount := sourceItems count: [ :each | each == object ].
	identityCount = 1
		ifFalse: [ ^ self rejectedWithSource: sourceItems destination: destinationItems because: 'The moved object must occur exactly once in the source relation.' ].
	(destinationItems anySatisfy: [ :each | each == object ])
		ifTrue: [ ^ self rejectedWithSource: sourceItems destination: destinationItems because: 'The moved object is already present in the destination relation.' ].

	destinationDescription isOrdered
		ifTrue: [
			((destinationIndex isInteger)
				and: [ destinationIndex between: 1 and: destinationItems size + 1 ])
				ifFalse: [ ^ self rejectedWithSource: sourceItems destination: destinationItems because: 'The destination index is outside the current destination relation.' ] ]
		ifFalse: [
			destinationIndex ifNotNil: [ ^ self rejectedWithSource: sourceItems destination: destinationItems because: 'An unordered destination does not accept an insertion index.' ] ].

	proposedSourceItems := sourceItems species withAll: (sourceItems reject: [ :each | each == object ]).
	proposedDestinationItems := destinationDescription isOrdered
		ifTrue: [ self inserting: object at: destinationIndex into: destinationItems ]
		ifFalse: [
			| theItems |
			theItems := destinationItems species withAll: destinationItems.
			theItems add: object.
			theItems ].

	[ sourceDescription validate: proposedSourceItems ]
		on: MAValidationError
		do: [ :anException |
			^ self rejectedWithSource: sourceItems destination: destinationItems because: anException printString ].
	[ destinationDescription validate: proposedDestinationItems ]
		on: MAValidationError
		do: [ :anException |
			^ self rejectedWithSource: sourceItems destination: destinationItems because: anException printString ].

	^ CFAtelierMoveAssessment
		sourceItems: sourceItems
		destinationItems: destinationItems
		proposedSourceItems: proposedSourceItems
		proposedDestinationItems: proposedDestinationItems
]

{ #category : 'applying' }
CFAtelierMove >> applyAssessment: anAssessment [
	sourceMemento
		write: anAssessment proposedSourceItems
		using: sourceDescription.
	destinationMemento
		write: anAssessment proposedDestinationItems
		using: destinationDescription
]

{ #category : 'accessing' }
CFAtelierMove >> destinationDescription [
	^ destinationDescription
]

{ #category : 'accessing' }
CFAtelierMove >> destinationDescription: aDescription [
	destinationDescription := aDescription
]

{ #category : 'accessing' }
CFAtelierMove >> destinationIndex [
	^ destinationIndex
]

{ #category : 'accessing' }
CFAtelierMove >> destinationIndex: anInteger [
	destinationIndex := anInteger
]

{ #category : 'accessing' }
CFAtelierMove >> destinationMemento [
	^ destinationMemento
]

{ #category : 'accessing' }
CFAtelierMove >> destinationMemento: aMemento [
	destinationMemento := aMemento
]

{ #category : 'private' }
CFAtelierMove >> inserting: anObject at: anIndex into: aCollection [
	| theItems |
	theItems := OrderedCollection new: aCollection size + 1.
	1 to: aCollection size + 1 do: [ :eachIndex |
		eachIndex = anIndex ifTrue: [ theItems add: anObject ].
		eachIndex <= aCollection size ifTrue: [ theItems add: (aCollection at: eachIndex) ] ].
	^ aCollection species withAll: theItems
]

{ #category : 'accessing' }
CFAtelierMove >> object [
	^ object
]

{ #category : 'accessing' }
CFAtelierMove >> object: anObject [
	object := anObject
]

{ #category : 'private' }
CFAtelierMove >> rejectedWithSource: sourceItems destination: destinationItems because: aString [
	^ CFAtelierMoveAssessment
		sourceItems: sourceItems
		destinationItems: destinationItems
		rejectedBecause: aString
]

{ #category : 'accessing' }
CFAtelierMove >> sourceDescription [
	^ sourceDescription
]

{ #category : 'accessing' }
CFAtelierMove >> sourceDescription: aDescription [
	sourceDescription := aDescription
]

{ #category : 'accessing' }
CFAtelierMove >> sourceMemento [
	^ sourceMemento
]

{ #category : 'accessing' }
CFAtelierMove >> sourceMemento: aMemento [
	sourceMemento := aMemento
]
