Class {
	#name : 'CFMaDetailTagAptitude',
	#superclass : 'BrGlamorousEditableLabelAptitude',
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'initialization' }
CFMaDetailTagAptitude >> initialize [
	super initialize.
	self add: (BrStyleCommonAptitude new
		default: [ :aStyle |
			aStyle
				geometry: (BlRoundedRectangleGeometry cornerRadius: 12);
				constraintsDo: [ :c |
					c minWidth: 20.
					c vertical exact: 20 ] ])
]


{ #category : #'theme - applying' }
CFMaDetailTagAptitude >> applyTheme: aTheme [
	defaultBackground := aTheme controls tagBackgroundTint blocResolveColorForTheme: aTheme.
	focusedBackground := aTheme highlight color blocResolveColorForTheme: aTheme.
	self widgetDo: [ :aWidget | aWidget requestStyle ]
]
