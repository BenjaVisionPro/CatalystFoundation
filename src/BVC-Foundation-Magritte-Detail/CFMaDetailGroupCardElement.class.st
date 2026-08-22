Class {
	#name : 'CFMaDetailGroupCardElement',
	#superclass : 'BrVerticalPane',
	#instVars : [
		'rowCount'
	],
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'adding' }
CFMaDetailGroupCardElement >> addChild: anElement [
	rowCount > 0 ifTrue: [ super addChild: self newSeparator ].
	super addChild: anElement.
	rowCount := rowCount + 1
]

{ #category : 'private - metrics' }
CFMaDetailGroupCardElement >> cornerRadius [
	^ 12
]

{ #category : 'private - metrics' }
CFMaDetailGroupCardElement >> edgeInset [
	^ 2
]

{ #category : 'initialization' }
CFMaDetailGroupCardElement >> initialize [
	super initialize.
	rowCount := 0.
	self
		background: (Color r: 248 g: 248 b: 248 range: 255);
		border: BlBorder empty;
		geometry: (BlRoundedRectangleGeometry cornerRadius: self cornerRadius);
		clipChildren: true;
		margin: BlInsets empty;
		padding: (BlInsets top: self edgeInset right: 0 bottom: self edgeInset left: 0);
		cellSpacing: 0;
		hMatchParent;
		vFitContent
]

{ #category : 'private - elements' }
CFMaDetailGroupCardElement >> newSeparator [
	| aSeparator aFrame |
	aSeparator := BlElement new
		background: (Color r: 229 g: 229 b: 229 range: 255);
		yourself.
	aSeparator constraintsDo: [ :c |
		c horizontal matchParent.
		c vertical exact: 1.
		c frame horizontal alignCenter.
		c frame vertical alignCenter ].
	aFrame := BrFrame new
		hMatchParent;
		vExact: 1;
		padding: (BlInsets left: self rowHorizontalInset right: self rowHorizontalInset);
		addChild: aSeparator;
		yourself.
	^ aFrame
]

{ #category : 'private - metrics' }
CFMaDetailGroupCardElement >> rowHorizontalInset [
	^ 8
]
