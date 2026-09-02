"I coordinate removing one or more existing objects from one Magritte relation.

For a to-many relation I remove the requested identities as one editing intention and stage one complete replacement collection. Every requested object must occur exactly once and the request itself may not contain duplicate identities. For a to-one relation exactly one object must be requested and I clear the value only when the current staged value is that exact identity.

Assessment validates the complete proposed value without mutation and apply uses CFAtelierOperation's mandatory fresh reassessment before the single Magritte write. Existing embedded child mementos for removed objects are detached transactionally after the write.

I deliberately describe only the local relation edit. Domain operations with wider consequences, such as Process node removal also removing incident edges, remain domain operations rather than being hidden inside me."
Class {
	#name : 'CFAtelierRemove',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'objects',
		'memento',
		'description'
	],
	#category : 'BVC-Foundation-Atelier-Removal',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'Removal'
}

{ #category : 'instance creation' }
CFAtelierRemove class >> object: anObject memento: aMemento description: aDescription [
	^ self
		objects: { anObject }
		memento: aMemento
		description: aDescription
]

{ #category : 'instance creation' }
CFAtelierRemove class >> objects: someObjects memento: aMemento description: aDescription [
	^ self new
		objects: someObjects;
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
	objects ifEmpty: [ ^ self rejectedWithCurrentValue: current because: 'At least one object is required for removal.' ].
	(self hasDuplicateRequestedIdentity)
		ifTrue: [ ^ self rejectedWithCurrentValue: current because: 'Each removed object identity may be requested only once.' ].

	description isMultiple
		ifTrue: [
			current ifNil: [ ^ self rejectedWithCurrentValue: current because: 'The target relation has no collection.' ].
			objects do: [ :anObject |
				(current count: [ :each | each == anObject ]) = 1
					ifFalse: [ ^ self rejectedWithCurrentValue: current because: 'Every removed object must occur exactly once in the relation.' ] ].
			proposed := current species withAll: (current reject: [ :each |
				objects anySatisfy: [ :anObject | each == anObject ] ]) ]
		ifFalse: [
			objects size = 1
				ifFalse: [ ^ self rejectedWithCurrentValue: current because: 'A to-one relation can remove only its current object.' ].
			current == objects first
				ifFalse: [ ^ self rejectedWithCurrentValue: current because: 'The removed object is not the current relation value.' ].
			proposed := nil ].

	[ description validate: proposed ]
		on: Error
		do: [ :anException |
			^ self rejectedWithCurrentValue: current because: anException printString ].

	^ CFAtelierRemoveAssessment
		objects: objects
		currentValue: current
		proposedValue: proposed
]

{ #category : 'applying' }
CFAtelierRemove >> applyAssessment: anAssessment [
	memento write: anAssessment proposedValue using: description.
	objects do: [ :anObject |
		memento detachChildMementoFor: anObject inRelation: description ]
]

{ #category : 'private' }
CFAtelierRemove >> hasDuplicateRequestedIdentity [
	objects withIndexDo: [ :anObject :anIndex |
		(anIndex + 1 to: objects size) do: [ :anotherIndex |
			(anObject == (objects at: anotherIndex)) ifTrue: [ ^ true ] ] ].
	^ false
]

{ #category : 'accessing' }
CFAtelierRemove >> object [
	^ objects ifEmpty: [ nil ] ifNotEmpty: [ objects first ]
]

{ #category : 'accessing' }
CFAtelierRemove >> object: anObject [
	objects := { anObject }
]

{ #category : 'accessing' }
CFAtelierRemove >> objects [ ^ objects ]

{ #category : 'accessing' }
CFAtelierRemove >> objects: someObjects [
	objects := someObjects asArray
]

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
		objects: objects
		currentValue: aValue
		rejectedBecause: aString
]
