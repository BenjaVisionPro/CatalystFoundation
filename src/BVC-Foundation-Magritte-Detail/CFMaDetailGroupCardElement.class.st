Class {
	#name : 'CFMaDetailGroupCardElement',
	#superclass : 'BrVerticalPane',
	#instVars : [
		'rows'
	],
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'adding' }
CFMaDetailGroupCardElement >> addChild: anElement [
	self addRow: anElement at: rows size + 1
]

{ #category : 'adding' }
CFMaDetailGroupCardElement >> addRow: anElement at: anIndex [
	self
		assert: [ anIndex between: 1 and: rows size + 1 ]
		description: [ 'A row index must be between 1 and the number of rows + 1' ].
	self
		assert: [ anElement hasParent not ]
		description: [ 'A row must not already belong to another element' ].

	rows ifEmpty: [
		super addChild: anElement.
		rows add: anElement at: anIndex.
		^ anElement ].

	anIndex = (rows size + 1)
		ifTrue: [
			super addChild: self newSeparator.
			super addChild: anElement ]
		ifFalse: [
			super addChild: anElement at: (anIndex * 2 - 1).
			super addChild: self newSeparator at: anIndex * 2 ].
	rows add: anElement at: anIndex
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
	rows := OrderedCollection new.
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

{ #category : 'removing' }
CFMaDetailGroupCardElement >> removeChild: anElement [
	(rows identityIncludes: anElement)
		ifTrue: [ ^ self removeRow: anElement ].
	^ super removeChild: anElement
]

{ #category : 'removing' }
CFMaDetailGroupCardElement >> removeChildren [
	rows removeAll.
	^ super removeChildren
]

{ #category : 'removing' }
CFMaDetailGroupCardElement >> removeRow: anElement [
	| anIndex |
	anIndex := rows identityIndexOf: anElement ifAbsent: [
		^ self error: 'The element is not a row in this card' ].

	rows size = 1 ifTrue: [
		rows removeAt: anIndex.
		^ super removeChild: anElement ].

	anIndex = 1
		ifTrue: [
			super removeChild: (self children at: 2).
			super removeChild: anElement ]
		ifFalse: [
			super removeChild: (self children at: anIndex * 2 - 2).
			super removeChild: anElement ].
	rows removeAt: anIndex
]

{ #category : 'accessing' }
CFMaDetailGroupCardElement >> rowCount [
	^ rows size
]

{ #category : 'private - metrics' }
CFMaDetailGroupCardElement >> rowHorizontalInset [
	^ 8
]

{ #category : 'accessing' }
CFMaDetailGroupCardElement >> rows [
	^ rows copy
]
