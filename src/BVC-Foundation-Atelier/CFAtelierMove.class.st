"I coordinate one semantic move of an existing object between two distinct Magritte relation editing contexts.

A source or destination may be to-one or to-many. To-many destinations follow their ordered/unordered insertion semantics. A to-one destination must currently be empty: replacing an existing destination object would be a different compound intention, not a pure move.

Assessment reads current staged values, derives complete proposed values and validates both descriptions without mutation. apply reassesses immediately before staging the two ordinary memento writes.

After the relation writes are staged, I ask the source Foundation memento to transfer any existing embedded child memento for the moved object into the destination relation context. This preserves staged edits on an embedded object across the move without changing relation identity semantics or introducing another transaction system.

I intentionally do not own drag/drop or presentation geometry."
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
	| sourceValue destinationValue proposedSourceValue proposedDestinationValue |
	sourceValue := sourceMemento readUsing: sourceDescription.
	destinationValue := destinationMemento readUsing: destinationDescription.

	(sourceMemento == destinationMemento and: [ sourceDescription == destinationDescription ])
		ifTrue: [ ^ self rejectedWithSource: sourceValue destination: destinationValue because: 'A move requires distinct relation contexts.' ].

	sourceDescription isReadOnly
		ifTrue: [ ^ self rejectedWithSource: sourceValue destination: destinationValue because: 'The source relation is read-only.' ].
	destinationDescription isReadOnly
		ifTrue: [ ^ self rejectedWithSource: sourceValue destination: destinationValue because: 'The destination relation is read-only.' ].

	(sourceDescription autoAccept or: [ destinationDescription autoAccept ])
		ifTrue: [ ^ self rejectedWithSource: sourceValue destination: destinationValue because: 'This compound move requires staged relation descriptions; an affected relation is auto-accepting.' ].

	(self sourceValue: sourceValue containsObjectExactlyOnce: object) ifFalse: [
		^ self rejectedWithSource: sourceValue destination: destinationValue because: 'The moved object must occur exactly once in the source relation.' ].

	(self destinationValue: destinationValue alreadyContainsObject: object) ifTrue: [
		^ self rejectedWithSource: sourceValue destination: destinationValue because: 'The moved object is already present in the destination relation.' ].

	(destinationDescription isMultiple not and: [ destinationValue notNil ]) ifTrue: [
		^ self rejectedWithSource: sourceValue destination: destinationValue because: 'A to-one destination must be empty for a move.' ].

	(self destinationIndexIsValidFor: destinationValue) ifFalse: [
		^ self rejectedWithSource: sourceValue destination: destinationValue because: self destinationIndexRejectionMessage ].

	proposedSourceValue := self sourceValueByRemovingObject: object from: sourceValue.
	proposedDestinationValue := self destinationValueByAddingObject: object to: destinationValue.

	[ sourceDescription validate: proposedSourceValue ]
		on: MAValidationError
		do: [ :anException |
			^ self rejectedWithSource: sourceValue destination: destinationValue because: anException printString ].
	[ destinationDescription validate: proposedDestinationValue ]
		on: MAValidationError
		do: [ :anException |
			^ self rejectedWithSource: sourceValue destination: destinationValue because: anException printString ].

	^ CFAtelierMoveAssessment
		sourceItems: sourceValue
		destinationItems: destinationValue
		proposedSourceItems: proposedSourceValue
		proposedDestinationItems: proposedDestinationValue
]

{ #category : 'applying' }
CFAtelierMove >> applyAssessment: anAssessment [
	sourceMemento
		write: anAssessment proposedSourceItems
		using: sourceDescription.
	destinationMemento
		write: anAssessment proposedDestinationItems
		using: destinationDescription.
	sourceMemento
		transferChildMementoFor: object
		inRelation: sourceDescription
		to: destinationMemento
		inRelation: destinationDescription
]

{ #category : 'private - assessing' }
CFAtelierMove >> sourceValue: aValue containsObjectExactlyOnce: anObject [
	sourceDescription isMultiple ifFalse: [ ^ aValue == anObject ].
	aValue ifNil: [ ^ false ].
	^ (aValue count: [ :each | each == anObject ]) = 1
]

{ #category : 'private - assessing' }
CFAtelierMove >> destinationValue: aValue alreadyContainsObject: anObject [
	destinationDescription isMultiple ifFalse: [ ^ aValue == anObject ].
	aValue ifNil: [ ^ false ].
	^ aValue anySatisfy: [ :each | each == anObject ]
]

{ #category : 'private - assessing' }
CFAtelierMove >> destinationIndexIsValidFor: aValue [
	destinationDescription isMultiple ifFalse: [ ^ destinationIndex isNil ].
	aValue ifNil: [ ^ false ].
	destinationDescription isOrdered ifFalse: [ ^ destinationIndex isNil ].
	^ destinationIndex isInteger
		and: [ destinationIndex between: 1 and: aValue size + 1 ]
]

{ #category : 'private - assessing' }
CFAtelierMove >> destinationIndexRejectionMessage [
	destinationDescription isMultiple ifFalse: [ ^ 'A to-one destination does not accept an insertion index.' ].
	destinationDescription isOrdered ifFalse: [ ^ 'An unordered destination does not accept an insertion index.' ].
	^ 'The destination index is outside the current destination relation.'
]

{ #category : 'private - assessing' }
CFAtelierMove >> sourceValueByRemovingObject: anObject from: aValue [
	sourceDescription isMultiple ifFalse: [ ^ nil ].
	^ aValue species withAll: (aValue reject: [ :each | each == anObject ])
]

{ #category : 'private - assessing' }
CFAtelierMove >> destinationValueByAddingObject: anObject to: aValue [
	| theItems |
	destinationDescription isMultiple ifFalse: [ ^ anObject ].
	destinationDescription isOrdered
		ifTrue: [ ^ self inserting: anObject at: destinationIndex into: aValue ].
	theItems := aValue species withAll: aValue.
	theItems add: anObject.
	^ theItems
]

{ #category : 'accessing' }
CFAtelierMove >> destinationDescription [ ^ destinationDescription ]
{ #category : 'accessing' }
CFAtelierMove >> destinationDescription: aDescription [ destinationDescription := aDescription ]
{ #category : 'accessing' }
CFAtelierMove >> destinationIndex [ ^ destinationIndex ]
{ #category : 'accessing' }
CFAtelierMove >> destinationIndex: anInteger [ destinationIndex := anInteger ]
{ #category : 'accessing' }
CFAtelierMove >> destinationMemento [ ^ destinationMemento ]
{ #category : 'accessing' }
CFAtelierMove >> destinationMemento: aMemento [ destinationMemento := aMemento ]

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
CFAtelierMove >> object [ ^ object ]
{ #category : 'accessing' }
CFAtelierMove >> object: anObject [ object := anObject ]

{ #category : 'private' }
CFAtelierMove >> rejectedWithSource: sourceValue destination: destinationValue because: aString [
	^ CFAtelierMoveAssessment
		sourceItems: sourceValue
		destinationItems: destinationValue
		rejectedBecause: aString
]

{ #category : 'accessing' }
CFAtelierMove >> sourceDescription [ ^ sourceDescription ]
{ #category : 'accessing' }
CFAtelierMove >> sourceDescription: aDescription [ sourceDescription := aDescription ]
{ #category : 'accessing' }
CFAtelierMove >> sourceMemento [ ^ sourceMemento ]
{ #category : 'accessing' }
CFAtelierMove >> sourceMemento: aMemento [ sourceMemento := aMemento ]
