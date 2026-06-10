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
	| aContainer aList isEditable anAddElement |
	isEditable := aDescription definitive not
		and: [ aDescription newItemStencil isNotNil ].

	aContainer := self newRelationEditorContainer.

	aList := self newRelationListUsing: aDescription.
	aList constraintsDo: [ :c | c padding: (BlInsets top: 10 bottom: 10) ].

	self installRelationEditorFocusOn: aContainer primaryFocusElement: aList.

	aContainer addChild: aList.

	isEditable
		ifTrue: [
			anAddElement := CFMaAddItemViewModel new
				memento: aMemento;
				description: aDescription;
				stencil: aDescription newItemStencil;
				asElement.
			aContainer addChild: anAddElement ].

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
					description: aDescription ].
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
			aContainer states addState: CFMaRelationEditorActiveState uniqueInstance.
			aContainer border: (BlBorder paint: BrGlamorousColors focusedEditorBorderColor width: 1) ];
		when: BlFocusOutEvent
		do: [ :anEvent |
			aContainer states removeState: CFMaRelationEditorActiveState uniqueInstance.
			aContainer border: (BlBorder paint: BrGlamorousColors disabledButtonBorderColor width: 1) ].

	^ aContainer
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
CFMaBuilderUtility class >> installRelationEditorNavigationShortcutsOn: anElement form: aForm [
	anElement
		addShortcut: (BlShortcutWithAction new
			name: 'Move to next form item';
			description: 'Moves to the next form item. If none is found, we cycle back to the first.';
			combination: (BlKeyCombination tab or: BlKeyCombination enter);
			overrideChildren: true;
			action: [ :anEvent |
				BlFocusFinder new
					direction: BlFocusSearchDirectionForward new;
					root: aForm;
					referenceElement: anEvent target;
					nextFocusDo: #requestFocus
					ifNone: [ self requestFirstFocusIn: aForm ] ]);
		addShortcut: (BlShortcutWithAction new
			name: 'Move to previous form item';
			description: 'Moves to the previous form item. If none is found, we cycle back to the last.';
			combination: BlKeyCombination shiftTab;
			overrideChildren: true;
			action: [ :anEvent |
				BlFocusFinder new
					direction: BlFocusSearchDirectionBackward new;
					root: aForm;
					referenceElement: anEvent target;
					nextFocusDo: #requestFocus
					ifNone: [ self requestLastFocusIn: aForm ] ]).
	^ anElement
]

{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> requestFirstFocusIn: aForm [
	| theCandidates |
	theCandidates := (BlFocusFinder new
		root: aForm;
		direction: BlFocusSearchDirectionForward new;
		focusableCandidates).
	theCandidates isEmpty
		ifFalse: [ (theCandidates at: 1) requestFocus ]
]

{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> requestLastFocusIn: aForm [
	| theCandidates |
	theCandidates := (BlFocusFinder new
		root: aForm;
		direction: BlFocusSearchDirectionBackward new;
		focusableCandidates).
	theCandidates isEmpty
		ifFalse: [ (theCandidates at: theCandidates size) requestFocus ]
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
	anAddElement dispatchEvent: BlClickEvent new
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
	^ aList
]

{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> newRelationListItemStencil [
	^ CFMaRelationListItemElementWithSelectionDecorator new
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
