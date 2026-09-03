"I coordinate one semantic move of one or more existing objects between two distinct Magritte relation editing contexts.

A single-object move may cross to-one and to-many cardinalities. A multi-object move requires a to-many source and a to-many destination. For a to-many source I derive the moved group in its authoritative staged relation order rather than trusting drag-item order. Ordered destinations require the explicit first destination index; unordered destinations append the group without inventing positional semantics. A to-one destination must be empty.

Assessment reads current staged values, derives complete proposed values and validates both descriptions without mutation. apply reassesses immediately before staging the two ordinary memento writes.

After the relation writes are staged, I ask the source Foundation memento to re-key any existing embedded child mementos when both relations belong to that same parent editing transaction. If source and destination are distinct parent mementos, assessment rejects the move whenever any moved object already participates in embedded child editing state. A cross-transaction move without child editing state remains legal; Atelier does not silently orphan an active child transaction.

I intentionally do not own drag/drop or presentation geometry."
Class {
	#name : 'CFAtelierMove',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'objects',
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
	^ self
		objects: { anObject }
		sourceMemento: aSourceMemento
		sourceDescription: aSourceDescription
		destinationMemento: aDestinationMemento
		destinationDescription: aDestinationDescription
		destinationIndex: anIndex
]

{ #category : 'instance creation' }
CFAtelierMove class >> objects: someObjects sourceMemento: aSourceMemento sourceDescription: aSourceDescription destinationMemento: aDestinationMemento destinationDescription: aDestinationDescription destinationIndex: anIndex [
	^ self new
		objects: someObjects;
		sourceMemento: aSourceMemento;
		sourceDescription: aSourceDescription;
		destinationMemento: aDestinationMemento;
		destinationDescription: aDestinationDescription;
		destinationIndex: anIndex;
		yourself
]

{ #category : 'assessing' }
CFAtelierMove >> assess [
	| sourceValue destinationValue movedObjects proposedSourceValue proposedDestinationValue |
	sourceValue := sourceMemento readUsing: sourceDescription.
	destinationValue := destinationMemento readUsing: destinationDescription.

	(sourceMemento == destinationMemento and: [ sourceDescription == destinationDescription ])
		ifTrue: [ ^ self rejectedWithSource: sourceValue destination: destinationValue because: 'A move requires distinct relation contexts.' ].

	objects ifNil: [ ^ self rejectedWithSource: sourceValue destination: destinationValue because: 'At least one moved object is required.' ].
	objects isEmpty ifTrue: [ ^ self rejectedWithSource: sourceValue destination: destinationValue because: 'At least one moved object is required.' ].
	(self hasDuplicateObjectIdentities: objects) ifTrue: [
		^ self rejectedWithSource: sourceValue destination: destinationValue because: 'A move cannot contain the same object identity more than once.' ].

	objects size > 1 ifTrue: [
		sourceDescription isMultiple ifFalse: [
			^ self rejectedWithSource: sourceValue destination: destinationValue because: 'Moving multiple objects requires a to-many source relation.' ].
		destinationDescription isMultiple ifFalse: [
			^ self rejectedWithSource: sourceValue destination: destinationValue because: 'Moving multiple objects requires a to-many destination relation.' ] ].

	sourceDescription isReadOnly
		ifTrue: [ ^ self rejectedWithSource: sourceValue destination: destinationValue because: 'The source relation is read-only.' ].
	destinationDescription isReadOnly
		ifTrue: [ ^ self rejectedWithSource: sourceValue destination: destinationValue because: 'The destination relation is read-only.' ].

	(sourceDescription autoAccept or: [ destinationDescription autoAccept ])
		ifTrue: [ ^ self rejectedWithSource: sourceValue destination: destinationValue because: 'This compound move requires staged relation descriptions; an affected relation is auto-accepting.' ].

	movedObjects := self movedObjectsInSourceOrderFrom: sourceValue.
	movedObjects ifNil: [
		^ self rejectedWithSource: sourceValue destination: destinationValue because: 'Every moved object must occur exactly once in the source relation.' ].

	(sourceMemento ~~ destinationMemento and: [
		movedObjects anySatisfy: [ :anObject |
			sourceMemento hasChildMementoFor: anObject inRelation: sourceDescription ] ]) ifTrue: [
		^ self rejectedWithSource: sourceValue destination: destinationValue because: 'A move between distinct editing transactions cannot transfer active embedded editing state.' ].

	(movedObjects anySatisfy: [ :anObject | self destinationValue: destinationValue alreadyContainsObject: anObject ]) ifTrue: [
		^ self rejectedWithSource: sourceValue destination: destinationValue because: 'A moved object is already present in the destination relation.' ].

	(destinationDescription isMultiple not and: [ destinationValue notNil ]) ifTrue: [
		^ self rejectedWithSource: sourceValue destination: destinationValue because: 'A to-one destination must be empty for a move.' ].

	(self destinationIndexIsValidFor: destinationValue) ifFalse: [
		^ self rejectedWithSource: sourceValue destination: destinationValue because: self destinationIndexRejectionMessage ].

	proposedSourceValue := self sourceValueByRemovingObjects: movedObjects from: sourceValue.
	proposedDestinationValue := self destinationValueByAddingObjects: movedObjects to: destinationValue.

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
	| movedObjects |
	movedObjects := self movedObjectsInSourceOrderFrom: anAssessment sourceItems.
	sourceMemento
		write: anAssessment proposedSourceItems
		using: sourceDescription.
	destinationMemento
		write: anAssessment proposedDestinationItems
		using: destinationDescription.
	movedObjects do: [ :anObject |
		sourceMemento
			transferChildMementoFor: anObject
			inRelation: sourceDescription
			to: destinationMemento
			inRelation: destinationDescription ]
]

{ #category : 'private - assessing' }
CFAtelierMove >> movedObjectsInSourceOrderFrom: sourceValue [
	objects size = 1 ifTrue: [
		^ (self sourceValue: sourceValue containsObjectExactlyOnce: objects first)
			ifTrue: [ objects copy ]
			ifFalse: [ nil ] ].
	sourceValue ifNil: [ ^ nil ].
	(objects allSatisfy: [ :anObject | (sourceValue count: [ :each | each == anObject ]) = 1 ]) ifFalse: [ ^ nil ].
	^ sourceValue select: [ :each | objects identityIncludes: each ]
]

{ #category : 'private - assessing' }
CFAtelierMove >> hasDuplicateObjectIdentities: someObjects [
	1 to: someObjects size do: [ :firstIndex |
		firstIndex + 1 to: someObjects size do: [ :secondIndex |
			((someObjects at: firstIndex) == (someObjects at: secondIndex)) ifTrue: [ ^ true ] ] ].
	^ false
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
CFAtelierMove >> sourceValueByRemovingObjects: someObjects from: aValue [
	sourceDescription isMultiple ifFalse: [ ^ nil ].
	^ aValue species withAll: (aValue reject: [ :each | someObjects identityIncludes: each ])
]

{ #category : 'private - assessing' }
CFAtelierMove >> destinationValueByAddingObjects: someObjects to: aValue [
	| theItems |
	destinationDescription isMultiple ifFalse: [ ^ someObjects first ].
	destinationDescription isOrdered
		ifTrue: [ ^ self insertingObjects: someObjects at: destinationIndex into: aValue ].
	theItems := aValue species withAll: aValue.
	theItems addAll: someObjects.
	^ theItems
]

{ #category : 'private' }
CFAtelierMove >> insertingObjects: someObjects at: anIndex into: aCollection [
	| theItems |
	theItems := OrderedCollection new: aCollection size + someObjects size.
	1 to: aCollection size + 1 do: [ :eachIndex |
		eachIndex = anIndex ifTrue: [ theItems addAll: someObjects ].
		eachIndex <= aCollection size ifTrue: [ theItems add: (aCollection at: eachIndex) ] ].
	^ aCollection species withAll: theItems
]

{ #category : 'accessing' }
CFAtelierMove >> object [
	^ objects size = 1 ifTrue: [ objects first ] ifFalse: [ nil ]
]
{ #category : 'accessing' }
CFAtelierMove >> object: anObject [ objects := { anObject } ]
{ #category : 'accessing' }
CFAtelierMove >> objects [ ^ objects ]
{ #category : 'accessing' }
CFAtelierMove >> objects: someObjects [ objects := someObjects asArray ]
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
{ #category : 'accessing' }
CFAtelierMove >> sourceDescription [ ^ sourceDescription ]
{ #category : 'accessing' }
CFAtelierMove >> sourceDescription: aDescription [ sourceDescription := aDescription ]
{ #category : 'accessing' }
CFAtelierMove >> sourceMemento [ ^ sourceMemento ]
{ #category : 'accessing' }
CFAtelierMove >> sourceMemento: aMemento [ sourceMemento := aMemento ]

{ #category : 'private' }
CFAtelierMove >> rejectedWithSource: sourceValue destination: destinationValue because: aString [
	^ CFAtelierMoveAssessment
		sourceItems: sourceValue
		destinationItems: destinationValue
		rejectedBecause: aString
]
