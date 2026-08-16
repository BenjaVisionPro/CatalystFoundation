"I present Magritte descriptions using Foundation's settings interface language: section headings, rounded cards, contiguous rows and trailing controls."

Class {
	#name : 'CFMaSettingsPresentation',
	#superclass : 'CFMaPresentation',
	#instVars : [
		'rowCountsByContainer'
	],
	#category : 'BVC-Foundation-Magritte-GT-Presentations-Settings',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Presentations-Settings'
}

{ #category : 'initialization' }
CFMaSettingsPresentation >> initialize [
	super initialize.
	rowCountsByContainer := IdentityDictionary new
]

{ #category : 'api - building' }
CFMaSettingsPresentation >> build [
	| anElement |
	rowCountsByContainer removeAll.
	anElement := super build.
	self hostElement background: Color white.
	^ anElement
]

{ #category : 'private - appearance' }
CFMaSettingsPresentation >> cardBackground [
	^ Color r: 248 g: 248 b: 248 range: 255
]

{ #category : 'private - appearance' }
CFMaSettingsPresentation >> primaryTextColor [
	^ Color r: 39 g: 39 b: 39 range: 255
]

{ #category : 'private - appearance' }
CFMaSettingsPresentation >> secondaryTextColor [
	^ Color r: 125 g: 125 b: 125 range: 255
]

{ #category : 'private - appearance' }
CFMaSettingsPresentation >> separatorColor [
	^ Color r: 229 g: 229 b: 229 range: 255
]

{ #category : 'private - metrics' }
CFMaSettingsPresentation >> cardCornerRadius [
	^ 12
]

{ #category : 'private - metrics' }
CFMaSettingsPresentation >> compactRowHeight [
	^ 42
]

{ #category : 'private - metrics' }
CFMaSettingsPresentation >> commentRowHeight [
	^ 58
]

{ #category : 'private - metrics' }
CFMaSettingsPresentation >> rowHorizontalInset [
	^ 10
]

{ #category : 'private - metrics' }
CFMaSettingsPresentation >> rowHorizontalSpacing [
	^ 12
]

{ #category : 'private - metrics' }
CFMaSettingsPresentation >> sectionHorizontalInset [
	^ 6
]

{ #category : 'private - composition' }
CFMaSettingsPresentation >> newFieldContainer [
	^ BrVerticalPane new
		background: self cardBackground;
		border: BlBorder empty;
		geometry: (BlRoundedRectangleGeometry cornerRadius: self cardCornerRadius);
		clipChildren: true;
		margin: BlInsets empty;
		cellSpacing: 0;
		hMatchParent;
		vFitContent;
		yourself
]

{ #category : 'private - groups' }
CFMaSettingsPresentation >> newGroupNamed: aGroup [
	| aSection aHeading aContainer |
	aHeading := BrLabel new
		text: aGroup asString;
		aptitude: (BrGlamorousLabelAptitude new
			foreground: self primaryTextColor;
			fontSize: 13;
			bold);
		fitContent;
		margin: (BlInsets
			top: 22
			right: self rowHorizontalInset
			bottom: 8
			left: self sectionHorizontalInset + self rowHorizontalInset);
		yourself.

	aContainer := self newFieldContainer.
	aContainer margin: (BlInsets left: 0 right: 0).

	aSection := BrVerticalPane new
		hMatchParent;
		vFitContent;
		margin: (BlInsets left: self sectionHorizontalInset right: self sectionHorizontalInset);
		addChild: aHeading;
		addChild: aContainer;
		yourself.

	self hostElement addChild: aSection.
	^ aContainer
]

{ #category : 'private - composition' }
CFMaSettingsPresentation >> addSeparatorTo: aContainer [
	| aSeparator |
	aSeparator := BlElement new
		background: self separatorColor;
		margin: (BlInsets left: self rowHorizontalInset right: self rowHorizontalInset);
		yourself.
	aSeparator constraintsDo: [ :c |
		c horizontal matchParent.
		c vertical exact: 1 ].
	aContainer addChild: aSeparator
]

{ #category : 'private - composition' }
CFMaSettingsPresentation >> prepareRowIn: aContainer [
	| aCount |
	aCount := rowCountsByContainer at: aContainer ifAbsent: [ 0 ].
	aCount > 0 ifTrue: [ self addSeparatorTo: aContainer ].
	rowCountsByContainer at: aContainer put: aCount + 1
]

{ #category : 'private - composition' }
CFMaSettingsPresentation >> addLabel: aLabel field: aFieldElement for: aDescription [
	self
		addLabel: aLabel
		field: aFieldElement
		for: aDescription
		to: (self containerForGroup: aDescription group)
]

{ #category : 'private - composition' }
CFMaSettingsPresentation >> addLabel: aLabel field: aFieldElement for: aDescription to: aContainer [
	| aRow aTopLine aTrailing aComment |
	self prepareRowIn: aContainer.

	aLabel
		aptitude: (BrGlamorousLabelAptitude new
			foreground: self primaryTextColor;
			fontSize: 13);
		margin: BlInsets empty.
	aLabel constraintsDo: [ :c |
		c horizontal matchParent.
		c linear weight: 1.
		c linear vertical alignCenter ].

	aTrailing := BrFrame new
		hFitContent;
		vFitContent;
		addChild: aFieldElement;
		yourself.
	aFieldElement constraintsDo: [ :c |
		c frame horizontal alignRight.
		c frame vertical alignCenter ].

	aTopLine := BrHorizontalPane new
		hMatchParent;
		vFitContent;
		cellSpacing: self rowHorizontalSpacing;
		addChild: aLabel;
		addChild: aTrailing;
		yourself.

	aRow := BrVerticalPane new
		hMatchParent;
		cellSpacing: 1;
		padding: (BlInsets
			left: self rowHorizontalInset
			right: self rowHorizontalInset);
		addChild: aTopLine;
		yourself.

	aDescription hasComment ifTrue: [
		aComment := BrLabel new
			text: aDescription comment;
			aptitude: (BrGlamorousLabelAptitude new
				foreground: self secondaryTextColor;
				fontSize: 11);
			hMatchParent;
			vFitContent;
			yourself.
		aRow addChild: aComment ].

	aRow constraintsDo: [ :c |
		c vertical exact: (aDescription hasComment
			ifTrue: [ self commentRowHeight ]
			ifFalse: [ self compactRowHeight ]) ].

	aContainer addChild: aRow
]

{ #category : 'private - composition' }
CFMaSettingsPresentation >> addElement: anElement to: aContainer [
	self prepareRowIn: aContainer.
	anElement margin: (BlInsets
		top: 6
		right: self rowHorizontalInset
		bottom: 6
		left: self rowHorizontalInset).
	anElement constraintsDo: [ :c | c horizontal matchParent ].
	aContainer addChild: anElement
]

{ #category : 'elements' }
CFMaSettingsPresentation >> addFieldElement: aFieldElement using: aDescription [
	| aLabel aText |
	aText := aDescription label asRopedText.
	aDescription isRequired ifTrue: [ aText append: '*' asRopedText ].
	aLabel := BrLabel new
		id: (GtMagritteFieldLabelId new description: aDescription);
		text: aText;
		fitContent;
		yourself.

	self configureTabStopFor: aFieldElement using: aDescription.
	self addLabel: aLabel field: aFieldElement for: aDescription.
	^ aLabel
]

{ #category : 'visiting-description' }
CFMaSettingsPresentation >> visitBooleanDescription: aDescription [
	| aBooleanElement aValidationElement |
	aBooleanElement := aDescription blocStencil
		ifNotNil: [ :aStencil |
			aStencil
				memento: self memento;
				description: aDescription;
				asElement ]
		ifNil: [
			CFMaSettingsBooleanElement new
				fieldViewModel: (GtMagritteFieldViewModel new
					memento: self memento;
					description: aDescription) ].

	aValidationElement := GtMagritteBuilderUtility
		newValidationContainerWith: aBooleanElement
		memento: self memento
		using: aDescription.

	self addFieldElement: aValidationElement using: aDescription
]
