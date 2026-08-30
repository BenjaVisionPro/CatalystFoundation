Class {
	#name : #CFMaTooltipShadowElement,
	#superclass : #CFGlassShadowElement,
	#category : #'BVC-Foundation-Magritte-GT-Tooltip'
}

{ #category : #initialization }
CFMaTooltipShadowElement >> initialize [
	super initialize.

	self addAptitude: (BrLazyStyleCommonAptitude new
		default: [ :aStyle |
			aStyle do: [
				self geometry: (BlRoundedRectangleGeometry cornerRadius: self theme tooltip cornerRadius) ] ])
]
