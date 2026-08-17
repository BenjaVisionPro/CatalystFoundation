Class {
	#name : 'CFMaSettingsCommentAptitude',
	#superclass : 'BrGlamorousLabelAptitude',
	#category : 'BVC-Foundation-Magritte-GT-Presentations-Settings',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Presentations-Settings'
}

{ #category : 'default' }
CFMaSettingsCommentAptitude >> defaultLabelElement [
	| anElement |
	anElement := CFMaMultilineTextElement new
		text: 'Label' asRopedText;
		tightMeasurement;
		padding: BlInsets empty;
		yourself.
	anElement constraintsDo: [ :c |
		c horizontal matchParent.
		c vertical fitContent ].
	^ anElement
]
