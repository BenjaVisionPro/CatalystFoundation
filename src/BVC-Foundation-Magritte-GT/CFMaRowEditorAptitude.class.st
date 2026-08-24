"
I remove GT's per-editor hover/focus border when the enclosing form row owns interaction chrome.
"
Class {
	#name : 'CFMaRowEditorAptitude',
	#superclass : 'BrStyleCommonAptitude',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'initialization' }
CFMaRowEditorAptitude >> initialize [
	super initialize.

	self
		default: [ :aStyle | aStyle border: BlBorder empty ];
		hovered: [ :aStyle | aStyle border: BlBorder empty ];
		focused: [ :aStyle | aStyle border: BlBorder empty ]
]
