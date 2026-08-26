Class {
	#name : 'CFMaTextEditorParagraphSegment',
	#superclass : 'BrTextEditorParagraphSegment',
	#category : 'BVC-Foundation-Magritte-GT-Elements',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Elements'
}

{ #category : 'accessing' }
CFMaTextEditorParagraphSegment >> segmentType [
	^ CFMaTextEditorParagraphSegmentType uniqueInstance
]
