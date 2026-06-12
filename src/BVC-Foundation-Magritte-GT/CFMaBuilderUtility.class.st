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
	| aContainer aList canModify canAdd anActionContainer anAddElement aRemoveButton |
	canModify := aDescription definitive not.
	canAdd := canModify and: [ aDescription newItemStencil isNotNil ].

	aContainer := self newRelationEditorContainer.

	aList := self newRelationListUsing: aDescription.
	aList constraintsDo: [ :c | c padding: (BlInsets top: 10 bottom: 10) ].

	self installRelationEditorFocusOn: aContainer primaryFocusElement: aList.

	aContainer addChild: aList.

	canModify ifTrue: [
		anActionContainer := BrHorizontalPane new
			fitContent;
			cellSpacing: 8;
			yourself.

		canAdd ifTrue: [
			anAddElement := CFMaAddItemViewModel new
				memento: aMemento;
				description: aDescription;
				stencil: aDescription newItemStencil;
				asElement.
			anActionContainer addChild: anAddElement ].

		aRemoveButton := self
			newToManyRemoveButtonMemento: aMemento
			using: aDescription
			list: aList.
		anActionContainer addChild: aRemoveButton.

		aContainer addChild: anActionContainer.

		aList
			when: BrSelectionChanged
			do: [ :anEvent |
				self updateToManyRemoveButton: aRemoveButton list: aList ] ].

	self
		installRelationEditorShortcutsOn: aContainer
		primaryFocusElement: aList
		addElement: anAddElement
		memento: aMemento
		description: aDescription
		removeAction: [ :anElement |
			self
				removeSelectedToManyItemFrom: aList
				memento: aMemento
				description: aDescription
				element: anElement ].

	aContainer withAsyncSinkDo: [ :anElementSink |
		anElementSink
			sink: AsyncPeekSink new;
			whenUpdate: [ :theContainer :aSink |
				self
					onFlowList: aList
					sinkUpdate: aSink
					memento: aMemento
					description: aDescription.
				aRemoveButton ifNotNil: [
					self updateToManyRemoveButton: aRemoveButton list: aList ] ].
		(aMemento readObservableValueUsing: aDescription)
			observe: anElementSink ].

	^ aContainer
]




{ #category : 'private - support' }
CFMaBuilderUtility class >> onFlowList: aListElement sinkUpdate: aSink memento: aMemento description: aDescription [
	| aModels |
	aModels := aSink value currentValue ifNil: [ #() ].
	^ aListElement items: (self
		relationItemViewModelsForModels: aModels
		existingViewModels: aListElement viewModel items
		memento: aMemento
		description: aDescription)
]


{ #category : 'api - ui' }
CFMaBuilderUtility class >> newToOneListMemento: aMemento using: aDescription [
	| aContainer aList anActionContainer isModifiable canAdd anAddElement aRemoveButton |
	isModifiable := true.
	canAdd := aDescription newItemStencil isNotNil.

	aContainer := self newRelationEditorContainer.

	aList := self newRelationListUsing: aDescription.
	aList constraintsDo: [ :c | c padding: (BlInsets top: 10 bottom: 10) ].

	self installRelationEditorFocusOn: aContainer primaryFocusElement: aList.

	aContainer addChild: aList.

	(isModifiable or: [ canAdd ]) ifTrue: [
		anActionContainer := BrHorizontalPane new
			fitContent;
			cellSpacing: 8;
			yourself.

		canAdd ifTrue: [
			anAddElement := CFMaToOneAddItemViewModel new
				memento: aMemento;
				description: aDescription;
				stencil: aDescription newItemStencil;
				asElement.
			anActionContainer addChild: anAddElement ].

		isModifiable ifTrue: [
			aRemoveButton := self newToOneRemoveButtonMemento: aMemento using: aDescription.
			anActionContainer addChild: aRemoveButton ].

		aContainer addChild: anActionContainer ].

	self
		installRelationEditorShortcutsOn: aContainer
		primaryFocusElement: aList
		addElement: anAddElement
		memento: aMemento
		description: aDescription
		removeAction: [ :anElement |
			GtMagritteBuilderUtility
				write: nil
				using: aDescription
				memento: aMemento
				element: anElement ].

	aContainer withAsyncSinkDo: [ :anElementSink |
		anElementSink
			sink: AsyncPeekSink new;
			whenUpdate: [ :theContainer :aSink |
				self
					onToOneList: aList
					sinkUpdate: aSink
					memento: aMemento
					description: aDescription.
				isModifiable ifTrue: [
					self
						updateToOneRemoveButton: aRemoveButton
						sinkUpdate: aSink ] ].
		(aMemento readObservableValueUsing: aDescription)
			observe: anElementSink ].

	^ aContainer
]

{ #category : 'api - ui' }
CFMaBuilderUtility class >> newEmbeddedToOneMemento: aMemento using: aDescription [
	| aContainer aFrame anActionContainer isModifiable canAdd anAddElement aRemoveButton |
	isModifiable := true.
	canAdd := aDescription newItemStencil isNotNil.

	aContainer := self newRelationEditorContainer.

	aFrame := BrFrame new
		hMatchParent;
		vFitContent;
		yourself.
	aContainer addChild: aFrame.

	(isModifiable or: [ canAdd ]) ifTrue: [
		anActionContainer := BrHorizontalPane new
			fitContent;
			cellSpacing: 8;
			yourself.

		canAdd ifTrue: [
			anAddElement := CFMaToOneAddItemViewModel new
				memento: aMemento;
				description: aDescription;
				stencil: aDescription newItemStencil;
				asElement.
			anActionContainer addChild: anAddElement ].

		isModifiable ifTrue: [
			aRemoveButton := self newToOneRemoveButtonMemento: aMemento using: aDescription.
			anActionContainer addChild: aRemoveButton ].

		aContainer addChild: anActionContainer ].

	self installRelationEditorFocusOn: aContainer primaryFocusElement: aFrame.

	self
		installRelationEditorShortcutsOn: aContainer
		primaryFocusElement: aFrame
		addElement: anAddElement
		memento: aMemento
		description: aDescription
		removeAction: [ :anElement |
			GtMagritteBuilderUtility
				write: nil
				using: aDescription
				memento: aMemento
				element: anElement ].

	aContainer withAsyncSinkDo: [ :anElementSink |
		anElementSink
			sink: AsyncPeekSink new;
			whenUpdate: [ :theContainer :aSink |
				self
					onEmbeddedToOneFrame: aFrame
					sinkUpdate: aSink
					memento: aMemento
					description: aDescription.
				isModifiable ifTrue: [
					self
						updateToOneRemoveButton: aRemoveButton
						sinkUpdate: aSink ] ].
		(aMemento readObservableValueUsing: aDescription)
			observe: anElementSink ].

	^ aContainer
]

{ #category : 'private - support' }
CFMaBuilderUtility class >> onToOneList: aListElement sinkUpdate: aSink memento: aMemento description: aDescription [
	| anObject aModels |
	anObject := aSink value currentValue.
	aModels := anObject ifNil: [ #() ] ifNotNil: [ { anObject } ].
	^ aListElement items: (self
		relationItemViewModelsForModels: aModels
		existingViewModels: aListElement viewModel items
		memento: aMemento
		description: aDescription)
]

{ #category : 'private - support' }
CFMaBuilderUtility class >> onEmbeddedToOneFrame: aFrame sinkUpdate: aSink memento: aMemento description: aDescription [
	| anObject anItemViewModel anElement |
	anObject := aSink value currentValue.
	aFrame removeChildren.
	anObject ifNil: [ ^ self ].

	anItemViewModel := aDescription blocItemViewModelStencil
		model: anObject;
		description: aDescription;
		memento: aMemento;
		build.
	anElement := aDescription blocItemStencil
		listElement: aFrame;
		rowValue: anItemViewModel;
		rowIndex: 1;
		build.
	aFrame addChild: anElement
]

{ #category : 'private - instance creation' }
CFMaBuilderUtility class >> newToManyRemoveButtonMemento: aMemento using: aDescription list: aListElement [
	^ BrButton new
		aptitude: BrGlamorousButtonWithIconCircularAptitude;
		icon: BrGlamorousVectorIcons remove;
		label: 'Remove';
		action: [ :anElement |
			self
				removeSelectedToManyItemFrom: aListElement
				memento: aMemento
				description: aDescription
				element: anElement ];
		disable;
		constraintsDo: [ :c | c flow vertical alignCenter ];
		yourself
]

{ #category : 'private - support' }
CFMaBuilderUtility class >> updateToManyRemoveButton: aButton list: aListElement [
	| hasSelection |
	hasSelection := false.
	aListElement selectedIndices do: [ :anIndex |
		(anIndex between: 1 and: aListElement maxSelectionIndex)
			ifTrue: [ hasSelection := true ] ].
	hasSelection
		ifTrue: [ aButton enable ]
		ifFalse: [ aButton disable ]
]

{ #category : 'private - instance creation' }
CFMaBuilderUtility class >> newToOneRemoveButtonMemento: aMemento using: aDescription [
	^ BrButton new
		aptitude: BrGlamorousButtonWithIconCircularAptitude;
		icon: BrGlamorousVectorIcons remove;
		label: 'Remove';
		action: [ :anElement |
			GtMagritteBuilderUtility
				write: nil
				using: aDescription
				memento: aMemento
				element: anElement ];
		disable;
		constraintsDo: [ :c | c flow vertical alignCenter ];
		yourself
]

{ #category : 'private - support' }
CFMaBuilderUtility class >> updateToOneRemoveButton: aButton sinkUpdate: aSink [
	| anObject |
	anObject := aSink value currentValue.
	anObject
		ifNil: [ aButton disable ]
		ifNotNil: [ aButton enable ]
]

{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> newRelationEditorContainer [
	| aContainer |
	aContainer := BrVerticalPane new
		matchParent;
		vFitContent;
		cellSpacing: 8;
		padding: (BlInsets all: 4);
		border: (BlBorder paint: BrGlamorousColors disabledButtonBorderColor width: 1);
		background: Color white;
		yourself.

	aContainer
		when: BlFocusInEvent
		do: [ :anEvent |
			aContainer border: (BlBorder paint: BrGlamorousColors focusedEditorBorderColor width: 1) ];
		when: BlFocusOutEvent
		do: [ :anEvent |
			aContainer border: (BlBorder paint: BrGlamorousColors disabledButtonBorderColor width: 1) ].

	^ aContainer
]


{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> newAutoSizingRelationEditorContainer [
	^ self newRelationEditorContainer
		hMatchParent;
		vFitContentLimited;
		yourself
]

{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> newExpandingRelationEditorContainer [
	^ self newRelationEditorContainer
		matchParent;
		yourself
]

{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> installRelationEditorFocusOn: aContainer primaryFocusElement: anElement [
	aContainer
		when: BlClickEvent
		do: [ :anEvent |
			anElement requestFocus ].
	^ aContainer
]

{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> installRelationEditorShortcutsOn: aContainer primaryFocusElement: aList addElement: anAddElement memento: aMemento description: aDescription removeAction: aRemoveAction [
	aContainer
		addShortcut: (BlShortcutWithAction new
			name: 'Add relation item';
			combination: BlKeyCombination primaryN;
			overrideChildren: true;
			action: [ :anEvent :aShortcut |
				anEvent consumed: true.
				self activateRelationAddElement: anAddElement ]);
		addShortcut: (BlShortcutWithAction new
			name: 'Remove selected relation item';
			combination: BlKeyCombination delete;
			overrideChildren: true;
			action: [ :anEvent :aShortcut |
				anEvent consumed: true.
				aRemoveAction value: aContainer ]);
		addShortcut: (BlShortcutWithAction new
			name: 'Remove selected relation item';
			combination: BlKeyCombination builder backspace build;
			overrideChildren: true;
			action: [ :anEvent :aShortcut |
				anEvent consumed: true.
				aRemoveAction value: aContainer ]).
	^ aContainer
]

{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> activateRelationAddElement: anAddElement [
	anAddElement ifNil: [ ^ self ].
	anAddElement requestFocus.
	BlSpace simulateClickOn: anAddElement
]

{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> removeSelectedToManyItemFrom: aListElement memento: aMemento description: aDescription element: anElement [
	aListElement selectedItemDo: [ :anItemViewModel :anIndex |
		| anObject anExistingItems aNewItems |
		anObject := self relationObjectForItem: anItemViewModel.
		anExistingItems := aMemento readUsing: aDescription.
		anExistingItems ifNil: [ ^ self ].
		aNewItems := anExistingItems copyWithout: anObject.
		anExistingItems = aNewItems ifTrue: [ ^ self ].
		GtMagritteBuilderUtility
			write: aNewItems
			using: aDescription
			memento: aMemento
			element: anElement ]
]


{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> newRelationListUsing: aDescription [
	| aList |
	aList := BrSimpleList new.
	aList
		matchParent;
		itemType: [ :anItemTypeFactory :anItemObject :anItemIndex |
			anItemTypeFactory default ];
		itemStencil: self newRelationListItemStencil;
		itemDataBinder: (self newRelationListItemDataBinderUsing: aDescription);
		selectionCallback: [ :theIndices |
			self relationSelectionFrom: aList indices: theIndices ];
		addEventHandler: (GtPhlowListToSelectHandler new
			transformation: GtPhlowSendTransformation default).

	aList addAptitude: CFMaFocusWithinAptitude.
	^ aList
]

{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> newRelationListItemStencil [
	^ CFMaListItemElementStencilBuilder new
		stencilBuilder: (GtPhlowSimpleListErrorHandlingItemElementStencilBuilder new
			stencilBuilder: ([ :anItemType |
				BlElement new
					layout: BlFrameLayout new;
					constraintsDo: [ :c |
						c horizontal matchParent.
						c vertical fitContent ];
					yourself ] asStencilBuilder: BrListItemElementStencilBuilder);
			cellSpacing: (BlInsets left: 10);
			yourself);
		yourself
]

{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> newRelationListItemDataBinderUsing: aDescription [
	^ [ :anItemElement :anItemViewModel :anItemIndex |
		| anItemStencil anItemContent |
		anItemElement removeChildren.
		anItemStencil := aDescription blocItemStencil.
		anItemContent := anItemStencil
			listElement: anItemElement;
			rowValue: anItemViewModel;
			rowIndex: anItemIndex;
			build.
		anItemElement addChild: anItemContent.
		anItemElement ]
]


{ #category : 'api - ui' }
CFMaBuilderUtility class >> newColumnedRelationListMemento: aMemento using: aDescription [
	| aContainer aList canModify canAdd anActionContainer anAddElement aRemoveButton |
	canModify := aDescription definitive not.
	canAdd := canModify and: [ aDescription newItemStencil isNotNil ].

	aContainer := self newAutoSizingRelationEditorContainer.

	aList := self newColumnedRelationListElementMemento: aMemento using: aDescription.
	aList
		hMatchParent;
		vFitContentLimited.
	aList constraintsDo: [ :c |
		c padding: (BlInsets top: 10 bottom: 10).
		c maxHeight: 200 ].

	self installRelationEditorFocusOn: aContainer primaryFocusElement: aList.

	aContainer addChild: aList.

	canModify ifTrue: [
		anActionContainer := BrHorizontalPane new
			fitContent;
			cellSpacing: 8;
			yourself.

		canAdd ifTrue: [
			anAddElement := CFMaAddItemViewModel new
				memento: aMemento;
				description: aDescription;
				stencil: aDescription newItemStencil;
				asElement.
			anActionContainer addChild: anAddElement ].

		aRemoveButton := self
			newToManyRemoveButtonMemento: aMemento
			using: aDescription
			list: aList.
		anActionContainer addChild: aRemoveButton.

		aContainer addChild: anActionContainer.

		aList
			when: BrSelectionChanged
			do: [ :anEvent |
				self updateToManyRemoveButton: aRemoveButton list: aList ] ].

	self
		installRelationEditorShortcutsOn: aContainer
		primaryFocusElement: aList
		addElement: anAddElement
		memento: aMemento
		description: aDescription
		removeAction: [ :anElement |
			self
				removeSelectedToManyItemFrom: aList
				memento: aMemento
				description: aDescription
				element: anElement ].

	aContainer withAsyncSinkDo: [ :anElementSink |
		anElementSink
			sink: AsyncPeekSink new;
			whenUpdate: [ :theContainer :aSink |
				self
					onFlowList: aList
					sinkUpdate: aSink
					memento: aMemento
					description: aDescription.
				aRemoveButton ifNotNil: [
					self updateToManyRemoveButton: aRemoveButton list: aList ] ].
		(aMemento readObservableValueUsing: aDescription)
			observe: anElementSink ].

	^ aContainer
]

{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> newColumnedRelationListElementMemento: aMemento using: aDescription [
	| aList |
	aList := BrColumnedList new.
	aList
		matchParent;
		rowStencil: CFMaColumnedListItemElementStencilBuilder new;
		rowDataBinder: [ :anItemElement :anItemViewModel :anItemIndex | anItemElement ];
		selectionCallback: [ :theIndices |
			self relationSelectionFrom: aList indices: theIndices ];
		addAptitude: CFMaFocusWithinAptitude;
		addEventHandler: (GtPhlowListToSelectHandler new
			transformation: GtPhlowSendTransformation default).

	self addReferenceColumnsTo: aList memento: aMemento using: aDescription.
	^ aList
]

{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> addReferenceColumnsTo: aColumnedList memento: aMemento using: aDescription [
	| theReferenceDescriptions anExpandingColumnIndex |
	theReferenceDescriptions := self referenceDescriptionsFor: aDescription.
	anExpandingColumnIndex := self expandingReferenceColumnIndexIn: theReferenceDescriptions.

	theReferenceDescriptions withIndexDo: [ :eachReferenceDescription :eachIndex |
		| aColumn isExpanding |
		isExpanding := eachIndex = anExpandingColumnIndex.
		aColumn := aColumnedList column
			title: eachReferenceDescription label;
			cellStencil: [ self newReferenceColumnCellElementExpanding: isExpanding ];
			dataBinder: [ :aCellElement :anItemViewModel :anItemIndex :aRowHolder :aColumnIndex |
				| aCellChild |
				aCellChild := self
					newReadOnlyColumnCellFor: (self relationObjectForItem: anItemViewModel)
					using: eachReferenceDescription.
				aCellElement
					removeChildren;
					addChild: aCellChild ].

		self
			configureReferenceColumn: aColumn
			description: eachReferenceDescription
			index: eachIndex
			expandingIndex: anExpandingColumnIndex ]
]

{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> referenceDescriptionsFor: aDescription [
	^ Array streamContents: [ :aStream |
		aDescription reference do: [ :eachReferenceDescription |
			aStream nextPut: eachReferenceDescription ] ]
]

{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> expandingReferenceColumnIndexIn: aCollectionOfReferenceDescriptions [
	aCollectionOfReferenceDescriptions withIndexDo: [ :eachReferenceDescription :eachIndex |
		(self isIconReferenceDescription: eachReferenceDescription)
			ifFalse: [ ^ eachIndex ] ].
	^ nil
]

{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> isIconReferenceDescription: aDescription [
	^ aDescription isKindOf: GtMagritteIconDescription
]

{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> configureReferenceColumn: aColumn description: aDescription index: anIndex expandingIndex: anExpandingIndex [
	(self isIconReferenceDescription: aDescription)
		ifTrue: [ ^ self ].

	anIndex = anExpandingIndex
		ifTrue: [ aColumn weight: 1 ]
]

{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> referenceIconHeight [
	^ 24
]

{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> newReferenceColumnCellElementExpanding: aBoolean [
	^ BlElement new
		layout: BlFrameLayout new;
		constraintsDo: [ :c |
			c vertical fitContent.
			aBoolean
				ifTrue: [ c horizontal matchParent ]
				ifFalse: [ c horizontal fitContent ] ];
		yourself
]


{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> newReadOnlyColumnCellFor: anObject using: aDescription [
	| aReadOnlyDescription aCellMemento |
	aReadOnlyDescription := aDescription copy
		beReadOnly;
		yourself.
	(self isIconReferenceDescription: aReadOnlyDescription)
		ifTrue: [ aReadOnlyDescription iconHeight: self referenceIconHeight ].
	aCellMemento := GtMagritteMemento
		model: anObject
		description: aReadOnlyDescription asContainer.

	^ self
		newReadOnlyColumnCellFor: anObject
		memento: aCellMemento
		using: aReadOnlyDescription
]

{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> newReadOnlyColumnCellFor: anObject memento: aMemento using: aDescription [
	(aDescription isKindOf: GtMagritteIconDescription)
		ifTrue: [ ^ GtMagritteBuilderUtility
			newIconWithMemento: aMemento
			using: aDescription ].

	(aDescription isKindOf: MAStringDescription)
		ifTrue: [ ^ self
			newTextColumnCellFor: anObject
			using: aDescription ].

	aDescription blocStencil
		ifNotNil: [ :aStencil |
			^ aStencil
				memento: aMemento;
				description: aDescription;
				asElement ].

	^ self
		newTextColumnCellFor: anObject
		using: aDescription
]

{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> newTextColumnCellFor: anObject using: aDescription [
	^ BrColumnCellLabelStencil
		fitContent: (aDescription readToString: anObject)
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
CFMaBuilderUtility class >> relationObjectForItem: anItemViewModel [
	^ anItemViewModel object
]

{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> relationSelectionFrom: aListElement indices: theIndices [
	| theItems |
	theItems := theIndices collect: [ :anIndex |
		self relationObjectForItem: (aListElement viewModel itemAt: anIndex) ].
	^ theItems size = 1
		ifTrue: [ theItems first ]
		ifFalse: [ theItems ]
]
