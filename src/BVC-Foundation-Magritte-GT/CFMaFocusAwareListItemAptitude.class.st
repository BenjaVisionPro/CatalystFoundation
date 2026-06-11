Class {
	#name : 'CFMaFocusAwareListItemAptitude',
	#superclass : 'BrGlamorousListItemAptitude',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'initialization' }
CFMaFocusAwareListItemAptitude >> initialize [
	super initialize.

	self
		when: CFMaFocusWithinState uniqueInstance & BlElementState selected
		style: [ :aStyle |
			aStyle background: self theme item selectedColor ];
		when: CFMaFocusWithinState uniqueInstance not & BlElementState selected
		style: [ :aStyle |
			aStyle background: self theme item hoveredColor ]
]
