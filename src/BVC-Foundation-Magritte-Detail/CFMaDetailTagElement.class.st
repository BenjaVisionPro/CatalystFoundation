Class {
	#name : 'CFMaDetailTagElement',
	#superclass : 'CFEditableLabel',
	#instVars : [
		'value',
		'selectedBlock'
	],
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'initialization' }
CFMaDetailTagElement >> initialize [
	super initialize.
	self
		aptitude: BrGlamorousEditableLabelAptitude new glamorousRegularFontAndSize;
		fitContent;
		padding: (BlInsets top: 3 right: 8 bottom: 3 left: 8);
		margin: (BlInsets top: 2 right: 4 bottom: 2 left: 0);
		geometry: (BlRoundedRectangleGeometry cornerRadius: 8);
		background: (Color black alpha: 0.06);
		border: BlBorder empty;
		constraintsDo: [ :c | c flow vertical alignCenter ];
		when: BlClickEvent do: [ :anEvent |
			selectedBlock ifNotNil: [ selectedBlock cull: self ] ].
]

{ #category : 'accessing' }
CFMaDetailTagElement >> selectedBlock: aBlock [
	selectedBlock := aBlock
]

{ #category : 'accessing' }
CFMaDetailTagElement >> value [
	^ value
]

{ #category : 'accessing' }
CFMaDetailTagElement >> value: anObject [
	value := anObject
]

{ #category : 'selection' }
CFMaDetailTagElement >> beSelected [
	self
		background: CFMaDetailColours highlight;
		foreground: Color white
]

{ #category : 'selection' }
CFMaDetailTagElement >> beUnselected [
	self
		background: (Color black alpha: 0.06);
		foreground: CFMaDetailColours primaryForeground
]
