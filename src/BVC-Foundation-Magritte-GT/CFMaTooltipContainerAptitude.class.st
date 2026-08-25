Class {
	#name : 'CFMaTooltipContainerAptitude',
	#superclass : 'BrAptitude',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'initialization' }
CFMaTooltipContainerAptitude >> initialize [
	super initialize.

	"The stepped menu is positioning infrastructure only. The visible glass
	 surfaces are the tooltip content and handle themselves."
	self
		addChangeProperty: #(widget border)
		with: [ BlBorder empty ].
	self
		addChangeProperty: #(widget background)
		with: [ Color transparent ]
]
