Class {
	#name : 'CFMaDetailAddPopupElement',
	#superclass : 'CFMaDetailPopupElement',
	#traits : 'TBrEnableable',
	#classTraits : 'TBrEnableable classTrait',
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}



{ #category : 'instance creation' }
CFMaDetailAddPopupElement class >> classChoiceFor: anAddItemViewModel [
	| anAddElement aDropdownAptitude |
	anAddElement := self new.
	aDropdownAptitude := CFMaDetailDropdownAptitude
		handle: [ self newClassChoiceHandle ]
		content: [ self classChoiceContentFor: anAddItemViewModel ].
	aDropdownAptitude
		withGainFocusOnShow;
		menuContainerDo: [ :aContainer |
			aContainer
				padding: BlInsets empty;
				geometry: (BlChildrenWrappingGeometry
					cornerRadius: CFMaDetailPopupMetrics menuCornerRadius
					enlargedBy: 1.5);
				outskirts: BlOutskirts inside;
				addAptitude: CFGlassSurfaceAptitude new;
				addAptitude: BrShadowAptitude new ].
	anAddElement addAptitude: aDropdownAptitude.
	^ anAddElement
]


{ #category : 'private - instance creation' }
CFMaDetailAddPopupElement class >> newClassChoiceHandle [
	| aHandle anIndicator |
	aHandle := BlElement new
		size: CFMaDetailPopupMetrics controlHeight asPoint;
		geometry: BlCircleGeometry new;
		background: BlBackground transparent;
		border: BlBorder empty;
		yourself.
	anIndicator := (FontAwesomeIcons icon: #plus)
		size: CFMaDetailPopupMetrics indicatorGlyphExtent;
		color: (Color black alpha: 0.72);
		yourself.
	anIndicator constraintsDo: [ :c |
		c frame horizontal alignCenter.
		c frame vertical alignCenter ].
	aHandle
		layout: BlFrameLayout new;
		addChild: anIndicator.
	^ aHandle
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
	self removeChild: valueLabel.
	anInset := (CFMaDetailPopupMetrics controlHeight
		- CFMaDetailPopupMetrics indicatorExtent y) / 2.
	self
		padding: (BlInsets all: anInset);
		geometry: BlCircleGeometry new
]


{ #category : 'private - instance creation' }
CFMaDetailAddPopupElement >> newIndicator [
	^ (FontAwesomeIcons icon: #plus)
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
