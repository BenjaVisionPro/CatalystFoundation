Class {
	#name : 'CFMaTooltipContainerAptitude',
	#superclass : 'BrAptitude',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'initialization' }
CFMaTooltipContainerAptitude >> initialize [
	super initialize.

	self
		addChangeProperty: #(widget geometry)
		with: [ BlChildrenWrappingGeometry
				cornerRadius: BrMenuConstants cornerRadius
				enlargedBy: 1 ].
	self
		addChangeProperty: #(widget border)
		with: [ BlBorder paint: Color veryLightGray width: 1 ].
	self addChangeProperty: #(widget outskirts) with: [ BlOutskirts centered ].
	self
		addChangeProperty: #(widget background)
		with: [ Color white alpha: 0.85 ].
	self
		addChangeProperty: #(widget effect)
		with: [ BlBlurBelowEffect radius: 14 ].

]
