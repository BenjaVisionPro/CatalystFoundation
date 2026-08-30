Class {
	#name : 'CFMaDetailTagAptitude',
	#superclass : 'BrGlamorousEditableLabelAptitude',
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'initialization' }
CFMaDetailTagAptitude >> initialize [
	super initialize.
	self add: (BrLazyStyleCommonAptitude new
		default: [ :aStyle |
			aStyle
				background: self theme controls tagBackgroundTint;
				geometry: (BlRoundedRectangleGeometry cornerRadius: 12);
				constraintsDo: [ :c |
					c minWidth: 20.
					c vertical exact: 20 ] ];
		when: [ :aState | aState hovered and: BrEditorModeState readOnly ]
			style: [ :aStyle |
				aStyle background: self theme controls tagHoveredBackgroundTint ];
		when: [ :aState | aState focused and: BrEditorModeState readOnly ]
			style: [ :aStyle |
				aStyle background: self theme item selectedColor ])
]


