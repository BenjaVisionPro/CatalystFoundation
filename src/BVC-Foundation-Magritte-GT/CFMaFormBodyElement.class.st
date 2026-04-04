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

	self magritte
		beLabelContainer;
		beFieldContainer.

	self
		padding: (BlInsets all: 14);
		cellSpacing: 8;
		hMatchParent;
		vFitContent
]
