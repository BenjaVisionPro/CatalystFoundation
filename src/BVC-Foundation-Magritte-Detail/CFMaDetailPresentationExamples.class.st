Class {
	#name : 'CFMaDetailPresentationExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Magritte-Detail-Examples',
	#package : 'BVC-Foundation-Magritte-Detail',
	#tag : 'Examples'
}

{ #category : 'examples - actions' }
CFMaDetailPresentationExamples >> actionDescriptionUsesFoundationPlacement [
	<gtExample>
	| anAction |
	anAction := MAActionDescription new
		label: 'Store in iCloud';
		comment: 'Only store the most recent messages on this Mac.';
		group: 'General';
		categories: #(storage);
		priority: 40;
		action: [ :aModel | aModel ];
		yourself.

	self assert: anAction group equals: 'General'.
	self assert: anAction categories equals: #(storage).
	self assert: anAction priority equals: 40.
	^ anAction
]

{ #category : 'examples' }
CFMaDetailPresentationExamples >> descriptionCategories [
	<gtExample>
	| aDescription |
	aDescription := MAStringDescription new
		categories: #(main extension);
		yourself.

	self assert: aDescription categories equals: #(main extension).
	^ aDescription
]

{ #category : 'examples' }
CFMaDetailPresentationExamples >> configuredGroupHierarchy [
	<gtExample>
	| aPresentation aGeneral aMain anExtension |
	aPresentation := CFMaDetailPresentation new
		group: 'General' configure: [ :general |
			general category: #main configure: [ :main |
				main category: #extension configure: [ :extension | ] ] ];
		yourself.

	aGeneral := aPresentation groupConfigurationFor: 'General'.
	aMain := aGeneral categoryConfigurationFor: #main.
	anExtension := aMain categoryConfigurationFor: #extension.

	self assert: aGeneral class equals: CFMaDetailGroupConfiguration.
	self assert: aMain class equals: CFMaDetailGroupConfiguration.
	self assert: anExtension class equals: CFMaDetailGroupConfiguration.
	self assert: aGeneral ~~ aMain.
	self assert: aMain ~~ anExtension.
	^ aPresentation
]

{ #category : 'examples' }
CFMaDetailPresentationExamples >> groupConfigurationsAreCreatedLazily [
	<gtExample>
	| aPresentation aGeneral firstMain secondMain |
	aPresentation := CFMaDetailPresentation new.
	aGeneral := aPresentation groupConfigurationFor: 'General'.
	firstMain := aGeneral categoryConfigurationFor: #main.
	secondMain := aGeneral categoryConfigurationFor: #main.

	self assert: firstMain == secondMain.
	self assert: firstMain class equals: CFMaDetailGroupConfiguration.
	^ aPresentation
]

{ #category : 'examples' }
CFMaDetailPresentationExamples >> groupCanPresentChildrenAsTabs [
	<gtExample>
	| aConfiguration aTabs |
	aConfiguration := CFMaDetailGroupConfiguration new.
	aTabs := aConfiguration beTabs.

	self assert: aTabs class equals: CFMaDetailTabsConfiguration.
	self assert: aConfiguration presentation == aTabs.
	^ aConfiguration
]

{ #category : 'examples' }
CFMaDetailPresentationExamples >> groupCanPresentChildrenAsButtonBar [
	<gtExample>
	| aConfiguration aButtonBar |
	aConfiguration := CFMaDetailGroupConfiguration new.
	aButtonBar := aConfiguration beButtonBar.

	self assert: aButtonBar class equals: CFMaDetailButtonBarConfiguration.
	self assert: aConfiguration presentation == aButtonBar.
	^ aConfiguration
]

{ #category : 'examples' }
CFMaDetailPresentationExamples >> groupCanPresentChildrenAsIconButtonBar [
	<gtExample>
	| aConfiguration aButtonBar |
	aConfiguration := CFMaDetailGroupConfiguration new.
	aButtonBar := aConfiguration beIconButtonBar.

	self assert: aButtonBar class equals: CFMaDetailButtonBarConfiguration.
	self assert: aButtonBar isIconOnly.
	self assert: aConfiguration presentation == aButtonBar.
	^ aConfiguration
]



{ #category : 'examples - layout' }
CFMaDetailPresentationExamples >> groupCanReserveAccessorySlots [
	<gtExample>
	| aConfiguration |
	aConfiguration := CFMaDetailGroupConfiguration new.

	self assert: aConfiguration reservedAccessorySlots equals: 0.
	aConfiguration reserveAccessorySlots: 3.
	self assert: aConfiguration reservedAccessorySlots equals: 3.
	^ aConfiguration
]

{ #category : 'examples - layout' }
CFMaDetailPresentationExamples >> groupCardAppliesAccessoryReservationToRows [
	<gtExample>
	| aCard firstRow secondRow |
	aCard := CFMaDetailGroupCardElement new reservedAccessorySlots: 2; yourself.
	firstRow := BlElement new layout: CFMaDetailRowLayout new; yourself.
	secondRow := BlElement new layout: CFMaDetailRowLayout new; yourself.

	aCard addChild: firstRow.
	aCard addChild: secondRow.

	self assert: firstRow layout reservedAccessorySlots equals: 2.
	self assert: secondRow layout reservedAccessorySlots equals: 2.
	self assert: firstRow layout reservedAccessoriesWidth equals: 36.0.
	^ aCard
]

{ #category : 'examples - layout' }
CFMaDetailPresentationExamples >> detailRowUsesTypedLayoutConstraints [
	<gtExample>
	| aRow aLabel aContent aLayout |
	aLayout := CFMaDetailRowLayout new.
	aLabel := BrLabel new text: 'Name'; fitContent.
	aContent := BrLabel new text: 'Jupiter'; fitContent.
	aLabel constraintsDo: [ :c | (c at: CFMaDetailRowLayout) beDescription ].
	aContent constraintsDo: [ :c | (c at: CFMaDetailRowLayout) beContent ].
	aRow := BlElement new
		layout: aLayout;
		padding: (BlInsets all: 8);
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical fitContent ];
		addChild: aLabel;
		addChild: aContent;
		yourself.

	self assert: (aLabel constraints at: CFMaDetailRowLayout) isDescription.
	self assert: (aContent constraints at: CFMaDetailRowLayout) isContent.
	self assert: aRow layout == aLayout.
	^ aRow
]

{ #category : 'examples - layout' }
CFMaDetailPresentationExamples >> detailRowSupportsFullGrammar [
	<gtExample>
	| aPresentation aLeading aDescription aSupporting aContent firstAccessory secondAccessory aTrailing aRow |
	aPresentation := CFMaDetailPresentation new.
	aLeading := BrLabel new text: '●'; fitContent.
	aDescription := BrLabel new text: 'Wi-Fi'; fitContent.
	aSupporting := BrEditor new
		aptitude: BrGlamorousRegularEditorAptitude new;
		beReadOnlyWithoutSelection;
		focusability: BlFocusability none;
		text: 'Connect automatically to known networks';
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical fitContent ];
		yourself.
	aContent := BrLabel new text: 'On'; fitContent.
	firstAccessory := BrLabel new text: 'i'; fitContent.
	secondAccessory := BrLabel new text: '↶'; fitContent.
	aTrailing := BrLabel new text: '›'; fitContent.

	aRow := aPresentation
		newRowLeading: aLeading
		description: aDescription
		supporting: aSupporting
		content: aContent
		accessories: { firstAccessory. secondAccessory }
		trailing: aTrailing.

	self assert: (aLeading constraints at: CFMaDetailRowLayout) isLeading.
	self assert: (aDescription constraints at: CFMaDetailRowLayout) isDescription.
	self assert: (aSupporting constraints at: CFMaDetailRowLayout) isSupporting.
	self assert: (aContent constraints at: CFMaDetailRowLayout) isContent.
	self assert: (firstAccessory constraints at: CFMaDetailRowLayout) isAccessory.
	self assert: (secondAccessory constraints at: CFMaDetailRowLayout) isAccessory.
	self assert: (aTrailing constraints at: CFMaDetailRowLayout) isTrailing.
	self assert: aRow children size equals: 7.
	^ aRow
]

{ #category : 'examples - layout' }
CFMaDetailPresentationExamples >> detailRowGoneAccessoryDoesNotParticipateInLayout [
	<gtExample>
	| aPresentation aDescription aContent aVisibleAccessory aGoneAccessory aRow accountedChildren |
	aPresentation := CFMaDetailPresentation new.
	aDescription := BrLabel new text: 'Name'; fitContent.
	aContent := BrLabel new text: 'Jupiter'; fitContent.
	aVisibleAccessory := BrLabel new text: 'i'; fitContent.
	aGoneAccessory := BrLabel new
		text: '›';
		fitContent;
		visibility: BlVisibility gone;
		yourself.

	aRow := aPresentation
		newRowLeading: nil
		description: aDescription
		supporting: nil
		content: aContent
		accessories: { aVisibleAccessory. aGoneAccessory }.
	accountedChildren := aRow children accountedByLayout.

	self assert: (accountedChildren includes: aVisibleAccessory).
	self assert: (accountedChildren includes: aGoneAccessory) not.
	^ aRow
]

{ #category : 'examples - field configuration' }
CFMaDetailPresentationExamples >> fieldConfigurationUsesDetailDefaults [
	<gtExample>
	| aDescription aConfiguration |
	aDescription := MAStringDescription new accessor: #name; yourself.
	aConfiguration := CFMaDetailPresentation new fieldConfigurationFor: aDescription.

	self assert: aConfiguration icon isMedium.
	self assert: aConfiguration icon isChromed.
	^ aConfiguration
]

{ #category : 'examples - field configuration' }
CFMaDetailPresentationExamples >> fieldConfigurationAppliesDescriptionHints [
	<gtExample>
	| aDescription aConfiguration |
	aDescription := MAStringDescription new
		accessor: #name;
		fieldConfigure: [ :field |
			field icon
				beLarge;
				backgroundColor: Color blue ];
		yourself.
	aConfiguration := CFMaDetailPresentation new fieldConfigurationFor: aDescription.

	self assert: aConfiguration icon isLarge.
	self assert: aConfiguration icon backgroundColor equals: Color blue.
	^ aConfiguration
]

{ #category : 'examples - field configuration' }
CFMaDetailPresentationExamples >> fieldConfigurationPresentationOverrideWins [
	<gtExample>
	| aDescription aPresentation aConfiguration |
	aDescription := MAStringDescription new
		accessor: #name;
		fieldConfigure: [ :field | field icon beLarge ];
		yourself.
	aPresentation := CFMaDetailPresentation new
		description: aDescription configure: [ :field | field icon beSmall ];
		yourself.
	aConfiguration := aPresentation fieldConfigurationFor: aDescription.

	self assert: aConfiguration icon isSmall.
	^ aConfiguration
]

{ #category : 'examples - field configuration' }
CFMaDetailPresentationExamples >> fieldConfigurationOverrideUsesMagritteEquality [
	<gtExample>
	| configuredDescription visitedDescription aPresentation aConfiguration |
	configuredDescription := MAStringDescription new accessor: #name; yourself.
	visitedDescription := MAStringDescription new accessor: #name; yourself.
	aPresentation := CFMaDetailPresentation new
		description: configuredDescription configure: [ :field | field icon beLarge ];
		yourself.
	aConfiguration := aPresentation fieldConfigurationFor: visitedDescription.

	self assert: configuredDescription equals: visitedDescription.
	self assert: aConfiguration icon isLarge.
	^ aConfiguration
]

{ #category : 'examples - field configuration' }
CFMaDetailPresentationExamples >> fieldConfigurationHintSurvivesDescriptionCopy [
	<gtExample>
	| originalDescription copiedDescription aConfiguration |
	originalDescription := MAStringDescription new
		accessor: #name;
		fieldConfigure: [ :field | field icon beLarge ];
		yourself.
	copiedDescription := originalDescription copy.
	aConfiguration := CFMaDetailPresentation new fieldConfigurationFor: copiedDescription.

	self assert: aConfiguration icon isLarge.
	^ aConfiguration
]

{ #category : 'examples - field configuration' }
CFMaDetailPresentationExamples >> fieldConfigurationDefaultsToTextRepresentation [
	<gtExample>
	| aDescription aConfiguration |
	aDescription := MANumberDescription new accessor: #priority; yourself.
	aConfiguration := CFMaDetailPresentation new fieldConfigurationFor: aDescription.

	self assert: aConfiguration representation class equals: CFMaTextConfiguration.
	^ aConfiguration
]

{ #category : 'examples - field configuration' }
CFMaDetailPresentationExamples >> fieldConfigurationPopupOwnsItsValues [
	<gtExample>
	| aDescription aConfiguration aPopupConfiguration |
	aDescription := MANumberDescription new
		accessor: #priority;
		fieldConfigure: [ :field | field bePopup values: #(25 50 75 100) ];
		yourself.
	aConfiguration := CFMaDetailPresentation new fieldConfigurationFor: aDescription.
	aPopupConfiguration := aConfiguration representation.

	self assert: aPopupConfiguration class equals: CFMaPopupConfiguration.
	self assert: aPopupConfiguration values equals: #(25 50 75 100).
	^ aConfiguration
]

{ #category : 'examples - field configuration' }
CFMaDetailPresentationExamples >> fieldConfigurationRepresentationReplacementIsTyped [
	<gtExample>
	| aFieldConfiguration aPopupConfiguration aSliderConfiguration |
	aFieldConfiguration := CFMaFieldConfiguration new.
	aPopupConfiguration := aFieldConfiguration bePopup.
	aPopupConfiguration values: #(25 50 75 100).
	aSliderConfiguration := aFieldConfiguration beSlider.

	self assert: aPopupConfiguration class equals: CFMaPopupConfiguration.
	self assert: aSliderConfiguration class equals: CFMaSliderConfiguration.
	self assert: aFieldConfiguration representation == aSliderConfiguration.
	^ aFieldConfiguration
]

{ #category : 'examples - field configuration' }
CFMaDetailPresentationExamples >> fieldConfigurationRepresentationDoesNotDisturbIcon [
	<gtExample>
	| aFieldConfiguration |
	aFieldConfiguration := CFMaFieldConfiguration new.
	aFieldConfiguration icon beLarge.
	aFieldConfiguration bePopup values: #(1 2 3).
	aFieldConfiguration beSlider.

	self assert: aFieldConfiguration icon isLarge.
	self assert: aFieldConfiguration representation class equals: CFMaSliderConfiguration.
	^ aFieldConfiguration
]

{ #category : 'examples - field configuration' }
CFMaDetailPresentationExamples >> fieldConfigurationPresentationOverrideReplacesRepresentation [
	<gtExample>
	| aDescription aPresentation aConfiguration |
	aDescription := MANumberDescription new
		accessor: #priority;
		fieldConfigure: [ :field | field bePopup values: #(25 50 75 100) ];
		yourself.
	aPresentation := CFMaDetailPresentation new
		description: aDescription configure: [ :field | field beText ];
		yourself.
	aConfiguration := aPresentation fieldConfigurationFor: aDescription.

	self assert: aConfiguration representation class equals: CFMaTextConfiguration.
	^ aConfiguration
]

{ #category : 'examples - field configuration' }
CFMaDetailPresentationExamples >> fieldConfigurationIsResolvedOncePerPresentation [
	<gtExample>
	| aDescription aPresentation firstConfiguration secondConfiguration |
	aDescription := MANumberDescription new accessor: #priority; yourself.
	aPresentation := CFMaDetailPresentation new.
	firstConfiguration := aPresentation fieldConfigurationFor: aDescription.
	secondConfiguration := aPresentation fieldConfigurationFor: aDescription.

	self assert: firstConfiguration == secondConfiguration.
	^ firstConfiguration
]

{ #category : 'examples - layout' }
CFMaDetailPresentationExamples >> detailCardOwnsLogicalRowsIndependentlyOfSeparators [
	<gtExample>
	| aCard firstRow secondRow thirdRow |
	aCard := CFMaDetailGroupCardElement new.
	firstRow := BlElement new.
	secondRow := BlElement new.
	thirdRow := BlElement new.

	aCard
		addChild: firstRow;
		addChild: thirdRow;
		addRow: secondRow at: 2.

	self assert: aCard rowCount equals: 3.
	self assert: aCard rows asArray equals: { firstRow. secondRow. thirdRow }.
	self assert: aCard children size equals: 5.
	self assert: (aCard children at: 1) == firstRow.
	self assert: (aCard children at: 3) == secondRow.
	self assert: (aCard children at: 5) == thirdRow.
	^ aCard
]

{ #category : 'examples - layout' }
CFMaDetailPresentationExamples >> detailCardRemovalPreservesSeparatorInvariant [
	<gtExample>
	| aCard firstRow secondRow thirdRow |
	aCard := self detailCardOwnsLogicalRowsIndependentlyOfSeparators.
	firstRow := aCard rows first.
	secondRow := aCard rows second.
	thirdRow := aCard rows third.

	aCard removeChild: secondRow.

	self assert: aCard rowCount equals: 2.
	self assert: aCard rows asArray equals: { firstRow. thirdRow }.
	self assert: aCard children size equals: 3.
	self assert: (aCard children at: 1) == firstRow.
	self assert: (aCard children at: 3) == thirdRow.
	^ aCard
]

{ #category : 'examples - field configuration' }
CFMaDetailPresentationExamples >> relationFieldConfigurationDefaultsToList [
	<gtExample>
	| aDescription aConfiguration |
	aDescription := MAToOneRelationDescription new
		accessor: #owner;
		classes: { Object };
		yourself.
	aConfiguration := CFMaDetailPresentation new fieldConfigurationFor: aDescription.

	self assert: aConfiguration representation class equals: CFMaListConfiguration.
	^ aConfiguration
]

{ #category : 'examples - field configuration' }
CFMaDetailPresentationExamples >> relationFieldConfigurationCanEmbedForms [
	<gtExample>
	| aDescription aConfiguration |
	aDescription := MAToManyRelationDescription new
		accessor: #items;
		classes: { Object };
		fieldConfigure: [ :field | field beEmbeddedForms ];
		yourself.
	aConfiguration := CFMaDetailPresentation new fieldConfigurationFor: aDescription.

	self assert: aConfiguration representation class equals: CFMaEmbeddedFormsConfiguration.
	^ aConfiguration
]

{ #category : 'examples - field configuration' }
CFMaDetailPresentationExamples >> embeddedFormsRelationRowIsVisibleByDefault [
	<gtExample>
	| aConfiguration |
	aConfiguration := CFMaEmbeddedFormsConfiguration new.
	self assert: aConfiguration relationRowVisible.
	^ aConfiguration
]

{ #category : 'examples - field configuration' }
CFMaDetailPresentationExamples >> embeddedFormsRelationRowCanBeHiddenExplicitly [
	<gtExample>
	| aDescription aConfiguration |
	aDescription := MAToOneRelationDescription new
		accessor: #owner;
		classes: { Object };
		fieldConfigure: [ :field | field beEmbeddedForm hideRelationRow ];
		yourself.
	aConfiguration := CFMaDetailPresentation new fieldConfigurationFor: aDescription.

	self deny: aConfiguration representation relationRowVisible.
	^ aConfiguration
]

{ #category : 'examples - relations' }
CFMaDetailPresentationExamples >> hiddenEmbeddedRelationRowDoesNotMakeFirstChildRowSelectable [
	<gtExample>
	| aModel anObject aDescription aContainer aMemento aPresentation theRows |
	aModel := CFMaFormShowcase new.
	anObject := aModel embeddedObject.
	aDescription := aModel embeddedObjectDescription
		fieldConfigure: [ :field | field beEmbeddedForm hideRelationRow ];
		yourself.
	aContainer := MAContainer new
		add: aDescription;
		yourself.
	aMemento := CFMaMemento model: aModel description: aContainer.
	aPresentation := CFMaDetailPresentation new
		memento: aMemento;
		yourself.
	theRows := aPresentation newEmbeddedRowsFor: anObject description: aDescription.

	self assert: theRows notEmpty.
	self deny: theRows first focusability = BlFocusability after.
	^ theRows first
]

{ #category : 'examples - relations' }
CFMaDetailPresentationExamples >> detailToOneListObjectElementUsesStandardDetailRepresentation [
	<gtExample>
	| anObject anElement aDescription aRepresentation |
	anObject := CFMaFormShowcaseItem exampleNamed: 'Related' score: 40 status: #active.
	aDescription := MAToOneRelationDescription new.
	anElement := CFMaDetailPresentation new
		newRelationObjectElementFor: anObject
		description: aDescription.

	self assert: anElement class equals: BrFrame.
	self assert: anElement children size equals: 1.
	aRepresentation := anElement children first.
	self assert: aRepresentation class equals: BrHorizontalPane.
	self assert: aRepresentation children first class equals: CFIconTile.
	self assert: aRepresentation children second text asString equals: 'Related'.
	^ anElement
]




{ #category : 'examples - relations' }
CFMaDetailPresentationExamples >> detailToOneListRemovalUsesValidatedMementoWrite [
	<gtExample>
	| aModel aDescription aContainer aMemento anObject |
	aModel := CFMaFormShowcase new.
	anObject := aModel listObject.
	aDescription := MAToOneRelationDescription new
		accessor: #listObject;
		classes: { CFMaFormShowcaseItem. CFMaFormShowcaseAccentItem };
		yourself.
	aContainer := MAContainer new
		add: aDescription;
		yourself.
	aMemento := CFMaMemento model: aModel description: aContainer.

	self assert: (aMemento readUsing: aDescription) == anObject.
	CFMaBuilderUtility
		removeToOneMemento: aMemento
		using: aDescription
		element: BlElement new.
	self assert: (aMemento readUsing: aDescription) isNil.
	^ aMemento
]

{ #category : 'examples - relations' }
CFMaDetailPresentationExamples >> detailToManyListItemUsesPeerRowLayout [
	<gtExample>
	| anObject aDescription aRow |
	anObject := CFMaFormShowcaseItem exampleNamed: 'Related' score: 40 status: #active.
	aDescription := MAToManyRelationDescription new.
	aRow := CFMaDetailPresentation new
		newToManyRelationRowFor: anObject
		description: aDescription.

	self assert: aRow class equals: BlElement.
	self assert: aRow layout class equals: CFMaDetailRowLayout.
	self assert: aRow children size equals: 4.
	self assert: aRow children first class equals: CFIconTile.
	self assert: aRow children second text asString equals: 'Related'.
	^ aRow
]


{ #category : 'examples - relations' }
CFMaDetailPresentationExamples >> detailEmbeddedRowsUseChildMementoAndStandardRows [
	<gtExample>
	| anObject aChildMemento aPresentation aCard theRows |
	anObject := CFMaFormShowcaseItem exampleNamed: 'Embedded' score: 40 status: #active.
	aChildMemento := CFMaMemento model: anObject.
	aPresentation := CFMaDetailPresentation new
		memento: aChildMemento;
		yourself.
	aCard := CFMaDetailGroupCardElement new.
	theRows := aPresentation buildEmbeddedRowsIn: aCard.

	self assert: theRows notEmpty.
	self assert: aCard rows size equals: theRows size.
	self assert: theRows first parent == aCard.
	^ aCard
]

{ #category : 'examples - relations' }
CFMaDetailPresentationExamples >> detailEmbeddedIdentityUsesStandardRepresentation [
	<gtExample>
	| anObject aRow aLeadingElement |
	anObject := CFMaFormShowcaseItem exampleNamed: 'Alpha' score: 30 status: #active.
	aRow := CFMaDetailPresentation new newRelationObjectIdentityRowFor: anObject.

	self assert: aRow class equals: BlElement.
	self assert: aRow layout class equals: CFMaDetailRowLayout.
	self assert: aRow children size >= 3.
	aLeadingElement := aRow children first.
	self assert: aLeadingElement class equals: CFIconTile.
	self assert: aRow children second text asString equals: 'Alpha'.
	^ aRow
]

{ #category : 'examples - relations' }
CFMaDetailPresentationExamples >> detailToOneEmbeddedUsesParentChildMemento [
	<gtExample>
	| aModel anObject aDescription aContainer aMemento aPresentation theRows aChildMemento |
	aModel := CFMaFormShowcase new.
	anObject := aModel embeddedObject.
	aDescription := aModel embeddedObjectDescription.
	aContainer := MAContainer new
		add: aDescription;
		yourself.
	aMemento := CFMaMemento model: aModel description: aContainer.
	aPresentation := CFMaDetailPresentation new
		memento: aMemento;
		yourself.
	aChildMemento := aMemento childMementoFor: anObject inRelation: aDescription.
	theRows := aPresentation newEmbeddedRowsFor: anObject description: aDescription.

	self assert: theRows notEmpty.
	self assert: (aMemento childMementoFor: anObject inRelation: aDescription) == aChildMemento.
	^ theRows first
]

{ #category : 'examples - relations' }
CFMaDetailPresentationExamples >> detailToManyEmbeddedUsesChildMementos [
	<gtExample>
	| aModel aDescription aContainer aMemento aPresentation firstObject secondObject firstRows secondRows |
	aModel := CFMaFormShowcase new.
	aDescription := aModel embeddedItemsDescription.
	aContainer := MAContainer new
		add: aDescription;
		yourself.
	aMemento := CFMaMemento model: aModel description: aContainer.
	aPresentation := CFMaDetailPresentation new
		memento: aMemento;
		yourself.
	firstObject := aModel embeddedItems first.
	secondObject := aModel embeddedItems second.
	firstRows := aPresentation newEmbeddedRowsFor: firstObject description: aDescription.
	secondRows := aPresentation newEmbeddedRowsFor: secondObject description: aDescription.

	self assert: firstRows notEmpty.
	self assert: secondRows notEmpty.
	self assert: (aMemento childMementoFor: firstObject inRelation: aDescription) model == firstObject.
	self assert: (aMemento childMementoFor: secondObject inRelation: aDescription) model == secondObject.
	^ firstRows first
]

{ #category : 'examples - relations - selection' }
CFMaDetailPresentationExamples >> relationSelectionIsExclusiveWithinDescription [
	<gtExample>
	| aPresentation aDescription firstElement secondElement |
	aPresentation := CFMaDetailPresentation new.
	aDescription := MAToManyRelationDescription new.
	firstElement := BlElement new.
	secondElement := BlElement new.

	aPresentation selectRelationElement: firstElement for: aDescription.
	self assert: firstElement states isSelected.
	self assert: (aPresentation relationElementIsSelected: firstElement for: aDescription).

	aPresentation selectRelationElement: secondElement for: aDescription.
	self assert: firstElement states isSelected not.
	self assert: secondElement states isSelected.
	self assert: (aPresentation relationElementIsSelected: secondElement for: aDescription).
	^ secondElement
]

{ #category : 'examples - relations - selection' }
CFMaDetailPresentationExamples >> relationSelectionIsIndependentAcrossDescriptions [
	<gtExample>
	| aPresentation firstDescription secondDescription firstElement secondElement |
	aPresentation := CFMaDetailPresentation new.
	firstDescription := MAToOneRelationDescription new.
	secondDescription := MAToManyRelationDescription new.
	firstElement := BlElement new.
	secondElement := BlElement new.

	aPresentation selectRelationElement: firstElement for: firstDescription.
	aPresentation selectRelationElement: secondElement for: secondDescription.

	self assert: (aPresentation relationElementIsSelected: firstElement for: firstDescription).
	self assert: (aPresentation relationElementIsSelected: secondElement for: secondDescription).
	self assert: firstElement states isSelected.
	self assert: secondElement states isSelected.
	^ secondElement
]

{ #category : 'examples - relations - selection' }
CFMaDetailPresentationExamples >> relationActiveSelectionKeepsSelectionWhenFocusLeaves [
	<gtExample>
	| aPresentation aDescription anElement |
	aPresentation := CFMaDetailPresentation new.
	aDescription := MAToManyRelationDescription new.
	anElement := BlElement new.

	aPresentation selectRelationElement: anElement for: aDescription.
	aPresentation setRelationActive: true for: aDescription.
	self assert: anElement states isSelected.
	self assert: (anElement states hasState: CFMaActiveSelectionState uniqueInstance).

	aPresentation setRelationActive: false for: aDescription.
	self assert: anElement states isSelected.
	self assert: (anElement states hasState: CFMaActiveSelectionState uniqueInstance) not.
	^ anElement
]

{ #category : 'examples - relations - selection' }
CFMaDetailPresentationExamples >> relationFocusContextIncludesRowDescendants [
	<gtExample>
	| aPresentation aRow aChild |
	aPresentation := CFMaDetailPresentation new.
	aRow := BlElement new.
	aChild := BlElement new.
	aRow addChild: aChild.

	self assert: (aPresentation relationFocusElement: aRow isWithinRows: { aRow }).
	self assert: (aPresentation relationFocusElement: aChild isWithinRows: { aRow }).
	self assert: (aPresentation relationFocusElement: BlElement new isWithinRows: { aRow }) not.
	^ aChild
]


{ #category : 'examples - tags' }
CFMaDetailPresentationExamples >> scalarRelationUsesTagsElement [
	| aShowcase aDescription aMemento anElement |
	aShowcase := CFMaFormShowcase new.
	aDescription := aShowcase tagsDescription.
	aMemento := GtMagritteMemento new
		model: aShowcase;
		description: aShowcase magritteDescription;
		yourself.
	anElement := CFMaDetailTagsElement new
		description: aDescription memento: aMemento;
		yourself.
	self assert: aDescription reference class equals: MAStringDescription.
	^ anElement
]


{ #category : 'examples - colour picker' }
CFMaDetailPresentationExamples >> themeColourPicker [
	<gtExample>
	| aPicker |
	aPicker := CFMaDetailColourPickerElement new
		colours: CgtPalette themeColours;
		labelBlock: [ :aColour | CgtPalette themeNameFor: aColour ];
		value: CgtPalette themePurple;
		yourself.
	self assert: aPicker colours size equals: 8.
	self assert: aPicker value equals: CgtPalette themePurple.
	^ aPicker
]

{ #category : 'examples - colour picker' }
CFMaDetailPresentationExamples >> themeColourPickersUseSingleOptionDescriptions [
	<gtExample>
	| aShowcase |
	aShowcase := CFMaFormShowcase new.
	self assert: aShowcase themeColourDescription class equals: MASingleOptionDescription.
	self assert: aShowcase textSelectionColourDescription class equals: MASingleOptionDescription.
	self assert: aShowcase themeColourDescription options size equals: 8.
	self assert: aShowcase textSelectionColourDescription options size equals: 9.
	self
		assert: (CgtPalette automaticTextSelectionColourForThemeColour: CgtPalette themePurple)
		equals: CgtPalette textSelectionPurple.
	^ aShowcase
]

{ #category : 'examples - grouping' }
CFMaDetailPresentationExamples >> groupConfigurationCanHideLabel [
	<gtExample>
	| aConfiguration |
	aConfiguration := CFMaDetailGroupConfiguration new.
	self assert: aConfiguration labelVisible.
	aConfiguration hideLabel.
	self assert: aConfiguration labelVisible not.
	^ aConfiguration
]

