Class {
	#name : 'CFMaAccordionItemViewModelStencilBuilder',
	#superclass : 'GtMagritteModelStencilBuilder',
	#category : 'BVC-Foundation-Magritte-GT-Stencils',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Stencils'
}

{ #category : 'api - instantiation' }
CFMaAccordionItemViewModelStencilBuilder >> buildDefault [
	^ CFMaAccordionItemViewModel forObject: self model
]
