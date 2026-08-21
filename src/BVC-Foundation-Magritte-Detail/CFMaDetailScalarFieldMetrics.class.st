Class {
	#name : 'CFMaDetailScalarFieldMetrics',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'metrics' }
CFMaDetailScalarFieldMetrics class >> trailingControlInset [
	"BrEditor>>initialize uses 5px padding. Trailing scalar controls use the same
	inset so their visible right edge aligns with editor text, not the editor box."
	^ 5
]
