"I coordinate insertion of one supplied object into an existing to-many Magritte relation.

I am deliberately about insertion, not materialisation. A palette/provider may materialise a candidate before constructing me, but I receive the candidate object itself. Assessment reads the current staged relation value, derives the complete proposed replacement collection, validates it without mutation and records the exact insertion index. apply uses CFAtelierOperation's mandatory fresh reassessment immediately before the single Magritte write.

An explicit index is required for ordered relations. Unordered relations append without inventing positional semantics. I reject inserting an identity already present in the target relation because Atelier relation operations and embedded child editing contexts address members by object identity."
Class {
	#name : 'CFAtelierInsert',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'object',
		'memento',
		'description',
		'insertionIndex'
	],
	#category : 'BVC-Foundation-Atelier-Insertion',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'Insertion'
}

{ #category : 'instance creation' }
CFAtelierInsert class >> object: anObject memento: aMemento description: aDescription [
	^ self new
		object: anObject;
		memento: aMemento;
		description: aDescription;
		yourself
]

{ #category : 'instance creation' }
CFAtelierInsert class >> object: anObject memento: aMemento description: aDescription at: anIndex [
	^ self new
		object: anObject;
		memento: aMemento;
		description: aDescription;
		insertionIndex: anIndex;
		yourself
]

{ #category : 'assessing' }
CFAtelierInsert >> assess [
	| items proposedItems effectiveIndex |
	items := memento readUsing: description.

	items ifNil: [ ^ self rejectedWithItems: items because: 'The target relation has no collection.' ].
	description isReadOnly
		ifTrue: [ ^ self rejectedWithItems: items because: 'The target relation is read-only.' ].
	description isMultiple
		ifFalse: [ ^ self rejectedWithItems: items because: 'Insertion requires a to-many relation.' ].
	(items anySatisfy: [ :each | each == object ])
		ifTrue: [ ^ self rejectedWithItems: items because: 'The inserted object is already present in the target relation.' ].

	description isOrdered
		ifTrue: [
			insertionIndex ifNil: [ ^ self rejectedWithItems: items because: 'An ordered relation requires an insertion index.' ].
			(insertionIndex between: 1 and: items size + 1)
				ifFalse: [ ^ self rejectedWithItems: items because: 'The insertion index is outside the target relation.' ].
			effectiveIndex := insertionIndex ]
		ifFalse: [
			insertionIndex ifNotNil: [ ^ self rejectedWithItems: items because: 'An unordered relation does not accept an insertion index.' ].
			effectiveIndex := items size + 1 ].

	proposedItems := items species withAll: items.
	proposedItems add: object beforeIndex: effectiveIndex.

	[ description validate: proposedItems ]
		on: Error
		do: [ :anException |
			^ self rejectedWithItems: items because: anException printString ].

	^ CFAtelierInsertAssessment
		object: object
		items: items
		proposedItems: proposedItems
		insertionIndex: effectiveIndex
]

{ #category : 'applying' }
CFAtelierInsert >> applyAssessment: anAssessment [
	memento
		write: anAssessment proposedItems
		using: description.
	memento
		reattachDetachedChildMementoFor: object
		inRelation: description
]

{ #category : 'accessing' }
CFAtelierInsert >> description [ ^ description ]
{ #category : 'accessing' }
CFAtelierInsert >> description: aDescription [ description := aDescription ]
{ #category : 'accessing' }
CFAtelierInsert >> insertionIndex [ ^ insertionIndex ]
{ #category : 'accessing' }
CFAtelierInsert >> insertionIndex: anInteger [ insertionIndex := anInteger ]
{ #category : 'accessing' }
CFAtelierInsert >> memento [ ^ memento ]
{ #category : 'accessing' }
CFAtelierInsert >> memento: aMemento [ memento := aMemento ]
{ #category : 'accessing' }
CFAtelierInsert >> object [ ^ object ]
{ #category : 'accessing' }
CFAtelierInsert >> object: anObject [ object := anObject ]

{ #category : 'private' }
CFAtelierInsert >> rejectedWithItems: items because: aString [
	^ CFAtelierInsertAssessment
		object: object
		items: items
		rejectedBecause: aString
]
