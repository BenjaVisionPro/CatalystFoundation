"I coordinate replacing one existing object with one supplied object in a Magritte relation.

For a to-one relation I replace the staged related object directly. For a to-many relation I locate the existing object by identity, derive the complete proposed relation value and preserve its position when the relation is ordered. Unordered relations preserve only membership semantics. Assessment validates the proposed value without mutation; apply uses CFAtelierOperation's mandatory fresh reassessment immediately before the single Magritte write.

I am deliberately about replacement, not materialisation. The replacement object may come from any Atelier provider or client-specific workflow before I am constructed."
Class {
	#name : 'CFAtelierReplace',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'object',
		'replacementObject',
		'memento',
		'description'
	],
	#category : 'BVC-Foundation-Atelier-Replacement',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'Replacement'
}

{ #category : 'instance creation' }
CFAtelierReplace class >> object: anObject with: replacementObject memento: aMemento description: aDescription [
	^ self new
		object: anObject;
		replacementObject: replacementObject;
		memento: aMemento;
		description: aDescription;
		yourself
]

{ #category : 'assessing' }
CFAtelierReplace >> assess [
	| currentValue proposedValue replacementIndex |
	currentValue := memento readUsing: description.

	description isReadOnly
		ifTrue: [ ^ self rejectedWithCurrentValue: currentValue because: 'The target relation is read-only.' ].
	object == replacementObject
		ifTrue: [ ^ self rejectedWithCurrentValue: currentValue because: 'Replacement requires a different object identity.' ].

	description isMultiple
		ifTrue: [
			currentValue ifNil: [ ^ self rejectedWithCurrentValue: currentValue because: 'The target relation has no collection.' ].
			(currentValue count: [ :each | each == object ]) = 1
				ifFalse: [ ^ self rejectedWithCurrentValue: currentValue because: 'The replaced object must occur exactly once in the relation.' ].

			description isOrdered
				ifTrue: [
					replacementIndex := currentValue identityIndexOf: object.
					proposedValue := currentValue species withAll: currentValue.
					proposedValue at: replacementIndex put: replacementObject ]
				ifFalse: [
					proposedValue := currentValue species withAll: (currentValue reject: [ :each | each == object ]).
					proposedValue add: replacementObject ] ]
		ifFalse: [
			currentValue == object
				ifFalse: [ ^ self rejectedWithCurrentValue: currentValue because: 'The replaced object is not the current relation value.' ].
			proposedValue := replacementObject ].

	[ description validate: proposedValue ]
		on: Error
		do: [ :anException |
			^ self rejectedWithCurrentValue: currentValue because: anException printString ].

	^ CFAtelierReplaceAssessment
		object: object
		replacementObject: replacementObject
		currentValue: currentValue
		proposedValue: proposedValue
		replacementIndex: replacementIndex
]

{ #category : 'applying' }
CFAtelierReplace >> applyAssessment: anAssessment [
	memento
		write: anAssessment proposedValue
		using: description.
	memento
		detachChildMementoFor: object
		inRelation: description
]

{ #category : 'accessing' }
CFAtelierReplace >> description [ ^ description ]
{ #category : 'accessing' }
CFAtelierReplace >> description: aDescription [ description := aDescription ]
{ #category : 'accessing' }
CFAtelierReplace >> memento [ ^ memento ]
{ #category : 'accessing' }
CFAtelierReplace >> memento: aMemento [ memento := aMemento ]
{ #category : 'accessing' }
CFAtelierReplace >> object [ ^ object ]
{ #category : 'accessing' }
CFAtelierReplace >> object: anObject [ object := anObject ]
{ #category : 'accessing' }
CFAtelierReplace >> replacementObject [ ^ replacementObject ]
{ #category : 'accessing' }
CFAtelierReplace >> replacementObject: anObject [ replacementObject := anObject ]

{ #category : 'private' }
CFAtelierReplace >> rejectedWithCurrentValue: currentValue because: aString [
	^ CFAtelierReplaceAssessment
		object: object
		replacementObject: replacementObject
		currentValue: currentValue
		rejectedBecause: aString
]
