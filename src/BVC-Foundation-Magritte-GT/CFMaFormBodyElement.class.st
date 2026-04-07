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
		padding: (BlInsets top: 12 right: 14 bottom: 12 left: 14);
		cellSpacing: 8;
		hMatchParent;
		vFitContent
]
