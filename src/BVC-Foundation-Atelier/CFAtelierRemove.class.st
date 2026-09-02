"I coordinate removing one existing object from one Magritte relation.

For a to-many relation I remove exactly one occurrence by identity and stage the complete replacement collection. For a to-one relation I clear the value only when the current staged value is the exact object identity. Assessment validates the complete proposed value without mutation and apply uses CFAtelierOperation's mandatory fresh reassessment before the single Magritte write.

I deliberately describe only the local relation edit. Domain operations with wider consequences, such as Process node removal also removing incident edges, remain domain operations rather than being hidden inside me."
Class {
	#name : 'CFAtelierRemove',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'object',
		'memento',
		'description'
	],
	#category : 'BVC-Foundation-Atelier-Removal',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'Removal'
}

{ #category : 'instance creation' }
CFAtelierRemove class >> object: anObject memento: aMemento description: aDescription [
	^ self new
		object: anObject;
		memento: aMemento;
		description: aDescription;
		yourself
]

{ #category : 'assessing' }
CFAtelierRemove >> assess [
	| current proposed |
	current := memento readUsing: description.
	description isReadOnly
		ifTrue: [ ^ self rejectedWithCurrentValue: current because: 'The target relation is read-only.' ].

	description isMultiple
		ifTrue: [
			current ifNil: [ ^ self rejectedWithCurrentValue: current because: 'The target relation has no collection.' ].
			(current count: [ :each | each == object ]) = 1
				ifFalse: [ ^ self rejectedWithCurrentValue: current because: 'The removed object must occur exactly once in the relation.' ].
			proposed := current species withAll: (current reject: [ :each | each == object ]) ]
		ifFalse: [
			current == object
				ifFalse: [ ^ self rejectedWithCurrentValue: current because: 'The removed object is not the current relation value.' ].
			proposed := nil ].

	[ description validate: proposed ]
		on: Error
		do: [ :anException |
			^ self rejectedWithCurrentValue: current because: anException printString ].

	^ CFAtelierRemoveAssessment
		object: object
		currentValue: current
		proposedValue: proposed
]

{ #category : 'applying' }
CFAtelierRemove >> applyAssessment: anAssessment [
	memento write: anAssessment proposedValue using: description
]

{ #category : 'accessing' }
CFAtelierRemove >> object [ ^ object ]
{ #category : 'accessing' }
CFAtelierRemove >> object: anObject [ object := anObject ]
{ #category : 'accessing' }
CFAtelierRemove >> memento [ ^ memento ]
{ #category : 'accessing' }
CFAtelierRemove >> memento: aMemento [ memento := aMemento ]
{ #category : 'accessing' }
CFAtelierRemove >> description [ ^ description ]
{ #category : 'accessing' }
CFAtelierRemove >> description: aDescription [ description := aDescription ]

{ #category : 'private' }
CFAtelierRemove >> rejectedWithCurrentValue: aValue because: aString [
	^ CFAtelierRemoveAssessment
		object: object
		currentValue: aValue
		rejectedBecause: aString
]
