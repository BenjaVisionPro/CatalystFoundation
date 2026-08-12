Class {
	#name : 'CFMaFormStencilBuilder',
	#superclass : 'GtMagritteFormStencilBuilder',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'api - instantiation' }
CFMaFormStencilBuilder >> buildDefault [
	| aForm aGrid |
	"GT Magritte owns field construction. A form stencil only supplies the
	three standard insertion points that GtMagritteElementBuilder uses."
	aForm := BrVerticalPane new
		geometry: (BlRoundedRectangleGeometry cornerRadius: 10);
		background: (Color black alpha: 0.025);
		border: (BlBorder paint: (Color black alpha: 0.13) width: 1);
		margin: (BlInsets all: 8);
		hFitContentLimited;
		vFitContent.

	aGrid := BrHorizontalGrid new.
	aGrid magritte
		beLabelContainer;
		beFieldContainer;
		beToolbarContainer.
	aGrid
		cellSpacing: 0;
		columnCount: 2;
		hFitContentLimited;
		vFitContent;
		padding: (BlInsets top: 12 right: 14 bottom: 12 left: 14).
	aForm addChild: aGrid.
	^ aForm
]
