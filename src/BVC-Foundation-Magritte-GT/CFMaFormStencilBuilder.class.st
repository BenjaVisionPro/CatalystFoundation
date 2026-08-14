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
		background: Color transparent;
		border: BlBorder empty;
		margin: BlInsets empty;
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
