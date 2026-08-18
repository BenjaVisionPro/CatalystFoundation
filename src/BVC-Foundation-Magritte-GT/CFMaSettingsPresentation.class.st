"I present Magritte descriptions using Foundation's settings interface language: section headings, rounded cards, contiguous rows and trailing controls."

Class {
	#name : 'CFMaSettingsPresentation',
	#superclass : 'CFMaPresentation',
	#instVars : [
		'sectionsByGroup',
		'ungroupedSection',
		'cardsBySectionAndPath',
		'focusOverlaysByContainer'
	],
	#category : 'BVC-Foundation-Magritte-GT-Presentations-Settings',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Presentations-Settings'
}

{ #category : 'initialization' }
CFMaSettingsPresentation >> initialize [
	super initialize.
	sectionsByGroup := Dictionary new.
	cardsBySectionAndPath := Dictionary new.
	focusOverlaysByContainer := IdentityDictionary new
]

{ #category : 'api - building' }
CFMaSettingsPresentation >> build [
	| anElement |
	sectionsByGroup removeAll.
	cardsBySectionAndPath removeAll.
	focusOverlaysByContainer removeAll.
	ungroupedSection := nil.
	anElement := super build.
	self hostElement background: Color white.
	^ anElement
]

{ #category : 'private - appearance' }
CFMaSettingsPresentation >> primaryTextColor [
	^ Color r: 39 g: 39 b: 39 range: 255
]

{ #category : 'private - appearance' }
CFMaSettingsPresentation >> secondaryTextColor [
	^ Color r: 125 g: 125 b: 125 range: 255
]


{ #category : 'private - composition' }
CFMaSettingsPresentation >> newFieldContainer [
	^ CFMaSettingsCardElement new
]

{ #category : 'private - groups' }
CFMaSettingsPresentation >> newSectionNamed: aGroup [
	| aSection aHeading |
	aSection := CFMaSettingsSectionElement new.
	aGroup ifNotNil: [
		aHeading := BrLabel new
			text: aGroup asString;
			aptitude: (BrGlamorousLabelAptitude new
				foreground: self primaryTextColor;
				fontSize: 13;
				bold);
			fitContent;
			margin: (BlInsets top: 22 right: 8 bottom: 8 left: 8);
			yourself.
		aSection heading: aHeading ].
	self hostElement addChild: aSection.
	^ aSection
]

{ #category : 'private - groups' }
CFMaSettingsPresentation >> sectionForGroup: aGroup [
	aGroup ifNil: [
		^ ungroupedSection ifNil: [
			ungroupedSection := self newSectionNamed: nil ] ].
	^ sectionsByGroup
		at: aGroup
		ifAbsentPut: [ self newSectionNamed: aGroup ]
]

{ #category : 'private - groups' }
CFMaSettingsPresentation >> cardForDescription: aDescription [
	| aSection aKey |
	aSection := self sectionForGroup: aDescription group.
	aKey := { aSection. aDescription path }.
	^ cardsBySectionAndPath
		at: aKey
		ifAbsentPut: [
			| aCard |
			aCard := CFMaSettingsCardElement new.
			aSection addCard: aCard.
			aCard ]
]

{ #category : 'private - groups' }
CFMaSettingsPresentation >> containerForDescription: aDescription [
	^ self cardForDescription: aDescription
]

{ #category : 'private - groups' }
CFMaSettingsPresentation >> newGroupNamed: aGroup [
	| aSection aCard |
	aSection := self sectionForGroup: aGroup.
	aCard := CFMaSettingsCardElement new.
	aSection addCard: aCard.
	^ aCard
]

{ #category : 'private - focus' }
CFMaSettingsPresentation >> focusOverlayFor: aRow in: aContainer [
	^ focusOverlaysByContainer
		at: aContainer
		ifAbsentPut: [
			| anOverlay |
			anOverlay := BlOverlayElement on: aRow.
			anOverlay
				border: BlBorder empty;
				background: Color transparent;
				zIndex: 100.
			anOverlay
				when: BlElementPositionChangedEvent
				do: [ :anEvent |
					self updateFocusOverlayGeometry: anOverlay in: aContainer ];
				when: BlElementExtentChangedEvent
				do: [ :anEvent |
					self updateFocusOverlayGeometry: anOverlay in: aContainer ].
			aContainer
				when: BlElementExtentChangedEvent
				do: [ :anEvent |
					self updateFocusOverlayGeometry: anOverlay in: aContainer ].
			aContainer addChild: anOverlay.
			anOverlay ]
]

{ #category : 'private - focus' }
CFMaSettingsPresentation >> installFocusOverlayFor: aRow in: aContainer [
	| anOverlay |
	anOverlay := self focusOverlayFor: aRow in: aContainer.

	aRow
		when: BlFocusInEvent
		do: [ :anEvent |
			anOverlay
				attachTo: aRow;
				border: (BlBorder
					paint: anOverlay theme editor focusedBorderColor
					width: 1).
			self updateFocusOverlayGeometry: anOverlay in: aContainer ];
		when: BlFocusOutEvent
		do: [ :anEvent |
			anOverlay border: BlBorder empty ]
]

{ #category : 'private - focus' }
CFMaSettingsPresentation >> updateFocusOverlayGeometry: anOverlay in: aContainer [
	| overlayBounds topRadius bottomRadius radii |
	anOverlay hasParent ifFalse: [ ^ self ].

	overlayBounds := (anOverlay bounds inParent: aContainer) asRectangle.
	topRadius := (overlayBounds top closeTo: aContainer padding top epsilon: BlElement epsilon)
		ifTrue: [ aContainer cornerRadius ]
		ifFalse: [ 0 ].
	bottomRadius := (overlayBounds bottom
		closeTo: aContainer extent y - aContainer padding bottom
		epsilon: BlElement epsilon)
		ifTrue: [ aContainer cornerRadius ]
		ifFalse: [ 0 ].

	radii := BlCornerRadii new
		topLeft: topRadius;
		topRight: topRadius;
		bottomLeft: bottomRadius;
		bottomRight: bottomRadius;
		yourself.

	anOverlay geometry: (BlRoundedRectangleGeometry cornerRadii: radii)
]

{ #category : 'private - metrics' }
CFMaSettingsPresentation >> editorTextHorizontalInset [
	^ 0
]

{ #category : 'private - composition' }
CFMaSettingsPresentation >> prepareEditorChromeIn: aFieldElement [
	| editors |
	editors := OrderedCollection new.
	(aFieldElement isKindOf: GtMagritteOneLineEditorElement)
		ifTrue: [ editors add: aFieldElement ].
	aFieldElement allChildrenBreadthFirstDo: [ :aChild |
		(aChild isKindOf: GtMagritteOneLineEditorElement)
			ifTrue: [ editors add: aChild ] ].

	editors do: [ :anEditor |
		anEditor
			addAptitude: CFMaSettingsEditorAptitude new;
			geometry: BlRectangleGeometry new;
			margin: BlInsets empty;
			padding: (BlInsets
				top: 0
				right: self editorTextHorizontalInset
				bottom: 0
				left: self editorTextHorizontalInset) ].
	^ aFieldElement
]

{ #category : 'private - composition' }
CFMaSettingsPresentation >> prepareField: aFieldElement [
	self prepareEditorChromeIn: aFieldElement.
	aFieldElement margin: BlInsets empty.
	(aFieldElement isKindOf: CFMaSettingsBooleanElement)
		ifFalse: [ aFieldElement padding: BlInsets empty ].
	^ aFieldElement
]

{ #category : 'private - composition' }
CFMaSettingsPresentation >> newRowFor: aDescription field: aFieldElement multiline: aBoolean [
	| aRow metadata |
	metadata := aDescription fieldMetadataFor: self memento model.
	aRow := CFMaSettingsRowElement new.
	aRow
		icon: (metadata icon ifNotNil: [ :anIcon |
			CFIconTile new
				icon: anIcon;
				backgroundColor: metadata iconBackground;
				beMedium;
				yourself ])
		label: (self newFieldLabelFor: aDescription)
		comment: (aDescription hasComment
			ifTrue: [ self newCommentFor: aDescription ]
			ifFalse: [ nil ])
		field: (self prepareField: aFieldElement)
		multiline: aBoolean.
	^ aRow
]

{ #category : 'private - composition' }
CFMaSettingsPresentation >> addRow: aRow for: aDescription [
	| aCard |
	aCard := self cardForDescription: aDescription.
	aCard addRow: aRow.
	self installFocusOverlayFor: aRow in: aCard
]

{ #category : 'private - composition' }
CFMaSettingsPresentation >> newCommentFor: aDescription [
	^ BrEditor new
		aptitude: BrGlamorousRegularEditorAptitude new;
		beReadOnlyWithoutSelection;
		focusability: BlFocusability none;
		text: (aDescription comment asRopedText
			foreground: self secondaryTextColor;
			fontSize: 11);
		hMatchParent;
		vFitContent;
		background: Color transparent;
		border: BlBorder empty;
		padding: BlInsets empty;
		margin: (BlInsets
			top: 1
			right: 0
			bottom: 0
			left: 0.5);
		yourself
]

{ #category : 'private - composition' }
CFMaSettingsPresentation >> addElement: anElement for: aDescription [
	| aRow |
	aRow := CFMaSettingsRowElement new.
	aRow
		icon: nil
		label: nil
		comment: nil
		field: anElement
		multiline: false.
	self addRow: aRow for: aDescription
]

{ #category : 'private - composition' }
CFMaSettingsPresentation >> addElement: anElement to: aContainer [
	| aRow |
	aRow := CFMaSettingsRowElement new.
	aRow
		icon: nil
		label: nil
		comment: nil
		field: anElement
		multiline: false.
	aContainer addRow: aRow
]

{ #category : 'elements' }
CFMaSettingsPresentation >> addFieldElement: aFieldElement using: aDescription [
	self configureTabStopFor: aFieldElement using: aDescription.
	self
		addRow: (self
			newRowFor: aDescription
			field: aFieldElement
			multiline: false)
		for: aDescription.
	^ aFieldElement
]

{ #category : 'private - building' }
CFMaSettingsPresentation >> addMemoFieldUsing: aDescription [
	| anEditor aCompletionStrategy |
	anEditor := BrEditor new
		inputFilter: BrTextEditorNoInputFilter new;
		aptitude: (aDescription editorAptitude
			ifNil: [ BrGlamorousRegularEditorAptitude new glamorousRegularFontAndSize ]
			ifNotNil: #value);
		hMatchParent;
		vFitContent;
		padding: BlInsets empty;
		margin: BlInsets empty;
		yourself.
	anEditor editor segmentBuilder splitter:
		(BrTextEditorSplitter new
			segmentClass: CFMaSettingsRightAlignedParagraphSegment;
			yourself).
	anEditor
		focusability: BlFocusability block;
		when: BlFocusInEvent
		do: [ :anEvent | anEditor selecter all select ];
		when: BlFocusOutEvent
		do: [ :anEvent | anEditor deselecter all deselect ].
	self installFormNavigationOn: anEditor.

	aDescription isReadOnly
		ifTrue: [ anEditor beReadOnlyWithSelection ]
		ifFalse: [ anEditor beEditable ].

	anEditor
		withAsyncSinkDo: [ :anElementSink |
			anElementSink
				sink: AsyncPeekSink new;
				whenUpdate: [ :theEditor :aSink |
					| aValue aText |
					aValue := aSink value currentValue.
					aText := aValue ifNil: [ '' ] ifNotNil: [ aValue asString ].
					theEditor text characters = aText asRopedText characters
						ifFalse: [ theEditor text: aText ] ].
			(self memento readObservableValueUsing: aDescription) observe: anElementSink ].

	aDescription isReadOnly ifFalse: [
		anEditor editor
			when: BrTextEditorModifiedEvent
			do: [ :anEvent |
				GtMagritteBuilderUtility
					writeText: anEvent text
					using: aDescription
					memento: self memento
					element: anEditor ] ].

	self addShortcutsTo: anEditor using: aDescription.

	aDescription blocCompletion ifNotNil: [ :aStencil |
		aCompletionStrategy := aStencil
			memento: self memento;
			description: aDescription;
			build.
		(GtCompletionController
			on: anEditor
			strategy: aCompletionStrategy) install ].

	self
		addRow: (self
			newRowFor: aDescription
			field: anEditor
			multiline: true)
		for: aDescription.
	^ anEditor
]

{ #category : 'private - composition' }
CFMaSettingsPresentation >> newFieldLabelFor: aDescription [
	| aLabel aText |
	aText := aDescription label asRopedText.
	aDescription isRequired ifTrue: [ aText append: '*' asRopedText ].
	aLabel := BrLabel new
		id: (GtMagritteFieldLabelId new description: aDescription);
		text: aText;
		aptitude: (BrGlamorousLabelAptitude new
			glamorousRegularFontAndSize;
			foreground: self primaryTextColor;
			padding: BlInsets empty);
		margin: BlInsets empty;
		fitContent;
		yourself.
	^ aLabel
]

{ #category : 'visiting-description' }
CFMaSettingsPresentation >> visitMemoDescription: aDescription [
	self addMemoFieldUsing: aDescription
]

{ #category : 'visiting-description' }
CFMaSettingsPresentation >> visitBooleanDescription: aDescription [
	| aBooleanElement |
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

	self addFieldElement: aBooleanElement using: aDescription
]
