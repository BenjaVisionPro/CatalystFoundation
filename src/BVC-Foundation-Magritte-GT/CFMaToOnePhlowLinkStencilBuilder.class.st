Class {
	#name : 'CFMaToOnePhlowLinkStencilBuilder',
	#superclass : 'GtMagritteDescriptionElementStencilBuilder',
	#category : 'BVC-Foundation-Magritte-GT-Stencils',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Stencils'
}

{ #category : 'api - instantiation' }
CFMaToOnePhlowLinkStencilBuilder >> buildDefault [
	(self memento isNil or: [ self description isNil ])
		ifTrue: [ ^ BrFrame new fitContent ].

	^ GtMagritteValidatedFieldElement new
		memento: self memento
		description: self description
		element: (CFMaBuilderUtility
			newPhlowLinkToOneMemento: self memento
			using: self description);
		hMatchParent;
		vFitContent;
		yourself
]
