"I remove GT's per-editor hover/focus border in the settings presentation. The enclosing row owns interaction chrome."

Class {
	#name : 'CFMaSettingsEditorAptitude',
	#superclass : 'BrStyleCommonAptitude',
	#category : 'BVC-Foundation-Magritte-GT-Presentations-Settings',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Presentations-Settings'
}

{ #category : 'initialization' }
CFMaSettingsEditorAptitude >> initialize [
	super initialize.

	self
		default: [ :aStyle | aStyle border: BlBorder empty ];
		hovered: [ :aStyle | aStyle border: BlBorder empty ];
		focused: [ :aStyle | aStyle border: BlBorder empty ]
]
