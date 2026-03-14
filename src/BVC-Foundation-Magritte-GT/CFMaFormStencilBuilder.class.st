Class {
	#name : 'CFMaFormStencilBuilder',
	#superclass : 'GtMagritteFormStencilBuilder',
	#instVars : [
		'headerElement'
	],
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'api - instantiation' }
CFMaFormStencilBuilder >> buildDefault [
	| aContainer background |
	aContainer := BrVerticalPane new.
	"headerElement := CFMaFormHeaderElement new
			fieldViewModel: (GtMagritteFieldViewModel new
					memento: memento;
					description: memento magritteDescription)."

	aContainer magritte
		beLabelContainer;
		beFieldContainer;
		beToolbarContainer.

	background := Color black alpha: 0.02.

	aContainer
		geometry: (BlRoundedRectangleGeometry cornerRadius: 8.0);
		padding: (BlInsets all: 6);
		margin: (BlInsets all: 4);
		background: background;
		cellSpacing: 0;
		hFitContentLimited;
		vFitContent.

	"aContainer addChild: headerElement as: #header."
	^ aContainer
]
