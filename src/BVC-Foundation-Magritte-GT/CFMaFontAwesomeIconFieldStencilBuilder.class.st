Class {
	#name : 'CFMaFontAwesomeIconFieldStencilBuilder',
	#superclass : 'GtMagritteDescriptionElementStencilBuilder',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'api - instantiation' }
CFMaFontAwesomeIconFieldStencilBuilder >> buildDefault [
	^ CFMaFontAwesomeIconFieldElement new
		fieldViewModel: (GtMagritteFieldViewModel new
				memento: self memento;
				description: self description;
				yourself);
		yourself
]
