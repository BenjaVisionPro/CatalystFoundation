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
	self addChangeProperty: #(widget outskirts) with: [ BlOutskirts outside ].
	self
		addChangeProperty: #(widget background)
		with: [ Color white alpha: 1.0 ].

]
