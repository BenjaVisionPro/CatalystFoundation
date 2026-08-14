Class {
	#name : 'CFMaGridElementStencilBuilder',
	#superclass : 'GtMagritteListElementStencilBuilder',
	#category : 'BVC-Foundation-Magritte-GT-Stencils',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Stencils'
}

{ #category : 'api - instantiation' }
CFMaGridElementStencilBuilder >> buildDefault [
	<return: #BlElement>
	| aGridElement |
	(self memento isNil or: [ self description isNil ])
		ifTrue: [ ^ BrFrame new fitContent ].

	aGridElement := CFMaBuilderUtility
		newGridListMemento: self memento
		using: self description.

	^ GtMagritteValidatedFieldElement new
		memento: self memento
		description: self description
		element: aGridElement;
		hMatchParent;
		vFitContentLimited;
		yourself
]
