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
