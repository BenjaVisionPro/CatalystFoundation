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
		padding: (BlInsets top: 5 right: 11 bottom: 7 left: 11);
		cellSpacing: 7;
		hMatchParent;
		vFitContent
]
