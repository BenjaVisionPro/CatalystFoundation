Class {
	#name : 'CFMaFormStencilBuilder',
	#superclass : 'GtMagritteFormStencilBuilder',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'api - instantiation' }
CFMaFormStencilBuilder >> buildDefault [
	"GT Magritte owns field construction. A form stencil only supplies the
	three standard insertion points that GtMagritteElementBuilder uses."
	| aContainer |
	aContainer := BrHorizontalGrid new.
	aContainer magritte
		beLabelContainer;
		beFieldContainer;
		beToolbarContainer.
	aContainer
		cellSpacing: 0;
		columnCount: 2;
		hFitContentLimited;
		vFitContent;
		padding: (BlInsets all: 8).
	^ aContainer
]
