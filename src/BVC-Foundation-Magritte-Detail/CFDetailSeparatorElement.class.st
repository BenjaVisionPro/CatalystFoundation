Class {
	#name : 'CFDetailSeparatorElement',
	#superclass : 'BlElement',
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'initialization' }
CFDetailSeparatorElement >> initialize [
	super initialize.
	self background: Color transparent
]

{ #category : 'api - theme' }
CFDetailSeparatorElement >> onThemeChanged [
	super onThemeChanged.
	self background: self theme surfaces separatorTint
]
