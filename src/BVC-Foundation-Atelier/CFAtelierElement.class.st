"I am the visible Atelier host when orchestration UI is configured around a normal Foundation Magritte form.

The form remains the element produced by CFMaViewModel. I only arrange Atelier-owned UI beside it; I do not render Magritte descriptions myself."
Class {
	#name : 'CFAtelierElement',
	#superclass : 'BrHorizontalPane',
	#instVars : [
		'paletteElement',
		'formElement'
	],
	#category : 'BVC-Foundation-Atelier-UI',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'UI'
}

{ #category : 'initialization' }
CFAtelierElement >> initialize [
	super initialize.
	self
		hMatchParent;
		vFitContent;
		cellSpacing: 12
]

{ #category : 'accessing' }
CFAtelierElement >> formElement [
	^ formElement
]

{ #category : 'accessing' }
CFAtelierElement >> formElement: anElement [
	formElement ifNotNil: [ self removeChild: formElement ].
	formElement := anElement.
	formElement
		hMatchParent;
		vFitContent.
	self addChild: formElement
]

{ #category : 'accessing' }
CFAtelierElement >> paletteElement [
	^ paletteElement
]

{ #category : 'accessing' }
CFAtelierElement >> palette: anAtelierPalette [
	paletteElement ifNotNil: [ self removeChild: paletteElement ].
	paletteElement := CFAtelierPaletteElement new
		palette: anAtelierPalette;
		yourself.
	self addChild: paletteElement at: 1
]
