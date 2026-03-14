Class {
	#name : 'CFMaFontAwesomeIconStencilBuilder',
	#superclass : 'GtMagritteModelStencilBuilder',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'api - instantiation' }
CFMaFontAwesomeIconStencilBuilder >> buildDefault [
	^ self model
		ifNil: [ CFMaBuilderUtility newChooseIconAffordanceFor: self description ]
		ifNotNil: [ CFMaBuilderUtility newFontAwesomeIconFor: self model using: self description ]
]
