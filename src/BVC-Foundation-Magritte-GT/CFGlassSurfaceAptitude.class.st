Class {
	#name : 'CFGlassSurfaceAptitude',
	#superclass : 'BrAptitude',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'initialization' }
CFGlassSurfaceAptitude >> initialize [
	super initialize.

	self
		addChangeProperty: #(widget border)
		with: [ BlBorder paint: Color veryLightGray width: 1 ];
		addChangeProperty: #(widget effect)
		with: [ BlCompositeEffect effects: {
			BlBlurBelowEffect radius: 14.
			BlGaussianShadowEffect
				color: (Color black alpha: 0.30)
				width: 8
				offset: 0 @ 3 } ];
		add: (BrLazyStyleCommonAptitude new
			default: [ :aStyle |
				aStyle background:
					((self theme surfaces baseBackground
						blocResolveColorForTheme: self theme)
						alpha: 0.65) ])
]
