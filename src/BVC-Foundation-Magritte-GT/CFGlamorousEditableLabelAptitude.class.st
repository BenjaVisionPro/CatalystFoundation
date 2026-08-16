"I am Foundation's editable-label aptitude. I keep Brick's normal editor styling while presenting focused read-only labels with Foundation's selection colour and their normal text foreground."

Class {
	#name : 'CFGlamorousEditableLabelAptitude',
	#superclass : 'BrGlamorousEditableLabelAptitude',
	#category : 'BVC-Foundation-Magritte-GT-Aptitudes',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Aptitudes'
}

{ #category : 'initialization' }
CFGlamorousEditableLabelAptitude >> initialize [
	super initialize.

	self add: (BrStyleCommonAptitude new
		when: [ :aState |
			aState focused and: BrEditorModeState readOnly ]
		style: [ :aStyle |
			aStyle background: self theme item selectedColor.
			aStyle do: [ self foreground: self defaultForeground ] ])
]
