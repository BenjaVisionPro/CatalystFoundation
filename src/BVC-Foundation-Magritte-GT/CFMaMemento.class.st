"
I am responsible for extending a GT Magritte editing transaction across embedded relation objects.
"
Class {
	#name : 'CFMaMemento',
	#superclass : 'GtMagritteMemento',
	#instVars : [
		'childMementosByDescription',
		'statusPulse',
		'compositeOverallStatus'
	],
	#category : 'BVC-Foundation-Magritte-GT-Models',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Models'
}


{ #category : 'instance creation' }
CFMaMemento class >> model: anObject [
	^ self
		model: anObject
		description: anObject magritteDescription
]

{ #category : 'instance creation' }
CFMaMemento class >> model: anObject description: aDescription [
	^ super model: anObject description: aDescription
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
			aMemento overallStatus observe: statusPulse.
			statusPulse value: aMemento overallStatus valueOrNil.
			aMemento ]
]

{ #category : 'actions' }
CFMaMemento >> commit [
	self allChildMementos do: [ :aMemento | aMemento commit ].
	^ super commit
]

{ #category : 'private - status' }
CFMaMemento >> computeCompositeOverallStatus [
	| aParentStatus theChildStatuses |
	aParentStatus := super overallStatus valueOrNil.
	aParentStatus ifNil: [ ^ GtMagritteOverallStatus new ].

	theChildStatuses := self allChildMementos
		collect: [ :aMemento | aMemento overallStatus valueOrNil ].
	theChildStatuses := theChildStatuses reject: #isNil.

	^ GtMagritteOverallStatus new
		isValid: (aParentStatus isValid
			and: [ theChildStatuses allSatisfy: #isValid ]);
		isChanged: (aParentStatus isChanged
			or: [ theChildStatuses anySatisfy: #isChanged ]);
		executionStatus: aParentStatus executionStatus;
		yourself
]

{ #category : 'initialization' }
CFMaMemento >> initialize [
	super initialize.

	childMementosByDescription := Dictionary new.
	statusPulse := AsyncObservableValue
		executionConfiguration: GtMagritteBuilderUtility executionConfiguration.
	compositeOverallStatus := (statusPulse observe
		map: [ :anIgnoredValue | self computeCompositeOverallStatus ])
			asAsyncObservable: GtMagritteBuilderUtility executionConfiguration.

	super overallStatus observe: statusPulse
]

{ #category : 'accessing' }
CFMaMemento >> overallStatus [
	^ compositeOverallStatus
]

{ #category : 'actions' }
CFMaMemento >> reset [
	self allChildMementos do: [ :aMemento | aMemento reset ].
	^ super reset
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
		childMementosByDescription removeKey: aDescription ifAbsent: [ ] ].

	statusPulse value: super overallStatus valueOrNil
]

{ #category : 'actions' }
CFMaMemento >> revertUsing: aDescription [
	| anObservable aValue aFuture |
	anObservable := self readObservableValueUsing: aDescription.
	aValue := anObservable valueOrNil.
	aFuture := (self validatorUsing: aDescription) observeNext next.
	anObservable value: (aValue copyWithCurrentValue: aValue originalValue).
	^ aFuture
]
