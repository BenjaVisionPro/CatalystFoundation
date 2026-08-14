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
