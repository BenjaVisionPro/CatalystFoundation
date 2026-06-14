Class {
	#name : 'CFMaFormElement',
	#superclass : 'BrVerticalPane',
	#category : 'BVC-Foundation-Magritte-GT-Widgets',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Widgets'
}

{ #category : 'initialization' }
CFMaFormElement >> initialize [
	super initialize.

	self
		geometry: (BlRoundedRectangleGeometry cornerRadius: 10.0);
		background: (Color black alpha: 0.03);
		margin: (BlInsets all: 6);
		cellSpacing: 0;
		hMatchParent;
		vMatchParent
]
