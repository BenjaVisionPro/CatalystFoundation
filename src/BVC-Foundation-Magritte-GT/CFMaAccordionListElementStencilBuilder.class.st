Class {
	#name : 'CFMaAccordionListElementStencilBuilder',
	#superclass : 'GtMagritteListElementStencilBuilder',
	#category : 'BVC-Foundation-Magritte-GT-Stencils',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Stencils'
}

{ #category : 'api - instantiation' }
CFMaAccordionListElementStencilBuilder >> buildDefault [
	<return: #BlElement>
	| anAccordionElement |
	(self memento isNil or: [ self description isNil ])
		ifTrue: [ ^ BrFrame new fitContent ].

	anAccordionElement := CFMaBuilderUtility
		newAccordionListMemento: self memento
		using: self description.
	anAccordionElement
		hMatchParent;
		vFitContent;
		background: Color transparent.

	^ anAccordionElement
]
