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
				beInSeparateCompositionLayer;
				aptitude: CFMaDetailPopupContainerAptitude new;
				effect: BlNullEffect new ].
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
		yourself.
	aHandle
		layout: BlFrameLayout new;
		addChild: anIndicator;
		addAptitude: (BrLazyStyleCommonAptitude new
			@ anIndicator;
			default: [ :aStyle |
				aStyle do: [ anIndicator color: aHandle theme controls controlIndicatorForeground ] ]).
	anIndicator constraintsDo: [ :c |
		c frame horizontal alignCenter.
		c frame vertical alignCenter ].
	^ aHandle
]

{ #category : 'private - instance creation' }
CFMaDetailAddPopupElement class >> classChoiceContentFor: anAddItemViewModel [
	| aList |
	aList := BrSimpleList new
		itemStencil: [ :anItemType :aListWidget | CFMaDetailPopupOptionElement new ];
		itemDataBinder: [ :anItemElement :aClass :anItemIndex |
			anItemElement
				selectionIn: aList at: anItemIndex;
				text: aClass displayString;
				canActivateBlock: [ (anAddItemViewModel shouldDisableNewItemClass: aClass) not ];
				activateBlock: [ anAddItemViewModel addItemForClass: aClass from: anItemElement ] ];
		hFitContent;
		vFitContent;
		padding: (BlInsets all: CFMaDetailPopupMetrics menuInset);
		geometry: (BlRoundedRectangleGeometry cornerRadius: CFMaDetailPopupMetrics menuCornerRadius);
		addAptitude: CFGlassSurfaceAptitude new;
		addAptitude: (BrLazyStyleCommonAptitude new
			default: [ :aStyle |
				aStyle border: (BlBorder
					paint: (aList theme menu borderColor blocResolveColorForTheme: aList theme)
					width: 1) ]);
		items: anAddItemViewModel newItemClasses;
		yourself.
	^ BlElement new
		layout: BlFrameLayout new;
		constraintsDo: [ :c |
			c horizontal fitContent.
			c vertical fitContent ];
		geometry: (BlRoundedRectangleGeometry cornerRadius: CFMaDetailPopupMetrics menuCornerRadius);
		background: Color transparent;
		border: BlBorder empty;
		addAptitude: CFMenuShadowAptitude new;
		addChild: aList;
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
	self
		when: BlMouseEnterEvent do: [ :anEvent | indicator hovered: true ];
		when: BlMouseLeaveEvent do: [ :anEvent | indicator hovered: false ].
	anInset := (CFMaDetailPopupMetrics controlHeight
		- CFMaDetailPopupMetrics indicatorExtent y) / 2.
	self
		padding: (BlInsets all: anInset);
		geometry: BlCircleGeometry new;
		background: BlBackground transparent.
	indicatorHost background: BlBackground transparent
]

{ #category : 'private - styling' }
CFMaDetailAddPopupElement >> installThemeStyles [
	"The add control is intentionally transparent; its icon owns the only visual state."
	popupStyleAptitude := BrLazyStyleCommonAptitude new
		default: [ :aStyle | aStyle background: BlBackground transparent ].
	indicatorHostStyleAptitude := BrLazyStyleCommonAptitude new
		@ indicatorHost;
		default: [ :aStyle | aStyle background: BlBackground transparent ].
	self
		addAptitude: popupStyleAptitude;
		addAptitude: indicatorHostStyleAptitude.
	self installIndicatorThemeStyle
]

{ #category : 'private - styling' }
CFMaDetailAddPopupElement >> installIndicatorThemeStyle [
]

{ #category : 'private - instance creation' }
CFMaDetailAddPopupElement >> newIndicator [
	^ CFMaDetailAddIconElement size: 16 @ 16
]

{ #category : 'layout' }
CFMaDetailAddPopupElement >> supportsBaseline [
	^ false
]
