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
		| labels iconHolder size |
		size := self previewSize.
		iconHolder := anElement childNamed: #icon.
		iconHolder
			removeChildren;
			addChild: (CFMaBuilderUtility newFontAwesomeIconForMetadata: anMetadata size: size).
		labels := anElement childNamed: #labels.
		(labels childNamed: #title) text: (anMetadata label ifNil: [ anMetadata selectorSymbol asString ]).
		(labels childNamed: #selector) text: anMetadata selectorSymbol asString.
		anElement ]
]

{ #category : 'private' }
CFMaFontAwesomeIconSelectorElement >> metadata [
	^ self description iconLibraryClass metadata
]

{ #category : 'private' }
CFMaFontAwesomeIconSelectorElement >> newControlsRow [
	| row searchLabel sizeLabel |
	row := BrHorizontalPane new
		cellSpacing: 6;
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical fitContent ];
		margin: (BlInsets bottom: 6);
		yourself.

	searchLabel := BrLabel new
		aptitude: BrLabelAptitude new;
		text: 'Search';
		fitContent;
		yourself.

	sizeLabel := BrLabel new
		aptitude: BrLabelAptitude new;
		text: 'Size';
		fitContent;
		yourself.

	row addChildren: {
		searchLabel.
		searchEditor.
		sizeLabel.
		sizeEditor }.

	^ row
]

{ #category : 'private' }
CFMaFontAwesomeIconSelectorElement >> newInfoBar [
	| row spacer rightPane |
	row := BrHorizontalPane new
		cellSpacing: 6;
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical fitContent ];
		margin: (BlInsets top: 6);
		yourself.

	infoSummaryLabel := BrLabel new
		aptitude: BrLabelAptitude new;
		fitContent;
		yourself.

	spacer := BlElement new
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical fitContent ];
		yourself.

	rightPane := BrVerticalPane new
		cellSpacing: 2;
		constraintsDo: [ :c |
			c horizontal fitContent.
			c vertical fitContent ];
		yourself.

	versionLabel := BrLabel new
		aptitude: BrLabelAptitude new;
		opacity: 0.5;
		fitContent;
		constraintsDo: [ :c | c linear horizontal alignRight ];
		yourself.

	logoContainer := BrFrame new
		fitContent;
		constraintsDo: [ :c | c linear horizontal alignRight ];
		yourself.

	rightPane addChildren: { versionLabel. logoContainer }.
	row addChildren: { infoSummaryLabel. spacer. rightPane }.
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
	^ [ ((((self description iconLibraryClass style: 'brands')
		icon: #fontAwesomeLogoFull)
		asElement)
		asScalableElement
		size: 96 @ 18)
		opacity: 0.5;
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
	self configureList
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
CFMaFontAwesomeIconSelectorElement >> previewSize [
	| text number |
	text := sizeEditor text asString trimBoth.
	text isEmpty ifTrue: [ ^ 32 @ 32 ].
	number := [ text asNumber ] on: Error do: [ 32 ].
	^ number @ number
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
