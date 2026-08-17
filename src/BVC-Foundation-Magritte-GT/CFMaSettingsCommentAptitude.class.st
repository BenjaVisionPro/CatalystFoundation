Class {
	#name : 'CFMaSettingsCommentAptitude',
	#superclass : 'BrGlamorousLabelAptitude',
	#category : 'BVC-Foundation-Magritte-GT-Presentations-Settings',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Presentations-Settings'
}

{ #category : 'default' }
CFMaSettingsCommentAptitude >> defaultLabelElement [
	^ CFMaMultilineTextElement new
		text: 'Label' asRopedText;
		tightMeasurement;
		hMatchParent;
		vFitContent;
		padding: BlInsets empty;
		yourself
]
