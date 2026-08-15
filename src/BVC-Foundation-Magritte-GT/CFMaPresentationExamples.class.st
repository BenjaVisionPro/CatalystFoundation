"I provide executable examples for Foundation Magritte presentation strategies."

Class {
	#name : 'CFMaPresentationExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Magritte-GT-Examples',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Examples'
}

{ #category : 'examples - labels' }
CFMaPresentationExamples >> inlineLabelPresentation [
	<gtExample>
	^ CFMaInlineLabelPresentation new
]

{ #category : 'examples - labels' }
CFMaPresentationExamples >> leftLabelPresentation [
	<gtExample>
	^ CFMaLeftLabelPresentation new
]

{ #category : 'examples - groups' }
CFMaPresentationExamples >> inlineGroupPresentation [
	<gtExample>
	^ CFMaInlineGroupPresentation new
]

{ #category : 'examples - groups' }
CFMaPresentationExamples >> accordionGroupPresentation [
	<gtExample>
	^ CFMaAccordionGroupPresentation new
]

{ #category : 'examples - groups' }
CFMaPresentationExamples >> tabbedGroupPresentation [
	<gtExample>
	^ CFMaTabbedGroupPresentation new
]

{ #category : 'examples - forms' }
CFMaPresentationExamples >> accordionGroupsElement [
	<gtExample>
	| aViewModel |
	aViewModel := CFMaViewModel forObject: CFMaFormShowcase example.
	aViewModel beAccordionGroups.
	^ aViewModel asElement
]

{ #category : 'examples - forms' }
CFMaPresentationExamples >> tabbedGroupsElement [
	<gtExample>
	| aViewModel |
	aViewModel := CFMaViewModel forObject: CFMaFormShowcase example.
	aViewModel beTabbedGroups.
	^ aViewModel asElement
]

{ #category : 'examples - forms' }
CFMaPresentationExamples >> leftLabelsWithTabbedGroupsElement [
	<gtExample>
	| aViewModel |
	aViewModel := CFMaViewModel forObject: CFMaFormShowcase example.
	aViewModel
		beLeftLabels;
		beTabbedGroups.
	^ aViewModel asElement
]
