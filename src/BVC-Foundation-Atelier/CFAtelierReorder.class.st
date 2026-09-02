"I coordinate reordering one existing object within one ordered to-many Magritte relation.

Assessment reads the current staged relation value, locates the object by identity, derives the complete proposed replacement collection and validates it without mutation. destinationIndex is the object's index in the final collection. apply uses CFAtelierOperation's mandatory fresh reassessment immediately before the single Magritte write.

I intentionally operate on object identity rather than equality and do not own drag geometry or relative before/after UI semantics. A presentation can translate its interaction into the explicit final index I require."
Class {
	#name : 'CFAtelierReorder',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'object',
		'memento',
		'description',
		'destinationIndex'
	],
	#category : 'BVC-Foundation-Atelier-Reorder',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'Reorder'
}

{ #category : 'instance creation' }
CFAtelierReorder class >> object: anObject memento: aMemento description: aDescription to: anIndex [
	^ self new
		object: anObject;
		memento: aMemento;
		description: aDescription;
		destinationIndex: anIndex;
		yourself
]

{ #category : 'assessing' }
CFAtelierReorder >> assess [
	| items sourceIndex remainingItems proposedItems |
	items := memento readUsing: description.

	items ifNil: [ ^ self rejectedWithItems: items because: 'The target relation has no collection.' ].
	description isReadOnly
		ifTrue: [ ^ self rejectedWithItems: items because: 'The target relation is read-only.' ].
	description isMultiple
		ifFalse: [ ^ self rejectedWithItems: items because: 'Reordering requires a to-many relation.' ].
	description isOrdered
		ifFalse: [ ^ self rejectedWithItems: items because: 'Reordering requires an ordered relation.' ].

	(items count: [ :each | each == object ]) = 1
		ifFalse: [ ^ self rejectedWithItems: items because: 'The reordered object must occur exactly once in the relation.' ].
	((destinationIndex isInteger) and: [ destinationIndex between: 1 and: items size ])
		ifFalse: [ ^ self rejectedWithItems: items because: 'The destination index is outside the current relation.' ].

	sourceIndex := items identityIndexOf: object.
	sourceIndex = destinationIndex
		ifTrue: [ ^ self rejectedWithItems: items because: 'The object is already at the requested index.' ].

	remainingItems := items species withAll: (items reject: [ :each | each == object ]).
	proposedItems := remainingItems species withAll: remainingItems.
	proposedItems add: object beforeIndex: destinationIndex.

	[ description validate: proposedItems ]
		on: Error
		do: [ :anException |
			^ self rejectedWithItems: items because: anException printString ].

	^ CFAtelierReorderAssessment
		object: object
		items: items
		proposedItems: proposedItems
		sourceIndex: sourceIndex
		destinationIndex: destinationIndex
]

{ #category : 'applying' }
CFAtelierReorder >> applyAssessment: anAssessment [
	memento
		write: anAssessment proposedItems
		using: description
]

{ #category : 'accessing' }
CFAtelierReorder >> description [ ^ description ]
{ #category : 'accessing' }
CFAtelierReorder >> description: aDescription [ description := aDescription ]
{ #category : 'accessing' }
CFAtelierReorder >> destinationIndex [ ^ destinationIndex ]
{ #category : 'accessing' }
CFAtelierReorder >> destinationIndex: anInteger [ destinationIndex := anInteger ]
{ #category : 'accessing' }
CFAtelierReorder >> memento [ ^ memento ]
{ #category : 'accessing' }
CFAtelierReorder >> memento: aMemento [ memento := aMemento ]
{ #category : 'accessing' }
CFAtelierReorder >> object [ ^ object ]
{ #category : 'accessing' }
CFAtelierReorder >> object: anObject [ object := anObject ]

{ #category : 'private' }
CFAtelierReorder >> rejectedWithItems: items because: aString [
	^ CFAtelierReorderAssessment
		object: object
		items: items
		rejectedBecause: aString
]
