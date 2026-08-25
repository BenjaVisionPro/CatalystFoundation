Class {
	#name : 'CFMaDetailPopupOptionElement',
	#superclass : 'BrHorizontalPane',
	#instVars : [
		'checkLabel',
		'valueLabel',
		'activateBlock',
		'hoverBlock',
		'checked'
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
			hovered: [ :aStyle | aStyle background: (Color black alpha: 0.08) ];
			selected: [ :aStyle |
				aStyle background: CFMaDetailColours highlight ]);
		addAptitude: (BrStyleCommonAptitude new
			@ checkLabelAptitude label;
			default: [ :aStyle | aStyle foreground: CFMaDetailColours primaryForeground ];
			selected: [ :aStyle | aStyle foreground: Color white ]);
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
CFMaDetailPopupOptionElement >> checked: aBoolean [
	checked := aBoolean.
	checkLabel visibility: (checked
		ifTrue: [ BlVisibility visible ]
		ifFalse: [ BlVisibility hidden ])
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
	| shouldDismiss |
	activateBlock ifNil: [ ^ self ].
	shouldDismiss := activateBlock cull: self.
	shouldDismiss ifTrue: [ self blinkSelectionAndDismiss ]
]

{ #category : 'private - interaction' }
CFMaDetailPopupOptionElement >> blinkSelectionAndDismiss [
	| menuContainer firstFlash secondFlash fadeAnimation dismissalAnimation |
	self states addState: BlElementState selected.
	menuContainer := self
		allParentsDetect: [ :eachParent | eachParent isKindOf: BrMenuSteppedElement ]
		ifFound: [ :aMenuContainer | aMenuContainer ]
		ifNone: [
			self fireEvent: BrDropdownHideWish new.
			^ self ].

	firstFlash := BlSequentialAnimation new
		addAll: {
			BlAnimation new
				duration: 80 milliSeconds;
				onFinishedDo: [ self states removeState: BlElementState selected ].
			BlAnimation new
				duration: 80 milliSeconds;
				onFinishedDo: [ self states addState: BlElementState selected ] };
		yourself.

	secondFlash := BlSequentialAnimation new
		addAll: {
			BlAnimation new
				duration: 80 milliSeconds;
				onFinishedDo: [ self states removeState: BlElementState selected ].
			BlAnimation new
				duration: 80 milliSeconds;
				onFinishedDo: [ self states addState: BlElementState selected ] };
		yourself.

	fadeAnimation := BlOpacityAnimation new
		target: menuContainer;
		opacity: 0.0;
		duration: 200 milliSeconds;
		yourself.

	dismissalAnimation := BlSequentialAnimation new
		add: firstFlash;
		add: (BlParallelAnimation with: { secondFlash. fadeAnimation });
		yourself.
	dismissalAnimation onFinishedDo: [
		self fireEvent: BrDropdownHideWish new.
		menuContainer opacity: 1.0 ].
	menuContainer addAnimation: dismissalAnimation
]

{ #category : 'accessing' }
CFMaDetailPopupOptionElement >> hoverBlock: aBlock [
	hoverBlock := aBlock
]
