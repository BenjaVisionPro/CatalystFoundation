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
		padding: BlInsets empty.

	aContainer magritte
		beLabelContainer;
		beFieldContainer;
		beToolbarContainer.

	^ aContainer
]
