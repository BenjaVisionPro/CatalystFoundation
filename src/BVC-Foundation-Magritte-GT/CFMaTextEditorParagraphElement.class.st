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
