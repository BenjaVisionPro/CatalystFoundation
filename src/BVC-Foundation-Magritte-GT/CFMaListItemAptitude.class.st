"
I am responsible for presenting a selected Foundation list item according to whether its selection context is active.
"
Class {
	#name : 'CFMaListItemAptitude',
	#superclass : 'BrGlamorousListItemAptitude',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}


{ #category : 'private - appearance' }
CFMaListItemAptitude >> inactiveSelectionColour [
	| aColor aGrey desaturation aRed aGreen aBlue |
	aColor := self theme appearanceState textSelectionColour.
	aGrey := (aColor red * 0.2126) + (aColor green * 0.7152) + (aColor blue * 0.0722).
	desaturation := 0.50.
	aRed := aColor red + ((aGrey - aColor red) * desaturation).
	aGreen := aColor green + ((aGrey - aColor green) * desaturation).
	aBlue := aColor blue + ((aGrey - aColor blue) * desaturation).
	^ Color
		r: aRed + ((1.0 - aRed) * 0.30)
		g: aGreen + ((1.0 - aGreen) * 0.30)
		b: aBlue + ((1.0 - aBlue) * 0.30)
		alpha: aColor alpha
]

{ #category : 'initialization' }
CFMaListItemAptitude >> initialize [
	super initialize.

	self
		when: CFMaActiveSelectionState uniqueInstance & BlElementState selected
		style: [ :aStyle |
			aStyle
			background: Color transparent;
			effect: (BlOverlayAboveEffect new
				paint: (self theme appearanceState textSelectionColour blocResolveColorForTheme: self theme)) ];
		when: CFMaActiveSelectionState uniqueInstance not & BlElementState selected
		style: [ :aStyle |
			aStyle
			background: Color transparent;
			effect: (BlOverlayAboveEffect new
				paint: (self inactiveSelectionColour)) ]
]
