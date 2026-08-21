Class {
	#name : 'CFMaDetailPopupOptionElement',
	#superclass : 'BrHorizontalPane',
	#instVars : [
		'checkLabel',
		'valueLabel'
	],
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'initialization' }
CFMaDetailPopupOptionElement >> initialize [
	super initialize.
	self
		hFitContent;
		vExact: 24;
		padding: (BlInsets top: 0 right: 8 bottom: 0 left: 6);
		geometry: (BlRoundedRectangleGeometry cornerRadius: 5);
		background: Color transparent;
		border: BlBorder empty;
		cellSpacing: 2.

	checkLabel := BrLabel new
		aptitude: (BrGlamorousLabelAptitude new
			glamorousRegularFontAndSize;
			padding: BlInsets empty;
			yourself);
		text: ('✓' asRopedText foreground: Color transparent);
		hExact: 14;
		vFitContent;
		yourself.

	valueLabel := BrLabel new
		aptitude: (BrGlamorousLabelAptitude new
			glamorousRegularFontAndSize;
			padding: BlInsets empty;
			yourself);
		fitContent;
		yourself.

	self
		addChild: checkLabel;
		addChild: valueLabel;
		addAptitude: (BrStyleCommonAptitude new
			default: [ :aStyle |
				aStyle background: Color transparent.
				checkLabel text: ('✓' asRopedText foreground: Color transparent).
				valueLabel text: (valueLabel text asString asRopedText foreground: Color black) ];
			hovered: [ :aStyle | aStyle background: (Color black alpha: 0.06) ];
			selected: [ :aStyle |
				aStyle background: (Color r: 10 g: 132 b: 255 range: 255).
				checkLabel text: ('✓' asRopedText foreground: Color white).
				valueLabel text: (valueLabel text asString asRopedText foreground: Color white) ])
]

{ #category : 'accessing' }
CFMaDetailPopupOptionElement >> text [
	^ valueLabel text
]

{ #category : 'accessing' }
CFMaDetailPopupOptionElement >> text: aTextOrString [
	valueLabel text: (aTextOrString asRopedText foreground: Color black)
]
