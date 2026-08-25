Class {
	#name : 'CFMaDetailPopupOptionElement',
	#superclass : 'BrHorizontalPane',
	#instVars : [
		'checkLabel',
		'valueLabel',
		'activateBlock'
	],
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'initialization' }
CFMaDetailPopupOptionElement >> initialize [
	| checkLabelAptitude valueLabelAptitude |
	super initialize.
	self
		hMatchParent;
		vExact: CFMaDetailPopupMetrics optionHeight;
		padding: (BlInsets
			top: 0
			right: CFMaDetailPopupMetrics optionRightInset
			bottom: 0
			left: CFMaDetailPopupMetrics optionLeftInset);
		geometry: (BlRoundedRectangleGeometry cornerRadius: CFMaDetailPopupMetrics optionCornerRadius);
		background: Color transparent;
		border: BlBorder empty;
		cellSpacing: CFMaDetailPopupMetrics checkLabelGap.

	checkLabelAptitude := BrGlamorousLabelAptitude new
		glamorousRegularFontAndSize;
		padding: BlInsets empty;
		yourself.
	checkLabel := BrLabel new
		aptitude: checkLabelAptitude;
		text: '✓';
		hExact: CFMaDetailPopupMetrics checkWidth;
		vFitContent;
		constraintsDo: [ :c | c linear vertical alignCenter ];
		yourself.

	valueLabelAptitude := BrGlamorousLabelAptitude new
		glamorousRegularFontAndSize;
		padding: BlInsets empty;
		yourself.
	valueLabel := BrLabel new
		aptitude: valueLabelAptitude;
		fitContent;
		constraintsDo: [ :c | c linear vertical alignCenter ];
		yourself.

	activateBlock := nil.
	self
		when: BlClickEvent do: [ :anEvent | activateBlock ifNotNil: [ activateBlock value ] ];
		addChild: checkLabel;
		addChild: valueLabel;
		addAptitude: (BrStyleCommonAptitude new
			default: [ :aStyle | aStyle background: Color transparent ];
			hovered: [ :aStyle | aStyle background: (Color black alpha: 0.08) ];
			selected: [ :aStyle |
				aStyle background: CFMaDetailColours highlight ]);
		addAptitude: (BrStyleCommonAptitude new
			@ checkLabel;
			deselected: [ :aStyle | aStyle hidden ];
			selected: [ :aStyle | aStyle visible ]);
		addAptitude: (BrStyleCommonAptitude new
			@ checkLabelAptitude label;
			default: [ :aStyle | aStyle foreground: Color white ]);
		addAptitude: (BrStyleCommonAptitude new
			@ valueLabelAptitude label;
			default: [ :aStyle | aStyle foreground: CFMaDetailColours primaryForeground ];
			selected: [ :aStyle | aStyle foreground: Color white ])
]



{ #category : 'accessing' }
CFMaDetailPopupOptionElement >> activateBlock: aBlock [
	activateBlock := aBlock
]

{ #category : 'accessing' }
CFMaDetailPopupOptionElement >> text [
	^ valueLabel text
]

{ #category : 'accessing' }
CFMaDetailPopupOptionElement >> text: aTextOrString [
	valueLabel text: aTextOrString
]
