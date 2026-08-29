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
					enlargedBy: 2 ];
		addChangeProperty: #(widget background)
		with: [ Color transparent ];
		addChangeProperty: #(widget border)
		with: [ BlBorder empty ];
		addChangeProperty: #(widget outskirts)
		with: [ BlOutskirts inside ]
]
