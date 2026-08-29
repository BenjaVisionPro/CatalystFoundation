Class {
	#name : 'CFDetailSeparatorElement',
	#superclass : 'BlElement',
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'initialization' }
CFDetailSeparatorElement >> initialize [
	super initialize.
	self
		background: Color transparent;
		addAptitude: (BrLazyStyleCommonAptitude new
			default: [ :aStyle |
				aStyle background: self theme surfaces separatorTint ])
]

