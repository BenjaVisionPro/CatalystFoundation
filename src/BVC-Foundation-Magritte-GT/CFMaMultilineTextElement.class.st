Class {
	#name : 'CFMaMultilineTextElement',
	#superclass : 'BlAttributedTextElement',
	#category : 'BVC-Foundation-Magritte-GT-Elements',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Elements'
}

{ #category : 'private - paragraph' }
CFMaMultilineTextElement >> createTextParagraph [
	^ BlMultiLineTextParagraph new
]
