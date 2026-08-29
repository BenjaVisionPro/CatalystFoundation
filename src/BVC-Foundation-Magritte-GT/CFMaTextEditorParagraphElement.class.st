Class {
	#name : 'CFMaTextEditorParagraphElement',
	#superclass : 'BrTextEditorParagraphElement',
	#category : 'BVC-Foundation-Magritte-GT-Elements',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Elements'
}

{ #category : 'defaults' }
CFMaTextEditorParagraphElement >> defaultSelectionColor [
	^ self theme editor textSelectionColor blocResolveColorForTheme: self theme
]


{ #category : 'drawing' }
CFMaTextEditorParagraphElement >> drawChildrenOnSpartaCanvas: aCanvas [
	aCanvas clip
		when: [ self clipChildren ]
		by: [ self geometry pathOnSpartaCanvas: aCanvas of: self ]
		during: [
			self drawSelectionOnSpartaCanvas: aCanvas.

			paragraph
				valueDo: [ :aParagraph |
					aParagraph
						paintOn: aCanvas
						at: self padding topLeft ]
				ifNone: [ self requestLayout ].

			self children sortedByElevation do: [ :anElement |
				(self canAddTextToParagraph: anElement)
					ifFalse: [ anElement fullDrawOnSpartaCanvas: aCanvas ] ] ]
]

{ #category : 'drawing' }
CFMaTextEditorParagraphElement >> paintChildrenOn: aCompositorPainter offset: anOffset [
	self
		paintSelectionOn: aCompositorPainter
		offset: anOffset + self padding topLeft.

	paragraph
		valueDo: [ :aParagraph |
			aParagraph
				paintOn: aCompositorPainter canvas
				at: anOffset + self padding topLeft ]
		ifNone: [ self requestLayout ].

	aCompositorPainter
		pushChildren: self children sortedByElevation
		offset: anOffset
		compositing: self compositingMode
		thenPaint: [ :aChildElement :aChildPainter :aChildOffset |
			(self canAddTextToParagraph: aChildElement)
				ifFalse: [ aChildElement fullPaintOn: aChildPainter offset: aChildOffset ] ]
]
