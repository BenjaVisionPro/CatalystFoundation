Class {
	#name : 'CFMaDetailGroupCardElement',
	#superclass : 'BrVerticalPane',
	#instVars : [
		'rows',
		'focusOverlay',
		'reservedAccessorySlots'
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
	self configureAccessoryReservationFor: anElement.
	self
		assert: [ anIndex between: 1 and: rows size + 1 ]
		description: [ 'A row index must be between 1 and the number of rows + 1' ].
	self
		assert: [ anElement hasParent not ]
		description: [ 'A row must not already belong to another element' ].

	rows ifEmpty: [
		self addStructuralChild: anElement.
		rows add: anElement beforeIndex: anIndex.
		self installFocusOverlayFor: anElement.
		self notifyRowsChanged.
		^ anElement ].

	anIndex = (rows size + 1)
		ifTrue: [
			self addStructuralChild: self newSeparator.
			self addStructuralChild: anElement ]
		ifFalse: [
			super addChild: anElement at: (anIndex * 2 - 1).
			super addChild: self newSeparator at: anIndex * 2 ].
	rows add: anElement beforeIndex: anIndex.
	self installFocusOverlayFor: anElement.
	self notifyRowsChanged
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
	focusOverlay := nil.
	reservedAccessorySlots := 0.
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
	focusOverlay := nil.
	^ super removeChildren
]

{ #category : 'removing' }
CFMaDetailGroupCardElement >> removeRow: anElement [
	| anIndex |
	anIndex := rows identityIndexOf: anElement ifAbsent: [
		^ self error: 'The element is not a row in this card' ].

	rows size = 1 ifTrue: [
		rows removeAt: anIndex.
		self removeFocusOverlay.
		super removeChild: anElement.
		self notifyRowsChanged.
		^ anElement ].

	anIndex = 1
		ifTrue: [
			super removeChild: (self children at: 2).
			super removeChild: anElement ]
		ifFalse: [
			super removeChild: (self children at: anIndex * 2 - 2).
			super removeChild: anElement ].
	rows removeAt: anIndex.
	self notifyRowsChanged
]


{ #category : 'private - focus' }
CFMaDetailGroupCardElement >> addStructuralChild: anElement [
	focusOverlay
		ifNil: [ super addChild: anElement ]
		ifNotNil: [ super addChild: anElement at: self childrenCount ]
]

{ #category : 'private - focus' }
CFMaDetailGroupCardElement >> focusOverlayFor: aRow [
	focusOverlay ifNotNil: [ ^ focusOverlay ].
	focusOverlay := BlOverlayElement on: aRow.
	focusOverlay
		border: BlBorder empty;
		background: Color transparent;
		zIndex: 100.
	focusOverlay
		when: BlElementPositionChangedEvent
		do: [ :anEvent | self updateFocusOverlayGeometry ];
		when: BlElementExtentChangedEvent
		do: [ :anEvent | self updateFocusOverlayGeometry ].
	self
		when: BlElementExtentChangedEvent
		do: [ :anEvent | self updateFocusOverlayGeometry ].
	super addChild: focusOverlay.
	^ focusOverlay
]

{ #category : 'private - focus' }
CFMaDetailGroupCardElement >> installFocusOverlayFor: aRow [
	aRow
		when: BlFocusInEvent
		do: [ :anEvent |
			| anOverlay |
			anOverlay := self focusOverlayFor: aRow.
			anOverlay
				attachTo: aRow;
				border: (BlBorder
					paint: (anOverlay theme editor focusedBorderColor alpha: 0.3)
					width: 1).
			self updateFocusOverlayGeometry ];
		when: BlFocusOutEvent
		do: [ :anEvent |
			focusOverlay ifNotNil: [ :anOverlay |
				anOverlay border: BlBorder empty ] ]
]

{ #category : 'private - focus' }
CFMaDetailGroupCardElement >> removeFocusOverlay [
	focusOverlay ifNil: [ ^ self ].
	focusOverlay hasParent ifTrue: [ super removeChild: focusOverlay ].
	focusOverlay := nil
]

{ #category : 'private - focus' }
CFMaDetailGroupCardElement >> updateFocusOverlayGeometry [
	| overlayBounds topRadius bottomRadius radii |
	focusOverlay ifNil: [ ^ self ].
	focusOverlay hasParent ifFalse: [ ^ self ].

	overlayBounds := (focusOverlay bounds inParent: self) asRectangle.
	topRadius := (overlayBounds top closeTo: self padding top epsilon: BlElement epsilon)
		ifTrue: [ self cornerRadius ]
		ifFalse: [ 0 ].
	bottomRadius := (overlayBounds bottom
		closeTo: self extent y - self padding bottom
		epsilon: BlElement epsilon)
		ifTrue: [ self cornerRadius ]
		ifFalse: [ 0 ].

	radii := BlCornerRadii new
		topLeft: topRadius;
		topRight: topRadius;
		bottomLeft: bottomRadius;
		bottomRight: bottomRadius;
		yourself.
	focusOverlay geometry: (BlRoundedRectangleGeometry cornerRadii: radii)
]

{ #category : 'private - layout' }
CFMaDetailGroupCardElement >> notifyRowsChanged [
	(self parent isKindOf: CFMaDetailGroupElement) ifTrue: [
		self parent updateGroupSpacing ]
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


{ #category : 'private - layout' }
CFMaDetailGroupCardElement >> configureAccessoryReservationFor: aRow [
	(aRow layout isKindOf: CFMaDetailRowLayout) ifFalse: [ ^ self ].
	aRow layout reservedAccessorySlots: reservedAccessorySlots
]

{ #category : 'accessing' }
CFMaDetailGroupCardElement >> reservedAccessorySlots [
	^ reservedAccessorySlots
]

{ #category : 'accessing' }
CFMaDetailGroupCardElement >> reservedAccessorySlots: aNumber [
	self
		assert: [ aNumber isInteger and: [ aNumber >= 0 ] ]
		description: [ 'The number of reserved accessory slots must be a non-negative integer' ].
	reservedAccessorySlots := aNumber.
	rows do: [ :aRow |
		self configureAccessoryReservationFor: aRow.
		aRow requestLayout ].
	self requestLayout
]
