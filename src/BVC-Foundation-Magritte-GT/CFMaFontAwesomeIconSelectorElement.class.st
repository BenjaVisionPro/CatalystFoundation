Class {
	#name : 'CFMaFontAwesomeIconSelectorElement',
	#superclass : 'BrSimpleList',
	#traits : 'TGtMagritteWithFieldViewModel',
	#classTraits : 'TGtMagritteWithFieldViewModel classTrait',
	#instVars : [
		'dropdownAnchor'
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
			addChild: (BlElement new size: self description iconSize) as: #icon;
			addChild: (BrLabel new
					aptitude: BrLabelAptitude new;
					constraintsDo: [ :c | c linear vertical alignCenter ];
					padding: (BlInsets left: 10 right: 3)) as: #label ]
]

{ #category : 'private' }
CFMaFontAwesomeIconSelectorElement >> configureList [
	self
		itemStencil: self buildItemStencil;
		itemDataBinder: self itemDataBinderBlock;
		items: self description availableIconAssociations
]

{ #category : 'accessing' }
CFMaFontAwesomeIconSelectorElement >> dropdownAnchor [
	^ dropdownAnchor
]

{ #category : 'accessing' }
CFMaFontAwesomeIconSelectorElement >> dropdownAnchor: anElement [
	dropdownAnchor := anElement
]

{ #category : 'actions' }
CFMaFontAwesomeIconSelectorElement >> hideDropdown [
	dropdownAnchor ifNotNil: [ dropdownAnchor fireEvent: BrDropdownHideWish new ]
]

{ #category : 'initialization' }
CFMaFontAwesomeIconSelectorElement >> initialize [
	super initialize.
	self
		hFitContent;
		vFitContent;
		padding: (BlInsets all: 4).
	self when: BrSelectionChanged do: [ :anEvent | self onSelectionChanged: anEvent ]
]

{ #category : 'private' }
CFMaFontAwesomeIconSelectorElement >> itemDataBinderBlock [
	^ [ :anElement :anAssociation :anIndex |
		anElement
			replaceChild: (anElement childNamed: #icon)
			with: (CFMaBuilderUtility newFontAwesomeIconFor: anAssociation key using: self description)
			as: #icon.
		(anElement childNamed: #label) text: anAssociation key asString.
		anElement ]
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
		| selectedAssociation |
		selectedAssociation := aWidgetElement viewModel itemAt: anInterval first.
		GtMagritteBuilderUtility
			write: selectedAssociation key
			using: self description
			memento: self memento
			element: self.
		self hideDropdown ]
]
