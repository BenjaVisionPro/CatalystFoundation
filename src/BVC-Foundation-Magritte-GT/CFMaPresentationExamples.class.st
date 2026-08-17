"I provide executable examples for Foundation Magritte presentations."

Class {
	#name : 'CFMaPresentationExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Magritte-GT-Examples',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Examples'
}

{ #category : 'examples - presentations' }
CFMaPresentationExamples >> defaultPresentation [
	<gtExample>
	^ CFMaPresentation new
]

{ #category : 'examples - presentations' }
CFMaPresentationExamples >> accordionPresentation [
	<gtExample>
	^ CFMaAccordionPresentation new
]

{ #category : 'examples - presentations' }
CFMaPresentationExamples >> tabbedPresentation [
	<gtExample>
	^ CFMaTabbedPresentation new
]

{ #category : 'examples - presentations' }
CFMaPresentationExamples >> settingsPresentation [
	<gtExample>
	^ CFMaSettingsPresentation new
]

{ #category : 'examples - presentations' }
CFMaPresentationExamples >> leftTabbedPresentation [
	<gtExample>
	^ CFMaLeftTabbedPresentation new
]

{ #category : 'examples - forms' }
CFMaPresentationExamples >> accordionPresentationElement [
	<gtExample>
	| aViewModel |
	aViewModel := CFMaViewModel forObject: CFMaFormShowcase example.
	aViewModel presentationClass: CFMaAccordionPresentation.
	^ aViewModel asElement
]

{ #category : 'examples - forms' }
CFMaPresentationExamples >> tabbedPresentationElement [
	<gtExample>
	| aViewModel |
	aViewModel := CFMaViewModel forObject: CFMaFormShowcase example.
	aViewModel presentationClass: CFMaTabbedPresentation.
	^ aViewModel asElement
]

{ #category : 'examples - forms' }
CFMaPresentationExamples >> settingsPresentationElement [
	<gtExample>
	| aViewModel |
	aViewModel := CFMaViewModel forObject: CFMaFormShowcase example.
	aViewModel presentationClass: CFMaSettingsPresentation.
	^ aViewModel asElement
]

{ #category : 'examples - forms' }
CFMaPresentationExamples >> leftTabbedPresentationElement [
	<gtExample>
	| aViewModel |
	aViewModel := CFMaViewModel forObject: CFMaFormShowcase example.
	aViewModel presentationClass: CFMaLeftTabbedPresentation.
	^ aViewModel asElement
]

{ #category : 'examples - forms' }
CFMaPresentationExamples >> showcaseUsesSettingsPresentation [
	<gtExample>
	| aViewModel |
	aViewModel := CFMaFormShowcase example asGtMagritteViewModel.

	self assert: aViewModel presentationClass equals: CFMaSettingsPresentation.
	^ aViewModel asElement
]

{ #category : 'examples - paths' }
CFMaPresentationExamples >> descriptionPath [
	<gtExample>
	| aDescription |
	aDescription := MAStringDescription new.
	self assert: aDescription path equals: #().
	aDescription path: #(appearance display).
	self assert: aDescription path equals: #(appearance display).
	self assert: (aDescription propertyAt: #cfPath) equals: #(appearance display).
	^ aDescription
]

{ #category : 'examples - paths' }
CFMaPresentationExamples >> showcasePathsAreScopedToFields [
	<gtExample>
	| aShowcase descriptions fieldDescriptions relationDescriptions |
	aShowcase := CFMaFormShowcase example.
	descriptions := aShowcase magritteDescription children.
	fieldDescriptions := descriptions select: [ :each | each group = 'Fields' ].
	relationDescriptions := descriptions reject: [ :each | each group = 'Fields' ].

	self assert: fieldDescriptions isNotEmpty.
	self assert: (fieldDescriptions allSatisfy: [ :each | each path isNotEmpty ]).
	self assert: (relationDescriptions allSatisfy: [ :each | each path isEmpty ]).
	^ aShowcase
]

{ #category : 'examples - settings' }
CFMaPresentationExamples >> settingsRowAptitude [
	<gtExample>
	| anAptitude |
	anAptitude := CFMaSettingsRowAptitude new.
	self assert: anAptitude class equals: CFMaSettingsRowAptitude.
	^ anAptitude
]

{ #category : 'examples - settings' }
CFMaPresentationExamples >> settingsEditorAptitude [
	<gtExample>
	| anAptitude |
	anAptitude := CFMaSettingsEditorAptitude new.
	self assert: anAptitude class equals: CFMaSettingsEditorAptitude.
	^ anAptitude
]

{ #category : 'examples - settings' }
CFMaPresentationExamples >> settingsFocusOverlayUsesBlocOverlay [
	<gtExample>
	| aRow anOverlay aContainer |
	aContainer := BrFrame new
		hExact: 200;
		vExact: 40;
		yourself.
	aRow := BrFrame new
		hExact: 200;
		vExact: 40;
		yourself.
	aContainer addChild: aRow.
	anOverlay := BlOverlayElement on: aRow.
	aContainer addChild: anOverlay.

	self assert: anOverlay isAttached.
	self assert: anOverlay parent equals: aContainer.
	^ anOverlay
]



{ #category : 'examples - settings' }
CFMaPresentationExamples >> settingsCommentEditor [
	<gtExample>
	| anEditor |
	anEditor := BrEditor new
		aptitude: BrGlamorousRegularEditorAptitude new;
		beReadOnlyWithoutSelection;
		text: 'A long settings comment that may wrap onto more than one line.' asRopedText;
		hMatchParent;
		vFitContent;
		yourself.
	self assert: anEditor class equals: BrEditor.
	^ anEditor
]



{ #category : 'examples - settings' }
CFMaPresentationExamples >> settingsMemoEditor [
	<gtExample>
	| anEditor |
	anEditor := BrEditor new
		inputFilter: BrTextEditorNoInputFilter new;
		aptitude: (BrGlamorousRegularEditorAptitude new fontSize: 13);
		hMatchParent;
		vFitContent;
		padding: BlInsets empty;
		margin: BlInsets empty;
		yourself.
	self assert: anEditor class equals: BrEditor.
	self assert: anEditor inputFilter class equals: BrTextEditorNoInputFilter.
	^ anEditor
]

{ #category : 'examples - settings' }
CFMaPresentationExamples >> settingsRightAlignedMemoSegment [
	<gtExample>
	| aSegment aType aHolder |
	aSegment := CFMaSettingsRightAlignedParagraphSegment new.
	aType := aSegment segmentType.
	aHolder := aType holder.
	self assert: aType class equals: CFMaSettingsRightAlignedParagraphSegmentType.
	self assert: aHolder class equals: CFMaSettingsRightAlignedParagraphSegmentHolder.
	self assert: aHolder createSegmentElement class equals: CFMaSettingsRightAlignedParagraphElement.
	^ aSegment
]



{ #category : 'examples - settings' }
CFMaPresentationExamples >> settingsMemoDeselectsOnFocusOut [
	<gtExample>
	| anEditor |
	anEditor := BrEditor new
		inputFilter: BrTextEditorNoInputFilter new;
		aptitude: BrGlamorousRegularEditorAptitude new;
		yourself.
	anEditor
		when: BlFocusOutEvent
		do: [ :anEvent | anEditor deselecter all deselect ].
	self assert: anEditor class equals: BrEditor.
	^ anEditor
]

{ #category : 'examples - settings' }
CFMaPresentationExamples >> settingsOneLineEditorKeepsNativeSelectionBehaviour [
	<gtExample>
	| anEditor aPresentation |
	anEditor := GtMagritteOneLineEditorElement new.
	aPresentation := CFMaSettingsPresentation new.
	aPresentation prepareEditorChromeIn: anEditor.
	self assert: anEditor class equals: GtMagritteOneLineEditorElement.
	^ anEditor
]

{ #category : 'examples - settings' }
CFMaPresentationExamples >> settingsMemoKeepsNativeEditorFocusability [
	<gtExample>
	| anEditor |
	anEditor := BrEditor new.
	self assert: anEditor focusability equals: BlFocusability block.
	^ anEditor
]

{ #category : 'examples - settings' }
CFMaPresentationExamples >> settingsCommentIsNotATabStop [
	<gtExample>
	| aComment |
	aComment := BrEditor new
		beReadOnlyWithoutSelection;
		focusability: BlFocusability none;
		yourself.
	self assert: aComment focusability equals: BlFocusability none.
	^ aComment
]





{ #category : 'examples - settings' }
CFMaPresentationExamples >> settingsRowOwnsCanonicalInsets [
	<gtExample>
	| aRow |
	aRow := CFMaSettingsRowElement new.
	self assert: aRow padding top equals: aRow topInset.
	self assert: aRow padding left equals: aRow horizontalInset.
	self assert: aRow padding bottom equals: aRow bottomInset.
	self assert: aRow padding right equals: aRow horizontalInset.
	^ aRow
]

{ #category : 'examples - settings' }
CFMaPresentationExamples >> settingsCardOwnsEdgeSpacingAndSeparators [
	<gtExample>
	| aCard aFirstRow aSecondRow |
	aCard := CFMaSettingsCardElement new.
	aFirstRow := CFMaSettingsRowElement new.
	aSecondRow := CFMaSettingsRowElement new.
	aCard addRow: aFirstRow.
	aCard addRow: aSecondRow.
	self assert: aCard padding top equals: aCard edgeInset.
	self assert: aCard padding bottom equals: aCard edgeInset.
	self assert: aCard children size equals: 3.
	^ aCard
]

{ #category : 'examples - settings' }
CFMaPresentationExamples >> settingsSectionOwnsCardSpacing [
	<gtExample>
	| aSection |
	aSection := CFMaSettingsSectionElement new.
	self assert: aSection class equals: CFMaSettingsSectionElement.
	^ aSection
]

{ #category : 'examples - settings' }
CFMaPresentationExamples >> settingsStandardRowDoesNotIgnoreTrailingField [
	<gtExample>
	| aRow aLabel aField aContent |
	aLabel := BrLabel new
		text: 'Label';
		aptitude: BrGlamorousLabelAptitude new;
		fitContent;
		yourself.
	aField := BrEditor new
		hExact: 80;
		vExact: 24;
		yourself.
	aRow := CFMaSettingsRowElement new
		label: aLabel
		comment: nil
		field: aField
		multiline: false;
		yourself.

	aContent := aRow children first.
	self assert: aContent children includes: aField.
	self assert: aField constraints isIgnoredByLayout not.
	^ aRow
]

{ #category : 'examples - settings' }
CFMaPresentationExamples >> settingsBooleanUsesSharedRightTextInset [
	<gtExample>
	| aRow aLabel aField |
	aLabel := BrLabel new
		text: 'Enabled';
		aptitude: BrGlamorousLabelAptitude new;
		fitContent;
		yourself.
	aField := CFMaSettingsBooleanElement new.
	aRow := CFMaSettingsRowElement new
		label: aLabel
		comment: nil
		field: aField
		multiline: false;
		yourself.

	self assert: aField margin right equals: aRow editorTextHorizontalInset.
	^ aRow
]

{ #category : 'examples - settings' }
CFMaPresentationExamples >> settingsRowUsesSymmetricVerticalInsets [
	<gtExample>
	| aRow |
	aRow := CFMaSettingsRowElement new.
	self assert: aRow topInset equals: aRow bottomInset.
	^ aRow
]

{ #category : 'examples - settings' }
CFMaPresentationExamples >> settingsStandardRowHasFitContentTrailingRegion [
	<gtExample>
	| aLabel aField aRow aContent aTrailing |
	aLabel := BrLabel new
		text: 'Text';
		aptitude: BrGlamorousLabelAptitude new;
		fitContent;
		yourself.
	aField := BrLabel new
		text: 'Editable text';
		aptitude: BrGlamorousLabelAptitude new;
		fitContent;
		yourself.

	aRow := CFMaSettingsRowElement new
		label: aLabel
		comment: nil
		field: aField
		multiline: false;
		yourself.
	aContent := aRow children first.
	aTrailing := aContent children last.

	self assert: aContent class equals: BrHorizontalPane.
	self assert: aTrailing class equals: BrFrame.
	self assert: aTrailing constraints horizontal resizer isFitContent.
	^ aRow
]
