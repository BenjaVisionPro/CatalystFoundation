"I provide executable examples of Foundation layouts and item representations for Magritte to-many relations."

Class {
	#name : 'CFMaToManyRelationExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Magritte-GT-Examples',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Examples'
}

{ #category : 'examples' }
CFMaToManyRelationExamples >> expandableListDescription [
	<gtExample>
	| aDescription |
	aDescription := MAToManyRelationDescription new
		accessor: #items;
		classes: { CFMagritteEditorExample };
		beModifiable;
		beExpandableList;
		yourself.

	self assert: aDescription blocListStencil class equals: CFMaExpandableListElementStencilBuilder.
	self assert: aDescription blocItemViewModelStencil class equals: CFMaExpanderItemViewModelStencilBuilder.
	^ aDescription
]

{ #category : 'examples' }
CFMaToManyRelationExamples >> gridDescription [
	<gtExample>
	| aDescription |
	aDescription := MAToManyRelationDescription new
		accessor: #items;
		classes: { CFMagritteEditorExample };
		beModifiable;
		beGrid;
		yourself.

	self assert: aDescription blocListStencil class equals: CFMaGridElementStencilBuilder.
	self assert: aDescription blocItemViewModelStencil class equals: GtMagritteModelStencilBuilder.
	^ aDescription
]

{ #category : 'examples' }
CFMaToManyRelationExamples >> expandableListElement [
	<gtExample>
	| aModel aDescription aMemento anElement |
	aModel := CFMaAccordionExampleContainer new.
	aDescription := self expandableListDescription.
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
CFMaToManyRelationExamples >> gridElement [
	<gtExample>
	| aModel aDescription aMemento anElement |
	aModel := CFMaAccordionExampleContainer new.
	aDescription := self gridDescription.
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
CFMaToManyRelationExamples >> ordinaryDescriptionUsesFoundationDefaults [
	<gtExample>
	| aDescription |
	aDescription := MAToManyRelationDescription new.

	self assert: aDescription blocListStencil class equals: CFMaListElementStencilBuilder.
	self assert: aDescription blocItemViewModelStencil class equals: GtMagritteModelStencilBuilder.
	^ aDescription
]

{ #category : 'examples' }
CFMaToManyRelationExamples >> simpleListDescription [
	<gtExample>
	| aDescription |
	aDescription := self expandableListDescription.
	aDescription beSimpleList.

	self assert: aDescription blocListStencil class equals: CFMaListElementStencilBuilder.
	self assert: aDescription blocItemViewModelStencil class equals: GtMagritteModelStencilBuilder.
	^ aDescription
]

{ #category : 'examples' }
CFMaToManyRelationExamples >> columnedListDescription [
	<gtExample>
	| aDescription |
	aDescription := self expandableListDescription.
	aDescription beColumnedList.

	self assert: aDescription blocListStencil class equals: CFMaColumnedListElementStencilBuilder.
	self assert: aDescription blocItemViewModelStencil class equals: GtMagritteModelStencilBuilder.
	^ aDescription
]

{ #category : 'examples' }
CFMaToManyRelationExamples >> accordionListDescription [
	<gtExample>
	| aDescription |
	aDescription := MAToManyRelationDescription new
		accessor: #items;
		classes: { CFMagritteEditorExample };
		beModifiable;
		beAccordionList;
		yourself.

	self assert: aDescription blocListStencil class equals: CFMaAccordionListElementStencilBuilder.
	self assert: aDescription blocItemViewModelStencil class equals: CFMaExpanderItemViewModelStencilBuilder.
	^ aDescription
]



{ #category : 'examples' }
CFMaToManyRelationExamples >> embeddedFormsDescription [
	<gtExample>
	| aDescription |
	aDescription := MAToManyRelationDescription new
		accessor: #items;
		classes: { CFMagritteEditorExample };
		beModifiable;
		beSimpleList;
		itemsAsEmbeddedForms;
		yourself.

	self assert: aDescription blocListStencil class equals: CFMaListElementStencilBuilder.
	self assert: aDescription blocItemStencil class equals: CFMaEmbeddedFormItemStencilBuilder.
	self assert: aDescription blocItemViewModelStencil class equals: CFMaEmbeddedItemViewModelStencilBuilder.
	^ aDescription
]

{ #category : 'examples' }
CFMaToManyRelationExamples >> gridOfEmbeddedFormsDescription [
	<gtExample>
	| aDescription |
	aDescription := MAToManyRelationDescription new
		accessor: #items;
		classes: { CFMagritteEditorExample };
		beModifiable;
		beGrid;
		itemsAsEmbeddedForms;
		yourself.

	self assert: aDescription blocListStencil class equals: CFMaGridElementStencilBuilder.

	self assert: aDescription relationBodyInsets equals: BlInsets empty.
	self assert: aDescription relationGridItemInsets equals: BlInsets empty.
	self assert: aDescription blocItemStencil class equals: CFMaEmbeddedFormItemStencilBuilder.
	self assert: aDescription blocItemViewModelStencil class equals: CFMaEmbeddedItemViewModelStencilBuilder.
	^ aDescription
]

{ #category : 'examples' }
CFMaToManyRelationExamples >> phlowLinksDescription [
	<gtExample>
	| aDescription |
	aDescription := MAToManyRelationDescription new
		accessor: #items;
		classes: { CFMagritteEditorExample };
		beModifiable;
		beSimpleList;
		itemsAsPhlowLinks;
		yourself.

	self assert: aDescription blocListStencil class equals: CFMaListElementStencilBuilder.
	self assert: aDescription blocItemStencil class equals: CFMaPhlowLinkItemStencilBuilder.
	^ aDescription
]

{ #category : 'examples' }
CFMaToManyRelationExamples >> gridOfPhlowLinksDescription [
	<gtExample>
	| aDescription |
	aDescription := MAToManyRelationDescription new
		accessor: #items;
		classes: { CFMagritteEditorExample };
		beModifiable;
		beGrid;
		itemsAsPhlowLinks;
		yourself.

	self assert: aDescription blocListStencil class equals: CFMaGridElementStencilBuilder.
	self assert: aDescription blocItemStencil class equals: CFMaPhlowLinkItemStencilBuilder.
	^ aDescription
]

{ #category : 'examples' }
CFMaToManyRelationExamples >> compactItemsCanReplaceAnotherItemRepresentation [
	<gtExample>
	| aDescription |
	aDescription := self embeddedFormsDescription.
	aDescription itemsAsCompactObjects.

	self assert: aDescription blocItemViewModelStencil class equals: GtMagritteModelStencilBuilder.
	self assert: aDescription blocItemStencil class equals: BrListRowStencilBuilder.
	^ aDescription
]
