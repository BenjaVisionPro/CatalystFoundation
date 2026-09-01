"I select Foundation's fixed-colour picker representation for an ordinary
Magritte single-option field. Domain options remain owned by the description."

Class {
	#name : 'CFMaColourPickerConfiguration',
	#superclass : 'CFMaFieldRepresentationConfiguration',
	#instVars : [
		'colourBlock',
		'labelBlock'
	],
	#category : 'BVC-Foundation-Magritte-Core-Field',
	#package : 'BVC-Foundation-Magritte-Core',
	#tag : 'Field'
}

{ #category : 'initialization' }
CFMaColourPickerConfiguration >> initialize [
	super initialize.
	colourBlock := [ :anOption | anOption ].
	labelBlock := [ :anOption |
		anOption ifNil: [ 'Automatic' ] ifNotNil: [ anOption printString ] ]
]

{ #category : 'accessing' }
CFMaColourPickerConfiguration >> colourBlock [
	^ colourBlock
]

{ #category : 'accessing' }
CFMaColourPickerConfiguration >> colourBlock: aBlock [
	colourBlock := aBlock
]

{ #category : 'accessing' }
CFMaColourPickerConfiguration >> labelBlock [
	^ labelBlock
]

{ #category : 'accessing' }
CFMaColourPickerConfiguration >> labelBlock: aBlock [
	labelBlock := aBlock
]
