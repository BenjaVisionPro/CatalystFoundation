Class {
	#name : 'CFMaDetailPopupElement',
	#superclass : 'BrHorizontalPane',
	#instVars : [
		'leadingElement',
		'valueLabel',
		'indicatorHost',
		'indicator',
		'popupOpen',
		'popupStyleAptitude',
		'indicatorHostStyleAptitude'
	],
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'initialization' }
CFMaDetailPopupElement >> initialize [
	super initialize.
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
		background: BlBackground transparent;
		padding: BlInsets empty;
		addChild: indicator;
		yourself.

	self
		addChild: valueLabel;
		addChild: indicatorHost;
		when: BlMouseDownEvent do: [ :anEvent |
			anEvent primaryButtonPressed ifTrue: [ self requestFocus ] ].

	self installThemeStyles
]

{ #category : 'private - styling' }
CFMaDetailPopupElement >> installThemeStyles [
	popupStyleAptitude := BrLazyStyleCommonAptitude new
		default: [ :aStyle | aStyle background: BlBackground transparent ];
		hovered: [ :aStyle |
			aStyle background: (popupOpen
				ifTrue: [ BlBackground transparent ]
				ifFalse: [ self theme interaction popupBackgroundTint ]) ];
		focused: [ :aStyle |
			aStyle background: (popupOpen
				ifTrue: [ BlBackground transparent ]
				ifFalse: [ self theme interaction popupBackgroundTint ]) ];
		yourself.
	self addAptitude: popupStyleAptitude.

	indicatorHostStyleAptitude := BrLazyStyleCommonAptitude new
		@ indicatorHost;
		default: [ :aStyle |
			aStyle background: (popupOpen
				ifTrue: [ BlBackground transparent ]
				ifFalse: [ self theme interaction popupBackgroundTint ]) ];
		hovered: [ :aStyle | aStyle background: BlBackground transparent ];
		focused: [ :aStyle | aStyle background: BlBackground transparent ];
		yourself.
	self addAptitude: indicatorHostStyleAptitude.
	self installIndicatorThemeStyle
]

{ #category : 'private - styling' }
CFMaDetailPopupElement >> installIndicatorThemeStyle [
	self addAptitude: (BrLazyStyleCommonAptitude new
		@ indicator;
		default: [ :aStyle |
			aStyle do: [ indicator color: self theme label defaultTextForeground ] ])
]

{ #category : 'private - instance creation' }
CFMaDetailPopupElement >> newIndicator [
	^ (FontAwesomeIcons icon: #anglesUpDown)
		size: CFMaDetailPopupMetrics indicatorGlyphExtent;
		yourself
]

{ #category : 'accessing' }
CFMaDetailPopupElement >> popupOpen: aBoolean [
	popupOpen = aBoolean ifTrue: [ ^ self ].
	popupOpen := aBoolean.
	popupStyleAptitude updateWith: [ ].
	indicatorHostStyleAptitude updateWith: [ ]
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
