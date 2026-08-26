Class {
	#name : 'CFMaTextEditorParagraphSegmentHolder',
	#superclass : 'BrTextEditorParagraphSegmentHolder',
	#category : 'BVC-Foundation-Magritte-GT-Elements',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Elements'
}

{ #category : 'initialization' }
CFMaTextEditorParagraphSegmentHolder >> createSegmentElement [
	^ CFMaTextEditorParagraphElement new
		beInSeparateCompositionLayer;
		clipChildren: false;
		focusability: BlFocusability block;
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical fitContent ];
		aptitude: (BrLayoutResizerAptitude new
			hInherit;
			vAnyToFitContent);
		yourself
]
