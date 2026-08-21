Class {
	#name : 'CFMaDetailPresentationExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Magritte-Detail-Examples',
	#package : 'BVC-Foundation-Magritte-Detail',
	#tag : 'Examples'
}

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
CFMaDetailPresentationExamples >> configuredPresentation [
	<gtExample>
	| aContainer aPresentation aGeneral aMain anExtension |
	aContainer := MAContainer new.
	aContainer blocPresentationStencil: [ :aMemento |
		CFMaDetailPresentation new
			group: 'General' configure: [ :general |
				general category: #main configure: [ :main |
					main asTabs.
					main category: #extension configure: [ :extension |
						extension asAccordions ] ] ];
			yourself ].

	aPresentation := aContainer blocPresentationStencil
		memento: nil;
		build.
	aGeneral := aPresentation groupConfigurationFor: 'General'.
	aMain := aGeneral categoryConfigurationFor: #main.
	anExtension := aMain categoryConfigurationFor: #extension.

	self assert: aMain arrangement isTabs.
	self assert: anExtension arrangement isAccordions.
	^ aPresentation
]

{ #category : 'examples' }
CFMaDetailPresentationExamples >> presentationStencilCreatesFreshInstances [
	<gtExample>
	| aContainer first second |
	aContainer := MAContainer new.
	aContainer blocPresentationStencil: [ :aMemento |
		CFMaDetailPresentation new
			group: 'General' configure: [ :general |
				general category: #main configure: [ :main | main asTabs ] ];
			yourself ].

	first := aContainer blocPresentationStencil
		memento: nil;
		build.
	second := aContainer blocPresentationStencil
		memento: nil;
		build.

	self assert: first ~~ second.
	self assert: (first groupConfigurationFor: 'General') ~~ (second groupConfigurationFor: 'General').
	^ first
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
CFMaDetailPresentationExamples >> detailDescriptionWithSupportingText [
	<gtExample>
	| aPrimary aSupporting aDescription |
	aPrimary := BrLabel new
		text: 'Wi-Fi';
		fitContent.
	aSupporting := BrEditor new
		aptitude: BrGlamorousRegularEditorAptitude new;
		beReadOnlyWithoutSelection;
		focusability: BlFocusability none;
		text: 'Connect automatically to known networks';
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical fitContent ];
		yourself.
	aDescription := CFMaDetailDescriptionElement new
		primary: aPrimary supporting: aSupporting;
		yourself.

	self assert: aDescription primaryElement == aPrimary.
	self assert: aDescription supportingElement == aSupporting.
	self assert: aDescription supportsBaseline.
	^ aDescription
]

{ #category : 'examples - layout' }
CFMaDetailPresentationExamples >> detailRowSupportsFullGrammar [
	<gtExample>
	| aPresentation aLeading aDescription aContent firstAccessory secondAccessory aRow |
	aPresentation := CFMaDetailPresentation new.
	aLeading := BrLabel new text: '●'; fitContent.
	aDescription := self detailDescriptionWithSupportingText.
	aContent := BrLabel new text: 'On'; fitContent.
	firstAccessory := BrLabel new text: 'i'; fitContent.
	secondAccessory := BrLabel new text: '›'; fitContent.

	aRow := aPresentation
		newRowLeading: aLeading
		description: aDescription primaryElement
		supporting: aDescription supportingElement
		content: aContent
		accessories: { firstAccessory. secondAccessory }.

	self assert: (aLeading constraints at: CFMaDetailRowLayout) isLeading.
	self assert: (aDescription primaryElement constraints at: CFMaDetailRowLayout) isDescription.
	self assert: (aDescription supportingElement constraints at: CFMaDetailRowLayout) isSupporting.
	self assert: (aContent constraints at: CFMaDetailRowLayout) isContent.
	self assert: (firstAccessory constraints at: CFMaDetailRowLayout) isAccessory.
	self assert: (secondAccessory constraints at: CFMaDetailRowLayout) isAccessory.
	self assert: aRow children size equals: 6.
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
