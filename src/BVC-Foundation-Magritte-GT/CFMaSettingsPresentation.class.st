"I present Magritte descriptions using Foundation's settings interface language: section headings, rounded cards, contiguous rows and trailing controls."

Class {
	#name : 'CFMaSettingsPresentation',
	#superclass : 'CFMaPresentation',
	#instVars : [
		'rowCountsByContainer',
		'sectionsByGroup',
		'ungroupedSection',
		'cardCountsBySection',
		'currentGroup',
		'currentPath',
		'currentPathContainer',
		'focusOverlaysByContainer'
	],
	#category : 'BVC-Foundation-Magritte-GT-Presentations-Settings',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Presentations-Settings'
}

{ #category : 'initialization' }
CFMaSettingsPresentation >> initialize [
	super initialize.
	rowCountsByContainer := IdentityDictionary new.
	sectionsByGroup := Dictionary new.
	cardCountsBySection := IdentityDictionary new.
	focusOverlaysByContainer := IdentityDictionary new
]

{ #category : 'api - building' }
CFMaSettingsPresentation >> build [
	| anElement |
	rowCountsByContainer removeAll.
	sectionsByGroup removeAll.
	cardCountsBySection removeAll.
	focusOverlaysByContainer removeAll.
	ungroupedSection := nil.
	currentGroup := nil.
	currentPath := nil.
	currentPathContainer := nil.
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
CFMaSettingsPresentation >> rowHorizontalInset [
	^ 8
]

{ #category : 'private - metrics' }
CFMaSettingsPresentation >> rowBottomInset [
	^ 7
]

{ #category : 'private - metrics' }
CFMaSettingsPresentation >> rowTopInset [
	^ 4
]

{ #category : 'private - metrics' }
CFMaSettingsPresentation >> fieldBaselineOffset [
	^ 1
]

{ #category : 'private - metrics' }
CFMaSettingsPresentation >> editorTextHorizontalInset [
	"Match BrEditor>>initialize horizontal text padding without affecting memo vertical alignment."
	^ 5
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
CFMaSettingsPresentation >> newSectionNamed: aGroup [
	| aSection aHeading aBody |
	aBody := BrVerticalPane new
		hMatchParent;
		vFitContent;
		margin: BlInsets empty;
		yourself.

	aSection := BrVerticalPane new
		hMatchParent;
		vFitContent;
		margin: (BlInsets
			left: self sectionHorizontalInset
			right: self sectionHorizontalInset);
		yourself.

	aGroup ifNotNil: [
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
				left: self rowHorizontalInset);
			yourself.
		aSection addChild: aHeading ].

	aSection addChild: aBody.
	self hostElement addChild: aSection.
	^ aBody
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
CFMaSettingsPresentation >> newPathContainerFor: aPath in: aSection [
	| aContainer aCount |
	aContainer := self newFieldContainer.
	aCount := cardCountsBySection at: aSection ifAbsent: [ 0 ].
	aCount > 0 ifTrue: [
		aContainer margin: (BlInsets top: 10) ].
	cardCountsBySection at: aSection put: aCount + 1.
	aSection addChild: aContainer.
	^ aContainer
]

{ #category : 'private - groups' }
CFMaSettingsPresentation >> containerForDescription: aDescription [
	| aGroup aPath aSection |
	aGroup := aDescription group.
	aPath := aDescription path.

	((currentGroup = aGroup)
		and: [ (currentPath = aPath)
			and: [ currentPathContainer isNotNil ] ])
		ifTrue: [ ^ currentPathContainer ].

	aSection := self sectionForGroup: aGroup.
	currentGroup := aGroup.
	currentPath := aPath copy.
	currentPathContainer := self
		newPathContainerFor: aPath
		in: aSection.
	^ currentPathContainer
]

{ #category : 'private - groups' }
CFMaSettingsPresentation >> newGroupNamed: aGroup [
	"Compatibility with the inherited group API. Settings rendering normally
	enters through #containerForDescription: so description paths can choose cards."
	^ self
		newPathContainerFor: #()
		in: (self sectionForGroup: aGroup)
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
	topRadius := (overlayBounds top closeTo: 0 epsilon: BlElement epsilon)
		ifTrue: [ self cardCornerRadius ]
		ifFalse: [ 0 ].
	bottomRadius := (overlayBounds bottom closeTo: aContainer extent y epsilon: BlElement epsilon)
		ifTrue: [ self cardCornerRadius ]
		ifFalse: [ 0 ].

	radii := BlCornerRadii new
		topLeft: topRadius;
		topRight: topRadius;
		bottomLeft: bottomRadius;
		bottomRight: bottomRadius;
		yourself.

	anOverlay geometry: (BlRoundedRectangleGeometry cornerRadii: radii)
]

{ #category : 'private - composition' }
CFMaSettingsPresentation >> addSeparatorTo: aContainer [
	| aSeparator aSeparatorFrame |
	aSeparator := BlElement new
		background: self separatorColor;
		yourself.
	aSeparator constraintsDo: [ :c |
		c horizontal matchParent.
		c vertical exact: 1.
		c frame horizontal alignCenter.
		c frame vertical alignCenter ].

	aSeparatorFrame := BrFrame new
		hMatchParent;
		vExact: 1;
		padding: (BlInsets
			left: self rowHorizontalInset
			right: self rowHorizontalInset + self editorTextHorizontalInset);
		addChild: aSeparator;
		yourself.

	aContainer addChild: aSeparatorFrame
]

{ #category : 'private - composition' }
CFMaSettingsPresentation >> prepareRowIn: aContainer [
	| aCount |
	aCount := rowCountsByContainer at: aContainer ifAbsent: [ 0 ].
	aCount > 0 ifTrue: [ self addSeparatorTo: aContainer ].
	rowCountsByContainer at: aContainer put: aCount + 1
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
			when: BlFocusInEvent
			do: [ :anEvent | anEditor deselecter all deselect ] ].
	^ aFieldElement
]

{ #category : 'private - composition' }
CFMaSettingsPresentation >> prepareTrailingField: aFieldElement [
	"GT's normal form renderers may add outer margins for grid presentation.
	The settings row owns the outer positioning, so its trailing root starts
	and ends exactly on the row content bounds."
	self prepareEditorChromeIn: aFieldElement.
	aFieldElement margin: (BlInsets top: self fieldBaselineOffset).
	(aFieldElement isKindOf: CFMaSettingsBooleanElement)
		ifTrue: [ aFieldElement margin: BlInsets empty ].
	aFieldElement allChildrenBreadthFirstDo: [ :aChild |
		(aChild isKindOf: GtMagritteOneLineEditorElement)
			ifTrue: [ aChild margin: BlInsets empty ] ].
	^ aFieldElement
]

{ #category : 'private - composition' }
CFMaSettingsPresentation >> addMemoLabel: aLabel field: aFieldElement for: aDescription to: aContainer [
	| aRow aTopLine aLabelColumn aFieldColumn aComment updateArrangement |
	self prepareRowIn: aContainer.

	aLabel
		aptitude: (BrGlamorousLabelAptitude new
			foreground: self primaryTextColor;
			fontSize: 13;
			padding: BlInsets empty);
		margin: BlInsets empty;
		fitContent.

	aLabelColumn := BrVerticalPane new
		hFitContent;
		vFitContent;
		addChild: aLabel;
		yourself.

	aDescription hasComment ifTrue: [
		aComment := self newCommentFor: aDescription ].

	aFieldElement
		hMatchParent;
		vFitContent;
		margin: BlInsets empty;
		padding: (BlInsets right: self editorTextHorizontalInset).

	aFieldColumn := BrFrame new
		hMatchParent;
		vFitContent;
		padding: (BlInsets left: 12);
		addChild: aFieldElement;
		yourself.
	aFieldColumn constraintsDo: [ :c |
		c linear weight: 1.
		c linear vertical alignTop ].
	aFieldElement constraintsDo: [ :c |
		c frame vertical alignTop ].

	aTopLine := BrHorizontalPane new
		hMatchParent;
		vFitContent;
		addChild: aLabelColumn;
		addChild: aFieldColumn;
		yourself.

	aRow := BrVerticalPane new
		hMatchParent;
		vFitContent;
		addAptitude: CFMaActiveSelectionAptitude new;
		addAptitude: CFMaSettingsRowAptitude new;
		padding: (BlInsets
			top: self rowTopInset
			left: self rowHorizontalInset
			bottom: self rowBottomInset
			right: self rowHorizontalInset);
		addChild: aTopLine;
		yourself.

	aComment ifNotNil: [ aRow addChild: aComment ].

	updateArrangement := [
		(self memoEditorIsWrapped: aFieldElement)
			ifTrue: [
				self
					arrangeWrappedMemoRow: aRow
					labelColumn: aLabelColumn
					fieldColumn: aFieldColumn
					comment: aComment ]
			ifFalse: [
				self
					arrangeCompactMemoRow: aRow
					labelColumn: aLabelColumn
					fieldColumn: aFieldColumn
					comment: aComment ] ].

	aFieldElement
		when: BlElementExtentChangedEvent
		do: [ :anEvent |
			aRow enqueueTask: (BlTaskAction new action: updateArrangement) ].

	aContainer addChild: aRow.
	self installFocusOverlayFor: aRow in: aContainer.
	aRow enqueueTask: (BlTaskAction new action: updateArrangement)
]


{ #category : 'private - composition' }
CFMaSettingsPresentation >> arrangeCompactMemoRow: aRow labelColumn: aLabelColumn fieldColumn: aFieldColumn comment: aComment [
	aComment ifNotNil: [
		aComment hasParent ifTrue: [
			aComment parent == aRow ifFalse: [
				aComment parent removeChild: aComment.
				aRow addChild: aComment ] ] ].

	aLabelColumn
		hFitContent;
		padding: BlInsets empty;
		constraintsDo: [ :c |
			c linear weight: 0.
			c linear vertical alignTop ].

	aFieldColumn
		padding: (BlInsets left: 12);
		constraintsDo: [ :c |
			c linear weight: 1.
			c linear vertical alignTop ]
]

{ #category : 'private - composition' }
CFMaSettingsPresentation >> arrangeWrappedMemoRow: aRow labelColumn: aLabelColumn fieldColumn: aFieldColumn comment: aComment [
	aComment ifNotNil: [
		aComment hasParent ifTrue: [
			aComment parent == aLabelColumn ifFalse: [
				aComment parent removeChild: aComment.
				aLabelColumn addChild: aComment ] ] ].

	aLabelColumn
		hMatchParent;
		padding: (BlInsets right: 6);
		constraintsDo: [ :c |
			c linear weight: 1.
			c linear vertical alignTop ].

	aFieldColumn
		padding: (BlInsets left: 6);
		constraintsDo: [ :c |
			c linear weight: 1.
			c linear vertical alignTop ]
]

{ #category : 'private - composition' }
CFMaSettingsPresentation >> memoEditorIsWrapped: anEditor [
	| paragraphElements |
	paragraphElements := anEditor allChildrenBreadthFirstSelect: [ :each |
		each isKindOf: CFMaSettingsRightAlignedParagraphElement ].

	paragraphElements isEmpty ifTrue: [ ^ false ].
	paragraphElements size > 1 ifTrue: [ ^ true ].
	^ paragraphElements first visualLineCount > 1
]

{ #category : 'private - composition' }
CFMaSettingsPresentation >> newCommentFor: aDescription [
	^ BrEditor new
		aptitude: BrGlamorousRegularEditorAptitude new;
		beReadOnlyWithoutSelection;
		text: (aDescription comment asRopedText
			foreground: self secondaryTextColor;
			fontSize: 11);
		hMatchParent;
		vFitContent;
		background: Color transparent;
		border: BlBorder empty;
		padding: BlInsets empty;
		margin: (BlInsets top: 1);
		yourself
]

{ #category : 'private - composition' }
CFMaSettingsPresentation >> addLabel: aLabel field: aFieldElement for: aDescription [
	self
		addLabel: aLabel
		field: aFieldElement
		for: aDescription
		to: (self containerForDescription: aDescription)
]

{ #category : 'private - composition' }
CFMaSettingsPresentation >> addLabel: aLabel field: aFieldElement for: aDescription to: aContainer [
	| aRow aLeading aTrailing aComment |
	self prepareRowIn: aContainer.

	aLabel
		aptitude: (BrGlamorousLabelAptitude new
			foreground: self primaryTextColor;
			fontSize: 13;
			padding: BlInsets empty);
		margin: BlInsets empty;
		fitContent.

	aLeading := BrVerticalPane new
		hMatchParent;
		vFitContent;
		addChild: aLabel;
		yourself.

	aDescription hasComment ifTrue: [
		aComment := self newCommentFor: aDescription.
		aLeading addChild: aComment ].

	self prepareTrailingField: aFieldElement.

	aTrailing := BrFrame new
		hFitContent;
		vFitContent;
		margin: BlInsets empty;
		padding: BlInsets empty;
		addChild: aFieldElement;
		yourself.
	aFieldElement constraintsDo: [ :c |
		c frame horizontal alignRight.
		c frame vertical alignCenter ].
	aTrailing constraintsDo: [ :c |
		c ignoreByLayout.
		c ignored horizontal alignRight.
		(aFieldElement isKindOf: CFMaSettingsBooleanElement)
			ifTrue: [ c ignored vertical alignCenter ]
			ifFalse: [ c ignored vertical alignTop ] ].

	aRow := BrFrame new
		hMatchParent;
		vFitContent;
		addAptitude: CFMaActiveSelectionAptitude new;
		addAptitude: CFMaSettingsRowAptitude new;
		padding: (BlInsets
			top: self rowTopInset
			left: self rowHorizontalInset
			bottom: self rowBottomInset
			right: self rowHorizontalInset);
		addChild: aLeading;
		addChild: aTrailing;
		yourself.
	aLeading constraintsDo: [ :c |
		c frame horizontal alignLeft.
		c frame vertical alignTop ].

	aContainer addChild: aRow.
	self installFocusOverlayFor: aRow in: aContainer
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
	| aLabel |
	aLabel := self newFieldLabelFor: aDescription.
	self configureTabStopFor: aFieldElement using: aDescription.
	self addLabel: aLabel field: aFieldElement for: aDescription.
	^ aLabel
]

{ #category : 'private - building' }
CFMaSettingsPresentation >> addMemoFieldUsing: aDescription [
	| anEditor aLabel aCompletionStrategy |
	anEditor := BrEditor new
		inputFilter: BrTextEditorNoInputFilter new;
		aptitude: (aDescription editorAptitude
			ifNil: [ BrGlamorousRegularEditorAptitude new fontSize: 13 ]
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

	aLabel := self newFieldLabelFor: aDescription.
	self configureTabStopFor: anEditor using: aDescription.
	self
		addMemoLabel: aLabel
		field: anEditor
		for: aDescription
		to: (self containerForDescription: aDescription).
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
