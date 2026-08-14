Class {
	#name : 'CFMaExpandableListElementStencilBuilder',
	#superclass : 'GtMagritteListElementStencilBuilder',
	#category : 'BVC-Foundation-Magritte-GT-Stencils',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Stencils'
}

{ #category : 'api - instantiation' }
CFMaExpandableListElementStencilBuilder >> buildDefault [
	<return: #BlElement>
	| aListElement |
	(self memento isNil or: [ self description isNil ])
		ifTrue: [ ^ BrFrame new fitContent ].

	aListElement := CFMaBuilderUtility
		newExpandableListMemento: self memento
		using: self description.
	aListElement
		matchParent;
		background: Color transparent.

	^ GtMagritteValidatedFieldElement new
		memento: self memento
		description: self description
		element: aListElement;
		matchParent;
		yourself
]
