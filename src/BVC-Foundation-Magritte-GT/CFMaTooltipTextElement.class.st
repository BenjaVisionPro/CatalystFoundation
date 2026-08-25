Class {
	#name : #CFMaTooltipTextElement,
	#superclass : #BlAttributedTextElement,
	#category : #'BVC-Foundation-Magritte-GT-Tooltip'
}

{ #category : #'private - paragraph' }
CFMaTooltipTextElement >> createTextParagraph [
	^ BlMultiLineTextParagraph new
]
