Class {
	#name : 'CFMaSettingsRightAlignedParagraphSegment',
	#superclass : 'BrTextEditorParagraphSegment',
	#category : 'BVC-Foundation-Magritte-GT-Elements',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Elements'
}

{ #category : 'accessing' }
CFMaSettingsRightAlignedParagraphSegment >> segmentType [
	^ CFMaSettingsRightAlignedParagraphSegmentType uniqueInstance
]
