Class {
	#name : 'CFMaDetailAddPopupElement',
	#superclass : 'CFMaDetailPopupElement',
	#traits : 'TBrEnableable',
	#instVars : [
		'activeBackgroundColor'
	],
	#classTraits : 'TBrEnableable classTrait',
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}



{ #category : 'instance creation' }
CFMaDetailAddPopupElement class >> classChoiceFor: anAddItemViewModel [
	| anAddElement aDropdownAptitude |
	anAddElement := self new.
	aDropdownAptitude := BrGlamorousWithExplicitDropdownAptitude
		handle: [ self new
			popupBackgroundColor: CFMaDetailPopupMetrics menuBackgroundColor;
			popupOpen: true;
			yourself ]
		content: [ self classChoiceContentFor: anAddItemViewModel ].
	aDropdownAptitude
		withGainFocusOnShow;
		menuContainerDo: [ :aContainer |
			aContainer
				padding: BlInsets empty;
				geometry: (BlChildrenWrappingGeometry
					cornerRadius: CFMaDetailPopupMetrics menuCornerRadius
					enlargedBy: 0.5);
				background: CFMaDetailPopupMetrics menuBackgroundColor;
				border: (BlBorder paint: (Color black alpha: 0.18) width: 0.5);
				aptitude: BrShadowAptitude new ].
	anAddElement addAptitude: aDropdownAptitude.
	^ anAddElement
]

{ #category : 'private - instance creation' }
CFMaDetailAddPopupElement class >> classChoiceContentFor: anAddItemViewModel [
	^ BrSimpleList new
		itemStencil: [ :anItemType :aListWidget | CFMaDetailPopupOptionElement new ];
		itemDataBinder: [ :anItemElement :aClass :anItemIndex |
			anItemElement
				text: aClass displayString;
				activateBlock: [
					(anAddItemViewModel shouldDisableNewItemClass: aClass) ifFalse: [
						anAddItemViewModel addItemForClass: aClass from: anItemElement.
						anItemElement fireEvent: BrDropdownHideWish new ] ] ];
		hFitContent;
		vFitContent;
		padding: (BlInsets all: CFMaDetailPopupMetrics menuInset);
		background: Color transparent;
		border: BlBorder empty;
		items: anAddItemViewModel newItemClasses;
		yourself
]

{ #category : 'instance creation' }
CFMaDetailAddPopupElement class >> immediateFor: anAddItemViewModel [
	^ self new
		when: BlClickEvent do: [ :anEvent |
			anAddItemViewModel onClick: anEvent currentTarget ];
		yourself
]

{ #category : 'initialization' }
CFMaDetailAddPopupElement >> initialize [
	| anInset |
	super initialize.
	activeBackgroundColor := nil.
	self removeChild: valueLabel.
	anInset := (CFMaDetailPopupMetrics controlHeight
		- CFMaDetailPopupMetrics indicatorExtent y) / 2.
	self
		padding: (BlInsets all: anInset);
		geometry: BlCircleGeometry new
]


{ #category : 'private - appearance' }
CFMaDetailAddPopupElement >> popupBackgroundColor [
	^ activeBackgroundColor ifNil: [ super popupBackgroundColor ]
]

{ #category : 'private - appearance' }
CFMaDetailAddPopupElement >> popupBackgroundColor: aColor [
	activeBackgroundColor := aColor.
	self updatePopupAppearance
]

{ #category : 'private - instance creation' }
CFMaDetailAddPopupElement >> newIndicator [
	^ (FontAwesomeIcons icon: #circlePlus)
		size: CFMaDetailPopupMetrics indicatorGlyphExtent;
		color: (Color black alpha: 0.72);
		yourself
]


{ #category : 'private - appearance' }
CFMaDetailAddPopupElement >> updatePopupAppearance [
	popupOpen ifTrue: [
		self background: BlBackground transparent.
		indicatorHost background: BlBackground transparent.
		^ self ].
	super updatePopupAppearance
]

{ #category : 'layout' }
CFMaDetailAddPopupElement >> supportsBaseline [
	^ false
]
