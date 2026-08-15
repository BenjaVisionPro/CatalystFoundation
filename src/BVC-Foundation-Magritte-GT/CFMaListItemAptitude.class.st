"I am responsible for presenting a selected Foundation list item according to whether its selection context is active."

Class {
	#name : 'CFMaListItemAptitude',
	#superclass : 'BrGlamorousListItemAptitude',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'initialization' }
CFMaListItemAptitude >> initialize [
	super initialize.

	self
		when: CFMaActiveSelectionState uniqueInstance & BlElementState selected
		style: [ :aStyle |
			aStyle effect: (BlOverlayAboveEffect new
				paint: self theme item selectedColor) ];
		when: CFMaActiveSelectionState uniqueInstance not & BlElementState selected
		style: [ :aStyle |
			aStyle effect: (BlOverlayAboveEffect new
				paint: (Color black alpha: 0.04)) ]
]
