"I am responsible for presenting a to-one relation as an embedded Foundation Magritte form."

Class {
	#name : 'CFMaToOneEmbeddedFormStencilBuilder',
	#superclass : 'GtMagritteDescriptionElementStencilBuilder',
	#category : 'BVC-Foundation-Magritte-GT-Stencils',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Stencils'
}

{ #category : 'api - instantiation' }
CFMaToOneEmbeddedFormStencilBuilder >> buildDefault [
	(self memento isNil or: [ self description isNil ])
		ifTrue: [ ^ BrFrame new fitContent ].

	^ GtMagritteValidatedFieldElement new
		memento: self memento
		description: self description
		element: (CFMaBuilderUtility
			newEmbeddedFormToOneMemento: self memento
			using: self description);
		hMatchParent;
		vFitContent;
		yourself
]
