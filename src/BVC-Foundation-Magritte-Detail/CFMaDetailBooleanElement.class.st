"I preserve GT Magritte's boolean field lifecycle while presenting the boolean control as a Detail switch."

Class {
	#name : 'CFMaDetailBooleanElement',
	#superclass : 'GtMagritteBooleanElement',
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'initialization' }
CFMaDetailBooleanElement >> initializeCheckboxElement [
	checkboxElement := BrToggle new
		aptitude: CFMaDetailSwitchAptitude new;
		yourself.

	checkboxElement
		when: BrToggleActivatedEvent do: [ self writeCheckedMemento ];
		when: BrToggleDeactivatedEvent do: [ self writeUncheckedMemento ].

	checkboxElement constraintsDo: [ :c | c linear vertical alignCenter ]
]

{ #category : 'private - updating' }
CFMaDetailBooleanElement >> updateCheckbox: aGtMagritteValue [
	checkboxElement activated: (aGtMagritteValue currentValue ifNil: [ false ])
]
