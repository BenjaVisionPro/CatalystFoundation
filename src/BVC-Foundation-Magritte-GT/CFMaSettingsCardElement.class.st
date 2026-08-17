Class {
	#name : 'CFMaSettingsCardElement',
	#superclass : 'BrVerticalPane',
	#instVars : [
		'rowCount'
	],
	#category : 'BVC-Foundation-Magritte-GT-Presentations-Settings',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Presentations-Settings'
}

{ #category : 'initialization' }
CFMaSettingsCardElement >> initialize [
	super initialize.
	rowCount := 0.
	self
		background: (Color r: 248 g: 248 b: 248 range: 255);
		border: BlBorder empty;
		geometry: (BlRoundedRectangleGeometry cornerRadius: self cornerRadius);
		clipChildren: true;
		margin: BlInsets empty;
		padding: (BlInsets top: self edgeInset bottom: self edgeInset);
		cellSpacing: 0;
		hMatchParent;
		vFitContent
]

{ #category : 'adding' }
CFMaSettingsCardElement >> addRow: aRow [
	rowCount > 0 ifTrue: [ self addChild: self newSeparator ].
	self addChild: aRow.
	rowCount := rowCount + 1
]

{ #category : 'private - elements' }
CFMaSettingsCardElement >> newSeparator [
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
		padding: (BlInsets left: self rowHorizontalInset right: self rowHorizontalInset + self editorTextHorizontalInset);
		addChild: aSeparator;
		yourself.
	^ aFrame
]

{ #category : 'private - metrics' }
CFMaSettingsCardElement >> cornerRadius [
	^ 12
]

{ #category : 'private - metrics' }
CFMaSettingsCardElement >> edgeInset [
	^ 3
]

{ #category : 'private - metrics' }
CFMaSettingsCardElement >> editorTextHorizontalInset [
	^ 5
]

{ #category : 'private - metrics' }
CFMaSettingsCardElement >> rowHorizontalInset [
	^ 8
]
