Class {
	#name : 'CFMaDetailColourPickerOptionElement',
	#superclass : 'BrVerticalPane',
	#instVars : [
		'value',
		'colour',
		'swatch',
		'labelElement',
		'selected',
		'activateBlock'
	],
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'initialization' }
CFMaDetailColourPickerOptionElement >> initialize [
	super initialize.
	selected := false.
	swatch := BrButton new
		aptitude: BrGlamorousButtonLayoutAptitude new;
		hExact: 44;
		vExact: 44;
		padding: (BlInsets all: 5);
		background: Color transparent;
		border: BlBorder empty;
		geometry: BlCircleGeometry new;
		action: [ :aButton |
			activateBlock ifNotNil: [ activateBlock cull: self ] ];
		yourself.
	labelElement := BrLabel new
		aptitude: BrGlamorousLabelAptitude new glamorousRegularFontAndSize;
		hFitContent;
		vFitContent;
		visibility: BlVisibility hidden;
		yourself.
	self
		hExact: 56;
		vFitContent;
		cellSpacing: 2;
		alignCenter;
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
	colour := aColour.
	swatch
		removeChildren;
		addChild: (BlElement new
			size: 34 @ 34;
			geometry: BlCircleGeometry new;
			background: (colour ifNil: [ Color veryLightGray ]);
			border: (colour
				ifNil: [ BlBorder paint: Color lightGray width: 1 ]
				ifNotNil: [ BlBorder empty ]);
			constraintsDo: [ :c |
				c frame horizontal alignCenter.
				c frame vertical alignCenter ];
			yourself)
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
		ifFalse: [ BlBorder empty ]).
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
