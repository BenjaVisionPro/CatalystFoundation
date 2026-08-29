Class {
	#name : 'CFMaDetailPopupElement',
	#superclass : 'BrHorizontalPane',
	#instVars : [
		'leadingElement',
		'valueLabel',
		'indicatorHost',
		'indicator',
		'hovered',
		'popupOpen'
	],
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'initialization' }
CFMaDetailPopupElement >> initialize [
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

	indicator := self newIndicator.
	indicator constraintsDo: [ :c |
		c frame horizontal alignCenter.
		c frame vertical alignCenter ].

	indicatorHost := BrFrame new
		size: CFMaDetailPopupMetrics indicatorExtent;
		geometry: BlCircleGeometry new;
		background: self popupBackgroundColor;
		padding: BlInsets empty;
		addChild: indicator;
		yourself.

	indicator
		when: BlElementThemeChanged
		do: [ :anEvent | self updateIndicatorAppearance ].
	indicatorHost
		when: BlElementThemeChanged
		do: [ :anEvent | self updateIndicatorHostAppearance ].

	self
		addChild: valueLabel;
		addChild: indicatorHost;
		when: BlMouseDownEvent do: [ :anEvent |
			anEvent primaryButtonPressed ifTrue: [ self requestFocus ] ];
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
		color: self theme label defaultTextForeground;
		yourself
]

{ #category : #'theme - applying' }
CFMaDetailPopupElement >> onThemeChanged [
	super onThemeChanged.
	self updatePopupBackgroundAppearance
]

{ #category : 'private - appearance' }
CFMaDetailPopupElement >> updateIndicatorAppearance [
	indicator color: indicator theme label defaultTextForeground
]


{ #category : 'private - appearance' }
CFMaDetailPopupElement >> popupBackgroundColor [
	^ self theme interaction popupBackgroundTint
]

{ #category : 'private - appearance' }
CFMaDetailPopupElement >> updatePopupAppearance [
	self updatePopupBackgroundAppearance.
	self updateIndicatorHostAppearance
]

{ #category : 'private - appearance' }
CFMaDetailPopupElement >> updatePopupBackgroundAppearance [
	popupOpen ifTrue: [
		self background: BlBackground transparent.
		^ self ].

	self background: ((hovered or: [ self hasFocus ])
		ifTrue: [ self popupBackgroundColor ]
		ifFalse: [ BlBackground transparent ])
]

{ #category : 'private - appearance' }
CFMaDetailPopupElement >> updateIndicatorHostAppearance [
	popupOpen ifTrue: [
		indicatorHost background: BlBackground transparent.
		^ self ].

	indicatorHost background: ((hovered or: [ self hasFocus ])
		ifTrue: [ BlBackground transparent ]
		ifFalse: [ indicatorHost theme interaction popupBackgroundTint ])
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


{ #category : 'accessing' }
CFMaDetailPopupElement >> leadingElement: anElement [
	leadingElement ifNotNil: [
		leadingElement parent ifNotNil: [ leadingElement removeFromParent ] ].
	leadingElement := anElement.
	leadingElement ifNil: [ ^ self ].
	leadingElement margin: (BlInsets right: 6).
	self addChild: leadingElement before: valueLabel
]
