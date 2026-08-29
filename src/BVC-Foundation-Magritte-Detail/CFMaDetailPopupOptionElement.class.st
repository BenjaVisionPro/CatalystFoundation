Class {
	#name : 'CFMaDetailPopupOptionElement',
	#superclass : 'BrHorizontalPane',
	#instVars : [
		'checkLabel',
		'leadingElement',
		'valueLabel',
		'activateBlock',
		'canActivateBlock',
		'hoverBlock',
		'checked',
		'selectionList',
		'selectionIndex'
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
	canActivateBlock := [ true ].
	hoverBlock := nil.
	checked := false.
	checkLabel visibility: BlVisibility hidden.
	self
		when: BlMouseEnterEvent do: [ :anEvent |
			hoverBlock ifNotNil: [ hoverBlock cull: self ] ];
		when: BlClickEvent do: [ :anEvent | self activate ];
		addChild: checkLabel;
		addChild: valueLabel;
		addAptitude: (BrStyleCommonAptitude new
			default: [ :aStyle | aStyle background: Color transparent ];
			hovered: [ :aStyle | aStyle background: (self theme interaction controlBackgroundTint) ];
			selected: [ :aStyle |
				aStyle background: (self theme appearanceState themeColour) ]);
		addAptitude: (BrStyleCommonAptitude new
			@ checkLabelAptitude label;
			default: [ :aStyle | aStyle foreground: (self theme typography primaryForeground) ];
			selected: [ :aStyle | aStyle foreground: (Color white) ]);
		addAptitude: (BrStyleCommonAptitude new
			@ valueLabelAptitude label;
			default: [ :aStyle | aStyle foreground: (self theme typography primaryForeground) ];
			selected: [ :aStyle | aStyle foreground: (Color white) ])
]



{ #category : 'accessing' }
CFMaDetailPopupOptionElement >> activateBlock: aBlock [
	activateBlock := aBlock
]

{ #category : 'accessing' }
CFMaDetailPopupOptionElement >> canActivateBlock: aBlock [
	canActivateBlock := aBlock
]

{ #category : 'accessing' }
CFMaDetailPopupOptionElement >> checked: aBoolean [
	checked := aBoolean.
	checkLabel visibility: (checked
		ifTrue: [ BlVisibility visible ]
		ifFalse: [ BlVisibility hidden ])
]


{ #category : 'accessing' }
CFMaDetailPopupOptionElement >> selectionIn: aList at: anIndex [
	selectionList := aList.
	selectionIndex := anIndex
]

{ #category : 'accessing' }
CFMaDetailPopupOptionElement >> selectionIndex [
	^ selectionIndex
]

{ #category : 'accessing' }
CFMaDetailPopupOptionElement >> selectionList [
	^ selectionList
]

{ #category : 'accessing' }
CFMaDetailPopupOptionElement >> text [
	^ valueLabel text
]

{ #category : 'accessing' }
CFMaDetailPopupOptionElement >> text: aTextOrString [
	valueLabel text: aTextOrString
]


{ #category : 'private - interaction' }
CFMaDetailPopupOptionElement >> activate [
	activateBlock ifNil: [ ^ self ].
	(canActivateBlock cull: self) ifFalse: [ ^ self ].
	activateBlock cull: self.
	self fireEvent: CFMaDetailPopupDismissRequest new
]

{ #category : 'accessing' }
CFMaDetailPopupOptionElement >> hoverBlock: aBlock [
	hoverBlock := aBlock
]


{ #category : 'accessing' }
CFMaDetailPopupOptionElement >> leadingElement: anElement [
	leadingElement ifNotNil: [
		leadingElement parent ifNotNil: [ leadingElement removeFromParent ] ].
	leadingElement := anElement.
	leadingElement ifNil: [ ^ self ].
	leadingElement
		margin: (BlInsets right: 6);
		constraintsDo: [ :c | c linear vertical alignCenter ].
	self addChild: leadingElement after: checkLabel
]
