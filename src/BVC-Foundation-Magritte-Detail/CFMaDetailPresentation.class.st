Class {
	#name : 'CFMaDetailPresentation',
	#superclass : 'CFMaPresentation',
	#instVars : [
		'groupConfigurations',
		'groups',
		'categoryGroups',
		'embeddedRowsContainer'
	],
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'initialization' }
CFMaDetailPresentation >> initialize [
	super initialize.
	groupConfigurations := Dictionary new.
	groups := Dictionary new.
	categoryGroups := Dictionary new
]

{ #category : 'api - building' }
CFMaDetailPresentation >> build [
	groups removeAll.
	categoryGroups removeAll.
	self form background: self formBackgroundPaint.
	^ super build
]

{ #category : 'visiting-description' }
CFMaDetailPresentation >> visitContainer: aDescription [
	| thePresentationItems |
	aDescription == self objectDescription ifFalse: [
		^ super visitContainer: aDescription ].

	thePresentationItems := OrderedCollection new
		addAll: aDescription children;
		addAll: (self memento magritteActions reject: #isToolbarAction);
		yourself.
	thePresentationItems sort: [ :a :b | a priority < b priority ].

	thePresentationItems do: [ :each |
		(each isKindOf: MAActionDescription)
			ifTrue: [ self addActionRowUsing: each ]
			ifFalse: [ self visit: each ] ]
]

{ #category : 'private - appearance' }
CFMaDetailPresentation >> formBackgroundPaint [
	^ Color white
]

{ #category : 'configuration' }
CFMaDetailPresentation >> group: aGroup configure: aBlock [
	| aConfiguration |
	aConfiguration := self groupConfigurationFor: aGroup.
	aBlock cull: aConfiguration.
	^ self
]

{ #category : 'configuration' }
CFMaDetailPresentation >> groupConfigurationFor: aGroup [
	^ groupConfigurations
		at: aGroup
		ifAbsentPut: [ CFMaDetailGroupConfiguration new ]
]

{ #category : 'private - groups' }
CFMaDetailPresentation >> containerForDescription: aDescription [
	| aGroup aConfiguration |
	embeddedRowsContainer ifNotNil: [ ^ embeddedRowsContainer ].
	aConfiguration := self groupConfigurationFor: aDescription group.
	aGroup := self
		groupFor: aDescription group
		configuredBy: aConfiguration.
	aDescription categories do: [ :aCategory |
		aConfiguration := aConfiguration categoryConfigurationFor: aCategory.
		aGroup := self
			category: aCategory
			in: aGroup
			configuredBy: aConfiguration ].
	^ aGroup rows
]

{ #category : 'private - groups' }
CFMaDetailPresentation >> groupFor: aGroup configuredBy: aConfiguration [
	^ groups
		at: aGroup
		ifAbsentPut: [
			self
				newGroup: aGroup
				in: self hostElement
				configuredBy: aConfiguration ]
]

{ #category : 'private - groups' }
CFMaDetailPresentation >> category: aCategory in: aParentGroup configuredBy: aConfiguration [
	| aKey |
	aKey := { aParentGroup. aCategory }.
	^ categoryGroups
		at: aKey
		ifAbsentPut: [
			self
				newGroupIn: aParentGroup
				label: aCategory
				configuredBy: aConfiguration ]
]

{ #category : 'private - groups' }
CFMaDetailPresentation >> newGroup: aGroup in: aParent configuredBy: aConfiguration [
	^ (self
		newGroupIn: aParent
		configuredBy: aConfiguration)
		group: aGroup;
		yourself
]

{ #category : 'private - groups' }
CFMaDetailPresentation >> newGroupIn: aParent configuredBy: aConfiguration [
	| anElement |
	anElement := CFMaDetailGroupElement new
		configuration: aConfiguration;
		yourself.
	aParent addChild: anElement.
	^ anElement
]

{ #category : 'private - groups' }
CFMaDetailPresentation >> newGroupIn: aParent label: aLabel configuredBy: aConfiguration [
	| anElement |
	anElement := CFMaDetailGroupElement new
		configuration: aConfiguration;
		yourself.
	aParent addGroup: anElement label: aLabel.
	^ anElement
]

{ #category : 'configuration - fields' }
CFMaDetailPresentation >> newFieldConfiguration [
	| aConfiguration |
	aConfiguration := super newFieldConfiguration.
	aConfiguration icon
		beMedium;
		beChromed.
	^ aConfiguration
]

{ #category : 'private - building' }
CFMaDetailPresentation >> prepareResourceDropdown: aDropdown [
	aDropdown
		margin: BlInsets empty;
		padding: (BlInsets top: 2 right: CFMaDetailScalarFieldMetrics trailingControlInset bottom: 2 left: 5);
		geometry: (BlRoundedRectangleGeometry cornerRadius: 4);
		background: (Color black alpha: 0.05).
	^ aDropdown
]

{ #category : 'private - actions' }
CFMaDetailPresentation >> addActionRowUsing: anActionDescription [
	| aLabel aSupportingElement aButton aRow |
	aLabel := BrLabel new
		text: anActionDescription label asRopedText;
		aptitude: self defaultLabelAptitude;
		fitContent.

	aSupportingElement := anActionDescription comment
		ifNil: [ nil ]
		ifNotNil: [ :aComment |
			aComment isEmpty
				ifTrue: [ nil ]
				ifFalse: [ self supportingElementFor: anActionDescription ] ].

	aButton := self actionButtonFor: anActionDescription.
	aRow := self
		newRowLeading: nil
		description: aLabel
		supporting: aSupportingElement
		content: aButton
		accessories: #()
		trailing: nil.
	(self containerForDescription: anActionDescription) addChild: aRow
]

{ #category : 'private - actions' }
CFMaDetailPresentation >> actionButtonFor: anActionDescription [
	| aButton |
	aButton := BrButton new
		beNormalSize;
		aptitude: BrGlamorousButtonWithLabelAptitude new;
		label: anActionDescription label;
		hFitContent;
		vExact: 32;
		padding: (BlInsets top: 4 right: 14 bottom: 4 left: 14);
		geometry: (BlRoundedRectangleGeometry cornerRadius: 7);
		border: BlBorder empty;
		yourself.

	anActionDescription action ifNotNil: [ :anAction |
		aButton action: [ :theButton |
			anAction
				cull: self memento model
				cull: theButton
				cull: self memento
				cull: anActionDescription ] ].

	anActionDescription enabled ifNotNil: [ :aBoolean |
		aButton enabled: aBoolean ].
	anActionDescription visible ifNotNil: [ :aBoolean |
		aButton visibility: (aBoolean
			ifTrue: [ BlVisibility visible ]
			ifFalse: [ BlVisibility gone ]) ].

	aButton addAptitude: (BrStyleCommonAptitude new
		default: [ :aStyle |
			aStyle
				background: (Color black alpha: 0.08);
				border: BlBorder empty ];
		hovered: [ :aStyle |
			aStyle
				background: (Color black alpha: 0.12);
				border: BlBorder empty ];
		pressed: [ :aStyle |
			aStyle
				background: (Color black alpha: 0.16);
				border: BlBorder empty ]).
	self installFormNavigationOn: aButton.
	^ aButton
]

{ #category : 'private - building' }
CFMaDetailPresentation >> addBooleanField: aDescription [
	| aBooleanElement aMemento aLabel |
	aMemento := self memento.

	aDescription blocStencil
		ifNotNil: [ :aStencil |
			aBooleanElement := aStencil
				memento: aMemento;
				description: aDescription;
				asElement ]
		ifNil: [
			aBooleanElement := CFMaDetailBooleanElement new
				fieldViewModel: (GtMagritteFieldViewModel new
					memento: aMemento;
					description: aDescription) ].

	aLabel := self addFieldElement: aBooleanElement using: aDescription.
	aDescription hasCustomLabels ifTrue: [
		aLabel padding: aLabel padding + (BlInsets top: self defaultSpacing) ]
]

{ #category : 'private - building' }
CFMaDetailPresentation >> addDirectoryDropdown: aDescription [
	| aDropdown |
	aDropdown := GtMagritteBuilderUtility
		newDirectoryDropdownMemento: self memento
		using: aDescription.
	self prepareResourceDropdown: aDropdown.
	self addFieldElement: aDropdown using: aDescription
]

{ #category : 'private - building' }
CFMaDetailPresentation >> addFileDropdown: aDescription [
	| aDropdown |
	aDropdown := GtMagritteBuilderUtility
		newFileDropdownMemento: self memento
		using: aDescription.
	self prepareResourceDropdown: aDropdown.
	self addFieldElement: aDropdown using: aDescription
]

{ #category : 'private - composition' }
CFMaDetailPresentation >> addLabel: aLabel field: aFieldElement for: aDescription [
	| aSupportingElement aRow aFieldConfiguration aLeadingElement |
	aFieldConfiguration := self fieldConfigurationFor: aDescription.
	aLeadingElement := self
		leadingElementFor: aDescription
		configuration: aFieldConfiguration.
	aSupportingElement := aDescription hasComment
		ifTrue: [ self supportingElementFor: aDescription ]
		ifFalse: [ nil ].
	aRow := self
		newRowLeading: aLeadingElement
		description: aLabel
		supporting: aSupportingElement
		content: aFieldElement
		accessories: (self newAccessoriesFor: aDescription)
		trailing: nil.
	(self containerForDescription: aDescription) addChild: aRow
]

{ #category : 'private - accessories' }
CFMaDetailPresentation >> newAccessoriesFor: aDescription [
	| accessories information |
	accessories := OrderedCollection new.
	aDescription isWithChangeIndicator ifTrue: [
		accessories add: (self newRevertAccessoryFor: aDescription) ].
	accessories add: (self newValidationAccessoryFor: aDescription).
	information := aDescription informationFor: self memento model.
	information ifNotNil: [
		accessories add: (self newInformationAccessoryFor: information) ].
	^ accessories
]

{ #category : 'private - accessories' }
CFMaDetailPresentation >> newAccessoryButtonIconNamed: anIconName [
	| anIcon |
	anIcon := FontAwesomeIcons defaultStyle icon: anIconName.
	anIcon
		color: CFMaDetailColours secondaryForeground;
		size: 12 @ 12.
	^ BrButton new
		aptitude: BrGlamorousButtonIconAptitude new
			+ BrGlamorousButtonLayoutAptitude new
			+ BrGlamorousButtonWithLabelTooltipAptitude2 new;
		icon: anIcon;
		background: Color transparent;
		border: BlBorder empty;
		padding: BlInsets empty;
		hExact: 16;
		vExact: 20;
		yourself
]

{ #category : 'private - accessories' }
CFMaDetailPresentation >> newInformationAccessoryFor: information [
	^ (self newAccessoryButtonIconNamed: #circleInfo)
		label: information asString;
		yourself
]

{ #category : 'private - accessories' }
CFMaDetailPresentation >> newRevertAccessoryFor: aDescription [
	| aButton |
	aButton := self newAccessoryButtonIconNamed: #arrowRotateLeft.
	aButton
		label: 'Revert to saved value';
		action: [ self memento revertUsing: aDescription ];
		visibility: BlVisibility gone.
	aButton withAsyncSinkDo: [ :anElementSink |
		anElementSink
			sink: AsyncPeekSink new;
			whenUpdate: [ :anElement :aSink |
				aSink value isChanged
					ifTrue: [ anElement visibility: BlVisibility visible ]
					ifFalse: [ anElement visibility: BlVisibility gone ] ].
		(self memento readObservableValueUsing: aDescription) observe: anElementSink ].
	^ aButton
]

{ #category : 'private - accessories' }
CFMaDetailPresentation >> newValidationAccessoryFor: aDescription [
	| aButton |
	aButton := self newAccessoryButtonIconNamed: #triangleExclamation.
	aButton
		label: 'Validation failed';
		visibility: BlVisibility gone.
	aButton withAsyncSinkDo: [ :anElementSink |
		anElementSink
			sink: AsyncPeekSink new;
			whenUpdate: [ :anElement :aSink |
				| aValidationResult |
				aValidationResult := aSink value.
				aValidationResult isSuccess
					ifTrue: [ anElement visibility: BlVisibility gone ]
					ifFalse: [
						anElement
							label: aValidationResult issuesDescription;
							visibility: BlVisibility visible ] ].
		(self memento validatorUsing: aDescription) observe: anElementSink ].
	^ aButton
]

{ #category : 'defaults' }
CFMaDetailPresentation >> defaultLabelAptitude [
	^ BrGlamorousLabelAptitude new
		foreground: CFMaDetailColours primaryForeground;
		fontSize: 13
]

{ #category : 'private - composition' }
CFMaDetailPresentation >> supportingElementFor: aDescription [
	^ self supportingElementWithText: aDescription comment
]

{ #category : 'private - composition' }
CFMaDetailPresentation >> supportingElementWithText: aString [
	^ BrEditor new
		aptitude: BrGlamorousRegularEditorAptitude new;
		beReadOnlyWithoutSelection;
		focusability: BlFocusability none;
		text: (aString asRopedText
			foreground: CFMaDetailColours tertiaryForeground;
			fontSize: 11);
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical fitContent ];
		background: Color transparent;
		border: BlBorder empty;
		padding: BlInsets empty;
		margin: BlInsets empty;
		yourself
]

{ #category : 'private - icons' }
CFMaDetailPresentation >> leadingElementFor: aDescription configuration: aFieldConfiguration [
	| anIcon anIconConfiguration |
	anIcon := aDescription iconFor: self memento model.
	anIcon ifNil: [ ^ nil ].
	anIconConfiguration := aFieldConfiguration icon.
	^ anIconConfiguration isUnadorned
		ifTrue: [ self unadornedIconElement: anIcon configuration: anIconConfiguration ]
		ifFalse: [ self chromedIconElement: anIcon configuration: anIconConfiguration ]
]

{ #category : 'private - icons' }
CFMaDetailPresentation >> chromedIconElement: anIcon configuration: anIconConfiguration [
	| aTile |
	aTile := CFIconTile new
		icon: anIcon;
		backgroundColor: anIconConfiguration backgroundColor;
		yourself.
	anIconConfiguration isSmall ifTrue: [ aTile beSmall ].
	anIconConfiguration isMedium ifTrue: [ aTile beMedium ].
	anIconConfiguration isLarge ifTrue: [ aTile beLarge ].
	^ aTile
]

{ #category : 'private - composition' }
CFMaDetailPresentation >> rowInsets [
	^ BlInsets top: 6 right: 8 bottom: 6 left: 8
]

{ #category : 'private - icons' }
CFMaDetailPresentation >> unadornedIconElement: anIcon configuration: anIconConfiguration [
	anIconConfiguration isSmall ifTrue: [ anIcon size: 20 @ 20 ].
	anIconConfiguration isMedium ifTrue: [ anIcon size: 28 @ 28 ].
	anIconConfiguration isLarge ifTrue: [ anIcon size: 44 @ 44 ].
	^ anIcon
]

{ #category : 'private - composition' }
CFMaDetailPresentation >> newRowLeading: aLeadingElement description: aDescriptionElement supporting: aSupportingElement content: aContentElement accessories: accessoryElements [
	^ self
		newRowLeading: aLeadingElement
		description: aDescriptionElement
		supporting: aSupportingElement
		content: aContentElement
		accessories: accessoryElements
		trailing: nil
]

{ #category : 'private - composition' }
CFMaDetailPresentation >> newRowLeading: aLeadingElement description: aDescriptionElement supporting: aSupportingElement content: aContentElement accessories: accessoryElements trailing: aTrailingElement [
	| aRow |
	aRow := BlElement new
		layout: CFMaDetailRowLayout new;
		background: Color transparent;
		border: BlBorder empty;
		padding: self rowInsets;
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical fitContent ];
		yourself.

	aLeadingElement ifNotNil: [
		aLeadingElement margin: BlInsets empty.
		aLeadingElement constraintsDo: [ :c | (c at: CFMaDetailRowLayout) beLeading ].
		aRow addChild: aLeadingElement ].
	aDescriptionElement ifNotNil: [
		aDescriptionElement margin: BlInsets empty.
		aDescriptionElement constraintsDo: [ :c | (c at: CFMaDetailRowLayout) beDescription ].
		aRow addChild: aDescriptionElement ].
	aSupportingElement ifNotNil: [
		aSupportingElement margin: BlInsets empty.
		aSupportingElement constraintsDo: [ :c | (c at: CFMaDetailRowLayout) beSupporting ].
		aRow addChild: aSupportingElement ].
	aContentElement ifNotNil: [
		aContentElement
			margin: BlInsets empty;
			clipChildren: false.
		aContentElement constraintsDo: [ :c | (c at: CFMaDetailRowLayout) beContent ].
		aRow addChild: aContentElement ].
	accessoryElements do: [ :anAccessory |
		anAccessory margin: BlInsets empty.
		anAccessory constraintsDo: [ :c | (c at: CFMaDetailRowLayout) beAccessory ].
		aRow addChild: anAccessory ].
	aTrailingElement ifNotNil: [
		aTrailingElement margin: BlInsets empty.
		aTrailingElement constraintsDo: [ :c | (c at: CFMaDetailRowLayout) beTrailing ].
		aRow addChild: aTrailingElement ].
	^ aRow
]

{ #category : 'private - building' }
CFMaDetailPresentation >> addSingleOptionDropdownUsing: aDescription [
	self
		addPopupFieldUsing: aDescription
		values: aDescription options
		display: [ :aValue | aDescription displayStringFor: aValue ]
]

{ #category : 'private - building' }
CFMaDetailPresentation >> addNumberPopupUsing: aDescription configuration: aPopupConfiguration [
	| someValues aCurrentValue |
	someValues := aPopupConfiguration values.
	someValues isEmpty ifTrue: [
		self error: 'A popup field representation requires values' ].
	aCurrentValue := self memento readUsing: aDescription.
	(someValues includes: aCurrentValue) ifFalse: [
		self error: 'The current field value must be present in the popup values' ].
	self
		addPopupFieldUsing: aDescription
		values: someValues
		display: [ :aValue | aDescription displayStringFor: aValue ]
]

{ #category : 'private - building' }
CFMaDetailPresentation >> addPopupFieldUsing: aDescription values: someValues display: aDisplayBlock [
	| aPopup aField |
	aPopup := self
		newPopupUsing: aDescription
		values: someValues
		display: aDisplayBlock.
	aField := CFMaDetailPopupFieldElement new
		popup: aPopup;
		yourself.
	self addShortcutsTo: aField.
	self addFieldElement: aField using: aDescription
]

{ #category : 'private - building' }
CFMaDetailPresentation >> newPopupUsing: aDescription values: someValues display: aDisplayBlock [
	| aPopup aDropdownAptitude |
	aPopup := self newPopupDisplayUsing: aDescription display: aDisplayBlock.
	aDropdownAptitude := CFMaDetailDropdownAptitude
		handle: [ self newPopupHandleUsing: aDescription display: aDisplayBlock ]
		content: [
			self
				newPopupContent: aPopup
				using: aDescription
				values: someValues
				display: aDisplayBlock ].
	aDropdownAptitude
		withContainerAreaBuilders: {
			self popupAreaBuilderUsing: aDescription values: someValues };
		menuContainerDo: [ :aContainer |
			aContainer
				padding: BlInsets empty;
				aptitude: (BrStyleCommonAptitude new
					default: [ :aStyle |
						aStyle
							background: Color transparent;
							border: BlBorder empty ]) ].
	aPopup addAptitude: aDropdownAptitude.
	^ aPopup
]

{ #category : 'private - building' }
CFMaDetailPresentation >> popupAreaBuilderUsing: aDescription values: someValues [
	^ BlSteppedLayoutAreaBuilder new
		mark: BlSteppedLayoutMark bottomRight;
		direction: #right;
		alignTopLeft;
		bounds: [ :aState |
			| currentValue currentIndex selectedOffset left top |
			currentValue := self memento readUsing: aDescription.
			currentIndex := someValues indexOf: currentValue ifAbsent: [ 1 ].
			selectedOffset := CFMaDetailPopupMetrics selectedRowOffsetForIndex: currentIndex.
			left := (aState occupiedBounds left + CFMaDetailPopupMetrics menuHorizontalOffset)
				max: aState containerPositionXWithPadding.
			top := (aState occupiedBounds top - selectedOffset)
				max: aState containerPositionYWithPadding.
			left @ top corner: aState containerExtentWithPadding ];
		yourself
]

{ #category : 'private - building' }
CFMaDetailPresentation >> newPopupContent: aPopup using: aDescription values: someValues display: aDisplayBlock [
	| aList aCurrentValue aCurrentIndex |
	((aDescription isKindOf: MAOptionDescription)
		and: [ aDescription hasProperty: #blocItemStencil ]) ifTrue: [
		^ GtMagritteBuilderUtility
			newSingleOptionDropdownContent: aPopup
			memento: self memento
			description: aDescription ].

	aList := BrSimpleList new
		itemStencil: [ :anItemType :aListWidget | CFMaDetailPopupOptionElement new ];
		itemDataBinder: [ :anItemElement :anItemObject :anItemIndex |
			anItemElement
				text: (aDisplayBlock cull: anItemObject);
				activateBlock: [
					(aList isSelectedAt: anItemIndex)
						ifTrue: [ aPopup fireEvent: BrDropdownHideWish new ] ] ];
		hFitContent;
		vFitContent;
		padding: (BlInsets all: CFMaDetailPopupMetrics menuInset);
		geometry: (BlRoundedRectangleGeometry cornerRadius: CFMaDetailPopupMetrics menuCornerRadius);
		background: CFMaDetailPopupMetrics menuBackgroundColor;
		border: (BlBorder paint: (Color black alpha: 0.18) width: 0.5);
		addAptitude: BrShadowAptitude new;
		items: someValues;
		yourself.

	aCurrentValue := self memento readUsing: aDescription.
	aCurrentIndex := someValues indexOf: aCurrentValue ifAbsent: [ 0 ].
	aCurrentIndex > 0 ifTrue: [ aList selectOne: aCurrentIndex ].

	aList when: BrSelectionChanged do: [ :anEvent |
		| aWidgetElement |
		aWidgetElement := anEvent currentTarget.
		anEvent selectedDo: [ :anInterval |
			| selectedObject |
			selectedObject := aWidgetElement viewModel itemAt: anInterval first.
			GtMagritteBuilderUtility
				write: selectedObject
				using: aDescription
				memento: self memento
				element: aPopup.
			aPopup fireEvent: BrDropdownHideWish new ] ].
	^ aList
]

{ #category : 'private - building' }
CFMaDetailPresentation >> newPopupHandleUsing: aDescription display: aDisplayBlock [
	| aValue |
	aValue := self memento readUsing: aDescription.
	^ CFMaDetailPopupElement new
		text: (aDisplayBlock cull: aValue);
		visibility: BlVisibility hidden;
		yourself
]

{ #category : 'private - building' }
CFMaDetailPresentation >> newPopupDisplayUsing: aDescription display: aDisplayBlock [
	| aPopup |
	aPopup := CFMaDetailPopupElement new.
	aPopup withAsyncSinkDo: [ :anElementSink |
		anElementSink
			sink: AsyncPeekSink new;
			whenUpdate: [ :thePopup :aSink |
				| aValue |
				aValue := aSink value currentValue.
				thePopup text: (aDisplayBlock cull: aValue) ].
		(self memento readObservableValueUsing: aDescription) observe: anElementSink ].
	^ aPopup
]

{ #category : 'private - building' }
CFMaDetailPresentation >> addNumberSliderUsing: aDescription [
	| aMinimum aMaximum aSlider |
	aMinimum := aDescription min.
	aMaximum := aDescription max.
	(aMinimum isNil or: [ aMaximum isNil ]) ifTrue: [
		self error: 'A slider field representation requires both minimum and maximum values' ].
	aMinimum < aMaximum ifFalse: [
		self error: 'A slider field representation requires minimum to be less than maximum' ].
	aSlider := CFMaDetailSliderElement new
		minimum: aMinimum maximum: aMaximum;
		displayBlock: [ :aValue | aDescription displayStringFor: aValue ];
		value: (self memento readUsing: aDescription);
		valueChangedBlock: [ :aValue |
			GtMagritteBuilderUtility
				write: aValue
				using: aDescription
				memento: self memento
				element: aSlider ];
		yourself.
	aSlider withAsyncSinkDo: [ :anElementSink |
		anElementSink
			sink: AsyncPeekSink new;
			whenUpdate: [ :theSlider :aSink |
				theSlider value: aSink value currentValue ].
		(self memento readObservableValueUsing: aDescription) observe: anElementSink ].
	self addShortcutsTo: aSlider.
	self addFieldElement: aSlider using: aDescription
]


{ #category : 'private - relations' }
CFMaDetailPresentation >> buildEmbeddedRowsIn: aContainer [
	| theDescriptions |
	identityAffordanceEmitted := false.
	fieldConfigurations removeAll.
	containersByGroup removeAll.
	ungroupedContainer := nil.
	groups removeAll.
	categoryGroups removeAll.
	embeddedRowsContainer := aContainer.

	theDescriptions := OrderedCollection new
		addAll: self objectDescription children;
		yourself.
	theDescriptions sort: [ :a :b | a priority < b priority ].

	[ theDescriptions do: [ :each | self visit: each ] ]
		ensure: [ embeddedRowsContainer := nil ].
	^ aContainer rows copy
]

{ #category : 'private - relations' }
CFMaDetailPresentation >> newEmbeddedRowsFor: anObject description: aDescription [
	| aChildMemento aChildPresentation aTemporaryCard theRows |
	aChildMemento := self memento
		childMementoFor: anObject
		inRelation: aDescription.
	aChildPresentation := self class new
		form: self form;
		memento: aChildMemento;
		yourself.
	aTemporaryCard := CFMaDetailGroupCardElement new.
	theRows := aChildPresentation buildEmbeddedRowsIn: aTemporaryCard.
	theRows copy do: [ :aRow | aTemporaryCard removeRow: aRow ].
	^ theRows
]

{ #category : 'private - relations' }
CFMaDetailPresentation >> addToOneEmbeddedUsing: aDescription [
	| aContainer aHeaderContent aHeaderRow anAddElement childRows |
	aContainer := self containerForDescription: aDescription.
	anAddElement := self newToOneAddElementUsing: aDescription.
	aHeaderContent := self newRelationValueSlotWith: nil.
	self addFieldElement: aHeaderContent using: aDescription.
	aHeaderRow := aContainer rows last.
	childRows := OrderedCollection new.

	aHeaderContent withAsyncSinkDo: [ :anElementSink |
		anElementSink
			sink: AsyncPeekSink new;
			whenUpdate: [ :theElement :aSink |
				childRows := self
					updateToOneEmbeddedRows: childRows
					in: aContainer
					after: aHeaderRow
					with: aSink value currentValue
					addElement: anAddElement
					headerContent: theElement
					description: aDescription ].
		(self memento readObservableValueUsing: aDescription)
			observe: anElementSink ]
]

{ #category : 'private - relations' }
CFMaDetailPresentation >> updateToOneEmbeddedRows: oldRows in: aContainer after: aHeaderRow with: anObject addElement: anAddElement headerContent: aHeaderContent description: aDescription [
	| newRows headerIndex |
	oldRows copy do: [ :aRow | aContainer removeRow: aRow ].
	aHeaderContent removeChildren.

	anObject ifNil: [
		self memento retainChildMementosFor: #() inRelation: aDescription.
		self addRelationValueElement: anAddElement to: aHeaderContent.
		^ OrderedCollection new ].

	self memento retainChildMementosFor: { anObject } inRelation: aDescription.
	newRows := self newEmbeddedRowsFor: anObject description: aDescription.
	headerIndex := aContainer rows identityIndexOf: aHeaderRow ifAbsent: [ ^ OrderedCollection new ].
	newRows withIndexDo: [ :aRow :anIndex |
		aContainer addRow: aRow at: headerIndex + anIndex ].
	^ newRows
]

{ #category : 'private - relations' }
CFMaDetailPresentation >> addToOneListUsing: aDescription [
	| aRelationElement anAddElement |
	aRelationElement := self newRelationValueSlotWith: nil.
	anAddElement := self newToOneAddElementUsing: aDescription.

	aRelationElement withAsyncSinkDo: [ :anElementSink |
		anElementSink
			sink: AsyncPeekSink new;
			whenUpdate: [ :theElement :aSink |
				self
					updateToOneListElement: theElement
					with: aSink value currentValue
					addElement: anAddElement
					description: aDescription ].
		(self memento readObservableValueUsing: aDescription)
			observe: anElementSink ].

	self addShortcutsTo: aRelationElement.
	self addFieldElement: aRelationElement using: aDescription
]

{ #category : 'private - identity' }
CFMaDetailPresentation >> emitIdentityAffordanceUsing: aDescription [
	identityAffordanceEmitted ifTrue: [ ^ self ].
	identityAffordanceEmitted := true.

	self
		addElement: (self newRelationObjectIdentityRowFor: self memento model)
		for: aDescription
]

{ #category : 'private - relations' }
CFMaDetailPresentation >> relationObjectDisplayCommentFor: anObject [
	| aComment |
	aComment := (anObject respondsTo: #identifier)
		ifTrue: [ anObject identifier ]
		ifFalse: [ nil ].
	(aComment notNil and: [ aComment asString isNotEmpty ])
		ifTrue: [ ^ aComment asString ].
	^ nil
]

{ #category : 'private - relations' }
CFMaDetailPresentation >> relationObjectDisplayLabelFor: anObject [
	| aLabel |
	aLabel := (anObject respondsTo: #label)
		ifTrue: [ anObject label ]
		ifFalse: [ nil ].
	(aLabel notNil and: [ aLabel asString isNotEmpty ])
		ifTrue: [ ^ aLabel asString ].
	^ anObject gtDisplayText asString
]

{ #category : 'private - relations' }
CFMaDetailPresentation >> relationObjectLeadingElementFor: anObject [
	| anIconName anIcon |
	(anObject respondsTo: #iconDescription) ifFalse: [ ^ nil ].
	anIconName := anObject icon ifNil: [ anObject iconDescription default ].
	anIconName ifNil: [ ^ nil ].
	anIcon := FontAwesomeIcons defaultStyle icon: anIconName.
	^ CFIconTile new
		beMedium;
		icon: anIcon;
		yourself
]

{ #category : 'private - relations' }
CFMaDetailPresentation >> newRelationObjectIdentityRowFor: anObject [
	| aLeadingElement aLabel aComment aSupportingElement |
	aLeadingElement := self relationObjectLeadingElementFor: anObject.
	aLeadingElement ifNotNil: [ aLeadingElement beLarge ].
	aLabel := BrLabel new
		text: (self relationObjectDisplayLabelFor: anObject) asRopedText;
		aptitude: self defaultLabelAptitude;
		fitContent;
		yourself.
	aComment := self relationObjectDisplayCommentFor: anObject.
	aSupportingElement := aComment
		ifNil: [ nil ]
		ifNotNil: [ self supportingElementWithText: aComment ].

	^ self
		newRowLeading: aLeadingElement
		description: aLabel
		supporting: aSupportingElement
		content: self newRelationEmptyContentElement
		accessories: #()
]

{ #category : 'private - relations' }
CFMaDetailPresentation >> newRelationEmptyContentElement [
	^ BlElement new
		constraintsDo: [ :c |
			c horizontal exact: 0.
			c vertical exact: 0 ];
		background: Color transparent;
		border: BlBorder empty;
		yourself
]

{ #category : 'private - relations' }
CFMaDetailPresentation >> newRelationObjectPresentationFor: anObject [
	| aContainer aLeadingElement aLabel |
	aContainer := BrHorizontalPane new
		hFitContent;
		vFitContent;
		cellSpacing: 8;
		padding: BlInsets empty;
		yourself.

	aLeadingElement := self relationObjectLeadingElementFor: anObject.
	aLeadingElement ifNotNil: [ aContainer addChild: aLeadingElement ].
	aLabel := BrLabel new
		text: (self relationObjectDisplayLabelFor: anObject) asRopedText;
		aptitude: self defaultLabelAptitude;
		fitContent;
		constraintsDo: [ :c | c linear vertical alignCenter ];
		yourself.
	aContainer addChild: aLabel.
	^ aContainer
]

{ #category : 'private - relations' }
CFMaDetailPresentation >> newRelationObjectElementFor: anObject description: aDescription [
	^ self
		newRelationObjectElementFor: anObject
		remove: [ :anItemElement |
			CFMaBuilderUtility
				removeToOneMemento: self memento
				using: aDescription
				element: anItemElement ]
]

{ #category : 'private - relations' }
CFMaDetailPresentation >> newRelationObjectElementFor: anObject remove: aRemoveBlock [
	| anItemElement |
	anItemElement := BrFrame new
		hFitContent;
		vFitContent;
		constraintsDo: [ :c |
			c frame horizontal alignRight.
			c frame vertical alignCenter ];
		addChild: (self newRelationObjectPresentationFor: anObject);
		yourself.
	self
		installRelationSelectionOn: anItemElement
		for: anObject
		remove: aRemoveBlock.
	^ anItemElement
]

{ #category : 'private - relations' }
CFMaDetailPresentation >> installRelationSelectionOn: anItemElement for: anObject remove: aRemoveBlock [
	anItemElement
		focusability: BlFocusability after;
		addAptitude: CFMaActiveSelectionAptitude new;
		addAptitude: CFMaListItemAptitude new.

	anItemElement
		when: BlClickEvent
			do: [ :anEvent |
				| wasSelected |
				wasSelected := anItemElement userData
					at: #cfMaRelationSelected
					ifAbsent: [ false ].
				anEvent consumed: true.
				wasSelected
					ifTrue: [ anItemElement phlow spawnObject: anObject ]
					ifFalse: [
						anItemElement userData at: #cfMaRelationSelected put: true.
						anItemElement states addState: BlElementState selected.
						anItemElement requestFocus ] ];
		when: BlFocusOutEvent
			do: [ :anEvent |
				anItemElement userData at: #cfMaRelationSelected put: false.
				anItemElement states removeState: BlElementState selected ].

	anItemElement
		addShortcut: (BlShortcutWithAction new
			name: 'Remove selected relation item';
			combination: BlKeyCombination delete;
			overrideChildren: true;
			action: [ :anEvent :aShortcut |
				anEvent consumed: true.
				aRemoveBlock value: anItemElement ]);
		addShortcut: (BlShortcutWithAction new
			name: 'Remove selected relation item';
			combination: BlKeyCombination builder backspace build;
			overrideChildren: true;
			action: [ :anEvent :aShortcut |
				anEvent consumed: true.
				aRemoveBlock value: anItemElement ]).

	self installFormNavigationOn: anItemElement
]

{ #category : 'private - relations' }
CFMaDetailPresentation >> newToOneAddElementUsing: aDescription [
	(aDescription isReadOnly or: [ aDescription newItemStencil isNil ])
		ifTrue: [ ^ nil ].
	^ CFMaDetailToOneAddItemViewModel new
		memento: self memento;
		description: aDescription;
		stencil: aDescription newItemStencil;
		asElement
]

{ #category : 'private - relations' }
CFMaDetailPresentation >> updateToOneListElement: aRelationElement with: anObject addElement: anAddElement description: aDescription [
	aRelationElement removeChildren.
	anObject
		ifNil: [ self addRelationValueElement: anAddElement to: aRelationElement ]
		ifNotNil: [
			self
				addRelationValueElement: (self
					newRelationObjectElementFor: anObject
					description: aDescription)
				to: aRelationElement ].
	^ aRelationElement
]

{ #category : 'private - relations' }
CFMaDetailPresentation >> addToManyEmbeddedUsing: aDescription [
	| aContainer aHeaderContent aHeaderRow anAddElement itemRows |
	aContainer := self containerForDescription: aDescription.
	anAddElement := self newToManyAddElementUsing: aDescription.
	aHeaderContent := self newRelationValueSlotWith: anAddElement.
	self addFieldElement: aHeaderContent using: aDescription.
	aHeaderRow := aContainer rows last.
	itemRows := OrderedCollection new.

	aHeaderContent withAsyncSinkDo: [ :anElementSink |
		anElementSink
			sink: AsyncPeekSink new;
			whenUpdate: [ :theElement :aSink |
				itemRows := self
					updateToManyEmbeddedRows: itemRows
					in: aContainer
					after: aHeaderRow
					with: aSink value currentValue
					description: aDescription ].
		(self memento readObservableValueUsing: aDescription)
			observe: anElementSink ]
]

{ #category : 'private - relations' }
CFMaDetailPresentation >> addToManyListUsing: aDescription [
	| aContainer aHeaderContent aHeaderRow anAddElement itemRows |
	aContainer := self containerForDescription: aDescription.
	anAddElement := self newToManyAddElementUsing: aDescription.
	aHeaderContent := self newRelationValueSlotWith: anAddElement.
	self addFieldElement: aHeaderContent using: aDescription.
	aHeaderRow := aContainer rows last.
	itemRows := OrderedCollection new.

	aHeaderContent withAsyncSinkDo: [ :anElementSink |
		anElementSink
			sink: AsyncPeekSink new;
			whenUpdate: [ :theElement :aSink |
				itemRows := self
					updateToManyListRows: itemRows
					in: aContainer
					after: aHeaderRow
					with: aSink value currentValue
					description: aDescription ].
		(self memento readObservableValueUsing: aDescription)
			observe: anElementSink ]
]

{ #category : 'private - relations' }
CFMaDetailPresentation >> addRelationValueElement: anElement to: aSlot [
	anElement ifNil: [ ^ aSlot ].
	anElement constraintsDo: [ :c |
		c frame horizontal alignRight.
		c frame vertical alignCenter ].
	aSlot addChild: anElement.
	^ aSlot
]

{ #category : 'private - relations' }
CFMaDetailPresentation >> newRelationValueSlotWith: anElement [
	| aSlot |
	aSlot := BrFrame new
		hMatchParent;
		vFitContent;
		layout: BlFrameLayout new;
		yourself.
	^ self addRelationValueElement: anElement to: aSlot
]

{ #category : 'private - relations' }
CFMaDetailPresentation >> newToManyAddElementUsing: aDescription [
	((aDescription isReadOnly or: [ aDescription definitive ])
		or: [ aDescription newItemStencil isNil ])
		ifTrue: [ ^ nil ].
	^ CFMaDetailAddItemViewModel new
		memento: self memento;
		description: aDescription;
		stencil: aDescription newItemStencil;
		asElement
]

{ #category : 'private - relations' }
CFMaDetailPresentation >> newToManyRelationRowFor: anObject description: aDescription [
	| aLeadingElement aLabel aRow |
	aLeadingElement := self relationObjectLeadingElementFor: anObject.
	aLabel := BrLabel new
		text: (self relationObjectDisplayLabelFor: anObject) asRopedText;
		aptitude: self defaultLabelAptitude;
		fitContent;
		yourself.
	aRow := self
		newRowLeading: aLeadingElement
		description: aLabel
		supporting: nil
		content: self newRelationEmptyContentElement
		accessories: #().
	self
		installRelationSelectionOn: aRow
		for: anObject
		remove: [ :theItemElement |
			CFMaBuilderUtility
				removeToManyObject: anObject
				memento: self memento
				using: aDescription
				element: theItemElement ].
	^ aRow
]

{ #category : 'private - relations' }
CFMaDetailPresentation >> updateToManyListRows: oldItemRows in: aContainer after: aHeaderRow with: aCollection description: aDescription [
	| someObjects newItemRows headerIndex |
	someObjects := aCollection ifNil: [ #() ].

	oldItemRows copy do: [ :anAssociation |
		(someObjects anySatisfy: [ :anObject | anObject == anAssociation key ]) ifFalse: [
			aContainer removeRow: anAssociation value ] ].

	headerIndex := aContainer rows identityIndexOf: aHeaderRow ifAbsent: [
		^ oldItemRows ].
	newItemRows := OrderedCollection new.
	someObjects withIndexDo: [ :anObject :anItemIndex |
		| anAssociation aRow targetIndex currentIndex |
		anAssociation := oldItemRows
			detect: [ :each | each key == anObject ]
			ifNone: [ nil ].
		aRow := anAssociation
			ifNil: [ self newToManyRelationRowFor: anObject description: aDescription ]
			ifNotNil: [ anAssociation value ].
		targetIndex := headerIndex + anItemIndex.
		currentIndex := aContainer rows identityIndexOf: aRow ifAbsent: [ 0 ].
		currentIndex = 0
			ifTrue: [ aContainer addRow: aRow at: targetIndex ]
			ifFalse: [ currentIndex = targetIndex ifFalse: [
				aContainer removeRow: aRow.
				aContainer addRow: aRow at: targetIndex ] ].
		newItemRows add: anObject -> aRow ].
	^ newItemRows
]

{ #category : 'private - relations' }
CFMaDetailPresentation >> updateToManyEmbeddedRows: oldItemRows in: aContainer after: aHeaderRow with: aCollection description: aDescription [
	| someObjects newItemRows headerIndex targetIndex |
	someObjects := aCollection ifNil: [ #() ].

	oldItemRows copy do: [ :anAssociation |
		(someObjects anySatisfy: [ :anObject | anObject == anAssociation key ]) ifFalse: [
			anAssociation value do: [ :aRow | aContainer removeRow: aRow ] ] ].

	self memento retainChildMementosFor: someObjects inRelation: aDescription.
	headerIndex := aContainer rows identityIndexOf: aHeaderRow ifAbsent: [
		^ oldItemRows ].
	targetIndex := headerIndex + 1.
	newItemRows := OrderedCollection new.
	someObjects do: [ :anObject |
		| anAssociation theRows |
		anAssociation := oldItemRows
			detect: [ :each | each key == anObject ]
			ifNone: [ nil ].
		theRows := anAssociation
			ifNil: [ self newEmbeddedRowsFor: anObject description: aDescription ]
			ifNotNil: [ anAssociation value ].

		theRows do: [ :aRow |
			| currentIndex |
			currentIndex := aContainer rows identityIndexOf: aRow ifAbsent: [ 0 ].
			currentIndex = 0
				ifTrue: [ aContainer addRow: aRow at: targetIndex ]
				ifFalse: [ currentIndex = targetIndex ifFalse: [
					aContainer removeRow: aRow.
					aContainer addRow: aRow at: targetIndex ] ].
			targetIndex := targetIndex + 1 ].
		newItemRows add: anObject -> theRows ].
	^ newItemRows
]

{ #category : 'visiting-description' }
CFMaDetailPresentation >> visitNumberDescription: aDescription [
	| aRepresentation |
	aRepresentation := (self fieldConfigurationFor: aDescription) representation.
	(aRepresentation isKindOf: CFMaTextConfiguration) ifTrue: [
		^ super visitNumberDescription: aDescription ].
	(aRepresentation isKindOf: CFMaPopupConfiguration) ifTrue: [
		^ self addNumberPopupUsing: aDescription configuration: aRepresentation ].
	(aRepresentation isKindOf: CFMaSliderConfiguration) ifTrue: [
		^ self addNumberSliderUsing: aDescription ].
	^ self error: 'Unsupported number field representation'
]

{ #category : 'visiting-description' }
CFMaDetailPresentation >> visitToManyRelationDescription: aDescription [
	| aRepresentation |
	aRepresentation := (self fieldConfigurationFor: aDescription) representation.
	(aRepresentation isKindOf: CFMaListConfiguration) ifTrue: [
		^ self addToManyListUsing: aDescription ].
	(aRepresentation isKindOf: CFMaEmbeddedFormsConfiguration) ifTrue: [
		^ self addToManyEmbeddedUsing: aDescription ].
	^ self error: 'Unsupported to-many relation representation'
]

{ #category : 'visiting-description' }
CFMaDetailPresentation >> visitToOneRelationDescription: aDescription [
	| aRepresentation |
	aRepresentation := (self fieldConfigurationFor: aDescription) representation.
	(aRepresentation isKindOf: CFMaListConfiguration) ifTrue: [
		^ self addToOneListUsing: aDescription ].
	(aRepresentation isKindOf: CFMaEmbeddedFormsConfiguration) ifTrue: [
		^ self addToOneEmbeddedUsing: aDescription ].
	^ self error: 'Unsupported to-one relation representation'
]

