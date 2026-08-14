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
		background: (Color black alpha: 0.035);
		outskirts: BlOutskirts inside;
		addAptitude: CFLightBorderAptitude new beRaised;
		margin: (BlInsets all: 6);
		hFitContentLimited;
		vFitContent.

	aGrid := BrHorizontalGrid new.
	aGrid magritte
		beLabelContainer;
		beFieldContainer;
		beToolbarContainer.
	aGrid
		cellSpacing: 4;
		columnCount: 2;
		hFitContentLimited;
		vFitContent;
		padding: (BlInsets top: 14 right: 16 bottom: 14 left: 16).
	aForm addChild: aGrid.
	^ aForm
]
