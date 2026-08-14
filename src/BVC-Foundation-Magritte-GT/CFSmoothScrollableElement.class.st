Class {
	#name : 'CFSmoothScrollableElement',
	#superclass : 'BlScrollableElement',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'initialization' }
CFSmoothScrollableElement >> initialize [
	super initialize.

	self removeEventHandlersSuchThat: [ :anEventHandler |
		anEventHandler class = BlScrollableElementEventHandler ].
	self addEventHandler: CFSmoothScrollableElementEventHandler new
]
