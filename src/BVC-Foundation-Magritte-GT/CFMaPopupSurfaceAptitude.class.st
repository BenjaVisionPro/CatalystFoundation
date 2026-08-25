Class {
	#name : 'CFMaPopupSurfaceAptitude',
	#superclass : 'BrAptitude',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'initialization' }
CFMaPopupSurfaceAptitude >> initialize [
	super initialize.

	self
		addChangeProperty: #(widget border)
		with: [ BlBorder paint: Color veryLightGray width: 1 ].
	self
		addChangeProperty: #(widget background)
		with: [ Color white alpha: 0.65 ].
	self
		addChangeProperty: #(widget effect)
		with: [ BlBlurBelowEffect radius: 14 ]
]
