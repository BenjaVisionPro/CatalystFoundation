"
I present Magritte descriptions using Foundation's settings interface language: section headings, rounded cards, contiguous rows and trailing controls.
"
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

{ #category : 'private - composition' }
CFMaSettingsPresentation >> addElement: anElement for: aDescription [
	| aRow |
	aRow := CFMaSettingsRowElement new.
	aRow
		icon: nil
		label: nil
		comment: nil
		field: anElement
		trailingActions: #().
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
		trailingActions: #().
	aContainer addRow: aRow
]

{ #category : 'elements' }
CFMaSettingsPresentation >> addFieldElement: aFieldElement using: aDescription [
	self configureTabStopFor: aFieldElement using: aDescription.
	self
		addRow: (self
			newRowFor: aDescription
			field: aFieldElement)
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
			field: anEditor)
		for: aDescription.
	^ anEditor
]

{ #category : 'private - composition' }
CFMaSettingsPresentation >> addRow: aRow for: aDescription [
	| aCard |
	aCard := self cardForDescription: aDescription.
	aCard addRow: aRow.
	self installFocusOverlayFor: aRow in: aCard
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

{ #category : 'private - groups' }
CFMaSettingsPresentation >> cardForDescription: aDescription [
	| aSection aKey |
	aSection := self sectionForGroup: aDescription group.
	aKey := { aSection. aDescription categories }.
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

{ #category : 'private - metrics' }
CFMaSettingsPresentation >> editorTextHorizontalInset [
	^ 0
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

{ #category : 'initialization' }
CFMaSettingsPresentation >> initialize [
	super initialize.
	sectionsByGroup := Dictionary new.
	cardsBySectionAndPath := Dictionary new.
	focusOverlaysByContainer := IdentityDictionary new
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
					paint: self form theme highlight color
					width: 1).
			self updateFocusOverlayGeometry: anOverlay in: aContainer ];
		when: BlFocusOutEvent
		do: [ :anEvent |
			anOverlay border: BlBorder empty ]
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

{ #category : 'configuration - fields' }
CFMaSettingsPresentation >> newFieldConfiguration [
	| aConfiguration |
	aConfiguration := super newFieldConfiguration.
	aConfiguration icon
		beMedium;
		beChromed.
	^ aConfiguration
]

{ #category : 'private - composition' }
CFMaSettingsPresentation >> newFieldContainer [
	^ CFMaSettingsCardElement new
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

{ #category : 'private - groups' }
CFMaSettingsPresentation >> newGroupNamed: aGroup [
	| aSection aCard |
	aSection := self sectionForGroup: aGroup.
	aCard := CFMaSettingsCardElement new.
	aSection addCard: aCard.
	^ aCard
]

{ #category : 'private - row actions' }
CFMaSettingsPresentation >> newInformationActionFor: information [
	| aButton |
	aButton := self newRowActionButtonIconNamed: #infoCircle.
	aButton
		hExact: 12;
		icon: (aButton icon size: 12 @ 12);
		label: information asString.
	^ aButton
]

{ #category : 'private - row actions' }
CFMaSettingsPresentation >> newRevertActionFor: aDescription [
	| aButton |
	aButton := self newRowActionButtonIconNamed: #undo.
	aButton
		hExact: 12;
		icon: (aButton icon size: 12 @ 12).
	aButton
		label: 'Revert to saved value';
		action: [ self memento revertUsing: aDescription ];
		visibility: BlVisibility gone.
	aButton withAsyncSinkDo: [ :anElementSink |
		anElementSink
			sink: AsyncPeekSink new;
			whenUpdate: [ :anElement :aSink |
				aSink value isChanged
					ifTrue: [ anElement visibility: BlVisibility visible ]
					ifFalse: [ anElement visibility: BlVisibility gone ] ].
		(self memento readObservableValueUsing: aDescription) observe: anElementSink ].
	^ aButton
]

{ #category : 'private - row actions' }
CFMaSettingsPresentation >> newRowActionButtonIconNamed: anIconName [
	| anIcon |
	anIcon := FontAwesomeIcons defaultStyle icon: anIconName.
	anIcon
		color: (Color black alpha: 0.48);
		size: 16 @ 16.
	^ BrButton new
		aptitude: BrGlamorousButtonIconAptitude new
			+ BrGlamorousButtonWithLabelTooltipAptitude2 new;
		icon: anIcon;
		background: Color transparent;
		border: BlBorder empty;
		padding: BlInsets empty;
		alignCenterRight;
		hExact: 16;
		vExact: 24;
		yourself
]

{ #category : 'private - row actions' }
CFMaSettingsPresentation >> newRowActionsFor: aDescription [
	| theActions information |
	theActions := OrderedCollection new.
	aDescription isWithChangeIndicator ifTrue: [
		theActions add: (self newRevertActionFor: aDescription) ].
	theActions add: (self newValidationActionFor: aDescription).
	information := aDescription informationFor: self memento model.
	information ifNotNil: [
		theActions add: (self newInformationActionFor: information) ].
	^ theActions
]

{ #category : 'private - composition' }
CFMaSettingsPresentation >> newRowFor: aDescription field: aFieldElement [
	| aRow anIcon aFieldConfiguration |
	aFieldConfiguration := self fieldConfigurationFor: aDescription.
	anIcon := aDescription iconFor: self memento model.
	aRow := CFMaSettingsRowElement new.
	aRow
		icon: (anIcon ifNotNil: [ | aTile |
			aTile := CFIconTile new
				icon: anIcon;
				backgroundColor: aFieldConfiguration icon backgroundColor;
				yourself.
			aFieldConfiguration icon isSmall ifTrue: [ aTile beSmall ].
			aFieldConfiguration icon isMedium ifTrue: [ aTile beMedium ].
			aFieldConfiguration icon isLarge ifTrue: [ aTile beLarge ].
			aTile ])
		label: (self newFieldLabelFor: aDescription)
		comment: (aDescription hasComment
			ifTrue: [ self newCommentFor: aDescription ]
			ifFalse: [ nil ])
		field: (self prepareField: aFieldElement)
		trailingActions: (self newRowActionsFor: aDescription).
	^ aRow
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
				fontSize: 14;
				bold);
			fitContent;
			margin: (BlInsets top: 22 right: 8 bottom: 2 left: 8);
			yourself.
		aSection heading: aHeading ].
	self hostElement addChild: aSection.
	^ aSection
]

{ #category : 'private - row actions' }
CFMaSettingsPresentation >> newValidationActionFor: aDescription [
	| aButton |
	aButton := self newRowActionButtonIconNamed: #exclamationTriangle.
	aButton
		hExact: 12;
		icon: (aButton icon size: 12 @ 12);
		label: 'Validation failed';
		visibility: BlVisibility gone.
	aButton withAsyncSinkDo: [ :anElementSink |
		anElementSink
			sink: AsyncPeekSink new;
			whenUpdate: [ :anElement :aSink |
				| aValidationResult |
				aValidationResult := aSink value.
				aValidationResult isSuccess
					ifTrue: [ anElement visibility: BlVisibility gone ]
					ifFalse: [ anElement
						label: aValidationResult issuesDescription;
						visibility: BlVisibility visible ] ].
		(self memento validatorUsing: aDescription) observe: anElementSink ].
	^ aButton
]

{ #category : 'private - composition' }
CFMaSettingsPresentation >> prepareEditorChromeIn: aFieldElement [
	| editors |
	editors := OrderedCollection new.
	(aFieldElement isKindOf: BrEditor)
		ifTrue: [ editors add: aFieldElement ].
	aFieldElement allChildrenBreadthFirstDo: [ :aChild |
		(aChild isKindOf: BrEditor)
			ifTrue: [ editors add: aChild ] ].

	editors do: [ :anEditor |
		(anEditor isKindOf: GtMagritteOneLineEditorElement)
			ifTrue: [ anEditor addAptitude: CFMaRowEditorAptitude new ].
		anEditor
			geometry: BlRectangleGeometry new;
			margin: BlInsets empty;
			padding: (BlInsets
				top: 0
				right: self editorTextHorizontalInset
				bottom: 0
				left: self editorTextHorizontalInset).
		anEditor constraintsDo: [ :c | c minWidth: 0 ] ].
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

{ #category : 'private - appearance' }
CFMaSettingsPresentation >> primaryTextColor [
	^ Color r: 39 g: 39 b: 39 range: 255
]

{ #category : 'private - appearance' }
CFMaSettingsPresentation >> secondaryTextColor [
	^ Color r: 125 g: 125 b: 125 range: 255
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

{ #category : 'visiting-description' }
CFMaSettingsPresentation >> visitMemoDescription: aDescription [
	self addMemoFieldUsing: aDescription
]
