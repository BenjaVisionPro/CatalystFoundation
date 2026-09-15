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

	self assert: element class equals: CFAtelierElement.
	self assert: element formElement class equals: CFMaFormRootElement.
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

{ #category : 'examples - palette UI' }
CFAtelierEntryExamples >> paletteSourceRetainsConfiguredItemIdentity [
	<gtExample>
	| item paletteElement sourceElement |
	item := CFAtelierPaletteItem
		label: 'New example'
		provider: (CFAtelierFactoryProvider factory: [ CFAtelierEntryExampleModel new ]).
	paletteElement := CFAtelierPaletteElement new.
	sourceElement := paletteElement newItemElementFor: item.

	self assert: (sourceElement userData at: #atelierPaletteSource) equals: true.
	self assert: (sourceElement userData at: #atelierPaletteItem) == item.
	^ sourceElement
]


{ #category : 'examples - live composition' }
CFAtelierEntryExamples >> replacingWorkspaceRetainsAtelierContext [
	<gtExample>
	| model atelier element firstWorkspace secondWorkspace content contextScroll |
	model := CFAtelierEntryExampleModel new.
	firstWorkspace := BlElement new.
	atelier := model asAtelier
		workspaceElementFactory: [ :anAtelier | firstWorkspace ];
		yourself.
	element := atelier asElement.
	content := element children first.
	contextScroll := content children first.

	secondWorkspace := BlElement new.
	element workspaceElement: secondWorkspace.

	self assert: element children first == content.
	self assert: content children first == contextScroll.
	self assert: element workspaceElement == secondWorkspace.
	^ element
]

{ #category : 'examples - live composition' }
CFAtelierEntryExamples >> replacingPalettePreservesAtelierPosition [
	<gtExample>
	| firstPalette secondPalette element position |
	firstPalette := CFAtelierPalette new.
	secondPalette := CFAtelierPalette new.
	element := CFAtelierEntryExampleModel new asAtelier
		palette: firstPalette;
		asElement.
	position := 73 @ 41.
	element paletteElement relocate: position.

	element palette: secondPalette.

	self assert: element paletteElement palette == secondPalette.
	self assert: element paletteElement measuredPosition equals: position.
	^ element
]

{ #category : 'examples - live composition' }
CFAtelierEntryExamples >> clearingPaletteRemovesLivePaletteElement [
	<gtExample>
	| palette element |
	palette := CFAtelierPalette new.
	element := CFAtelierEntryExampleModel new asAtelier
		palette: palette;
		asElement.

	element palette: nil.

	self assert: element paletteElement isNil.
	^ element
]


{ #category : 'examples - live composition' }
CFAtelierEntryExamples >> workspaceClientIsBuiltBeforeInstallation [
	<gtExample>
	| host client workspace |
	host := CFAtelierElement new.
	client := CFAtelierEntryExampleModel new asAtelier.
	workspace := client installAsWorkspaceClientIn: host.

	self assert: host workspaceElement == workspace.
	self assert: workspace children isNotEmpty.
	^ host
]
