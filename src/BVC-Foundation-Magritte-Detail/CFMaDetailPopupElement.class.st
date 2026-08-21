Class {
	#name : 'CFMaDetailPopupElement',
	#superclass : 'BrHorizontalPane',
	#instVars : [
		'valueLabel',
		'indicatorHost',
		'hovered',
		'popupOpen'
	],
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'initialization' }
CFMaDetailPopupElement >> initialize [
	| anIndicator |
	super initialize.
	hovered := false.
	popupOpen := false.
	self
		layout: (CFMaDetailPopupLayout new gap: 12; yourself);
		fitContent;
		padding: (BlInsets top: 2 right: 4 bottom: 2 left: 12);
		geometry: (BlRoundedRectangleGeometry cornerRadius: 4);
		background: Color transparent;
		border: BlBorder empty;
		beFocusable.

	valueLabel := BrLabel new
		aptitude: (BrGlamorousLabelAptitude new
			glamorousRegularFontAndSize;
			padding: BlInsets empty;
			yourself);
		fitContent;
		yourself.

	anIndicator := (FontAwesomeIcons icon: #chevronDoubleDown)
		fitInto: 10 @ 10;
		color: (Color black alpha: 0.72);
		yourself.
	anIndicator constraintsDo: [ :c |
		c frame horizontal alignCenter.
		c frame vertical alignCenter ].

	indicatorHost := BrFrame new
		size: 20 @ 20;
		geometry: BlCircleGeometry new;
		background: self popupBackgroundColor;
		padding: BlInsets empty;
		addChild: anIndicator;
		yourself.

	self
		addChild: valueLabel;
		addChild: indicatorHost;
		when: BlMouseEnterEvent do: [ :anEvent |
			hovered := true.
			self updatePopupAppearance ];
		when: BlMouseLeaveEvent do: [ :anEvent |
			hovered := false.
			self updatePopupAppearance ];
		when: BlFocusInEvent do: [ :anEvent | self updatePopupAppearance ];
		when: BlFocusOutEvent do: [ :anEvent | self updatePopupAppearance ]

]

{ #category : 'private - appearance' }
CFMaDetailPopupElement >> popupBackgroundColor [
	^ Color black alpha: 0.1
]

{ #category : 'private - appearance' }
CFMaDetailPopupElement >> updatePopupAppearance [
	| isActive |
	isActive := popupOpen or: [ hovered or: [ self hasFocus ] ].
	self background: (isActive
		ifTrue: [ self popupBackgroundColor ]
		ifFalse: [ Color transparent ]).
	indicatorHost background: (isActive
		ifTrue: [ Color transparent ]
		ifFalse: [ self popupBackgroundColor ])
]

{ #category : 'accessing' }
CFMaDetailPopupElement >> popupOpen: aBoolean [
	popupOpen := aBoolean.
	self updatePopupAppearance
]


{ #category : 'layout' }
CFMaDetailPopupElement >> baselineOffset [
	^ valueLabel baselineOffset + valueLabel margin top + self padding top
]

{ #category : 'layout' }
CFMaDetailPopupElement >> supportsBaseline [
	^ true
]

{ #category : 'accessing' }
CFMaDetailPopupElement >> text [
	^ valueLabel text
]

{ #category : 'accessing' }
CFMaDetailPopupElement >> text: aTextOrString [
	valueLabel text: aTextOrString
]
