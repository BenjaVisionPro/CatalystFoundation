Class {
	#name : 'CFMaDetailPopupContainerAptitude',
	#superclass : 'BrAptitude',
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'initialization' }
CFMaDetailPopupContainerAptitude >> initialize [
	super initialize.

	self
		addChangeProperty: #(widget geometry)
		with: [ BlChildrenWrappingGeometry
			cornerRadius: CFMaDetailPopupMetrics menuCornerRadius
				enlargedBy: 1.5 ];
		addChangeProperty: #(widget background)
		with: [ Color transparent ];
		addChangeProperty: #(widget border)
		with: [ BlBorder empty ];
		addChangeProperty: #(widget outskirts)
		with: [ BlOutskirts inside ]
]
