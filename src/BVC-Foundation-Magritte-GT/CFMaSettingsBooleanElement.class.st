"
I preserve GT's Magritte boolean lifecycle while presenting its boolean control as a settings switch.
"
Class {
	#name : 'CFMaSettingsBooleanElement',
	#superclass : 'GtMagritteBooleanElement',
	#category : 'BVC-Foundation-Magritte-GT-Presentations-Settings',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Presentations-Settings'
}

{ #category : 'initialization' }
CFMaSettingsBooleanElement >> initializeCheckboxElement [
	checkboxElement := BrToggle new
		aptitude: CFMaSettingsSwitchAptitude new;
		yourself.

	checkboxElement
		when: BrToggleActivatedEvent do: [ self writeCheckedMemento ];
		when: BrToggleDeactivatedEvent do: [ self writeUncheckedMemento ].

	checkboxElement constraintsDo: [ :c | c linear vertical alignCenter ]
]

{ #category : 'private - updating' }
CFMaSettingsBooleanElement >> updateCheckbox: aGtMagritteValue [
	checkboxElement activated: (aGtMagritteValue currentValue ifNil: [ false ])
]
