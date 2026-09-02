"I coordinate copying one existing relation object into an ordered to-many destination relation.

I do not decide how a copy is made. copiedObject is a distinct, already-materialized candidate supplied by the client before this operation is created. This keeps object copying/decoding/domain initialization outside Atelier while giving Atelier an explicit copy intention rather than disguising copy as move or reference.

Assessment verifies that the source identity still occurs exactly once, that the supplied copy is a different identity, derives the complete proposed destination value and validates it without mutation. apply reassesses immediately before staging the one destination write."
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
	| sourceItems destinationItems proposedDestinationItems identityCount |
	sourceItems := sourceMemento readUsing: sourceDescription.
	destinationItems := destinationMemento readUsing: destinationDescription.

	sourceItems ifNil: [ ^ self rejectedWithSource: sourceItems destination: destinationItems because: 'The source relation has no collection value.' ].
	destinationItems ifNil: [ ^ self rejectedWithSource: sourceItems destination: destinationItems because: 'The destination relation has no collection value.' ].
	(sourceDescription isMultiple and: [ destinationDescription isMultiple ])
		ifFalse: [ ^ self rejectedWithSource: sourceItems destination: destinationItems because: 'A relation copy requires to-many relation descriptions.' ].
	destinationDescription isReadOnly
		ifTrue: [ ^ self rejectedWithSource: sourceItems destination: destinationItems because: 'The destination relation is read-only.' ].
	destinationDescription isOrdered
		ifFalse: [ ^ self rejectedWithSource: sourceItems destination: destinationItems because: 'An indexed destination requires an ordered relation.' ].

	identityCount := sourceItems count: [ :each | each == sourceObject ].
	identityCount = 1
		ifFalse: [ ^ self rejectedWithSource: sourceItems destination: destinationItems because: 'The copied source object must occur exactly once in the source relation.' ].
	copiedObject == sourceObject
		ifTrue: [ ^ self rejectedWithSource: sourceItems destination: destinationItems because: 'Copy requires a distinct materialized object identity; reusing the source identity is reference, not copy.' ].
	(destinationItems anySatisfy: [ :each | each == copiedObject ])
		ifTrue: [ ^ self rejectedWithSource: sourceItems destination: destinationItems because: 'The materialized copy is already present in the destination relation.' ].
	((destinationIndex isInteger) and: [ destinationIndex between: 1 and: destinationItems size + 1 ])
		ifFalse: [ ^ self rejectedWithSource: sourceItems destination: destinationItems because: 'The destination index is outside the current destination relation.' ].

	proposedDestinationItems := self inserting: copiedObject at: destinationIndex into: destinationItems.
	[ destinationDescription validate: proposedDestinationItems ]
		on: MAValidationError
		do: [ :anException |
			^ self rejectedWithSource: sourceItems destination: destinationItems because: anException printString ].

	^ CFAtelierCopyAssessment
		sourceObject: sourceObject
		copiedObject: copiedObject
		sourceItems: sourceItems
		destinationItems: destinationItems
		proposedDestinationItems: proposedDestinationItems
		destinationIndex: destinationIndex
]

{ #category : 'applying' }
CFAtelierCopy >> applyAssessment: anAssessment [
	destinationMemento write: anAssessment proposedDestinationItems using: destinationDescription
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
CFAtelierCopy >> rejectedWithSource: sourceItems destination: destinationItems because: aString [
	^ CFAtelierCopyAssessment
		sourceObject: sourceObject
		copiedObject: copiedObject
		sourceItems: sourceItems
		destinationItems: destinationItems
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
