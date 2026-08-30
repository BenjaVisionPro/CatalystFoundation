Class {
	#name : 'CFGlassSurfaceAptitude',
	#superclass : 'BrAptitude',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'accessing' }
CFGlassSurfaceAptitude >> borderColor [
	^ self theme menu borderColor blocResolveColorForTheme: self theme
]

{ #category : 'initialization' }
CFGlassSurfaceAptitude >> initialize [
	super initialize.

	self
		addChangeProperty: #(widget effect)
		with: [ BlBlurBelowEffect radius: 10 ];
		add: (BrLazyStyleCommonAptitude new
			default: [ :aStyle |
				aStyle
					background:
						((self theme surfaces baseBackground
							blocResolveColorForTheme: self theme)
							alpha: 0.65);
					border: (BlBorder paint: self borderColor width: 1) ])
]
