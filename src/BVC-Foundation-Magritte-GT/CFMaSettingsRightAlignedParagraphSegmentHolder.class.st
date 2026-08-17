Class {
	#name : 'CFMaSettingsRightAlignedParagraphSegmentHolder',
	#superclass : 'BrTextEditorParagraphSegmentHolder',
	#category : 'BVC-Foundation-Magritte-GT-Elements',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Elements'
}

{ #category : 'initialization' }
CFMaSettingsRightAlignedParagraphSegmentHolder >> createSegmentElement [
	^ CFMaSettingsRightAlignedParagraphElement new
		beInSeparateCompositionLayer;
		focusability: BlFocusability block;
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical fitContent ];
		aptitude: (BrLayoutResizerAptitude new
			hInherit;
			vAnyToFitContent);
		yourself
]
