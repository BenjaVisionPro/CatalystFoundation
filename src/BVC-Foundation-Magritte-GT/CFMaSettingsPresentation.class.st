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
	rowCountsByContainer removeAll.
	^ super build
]

{ #category : 'private - appearance' }
CFMaSettingsPresentation >> cardBackground [
	^ Color r: 247 g: 247 b: 247 range: 255
]

{ #category : 'private - appearance' }
CFMaSettingsPresentation >> primaryTextColor [
	^ Color r: 36 g: 36 b: 38 range: 255
]

{ #category : 'private - appearance' }
CFMaSettingsPresentation >> secondaryTextColor [
	^ Color r: 128 g: 128 b: 128 range: 255
]

{ #category : 'private - appearance' }
CFMaSettingsPresentation >> separatorColor [
	^ Color r: 224 g: 224 b: 224 range: 255
]

{ #category : 'private - composition' }
CFMaSettingsPresentation >> newFieldContainer [
	^ BrVerticalPane new
		background: self cardBackground;
		border: BlBorder empty;
		geometry: (BlRoundedRectangleGeometry cornerRadius: 16);
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
			fontSize: 15;
			bold);
		fitContent;
		margin: (BlInsets top: 24 right: 16 bottom: 10 left: 16);
		yourself.

	aContainer := self newFieldContainer.
	aContainer margin: (BlInsets left: 0 right: 0).

	aSection := BrVerticalPane new
		hMatchParent;
		vFitContent;
		margin: (BlInsets left: 12 right: 12);
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
		hMatchParent;
		vExact: 1;
		margin: (BlInsets left: 16 right: 16);
		yourself.
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
CFMaSettingsPresentation >> newLeadingContentFor: aDescription label: aLabel [
	| aLeading aComment |
	aLabel
		aptitude: (BrGlamorousLabelAptitude new
			foreground: self primaryTextColor;
			fontSize: 15);
		margin: BlInsets empty.

	aLeading := BrVerticalPane new
		hMatchParent;
		vFitContent;
		cellSpacing: 2;
		addChild: aLabel;
		yourself.

	aDescription hasComment ifTrue: [
		aComment := BrLabel new
			text: aDescription comment;
			aptitude: (BrGlamorousLabelAptitude new
				foreground: self secondaryTextColor;
				fontSize: 12);
			hMatchParent;
			vFitContent;
			yourself.
		aLeading addChild: aComment ].

	^ aLeading
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
	| aRow aLeading aTrailing |
	self prepareRowIn: aContainer.

	aLeading := self newLeadingContentFor: aDescription label: aLabel.
	aLeading constraintsDo: [ :c |
		c horizontal matchParent.
		c linear horizontal weight: 1.
		c linear vertical alignCenter ].

	aTrailing := BrFrame new
		hFitContent;
		vFitContent;
		addChild: aFieldElement;
		yourself.
	aFieldElement constraintsDo: [ :c |
		c frame horizontal alignRight.
		c frame vertical alignCenter ].

	aRow := BrHorizontalPane new
		hMatchParent;
		vFitContent;
		padding: (BlInsets top: 11 right: 16 bottom: 11 left: 16);
		cellSpacing: 16;
		addChild: aLeading;
		addChild: aTrailing;
		yourself.

	aContainer addChild: aRow
]

{ #category : 'private - composition' }
CFMaSettingsPresentation >> addElement: anElement to: aContainer [
	self prepareRowIn: aContainer.
	anElement
		hMatchParent;
		margin: (BlInsets top: 10 right: 16 bottom: 10 left: 16).
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
