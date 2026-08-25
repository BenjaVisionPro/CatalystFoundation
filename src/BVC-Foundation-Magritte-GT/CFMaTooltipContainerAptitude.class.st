Class {
	#name : 'CFMaTooltipContainerAptitude',
	#superclass : 'CFMaPopupSurfaceAptitude',
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
				enlargedBy: 2 ].
	self addChangeProperty: #(widget outskirts) with: [ BlOutskirts inside ]
]
