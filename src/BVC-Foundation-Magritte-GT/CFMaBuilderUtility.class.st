Class {
	#name : 'CFMaBuilderUtility',
	#superclass : 'GtMagritteBuilderUtility',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> activateRelationAddElement: anAddElement [
	anAddElement ifNil: [ ^ self ].
	anAddElement requestFocus.
	BlSpace simulateClickOn: anAddElement
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
				self alignReferenceColumnCellChild: aCellChild.
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
CFMaBuilderUtility class >> alignReferenceColumnCellChild: anElement [
	anElement constraintsDo: [ :c |
		c frame horizontal alignLeft.
		c frame vertical alignCenter ]
]

{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> canRemoveToOneUsing: aDescription currentValue: anObject [
	anObject ifNil: [ ^ false ].
	aDescription isReadOnly ifTrue: [ ^ false ].

	[ aDescription validate: nil ]
		on: Error
		do: [ :anException | ^ false ].
	^ true
]

{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> configureColumnedRelationList: aList [
	aList
		hMatchParent;
		vFitContentLimited.
	aList constraintsDo: [ :c |
		c padding: self relationListPadding.
		c maxHeight: self referenceColumnedListMaxHeight ].
	^ aList
]

{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> configureReferenceColumn: aColumn description: aDescription index: anIndex expandingIndex: anExpandingIndex [
	(self isIconReferenceDescription: aDescription)
		ifTrue: [ ^ self ].

	anIndex = anExpandingIndex
		ifTrue: [ aColumn weight: self primaryReferenceColumnWeight ]
		ifFalse: [ aColumn weight: self secondaryReferenceColumnWeight ]
]

{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> expandingReferenceColumnIndexIn: aCollectionOfReferenceDescriptions [
	aCollectionOfReferenceDescriptions withIndexDo: [ :eachReferenceDescription :eachIndex |
		(self isIconReferenceDescription: eachReferenceDescription)
			ifFalse: [ ^ eachIndex ] ].
	^ nil
]

{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> installListClickToPhlowSelectOn: aListElement [
	aListElement
		when: BrListItemElementAttached
		do: [ :anEvent |
			| anItemElement |
			anItemElement := anEvent itemElement.
			anItemElement userData
				at: #cfMaListClickToPhlowSelectHandlerInstalled
				ifAbsentPut: [
					anItemElement addEventHandler: (CFMaListClickToPhlowSelectHandler new
						listWidget: aListElement;
						transformation: GtPhlowSendTransformation default;
						yourself).
					true ] ].
	^ aListElement
]

{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> installOuterFormScrollForwardingOn: aListElement [
	aListElement addEventFilter: CFMaRelationListScrollEventFilter new.
	^ aListElement
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
CFMaBuilderUtility class >> isIconReferenceDescription: aDescription [
	^ aDescription isKindOf: GtMagritteIconDescription
]

{ #category : 'api - ui' }
CFMaBuilderUtility class >> newAccordionListMemento: aMemento using: aDescription [
	^ self
		newToManyRelationEditorMemento: aMemento
		using: aDescription
		list: (self newAccordionRelationListUsing: aDescription)
]

{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> newAccordionRelationListUsing: aDescription [
	| aList |
	aList := BrSimpleList new.
	aList
		hMatchParent;
		vFitContent;
		itemType: [ :anItemTypeFactory :anItemViewModel |
			anItemViewModel elementClass ];
		itemStencil: [ :anItemElementClass |
			anItemElementClass new vFitContent ];
		itemId: [ :anItemViewModel | anItemViewModel object ];
		itemDataBinder: [ :anItemElement :anItemViewModel :anItemIndex |
			anItemElement expanderItemViewModel: anItemViewModel ];
		selectionCallback: [ :theIndices |
			self relationSelectionFrom: aList indices: theIndices ].

	self installOuterFormScrollForwardingOn: aList.
	self installListClickToPhlowSelectOn: aList.
	^ aList
]

{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> newAutoSizingRelationEditorContainer [
	^ self newRelationEditorContainer
		hMatchParent;
		vFitContentLimited;
		yourself
]

{ #category : 'api - ui' }
CFMaBuilderUtility class >> newColumnedListToOneMemento: aMemento using: aDescription [
	| aList |
	aList := self newColumnedRelationListElementMemento: aMemento using: aDescription.
	self configureColumnedRelationList: aList.

	^ self
		newToOneRelationEditorMemento: aMemento
		using: aDescription
		contentElement: aList
		updateContent: [ :theList :aSink |
			self
				onToOneList: theList
				sinkUpdate: aSink
				memento: aMemento
				description: aDescription ]
]

{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> newColumnedRelationEditorMemento: aMemento using: aDescription addElement: anAddElement removeButtonBuilder: aRemoveButtonBuilder removeAction: aRemoveAction sinkUpdate: aSinkUpdate updateRemoveButton: anUpdateRemoveButton [
	| aContainer aList anActionContainer aRemoveButton |
	aContainer := self newAutoSizingRelationEditorContainer.

	aList := self newColumnedRelationListElementMemento: aMemento using: aDescription.
	self configureColumnedRelationList: aList.

	aRemoveButtonBuilder ifNotNil: [
		aRemoveButton := aRemoveButtonBuilder value: aList ].


	aContainer addContentChild: (self newRelationBodyContainerWith: aList using: aDescription).

	(anAddElement isNotNil or: [ aRemoveButton isNotNil ]) ifTrue: [
		anActionContainer := self newRelationActionContainer.

		anAddElement ifNotNil: [ anActionContainer addChild: anAddElement ].
		aRemoveButton ifNotNil: [ anActionContainer addChild: aRemoveButton ].

		aContainer addFooterChild: anActionContainer ].

	aRemoveButton ifNotNil: [
		aList
			when: BrSelectionChanged
			do: [ :anEvent |
				anUpdateRemoveButton value: aRemoveButton value: aList value: nil ] ].

	self
		installRelationEditorShortcutsOn: aContainer
		primaryFocusElement: aList
		addElement: anAddElement
		memento: aMemento
		description: aDescription
		removeAction: [ :anElement | aRemoveAction value: aList value: anElement ].

	aContainer withAsyncSinkDo: [ :anElementSink |
		anElementSink
			sink: AsyncPeekSink new;
			whenUpdate: [ :theContainer :aSink |
				aSinkUpdate value: aList value: aSink.
				aRemoveButton ifNotNil: [
					anUpdateRemoveButton value: aRemoveButton value: aList value: aSink ] ].
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
			self relationSelectionFrom: aList indices: theIndices ].

	self installOuterFormScrollForwardingOn: aList.
	self installListClickToPhlowSelectOn: aList.
	self addReferenceColumnsTo: aList memento: aMemento using: aDescription.
	^ aList
]

{ #category : 'api - ui' }
CFMaBuilderUtility class >> newColumnedRelationListMemento: aMemento using: aDescription [
	| canModify canAdd anAddElement aRemoveButtonBuilder |
	canModify := aDescription isReadOnly not and: [ aDescription definitive not ].
	canAdd := canModify and: [ aDescription newItemStencil isNotNil ].

	canAdd ifTrue: [
		anAddElement := CFMaAddItemViewModel new
			memento: aMemento;
			description: aDescription;
			stencil: aDescription newItemStencil;
			asElement ].

	canModify ifTrue: [
		aRemoveButtonBuilder := [ :aList |
			self
				newToManyRemoveButtonMemento: aMemento
				using: aDescription
				list: aList ] ].

	^ self
		newColumnedRelationEditorMemento: aMemento
		using: aDescription
		addElement: anAddElement
		removeButtonBuilder: aRemoveButtonBuilder
		removeAction: [ :aList :anElement |
			canModify ifTrue: [
				self
					removeSelectedToManyItemFrom: aList
					memento: aMemento
					description: aDescription
					element: anElement ] ]
		sinkUpdate: [ :aList :aSink |
			self
				onFlowList: aList
				sinkUpdate: aSink
				memento: aMemento
				description: aDescription ]
		updateRemoveButton: [ :aButton :aList :aSink |
			self updateToManyRemoveButton: aButton list: aList ]
]

{ #category : 'api - ui' }
CFMaBuilderUtility class >> newCompactListToOneMemento: aMemento using: aDescription [
	| aList |
	aList := self newRelationListUsing: aDescription.
	aList constraintsDo: [ :c | c padding: self relationListPadding ].

	^ self
		newToOneRelationEditorMemento: aMemento
		using: aDescription
		contentElement: aList
		updateContent: [ :theList :aSink |
			self
				onToOneList: theList
				sinkUpdate: aSink
				memento: aMemento
				description: aDescription ]
]

{ #category : 'api - ui' }
CFMaBuilderUtility class >> newEmbeddedFormToOneMemento: aMemento using: aDescription [
	| aFrame |
	aFrame := BrFrame new
		hMatchParent;
		vFitContent;
		yourself.

	^ self
		newToOneRelationEditorMemento: aMemento
		using: aDescription
		contentElement: aFrame
		updateContent: [ :theFrame :aSink |
			self
				onFoundationEmbeddedToOneFrame: theFrame
				sinkUpdate: aSink
				memento: aMemento
				description: aDescription ]
]

{ #category : 'api - ui' }
CFMaBuilderUtility class >> newExpandableListMemento: aMemento using: aDescription [
	^ self
		newToManyRelationEditorMemento: aMemento
		using: aDescription
		list: (self newExpandableRelationListUsing: aDescription)
]

{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> newExpandableRelationListUsing: aDescription [
	^ self newAccordionRelationListUsing: aDescription
]

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

{ #category : 'api - ui' }
CFMaBuilderUtility class >> newFiniteListMemento: aMemento using: aDescription [
	^ self
		newToManyRelationEditorMemento: aMemento
		using: aDescription
		list: (self newFiniteRelationListUsing: aDescription)
]

{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> newFiniteRelationListUsing: aDescription [
	| aList |
	aList := self newGridRelationListUsing: aDescription.
	aList
		singleColumn: true;
		itemSpacing: 0.
	^ aList
]

{ #category : 'api - ui' }
CFMaBuilderUtility class >> newFlowListMemento: aMemento using: aDescription [
	^ self
		newToManyRelationEditorMemento: aMemento
		using: aDescription
		list: (self newRelationListUsing: aDescription)
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

{ #category : 'api - ui' }
CFMaBuilderUtility class >> newGridListMemento: aMemento using: aDescription [
	^ self
		newToManyRelationEditorMemento: aMemento
		using: aDescription
		list: (self newGridRelationListUsing: aDescription)
]

{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> newGridRelationListUsing: aDescription [
	| aList |
	aList := CFMaFiniteFlowList new.
	aList
		minimumItemWidth: self relationGridMinimumItemWidth;
		itemSpacing: aDescription relationGridItemInsets width;
		stencil: ([ :anItemViewModel :anItemIndex :anInternalListElement |
			| anItemContent anItemElement |
			anItemContent := aDescription blocItemStencil
				listElement: aList;
				rowValue: anItemViewModel;
				rowIndex: anItemIndex;
				build.
			anItemElement := BrFrame new
				hExact: self relationGridMinimumItemWidth;
				vFitContent;
				margin: aDescription relationGridItemInsets;
				addAptitude: CFMaListItemAptitude;
				addChild: anItemContent;
				yourself.
			anItemElement addEventHandler: (CFMaFiniteListItemSelectionHandler new
				listWidget: aList;
				itemIndex: anItemIndex;
				yourself).
			anItemElement ] asStencilBuilder: BrListRowStencilBuilder);
		selectionCallback: [ :theIndices |
			self relationSelectionFrom: aList indices: theIndices ].
	self installOuterFormScrollForwardingOn: aList.
	^ aList
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
CFMaBuilderUtility class >> newPhlowLinkToOneMemento: aMemento using: aDescription [
	| aList |
	aList := self newRelationListUsing: aDescription.
	aList constraintsDo: [ :c | c padding: self relationListPadding ].

	^ self
		newToOneRelationEditorMemento: aMemento
		using: aDescription
		contentElement: aList
		updateContent: [ :theList :aSink |
			self
				onToOneList: theList
				sinkUpdate: aSink
				memento: aMemento
				description: aDescription ]
]

{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> newReadOnlyColumnCellFor: anObject memento: aMemento using: aDescription [
	(aDescription isKindOf: GtMagritteIconDescription)
		ifTrue: [
			^ (GtMagritteBuilderUtility
				newIconWithMemento: aMemento
				using: aDescription)
				padding: self referenceIconPadding;
				yourself ].

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
CFMaBuilderUtility class >> newRelationActionContainer [
	^ BrHorizontalPane new
		hMatchParent;
		vFitContent;
		cellSpacing: 8;
		margin: self relationActionContainerMargin;
		padding: (BlInsets top: 5 right: 6 bottom: 5 left: 6);
		background: (Color white alpha: 0.16);
		yourself
]

{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> newRelationBodyContainerWith: anElement using: aDescription [
	^ BrVerticalPane new
		hMatchParent;
		vFitContent;
		padding: aDescription relationBodyInsets;
		addChild: anElement;
		yourself
]

{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> newRelationEditorContainer [
	^ CFMaRelationSurfaceElement new
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
			self relationSelectionFrom: aList indices: theIndices ].

	self installOuterFormScrollForwardingOn: aList.
	self installListClickToPhlowSelectOn: aList.
	^ aList
]

{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> newTextColumnCellFor: anObject using: aDescription [
	^ BrColumnCellLabelStencil new
		text: (aDescription readToString: anObject);
		create
]

{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> newToManyRelationEditorMemento: aMemento using: aDescription list: aList [
	| aContainer canModify canAdd anActionContainer anAddElement aRemoveButton |
	canModify := aDescription isReadOnly not and: [ aDescription definitive not ].
	canAdd := canModify and: [ aDescription newItemStencil isNotNil ].

	aContainer := self newRelationEditorContainer.

	aList constraintsDo: [ :c | c padding: self relationListPadding ].


	aContainer addContentChild: (self newRelationBodyContainerWith: aList using: aDescription).

	canModify ifTrue: [
		anActionContainer := self newRelationActionContainer.

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

		aContainer addFooterChild: anActionContainer.

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

{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> newToOneEditorRemoveButtonMemento: aMemento using: aDescription [
	^ BrButton new
		aptitude: BrGlamorousButtonWithIconCircularAptitude;
		icon: BrGlamorousVectorIcons remove;
		label: 'Remove';
		action: [ :anElement |
			self
				removeToOneMemento: aMemento
				using: aDescription
				element: anElement ];
		disable;
		constraintsDo: [ :c | c flow vertical alignCenter ];
		yourself
]

{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> newToOneRelationEditorMemento: aMemento using: aDescription contentElement: aContentElement updateContent: anUpdateBlock [
	| aContainer canModify canAdd anActionContainer anAddElement aRemoveButton |
	canModify := aDescription isReadOnly not.
	canAdd := canModify and: [ aDescription newItemStencil isNotNil ].

	aContainer := self newRelationEditorContainer.
	aContainer addContentChild: (self newRelationBodyContainerWith: aContentElement using: aDescription).

	(canAdd or: [ canModify ]) ifTrue: [
		anActionContainer := self newRelationActionContainer.

		canAdd ifTrue: [
			anAddElement := CFMaToOneAddItemViewModel new
				memento: aMemento;
				description: aDescription;
				stencil: aDescription newItemStencil;
				asElement.
			anActionContainer addChild: anAddElement ].

		canModify ifTrue: [
			aRemoveButton := self
				newToOneEditorRemoveButtonMemento: aMemento
				using: aDescription.
			anActionContainer addChild: aRemoveButton ].

		aContainer addFooterChild: anActionContainer ].

	self
		installRelationEditorShortcutsOn: aContainer
		primaryFocusElement: aContentElement
		addElement: anAddElement
		memento: aMemento
		description: aDescription
		removeAction: [ :anElement |
			self
				removeToOneMemento: aMemento
				using: aDescription
				element: anElement ].

	aContainer withAsyncSinkDo: [ :anElementSink |
		anElementSink
			sink: AsyncPeekSink new;
			whenUpdate: [ :theContainer :aSink |
				anUpdateBlock value: aContentElement value: aSink.
				aRemoveButton ifNotNil: [
					self
						updateToOneRemoveButton: aRemoveButton
						description: aDescription
						sinkUpdate: aSink ] ].
		(aMemento readObservableValueUsing: aDescription)
			observe: anElementSink ].

	^ aContainer
]

{ #category : 'private - support' }
CFMaBuilderUtility class >> onFlowList: aListElement sinkUpdate: aSink memento: aMemento description: aDescription [
	| aModels theExistingViewModels |
	aModels := aSink value currentValue ifNil: [ #() ].
	theExistingViewModels := aListElement viewModel items.

	(aMemento isKindOf: CFMaMemento)
		ifTrue: [ aMemento retainChildMementosFor: aModels inRelation: aDescription ].

	(self relationModels: aModels matchViewModels: theExistingViewModels)
		ifTrue: [ ^ aListElement ].

	^ aListElement items: (self
		relationItemViewModelsForModels: aModels
		existingViewModels: theExistingViewModels
		memento: aMemento
		description: aDescription)
]

{ #category : 'private - support' }
CFMaBuilderUtility class >> onFoundationEmbeddedToOneFrame: aFrame sinkUpdate: aSink memento: aMemento description: aDescription [
	| anObject aChildMemento hasPresentedObject |
	anObject := aSink value currentValue.
	hasPresentedObject := aFrame userData includesKey: #cfMaPresentedObject.

	(hasPresentedObject
		and: [ (aFrame userData at: #cfMaPresentedObject) == anObject ])
			ifTrue: [ ^ aFrame ].

	aFrame removeChildren.
	aFrame userData at: #cfMaPresentedObject put: anObject.

	anObject ifNil: [
		(aMemento isKindOf: CFMaMemento)
			ifTrue: [ aMemento retainChildMementosFor: #() inRelation: aDescription ].
		^ aFrame ].

	aChildMemento := (aMemento isKindOf: CFMaMemento)
		ifTrue: [
			aMemento retainChildMementosFor: { anObject } inRelation: aDescription.
			aMemento childMementoFor: anObject inRelation: aDescription ]
		ifFalse: [ CFMaMemento model: anObject ].

	aFrame addChild: ((CFMaViewModel
		forObject: anObject
		memento: aChildMemento)
			presentationClass: CFMaPresentation;
			ignoreImplicitActions;
			asElement).
	^ aFrame
]

{ #category : 'private - support' }
CFMaBuilderUtility class >> onToOneList: aListElement sinkUpdate: aSink memento: aMemento description: aDescription [
	| anObject aModels theExistingViewModels |
	anObject := aSink value currentValue.
	aModels := anObject ifNil: [ #() ] ifNotNil: [ { anObject } ].
	theExistingViewModels := aListElement viewModel items.

	(aMemento isKindOf: CFMaMemento)
		ifTrue: [ aMemento retainChildMementosFor: aModels inRelation: aDescription ].

	(self relationModels: aModels matchViewModels: theExistingViewModels)
		ifTrue: [ ^ aListElement ].

	^ aListElement items: (self
		relationItemViewModelsForModels: aModels
		existingViewModels: theExistingViewModels
		memento: aMemento
		description: aDescription)
]

{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> primaryReferenceColumnWeight [
	^ 3
]

{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> referenceColumnedListMaxHeight [
	^ 200
]

{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> referenceDescriptionsFor: aDescription [
	^ aDescription reference asContainer children asArray
]

{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> referenceIconHeight [
	^ 18
]

{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> referenceIconPadding [
	^ BlInsets top: 3 right: 0 bottom: 3 left: 4
]

{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> relationActionContainerMargin [
	^ BlInsets empty
]

{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> relationEditorCellSpacing [
	^ 0
]

{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> relationEditorPadding [
	^ BlInsets empty
]

{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> relationGridMinimumItemWidth [
	^ 280
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
CFMaBuilderUtility class >> relationListPadding [
	^ BlInsets empty
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
CFMaBuilderUtility class >> removeToManyObject: anObject memento: aMemento using: aDescription element: anElement [
	| anExistingItems aNewItems |
	anExistingItems := aMemento readUsing: aDescription.
	anExistingItems ifNil: [ ^ self ].
	aNewItems := anExistingItems copyWithout: anObject.
	anExistingItems = aNewItems ifTrue: [ ^ self ].
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

{ #category : 'private - relation editor' }
CFMaBuilderUtility class >> secondaryReferenceColumnWeight [
	^ 1
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

{ #category : 'private - support' }
CFMaBuilderUtility class >> updateToOneRemoveButton: aButton description: aDescription sinkUpdate: aSink [
	(self
		canRemoveToOneUsing: aDescription
		currentValue: aSink value currentValue)
		ifTrue: [ aButton enable ]
		ifFalse: [ aButton disable ]
]
