Class {
	#name : 'CFMaDetailTagAptitude',
	#superclass : 'BrGlamorousEditableLabelAptitude',
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'initialization' }
CFMaDetailTagAptitude >> initialize [
	super initialize.
	self add: (BrStyleCommonAptitude new
		default: [ :aStyle |
			aStyle geometry: (BlRoundedRectangleGeometry cornerRadius: 12) ])
]
