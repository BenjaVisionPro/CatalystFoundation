Class {
	#name : 'CFMaDetailPresentation',
	#superclass : 'CFMaPresentation',
	#instVars : [
		'groupConfigurations'
	],
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'initialization' }
CFMaDetailPresentation >> initialize [
	super initialize.
	groupConfigurations := Dictionary new
]

{ #category : 'api - building' }
CFMaDetailPresentation >> build [
	self form background: self formBackgroundPaint.
	^ super build
]

{ #category : 'private - appearance' }
CFMaDetailPresentation >> formBackgroundPaint [
	^ (BlLinearGradientPaint direction: CFInterfaceLighting lightDirection asPoint)
		from: (Color black alpha: 0.06)
		to: (Color black alpha: 0.04)
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

{ #category : 'configuration' }
CFMaDetailPresentation >> groupConfigurationAt: aGroup ifAbsent: aBlock [
	^ groupConfigurations at: aGroup ifAbsent: aBlock
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
		accessories: #().
	(self containerForDescription: aDescription) addChild: aRow
]

{ #category : 'private - composition' }
CFMaDetailPresentation >> supportingElementFor: aDescription [
	^ BrEditor new
		aptitude: BrGlamorousRegularEditorAptitude new;
		beReadOnlyWithoutSelection;
		focusability: BlFocusability none;
		text: (aDescription comment asRopedText
			foreground: (Color black alpha: 0.52);
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

{ #category : 'private - icons' }
CFMaDetailPresentation >> unadornedIconElement: anIcon configuration: anIconConfiguration [
	anIconConfiguration isSmall ifTrue: [ anIcon size: 20 @ 20 ].
	anIconConfiguration isMedium ifTrue: [ anIcon size: 28 @ 28 ].
	anIconConfiguration isLarge ifTrue: [ anIcon size: 44 @ 44 ].
	^ anIcon
]

{ #category : 'private - composition' }
CFMaDetailPresentation >> newRowLeading: aLeadingElement description: aDescriptionElement supporting: aSupportingElement content: aContentElement accessories: accessoryElements [
	| aRow |
	aRow := BlElement new
		layout: CFMaDetailRowLayout new;
		background: Color transparent;
		border: BlBorder empty;
		padding: (BlInsets top: 6 right: 8 bottom: 6 left: 8);
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
		background: (Color white alpha: 0.96);
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

{ #category : 'visiting-description' }
CFMaDetailPresentation >> visitNumberDescription: aDescription [
	| aRepresentation |
	aRepresentation := (self fieldConfigurationFor: aDescription) representation.
	(aRepresentation isKindOf: CFMaTextConfiguration) ifTrue: [
		^ super visitNumberDescription: aDescription ].
	(aRepresentation isKindOf: CFMaPopupConfiguration) ifTrue: [
		^ self addNumberPopupUsing: aDescription configuration: aRepresentation ].
	(aRepresentation isKindOf: CFMaSliderConfiguration) ifTrue: [
		^ self error: 'Slider field representation is not implemented yet' ].
	^ self error: 'Unsupported number field representation'
]
