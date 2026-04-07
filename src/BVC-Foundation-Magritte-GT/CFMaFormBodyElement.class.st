Class {
	#name : 'CFMaFormBodyElement',
	#superclass : 'BrVerticalPane',
	#category : 'BVC-Foundation-Magritte-GT-Widgets',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Widgets'
}

{ #category : 'initialization' }
CFMaFormBodyElement >> initialize [
	super initialize.

	self magritte beFieldContainer.

	self
		padding: (BlInsets all: 22);
		cellSpacing: 14;
		hMatchParent;
		vFitContent
]
