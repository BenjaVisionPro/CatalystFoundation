"I coordinate copying one existing relation object into another Magritte relation editing context.

I do not decide how a copy is made. copiedObject is a distinct, already-materialized candidate supplied by the client before this operation is created. This keeps object copying/decoding/domain initialization outside Atelier while giving Atelier an explicit copy intention rather than disguising copy as move or reference.

The source may be to-one or to-many and is never mutated. A to-many destination follows its ordered/unordered insertion semantics. A to-one destination must currently be empty: replacing an existing destination object would be a replace intention, not a pure copy.

Assessment verifies that the source identity still occurs exactly once, that the supplied copy is a different identity, derives the complete proposed destination value and validates it without mutation. apply reassesses immediately before staging the destination write."
Class {
	#name : 'CFAtelierCopy',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'sourceObject',
		'copiedObject',
		'sourceMemento',
		'sourceDescription',
		'destinationMemento',
		'destinationDescription',
		'destinationIndex'
	],
	#category : 'BVC-Foundation-Atelier-Copy',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'Copy'
}

{ #category : 'instance creation' }
CFAtelierCopy class >> sourceObject: aSourceObject copiedObject: aCopiedObject sourceMemento: aSourceMemento sourceDescription: aSourceDescription destinationMemento: aDestinationMemento destinationDescription: aDestinationDescription destinationIndex: anIndex [
	^ self new
		sourceObject: aSourceObject;
		copiedObject: aCopiedObject;
		sourceMemento: aSourceMemento;
		sourceDescription: aSourceDescription;
		destinationMemento: aDestinationMemento;
		destinationDescription: aDestinationDescription;
		destinationIndex: anIndex;
		yourself
]

{ #category : 'assessing' }
CFAtelierCopy >> assess [
	| sourceValue destinationValue proposedDestinationValue |
	sourceValue := sourceMemento readUsing: sourceDescription.
	destinationValue := destinationMemento readUsing: destinationDescription.

	destinationDescription isReadOnly
		ifTrue: [ ^ self rejectedWithSource: sourceValue destination: destinationValue because: 'The destination relation is read-only.' ].

	(self sourceValue: sourceValue containsObjectExactlyOnce: sourceObject) ifFalse: [
		^ self rejectedWithSource: sourceValue destination: destinationValue because: 'The copied source object must occur exactly once in the source relation.' ].
	copiedObject == sourceObject
		ifTrue: [ ^ self rejectedWithSource: sourceValue destination: destinationValue because: 'Copy requires a distinct materialized object identity; reusing the source identity is reference, not copy.' ].
	(self destinationValue: destinationValue alreadyContainsObject: copiedObject) ifTrue: [
		^ self rejectedWithSource: sourceValue destination: destinationValue because: 'The materialized copy is already present in the destination relation.' ].
	(destinationDescription isMultiple not and: [ destinationValue notNil ]) ifTrue: [
		^ self rejectedWithSource: sourceValue destination: destinationValue because: 'A to-one destination must be empty for a copy.' ].
	(self destinationIndexIsValidFor: destinationValue) ifFalse: [
		^ self rejectedWithSource: sourceValue destination: destinationValue because: self destinationIndexRejectionMessage ].

	proposedDestinationValue := self destinationValueByAddingObject: copiedObject to: destinationValue.
	[ destinationDescription validate: proposedDestinationValue ]
		on: MAValidationError
		do: [ :anException |
			^ self rejectedWithSource: sourceValue destination: destinationValue because: anException printString ].

	^ CFAtelierCopyAssessment
		sourceObject: sourceObject
		copiedObject: copiedObject
		sourceItems: sourceValue
		destinationItems: destinationValue
		proposedDestinationItems: proposedDestinationValue
		destinationIndex: destinationIndex
]

{ #category : 'applying' }
CFAtelierCopy >> applyAssessment: anAssessment [
	destinationMemento write: anAssessment proposedDestinationItems using: destinationDescription
]

{ #category : 'private - assessing' }
CFAtelierCopy >> sourceValue: aValue containsObjectExactlyOnce: anObject [
	sourceDescription isMultiple ifFalse: [ ^ aValue == anObject ].
	aValue ifNil: [ ^ false ].
	^ (aValue count: [ :each | each == anObject ]) = 1
]

{ #category : 'private - assessing' }
CFAtelierCopy >> destinationValue: aValue alreadyContainsObject: anObject [
	destinationDescription isMultiple ifFalse: [ ^ aValue == anObject ].
	aValue ifNil: [ ^ false ].
	^ aValue anySatisfy: [ :each | each == anObject ]
]

{ #category : 'private - assessing' }
CFAtelierCopy >> destinationIndexIsValidFor: aValue [
	destinationDescription isMultiple ifFalse: [ ^ destinationIndex isNil ].
	aValue ifNil: [ ^ false ].
	destinationDescription isOrdered ifFalse: [ ^ destinationIndex isNil ].
	^ destinationIndex isInteger
		and: [ destinationIndex between: 1 and: aValue size + 1 ]
]

{ #category : 'private - assessing' }
CFAtelierCopy >> destinationIndexRejectionMessage [
	destinationDescription isMultiple ifFalse: [ ^ 'A to-one destination does not accept an insertion index.' ].
	destinationDescription isOrdered ifFalse: [ ^ 'An unordered destination does not accept an insertion index.' ].
	^ 'The destination index is outside the current destination relation.'
]

{ #category : 'private - assessing' }
CFAtelierCopy >> destinationValueByAddingObject: anObject to: aValue [
	| theItems |
	destinationDescription isMultiple ifFalse: [ ^ anObject ].
	destinationDescription isOrdered
		ifTrue: [ ^ self inserting: anObject at: destinationIndex into: aValue ].
	theItems := aValue species withAll: aValue.
	theItems add: anObject.
	^ theItems
]

{ #category : 'private' }
CFAtelierCopy >> inserting: anObject at: anIndex into: aCollection [
	| theItems |
	theItems := OrderedCollection new: aCollection size + 1.
	1 to: aCollection size + 1 do: [ :eachIndex |
		eachIndex = anIndex ifTrue: [ theItems add: anObject ].
		eachIndex <= aCollection size ifTrue: [ theItems add: (aCollection at: eachIndex) ] ].
	^ aCollection species withAll: theItems
]

{ #category : 'private' }
CFAtelierCopy >> rejectedWithSource: sourceValue destination: destinationValue because: aString [
	^ CFAtelierCopyAssessment
		sourceObject: sourceObject
		copiedObject: copiedObject
		sourceItems: sourceValue
		destinationItems: destinationValue
		rejectedBecause: aString
]

{ #category : 'accessing' }
CFAtelierCopy >> sourceObject [ ^ sourceObject ]
{ #category : 'accessing' }
CFAtelierCopy >> sourceObject: anObject [ sourceObject := anObject ]
{ #category : 'accessing' }
CFAtelierCopy >> copiedObject [ ^ copiedObject ]
{ #category : 'accessing' }
CFAtelierCopy >> copiedObject: anObject [ copiedObject := anObject ]
{ #category : 'accessing' }
CFAtelierCopy >> sourceMemento [ ^ sourceMemento ]
{ #category : 'accessing' }
CFAtelierCopy >> sourceMemento: aMemento [ sourceMemento := aMemento ]
{ #category : 'accessing' }
CFAtelierCopy >> sourceDescription [ ^ sourceDescription ]
{ #category : 'accessing' }
CFAtelierCopy >> sourceDescription: aDescription [ sourceDescription := aDescription ]
{ #category : 'accessing' }
CFAtelierCopy >> destinationMemento [ ^ destinationMemento ]
{ #category : 'accessing' }
CFAtelierCopy >> destinationMemento: aMemento [ destinationMemento := aMemento ]
{ #category : 'accessing' }
CFAtelierCopy >> destinationDescription [ ^ destinationDescription ]
{ #category : 'accessing' }
CFAtelierCopy >> destinationDescription: aDescription [ destinationDescription := aDescription ]
{ #category : 'accessing' }
CFAtelierCopy >> destinationIndex [ ^ destinationIndex ]
{ #category : 'accessing' }
CFAtelierCopy >> destinationIndex: anInteger [ destinationIndex := anInteger ]
