Class {
	#name : 'CFMaExpanderItemViewModelStencilBuilder',
	#superclass : 'GtMagritteModelStencilBuilder',
	#category : 'BVC-Foundation-Magritte-GT-Stencils',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Stencils'
}

{ #category : 'api - instantiation' }
CFMaExpanderItemViewModelStencilBuilder >> buildDefault [
	^ CFMaExpanderItemViewModel forObject: self model
]
