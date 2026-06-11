Class {
	#name : 'CFMaFocusWithinAptitude',
	#superclass : 'BrAptitude',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'initialization' }
CFMaFocusWithinAptitude >> initializeListeners [
	super initializeListeners.

	self
		when: BlFocusInEvent
		do: [ :anEvent |
			anEvent currentTarget states addState: CFMaFocusWithinState uniqueInstance ];
		when: BlFocusOutEvent
		do: [ :anEvent |
			anEvent currentTarget states removeState: CFMaFocusWithinState uniqueInstance ]
]
