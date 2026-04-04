Class {
	#name : 'CFMaFormFooterElement',
	#superclass : 'BrVerticalPane',
	#category : 'BVC-Foundation-Magritte-GT-Widgets',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Widgets'
}

{ #category : 'initialization' }
CFMaFormFooterElement >> initialize [
	super initialize.

	self magritte beToolbarContainer.

	self
		padding: (BlInsets top: 10 right: 14 bottom: 14 left: 14);
		cellSpacing: 8;
		background: (Color black alpha: 0.015);
		hMatchParent;
		vFitContent
]
