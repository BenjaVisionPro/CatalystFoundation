Class {
	#name : 'CFMaFormStencilBuilder',
	#superclass : 'GtMagritteFormStencilBuilder',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'api - instantiation' }
CFMaFormStencilBuilder >> buildDefault [
	| aFormElement aHeaderElement aBodyElement aBodyScrollableElement aFooterElement |
	aFormElement := CFMaFormElement new.
	aHeaderElement := CFMaFormHeaderElement new
		memento: memento;
		yourself.
	aBodyElement := CFMaFormBodyElement new.
	aBodyScrollableElement := BlScrollableElement new
		addChild: aBodyElement;
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical matchParent ];
		yourself.
	aFooterElement := CFMaFormFooterElement new.

	aFormElement
		addChild: aHeaderElement as: #header;
		addChild: aBodyScrollableElement as: #body;
		addChild: aFooterElement as: #footer.

	aFormElement
		addChild: ((CFMaFormLayoutDebugOverlayElement forTarget: aFormElement)
			zIndex: 1000;
			yourself)
		as: #layoutDebugOverlay.

	^ aFormElement
]
