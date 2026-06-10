Class {
	#name : 'CFMaRelationListItemAptitude',
	#superclass : 'BrGlamorousListItemAptitude',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'initialization' }
CFMaRelationListItemAptitude >> initialize [
	super initialize.

	self
		when: CFMaListFocusedState uniqueInstance & BlElementState selected
		style: [ :aStyle |
			aStyle background: self theme item selectedColor ];
		when: CFMaListFocusedState uniqueInstance not & BlElementState selected
		style: [ :aStyle |
			aStyle background: self theme item hoveredColor ]
]
