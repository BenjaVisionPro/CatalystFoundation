Class {
	#name : #CFMaTooltipLabelAptitude,
	#superclass : #BrGlamorousLabelAptitude,
	#category : #'BVC-Foundation-Magritte-GT-Tooltip'
}

{ #category : #default }
CFMaTooltipLabelAptitude >> defaultLabelElement [
	^ CFMaTooltipTextElement new
		text: 'Label' asRopedText;
		tightMeasurement;
		padding: (BlInsets all: 1);
		yourself
]
