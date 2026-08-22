"
I present a Foundation settings row. Hover is row-level, and focus is shown whenever focus is within the row hierarchy.
"
Class {
	#name : 'CFMaSettingsRowAptitude',
	#superclass : 'BrStyleCommonAptitude',
	#category : 'BVC-Foundation-Magritte-GT-Presentations-Settings',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Presentations-Settings'
}

{ #category : 'initialization' }
CFMaSettingsRowAptitude >> initialize [
	super initialize.

	self
		default: [ :aStyle |
			aStyle border: BlBorder empty ];
		hovered: [ :aStyle |
			aStyle background: (Color black alpha: 0.025) ]
]
