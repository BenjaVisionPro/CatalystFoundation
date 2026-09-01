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
CFMaDetailPresentationExamples >> groupDefaultsToOrdinaryPresentation [
	<gtExample>
	| aConfiguration |
	aConfiguration := CFMaDetailGroupConfiguration new.

	self assert: aConfiguration presentation class equals: CFMaDetailDefaultGroupConfiguration.
	^ aConfiguration
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

	self assert: aConfiguration representation relationRowVisible not.
	^ aConfiguration
]

{ #category : 'examples - relations' }
CFMaDetailPresentationExamples >> hiddenEmbeddedRelationRowDoesNotMakeChildHostSelectable [
	<gtExample>
	| aHost |
	aHost := CFMaDetailPresentation new newPresentationHost.
	self assert: (aHost focusability = BlFocusability after) not.
	^ aHost
]

{ #category : 'examples - relations' }
CFMaDetailPresentationExamples >> genericToOneListStencilUsesRelationReference [
	<gtExample>
	| anObject aDescription anElement |
	anObject := CFMaFormShowcaseItem new
		score: 40;
		yourself.
	aDescription := MAToOneRelationDescription new
		classes: { CFMaFormShowcaseItem };
		reference: (MANumberDescription new accessor: #score; yourself);
		yourself.

	anElement := aDescription blocItemStencil
		listElement: BrSimpleList new;
		rowValue: (CFMaViewModel forObject: anObject);
		rowIndex: 1;
		build.

	self assert: anElement class equals: BrHorizontalPane.
	self assert: anElement children size equals: 1.
	self assert: anElement children first text asString equals: '40'.
	^ anElement
]


{ #category : 'examples - relations' }
CFMaDetailPresentationExamples >> detailToOneListUsesRelationReferenceInsteadOfObjectIdentityProtocol [
	<gtExample>
	| aModel anObject aDescription aContainer aMemento anElement aReferenceElement |
	aModel := CFMaFormShowcase new.
	anObject := aModel listObject.
	aDescription := MAToOneRelationDescription new
		accessor: #listObject;
		classes: { CFMaFormShowcaseItem };
		reference: (MANumberDescription new accessor: #score; yourself);
		yourself.
	aContainer := MAContainer new add: aDescription; yourself.
	aMemento := CFMaMemento model: aModel description: aContainer.
	anElement := (CFMaDetailPresentation new
		memento: aMemento;
		form: BrFrame new;
		yourself)
		newToOneRelationObjectElementFor: anObject
		description: aDescription.

	self assert: anElement class equals: BrFrame.
	self assert: anElement children size equals: 1.
	aReferenceElement := anElement children first.
	self assert: aReferenceElement class equals: BrHorizontalPane.
	self assert: aReferenceElement children size equals: 1.
	self assert: aReferenceElement children first text asString equals: anObject score asString.
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
	| aModel anObject aDescription aContainer aMemento aPresentation aRow aReferenceElement |
	aModel := CFMaFormShowcase new.
	anObject := CFMaFormShowcaseItem exampleNamed: 'Related' score: 40 status: #active.
	aModel listItems: { anObject }.
	aDescription := aModel listItemsDescription.
	aContainer := MAContainer new
		add: aDescription;
		yourself.
	aMemento := CFMaMemento model: aModel description: aContainer.
	aPresentation := CFMaDetailPresentation new
		memento: aMemento;
		form: BrFrame new;
		yourself.
	aRow := aPresentation
		newToManyRelationRowFor: anObject
		description: aDescription.
	aReferenceElement := aRow children first.

	self assert: aRow class equals: BlElement.
	self assert: aRow layout class equals: CFMaDetailRowLayout.
	self assert: aRow children accountedByLayout size equals: 3.
	self assert: aRow children ignoredByLayout size equals: 1.
	self assert: aReferenceElement class equals: BrHorizontalPane.
	self assert: aReferenceElement children first text asString equals: 'Related'.
	^ aRow
]

{ #category : 'examples - relations' }
CFMaDetailPresentationExamples >> detailToManyListUsesRelationReferenceInsteadOfObjectIdentityProtocol [
	<gtExample>
	| aModel anObject aDescription aContainer aMemento aPresentation aRow aReferenceElement |
	aModel := CFMaFormShowcase new.
	anObject := CFMaFormShowcaseItem exampleNamed: 'Related' score: 40 status: #active.
	aModel listItems: { anObject }.
	aDescription := aModel listItemsDescription
		reference: (MAContainer new
			add: (MANumberDescription new accessor: #score; yourself);
			yourself);
		yourself.
	aContainer := MAContainer new
		add: aDescription;
		yourself.
	aMemento := CFMaMemento model: aModel description: aContainer.
	aPresentation := CFMaDetailPresentation new
		memento: aMemento;
		form: BrFrame new;
		yourself.
	aRow := aPresentation
		newToManyRelationRowFor: anObject
		description: aDescription.
	aReferenceElement := aRow children first.

	self assert: aReferenceElement children first text asString equals: '40'.
	^ aRow
]


{ #category : 'examples - relations' }
CFMaDetailPresentationExamples >> detailToManyListReusesItemViewModelsAndRowsAcrossReorder [
	<gtExample>
	| aModel firstObject secondObject aDescription aContainer aMemento aPresentation aCard aHeaderRow firstItems reorderedItems |
	aModel := CFMaFormShowcase new.
	firstObject := CFMaFormShowcaseItem exampleNamed: 'First' score: 10 status: #active.
	secondObject := CFMaFormShowcaseItem exampleNamed: 'Second' score: 20 status: #active.
	aModel listItems: { firstObject. secondObject }.
	aDescription := aModel listItemsDescription.
	aContainer := MAContainer new
		add: aDescription;
		yourself.
	aMemento := CFMaMemento model: aModel description: aContainer.
	aPresentation := CFMaDetailPresentation new
		memento: aMemento;
		form: BrFrame new;
		yourself.
	aCard := CFMaDetailGroupCardElement new.
	aHeaderRow := BlElement new.
	aCard addChild: aHeaderRow.

	firstItems := aPresentation
		updateToManyListRows: #()
		in: aCard
		after: aHeaderRow
		with: { firstObject. secondObject }
		description: aDescription.
	reorderedItems := aPresentation
		updateToManyListRows: firstItems
		in: aCard
		after: aHeaderRow
		with: { secondObject. firstObject }
		description: aDescription.

	self assert: firstItems first key == reorderedItems second key.
	self assert: firstItems second key == reorderedItems first key.
	self assert: firstItems first value == reorderedItems second value.
	self assert: firstItems second value == reorderedItems first value.
	self assert: (aCard rows at: 2) == reorderedItems first value.
	self assert: (aCard rows at: 3) == reorderedItems second value.
	^ aCard
]


{ #category : 'examples - relations' }
CFMaDetailPresentationExamples >> detailEmbeddedPresentationBuildsInChildHost [
	<gtExample>
	| anObject aChildMemento aPresentation aHost aChildPresentation |
	anObject := CFMaFormShowcaseItem exampleNamed: 'Embedded' score: 40 status: #active.
	aChildMemento := CFMaMemento model: anObject.
	aPresentation := CFMaDetailPresentation new.
	aHost := aPresentation newPresentationHost.
	aChildPresentation := aPresentation
		buildPresentationForMemento: aChildMemento
		in: aHost
		configure: [ :thePresentation | thePresentation ].

	self assert: aChildPresentation memento == aChildMemento.
	self assert: aHost children notEmpty.
	^ aHost
]


{ #category : 'examples - relations' }
CFMaDetailPresentationExamples >> detailToOneEmbeddedUsesParentChildMemento [
	<gtExample>
	| aModel anObject aDescription aContainer aMemento aPresentation aChildMemento aHost |
	aModel := CFMaFormShowcase new.
	anObject := aModel embeddedObject.
	aDescription := aModel embeddedObjectDescription.
	aContainer := MAContainer new
		add: aDescription;
		yourself.
	aMemento := CFMaMemento model: aModel description: aContainer.
	aPresentation := CFMaDetailPresentation new memento: aMemento; yourself.
	aChildMemento := aMemento childMementoFor: anObject inRelation: aDescription.
	aHost := aPresentation newPresentationHost.
	aPresentation
		buildPresentationForMemento: aChildMemento
		in: aHost
		configure: [ :thePresentation | thePresentation ].

	self assert: (aMemento childMementoFor: anObject inRelation: aDescription) == aChildMemento.
	self assert: aHost children notEmpty.
	^ aHost
]

{ #category : 'examples - relations' }
CFMaDetailPresentationExamples >> detailToManyEmbeddedUsesChildMementos [
	<gtExample>
	| aModel aDescription aContainer aMemento aPresentation firstObject secondObject firstHost secondHost |
	aModel := CFMaFormShowcase new.
	aDescription := aModel embeddedItemsDescription.
	aContainer := MAContainer new
		add: aDescription;
		yourself.
	aMemento := CFMaMemento model: aModel description: aContainer.
	aPresentation := CFMaDetailPresentation new memento: aMemento; yourself.
	firstObject := aModel embeddedItems first.
	secondObject := aModel embeddedItems second.
	firstHost := aPresentation newPresentationHost.
	secondHost := aPresentation newPresentationHost.
	aPresentation
		buildPresentationForMemento: (aMemento childMementoFor: firstObject inRelation: aDescription)
		in: firstHost
		configure: [ :thePresentation | thePresentation ].
	aPresentation
		buildPresentationForMemento: (aMemento childMementoFor: secondObject inRelation: aDescription)
		in: secondHost
		configure: [ :thePresentation | thePresentation ].

	self assert: (aMemento childMementoFor: firstObject inRelation: aDescription) model == firstObject.
	self assert: (aMemento childMementoFor: secondObject inRelation: aDescription) model == secondObject.
	self assert: firstHost children notEmpty.
	self assert: secondHost children notEmpty.
	^ firstHost
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
CFMaDetailPresentationExamples >> toManyListSelectionSupportsToggleRangeAndSelectAll [
	<gtExample>
	| aPresentation aDescription firstElement secondElement thirdElement fourthElement |
	aPresentation := CFMaDetailPresentation new.
	aDescription := MAToManyRelationDescription new.
	firstElement := BlElement new.
	secondElement := BlElement new.
	thirdElement := BlElement new.
	fourthElement := BlElement new.
	aPresentation
		relationSelectableRows: { firstElement. secondElement. thirdElement. fourthElement }
		for: aDescription.

	aPresentation selectRelationElement: firstElement for: aDescription.
	aPresentation toggleRelationElement: thirdElement for: aDescription.
	self assert: (aPresentation relationElementIsSelected: firstElement for: aDescription).
	self assert: (aPresentation relationElementIsSelected: thirdElement for: aDescription).
	self assert: (aPresentation relationElementIsSelected: secondElement for: aDescription) not.

	aPresentation selectRelationRangeTo: fourthElement for: aDescription.
	{ firstElement. secondElement. thirdElement. fourthElement } do: [ :anElement |
		self assert: (aPresentation relationElementIsSelected: anElement for: aDescription) ].

	aPresentation selectRelationElement: secondElement for: aDescription.
	aPresentation selectAllToManyListRowsFor: aDescription.
	{ firstElement. secondElement. thirdElement. fourthElement } do: [ :anElement |
		self assert: (aPresentation relationElementIsSelected: anElement for: aDescription) ].
	^ fourthElement
]

{ #category : 'examples - relations - selection' }
CFMaDetailPresentationExamples >> toManyListSelectionReconciliationDropsRemovedRows [
	<gtExample>
	| aPresentation aDescription firstElement secondElement |
	aPresentation := CFMaDetailPresentation new.
	aDescription := MAToManyRelationDescription new.
	firstElement := BlElement new.
	secondElement := BlElement new.
	aPresentation
		relationSelectableRows: { firstElement. secondElement }
		for: aDescription.
	aPresentation selectRelationElement: firstElement for: aDescription.
	aPresentation toggleRelationElement: secondElement for: aDescription.

	aPresentation
		relationSelectableRows: { secondElement }
		for: aDescription.
	self assert: (aPresentation relationElementIsSelected: firstElement for: aDescription) not.
	self assert: (aPresentation relationElementIsSelected: secondElement for: aDescription).
	self assert: firstElement states isSelected not.
	self assert: secondElement states isSelected.
	^ secondElement
]

{ #category : 'examples - relations - selection' }
CFMaDetailPresentationExamples >> relationActiveSelectionAppliesToEverySelectedRow [
	<gtExample>
	| aPresentation aDescription firstElement secondElement |
	aPresentation := CFMaDetailPresentation new.
	aDescription := MAToManyRelationDescription new.
	firstElement := BlElement new.
	secondElement := BlElement new.
	aPresentation
		relationSelectableRows: { firstElement. secondElement }
		for: aDescription.
	aPresentation selectRelationElement: firstElement for: aDescription.
	aPresentation toggleRelationElement: secondElement for: aDescription.

	aPresentation setRelationActive: true for: aDescription.
	self assert: (firstElement states hasState: CFMaActiveSelectionState uniqueInstance).
	self assert: (secondElement states hasState: CFMaActiveSelectionState uniqueInstance).

	aPresentation setRelationActive: false for: aDescription.
	self assert: (firstElement states hasState: CFMaActiveSelectionState uniqueInstance) not.
	self assert: (secondElement states hasState: CFMaActiveSelectionState uniqueInstance) not.
	^ secondElement
]

{ #category : 'examples - relations - selection' }
CFMaDetailPresentationExamples >> toManyListSelectedRowsResolveToRelationObjectsInOrder [
	<gtExample>
	| aModel firstObject secondObject thirdObject aDescription aContainer aMemento aPresentation aCard aHeaderRow itemRows selectedObjects |
	aModel := CFMaFormShowcase new.
	firstObject := CFMaFormShowcaseItem exampleNamed: 'First' score: 10 status: #active.
	secondObject := CFMaFormShowcaseItem exampleNamed: 'Second' score: 20 status: #active.
	thirdObject := CFMaFormShowcaseItem exampleNamed: 'Third' score: 30 status: #active.
	aModel listItems: { firstObject. secondObject. thirdObject }.
	aDescription := aModel listItemsDescription.
	aContainer := MAContainer new
		add: aDescription;
		yourself.
	aMemento := CFMaMemento model: aModel description: aContainer.
	aPresentation := CFMaDetailPresentation new
		memento: aMemento;
		form: BrFrame new;
		yourself.
	aCard := CFMaDetailGroupCardElement new.
	aHeaderRow := BlElement new.
	aCard addChild: aHeaderRow.
	itemRows := aPresentation
		updateToManyListRows: #()
		in: aCard
		after: aHeaderRow
		with: { firstObject. secondObject. thirdObject }
		description: aDescription.
	aPresentation
		relationSelectableRows: (itemRows collect: #value)
		for: aDescription.
	aPresentation selectRelationElement: itemRows first value for: aDescription.
	aPresentation toggleRelationElement: itemRows third value for: aDescription.

	selectedObjects := aPresentation selectedToManyListObjectsFor: aDescription.
	self assert: selectedObjects size equals: 2.
	self assert: selectedObjects first == firstObject.
	self assert: selectedObjects second == thirdObject.
	^ itemRows third value
]

{ #category : 'examples - relations - selection' }
CFMaDetailPresentationExamples >> toManyListRemovalTargetsSelectionOnlyFromSelectedRow [
	<gtExample>
	| aModel firstObject secondObject thirdObject aDescription aContainer aMemento aPresentation aCard aHeaderRow itemRows selectedRemoval unselectedRemoval |
	aModel := CFMaFormShowcase new.
	firstObject := CFMaFormShowcaseItem exampleNamed: 'First' score: 10 status: #active.
	secondObject := CFMaFormShowcaseItem exampleNamed: 'Second' score: 20 status: #active.
	thirdObject := CFMaFormShowcaseItem exampleNamed: 'Third' score: 30 status: #active.
	aModel listItems: { firstObject. secondObject. thirdObject }.
	aDescription := aModel listItemsDescription.
	aContainer := MAContainer new
		add: aDescription;
		yourself.
	aMemento := CFMaMemento model: aModel description: aContainer.
	aPresentation := CFMaDetailPresentation new
		memento: aMemento;
		form: BrFrame new;
		yourself.
	aCard := CFMaDetailGroupCardElement new.
	aHeaderRow := BlElement new.
	aCard addChild: aHeaderRow.
	itemRows := aPresentation
		updateToManyListRows: #()
		in: aCard
		after: aHeaderRow
		with: { firstObject. secondObject. thirdObject }
		description: aDescription.
	aPresentation
		relationSelectableRows: (itemRows collect: #value)
		for: aDescription.
	aPresentation selectRelationElement: itemRows first value for: aDescription.
	aPresentation toggleRelationElement: itemRows third value for: aDescription.

	selectedRemoval := aPresentation
		toManyListObjectsForRemovalFrom: itemRows first value
		object: firstObject
		description: aDescription.
	unselectedRemoval := aPresentation
		toManyListObjectsForRemovalFrom: itemRows second value
		object: secondObject
		description: aDescription.

	self assert: selectedRemoval size equals: 2.
	self assert: selectedRemoval first == firstObject.
	self assert: selectedRemoval second == thirdObject.
	self assert: unselectedRemoval size equals: 1.
	self assert: unselectedRemoval first == secondObject.
	^ itemRows first value
]

{ #category : 'examples - relations - ordering' }
CFMaDetailPresentationExamples >> toManyOrderedReorderMovesSingleObjectBeforeTarget [
	<gtExample>
	| firstObject secondObject thirdObject fourthObject reordered |
	firstObject := Object new.
	secondObject := Object new.
	thirdObject := Object new.
	fourthObject := Object new.

	reordered := CFMaBuilderUtility
		reorderedToManyItems: { firstObject. secondObject. thirdObject. fourthObject }
		moving: { thirdObject }
		relativeTo: firstObject
		after: false.

	self assert: reordered first == thirdObject.
	self assert: reordered second == firstObject.
	self assert: reordered third == secondObject.
	self assert: reordered fourth == fourthObject.
	^ reordered
]

{ #category : 'examples - relations - ordering' }
CFMaDetailPresentationExamples >> toManyOrderedReorderMovesSelectionAsStableBlock [
	<gtExample>
	| firstObject secondObject thirdObject fourthObject fifthObject reordered |
	firstObject := Object new.
	secondObject := Object new.
	thirdObject := Object new.
	fourthObject := Object new.
	fifthObject := Object new.

	reordered := CFMaBuilderUtility
		reorderedToManyItems: { firstObject. secondObject. thirdObject. fourthObject. fifthObject }
		moving: { fourthObject. secondObject }
		relativeTo: fifthObject
		after: true.

	self assert: reordered first == firstObject.
	self assert: reordered second == thirdObject.
	self assert: reordered third == fifthObject.
	self assert: reordered fourth == secondObject.
	self assert: reordered fifth == fourthObject.
	^ reordered
]

{ #category : 'examples - relations - ordering' }
CFMaDetailPresentationExamples >> toManyOrderedReorderOntoDraggedObjectIsNoOp [
	<gtExample>
	| firstObject secondObject thirdObject original reordered |
	firstObject := Object new.
	secondObject := Object new.
	thirdObject := Object new.
	original := { firstObject. secondObject. thirdObject }.

	reordered := CFMaBuilderUtility
		reorderedToManyItems: original
		moving: { firstObject. secondObject }
		relativeTo: secondObject
		after: true.

	self assert: reordered == original.
	^ reordered
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


{ #category : 'examples - composition' }
CFMaDetailPresentationExamples >> detailGroupPreservesNestedPresentationOrder [
	<gtExample>
	| aGroup firstRow aHost secondRow aComposition |
	aGroup := CFMaDetailGroupElement new
		configuration: CFMaDetailGroupConfiguration new;
		yourself.
	firstRow := BlElement new.
	aHost := CFMaPresentationHostElement new.
	secondRow := BlElement new.

	aGroup addContent: firstRow.
	aGroup addNestedPresentationElement: aHost.
	aGroup addContent: secondRow.
	aComposition := aGroup children first.

	self assert: aComposition children size equals: 3.
	self assert: aComposition children first class equals: CFMaDetailGroupCardElement.
	self assert: aComposition children second == aHost.
	self assert: aComposition children third class equals: CFMaDetailGroupCardElement.
	self assert: aComposition children first rows first == firstRow.
	self assert: aComposition children third rows first == secondRow.
	^ aGroup
]


{ #category : 'examples - relations' }
CFMaDetailPresentationExamples >> toManyIdentityComparisonDistinguishesEqualObjects [
	<gtExample>
	| firstObject secondObject |
	firstObject := 'same' copy.
	secondObject := 'same' copy.
	self assert: firstObject = secondObject.
	self assert: (firstObject == secondObject) not.
	self assert: (CFMaBuilderUtility
		toManyItems: { firstObject. secondObject }
		identityMatches: { secondObject. firstObject }) not.
	^ { firstObject. secondObject }
]

{ #category : 'examples - relations' }
CFMaDetailPresentationExamples >> reorderedToManyItemsMovesOneOfTwoEqualObjectsByIdentity [
	<gtExample>
	| firstObject secondObject targetObject reordered |
	firstObject := 'same' copy.
	secondObject := 'same' copy.
	targetObject := 'target' copy.
	reordered := CFMaBuilderUtility
		reorderedToManyItems: { firstObject. secondObject. targetObject }
		moving: { firstObject }
		relativeTo: targetObject
		after: true.
	self assert: reordered first == secondObject.
	self assert: reordered second == targetObject.
	self assert: reordered third == firstObject.
	^ reordered
]



{ #category : 'examples - relations - adding' }
CFMaDetailPresentationExamples >> toOneCreationIsOptIn [
	<gtExample>
	| aDescription |
	aDescription := MAToOneRelationDescription new
		classes: { Object };
		yourself.

	self assert: aDescription newItemStencil isNil.
	self assert: aDescription newItemClassStencil isNil.
	aDescription newItemClassStencil: [ :aClass | aClass new ].
	self assert: aDescription newItemClassStencil isNotNil.
	^ aDescription
]

{ #category : 'examples - relations - adding' }
CFMaDetailPresentationExamples >> toOneClassesDoNotImplicitlyEnableAdd [
	<gtExample>
	| aPresentation aDescription |
	aPresentation := CFMaDetailPresentation new.
	aDescription := MAToOneRelationDescription new
		classes: { Object };
		yourself.

	self assert: (aPresentation newToOneAddElementUsing: aDescription) isNil.
	^ aDescription
]

{ #category : 'examples - relations - adding' }
CFMaDetailPresentationExamples >> nativeNewItemStencilCreatesDomainItemWithoutClassDispatch [
	<gtExample>
	| aDescription aCreatedObject aViewModel |
	aCreatedObject := Object new.
	aDescription := MAToManyRelationDescription new
		classes: { Object };
		newItemStencil: [ aCreatedObject ];
		yourself.
	aViewModel := CFMaAddItemViewModel new
		description: aDescription;
		stencil: aDescription newItemStencil;
		yourself.

	self assert: aViewModel classStencil isNil.
	self assert: (aViewModel createItemForClass: nil) == aCreatedObject.
	self assert: aViewModel shouldShowNewItemClassChoiceMenu not.
	^ aViewModel
]

{ #category : 'examples - relations - adding' }
CFMaDetailPresentationExamples >> toManyAddingPreservesCollectionSpeciesAndOrder [
	<gtExample>
	| firstObject secondObject newObject existing added |
	firstObject := Object new.
	secondObject := Object new.
	newObject := Object new.
	existing := OrderedCollection with: firstObject with: secondObject.
	added := CFMaBuilderUtility toManyItems: existing adding: newObject.
	self assert: added class equals: OrderedCollection.
	self assert: added size equals: 3.
	self assert: added first == firstObject.
	self assert: added second == secondObject.
	self assert: added third == newObject.
	^ added
]

{ #category : 'examples - relations - adding' }
CFMaDetailPresentationExamples >> addClassAvailabilityDoesNotCreateSpeculativeDomainObjects [
	<gtExample>
	| aModel aDescription aContainer aMemento aViewModel creationCount |
	creationCount := 0.
	aModel := CFMaFormShowcase new.
	aDescription := aModel listItemsDescription.
	aContainer := MAContainer new add: aDescription; yourself.
	aMemento := CFMaMemento model: aModel description: aContainer.
	aViewModel := CFMaAddItemViewModel new
		memento: aMemento;
		description: aDescription;
		classStencil: [ :aClass |
			creationCount := creationCount + 1.
			aClass new ];
		yourself.

	self assert: (aViewModel shouldDisableNewItemClass: CFMaFormShowcaseItem) not.
	self assert: creationCount equals: 0.
	^ aViewModel
]

{ #category : 'examples - relations - adding' }
CFMaDetailPresentationExamples >> toOneClassAvailabilityIsDisabledWhenValueExistsWithoutCreatingCandidate [
	<gtExample>
	| aModel aDescription aContainer aMemento aViewModel creationCount |
	creationCount := 0.
	aModel := CFMaFormShowcase new.
	aModel listObject: (CFMaFormShowcaseItem exampleNamed: 'Existing' score: 10 status: #active).
	aDescription := aModel listObjectDescription.
	aContainer := MAContainer new add: aDescription; yourself.
	aMemento := CFMaMemento model: aModel description: aContainer.
	aViewModel := CFMaToOneAddItemViewModel new
		memento: aMemento;
		description: aDescription;
		classStencil: [ :aClass |
			creationCount := creationCount + 1.
			aClass new ];
		yourself.

	self assert: (aViewModel shouldDisableNewItemClass: CFMaFormShowcaseItem).
	self assert: creationCount equals: 0.
	^ aViewModel
]

{ #category : 'examples - compact object' }
CFMaDetailPresentationExamples >> compactIdentityRequiresExplicitReference [
	<gtExample>
	| aPresentation anIconDescription anIdentifierDescription aLabelDescription aReference theDescriptions |
	aPresentation := CFMaDetailPresentation new.
	anIconDescription := FontAwesomeIconDescription new
		accessor: #icon;
		group: 'General';
		categories: #(main);
		yourself.
	anIdentifierDescription := MASymbolDescription new
		accessor: #identifier;
		group: 'General';
		categories: #(main);
		yourself.
	aLabelDescription := MAStringDescription new
		accessor: #label;
		group: 'General';
		categories: #(main);
		yourself.
	aReference := MAContainer new
		add: anIconDescription copy;
		add: aLabelDescription copy;
		add: anIdentifierDescription copy;
		yourself.

	self assert: (aPresentation compactIdentityDescriptionsIn: {
		anIconDescription.
		anIdentifierDescription.
		aLabelDescription }) isEmpty.

	aPresentation compactIdentityReference: aReference.
	theDescriptions := aPresentation compactIdentityDescriptionsIn: {
		anIconDescription.
		anIdentifierDescription.
		aLabelDescription }.
	self assert: theDescriptions size equals: 3.

	aLabelDescription categories: #(other).
	self assert: (aPresentation compactIdentityDescriptionsIn: {
		anIconDescription.
		anIdentifierDescription.
		aLabelDescription }) isEmpty.
	^ aPresentation
]

{ #category : 'examples - compact object' }
CFMaDetailPresentationExamples >> compactObjectRendersReferenceDescription [
	<gtExample>
	| anObject aMemento aReference anElement |
	anObject := CFMaFormShowcase new.
	anObject label: 'Compact object'.
	aMemento := CFMaMemento model: anObject.
	aReference := MAContainer new
		add: anObject iconDescription;
		add: anObject labelDescription;
		add: anObject identifierDescription;
		yourself.
	anElement := CFCompactObjectElement new
		memento: aMemento;
		reference: aReference;
		yourself.

	self assert: anElement titleText equals: 'Compact object'.
	self assert: anElement identifierElement text asString equals: anObject identifier asString.
	self assert: anElement identifierElement visibility equals: BlVisibility visible.
	self assert: anElement iconContainer class equals: CFIconTile.
	anElement beSmall.
	self assert: anElement iconContainer constraints horizontal resizer size equals: 20.
	self assert: anElement iconContainer constraints vertical resizer size equals: 20.
	anElement beMedium.
	self assert: anElement iconContainer constraints horizontal resizer size equals: 28.
	self assert: anElement iconContainer constraints vertical resizer size equals: 28.
	anElement beLarge.
	self assert: anElement iconContainer constraints horizontal resizer size equals: 44.
	self assert: anElement iconContainer constraints vertical resizer size equals: 44.
	^ anElement
]
