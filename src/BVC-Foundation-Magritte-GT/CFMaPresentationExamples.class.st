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
CFMaPresentationExamples >> settingsMemoCompactArrangement [
	<gtExample>
	| aRow aLabelColumn aFieldColumn aComment aPresentation |
	aPresentation := CFMaSettingsPresentation new.
	aRow := BrVerticalPane new.
	aLabelColumn := BrVerticalPane new.
	aFieldColumn := BrFrame new.
	aComment := BrEditor new.
	aRow addChild: aComment.

	aPresentation
		arrangeCompactMemoRow: aRow
		labelColumn: aLabelColumn
		fieldColumn: aFieldColumn
		comment: aComment.

	self assert: aComment parent equals: aRow.
	^ aRow
]

{ #category : 'examples - settings' }
CFMaPresentationExamples >> settingsMemoWrappedArrangement [
	<gtExample>
	| aRow aLabelColumn aFieldColumn aComment aPresentation |
	aPresentation := CFMaSettingsPresentation new.
	aRow := BrVerticalPane new.
	aLabelColumn := BrVerticalPane new.
	aFieldColumn := BrFrame new.
	aComment := BrEditor new.
	aRow addChild: aComment.

	aPresentation
		arrangeWrappedMemoRow: aRow
		labelColumn: aLabelColumn
		fieldColumn: aFieldColumn
		comment: aComment.

	self assert: aComment parent equals: aLabelColumn.
	^ aRow
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
CFMaPresentationExamples >> settingsSingleRowHasBothEdgeInsets [
	<gtExample>
	| aPresentation aContainer aRow |
	aPresentation := CFMaSettingsPresentation new.
	aContainer := BrVerticalPane new.
	aRow := BrFrame new.
	aPresentation addRow: aRow to: aContainer.

	self assert: aRow padding top equals:
		aPresentation rowTopInset + aPresentation rowEdgeInset.
	self assert: aRow padding bottom equals:
		aPresentation rowBottomInset + aPresentation rowEdgeInset.
	^ aRow
]

{ #category : 'examples - settings' }
CFMaPresentationExamples >> settingsFirstAndLastRowsOwnCardEdgeSpacing [
	<gtExample>
	| aPresentation aContainer aFirstRow aLastRow |
	aPresentation := CFMaSettingsPresentation new.
	aContainer := BrVerticalPane new.
	aFirstRow := BrFrame new.
	aLastRow := BrFrame new.

	aPresentation addRow: aFirstRow to: aContainer.
	aPresentation addRow: aLastRow to: aContainer.

	self assert: aFirstRow padding top equals:
		aPresentation rowTopInset + aPresentation rowEdgeInset.
	self assert: aFirstRow padding bottom equals:
		aPresentation rowBottomInset.
	self assert: aLastRow padding top equals:
		aPresentation rowTopInset.
	self assert: aLastRow padding bottom equals:
		aPresentation rowBottomInset + aPresentation rowEdgeInset.
	^ aContainer
]

{ #category : 'examples - settings' }
CFMaPresentationExamples >> settingsRowsShareExactBaseInsets [
	<gtExample>
	| aPresentation aRow |
	aPresentation := CFMaSettingsPresentation new.
	aRow := aPresentation newRow.

	self assert: aRow padding top equals: aPresentation rowTopInset.
	self assert: aRow padding left equals: aPresentation rowHorizontalInset.
	self assert: aRow padding bottom equals: aPresentation rowBottomInset.
	self assert: aRow padding right equals: aPresentation rowHorizontalInset.
	^ aRow
]

{ #category : 'examples - settings' }
CFMaPresentationExamples >> settingsEdgeInsetsOnlyExtendBaseRowInsets [
	<gtExample>
	| aPresentation aContainer aFirst aMiddle aLast |
	aPresentation := CFMaSettingsPresentation new.
	aContainer := BrVerticalPane new.
	aFirst := aPresentation newRow.
	aMiddle := aPresentation newRow.
	aLast := aPresentation newRow.

	aPresentation addRow: aFirst to: aContainer.
	aPresentation addRow: aMiddle to: aContainer.
	aPresentation addRow: aLast to: aContainer.

	self assert: aFirst padding top equals:
		aPresentation rowTopInset + aPresentation rowEdgeInset.
	self assert: aFirst padding bottom equals: aPresentation rowBottomInset.
	self assert: aMiddle padding top equals: aPresentation rowTopInset.
	self assert: aMiddle padding bottom equals: aPresentation rowBottomInset.
	self assert: aLast padding top equals: aPresentation rowTopInset.
	self assert: aLast padding bottom equals:
		aPresentation rowBottomInset + aPresentation rowEdgeInset.
	^ aContainer
]
