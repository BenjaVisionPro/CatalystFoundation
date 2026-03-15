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
CFMaFontAwesomeIconSelectorElement >> buildItemStencil [
	^ [ BlElement new
			layout: BlLinearLayout horizontal;
			padding: (BlInsets all: 6);
			margin: (BlInsets all: 2);
			constraintsDo: [ :c |
				c horizontal matchParent.
				c vertical fitContent ];
			addChild: (BrFrame new fitContent) as: #icon;
			addChild: (BlElement new
				layout: BlLinearLayout vertical;
				constraintsDo: [ :c |
					c horizontal matchParent.
					c vertical fitContent ];
				addChild: (BrLabel new
					aptitude: BrLabelAptitude new;
					padding: (BlInsets left: 10 right: 3)) as: #title;
				addChild: (BrLabel new
					aptitude: BrLabelAptitude new;
					padding: (BlInsets left: 10 right: 3)) as: #selector) as: #labels ]
]

{ #category : 'private' }
CFMaFontAwesomeIconSelectorElement >> configureList [
	list
		itemStencil: self buildItemStencil;
		itemDataBinder: self itemDataBinderBlock.
	self refreshInfoBar.
	self refreshList
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
	^ self metadata searchIconsMatching: self searchText
]

{ #category : 'actions' }
CFMaFontAwesomeIconSelectorElement >> hideDropdown [
	dropdownAnchor ifNotNil: [ dropdownAnchor fireEvent: BrDropdownHideWish new ]
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

	self addChildren: { self newControlsRow. list. self newInfoBar }
]

{ #category : 'private' }
CFMaFontAwesomeIconSelectorElement >> itemDataBinderBlock [
	^ [ :anElement :anMetadata :anIndex |
		| labels iconHolder previewHeight |
		previewHeight := self previewHeight.
		iconHolder := anElement childNamed: #icon.
		iconHolder
			removeChildren;
			addChild: (CFMaBuilderUtility newFontAwesomeIconForMetadata: anMetadata height: previewHeight).
		labels := anElement childNamed: #labels.
		(labels childNamed: #title) text: (anMetadata label ifNil: [ anMetadata selectorSymbol asString ]).
		(labels childNamed: #selector) text: anMetadata selectorSymbol asString.
		anElement ]
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
		icon := (((self description iconLibraryClass style: 'solid')
			icon: aSelectorSymbol) asElement).
		icon
			height: 14;
			constraintsDo: [ :c | c linear vertical alignCenter ].
		icon ]
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
CFMaFontAwesomeIconSelectorElement >> newList [
	| aList |
	aList := BrSimpleList new
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical matchParent ];
		yourself.
	aList when: BrSelectionChanged do: [ :anEvent | self onSelectionChanged: anEvent ].
	^ aList
]

{ #category : 'private' }
CFMaFontAwesomeIconSelectorElement >> newLogoElement [
	^ [ | icon |
		icon := ((self description iconLibraryClass style: 'brands')
			icon: #fontAwesomeLogoFull) asElement.
		icon fitInto: 200 @ 30.
		icon opacity: 0.8.
		icon ]
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
	editor when: BlKeyUpEvent do: [ :evt | self refreshList ].
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
	editor when: BlKeyUpEvent do: [ :evt | self refreshList ].
	^ editor
]

{ #category : 'api - field view model' }
CFMaFontAwesomeIconSelectorElement >> onFieldViewModelChanged [
	self inUIProcessDo: [ self refreshContent ]
]

{ #category : 'events' }
CFMaFontAwesomeIconSelectorElement >> onSelectionChanged: anEvent [
	| aWidgetElement |
	aWidgetElement := anEvent currentTarget.
	anEvent selectedDo: [ :anInterval |
		| selectedMetadata |
		selectedMetadata := aWidgetElement viewModel itemAt: anInterval first.
		GtMagritteBuilderUtility
			write: selectedMetadata selectorSymbol
			using: self description
			memento: self memento
			element: self.
		self hideDropdown ]
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
	self configureList
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
	| metadata |
	metadata := self metadata.
	infoSummaryLabel ifNotNil: [
		infoSummaryLabel text: metadata allIconMetadata size asString, ' icons  ', metadata styles size asString, ' styles' ].
	versionLabel ifNotNil: [
		versionLabel text: 'v', metadata version ].
	logoContainer ifNotNil: [
		logoContainer
			removeChildren;
			addChild: self newLogoElement ]
]

{ #category : 'private' }
CFMaFontAwesomeIconSelectorElement >> refreshList [
	list items: self filteredMetadata
]

{ #category : 'private' }
CFMaFontAwesomeIconSelectorElement >> searchText [
	^ searchEditor text asString trimBoth
]
