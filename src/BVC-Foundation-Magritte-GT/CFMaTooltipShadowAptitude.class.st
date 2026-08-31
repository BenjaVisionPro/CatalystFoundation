Class {
	#name : #CFMaTooltipShadowAptitude,
	#superclass : #BrAptitude,
	#category : #'BVC-Foundation-Magritte-GT-Tooltip'
}

{ #category : #initialization }
CFMaTooltipShadowAptitude >> initialize [
	super initialize.

	self
		addChangeProperty: #(widget effect)
		with: [
			BlGaussianShadowEffect
				color: (self theme tooltip shadowColor
					blocResolveColorForTheme: self theme)
				width: self theme tooltip shadowWidth
				offset: self theme tooltip shadowOffset ]
]
