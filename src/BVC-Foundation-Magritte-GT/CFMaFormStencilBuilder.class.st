Class {
	#name : 'CFMaFormStencilBuilder',
	#superclass : 'GtMagritteFormStencilBuilder',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'api - instantiation' }
CFMaFormStencilBuilder >> buildDefault [
	| aContainer |
	aContainer := BrVerticalPane new
		background: Color transparent;
		border: BlBorder empty;
		margin: BlInsets empty;
		cellSpacing: 4;
		hMatchParent;
		vFitContent;
		padding: (BlInsets top: 0 right: 16 bottom: 0 left: 16).

	aContainer magritte
		beLabelContainer;
		beFieldContainer;
		beToolbarContainer.

	^ aContainer
]
