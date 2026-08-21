Class {
	#name : 'CFMaDetailPopupElement',
	#superclass : 'BrHorizontalPane',
	#instVars : [
		'valueLabel'
	],
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'initialization' }
CFMaDetailPopupElement >> initialize [
	| anIndicatorHost anIndicator |
	super initialize.
	self
		alignCenter;
		fitContent;
		cellSpacing: 8;
		padding: (BlInsets top: 4 right: 4 bottom: 4 left: 12);
		geometry: (BlRoundedRectangleGeometry cornerRadius: 10);
		background: Color transparent;
		border: BlBorder empty;
		beFocusable;
		addAptitude: (BrStyleCommonAptitude new
			default: [ :aStyle | aStyle background: Color transparent ];
			hovered: [ :aStyle | aStyle background: (Color black alpha: 0.07) ];
			focused: [ :aStyle | aStyle background: (Color black alpha: 0.07) ]).

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

	anIndicatorHost := BrFrame new
		size: 26 @ 26;
		geometry: BlCircleGeometry new;
		background: (Color black alpha: 0.07);
		padding: BlInsets empty;
		addChild: anIndicator;
		yourself.

	self
		addChild: valueLabel;
		addChild: anIndicatorHost
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
