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
		layout: BlFrameLayout new;
		fitContent;
		background: Color transparent;
		border: BlBorder empty;
		addAptitude: BrShadowAptitude new
]
