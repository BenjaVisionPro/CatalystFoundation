"I am responsible for presenting a to-one relation as a compact Foundation list editor."

Class {
	#name : 'CFMaToOneElementStencilBuilder',
	#superclass : 'GtMagritteListElementStencilBuilder',
	#category : 'BVC-Foundation-Magritte-GT-Stencils',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Stencils'
}

{ #category : 'api - instantiation' }
CFMaToOneElementStencilBuilder >> buildDefault [
	<return: #BlElement>
	(self memento isNil or: [ self description isNil ])
		ifTrue: [ ^ BrFrame new fitContent ].

	^ GtMagritteValidatedFieldElement new
		memento: self memento
		description: self description
		element: (CFMaBuilderUtility
			newCompactListToOneMemento: self memento
			using: self description);
		hMatchParent;
		vFitContent;
		yourself
]
