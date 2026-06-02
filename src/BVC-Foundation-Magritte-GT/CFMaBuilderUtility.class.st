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
		background: (Color black alpha: 0.05);
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

{ #category : 'api - ui' }
CFMaBuilderUtility class >> newFlowListMemento: aMemento using: aDescription [
	| aFlowElement |
	aFlowElement := BrFlowList new.
	aFlowElement
		matchParent;
		stencil: aDescription blocItemStencil;
		withAsyncSinkDo: [ :anElementSink |
			anElementSink
				sink: AsyncPeekSink new;
				whenUpdate: [ :theFlowElement :aSink |
					self
						onFlowList: theFlowElement
						sinkUpdate: aSink
						memento: aMemento
						description: aDescription ].
			(aMemento readObservableValueUsing: aDescription)
				observe: anElementSink ].

	^ aFlowElement
]


{ #category : 'api - ui' }
CFMaBuilderUtility class >> newSimpleListMemento: aMemento using: aDescription [
	| aListElement aContainer |
	aListElement := BrSimpleList new.
	aListElement
		hMatchParent;
		vFitContent;
		itemStencil: [ CFCompactListItemElement new ];
		itemDataBinder: [ :anItemElement :anItemViewModel :anItemIndex |
			anItemElement
				model: anItemViewModel object;
				description: anItemViewModel itemDescription;
				yourself ];
		constraintsDo: [ :c | c minHeight: 200 ];
		when: BrSelectionDoubleClicked
		do: [ :anEvent |
			anEvent selection ifNotEmpty: [ :theIndices |
				| aList selectedViewModel |
				aList := anEvent currentTarget.
				selectedViewModel := aList viewModel itemAt: theIndices first.
				aList phlow spawnObject: selectedViewModel object ] ];
		addShortcut: (BlShortcutWithAction new
			name: 'Remove selected item';
			description: 'Remove the selected item from the list.';
			combination: BlKeyCombination delete;
			action: [ :anEvent |
				self
					removeSelectedItemsFromSimpleList: aListElement
					memento: aMemento
					description: aDescription
					event: anEvent ]);
		withAsyncSinkDo: [ :anElementSink |
			anElementSink
				sink: AsyncPeekSink new;
				whenUpdate: [ :theListElement :aSink |
					self
						onSimpleList: theListElement
						sinkUpdate: aSink
						memento: aMemento
						description: aDescription ].
			(aMemento readObservableValueUsing: aDescription)
				observe: anElementSink ].

	aContainer := BrVerticalPane new
		hMatchParent;
		vFitContent;
		cellSpacing: 6;
		addChild: aListElement;
		yourself.

	aDescription isDefinitive not
		ifTrue: [ aContainer addChild: (CFMaAddItemViewModel new
			memento: aMemento;
			description: aDescription;
			yourself) asElement ].

	^ aContainer
]

{ #category : 'private - support' }
CFMaBuilderUtility class >> removeSelectedItemsFromSimpleList: aListElement memento: aMemento description: aDescription event: anEvent [
	| selectedIndices selectedIndexSet existingItems newItems |
	selectedIndices := aListElement selectedIndices.
	selectedIndices ifEmpty: [ ^ self ].

	selectedIndexSet := selectedIndices asSet.
	existingItems := aMemento readUsing: aDescription.
	newItems := OrderedCollection new.

	existingItems withIndexDo: [ :eachItem :eachIndex |
		(selectedIndexSet includes: eachIndex)
			ifFalse: [ newItems add: eachItem ] ].

	GtMagritteBuilderUtility
		write: newItems
		using: aDescription
		memento: aMemento
		element: aListElement.

	anEvent consumed: true
]

{ #category : 'private - support' }
CFMaBuilderUtility class >> onSimpleList: aListElement sinkUpdate: aSink memento: aMemento description: aDescription [
	| aModels anExistingViewModels aViewModels |
	aModels := aSink value currentValue ifNil: [ #() ].
	anExistingViewModels := aListElement items.

	aViewModels := Array
		new: aModels size
		streamContents: [ :aStream |
			self
				recycleViewModels: anExistingViewModels
				forModels: aModels
				into: aStream
				memento: aMemento
				description: aDescription ].

	^ aListElement items: aViewModels
]

{ #category : 'private - support' }
CFMaBuilderUtility class >> onFlowList: aFlowElement sinkUpdate: aSink memento: aMemento description: aDescription [
	| aModels anExistingViewModels aViewModels |
	aModels := aSink value currentValue ifNil: [ #() ].
	anExistingViewModels := aFlowElement items.

	aViewModels := Array
		new: (aModels size + aDescription isDefinitive not asBit)
		streamContents: [ :aStream |
			self
				recycleViewModels: anExistingViewModels
				forModels: aModels
				into: aStream
				memento: aMemento
				description: aDescription.

			aDescription isDefinitive not
				ifTrue: [ | anAddViewModel |
					anAddViewModel := CFMaAddItemViewModel new
						memento: aMemento;
						description: aDescription;
						yourself.
					aDescription newItemStencil
						ifNotNil: [ :aStencil | anAddViewModel stencil: aStencil ].
					aStream nextPut: anAddViewModel ] ].

	^ aFlowElement items: aViewModels
]
