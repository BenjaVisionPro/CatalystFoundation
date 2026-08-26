Class {
	#name : 'CFMaDetailColourPickerOptionElement',
	#superclass : 'BrVerticalPane',
	#instVars : [
		'value',
		'colour',
		'swatch',
		'labelElement',
		'selected',
		'hovered',
		'activateBlock',
		'hoverBlock'
	],
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'initialization' }
CFMaDetailColourPickerOptionElement >> initialize [
	super initialize.
	selected := false.
	hovered := false.
	swatch := BrButton new
		aptitude: BrGlamorousButtonLayoutAptitude new;
		hExact: 34;
		vExact: 34;
		padding: (BlInsets all: 5);
		background: Color transparent;
		border: BlBorder empty;
		geometry: BlCircleGeometry new;
		action: [ :aButton |
			activateBlock ifNotNil: [ activateBlock cull: self ] ];
		when: BlMouseEnterEvent do: [ :anEvent |
			hoverBlock
				ifNil: [ self hovered: true ]
				ifNotNil: [ hoverBlock cull: self cull: true ] ];
		when: BlMouseLeaveEvent do: [ :anEvent |
			hoverBlock
				ifNil: [ self hovered: false ]
				ifNotNil: [ hoverBlock cull: self cull: false ] ];
		yourself.
	labelElement := BrLabel new
		aptitude: (BrGlamorousLabelAptitude new
			glamorousRegularFont;
			glamorousRegularSmallSize);
		hFitContent;
		vFitContent;
		visibility: BlVisibility hidden;
		yourself.
	self
		hExact: 34;
		vFitContent;
		cellSpacing: 1;
		alignCenter;
		clipChildren: false;
		addChild: swatch;
		addChild: labelElement
]

{ #category : 'accessing' }
CFMaDetailColourPickerOptionElement >> activateBlock: aBlock [
	activateBlock := aBlock
]

{ #category : 'accessing' }
CFMaDetailColourPickerOptionElement >> colour [
	^ colour
]

{ #category : 'accessing' }
CFMaDetailColourPickerOptionElement >> colour: aColour [
	| aSwatchElement |
	colour := aColour.
	aSwatchElement := aColour
		ifNil: [ CFMaDetailColourSwatchElement automaticSize: 24 @ 24 ]
		ifNotNil: [
			CFMaDetailColourSwatchElement
				colour: aColour
				size: 24 @ 24 ].
	aSwatchElement constraintsDo: [ :c |
		c frame horizontal alignCenter.
		c frame vertical alignCenter ].
	swatch
		removeChildren;
		addChild: aSwatchElement
]

{ #category : 'accessing' }
CFMaDetailColourPickerOptionElement >> label: aString [
	labelElement text: aString asRopedText
]

{ #category : 'selection' }
CFMaDetailColourPickerOptionElement >> selected: aBoolean [
	selected := aBoolean.
	swatch border: (aBoolean
		ifTrue: [
			BlBorder
				paint: (colour ifNil: [ CFMaDetailColours secondaryForeground ])
				width: 3 ]
		ifFalse: [ BlBorder empty ])
]

{ #category : 'interaction' }
CFMaDetailColourPickerOptionElement >> hovered: aBoolean [
	hovered := aBoolean
]

{ #category : 'appearance' }
CFMaDetailColourPickerOptionElement >> labelVisible: aBoolean [
	labelElement visibility: (aBoolean
		ifTrue: [ BlVisibility visible ]
		ifFalse: [ BlVisibility hidden ])
]

{ #category : 'accessing' }
CFMaDetailColourPickerOptionElement >> value [
	^ value
]

{ #category : 'accessing' }
CFMaDetailColourPickerOptionElement >> value: anObject [
	value := anObject
]


{ #category : 'accessing' }
CFMaDetailColourPickerOptionElement >> hoverBlock: aBlock [
	hoverBlock := aBlock
]
