Class {
	#name : 'CFMaBuilderUtility',
	#superclass : 'GtMagritteBuilderUtility',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'elements' }
CFMaBuilderUtility class >> newFieldLabelUsing: aDescription [
	| aText labelAptitude |
	aText := aDescription label asRopedText.

	labelAptitude := aDescription labelAptitude
			ifNil: [ BrGlamorousLabelAptitude new
				foreground: (Color black alpha: 0.28) ]
			ifNotNil: #value.

	^ BrLabel new
		id: (GtMagritteFieldLabelId new description: aDescription);
		text: aText;
		aptitude: labelAptitude;
		hMatchParent;
		fitContent;
		margin: (BlInsets top: 0 right: 0 bottom: 4 left: 12);
		when: BlClickEvent
			do: [ :anEvent |
				anEvent modifiers isAlt
					ifTrue: [ anEvent consumed: true.
						anEvent target phlow spawnObject: aDescription ] ]
]

{ #category : 'elements' }
CFMaBuilderUtility class >> newFieldLabelWithSpace: aSpaceNumber using: aDescription [
	^ self newFieldLabelUsing: aDescription
]

{ #category : 'elements' }
CFMaBuilderUtility class >> newFormContainerFor: aMemento [
	^ BrVerticalPane new
		in: [ :aPane |
			aPane magritte
				beFieldContainer;
				beToolbarContainer ];
		hMatchParent;
		vFitContent;
		padding: (BlInsets all: 12);
		cellSpacing: 8;
		background: (Color black alpha: 0.08);
		yourself
]

{ #category : 'elements' }
CFMaBuilderUtility class >> newGroupLabelUsing: aGroupName [
	^ BrLabel new
		aptitude: (BrGlamorousLabelAptitude new foreground: (Color black alpha: 0.28));
		text: aGroupName asString asUppercase;
		hMatchParent;
		fitContent;
		margin: (BlInsets top: 2 right: 0 bottom: 6 left: 0);
		yourself
]

{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> relationItemViewModelsForModels: aCollection existingViewModels: anExistingViewModels memento: aMemento description: aDescription [
	^ Array streamContents: [ :aStream |
		aCollection do: [ :aModel |
			anExistingViewModels
				detect: [ :eachViewModel | eachViewModel isForObject: aModel ]
				ifFound: [ :aViewModel |
					aStream nextPut: aViewModel ]
				ifNone: [
					| aViewModel |
					aViewModel := aDescription blocItemViewModelStencil
						model: aModel;
						description: aDescription;
						memento: aMemento;
						build.
					aStream nextPut: aViewModel ] ] ]
]

{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> relationModels: aCollection matchViewModels: aViewModelCollection [
	| theModels |
	theModels := aCollection asArray.
	theModels size = aViewModelCollection size ifFalse: [ ^ false ].

	1 to: theModels size do: [ :anIndex |
		((aViewModelCollection at: anIndex) object == (theModels at: anIndex))
			ifFalse: [ ^ false ] ].
	^ true
]

{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> toManyItems: anExistingItems adding: anObject [
	| theItems |
	theItems := OrderedCollection new.
	anExistingItems ifNotNil: [ theItems addAll: anExistingItems ].
	theItems add: anObject.
	^ anExistingItems
		ifNil: [ theItems asArray ]
		ifNotNil: [ anExistingItems species withAll: theItems ]
]

{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> addToManyObject: anObject memento: aMemento using: aDescription element: anElement [
	| anExistingItems aNewItems |
	anObject ifNil: [ ^ self ].
	anExistingItems := aMemento readUsing: aDescription.
	aNewItems := self toManyItems: anExistingItems adding: anObject.
	self
		writeToManyItems: aNewItems
		ifChangedFrom: (anExistingItems ifNil: [ #() ])
		memento: aMemento
		using: aDescription
		element: anElement
]

{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> addToOneObject: anObject memento: aMemento using: aDescription element: anElement [
	| aCurrentValue |
	anObject ifNil: [ ^ self ].
	aCurrentValue := aMemento readUsing: aDescription.
	aCurrentValue ifNotNil: [ ^ self ].
	[ aDescription validate: anObject ]
		on: Error
		do: [ :anException | ^ self ].
	GtMagritteBuilderUtility
		write: anObject
		using: aDescription
		memento: aMemento
		element: anElement
]

{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> removeSelectedToManyItemFrom: aListElement memento: aMemento description: aDescription element: anElement [
	aListElement selectedItemDo: [ :anItemViewModel :anIndex |
		self
			removeToManyObject: (self relationObjectForItem: anItemViewModel)
			memento: aMemento
			using: aDescription
			element: anElement ]
]


{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> toManyItems: firstCollection identityMatches: secondCollection [
	firstCollection size = secondCollection size ifFalse: [ ^ false ].
	1 to: firstCollection size do: [ :anIndex |
		((firstCollection at: anIndex) == (secondCollection at: anIndex))
			ifFalse: [ ^ false ] ].
	^ true
]

{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> writeToManyItems: aNewItems ifChangedFrom: anExistingItems memento: aMemento using: aDescription element: anElement [
	(self toManyItems: anExistingItems identityMatches: aNewItems) ifTrue: [ ^ self ].
	[ aDescription validate: aNewItems ]
		on: Error
		do: [ :anException | ^ self ].
	GtMagritteBuilderUtility
		write: aNewItems
		using: aDescription
		memento: aMemento
		element: anElement
]

{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> reorderedToManyItems: anExistingItems moving: someObjects relativeTo: aTargetObject after: placeAfter [
	| draggedItems remainingItems targetIndex insertionIndex reorderedItems |
	draggedItems := anExistingItems select: [ :each |
		someObjects anySatisfy: [ :aDraggedObject | aDraggedObject == each ] ].
	draggedItems ifEmpty: [ ^ anExistingItems ].
	(draggedItems anySatisfy: [ :each | each == aTargetObject ]) ifTrue: [ ^ anExistingItems ].

	remainingItems := anExistingItems reject: [ :each |
		draggedItems anySatisfy: [ :aDraggedObject | aDraggedObject == each ] ].
	targetIndex := remainingItems identityIndexOf: aTargetObject ifAbsent: [ ^ anExistingItems ].
	insertionIndex := placeAfter
		ifTrue: [ targetIndex + 1 ]
		ifFalse: [ targetIndex ].

	reorderedItems := OrderedCollection new.
	remainingItems withIndexDo: [ :each :anIndex |
		anIndex = insertionIndex ifTrue: [ reorderedItems addAll: draggedItems ].
		reorderedItems add: each ].
	insertionIndex = (remainingItems size + 1) ifTrue: [ reorderedItems addAll: draggedItems ].
	^ anExistingItems species withAll: reorderedItems
]

{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> reorderToManyObjects: someObjects relativeTo: aTargetObject after: placeAfter memento: aMemento using: aDescription element: anElement [
	| anExistingItems aNewItems |
	anExistingItems := aMemento readUsing: aDescription.
	anExistingItems ifNil: [ ^ self ].
	aNewItems := self
		reorderedToManyItems: anExistingItems
		moving: someObjects
		relativeTo: aTargetObject
		after: placeAfter.
	self
		writeToManyItems: aNewItems
		ifChangedFrom: anExistingItems
		memento: aMemento
		using: aDescription
		element: anElement
]

{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> removeToManyObject: anObject memento: aMemento using: aDescription element: anElement [
	^ self
		removeToManyObjects: { anObject }
		memento: aMemento
		using: aDescription
		element: anElement
]

{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> removeToManyObjects: someObjects memento: aMemento using: aDescription element: anElement [
	| anExistingItems aNewItems |
	anExistingItems := aMemento readUsing: aDescription.
	anExistingItems ifNil: [ ^ self ].
	aNewItems := anExistingItems species withAll: (anExistingItems reject: [ :each |
		someObjects anySatisfy: [ :anObject | anObject == each ] ]).
	self
		writeToManyItems: aNewItems
		ifChangedFrom: anExistingItems
		memento: aMemento
		using: aDescription
		element: anElement
]

{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> removeToOneMemento: aMemento using: aDescription element: anElement [
	| aCurrentValue |
	aCurrentValue := aMemento readUsing: aDescription.
	(self canRemoveToOneUsing: aDescription currentValue: aCurrentValue)
		ifFalse: [ ^ self ].

	CFMaPhlowNavigation
		closeSpawnedInspectorFrom: anElement
		object: aCurrentValue.

	GtMagritteBuilderUtility
		write: nil
		using: aDescription
		memento: aMemento
		element: anElement
]

