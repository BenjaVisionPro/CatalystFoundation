Class {
	#name : 'CFMaDetailPopupElement',
	#superclass : 'BrHorizontalPane',
	#instVars : [
		'valueLabel',
		'indicatorHost',
		'hovered'
	],
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'initialization' }
CFMaDetailPopupElement >> initialize [
	| anIndicator |
	super initialize.
	hovered := false.
	self
		alignCenterLeft;
		fitContent;
		cellSpacing: 8;
		padding: (BlInsets top: 2 right: 4 bottom: 2 left: 12);
		geometry: (BlRoundedRectangleGeometry cornerRadius: 4);
		background: Color transparent;
		border: BlBorder empty;
		beFocusable;
		addAptitude: (BrStyleCommonAptitude new
			default: [ :aStyle | aStyle background: Color transparent ];
			hovered: [ :aStyle | aStyle background: self popupBackgroundColor ];
			focused: [ :aStyle | aStyle background: self popupBackgroundColor ]).

	valueLabel := BrLabel new
		aptitude: BrGlamorousLabelAptitude new glamorousRegularFontAndSize;
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
			self updateIndicatorBackground ];
		when: BlMouseLeaveEvent do: [ :anEvent |
			hovered := false.
			self updateIndicatorBackground ];
		when: BlFocusInEvent do: [ :anEvent | self updateIndicatorBackground ];
		when: BlFocusOutEvent do: [ :anEvent | self updateIndicatorBackground ]
]

{ #category : 'private - appearance' }
CFMaDetailPopupElement >> popupBackgroundColor [
	^ Color black alpha: 0.1
]

{ #category : 'private - appearance' }
CFMaDetailPopupElement >> updateIndicatorBackground [
	(hovered or: [ self hasFocus ])
		ifTrue: [ indicatorHost background: Color transparent ]
		ifFalse: [ indicatorHost background: self popupBackgroundColor ]
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
