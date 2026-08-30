Class {
	#name : 'CFMaDetailPresentation',
	#superclass : 'CFMaPresentation',
	#instVars : [
		'groupConfigurations',
		'groups',
		'categoryGroups',
		'relationSelections',
		'relationFocusRows',
		'relationFocusContainers',
		'relationActiveDescriptions'
	],
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'initialization' }
CFMaDetailPresentation >> initialize [
	super initialize.
	groupConfigurations := Dictionary new.
	groups := Dictionary new.
	categoryGroups := Dictionary new.
	relationSelections := IdentityDictionary new.
	relationFocusRows := IdentityDictionary new.
	relationFocusContainers := IdentityDictionary new.
	relationActiveDescriptions := IdentitySet new
]

{ #category : 'api - building' }
CFMaDetailPresentation >> build [
	groups removeAll.
	categoryGroups removeAll.
	relationSelections removeAll.
	relationFocusRows removeAll.
	relationFocusContainers removeAll.
	relationActiveDescriptions removeAll.
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
	^ self theme surfaces baseBackground
]

{ #category : 'private - building' }
CFMaDetailPresentation >> prepareHostElement [
	self hostElement background: self formBackgroundPaint
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
CFMaDetailPresentation >> presentationGroupForDescription: aDescription [
	| aGroup aConfiguration |
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
	^ aGroup
]

{ #category : 'private - groups' }
CFMaDetailPresentation >> containerForDescription: aDescription [
	"List relations still operate on a Detail card because their items are rows."
	^ (self presentationGroupForDescription: aDescription) rows
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
	| anElement aMargin |
	anElement := CFMaDetailGroupElement new
		configuration: aConfiguration;
		yourself.
	(aParent == self hostElement and: [ aParent children isEmpty not ]) ifTrue: [
		aMargin := anElement margin.
		anElement margin: (BlInsets
			top: 10
			right: aMargin right
			bottom: aMargin bottom
			left: aMargin left) ].
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
		addAptitude: (BrLazyStyleCommonAptitude new
			default: [ :aStyle |
				aStyle background: aDropdown theme interaction controlBackgroundTint ]).
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
	(self presentationGroupForDescription: anActionDescription) addContent: aRow
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

	aButton addAptitude: (BrLazyStyleCommonAptitude new
		default: [ :aStyle |
			aStyle
				background: (self theme interaction controlBackgroundTint);
				border: BlBorder empty ];
		hovered: [ :aStyle |
			aStyle
				background: (self theme interaction hoveredBackgroundTint);
				border: BlBorder empty ];
		pressed: [ :aStyle |
			aStyle
				background: (self theme interaction pressedBackgroundTint);
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
	(self presentationGroupForDescription: aDescription) addContent: aRow
]

{ #category : 'private - accessories' }
CFMaDetailPresentation >> newAccessoriesFor: aDescription [
	| accessories information |
	accessories := OrderedCollection new.
	(aDescription isWithChangeIndicator and: [ aDescription autoAccept not ]) ifTrue: [
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
		color: (self theme typography secondaryForeground);
		size: 10 @ 10.
	^ BrButton new
		aptitude: BrGlamorousButtonIconAptitude new
			+ BrGlamorousButtonLayoutAptitude new
			+ CFMaButtonWithLabelTooltipAptitude new;
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
		foreground: (self theme typography primaryForeground);
		fontSize: (self theme typography bodyFontSize)
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
			foreground: (self theme typography tertiaryForeground);
			fontSize: (self theme typography supportingFontSize));
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


{ #category : 'elements' }
CFMaDetailPresentation >> addFieldElement: aFieldElement using: aDescription [
	self prepareEditorFocusChromeIn: aFieldElement.
	^ super addFieldElement: aFieldElement using: aDescription
]

{ #category : 'private - focus' }
CFMaDetailPresentation >> prepareEditorFocusChromeIn: aFieldElement [
	| editors |
	editors := OrderedCollection new.
	(aFieldElement isKindOf: BrEditor)
		ifTrue: [ editors add: aFieldElement ].
	aFieldElement allChildrenBreadthFirstDo: [ :aChild |
		(aChild isKindOf: BrEditor)
			ifTrue: [ editors add: aChild ] ].

	editors do: [ :anEditor |
		anEditor editor segmentBuilder splitter:
			(BrTextEditorSplitter new
				segmentClass: CFMaTextEditorParagraphSegment;
				yourself).
		(anEditor isKindOf: GtMagritteOneLineEditorElement)
			ifTrue: [ anEditor addAptitude: CFMaRowEditorAptitude new ] ].
	^ aFieldElement
]

{ #category : 'private - building' }
CFMaDetailPresentation >> addSingleOptionDropdownUsing: aDescription [
	| aRepresentation aDisplayBlock anIconBlock |
	aRepresentation := (self fieldConfigurationFor: aDescription) representation.
	(aRepresentation isKindOf: CFMaColourPickerConfiguration) ifTrue: [
		^ self
			addSingleOptionColourPickerUsing: aDescription
			configuration: aRepresentation ].
	aDisplayBlock := ((aRepresentation isKindOf: CFMaPopupConfiguration)
		and: [ aRepresentation displayBlock notNil ])
		ifTrue: [ aRepresentation displayBlock ]
		ifFalse: [ [ :aValue | aDescription displayStringFor: aValue ] ].
	anIconBlock := (aDescription hasProperty: #blocOptionIconStencil)
		ifTrue: [ aDescription blocOptionIconStencil ]
		ifFalse: [ nil ].
	self
		addPopupFieldUsing: aDescription
		values: aDescription options
		display: aDisplayBlock
		icon: anIconBlock
]

{ #category : 'private - building' }
CFMaDetailPresentation >> addSingleOptionColourPickerUsing: aDescription configuration: aConfiguration [
	| aPicker |
	aPicker := CFMaDetailColourPickerElement new
		options: aDescription options;
		colourBlock: aConfiguration colourBlock;
		labelBlock: aConfiguration labelBlock;
		value: (self memento readUsing: aDescription);
		valueChangedBlock: [ :anOption |
			GtMagritteBuilderUtility
				write: anOption
				using: aDescription
				memento: self memento
				element: aPicker ];
		yourself.
	aPicker withAsyncSinkDo: [ :anElementSink |
		anElementSink
			sink: AsyncPeekSink new;
			whenUpdate: [ :thePicker :aSink |
				thePicker value: aSink value currentValue ].
		(self memento readObservableValueUsing: aDescription) observe: anElementSink ].
	self addShortcutsTo: aPicker.
	self addFieldElement: aPicker using: aDescription
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
	^ self
		addPopupFieldUsing: aDescription
		values: someValues
		display: aDisplayBlock
		icon: nil
]

{ #category : 'private - building' }
CFMaDetailPresentation >> addPopupFieldUsing: aDescription values: someValues display: aDisplayBlock icon: anIconBlock [
	| aPopup aField |
	aPopup := self
		newPopupUsing: aDescription
		values: someValues
		display: aDisplayBlock
		icon: anIconBlock.
	aField := CFMaDetailPopupFieldElement new
		popup: aPopup;
		yourself.
	self addShortcutsTo: aField.
	self addFieldElement: aField using: aDescription
]

{ #category : 'private - building' }
CFMaDetailPresentation >> newPopupUsing: aDescription values: someValues display: aDisplayBlock [
	^ self
		newPopupUsing: aDescription
		values: someValues
		display: aDisplayBlock
		icon: nil
]

{ #category : 'private - building' }
CFMaDetailPresentation >> newPopupUsing: aDescription values: someValues display: aDisplayBlock icon: anIconBlock [
	| aPopup aDropdownAptitude |
	aPopup := self
		newPopupDisplayUsing: aDescription
		display: aDisplayBlock
		icon: anIconBlock.
	aDropdownAptitude := CFMaDetailDropdownAptitude
		handle: [
			self
				newPopupHandleUsing: aDescription
				display: aDisplayBlock
				icon: anIconBlock ]
		content: [
			self
				newPopupContent: aPopup
				using: aDescription
				values: someValues
				display: aDisplayBlock
				icon: anIconBlock ].
	aDropdownAptitude
		pinRowIndexUsing: [
			| currentValue |
			currentValue := self memento readUsing: aDescription.
			someValues indexOf: currentValue ifAbsent: [ 1 ] ];
		withGainFocusOnShow;
		withContainerAreaBuilders: {
			self popupAreaBuilderUsing: aDropdownAptitude };
		menuContainerDo: [ :aContainer |
			aContainer
				padding: BlInsets empty;
				beInSeparateCompositionLayer;
				aptitude: CFMaDetailPopupContainerAptitude new;
				effect: BlNullEffect new ].
	aPopup addAptitude: aDropdownAptitude.
	^ aPopup
]

{ #category : 'private - building' }
CFMaDetailPresentation >> popupAreaBuilderUsing: aDropdownAptitude [
	^ BlSteppedLayoutAreaBuilder new
		mark: BlSteppedLayoutMark bottomRight;
		direction: #right;
		alignTopLeft;
		bounds: [ :aState |
			| selectedOffset anchorLeft left top |
			selectedOffset := CFMaDetailPopupMetrics
				selectedRowOffsetForIndex: aDropdownAptitude pinnedRowIndex.
			anchorLeft := aDropdownAptitude
				pinnedAnchorLeftUsing: aState occupiedBounds left.
			left := (anchorLeft + CFMaDetailPopupMetrics menuHorizontalOffset)
				max: aState containerPositionXWithPadding.
			top := (aState occupiedBounds top - selectedOffset)
				max: aState containerPositionYWithPadding.
			left @ top corner: aState containerExtentWithPadding ];
		yourself
]

{ #category : 'private - building' }
CFMaDetailPresentation >> newPopupContent: aPopup using: aDescription values: someValues display: aDisplayBlock [
	^ self
		newPopupContent: aPopup
		using: aDescription
		values: someValues
		display: aDisplayBlock
		icon: nil
]

{ #category : 'private - building' }
CFMaDetailPresentation >> newPopupContent: aPopup using: aDescription values: someValues display: aDisplayBlock icon: anIconBlock [
	| aList aCurrentValue aCurrentIndex |
	((aDescription isKindOf: MAOptionDescription)
		and: [ aDescription hasProperty: #blocItemStencil ]) ifTrue: [
		^ GtMagritteBuilderUtility
			newSingleOptionDropdownContent: aPopup
			memento: self memento
			description: aDescription ].

	aCurrentValue := self memento readUsing: aDescription.
	aList := BrSimpleList new
		itemStencil: [ :anItemType :aListWidget | CFMaDetailPopupOptionElement new ];
		itemDataBinder: [ :anItemElement :anItemObject :anItemIndex |
			anItemElement
				selectionIn: aList at: anItemIndex;
				text: (aDisplayBlock cull: anItemObject);
				checked: anItemObject = aCurrentValue;
				hoverBlock: [ aList selectOne: anItemIndex ];
				activateBlock: [
					GtMagritteBuilderUtility
						write: anItemObject
						using: aDescription
						memento: self memento
						element: aPopup ].
			anIconBlock ifNotNil: [
				anItemElement leadingElement: (anIconBlock cull: anItemObject) ].
			anItemElement ];
		hFitContent;
		vFitContent;
		padding: (BlInsets all: CFMaDetailPopupMetrics menuInset);
		geometry: (BlRoundedRectangleGeometry cornerRadius: CFMaDetailPopupMetrics menuCornerRadius);
		addAptitude: CFGlassSurfaceAptitude new;
		items: someValues;
		yourself.

	aCurrentIndex := someValues indexOf: aCurrentValue ifAbsent: [ 0 ].
	aCurrentIndex > 0 ifTrue: [ aList selectOne: aCurrentIndex ].

	^ CFGlassShadowElement new
		geometry: (BlRoundedRectangleGeometry cornerRadius: CFMaDetailPopupMetrics menuCornerRadius);
		addChild: aList;
		yourself
]

{ #category : 'private - building' }
CFMaDetailPresentation >> newPopupHandleUsing: aDescription display: aDisplayBlock [
	^ self
		newPopupHandleUsing: aDescription
		display: aDisplayBlock
		icon: nil
]

{ #category : 'private - building' }
CFMaDetailPresentation >> newPopupHandleUsing: aDescription display: aDisplayBlock icon: anIconBlock [
	| aValue aHandle |
	aValue := self memento readUsing: aDescription.
	aHandle := CFMaDetailPopupElement new
		text: (aDisplayBlock cull: aValue);
		visibility: BlVisibility hidden;
		yourself.
	anIconBlock ifNotNil: [
		aHandle leadingElement: (anIconBlock cull: aValue) ].
	^ aHandle
]

{ #category : 'private - building' }
CFMaDetailPresentation >> newPopupDisplayUsing: aDescription display: aDisplayBlock [
	^ self
		newPopupDisplayUsing: aDescription
		display: aDisplayBlock
		icon: nil
]

{ #category : 'private - building' }
CFMaDetailPresentation >> newPopupDisplayUsing: aDescription display: aDisplayBlock icon: anIconBlock [
	| aPopup |
	aPopup := CFMaDetailPopupElement new.
	aPopup withAsyncSinkDo: [ :anElementSink |
		anElementSink
			sink: AsyncPeekSink new;
			whenUpdate: [ :thePopup :aSink |
				| aValue |
				aValue := aSink value currentValue.
				thePopup text: (aDisplayBlock cull: aValue).
				anIconBlock ifNotNil: [
					thePopup leadingElement: (anIconBlock cull: aValue) ] ].
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
CFMaDetailPresentation >> addToOneEmbeddedUsing: aDescription [
	| aPresentationGroup aHeaderContent aHeaderRow aHeaderContainer anAddElement aRepresentation aHost |
	aPresentationGroup := self presentationGroupForDescription: aDescription.
	aRepresentation := (self fieldConfigurationFor: aDescription) representation.
	anAddElement := self newToOneAddElementUsing: aDescription.
	aHeaderContent := self newRelationValueSlotWith: nil.
	aHeaderRow := nil.
	aHeaderContainer := nil.

	aRepresentation relationRowVisible ifTrue: [
		self addFieldElement: aHeaderContent using: aDescription.
		aHeaderContainer := self containerForDescription: aDescription.
		aHeaderRow := aHeaderContainer rows last.
		self installToOneEmbeddedInteractionOn: aHeaderRow description: aDescription ].

	aHost := self newPresentationHost.
	aHost visibility: BlVisibility gone.
	aPresentationGroup addNestedPresentationElement: aHost.

	aHost withAsyncSinkDo: [ :anElementSink |
		anElementSink
			sink: AsyncPeekSink new;
			whenUpdate: [ :theHost :aSink |
				self
					updateToOneEmbeddedHost: theHost
					with: aSink value currentValue
					addElement: anAddElement
					headerContent: (aHeaderRow ifNil: [ nil ] ifNotNil: [ aHeaderContent ])
					description: aDescription ].
		(self memento readObservableValueUsing: aDescription)
			observe: anElementSink ].

	self
		relationFocusRows: (OrderedCollection new
			addAll: (aHeaderRow ifNil: [ #() ] ifNotNil: [ { aHeaderRow } ]);
			add: aHost;
			yourself)
		in: aPresentationGroup
		for: aDescription
]

{ #category : 'private - relations' }
CFMaDetailPresentation >> updateToOneEmbeddedHost: aHost with: anObject addElement: anAddElement headerContent: aHeaderContent description: aDescription [
	| aChildMemento aRepresentation |
	aHost removeChildren.
	aHeaderContent ifNotNil: [ aHeaderContent removeChildren ].

	anObject ifNil: [
		self memento retainChildMementosFor: #() inRelation: aDescription.
		aHost visibility: BlVisibility gone.
		aHeaderContent ifNotNil: [
			self addRelationValueElement: anAddElement to: aHeaderContent ].
		^ aHost ].

	self memento retainChildMementosFor: { anObject } inRelation: aDescription.
	aChildMemento := self memento
		childMementoFor: anObject
		inRelation: aDescription.
	aRepresentation := (self fieldConfigurationFor: aDescription) representation.
	aHost visibility: BlVisibility visible.
	self
		buildPresentationForMemento: aChildMemento
		in: aHost
		configure: aRepresentation presentationConfiguration.
	^ aHost
]

{ #category : 'private - relations' }
CFMaDetailPresentation >> addToOneListUsing: aDescription [
	| aContainer aHeaderRow aRelationElement anAddElement aChevron |
	aContainer := self containerForDescription: aDescription.
	aRelationElement := self newRelationValueSlotWith: nil.
	anAddElement := self newToOneAddElementUsing: aDescription.

	self addShortcutsTo: aRelationElement.
	self addFieldElement: aRelationElement using: aDescription.
	aHeaderRow := aContainer rows last.

	aChevron := self newRelationInspectorChevron.
	aChevron
		visibility: BlVisibility gone;
		margin: BlInsets empty;
		constraintsDo: [ :c | (c at: CFMaDetailRowLayout) beTrailing ].
	aHeaderRow addChild: aChevron.

	aRelationElement withAsyncSinkDo: [ :anElementSink |
		anElementSink
			sink: AsyncPeekSink new;
			whenUpdate: [ :theElement :aSink |
				self
					updateToOneListElement: theElement
					with: aSink value currentValue
					addElement: anAddElement
					chevron: aChevron
					description: aDescription ].
		(self memento readObservableValueUsing: aDescription)
			observe: anElementSink ].

	self
		installToOneListNavigationOn: aHeaderRow
		focusElement: aRelationElement
		description: aDescription.
	self relationFocusRows: { aHeaderRow } in: aContainer for: aDescription
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
CFMaDetailPresentation >> relationObjectSupportingTextFor: anObject [
	| aSupportingText |
	aSupportingText := (anObject respondsTo: #identifier)
		ifTrue: [ anObject identifier ]
		ifFalse: [ nil ].
	(aSupportingText notNil and: [ aSupportingText asString isNotEmpty ])
		ifTrue: [ ^ aSupportingText asString ].
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
CFMaDetailPresentation >> newRelationObjectLabelFor: anObject [
	^ BrLabel new
		text: (self relationObjectDisplayLabelFor: anObject) asRopedText;
		aptitude: self defaultLabelAptitude;
		fitContent;
		yourself
]

{ #category : 'private - relations' }
CFMaDetailPresentation >> newRelationObjectSupportingElementFor: anObject [
	^ (self relationObjectSupportingTextFor: anObject)
		ifNil: [ nil ]
		ifNotNil: [ :aString | self supportingElementWithText: aString ]
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
	| aLeadingElement |
	aLeadingElement := self relationObjectLeadingElementFor: anObject.
	aLeadingElement ifNotNil: [ aLeadingElement beLarge ].

	^ self
		newRowLeading: aLeadingElement
		description: (self newRelationObjectLabelFor: anObject)
		supporting: (self newRelationObjectSupportingElementFor: anObject)
		content: self newRelationEmptyContentElement
		accessories: #()
]

{ #category : 'private - relations' }
CFMaDetailPresentation >> newRelationEmptyContentElement [
	"Relation object rows use the standard Detail field-row layout but have no value control."
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
	aLabel := self newRelationObjectLabelFor: anObject.
	aLabel constraintsDo: [ :c | c linear vertical alignCenter ].
	aContainer addChild: aLabel.
	^ aContainer
]

{ #category : 'private - relations' }
CFMaDetailPresentation >> newRelationInspectorChevron [
	| anElement |
	anElement := FontAwesomeIcons defaultStyle icon: #chevronRight.
	anElement
		color: (self theme typography secondaryForeground);
		size: 8 @ 8.
	^ anElement
]

{ #category : 'private - relations' }
CFMaDetailPresentation >> newToOneRelationObjectElementFor: anObject description: aDescription [
	^ BrFrame new
		hFitContent;
		vFitContent;
		constraintsDo: [ :c |
			c frame horizontal alignRight.
			c frame vertical alignCenter ];
		addChild: (self newRelationObjectPresentationFor: anObject);
		yourself
]

{ #category : 'private - relations' }
CFMaDetailPresentation >> newRelationObjectElementFor: anObject description: aDescription [
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
		description: aDescription
		remove: [ :theItemElement |
			CFMaBuilderUtility
				removeToOneMemento: self memento
				using: aDescription
				element: theItemElement ].
	^ anItemElement
]

{ #category : 'private - relations' }
CFMaDetailPresentation >> relationElementIsSelected: anElement for: aDescription [
	^ (relationSelections at: aDescription ifAbsent: [ nil ]) == anElement
]

{ #category : 'private - relations' }
CFMaDetailPresentation >> selectRelationElement: anElement for: aDescription [
	| aPreviousElement |
	aPreviousElement := relationSelections at: aDescription ifAbsent: [ nil ].
	aPreviousElement == anElement ifTrue: [
		anElement states addState: BlElementState selected.
		(relationActiveDescriptions includes: aDescription) ifTrue: [
			anElement states addState: CFMaActiveSelectionState uniqueInstance ].
		^ anElement ].

	aPreviousElement ifNotNil: [
		aPreviousElement states
			removeState: BlElementState selected;
			removeState: CFMaActiveSelectionState uniqueInstance ].
	relationSelections at: aDescription put: anElement.
	anElement states addState: BlElementState selected.
	(relationActiveDescriptions includes: aDescription) ifTrue: [
		anElement states addState: CFMaActiveSelectionState uniqueInstance ].
	^ anElement
]

{ #category : 'private - relations' }
CFMaDetailPresentation >> installRelationSelectionOn: anItemElement for: anObject description: aDescription remove: aRemoveBlock [
	^ self
		installRelationInteractionOn: anItemElement
		for: anObject
		description: aDescription
		remove: aRemoveBlock
		highlightSelection: true
]


{ #category : 'private - relations' }
CFMaDetailPresentation >> installRelationNavigationOn: aRow focusElement: aFocusElement object: anObjectBlock description: aDescription [
	aRow
		when: BlClickEvent
		do: [ :anEvent |
			| anObject |
			anObject := anObjectBlock value.
			anObject ifNotNil: [
				anEvent consumed: true.
				aFocusElement requestFocus.
				self selectRelationElement: aFocusElement for: aDescription.
				anEvent modifiers isAlt
					ifTrue: [
						CFMaPhlowNavigation
							navigateNewBranchFrom: aRow
							to: anObject ]
					ifFalse: [
						CFMaPhlowNavigation
							selectFrom: aRow
							object: anObject ] ] ];
		when: BlDoubleClickEvent
		do: [ :anEvent |
			| anObject |
			anObject := anObjectBlock value.
			anObject ifNotNil: [
				anEvent consumed: true.
				CFMaPhlowNavigation
					navigateFrom: aRow
					to: anObject ] ]
]

{ #category : 'private - relations' }
CFMaDetailPresentation >> installRelationInteractionOn: anItemElement for: anObject description: aDescription remove: aRemoveBlock highlightSelection: aBoolean [
	anItemElement focusability: BlFocusability after.
	aBoolean ifTrue: [ anItemElement addAptitude: CFMaListItemAptitude new ].

	anItemElement
		when: BlFocusInEvent
		do: [ :anEvent |
			self selectRelationElement: anItemElement for: aDescription ].

	self
		installRelationNavigationOn: anItemElement
		focusElement: anItemElement
		object: [ anObject ]
		description: aDescription.

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
CFMaDetailPresentation >> installToOneEmbeddedInteractionOn: aRow description: aDescription [
	aRow
		focusability: BlFocusability after;
		addAptitude: CFMaListItemAptitude new;
		when: BlFocusInEvent
		do: [ :anEvent |
			self selectRelationElement: aRow for: aDescription ].
	self
		installToOneListNavigationOn: aRow
		focusElement: aRow
		description: aDescription.
	self installFormNavigationOn: aRow
]

{ #category : 'private - relations' }
CFMaDetailPresentation >> installToOneListNavigationOn: aRow focusElement: aFocusElement description: aDescription [
	self
		installRelationNavigationOn: aRow
		focusElement: aFocusElement
		object: [ self memento readUsing: aDescription ]
		description: aDescription.

	aFocusElement
		addShortcut: (BlShortcutWithAction new
			name: 'Remove to-one relation';
			combination: BlKeyCombination delete;
			overrideChildren: true;
			action: [ :anEvent :aShortcut |
				anEvent consumed: true.
				CFMaBuilderUtility
					removeToOneMemento: self memento
					using: aDescription
					element: aFocusElement ]);
		addShortcut: (BlShortcutWithAction new
			name: 'Remove to-one relation';
			combination: BlKeyCombination builder backspace build;
			overrideChildren: true;
			action: [ :anEvent :aShortcut |
				anEvent consumed: true.
				CFMaBuilderUtility
					removeToOneMemento: self memento
					using: aDescription
					element: aFocusElement ])
]
{ #category : 'private - relations' }
CFMaDetailPresentation >> relationFocusElement: anElement isWithinRows: theRows [
	anElement ifNil: [ ^ false ].
	^ theRows anySatisfy: [ :aRow |
		anElement == aRow or: [ anElement hasParent: aRow ] ]
]

{ #category : 'private - relations' }
CFMaDetailPresentation >> setRelationActive: aBoolean for: aDescription [
	| aSelectedElement |
	aBoolean
		ifTrue: [ relationActiveDescriptions add: aDescription ]
		ifFalse: [ relationActiveDescriptions remove: aDescription ifAbsent: [ ] ].
	aSelectedElement := relationSelections at: aDescription ifAbsent: [ nil ].
	aSelectedElement ifNil: [ ^ self ].
	aBoolean
		ifTrue: [ aSelectedElement states addState: CFMaActiveSelectionState uniqueInstance ]
		ifFalse: [ aSelectedElement states removeState: CFMaActiveSelectionState uniqueInstance ]
]

{ #category : 'private - relations' }
CFMaDetailPresentation >> updateRelationActiveFor: aDescription focusedElement: anElement [
	self
		setRelationActive: (self
			relationFocusElement: anElement
			isWithinRows: (relationFocusRows at: aDescription ifAbsent: [ #() ]))
		for: aDescription
]

{ #category : 'private - relations' }
CFMaDetailPresentation >> installRelationFocusContextIn: aContainer for: aDescription [
	(relationFocusContainers at: aDescription ifAbsent: [ nil ]) == aContainer ifTrue: [ ^ self ].
	relationFocusContainers at: aDescription put: aContainer.
	aContainer
		when: BlFocusInEvent
			do: [ :anEvent |
				self updateRelationActiveFor: aDescription focusedElement: anEvent target ];
		when: BlFocusTransferEvent
			do: [ :anEvent |
				self updateRelationActiveFor: aDescription focusedElement: anEvent focusedElement ];
		when: BlFocusOutEvent
			do: [ :anEvent | self setRelationActive: false for: aDescription ]
]

{ #category : 'private - relations' }
CFMaDetailPresentation >> relationFocusRows: theRows in: aContainer for: aDescription [
	| aFocusOwner |
	relationFocusRows at: aDescription put: theRows copy.
	self installRelationFocusContextIn: aContainer for: aDescription.
	aFocusOwner := aContainer space ifNotNil: [ :aSpace | aSpace focusOwner ].
	self updateRelationActiveFor: aDescription focusedElement: aFocusOwner
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
CFMaDetailPresentation >> updateToOneListElement: aRelationElement with: anObject addElement: anAddElement chevron: aChevron description: aDescription [
	aRelationElement removeChildren.
	anObject
		ifNil: [
			aChevron visibility: BlVisibility gone.
			self addRelationValueElement: anAddElement to: aRelationElement ]
		ifNotNil: [
			aChevron visibility: BlVisibility visible.
			self
				addRelationValueElement: (self
					newToOneRelationObjectElementFor: anObject
					description: aDescription)
				to: aRelationElement ].
	^ aRelationElement
]

{ #category : 'private - relations' }
CFMaDetailPresentation >> relationContextRowsWithHeader: aHeaderRow rows: theRows [
	^ OrderedCollection new
		addAll: (aHeaderRow ifNil: [ #() ] ifNotNil: [ { aHeaderRow } ]);
		addAll: theRows;
		yourself
]

{ #category : 'private - relations' }
CFMaDetailPresentation >> addToManyEmbeddedUsing: aDescription [
	| aPresentationGroup aHeaderContent aHeaderRow anAddElement aRepresentation aRelationContainer itemHosts |
	aPresentationGroup := self presentationGroupForDescription: aDescription.
	aRepresentation := (self fieldConfigurationFor: aDescription) representation.
	anAddElement := self newToManyAddElementUsing: aDescription.
	aHeaderContent := self newRelationValueSlotWith: anAddElement.
	aHeaderRow := nil.

	aRepresentation relationRowVisible ifTrue: [
		self addFieldElement: aHeaderContent using: aDescription.
		aHeaderRow := (self containerForDescription: aDescription) rows last ].

	aRelationContainer := BrVerticalPane new
		hMatchParent;
		vFitContent;
		margin: BlInsets empty;
		cellSpacing: 10;
		visibility: BlVisibility gone;
		yourself.
	aPresentationGroup addNestedPresentationElement: aRelationContainer.
	itemHosts := OrderedCollection new.

	aRelationContainer withAsyncSinkDo: [ :anElementSink |
		anElementSink
			sink: AsyncPeekSink new;
			whenUpdate: [ :theContainer :aSink |
				itemHosts := self
					updateToManyEmbeddedItems: itemHosts
					in: theContainer
					with: aSink value currentValue
					description: aDescription ].
		(self memento readObservableValueUsing: aDescription)
			observe: anElementSink ].

	self
		relationFocusRows: (OrderedCollection new
			addAll: (aHeaderRow ifNil: [ #() ] ifNotNil: [ { aHeaderRow } ]);
			add: aRelationContainer;
			yourself)
		in: aPresentationGroup
		for: aDescription
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
					description: aDescription.
				self
					relationFocusRows: (self
						relationContextRowsWithHeader: aHeaderRow
						rows: (itemRows collect: #value))
					in: aContainer
					for: aDescription ].
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
	aLabel := self newRelationObjectLabelFor: anObject.
	aRow := self
		newRowLeading: aLeadingElement
		description: aLabel
		supporting: nil
		content: self newRelationEmptyContentElement
		accessories: #()
		trailing: self newRelationInspectorChevron.
	self
		installRelationSelectionOn: aRow
		for: anObject
		description: aDescription
		remove: [ :theItemElement |
			CFMaBuilderUtility
				removeToManyObject: anObject
				memento: self memento
				using: aDescription
				element: theItemElement ].
	^ aRow
]

{ #category : 'private - relations' }
CFMaDetailPresentation >> relationRowAssociationFor: anObject in: itemRows [
	^ itemRows
		detect: [ :each | each key == anObject ]
		ifNone: [ nil ]
]

{ #category : 'private - relations' }
CFMaDetailPresentation >> placeRelationRows: theRows in: aContainer startingAt: aTargetIndex [
	| targetIndex |
	targetIndex := aTargetIndex.
	theRows do: [ :aRow |
		| currentIndex |
		currentIndex := aContainer rows identityIndexOf: aRow ifAbsent: [ 0 ].
		currentIndex = 0
			ifTrue: [ aContainer addRow: aRow at: targetIndex ]
			ifFalse: [ currentIndex = targetIndex ifFalse: [
				aContainer removeRow: aRow.
				aContainer addRow: aRow at: targetIndex ] ].
		targetIndex := targetIndex + 1 ].
	^ targetIndex
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
		| anAssociation aRow targetIndex |
		anAssociation := self relationRowAssociationFor: anObject in: oldItemRows.
		aRow := anAssociation
			ifNil: [ self newToManyRelationRowFor: anObject description: aDescription ]
			ifNotNil: [ anAssociation value ].
		targetIndex := headerIndex + anItemIndex.
		self placeRelationRows: { aRow } in: aContainer startingAt: targetIndex.
		newItemRows add: anObject -> aRow ].
	^ newItemRows
]

{ #category : 'private - relations' }
CFMaDetailPresentation >> newEmbeddedRelationItemFor: anObject host: aPresentationHost description: aDescription [
	| anItem |
	anItem := BrVerticalPane new
		hMatchParent;
		vFitContent;
		margin: BlInsets empty;
		addChild: aPresentationHost;
		yourself.
	self
		installRelationSelectionOn: anItem
		for: anObject
		description: aDescription
		remove: [ :anItemElement |
			CFMaBuilderUtility
				removeToManyObject: anObject
				memento: self memento
				using: aDescription
				element: anItemElement ].
	^ anItem
]

{ #category : 'private - relations' }
CFMaDetailPresentation >> updateToManyEmbeddedItems: oldItemElements in: aContainer with: aCollection description: aDescription [
	| someObjects newItemElements aRepresentation |
	someObjects := aCollection ifNil: [ #() ].
	aRepresentation := (self fieldConfigurationFor: aDescription) representation.

	oldItemElements copy do: [ :anAssociation |
		(someObjects anySatisfy: [ :anObject | anObject == anAssociation key ]) ifFalse: [
			anAssociation value hasParent ifTrue: [
				aContainer removeChild: anAssociation value ] ] ].

	self memento retainChildMementosFor: someObjects inRelation: aDescription.
	newItemElements := OrderedCollection new.
	someObjects do: [ :anObject |
		| anAssociation anItemElement aChildMemento |
		anAssociation := oldItemElements
			detect: [ :each | each key == anObject ]
			ifNone: [ nil ].
		anItemElement := anAssociation
			ifNil: [
				| aPresentationHost |
				aPresentationHost := self newPresentationHost.
				aChildMemento := self memento
					childMementoFor: anObject
					inRelation: aDescription.
				self
					buildPresentationForMemento: aChildMemento
					in: aPresentationHost
					configure: aRepresentation presentationConfiguration.
				aRepresentation relationRowVisible
					ifTrue: [ self
						newEmbeddedRelationItemFor: anObject
						host: aPresentationHost
						description: aDescription ]
					ifFalse: [ aPresentationHost ] ]
			ifNotNil: [ anAssociation value ].
		newItemElements add: anObject -> anItemElement ].

	newItemElements withIndexDo: [ :anAssociation :anIndex |
		| anItemElement currentIndex |
		anItemElement := anAssociation value.
		currentIndex := aContainer children asArray identityIndexOf: anItemElement ifAbsent: [ 0 ].
		currentIndex = 0
			ifTrue: [ aContainer addChild: anItemElement at: anIndex ]
			ifFalse: [ currentIndex = anIndex ifFalse: [
				aContainer removeChild: anItemElement.
				aContainer addChild: anItemElement at: anIndex ] ] ].
	aContainer visibility: (newItemElements
		ifEmpty: [ BlVisibility gone ]
		ifNotEmpty: [ BlVisibility visible ]).
	^ newItemElements
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
CFMaDetailPresentation >> visitToManyScalarRelationDescription: aDescription [
	| aTagsElement |
	aTagsElement := CFMaDetailTagsElement new
		description: aDescription memento: self memento;
		yourself.
	self
		installFormNavigationOn: aTagsElement
		forwardCombination: BlKeyCombination tab.
	self addFieldElement: aTagsElement using: aDescription.
	^ aTagsElement
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

