Class {
	#name : 'CFMaFontAwesomeIconSelectorElement',
	#superclass : 'BlElement',
	#traits : 'TGtMagritteWithFieldViewModel',
	#classTraits : 'TGtMagritteWithFieldViewModel classTrait',
	#instVars : [
		'dropdownAnchor',
		'searchEditor',
		'sizeEditor',
		'list',
		'searchIconContainer',
		'sizeIconContainer',
		'infoSummaryLabel',
		'versionLabel',
		'logoContainer'
	],
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'private' }
CFMaFontAwesomeIconSelectorElement >> availableMetadata [
	^ self metadata allIconMetadata
		select: [ :each | each supportsStyleNamed: self description styleName ]
]

{ #category : 'private' }
CFMaFontAwesomeIconSelectorElement >> buildItemStencil [
	^ [ :anMetadata :anIndex :aList |
		self newIconTileFor: anMetadata ]
]

{ #category : 'private' }
CFMaFontAwesomeIconSelectorElement >> configureList [
	self configureGridColumns.
	list
		stencil: self buildItemStencil.
	self refreshInfoBar.
	self refreshList
]

{ #category : 'private' }
CFMaFontAwesomeIconSelectorElement >> configureGridColumns [
	list aptitudeDo: [ :anAptitude |
		anAptitude columnCount: self gridColumnCount.
		anAptitude listElement layoutDo: [ :aLayout |
			aLayout cellSpacing: self gridCellSpacing ] ]
]

{ #category : 'accessing' }
CFMaFontAwesomeIconSelectorElement >> dropdownAnchor [
	^ dropdownAnchor
]

{ #category : 'accessing' }
CFMaFontAwesomeIconSelectorElement >> dropdownAnchor: anElement [
	dropdownAnchor := anElement
]

{ #category : 'private' }
CFMaFontAwesomeIconSelectorElement >> filteredMetadata [
	| searchText |
	searchText := self searchText.
	searchText isEmpty ifTrue: [ ^ self availableMetadata ].
	^ (self metadata searchIconsMatching: searchText)
		select: [ :each | each supportsStyleNamed: self description styleName ]
]

{ #category : 'private' }
CFMaFontAwesomeIconSelectorElement >> focusSearchEditor [
	searchEditor ifNotNil: [
		searchEditor inUIProcessDo: [ searchEditor requestFocus ] ]
]

{ #category : 'actions' }
CFMaFontAwesomeIconSelectorElement >> hideDropdown [
	dropdownAnchor ifNotNil: [ dropdownAnchor fireEvent: BrDropdownHideWish new ]
]

{ #category : 'private' }
CFMaFontAwesomeIconSelectorElement >> gridColumnCount [
	| availableWidth tileFootprint spacing |
	availableWidth := list width > 0
		ifTrue: [ list width ]
		ifFalse: [ self width > 0
			ifTrue: [ self width ]
			ifFalse: [ 600 ] ].
	spacing := self gridCellSpacing.
	tileFootprint := self tileExtentForPreviewHeight: self previewHeight.
	^ (((availableWidth + spacing) / (tileFootprint + spacing)) floor max: 1)
]

{ #category : 'private' }
CFMaFontAwesomeIconSelectorElement >> gridCellSpacing [
	^ 8
]

{ #category : 'initialization' }
CFMaFontAwesomeIconSelectorElement >> initialize [
	super initialize.
	self
		layout: BlLinearLayout vertical;
		padding: (BlInsets all: 4);
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical matchParent ].

	searchEditor := self newSearchEditor.
	sizeEditor := self newSizeEditor.
	list := self newList.
	list when: BlElementExtentChangedEvent do: [ :anEvent | self configureGridColumns ].
	self when: BlElementExtentChangedEvent do: [ :anEvent | self configureGridColumns ].

	self addChildren: { self newControlsRow. list. self newInfoBar }
]

{ #category : 'private' }
CFMaFontAwesomeIconSelectorElement >> metadata [
	self fieldViewModel ifNil: [ ^ CFFontAwesomeMetadata new ].
	^ self description iconLibraryClass metadata
]

{ #category : 'private' }
CFMaFontAwesomeIconSelectorElement >> newControlsRow [
	| row |
	row := BrHorizontalPane new
		cellSpacing: 6;
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical fitContent ];
		margin: (BlInsets bottom: 6);
		yourself.

	searchIconContainer := self newControlIconContainer.
	sizeIconContainer := self newControlIconContainer.

	row addChildren: {
		searchIconContainer.
		searchEditor.
		sizeIconContainer.
		sizeEditor }.

	^ row
]

{ #category : 'private' }
CFMaFontAwesomeIconSelectorElement >> newControlIconContainer [
	^ BrFrame new
		fitContent;
		constraintsDo: [ :c | c linear vertical alignCenter ];
		yourself
]

{ #category : 'private' }
CFMaFontAwesomeIconSelectorElement >> newControlIconNamed: aSelectorSymbol [
	^ [ | icon |
		icon := (self description iconLibraryClass style: 'solid')
			icon: aSelectorSymbol.
		(icon asScalableElementSized: (icon extentForHeight: 14))
			constraintsDo: [ :c | c linear vertical alignCenter ] ]
		on: Error
		do: [ BrLabel new
				aptitude: BrLabelAptitude new;
				text: '';
				fitContent;
				yourself ]
]

{ #category : 'private' }
CFMaFontAwesomeIconSelectorElement >> newInfoBar [
	| row spacer leftPane |
	row := BrHorizontalPane new
			cellSpacing: 2;
			constraintsDo: [ :c | 
				c horizontal matchParent.
				c vertical fitContent ];
			margin: (BlInsets top: 2);
			yourself.

	infoSummaryLabel := BrLabel new
			aptitude: BrLabelAptitude new;
			fitContent;
			yourself.

	versionLabel := BrLabel new
			aptitude: (BrLabelAptitude new
					fontSize: 9.0;
					yourself);
			opacity: 0.5;
			fitContent;
			yourself.

	logoContainer := BrFrame new
			height: 30;
			width: 200;
			constraintsDo: [ :c | c linear horizontal alignRight ];
			yourself.

	spacer := BlElement new
			constraintsDo: [ :c | 
				c horizontal matchParent.
				c vertical fitContent ];
			yourself.

	leftPane := BrVerticalPane new
			cellSpacing: 0;
			constraintsDo: [ :c | 
				c horizontal fitContent.
				c vertical fitContent ];
			yourself.

	leftPane
		addChildren: {infoSummaryLabel.
				versionLabel}.

	row
		addChildren: {leftPane.
				spacer.
				logoContainer}.

	^ row
]

{ #category : 'private' }
CFMaFontAwesomeIconSelectorElement >> newIconTileFor: anMetadata [
	| iconElement previewHeight tile tileExtent |
	previewHeight := self previewHeight.
	tileExtent := self tileExtentForPreviewHeight: previewHeight.
	iconElement := CFMaBuilderUtility
		newFontAwesomeIconForMetadata: anMetadata
		styleName: self description styleName
		fitInto: previewHeight @ previewHeight.
	iconElement constraintsDo: [ :c |
		c frame horizontal alignCenter.
		c frame vertical alignCenter ].

	tile := BlElement new
		layout: BlFrameLayout new;
		padding: (BlInsets all: 8);
		constraintsDo: [ :c |
			c horizontal exact: tileExtent.
			c vertical exact: tileExtent ];
		yourself.
	tile addChild: iconElement.
	tile when: BlClickEvent do: [ :anEvent | self selectMetadata: anMetadata ].
	^ tile
]

{ #category : 'private' }
CFMaFontAwesomeIconSelectorElement >> newList [
	| aList |
	aList := BrGridList new
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical matchParent.
			c linear weight: 1 ];
		yourself.
	^ aList
]

{ #category : 'private' }
CFMaFontAwesomeIconSelectorElement >> newLogoElement [
	^ [ | icon |
		icon := (self description iconLibraryClass style: 'brands')
			icon: #fontAwesomeLogoFull.
		icon color: Color black.
		(icon asScalableElementSized: (icon extentFittingInto: 200 @ 30))
			opacity: 0.8;
			yourself ]
		on: Error
		do: [ BrLabel new
				aptitude: BrLabelAptitude new;
				text: self metadata familyName;
				opacity: 0.5;
				fitContent;
				yourself ]
]

{ #category : 'private' }
CFMaFontAwesomeIconSelectorElement >> newSearchEditor [
	| editor |
	editor := BrEditor new
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical fitContent ];
		yourself.
	editor aptitude: BrEditorAptitude new.
	editor when: BlKeyUpEvent do: [ :evt | self refreshGrid ].
	^ editor
]

{ #category : 'private' }
CFMaFontAwesomeIconSelectorElement >> newSizeEditor [
	| editor |
	editor := BrEditor new
		constraintsDo: [ :c |
			c horizontal exact: 50.
			c vertical fitContent ];
		yourself.
	editor aptitude: BrEditorAptitude new.
	editor text: '32'.
	editor when: BlKeyUpEvent do: [ :evt | self refreshGrid ].
	^ editor
]

{ #category : 'api - field view model' }
CFMaFontAwesomeIconSelectorElement >> onFieldViewModelChanged [
	self inUIProcessDo: [ self refreshContent ]
]

{ #category : 'private' }
CFMaFontAwesomeIconSelectorElement >> previewHeight [
	| text number |
	text := sizeEditor text asString trimBoth.
	text isEmpty ifTrue: [ ^ 32 ].
	number := [ text asNumber ] on: Error do: [ 32 ].
	^ number
]

{ #category : 'private' }
CFMaFontAwesomeIconSelectorElement >> refreshContent [
	self refreshControlIcons.
	self configureList.
	self focusSearchEditor
]

{ #category : 'private' }
CFMaFontAwesomeIconSelectorElement >> refreshControlIcons [
	searchIconContainer
		removeChildren;
		addChild: (self newControlIconNamed: #search).
	sizeIconContainer
		removeChildren;
		addChild: (self newControlIconNamed: #expandAlt)
]

{ #category : 'private' }
CFMaFontAwesomeIconSelectorElement >> refreshInfoBar [
	| metadata availableCount |
	metadata := self metadata.
	availableCount := self availableMetadata size.
	infoSummaryLabel ifNotNil: [
		infoSummaryLabel text: availableCount asString, ' icons  ', metadata styles size asString, ' styles' ].
	versionLabel ifNotNil: [
		versionLabel text: 'v', metadata version ].
	logoContainer ifNotNil: [
		logoContainer
			removeChildren;
			addChild: self newLogoElement ]
]

{ #category : 'private' }
CFMaFontAwesomeIconSelectorElement >> refreshGrid [
	self configureGridColumns.
	self refreshList
]

{ #category : 'private' }
CFMaFontAwesomeIconSelectorElement >> refreshList [
	list items: self filteredMetadata
]

{ #category : 'private' }
CFMaFontAwesomeIconSelectorElement >> searchText [
	^ searchEditor text asString trimBoth
]

{ #category : 'private' }
CFMaFontAwesomeIconSelectorElement >> selectMetadata: selectedMetadata [
	GtMagritteBuilderUtility
		write: selectedMetadata selectorSymbol
		using: self description
		memento: self memento
		element: self.
	self hideDropdown
]

{ #category : 'private' }
CFMaFontAwesomeIconSelectorElement >> tileExtentForPreviewHeight: aNumber [
	^ (aNumber + 16) max: 44
]
