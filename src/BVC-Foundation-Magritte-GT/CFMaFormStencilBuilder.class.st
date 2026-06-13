Class {
	#name : 'CFMaFormStencilBuilder',
	#superclass : 'GtMagritteFormStencilBuilder',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'api - instantiation' }
CFMaFormStencilBuilder >> buildDefault [
	| aFormElement aHeaderElement aBodyElement aFooterElement |
	aFormElement := CFMaFormElement new.
	aHeaderElement := CFMaFormHeaderElement new
		memento: memento;
		yourself.
	aBodyElement := CFMaFormBodyElement new.
	aFooterElement := CFMaFormFooterElement new.

	aFormElement
		addChild: aHeaderElement as: #header;
		addChild: aBodyElement as: #body;
		addChild: aFooterElement as: #footer.

	CFMaFormLayoutDebugOverlayElement enabled ifTrue: [
		aFormElement addChild: (CFMaFormLayoutDebugOverlayElement forTarget: aFormElement) ].

	^ aFormElement
]
