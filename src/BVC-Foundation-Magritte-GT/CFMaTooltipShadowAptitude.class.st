Class {
	#name : #CFMaTooltipShadowAptitude,
	#superclass : #BrShadowAptitude,
	#category : #'BVC-Foundation-Magritte-GT-Tooltip'
}

{ #category : #initialization }
CFMaTooltipShadowAptitude >> initialize [
	super initialize.

	self
		color: (self theme tooltip shadowColor
			blocResolveColorForTheme: self theme);
		width: self theme tooltip shadowWidth;
		offset: self theme tooltip shadowOffset
]
