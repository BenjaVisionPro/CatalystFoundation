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
		layout: CFMaDetailPopupLayout new;
		fitContent;
		padding: (BlInsets
			top: (CFMaDetailPopupMetrics controlHeight - CFMaDetailPopupMetrics indicatorExtent y) / 2
			right: CFMaDetailPopupMetrics controlRightInset
			bottom: (CFMaDetailPopupMetrics controlHeight - CFMaDetailPopupMetrics indicatorExtent y) / 2
			left: CFMaDetailPopupMetrics controlLeftInset);
		geometry: (BlRoundedRectangleGeometry cornerRadius: CFMaDetailPopupMetrics controlCornerRadius);
		background: BlBackground transparent;
		border: BlBorder empty;
		beFocusable.

	valueLabel := BrLabel new
		aptitude: (BrGlamorousLabelAptitude new
			glamorousRegularFontAndSize;
			padding: BlInsets empty;
			yourself);
		fitContent;
		yourself.

	anIndicator := self newIndicator.
	anIndicator constraintsDo: [ :c |
		c frame horizontal alignCenter.
		c frame vertical alignCenter ].

	indicatorHost := BrFrame new
		size: CFMaDetailPopupMetrics indicatorExtent;
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


{ #category : 'private - instance creation' }
CFMaDetailPopupElement >> newIndicator [
	^ (FontAwesomeIcons icon: #anglesUpDown)
		size: CFMaDetailPopupMetrics indicatorGlyphExtent;
		color: (Color black alpha: 0.72);
		yourself
]

{ #category : 'private - appearance' }
CFMaDetailPopupElement >> popupBackgroundColor [
	^ CFMaDetailPopupMetrics controlBackgroundColor
]

{ #category : 'private - appearance' }
CFMaDetailPopupElement >> updatePopupAppearance [
	| isActive |
	isActive := popupOpen or: [ hovered or: [ self hasFocus ] ].
	self background: (isActive
		ifTrue: [ self popupBackgroundColor ]
		ifFalse: [ BlBackground transparent ]).
	indicatorHost background: (isActive
		ifTrue: [ BlBackground transparent ]
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
