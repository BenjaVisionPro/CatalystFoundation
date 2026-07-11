Class {
	#name : 'CFMaAccordionListExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Magritte-GT-Examples',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Examples'
}

{ #category : 'examples' }
CFMaAccordionListExamples >> accordionItemExpansionSurvivesElementRecreation [
	<gtExample>
	| aModel aDescription aViewModel firstExpander secondExpander |
	aModel := CFMaAccordionExampleContainer new.
	aDescription := aModel descriptionItems.
	aViewModel := aDescription blocItemViewModelStencil
		model: aModel items first;
		description: aDescription;
		memento: nil;
		build.
	firstExpander := CFMaExpanderItemElement new
		expanderItemViewModel: aViewModel.

	self assert: firstExpander isExpanded not.
	firstExpander expand.
	self assert: aViewModel expanded.

	secondExpander := CFMaExpanderItemElement new
		expanderItemViewModel: aViewModel.
	self assert: secondExpander isExpanded.
	^ secondExpander
]

{ #category : 'examples' }
CFMaAccordionListExamples >> accordionItemUsesCompactHeader [
	<gtExample>
	| aModel aDescription aViewModel anExpander aCompactElement |
	aModel := CFMaAccordionExampleContainer new.
	aDescription := aModel descriptionItems.
	aViewModel := aDescription blocItemViewModelStencil
		model: aModel items first;
		description: aDescription;
		memento: nil;
		build.
	anExpander := CFMaExpanderItemElement new
		expanderItemViewModel: aViewModel.
	aCompactElement := anExpander collapsedElement.

	self assert: aCompactElement memento == aViewModel itemMemento.
	self assert: aCompactElement titleText equals: 'First item'.
	^ anExpander
]

{ #category : 'examples' }
CFMaAccordionListExamples >> accordionRelationElement [
	<gtExample>
	| aModel aDescription aMemento anElement |
	aModel := CFMaAccordionExampleContainer new.
	aDescription := aModel descriptionItems.
	aMemento := GtMagritteMemento
		model: aModel
		description: aDescription asContainer.
	anElement := aDescription blocListStencil
		memento: aMemento;
		description: aDescription;
		asElement.

	self assert: anElement class equals: GtMagritteValidatedFieldElement.
	^ anElement
]

{ #category : 'examples' }
CFMaAccordionListExamples >> accordionRelationItemViewModel [
	<gtExample>
	| aModel aDescription aViewModel |
	aModel := CFMaAccordionExampleContainer new.
	aDescription := aModel descriptionItems.
	aViewModel := aDescription blocItemViewModelStencil
		model: aModel items first;
		description: aDescription;
		memento: nil;
		build.

	self assert: aViewModel class equals: CFMaExpanderItemViewModel.
	self assert: aViewModel elementClass equals: CFMaExpanderItemElement.
	self assert: aViewModel itemMemento model == aModel items first.
	self assert: aViewModel expanded not.
	^ aViewModel
]
