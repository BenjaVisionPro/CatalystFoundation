"I coordinate reordering one or more existing objects within one ordered to-many Magritte relation.

Assessment reads the current staged relation value, resolves the dragged objects by identity in their existing relation order, derives the complete proposed replacement collection and validates it without mutation. destinationIndex is the first index occupied by the moved group in the final collection. apply uses CFAtelierOperation's mandatory fresh reassessment immediately before the single Magritte write.

I intentionally operate on object identity rather than equality and do not own drag geometry or relative before/after UI semantics. A presentation can translate its interaction into the explicit final index I require."
Class {
	#name : 'CFAtelierReorder',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'objects',
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
	^ self
		objects: { anObject }
		memento: aMemento
		description: aDescription
		to: anIndex
]

{ #category : 'instance creation' }
CFAtelierReorder class >> objects: someObjects memento: aMemento description: aDescription to: anIndex [
	^ self new
		objects: someObjects;
		memento: aMemento;
		description: aDescription;
		destinationIndex: anIndex;
		yourself
]

{ #category : 'assessing' }
CFAtelierReorder >> assess [
	| items draggedItems remainingItems reorderedItems proposedItems sourceIndices |
	items := memento readUsing: description.

	items ifNil: [ ^ self rejectedWithItems: items because: 'The target relation has no collection.' ].
	description isReadOnly
		ifTrue: [ ^ self rejectedWithItems: items because: 'The target relation is read-only.' ].
	description isMultiple
		ifFalse: [ ^ self rejectedWithItems: items because: 'Reordering requires a to-many relation.' ].
	description isOrdered
		ifFalse: [ ^ self rejectedWithItems: items because: 'Reordering requires an ordered relation.' ].
	objects ifNil: [ ^ self rejectedWithItems: items because: 'At least one object is required for reordering.' ].
	objects isEmpty ifTrue: [ ^ self rejectedWithItems: items because: 'At least one object is required for reordering.' ].

	objects do: [ :anObject |
		(items count: [ :each | each == anObject ]) = 1
			ifFalse: [ ^ self rejectedWithItems: items because: (objects size = 1
				ifTrue: [ 'The reordered object must occur exactly once in the relation.' ]
				ifFalse: [ 'Each reordered object must occur exactly once in the relation.' ]) ].
		(objects count: [ :each | each == anObject ]) = 1
			ifFalse: [ ^ self rejectedWithItems: items because: 'The reordered objects must contain unique identities.' ] ].

	draggedItems := items select: [ :each |
		objects anySatisfy: [ :anObject | anObject == each ] ].
	remainingItems := items reject: [ :each |
		draggedItems anySatisfy: [ :anObject | anObject == each ] ].
	((destinationIndex isInteger) and: [ destinationIndex between: 1 and: remainingItems size + 1 ])
		ifFalse: [ ^ self rejectedWithItems: items because: 'The destination index is outside the final relation.' ].

	reorderedItems := OrderedCollection new.
	remainingItems withIndexDo: [ :each :anIndex |
		anIndex = destinationIndex ifTrue: [ reorderedItems addAll: draggedItems ].
		reorderedItems add: each ].
	destinationIndex = (remainingItems size + 1) ifTrue: [ reorderedItems addAll: draggedItems ].
	proposedItems := items species withAll: reorderedItems.
	(self identityMatches: items second: proposedItems)
		ifTrue: [ ^ self rejectedWithItems: items because: 'The objects are already at the requested position.' ].

	[ description validate: proposedItems ]
		on: Error
		do: [ :anException |
			^ self rejectedWithItems: items because: anException printString ].

	sourceIndices := draggedItems collect: [ :anObject | items identityIndexOf: anObject ].
	^ CFAtelierReorderAssessment
		objects: draggedItems
		items: items
		proposedItems: proposedItems
		sourceIndices: sourceIndices
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
CFAtelierReorder >> object [
	^ objects ifNotNil: [ objects size = 1 ifTrue: [ objects first ] ]
]
{ #category : 'accessing' }
CFAtelierReorder >> object: anObject [ objects := { anObject } ]
{ #category : 'accessing' }
CFAtelierReorder >> objects [ ^ objects ]
{ #category : 'accessing' }
CFAtelierReorder >> objects: someObjects [ objects := someObjects ]

{ #category : 'private' }
CFAtelierReorder >> identityMatches: firstCollection second: secondCollection [
	firstCollection size = secondCollection size ifFalse: [ ^ false ].
	1 to: firstCollection size do: [ :anIndex |
		((firstCollection at: anIndex) == (secondCollection at: anIndex))
			ifFalse: [ ^ false ] ].
	^ true
]

{ #category : 'private' }
CFAtelierReorder >> rejectedWithItems: items because: aString [
	^ CFAtelierReorderAssessment
		objects: objects
		items: items
		rejectedBecause: aString
]
