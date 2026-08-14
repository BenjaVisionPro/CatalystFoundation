"I am responsible for extending a GT Magritte transaction across embedded relation objects."

Class {
	#name : 'CFMaMemento',
	#superclass : 'GtMagritteMemento',
	#instVars : [
		'childMementosByDescription'
	],
	#category : 'BVC-Foundation-Magritte-GT-Models',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Models'
}

{ #category : 'initialization' }
CFMaMemento >> initialize [
	super initialize.
	childMementosByDescription := Dictionary new
]

{ #category : 'private - children' }
CFMaMemento >> allChildMementos [
	^ Array streamContents: [ :aStream |
		childMementosByDescription valuesDo: [ :aDictionary |
			aDictionary valuesDo: [ :aMemento | aStream nextPut: aMemento ] ] ]
]

{ #category : 'children' }
CFMaMemento >> childMementoFor: anObject inRelation: aDescription [
	| theRelationMementos |
	theRelationMementos := childMementosByDescription
		at: aDescription
		ifAbsentPut: [ IdentityDictionary new ].

	^ theRelationMementos
		at: anObject
		ifAbsentPut: [
			| aMemento |
			aMemento := self class model: anObject.
			aMemento overallStatus observe: internalStatus.
			aMemento ]
]

{ #category : 'children' }
CFMaMemento >> retainChildMementosFor: aCollection inRelation: aDescription [
	| theRelationMementos |
	theRelationMementos := childMementosByDescription
		at: aDescription
		ifAbsent: [ ^ self ].

	theRelationMementos keys copy do: [ :anObject |
		(aCollection identityIncludes: anObject)
			ifFalse: [ theRelationMementos removeKey: anObject ifAbsent: [ ] ] ].

	theRelationMementos ifEmpty: [
		childMementosByDescription removeKey: aDescription ifAbsent: [ ] ]
]

{ #category : 'private - status' }
CFMaMemento >> computeOverallStatus: anInternalStatus [
	| aStatus theChildStatuses |
	aStatus := super computeOverallStatus: anInternalStatus.
	theChildStatuses := self allChildMementos
		collect: [ :aMemento | aMemento overallStatus valueOrNil ].
	theChildStatuses := theChildStatuses reject: #isNil.

	theChildStatuses ifNotEmpty: [
		aStatus
			isValid: (aStatus isValid
				and: [ theChildStatuses allSatisfy: #isValid ]);
			isChanged: (aStatus isChanged
				or: [ theChildStatuses anySatisfy: #isChanged ]) ].

	^ aStatus
]

{ #category : 'actions' }
CFMaMemento >> commit [
	self allChildMementos do: [ :aMemento | aMemento commit ].
	^ super commit
]

{ #category : 'actions' }
CFMaMemento >> reset [
	self allChildMementos do: [ :aMemento | aMemento reset ].
	^ super reset
]
