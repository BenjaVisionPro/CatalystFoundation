"
I am responsible for presenting a finite single-column Foundation relation list whose outer form owns scrolling.
"
Class {
	#name : 'CFMaFiniteListElementStencilBuilder',
	#superclass : 'GtMagritteListElementStencilBuilder',
	#category : 'BVC-Foundation-Magritte-GT-Stencils',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Stencils'
}

{ #category : 'api - instantiation' }
CFMaFiniteListElementStencilBuilder >> buildDefault [
	<return: #BlElement>
	| aListElement |
	(self memento isNil or: [ self description isNil ])
		ifTrue: [ ^ BrFrame new fitContent ].

	aListElement := CFMaBuilderUtility
		newFiniteListMemento: self memento
		using: self description.

	aListElement
		hMatchParent;
		vFitContent.
	^ aListElement
]
