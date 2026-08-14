"I am responsible for presenting one relation item as an embedded Foundation Magritte form."

Class {
	#name : 'CFMaEmbeddedFormItemStencilBuilder',
	#superclass : 'BrListRowStencilBuilder',
	#category : 'BVC-Foundation-Magritte-GT-Stencils',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Stencils'
}

{ #category : 'api - instantiation' }
CFMaEmbeddedFormItemStencilBuilder >> buildDefault [
	| anEmbeddedElement |
	self rowValue ifNil: [ ^ BrFrame new fitContent ].
	anEmbeddedElement := self rowValue asEmbeddedElement.

	^ BrFrame new
		hMatchParent;
		vFitContent;
		margin: (BlInsets bottom: 6);
		addChild: anEmbeddedElement;
		yourself
]
