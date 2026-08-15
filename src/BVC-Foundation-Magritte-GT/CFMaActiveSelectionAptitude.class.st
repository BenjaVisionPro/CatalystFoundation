"I am responsible for marking a selection context active while focus is within its widget hierarchy."

Class {
	#name : 'CFMaActiveSelectionAptitude',
	#superclass : 'BrAptitude',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'initialization' }
CFMaActiveSelectionAptitude >> initializeListeners [
	super initializeListeners.

	self
		when: BlFocusInEvent
		do: [ :anEvent |
			self widget states addState: CFMaActiveSelectionState uniqueInstance ];
		when: BlFocusOutEvent
		do: [ :anEvent |
			self widget hasFocus ifFalse: [
				self widget states removeState: CFMaActiveSelectionState uniqueInstance ] ]
]
