Class {
	#name : 'CFMaFormFooterElement',
	#superclass : 'BrHorizontalPane',
	#category : 'BVC-Foundation-Magritte-GT-Widgets',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Widgets'
}

{ #category : 'initialization' }
CFMaFormFooterElement >> initialize [
	super initialize.
	self magritte beToolbarContainer.
	self
		padding: (BlInsets top: 7 right: 11 bottom: 9 left: 11);
		cellSpacing: 6;
		hMatchParent;
		vFitContent
]
