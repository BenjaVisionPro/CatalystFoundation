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
		addChangeProperty: #(widget background)
		with: [ Color transparent ];
		addChangeProperty: #(widget border)
		with: [ BlBorder empty ]
]
