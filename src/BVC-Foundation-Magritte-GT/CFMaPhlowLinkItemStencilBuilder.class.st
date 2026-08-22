"
I am responsible for presenting one relation item as passive Foundation Phlow-link content; the enclosing relation item owns selection, focus and activation.
"
Class {
	#name : 'CFMaPhlowLinkItemStencilBuilder',
	#superclass : 'BrListRowStencilBuilder',
	#category : 'BVC-Foundation-Magritte-GT-Stencils',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Stencils'
}

{ #category : 'api - instantiation' }
CFMaPhlowLinkItemStencilBuilder >> buildDefault [
	self rowValue ifNil: [ ^ BrFrame new fitContent ].
	^ CFCompactObjectStencil new
		object: self rowValue object;
		create
]
