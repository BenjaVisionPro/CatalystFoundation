Class {
	#name : 'CFMaColumnedListItemElementStencilBuilder',
	#superclass : 'BrColumnedListRowElementStencilBuilder',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'api - instantiation' }
CFMaColumnedListItemElementStencilBuilder >> buildDefault [
	^ super buildDefault
		addAptitude: CFMaFocusAwareListItemAptitude
]
