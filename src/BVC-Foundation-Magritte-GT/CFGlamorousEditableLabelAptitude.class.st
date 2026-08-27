"
I am Foundation's editable-label visual aptitude. I preserve Brick's editable-label styling except that focused read-only labels use Foundation selection colour and retain their configured text foreground.
"
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

	self remove: styleLook.

	self add:
		(styleLook := BrStyleCommonAptitude new
			default: [ :aStyle |
				aStyle geometry: (BlRoundedRectangleGeometry cornerRadius: 4).
				aStyle background: defaultBackground.
				aStyle border: BlBorder empty ];
			when: BrEditorModeState editable
				style: [ :aStyle |
					aStyle background: Color white ];
			when: [ :aState |
				aState focused not and: BrEditorModeState editable ]
				style: [ :aStyle |
					aStyle border: (BlBorder
						paint: defaultBorderColor
						width: 1) ];
			when: [ :aState |
				aState focused and: BrEditorModeState editable ]
				style: [ :aStyle |
					aStyle border: (BlBorder
						paint: self theme foundation highlightColor
						width: 1) ];
			when: [ :aState |
				aState hovered and: BrEditorModeState readOnly ]
				style: [ :aStyle |
					aStyle background: defaultBackground darker ];
			when: [ :aState |
				aState focused and: BrEditorModeState readOnly ]
				style: [ :aStyle |
					aStyle background: self theme item selectedColor.
					aStyle
						do: [ self foreground: self defaultForeground ]
						after: [ self foreground: self defaultForeground ] ])
]
