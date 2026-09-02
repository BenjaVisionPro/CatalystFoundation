"I prove the existing-object Atelier entry path without introducing a parallel presentation system."
Class {
	#name : 'CFAtelierEntryExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Atelier-Examples',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'Examples'
}

{ #category : 'examples - entry' }
CFAtelierEntryExamples >> ordinaryObjectOpensAsAtelier [
	<gtExample>
	| model atelier |
	model := CFAtelierEntryExampleModel new.

	atelier := model asAtelier.

	self assert: atelier class equals: CFAtelierViewModel.
	^ atelier
]

{ #category : 'examples - entry' }
CFAtelierEntryExamples >> atelierUsesFoundationMementoAndContainerStencil [
	<gtExample>
	| model memento atelier stencil |
	model := CFAtelierEntryExampleModel new.
	memento := CFMaMemento model: model.
	atelier := CFAtelierViewModel forObject: model memento: memento.

	stencil := atelier formContainerStencilForMemento: memento.

	self assert: stencil class equals: CFMaFormStencilBuilder.
	self assert: memento model == model.
	^ atelier
]

{ #category : 'examples - entry' }
CFAtelierEntryExamples >> atelierCreatesFoundationFormRoot [
	<gtExample>
	| element |
	element := CFAtelierEntryExampleModel new asAtelier asElement.

	self assert: element class equals: CFMaFormRootElement.
	^ element
]

{ #category : 'examples - palette UI' }
CFAtelierEntryExamples >> atelierWithPalette [
	<gtExample>
	| palette atelier element |
	palette := CFAtelierPalette new.
	palette add: (CFAtelierPaletteItem
		label: 'New example'
		provider: (CFAtelierFactoryProvider factory: [ CFAtelierEntryExampleModel new ])).
	atelier := CFAtelierEntryExampleModel new asAtelier
		palette: palette;
		yourself.

	element := atelier asElement.
	self assert: element class equals: CFAtelierElement.
	self assert: element formElement class equals: CFMaFormRootElement.
	self assert: element paletteElement palette == palette.
	^ element
]

{ #category : 'examples - palette UI' }
CFAtelierEntryExamples >> paletteDragMaterializesCandidateOnce [
	<gtExample>
	| count provider item paletteElement sourceElement dragItem |
	count := 0.
	provider := CFAtelierFactoryProvider factory: [
		count := count + 1.
		CFAtelierEntryExampleModel new ].
	item := CFAtelierPaletteItem label: 'New example' provider: provider.
	paletteElement := CFAtelierPaletteElement new.
	sourceElement := BlElement new.

	dragItem := paletteElement dragItemFor: item sourceElement: sourceElement.

	self assert: count equals: 1.
	self assert: dragItem sourceElement == sourceElement.
	self assert: dragItem domainObject class equals: CFAtelierEntryExampleModel.
	^ dragItem
]
