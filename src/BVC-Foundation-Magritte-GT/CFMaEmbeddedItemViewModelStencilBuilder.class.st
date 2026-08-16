"I am responsible for creating embedded relation view models inside their parent Magritte transaction."

Class {
	#name : 'CFMaEmbeddedItemViewModelStencilBuilder',
	#superclass : 'GtMagritteModelStencilBuilder',
	#category : 'BVC-Foundation-Magritte-GT-Stencils',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Stencils'
}

{ #category : 'api - instantiation' }
CFMaEmbeddedItemViewModelStencilBuilder >> buildDefault [
	| aChildMemento |
	aChildMemento := self memento
		ifNil: [ CFMaMemento model: self model ]
		ifNotNil: [
			self memento
				childMementoFor: self model
				inRelation: self description ].

	^ (CFMaViewModel
		forObject: self model
		memento: aChildMemento)
			presentationClass: CFMaAccordionPresentation;
			yourself
]
