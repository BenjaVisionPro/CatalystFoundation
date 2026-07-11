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
	| aModel aDescription aViewModel firstAccordion secondAccordion |
	aModel := CFMaAccordionExampleContainer new.
	aDescription := aModel descriptionItems.
	aViewModel := aDescription blocItemViewModelStencil
		model: aModel items first;
		description: aDescription;
		memento: nil;
		build.
	firstAccordion := CFMaBuilderUtility
		newAccordionForItemViewModel: aViewModel.

	self assert: firstAccordion isExpanded not.
	firstAccordion expand.
	self assert: aViewModel expanded.

	secondAccordion := CFMaBuilderUtility
		newAccordionForItemViewModel: aViewModel.
	self assert: secondAccordion isExpanded.
	^ secondAccordion
]

{ #category : 'examples' }
CFMaAccordionListExamples >> accordionItemUsesCompactHeader [
	<gtExample>
	| aModel aDescription aViewModel anAccordion aHeader aCompactElement |
	aModel := CFMaAccordionExampleContainer new.
	aDescription := aModel descriptionItems.
	aViewModel := aDescription blocItemViewModelStencil
		model: aModel items first;
		description: aDescription;
		memento: nil;
		build.
	anAccordion := CFMaBuilderUtility
		newAccordionForItemViewModel: aViewModel.
	aHeader := CFMaBuilderUtility
		newAccordionHeaderFor: aViewModel
		accordion: anAccordion.
	aCompactElement := aHeader children
		detect: [ :each | each isKindOf: CFCompactObjectElement ].

	self assert: aCompactElement memento == aViewModel itemMemento.
	self assert: aCompactElement titleText equals: 'First item'.
	^ aHeader
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

	self assert: aViewModel class equals: CFMaAccordionItemViewModel.
	self assert: aViewModel itemMemento model == aModel items first.
	self assert: aViewModel expanded not.
	^ aViewModel
]
