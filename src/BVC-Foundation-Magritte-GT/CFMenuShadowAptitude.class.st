Class {
	#name : #CFMenuShadowAptitude,
	#superclass : #BrAptitude,
	#category : #'BVC-Foundation-Magritte-GT'
}

{ #category : #initialization }
CFMenuShadowAptitude >> initialize [
	super initialize.

	self
		addChangeProperty: #(widget effect)
		with: [
			BlGaussianShadowEffect
				color: (self theme menu shadowColor
					blocResolveColorForTheme: self theme)
				width: self theme menu shadowWidth
				offset: self theme menu shadowOffset ]
]
