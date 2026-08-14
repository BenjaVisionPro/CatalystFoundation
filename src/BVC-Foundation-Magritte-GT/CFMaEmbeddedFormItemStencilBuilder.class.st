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
	| anObject |
	self rowValue ifNil: [ ^ BrFrame new fitContent ].
	anObject := self rowValue object.
	^ (CFMaViewModel forObject: anObject) asEmbeddedElement
]
