Class {
	#name : 'CFGlassShadowElement',
	#superclass : 'BlElement',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'initialization' }
CFGlassShadowElement >> initialize [
	super initialize.

	self
		beInSeparateCompositionLayer;
		layout: BlFrameLayout new;
		constraintsDo: [ :c |
			c horizontal fitContent.
			c vertical fitContent ];
		background: Color transparent;
		border: BlBorder empty;
		addAptitude: (BrShadowAptitude new
			color: (Color black alpha: 0.3))
]
