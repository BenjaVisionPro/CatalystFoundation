"
I am responsible for extending a GT Magritte editing transaction across embedded relation objects. I preserve child editing identity across moves and keep relation removal/replacement transactional by detaching removed child mementos until commit or restoring them on reset.
"
Class {
	#name : 'CFMaMemento',
	#superclass : 'GtMagritteMemento',
	#instVars : [
		'childMementosByDescription',
		'statusPulse',
		'compositeOverallStatus',
		'childMementoTransfers',
		'detachedChildMementos',
		'childMementoReparentings'
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
CFMaMemento >> hasChildMementoFor: anObject inRelation: aDescription [
	| relationMementos |
	relationMementos := childMementosByDescription
		at: aDescription
		ifAbsent: [ ^ false ].
	^ relationMementos includesKey: anObject
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
			aMemento := self newChildMementoFor: anObject.
			aMemento overallStatus observe: statusPulse.
			statusPulse value: aMemento overallStatus valueOrNil.
			aMemento ]
]


{ #category : 'private - children' }
CFMaMemento >> newChildMementoFor: anObject [
	"Subclasses may specialize the memento used for embedded relation objects.
	By default, preserve the existing recursive memento-class behavior."
	^ self class model: anObject
]


{ #category : 'children' }
CFMaMemento >> detachChildMementoFor: anObject inRelation: aDescription [
	| childMemento |
	childMemento := self
		removeChildMementoFor: anObject
		inRelation: aDescription.
	childMemento ifNil: [ ^ self ].

	detachedChildMementos add: { anObject. aDescription. childMemento }.
	statusPulse value: super overallStatus valueOrNil
]


{ #category : 'children' }
CFMaMemento >> reattachDetachedChildMementoFor: anObject inRelation: aDescription [
	| detachment childMemento |
	detachment := detachedChildMementos
		detect: [ :each | each first == anObject and: [ each second == aDescription ] ]
		ifNone: [ ^ self ].
	childMemento := detachment third.
	detachedChildMementos remove: detachment.
	self
		putChildMemento: childMemento
		for: anObject
		inRelation: aDescription.
	statusPulse value: super overallStatus valueOrNil
]

{ #category : 'children' }
CFMaMemento >> transferChildMementoFor: anObject inRelation: aSourceDescription to: aDestinationMemento inRelation: aDestinationDescription [
	| childMemento |
	"A relation-scoped embedded memento is part of this parent editing transaction.
	Only re-key it when both relation contexts belong to this same transaction.
	Moving it to another parent memento would also move status/lifecycle ownership,
	which this protocol does not claim to do."
	aDestinationMemento == self ifFalse: [ ^ self ].
	childMemento := self
		removeChildMementoFor: anObject
		inRelation: aSourceDescription.
	childMemento ifNil: [ ^ self ].

	self
		putChildMemento: childMemento
		for: anObject
		inRelation: aDestinationDescription.
	childMementoTransfers add: { anObject. aSourceDescription. aDestinationDescription. childMemento }.
	statusPulse value: super overallStatus valueOrNil
]

{ #category : 'private - children' }
CFMaMemento >> removeChildMementoFor: anObject inRelation: aDescription [
	| relationMementos childMemento |
	relationMementos := childMementosByDescription
		at: aDescription
		ifAbsent: [ ^ nil ].
	childMemento := relationMementos
		at: anObject
		ifAbsent: [ ^ nil ].
	relationMementos removeKey: anObject.
	relationMementos ifEmpty: [
		childMementosByDescription removeKey: aDescription ifAbsent: [ ] ].
	^ childMemento
]

{ #category : 'private - children' }
CFMaMemento >> putChildMemento: aChildMemento for: anObject inRelation: aDescription [
	| relationMementos |
	relationMementos := childMementosByDescription
		at: aDescription
		ifAbsentPut: [ IdentityDictionary new ].
	relationMementos at: anObject put: aChildMemento.
	^ aChildMemento
]

{ #category : 'private - children' }
CFMaMemento >> restoreDetachedChildMementos [
	detachedChildMementos reverseDo: [ :aDetachment |
		| anObject description childMemento currentChild |
		anObject := aDetachment first.
		description := aDetachment second.
		childMemento := aDetachment third.
		currentChild := self
			removeChildMementoFor: anObject
			inRelation: description.
		(currentChild notNil and: [ currentChild ~~ childMemento ]) ifTrue: [
			self
				putChildMemento: currentChild
				for: anObject
				inRelation: description ].
		self
			putChildMemento: childMemento
			for: anObject
			inRelation: description ].
	detachedChildMementos removeAll.
	statusPulse value: super overallStatus valueOrNil
]

{ #category : 'private - children' }
CFMaMemento >> restoreTransferredChildMementos [
	childMementoTransfers reverseDo: [ :aTransfer |
		| anObject sourceDescription destinationDescription childMemento currentChild |
		anObject := aTransfer first.
		sourceDescription := aTransfer second.
		destinationDescription := aTransfer third.
		childMemento := aTransfer fourth.
		currentChild := self
			removeChildMementoFor: anObject
			inRelation: destinationDescription.
		(currentChild notNil and: [ currentChild ~~ childMemento ]) ifTrue: [
			self
				putChildMemento: currentChild
				for: anObject
				inRelation: destinationDescription ].
		self
			putChildMemento: childMemento
			for: anObject
			inRelation: sourceDescription ].
	childMementoTransfers removeAll.
	statusPulse value: super overallStatus valueOrNil
]

{ #category : 'actions' }
CFMaMemento >> commit [
	"Publish surviving transferred children's explicit owner links before any former
	owner writes its collections. This avoids traversal-order dependence, including
	nesting reversals. GT commit invokes self reset, so clear rollback journals first."
	self childMementoReparentings do: [ :entry |
		(self includesActiveMemento: entry sixth) ifTrue: [
			entry sixth
				pushDescription: entry seventh
				currentValue: (entry sixth readObservableValueUsing: entry seventh) valueOrNil ] ].
	self allChildMementos do: [ :each | each commit ].
	self childMementoReparentings removeAll.
	childMementoTransfers removeAll.
	detachedChildMementos removeAll.
	^ super commit
]

{ #category : 'private - status' }
CFMaMemento >> computeCompositeOverallStatus [
	| aParentStatus theChildStatuses |
	aParentStatus := super computeOverallStatus.
	theChildStatuses := self allChildMementos
		collect: [ :aMemento | aMemento computeCompositeOverallStatus ].

	^ GtMagritteOverallStatus new
		isValid: (aParentStatus isValid
			and: [ theChildStatuses allSatisfy: #isValid ]);
		isChanged: (aParentStatus isChanged
			or: [ theChildStatuses anySatisfy: #isChanged ]);
		executionStatus: aParentStatus executionStatus;
		yourself
]


{ #category : 'testing' }
CFMaMemento >> hasChangesToCommit [
	| hasParentChanges |
	hasParentChanges := self cache associations anySatisfy: [ :anAssociation |
		| aDescription aValue |
		aDescription := anAssociation key.
		aValue := anAssociation value valueOrNil.
		aDescription isVisible
			and: [ aDescription isReadOnly not
				and: [ aValue notNil and: [ aValue isChanged ] ] ] ].

	^ hasParentChanges
		or: [ self allChildMementos anySatisfy: [ :aMemento | aMemento hasChangesToCommit ] ]
]

{ #category : 'initialization' }
CFMaMemento >> initialize [
	super initialize.

	childMementosByDescription := Dictionary new.
	childMementoTransfers := OrderedCollection new.
	detachedChildMementos := OrderedCollection new.
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

{ #category : 'private - children' }
CFMaMemento >> reconcileChildMementosWithCurrentRelations [
	childMementosByDescription keys copy do: [ :aDescription |
		| aValue currentObjects |
		aValue := self readUsing: aDescription.
		currentObjects := aDescription isMultiple
			ifTrue: [ aValue ifNil: [ #() ] ]
			ifFalse: [ aValue ifNil: [ #() ] ifNotNil: [ { aValue } ] ].
		self
			retainChildMementosFor: currentObjects
			inRelation: aDescription ]
]

{ #category : 'actions' }
CFMaMemento >> reset [
	| result |
	self restoreReparentedChildMementos.
	self restoreDetachedChildMementos.
	self restoreTransferredChildMementos.
	self allChildMementos do: [ :aMemento | aMemento reset ].
	result := super reset.
	self reconcileChildMementosWithCurrentRelations.
	^ result
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

{ #category : 'private - children' }
CFMaMemento >> childMementoReparentings [
	^ childMementoReparentings ifNil: [ childMementoReparentings := OrderedCollection new ]
]

{ #category : 'testing' }
CFMaMemento >> includesActiveMemento: aMemento [
	^ self == aMemento or: [ self allChildMementos anySatisfy: [ :each | each includesActiveMemento: aMemento ] ]
]

{ #category : 'private - status' }
CFMaMemento >> pulseChildStatus [
	statusPulse value: super overallStatus valueOrNil
]

{ #category : 'private - children' }
CFMaMemento >> removeOwnedChildMemento: aChildMemento for: anObject inRelation: aDescription [
	"A transferred child may subsequently have been removed or replaced."
	| relationMementos |
	relationMementos := childMementosByDescription at: aDescription ifAbsent: [ IdentityDictionary new ].
	(relationMementos at: anObject ifAbsent: [ nil ]) == aChildMemento ifTrue: [
		self removeChildMementoFor: anObject inRelation: aDescription ].
	detachedChildMementos removeAllSuchThat: [ :each |
		each first == anObject and: [ each second == aDescription and: [ each third == aChildMemento ] ] ]
]

{ #category : 'private - children' }
CFMaMemento >> restoreReparentedChildMementos [
	self childMementoReparentings reverseDo: [ :entry |
		entry fourth removeOwnedChildMemento: entry sixth for: entry first inRelation: entry fifth.
		entry second putChildMemento: entry sixth for: entry first inRelation: entry third.
		entry second pulseChildStatus.
		entry fourth pulseChildStatus ].
	self childMementoReparentings removeAll
]

{ #category : 'children' }
CFMaMemento >> reparentChildMementoFor: anObject from: aSourceMemento inRelation: aSourceDescription to: aDestinationMemento inRelation: aDestinationDescription ownerDescription: anOwnerDescription [
	"The common transaction owner journals lifecycle ownership before relation writes.
	Preserve the child itself, including caches, descendants and pending removals."
	| child |
	self assert: (self includesActiveMemento: aSourceMemento).
	self assert: (self includesActiveMemento: aDestinationMemento).
	self assert: aSourceMemento ~~ aDestinationMemento.
	self assert: (aDestinationMemento hasChildMementoFor: anObject inRelation: aDestinationDescription) not.
	child := aSourceMemento childMementoFor: anObject inRelation: aSourceDescription.
	self assert: (child includesActiveMemento: aDestinationMemento) not.
	self assert: anOwnerDescription isReadOnly not.
	self assert: anOwnerDescription isVisible.
	anOwnerDescription validate: aDestinationMemento model.
	aSourceMemento removeChildMementoFor: anObject inRelation: aSourceDescription.
	aDestinationMemento putChildMemento: child for: anObject inRelation: aDestinationDescription.
	"Route transferred changes to the common root. Observing the new parent
	would create a reactive cycle when reversing former ancestor relationships."
	child overallStatus observe: statusPulse.
	self childMementoReparentings add: { anObject. aSourceMemento. aSourceDescription. aDestinationMemento. aDestinationDescription. child. anOwnerDescription }.
	child write: aDestinationMemento model using: anOwnerDescription.
	aSourceMemento pulseChildStatus.
	aDestinationMemento pulseChildStatus.
	^ child
]
